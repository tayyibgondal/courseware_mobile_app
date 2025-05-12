const mongoose = require("mongoose");

const PostSchema = mongoose.Schema(
  {
    title: String,
    summary: String,
    content: String,
    cover: String,
    author: {type: mongoose.Schema.Types.ObjectId, ref: 'User'}
  },
  { timestamps: true }
);

PostSchema.index({ title: "text", summary: "text", content: "text" });

const PostModel = mongoose.model("Post", PostSchema);

module.exports = PostModel;