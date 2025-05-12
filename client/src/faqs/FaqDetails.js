import React, { useState } from "react";
import { Link, useParams } from "react-router-dom";
import { useContext } from "react";
import { useNavigate } from "react-router-dom";
import useFetch from "../useFetch";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";
import { useEffect } from "react";
import "./faqs.css";

export default function FaqDetails() {
  const isAdmin = localStorage.getItem("isAdmin");
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const { faqId } = useParams();
  const { data } = useFetch(`http://localhost:4000/faqs/${faqId}`);

  const [canAccess, setCanAccess] = useState(false);
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function handleDelete() {
    try {
      const apiUrl = `http://localhost:4000/faqs/delete/${faqId}`;
      const req = {
        method: "DELETE",
        credentials: "include",
      };
      const response = await fetch(apiUrl, req);
      if (response.ok) {
        navigator("/faqs");
      } else {
        alert("The FAQ could not be deleted!");
      }
    } catch (error) {
      console.error("Error deleting FAQ:", error);
    }
  }

  return (
    <div>
      {canAccess && data && (
        <div className="faq-details-container">
          <div>
            <h1>{data.question}</h1>
            <p>
              {!data.answer && <h3>Unanswered</h3>}
              {data.answer && (
                <div>
                  Answer:&nbsp;
                  {data.answer}
                </div>
              )}
            </p>
            {/* Only admins can see the edit and delete buttons */}
            {isAdmin && (
              <div>
                <div className="faq-info">
                  <div className="edit-row">
                    <Link to={`/faqs/edit/${faqId}`} className="Edit">
                      Edit
                    </Link>
                    <button onClick={handleDelete} className="Delete">
                      Delete
                    </button>
                  </div>
                </div>
              </div>
            )}
          </div>
<button onClick={() => navigator(-1)}>Go Back</button>
        </div>
      )}
      <Footer></Footer>
    </div>
  );
}
