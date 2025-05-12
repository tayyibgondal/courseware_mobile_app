import React from "react";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';
import { faFacebookF, faInstagram, faTwitter, faYoutube, faLinkedin } from '@fortawesome/free-brands-svg-icons';
import "./Footer.css";

export default function Footer() {
  return (
    <footer className="footer bg-dark text-light py-4">
  <div className="container">
    <div className="row">
      <div className="col-md-6">
        <h2 className="heading-footer">Join us in shaping the future of learning.</h2>
        <div className="buttons-footer">
          <a href="/faqs" className="btn btn-primary mr-2 bg-gradient blue-button">FAQs</a>
          <a href="/contact" className="btn btn-outline-primary bg-gradient-reverse blue-button-reverse">Contact</a>
        </div>
      </div>
      <div className="col-md-6">
        <p className="detail-footer">
          National Open CourseWare is an online publication of materials from students, instructors and everyone passionate about learning from all over Pakistan
        </p>
      </div>
    </div>
    <div className="row mt-4">
      <div className="col">
        <p className="cr">&copy; 2023 National Open CourseWare</p>
      </div>
    </div>
    
  </div>
</footer>
  );
}
