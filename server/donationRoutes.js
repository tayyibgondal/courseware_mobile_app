const express = require("express");
const Donation = require("./models/Donation");

const router = express.Router();

router.post("/", async (req, res) => {
  try {
    const { firstName, lastName, email, number, amount, currency } = req.body;
    // Check if any of the required fields is null
    if (!firstName || !lastName || !email || !number || !amount || !currency) {
      throw new Error("Missing required fields");
    }

    const donationRecord = await Donation.create(req.body);
    res.json({ message: "Donation data saved!", record: donationRecord });
  } catch (e) {
    res.status(500).json({ message: e.message || "Internal server error!" });
  }
});

module.exports = router;
