import { useState } from "react";
import Footer from "../Footer";
import "./auth.css";

export default function Register() {
  const [username, setUsername] = useState(null);
  const [password, setPassword] = useState(null);

  async function handleSubmit(e) {
    e.preventDefault();

    const apiUrl = "http://localhost:4000/register";
    const request = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }),
    };

    const response = await fetch(apiUrl, request);
    if (response.status === 200) {
      alert("Registration successful");
    } else {
      alert("Registration unsuccessful");
    }
  }

  return (
    <div>
      <div className="register-container">
        <form className="register" onSubmit={handleSubmit}>
          <h1>Register</h1>
          <input
            type="text"
            placeholder="Username"
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <input
            type="text"
            placeholder="Password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button>Register</button>
        </form>
      </div>
        <Footer></Footer>
    </div>
  );
}
