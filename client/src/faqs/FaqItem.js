import React from "react";
import { Link } from "react-router-dom";
import "./faq-main.css";

export default function FaqItem({ _id, question, answer, createdAt }) {
  const isAdmin = localStorage.getItem("isAdmin");

  // Set answer status message
  if (answer != null && answer != "") {
    var status = "Answered";
  } else {
    var status = "Unanswered";
  }

  return (
    <>
      {/* Show records only if user is admin, or if user is not admin but the question has been answered */}
      {isAdmin || (!isAdmin && answer !== null && !isAdmin && answer !== "") ? (
        <div className="faq-card">
          <h2 className="faq-question">{question}</h2>
          <p className="faq-answer">{answer}</p>
          <p className="faq-info">
            <span className="info-label">Created on:</span>{" "}
            {new Date(createdAt).toLocaleDateString()}
          </p>

          {/* Only admin can see status of a question */}
          {isAdmin && (
            <div>
              <p>
                Status:&nbsp;<b>{status}</b>
              </p>
            </div>
          )}

          <Link to={`/faqs/${_id}`} className="details-link">
            View Details
          </Link>
        </div>
      ) : null}
    </>
  );
}
