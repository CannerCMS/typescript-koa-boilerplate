import mongoose = require("mongoose");
import * as BPromise from "bluebird";
mongoose.Promise = BPromise;

export const bootstrap = async (mongoUrl: string) => {
  await mongoose.connect(mongoUrl, { useMongoClient: true });
  require("./articles");
};
