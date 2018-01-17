import * as mongoose from "mongoose";
const Schema = mongoose.Schema;

const schema = new Schema({
  title: String,
  content: String,
  createDate: Date
});

module.exports = mongoose.model("Articles", schema);
