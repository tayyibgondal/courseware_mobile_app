const mongoose = require("mongoose");

const faqSchema = mongoose.Schema(
  {
    question: {
      type: String,
    },
    answer: {
      type: String,
    },
  },
  {
    timestamps: true,
  }
);

const faqModel = mongoose.model("FAQ", faqSchema);

module.exports = faqModel;
