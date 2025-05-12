const mongodb = require("mongoose");

const DonationSchema = mongodb.Schema(
  {
    firstName: String,
    lastName: String,
    email: String,
    number: String,
    amount: Number,
    currency: String,
  },
  { timestamps: true }
);

const DonationModel = mongodb.model("Donation", DonationSchema);

module.exports = DonationModel;
