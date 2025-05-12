import React, { useState, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { useContext } from "react";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";
import "./faq-form.css";

export default function EditFaq() {
  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const { faqId } = useParams();

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);

    const fetchData = async () => {
      const response = await fetch(`http://localhost:4000/faqs/${faqId}`);
      if (response.status === 200) {
        const data = await response.json();
        setQuestion(data.question);
        setAnswer(data.answer);
      } else {
        alert("Could not fetch data!");
      }
    };

    fetchData();
  }, []);

  async function updateFaq(e) {
    e.preventDefault();

    const apiUrl = `http://localhost:4000/faqs/edit/${faqId}`;
    const request = {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ question, answer }),
      credentials: "include",
    };

    const response = await fetch(apiUrl, request);

    if (response.status === 200) {
      navigator(`/faqs/${faqId}`);
    } else {
      alert("Error updating the FAQ!");
    }
  }

  return (
    <div>
      {canAccess && (
        <div className="add-faq-container">
          <h1>Edit FAQ</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={updateFaq}>
            <label htmlFor="">Question: </label>
            <input
              type="text"
              placeholder="Question"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
            />
            <label htmlFor="">Answer:</label>
            <br />
            <textarea
              placeholder="Answer"
              value={answer}
              onChange={(e) => setAnswer(e.target.value)}
            />
            <button style={{ marginTop: "5px" }}>Update FAQ</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
