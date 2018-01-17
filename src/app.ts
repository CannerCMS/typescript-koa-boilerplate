import * as Koa from "koa";
import * as morgan from "koa-morgan";
import * as bodyParser from "koa-bodyparser";
import * as Router from "koa-router";
import * as cors from "@koa/cors";
import {bootstrap} from "./models";
import createConfig from "./config";
import * as mongoose from "mongoose";

// service
import { ArticleService } from "./services/articleService";

// ctrl
import { ArticleCtrl, mount as mountArticle } from "./controllers/articleCtrl";

export const createApp = async (): Promise<Koa> => {
  // load config
  const config = createConfig();

  // bootstrap db
  await bootstrap(config.mongoUrl);

  // cors
  const corsMid = cors({
    allowHeaders: ["Content-Type"],
    credentials: true
  });

  const app = new Koa();
  app.use(async (ctx, next) => {
    try {
      await next();
    } catch (err) {
      // tslint:disable-next-line:no-console
      console.log(err);
      const errorCode = (err.isBoom && err.data && err.data.code) ? err.data.code : "INTERNAL_ERROR";
      const statusCode =
        (err.isBoom && err.output && err.output.statusCode) ? err.output.statusCode : err.status || 500;

      ctx.status = statusCode;
      ctx.body = {code: errorCode, message: err.message};
    }
  });
  app.use(bodyParser());
  app.use(morgan("combined"));

  // root router
  const rootRouter = new Router();

  // health check
  rootRouter.get("/", async ctx => {
    ctx.body = "running healthy!";
  });

  // robot
  rootRouter.get("/robots.txt", async ctx => {
    ctx.body = "User-agent: *\nAllow:";
  });

  rootRouter.all("*", corsMid);

  // compose together
  const articleModel = mongoose.model("Articles");
  const articleService = new ArticleService({articleModel});
  const articleCtrl = new ArticleCtrl({articleService});

  // mount controllers
  mountArticle(rootRouter, articleCtrl);

  // mount rootRouter
  app.use(rootRouter.routes());
  return app;
};
