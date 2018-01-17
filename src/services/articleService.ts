import {Model, Document} from "mongoose";
import * as moment from "moment";
import {isEmpty, pickBy} from "lodash";

export interface IArticle {
  _id: string;
  title: string;
  content: string;
  createDate: Date | string;
}

export interface IArticleService {
  create({
    content,
    title
  }: {
    content: string;
    title: string;
  }): Promise<IArticle>;

  findById(id: string): Promise<IArticle | null>;
  find(query?: object): Promise<IArticle[]>;
  update({id, data}: {id: string; data: {content?: string, title?: string}}): Promise<any>;
  destroy(id: string): Promise<void>;
}

export class ArticleService implements IArticleService {
  private articleModel: Model<Document>;

  constructor(
    {articleModel}:
    {articleModel: Model<Document>}) {
    this.articleModel = articleModel;
  }

  public async create(
    {
      title,
      content
  }: {
    title: string;
    content: string;
  }) {
      const now = moment.utc();
      const user: any = await this.articleModel.create({
        title,
        content,
        createDate: now.toDate()
      });
      return user.toObject() as IArticle;
  }

  public findById(id: string): Promise<IArticle | null> {
    return this.articleModel
    .findById(id)
    .exec()
    .then((article: any) => (article) ? article.toObject() as IArticle : null);
  }

  public async find(query?: object): Promise<IArticle[]> {
    const articles = await this.articleModel
    .find(query)
    .exec();

    return (isEmpty(articles)) ? [] : articles.map((article: any) => article.toObject() as IArticle);
  }

  public update({id, data}: {id: string; data: {content?: string, title?: string}}): Promise<any> {
    // filter undefined
    data = pickBy(data);
    return this.articleModel.findOneAndUpdate({_id: id}, data).exec();
  }

  public destroy(id: string): Promise<void> {
    return this.articleModel.remove({_id: id}).exec();
  }
}
