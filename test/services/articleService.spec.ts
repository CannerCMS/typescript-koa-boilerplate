// tslint:disable:no-unused-expression
import {ArticleService, IArticleService} from "../../src/services/articleService";
import {bootstrap} from "../../src/models";
import createConfig from "../../src/config";
import * as mongoose from "mongoose";
import * as chai from "chai";
const expect = chai.expect;

describe("article service", () => {
  let articleService: IArticleService;
  let articleId: string;

  before(async () => {
    // load config
    const config = createConfig();
    // bootstrap db
    await bootstrap("mongodb://localhost:27017/unit-testing");
    const articleModel = mongoose.model("Articles");
    articleService = new ArticleService({articleModel});
  });

  it("should create article", async () => {
    const article = await articleService.create({
      content: "content",
      title: "title"
    });
    expect(article).to.be.ok;
    articleId = article._id;
  });

  it("should find article by id", async () => {
    const article = await articleService.findById(articleId);
    expect(article).to.be.ok;
    expect(article.content).to.be.eql("content");
    expect(article.title).to.be.eql("title");
  });

  it("should findAll article", async () => {
    const articles = await articleService.find();
    expect(articles).to.be.ok;
    expect(articles.length).to.be.eql(1);
  });

  it("should update article", async () => {
    await articleService.update({
      id: articleId,
      data: {
        content: "content2"
      }
    });

    const article = await articleService.findById(articleId);
    expect(article).to.be.ok;
    expect(article.content).to.be.eql("content2");
    expect(article.title).to.be.eql("title");
  });

  it("should delete article", async () => {
    await articleService.destroy(articleId);

    const article = await articleService.findById(articleId);
    expect(article).to.be.null;
  });

  after(async () => {
    const articleModel = mongoose.model("Articles");
    await articleModel.remove({}).exec();
  });
});
