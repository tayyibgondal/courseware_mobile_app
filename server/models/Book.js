const mongoose = require("mongoose");

const BookSchema = mongoose.Schema(
  {
    title: String,
    summary: String,
    author: String,
    book: String,
    uploader: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  },
  { timestamps: true }
);

BookSchema.index({
  title: "text",
  summary: "text",
  author: "text",
});

const BookModel = mongoose.model("Book", BookSchema);

module.exports = BookModel;
