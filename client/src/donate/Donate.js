import { useState } from "react";
import Footer from "../Footer";
import { useNavigate } from "react-router-dom";
import { useEffect } from "react";
import "./donate.css"

export default function Donate() {
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(false);
  const [formData, setFormData] = useState({
    firstName: "",
    lastName: "",
    email: "",
    number: "",
    amount: "",
    currency: "",
  });
  const [msg, setMsg] = useState("");

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  function handleInputChange(e) {
    const { name, value } = e.target;
    setFormData((prevData) => ({
      ...prevData,
      [name]: value,
    }));
  }

  async function handleFormDataSubmit(e) {
    e.preventDefault();
    setMsg("");

    // make call to save data in database
    const donationEndpointResponse = await fetch(
      "http://localhost:4000/donate",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        // NOTE: ALWAYS SEND DATA IN JSON FORMAT FROM CLIENT (server will receive an object in req.body)
        body: JSON.stringify(formData),
      }
    );
    if (donationEndpointResponse.ok) {
      const message = await donationEndpointResponse.json();
    } else {
      setMsg("Something went wrong...");
    }

    // make call to email endpoint
    const emailReq = { name: formData.firstName, email: formData.email };
    console.log(emailReq);
    const mailerResponse = await fetch("http://localhost:4000/contact/donate", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(emailReq),
    });
    if (mailerResponse.ok) {
      setMsg("Please check your email!");
    } else {
      setMsg("Something went wrong...");
    }
  }

  return (
    <section className="forms-container">
      {canAccess && (
        <div>
          <div>{msg}</div>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={handleFormDataSubmit}>
            <label htmlFor="first-name">First Name</label>
            <input
              type="text"
              name="firstName"
              id="first-name"
              value={formData.firstName}
              onChange={handleInputChange}
            />

            <label htmlFor="last-name">Last Name</label>
            <input
              type="text"
              name="lastName"
              value={formData.lastName}
              onChange={handleInputChange}
            />

            <label htmlFor="email">Email</label>
            <input
              type="email"
              name="email"
              id="email"
              value={formData.email}
              onChange={handleInputChange}
            />

            <label htmlFor="number">Phone Number</label>
            <input
              type="number"
              name="number"
              value={formData.number}
              onChange={handleInputChange}
            />

            <label htmlFor="amount">Amount</label>
            <input
              type="number"
              name="amount"
              value={formData.amount}
              onChange={handleInputChange}
            />

            <select
              name="currency"
              id="currency-select"
              value={formData.currency}
              onChange={handleInputChange}
            >
              <option value="">--Please choose an option--</option>
              <option value="PKR">PKR</option>
              <option value="INR">INR</option>
              <option value="USD">USD</option>
              <option value="Euro">Euro</option>
            </select>

            <input type="submit" value="Donate" />
          </form>
          <Footer></Footer>
        </div>
      )}
    </section>
  );
}
