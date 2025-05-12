const mongoose = require("mongoose");

const contactSchema = mongoose.Schema({
  name: {
    type: String,
  },
  email: {
    type: String,
    required: true,
  },
}, {
    timestamps: true
});

const ContactModel = mongoose.model("Contact", contactSchema);

module.exports = ContactModel;
