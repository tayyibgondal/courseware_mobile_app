const express = require("express");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const CareerPath = require("./models/CareerPath");
const uploadMiddleware = multer({ dest: "uploads" });
const fs = require("fs");

const secretKey = "kshdi7a8aifh8o373q9fg";

const router = express.Router();

// ====================== CAREER PATH ENDPOINTS =============================

// To get all career paths
router.get("/", async (req, res) => {
  const careerPaths = await CareerPath.find().sort({ createdAt: -1 }).limit(20);
  res.status(200).json(careerPaths);
});

// To get one career path by ID
router.get("/:careerPathId", async (req, res) => {
  try {
    const { careerPathId } = req.params;
    const careerPath = await CareerPath.findById(careerPathId);
    // ----------------------------------
    // if (!careerPath) {
    // res.status(404).json({ message: "CareerPath not found" });
    // } else {
    // ----------------------------------
    res.status(200).json(careerPath);
    // ----------------------------------
    // }
    // ----------------------------------
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error!" });
  }
});

// To create a career path
router.post("/create", uploadMiddleware.single("file"), async (req, res) => {
  try {
    let newPath = null;
    // -----------------------------
    // try {
    //   const { originalname, path } = req.file;
    //   const parts = originalname.split(".");
    //   const ext = parts[parts.length - 1];
    //   const newPath = path + "." + ext;
    //   fs.renameSync(path, newPath);
    // } catch (e) {
    //   newPath = null;
    // }
    // -----------------------------

    const { title, description } = req.body;
    if (!title || !description) {
      throw new Error("Missing required fields!");
    }
    const careerPath = await CareerPath.create({
      title,
      description,
      file: newPath,
    });
    res
      .status(200)
      .json({ message: "CareerPath added!", careerPath: careerPath });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error!" });
  }
});

// To update a career path
router.put(
  "/edit/:careerPathId",
  uploadMiddleware.single("file"),
  async (req, res) => {
    const { careerPathId } = req.params;
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

      const { title, description } = req.body;
      const careerPathOld = await CareerPath.findById(careerPathId);
      const updatedCareerPath = await CareerPath.findByIdAndUpdate(
        careerPathId,
        {
          title,
          description,
          file: newPath == null ? careerPathOld.file : newPath,
        },
        { new: true }
      );
      res.status(200).json({ message: "CareerPath updated!" });
    } catch (error) {
      res.status(500).json({ message: "Internal Server Error!" });
    }
  }
);

// To delete a career path by ID
router.delete("/delete/:careerPathId", async (req, res) => {
  try {
    const { careerPathId } = req.params;
    const careerPath = await CareerPath.findById(careerPathId);

    // --------------------------------------
    // if (!careerPath) {
    // --------------------------------------
    res.status(404).json({ message: "CareerPath not found" });
    // --------------------------------------
    // } else {
    // // Remove the associated file from the uploads folder
    // if (careerPath.file) {
    //   fs.unlinkSync(careerPath.file);
    // }
    // --------------------------------------

    // Delete the career path from the database
    await CareerPath.findByIdAndDelete(careerPathId);
    res.status(200).json({ message: "CareerPath deleted!" });
    // }
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error!" });
  }
});

// Search functionality for career paths
router.get("/search/:query", async (req, res) => {
  const { query } = req.params;
  const searchResults = await CareerPath.find(
    { $text: { $search: query } },
    { score: { $meta: "textScore" } }
  )
    .sort({ score: { $meta: "textScore" } })
    .limit(5)
    .exec();

  if (searchResults.length === 0) {
    res.status(404).json({ message: "No results found" });
  } else {
    res.status(200).json(searchResults);
  }
});

module.exports = router;
