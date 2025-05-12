const express = require("express");
const jwt = require("jsonwebtoken");
const multer = require("multer");
const Book = require("./models/Book");
const uploadMiddleware = multer({ dest: "uploads" });
const fs = require("fs");

// Create a salt
const secretKey = "kshdi7a8aifh8o373q9fg";

// Create a router
const router = express.Router();

// ====================== BOOK ENDPOINTS =============================
// To get all books - 1 step
router.get("/", async (req, res) => {
  const books = await Book.find()
    .populate("uploader", ["username"])
    .sort({ createdAt: -1 })
    .limit(20);
  res.status(200).json(books);
});

// To get 1 book - 1 step
router.get("/:bookId", async (req, res) => {
  try {
    const { bookId } = req.params;
    const book = await Book.findById(bookId).populate("uploader", ["username"]);
    res.status(200).json(book);
  } catch (e) {
    res.status(500).json({ message: "Internal server error!" });
  }
});

// To create a book - 3 steps
router.post("/create", uploadMiddleware.single("file"), async (req, res) => {
  let newPath = null;
  try {
    // -----------------------------
    // try {
    //   // req.file will give the file within server.
    //   const { originalname, path } = req.file;
    //   const parts = originalname.split(".");
    //   const ext = parts[parts.length - 1];
    //   const newPath = path + "." + ext;
    //   fs.renameSync(path, newPath);
    // } catch (e) {
    //   newPath = null;
    // }
    // -----------------------------

    // If no error in token verification
    const { title, summary, author, userId } = req.body;
    if (!title || !summary || !author || !userId) {
      throw new Error("Missing required fields");
    }
    const book = await Book.create({
      title,
      summary,
      author,
      book: newPath,
      uploader: userId,
    });
    res.status(200).json({ message: "Book added!", book: book });
  } catch (e) {
    res.status(500).json({ message: "Error!" });
  }
});

// To update a book - 4 steps
router.put(
  "/edit/:bookId",
  uploadMiddleware.single("file"),
  async (req, res) => {
    const { bookId } = req.params;
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
      // We need user id; also, we need to verify the user
      const { title, summary, author, userId } = req.body;
      const bookOld = await Book.findById(bookId);
      // Use findByIdAndUpdate with the correct syntax
      const updatedBook = await Book.findByIdAndUpdate(
        bookId,
        {
          title,
          summary,
          author,
          book: newPath == null ? bookOld.book : newPath, // Keep the old cover if no new file is uploaded
          userId,
        },
        { new: true } // This option returns the modified document, not the original
      );
      res.status(200).json({ message: "Book updated!" });
    } catch (err) {
      res.status(500).json({ message: "Internal server error!" });
    }
  }
);

// Delete endpoint
router.delete("/delete/:bookId", async (req, res) => {
  const { bookId } = req.params;
  try {
    const book = await Book.findByIdAndDelete(bookId);
    // ----------------------------------
    // if (!book) {
    //   return res.status(404).json({ message: "Book not found" });
    // }
    // ----------------------------------
    res.json({ message: "Deleted successfully" });
  } catch (e) {
    res.status(500).json({ message: "Internal server error!" });
  }
});

// Search a book
router.get("/search/:query", async (req, res) => {
  const { query } = req.params;
  const searchResults = await Book.find(
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
