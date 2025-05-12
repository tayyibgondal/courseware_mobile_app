import { useContext, useState } from "react";
import { useNavigate } from "react-router-dom";
import { UserContext } from "./UserContext";
import Footer from "../Footer";
import "./auth.css";

export default function Login() {
  const [username, setUsername] = useState(null);
  const [password, setPassword] = useState(null);
  const { userInfo, setUserInfo } = useContext(UserContext);
  const navigator = useNavigate();

  async function handleSubmit(e) {
    e.preventDefault();

    // Send request to login endpoint
    const apiUrl = "http://localhost:4000/login";
    const request = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }),
    };
    const response = await fetch(apiUrl, request);

    if (response.status === 200) {
      const data = await response.json();
      localStorage.setItem("authToken", data.token);
      localStorage.setItem("id", data.id);
      if (data.isAdmin == true) {
        localStorage.setItem("isAdmin", true);
      }
      setUserInfo({ id: data.id }); // This is redundant
      navigator("/posts");
    } else {
      alert("Invalid Credentials!");
    }
  }

  return (
    <div>
      <div className="register-container">
        <form className="login" onSubmit={handleSubmit}>
          <h1>Login</h1>
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
          <button>Login</button>
        </form>
      </div>
        <Footer></Footer>
    </div>
  );
}
