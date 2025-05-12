import React, { useContext, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { UserContext } from "./authentication/UserContext";
import "./Header.css";

export default function Header() {
  const { userInfo, setUserInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const [showFilesDropdown, setShowFilesDropdown] = useState(false);

  function logout() {
    localStorage.clear();
    setUserInfo(null);
    navigator("/");
  }

  return (
    <header className="header">
      <Link to="/posts" className="logo">
        National Open Courseware
      </Link>
      {!localStorage.getItem("id") && (
        <nav className="nav">
          <Link to="/">Login</Link>
          <Link to="/register">Register</Link>
        </nav>
      )}
      {localStorage.getItem("id") && (
        <nav className="nav">
          <Link to="/tutor" style={{ width: "90px" }}>
            AI Tutor
          </Link>
          <Link to="/courses">Courses</Link>
          <Link to="/library">Library</Link>
          <div
            className="dropdown"
            onMouseEnter={() => setShowFilesDropdown(true)}
            onMouseLeave={() => setShowFilesDropdown(false)}
          >
            <span>More</span>
            {showFilesDropdown && (
              <div className="dropdown-content vertical">
                <Link to="/posts">Blogs</Link>
                <Link to="/careers">Career Paths</Link>
                <Link to="/donate">Donate</Link>
                <Link to="/contact">Contact us</Link>
                <Link to="/faqs">FAQs</Link>
                <a href="http://localhost:7000/">Chatroom</a>
                <a onClick={logout}>Logout</a>
              </div>
            )}
          </div>
        </nav>
      )}
    </header>
  );
}