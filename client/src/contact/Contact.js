import React, { useState } from "react";
import axios from "axios";
import Footer from "../Footer";
import { useNavigate } from "react-router-dom";
import { useEffect } from "react";
import './contact.css'

function Contact() {
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(false);
  // Notice this line (1)
  const [formData, setFormData] = useState({ name: "", email: "" });
  // Notice this line (2)
  const [message, setMessage] = useState(null);

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Using axios instead of fetch, the function takes in url, data and header.
    // Returns a response object (not promise) that contains the message inside it
    try {
      // Notice that the request body is just the state which we defined above (3).
      // Remember: req body should be json string/javascript object only.
      const response = await axios.post(
        "http://localhost:4000/contact",
        formData
      );
      console.log(response.data.message);
      setMessage(response.data.message);
    } catch (error) {
      console.error(error);
      alert("Error!");
    }
  };

  return (
    <div className="contact-container">
      {canAccess && (
        <div>
          <h1>Contact Us</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          {message}
          <form onSubmit={handleSubmit}>
            <label>
              Name:
              <input
                type="text"
                name="name"
                value={formData.name}
                onChange={handleChange}
              />
            </label>
            <br />
            <label>
              Email:
              <input
                type="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
              />
            </label>
            <br />
            <button type="submit">Submit</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}

export default Contact;
