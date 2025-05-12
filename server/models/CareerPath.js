const mongoose = require("mongoose");

// Create the schema
const CareerPathSchema = mongoose.Schema(
  {
    title: String,
    description: String,
    file: String
  },
  { timestamps: true }
);

CareerPathSchema.index({
  title: "text",
  description: "text",
});

const CareerPathModel = mongoose.model("CareerPath", CareerPathSchema);

module.exports = CareerPathModel;
