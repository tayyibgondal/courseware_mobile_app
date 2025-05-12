const express = require("express");
const cors = require("cors");
const db = require("./db/db");
const User = require("./models/User");
const Post = require("./models/Post");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const cookieParser = require("cookie-parser");
const multer = require("multer");
const uploadMiddleware = multer({ dest: "uploads/" });
const fs = require("fs");
const postRoutes = require("./postRoutes");
const bookRoutes = require("./bookRoutes");
const courseRoutes = require("./courseRoutes");
const axios = require("axios");
const bodyParser = require("body-parser");
const careerRoutes = require("./careerPathRoutes");
const contactRoute = require("./contactRoute");
const faqRoute = require("./faqRoutes");
const donationRoute = require("./donationRoutes");

// Create a salt
const salt = bcrypt.genSaltSync(10);
const secretKey = "kshdi7a8aifh8o373q9fg";

const app = express();

// Middlewares
// Enable CORS for all origins with proper configuration
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  credentials: true,
  preflightContinue: false,
  optionsSuccessStatus: 204
}));

// Handle preflight requests
app.options('*', cors());

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
// Use cookie-parser middleware
app.use(cookieParser());
// Add body-parser middleware to parse JSON bodies of forms (only for non-url encoded forms)
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));
// Middleware for allowing clients to access static resources
app.use("/uploads", express.static(__dirname + "/uploads"));
// Routes
app.use("/posts/", postRoutes);
app.use("/library/", bookRoutes);
app.use("/courses/", courseRoutes);
app.use("/careerpaths/", careerRoutes);
app.use("/contact/", contactRoute);
app.use("/faqs/", faqRoute);
app.use("/donate/", donationRoute);

// // ====================== AUTHENTICATION MIDDLEWARE =========================
// const authMiddleware = (req, res, next) => {
//   const token = req.headers.authorization;
//   if (!token) {
//     return res.status(401).json({ message: "Auth token missing" });
//   }

//   jwt.verify(token, secretKey, (err, info) => {
//     if (err) {
//       return res.status(401).json({ message: "Invalid token" });
//     }
//   });

//   req.user_ki_id = info.id;
//   next();
// };

// ====================== AUTHENTICATION ENDPOINTS =============================
app.post("/login", async (req, res) => {
  try {
    // Extract username and password
    const { username, password } = req.body;
    
    // Check if username and password are provided
    if (!username || !password) {
      return res.status(400).json({ message: "Username and password are required" });
    }
    
    // Find user
    const userDoc = await User.findOne({ username });
    
    // If user not found
    if (!userDoc) {
      return res.status(401).json({ message: "Invalid username or password" });
    }
    
    // Check if passwords match
    const passwordTestResult = bcrypt.compareSync(password, userDoc.password);
    
    // If password doesn't match
    if (!passwordTestResult) {
      return res.status(401).json({ message: "Invalid username or password" });
    }
    
    // If user exists and passwords match
    const isAdmin = userDoc.isAdmin === true;
    
    jwt.sign(
      { username, id: userDoc._id },
      secretKey,
      { expiresIn: "1h" },
      (e, token) => {
        if (e) {
          console.error("JWT signing error:", e);
          return res.status(500).json({ message: "Error generating authentication token" });
        }
        
        // To show or unshow website, we'll use token stored in local storage
        // To show specific buttons etc, we'll use the user id which we'll save as a context in frontend.
        // We can also use user id for both tasks
        res.status(200).json({ token, id: userDoc._id, isAdmin: isAdmin });
      }
    );
  } catch (e) {
    console.error("Login error:", e);
    res.status(500).json({ message: "Server error. Please try again later." });
  }
});

app.post("/register", async (req, res) => {
  const { username, password } = req.body;
  const hashedPassword = bcrypt.hashSync(password, salt);
  try {
    const user = await User.create({
      username: username,
      password: hashedPassword,
      isAdmin: false,
    });
    res.status(200).json({ message: "User has been created!", user: user });
  } catch (e) {
    console.error(e);
    res.status(500).json({ message: "Could not register" });
  }
});

app.post("/logout", (req, res) => {
  // Set the cookie to an empty string
  res.cookie("token", "").json("OK");
});

// Add a health check endpoint
app.get("/health", (req, res) => {
  res.status(200).json({ status: "ok", message: "Server is running" });
});

// ============================================================
// End point that forwards client's request to chatPDF
// app.post("/chatpdf-request", async (req, res) => {
//   const apiUrl = "https://api.chatpdf.com/v1/chats/message";
//   const headers = {
//     "Content-Type": "application/json",
//     "x-api-key": "sec_w2zWAPuDvDlR8K1vx0mdIeXCjzMVC5fI",
//   };
//   const requestForApi = {
//     method: "POST",
//     headers,
//     body: JSON.stringify(req.body),
//   };
//   console.log(requestForApi);

//   try {
//     const apiResponse = await fetch(apiUrl, requestForApi);

//     if (apiResponse.ok) {
//       const apiData = await apiResponse.json();
//       res.json({ reply: apiData.content });
//     } else {
//       res
//         .status(apiResponse.status)
//         .json({ error: "Bad response from the AI bot, try again!" });
//     }
//   } catch (error) {
//     console.error("Error:", error);
//     res.status(500).json({ error: "Internal server error" });
//   }
// });
// ===========================================================
// app.post("/chatpdf-request", async (req, res) => {
//   console.log(req.body);
//   const apiUrl = "https://api.chatpdf.com/v1/chats/message";

//   // const headers = {
//   //   "Content-Type": "application/json",
//   //   "x-api-key": "sec_w2zWAPuDvDlR8K1vx0mdIeXCjzMVC5fI",
//   // };

//   try {
//     const apiResponse = await axios.post(apiUrl, req.body, { headers });

//     if (apiResponse.status === 200) {
//       res.json({ content: apiResponse.data.content });
//     } else {
//       res
//         .status(apiResponse.status)
//         .json({ error: "Bad response from the AI bot, try again!" });
//     }
//   } catch (error) {
//     console.error("Error:", error.message);
//     res.status(500).json({ error: "Internal server error" });
//   }
// });

module.exports = app;
