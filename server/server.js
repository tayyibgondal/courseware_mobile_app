const app = require("./index");

app.listen(4000, () => console.log("Server listening on http://localhost:4000/"));

app.get("/", (req, res) => {
  res.send("Hello World");
});
