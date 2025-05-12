const mongoose = require("mongoose");

const uri =
  "mongodb+srv://ahsansajjad57135:mockmate1122@cluster0.sk9okqm.mongodb.net/courseware?retryWrites=true&w=majority&appName=Cluster0";

mongoose
  .connect(uri)
  .then(() => console.log("Connected to mongodb successfully!"))
  .catch((e) => console.log("Could not connect", e));
