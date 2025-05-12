const mongoose = require("mongoose");

const CourseSchema = mongoose.Schema(
  {
    name: String,
    instructor: String,
    email: String,
    university: String,
    year: String,
    description: String,
    content: String,
    uploader: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
  },
  { timestamps: true }
);

CourseSchema.index({
  name: "text",
  instructor: "text",
  email: "text",
  university: "text",
  year: "text",
  description: "text",
});

const CourseModel = mongoose.model("Course", CourseSchema);

module.exports = CourseModel;
