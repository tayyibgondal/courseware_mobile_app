import React, { useState, useEffect } from "react";
import useFetch from "../useFetch";
import FaqItem from "./FaqItem";
import Footer from "../Footer";
import { useNavigate } from "react-router-dom";
import { Link } from "react-router-dom";
import './details.css'

export default function FaqsPage() {
  const isAdmin = localStorage.getItem("isAdmin");
  const [message, setMessage] = useState(null);
  const navigator = useNavigate();
  const { data: faqs, setData: setFaqs } = useFetch(
    "http://127.0.0.1:4000/faqs"
  );

  const [canAccess, setCanAccess] = useState(false);
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function showUnanswered() {
    const apiUrl = "http://localhost:4000/faqs/unanswered";
    const response = await fetch(apiUrl);
    if (response.ok) {
      const records = await response.json();
      if (records.length == 0) {
        setMessage("All faqs have been answered!");
      }
      setFaqs(records);
      console.log("showUnanswered completed");
    }
  }

  return (
    <div>
      <h1>
        <Link to="/faqs">Frequently Asked Questions</Link>
      </h1>
      {canAccess && (
        <div className="list-page-faq">
          <div className="button-wrapper">
            {isAdmin && (
              <div>
                <Link to="/faqs/create" className="create-faq-link">
                  Create a FAQ
                </Link>
                <button
                  onClick={showUnanswered}
                  className="unanswered-faqs-button"
                >
                  View Unanswered FAQs
                </button>
              </div>
            )}
            {!isAdmin && (
              <Link to="/faqs/create" className="ask-question-link">
                Ask a Question
              </Link>
            )}
          </div>
          {message}
          {faqs && faqs.map((faq) => <FaqItem key={faq._id} {...faq} />)}
          {faqs && <Footer />}
        </div>
      )}
    </div>
  );
}
