const express = require("express");
const Faq = require("./models/FAQ");

const router = express.Router();

// Get all FAQs
router.get("/", async (req, res) => {
  try {
    const faqs = await Faq.find().sort({ createdAt: -1 });
    res.status(200).json(faqs);
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Create a new FAQ
router.post("/create", async (req, res) => {
  try {
    const { question, answer } = req.body;
    const newFaq = await Faq.create({ question, answer });
    res.status(201).json({ message: "FAQ created", faq: newFaq });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Get all unanswered FAQs
router.get("/unanswered", async (req, res) => {
  try {
    const unanswered = await Faq.find({
      answer: { $in: [null, ""] },
    });
    res.json(unanswered);
  } catch (e) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Get a single FAQ by ID
router.get("/:faqId", async (req, res) => {
  try {
    const { faqId } = req.params;
    const faq = await Faq.findById(faqId);
    if (!faq) {
      return res.status(404).json({ message: "FAQ not found" });
    }
    res.status(200).json(faq);
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Update an existing FAQ by ID
router.put("/edit/:faqId", async (req, res) => {
  try {
    const { faqId } = req.params;
    const { question, answer } = req.body;
    const updatedFaq = await Faq.findByIdAndUpdate(
      faqId,
      { question, answer },
      { new: true }
    );
    if (!updatedFaq) {
      return res.status(404).json({ message: "FAQ not found" });
    }
    res.status(200).json({ message: "FAQ updated", faq: updatedFaq });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

// Delete an FAQ by ID
router.delete("/delete/:faqId", async (req, res) => {
  try {
    const { faqId } = req.params;
    const deletedFaq = await Faq.findByIdAndDelete(faqId);
    if (!deletedFaq) {
      return res.status(404).json({ message: "FAQ not found" });
    }
    res.status(200).json({ message: "FAQ deleted", faq: deletedFaq });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;
