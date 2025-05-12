import React, { useContext, useState } from "react";
import { useNavigate } from "react-router-dom";
import { UserContext } from "../authentication/UserContext";
import { useEffect } from "react";
import Footer from "../Footer";
import "./faq-form.css"

export default function CreateFaq() {
  const isAdmin = localStorage.getItem("isAdmin");
  let topRowMessage;
  if( isAdmin)
    topRowMessage = "Create a question";
  else 
    topRowMessage = "Aks a question";

  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");

  async function createNewFaq(e) {
    e.preventDefault();

    const apiUrl = "http://localhost:4000/faqs/create";
    const request = {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ question, answer }),
      credentials: "include",
    };

    const response = await fetch(apiUrl, request);

    if (response.ok) {
      navigator("/faqs");
    } else {
      alert("Error creating the FAQ!");
    }
  }

  return (
    <div>
      {canAccess && (
        <div className="add-faq-container">
          <h1>{topRowMessage}</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={createNewFaq}>
            <input
              type="text"
              placeholder="Question"
              value={question}
              onChange={(e) => setQuestion(e.target.value)}
            />
            {isAdmin && (
              <textarea
                placeholder="Answer"
                value={answer}
                onChange={(e) => setAnswer(e.target.value)}
              />
            )}
            <button style={{ marginTop: "5px" }}>Add FAQ</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
