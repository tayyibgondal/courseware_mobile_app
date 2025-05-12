const express = require("express");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const Course = require("./models/Course");
const uploadMiddleware = multer({ dest: "uploads" });
const fs = require("fs");

// Create a salt
const secretKey = "kshdi7a8aifh8o373q9fg";

// Create a router
const router = express.Router();

// ====================== COURSE ENDPOINTS =============================
// To get all courses - 1 step
router.get("/", async (req, res) => {
  const courses = await Course.find()
    .populate("uploader", ["username"])
    .sort({ createdAt: -1 })
    .limit(20);
  res.status(200).json(courses);
});

// To get 1 course - 1 step
router.get("/:courseId", async (req, res) => {
  try {
    const { courseId } = req.params;
    const course = await Course.findById(courseId).populate("uploader", [
      "username",
    ]);
    res.status(200).json(course);
  } catch (e) {
    res.status(500).json({ message: "Internal server error!" });
  }
});

// To create a course - 3 steps
router.post("/create", uploadMiddleware.single("file"), async (req, res) => {
  let newPath = null;
  try {
    // Handle file upload if present
    if (req.file) {
      const { originalname, path } = req.file;
      const parts = originalname.split(".");
      const ext = parts[parts.length - 1];
      newPath = path + "." + ext;
      fs.renameSync(path, newPath);
    }

    const { name, instructor, email, university, year, description, userId } = req.body;
    
    // Only name, instructor, university, year, and description are required
    if (!name || !instructor || !university || !year || !description) {
      return res.status(400).json({ message: "Missing required fields" });
    }
    
    const courseData = {
      name,
      instructor,
      university,
      year,
      description,
      content: newPath,
    };

    // Add optional fields if present
    if (email) courseData.email = email;
    if (userId) courseData.uploader = userId;

    const course = await Course.create(courseData);
    res.status(201).json({ message: "Course added!", course: course });
  } catch (e) {
    console.error("Course creation error:", e);
    res.status(500).json({ message: "Error creating course: " + e.message });
  }
});

// To update a book - 4 steps
router.put(
  "/edit/:courseId",
  uploadMiddleware.single("file"),
  async (req, res) => {
    const { courseId } = req.params;
    // If user has sent file, update its extension in the saved folder
    let newPath = null;
    try {
      // -----------------------------
      // if (req.file) {
      //   const { originalname, path } = req.file;
      //   const parts = originalname.split(".");
      //   const ext = parts[parts.length - 1];
      //   newPath = path + "." + ext;
      //   fs.renameSync(path, newPath);
      // }
      // -----------------------------

      const { name, instructor, email, university, year, description } =
        req.body;
      const courseOld = await Course.findById(courseId);
      // Use findByIdAndUpdate with the correct syntax
      const updatedCourse = await Course.findByIdAndUpdate(
        courseId,
        {
          name,
          instructor,
          email,
          university,
          year,
          description,
          content: newPath == null ? courseOld.content : newPath,
        },
        { new: true } // This option returns the modified document, not the original
      );
      res.status(200).json({ message: "Course updated!" });
    } catch (err) {
      res.status(500).json({ message: "Internal server error!" });
    }
  }
);

// Delete endpoint
router.delete("/delete/:courseId", async (req, res) => {
  const { courseId } = req.params;
  try {
    const course = await Course.findByIdAndDelete(courseId);
    // --------------------------------------
    // if (!course) {
    //   return res.status(404).json({ message: "Course not found" });
    // }
    // --------------------------------------
    res.json({ message: "Deleted successfully" });
  } catch (e) {
    res.status(500).json({ message: "Internal server error!" });
  }
});

// Search functionality
router.get("/search/:query", async (req, res) => {
  const { query } = req.params;
  const searchResults = await Course.find(
    { $text: { $search: query } },
    { score: { $meta: "textScore" } }
  )
    .sort({ score: { $meta: "textScore" } })
    .limit(5)
    .exec();

  if (searchResults.length === 0) {
    // If no results found, respond with 404 status
    res.status(404).json({ message: "No results found" });
  } else {
    // If results found, respond with the search results
    res.status(200).json(searchResults);
  }
});

module.exports = router;
