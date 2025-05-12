// For using nodemailer in server, I:
// 1. Turned off protection for less secure apps
// 2. Used an app password for my organization account in nodemailer

const express = require("express");
const Contact = require("./models/Contact");
const nodemailer = require("nodemailer");

const router = express.Router();

router.post("/", async (req, res) => {
  const { name, email } = req.body;

  // Save this contact in database
  const contact = await Contact.create({
    name,
    email,
  });
  // Create reusable transporter object using the default SMTP transport
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "thassan.bese21seecs@seecs.edu.pk", // replace with your Gmail email
      pass: "nmji vtiu trwb tnyd",
    },
  });

  // Send confirmation email to the user
  const mailOptions = {
    from: "thassan.bese21seecs@seecs.edu.pk",
    to: email,
    subject: "Contact Us Confirmation",
    text: `Dear ${name},\n\nThank you for contacting us. Our team will get in touch with you soon.\n\nRegards,\nNation Open courseware Team`,
  };

  try {
    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "Please check your email!" });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

router.post("/donate", async (req, res) => {
  const { name, email } = req.body;

  // Save this contact in database
  const contact = await Contact.create({
    name,
    email,
  });
  // Create reusable transporter object using the default SMTP transport
  const transporter = nodemailer.createTransport({
    service: "gmail",
    auth: {
      user: "thassan.bese21seecs@seecs.edu.pk", // replace with your Gmail email
      pass: "nmji vtiu trwb tnyd",
    },
  });

  // Send confirmation email to the user
  const mailOptions = {
    from: "thassan.bese21seecs@seecs.edu.pk",
    to: email,
    subject: "Donation Confirmation",
    text: `Dear ${name},\n\nThank you for contacting us. Our team will get in touch with you soon for transfering of money.\n\nRegards,\nNation Open courseware Team`,
  };

  try {
    await transporter.sendMail(mailOptions);
    res.status(200).json({ message: "Please check your email!" });
  } catch (error) {
    res.status(500).json({ message: "Internal Server Error" });
  }
});

module.exports = router;
