import { useContext, useEffect, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Link } from "react-router-dom";
import { formatISO9075 } from "date-fns";
import useFetch from "../useFetch";
import { UserContext } from "../authentication/UserContext";
import translate from "translate";
import Footer from "../Footer";
import './Post.css'

export default function PostDetails() {
  let isAdmin = localStorage.getItem("isAdmin");

  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const { postId } = useParams();
  const [canAccess, setCanAccess] = useState();
  // Fetching the data
  const { data, setData } = useFetch(`http://localhost:4000/posts/${postId}`);
  // For translations
  const [displayedTitle, setDisplayedTitle] = useState("");
  const [displayedContent, setDisplayedContent] = useState("");
  const [buttonText, setButtonText] = useState("Translate to Urdu");

  useEffect(() => {
    // SECURE THE ENDPOINT
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    // Otherwise set canAccess to true.
    setCanAccess(true);

    setDisplayedContent(data?.content);
    setDisplayedTitle(data?.title);
  }, [data]);

  // Function to delete the post
  async function handleDelete(e) {
    e.preventDefault();
    const apiUrl = `http://localhost:4000/posts/delete/${postId}`;
    const req = {
      method: "DELETE",
    };
    const response = await fetch(apiUrl, req);
    if (response.ok) {
      navigator("/posts");
    } else {
      alert("The post could not be deleted!");
    }
  }

  function extractTextFromHtml(htmlContent) {
    // Create a new DOMParser
    const parser = new DOMParser();
    // Parse the HTML content into a document
    const doc = parser.parseFromString(htmlContent, "text/html");
    // Extract text content from the document's body
    const textContent = doc.body.textContent || doc.body.innerText;
    // Return the extracted text content
    return textContent;
  }

  // Function to translate the content and title
  async function translateText() {
    translate.engine = process.env.REACT_APP_TRANSLATE_ENGINE;
    translate.key = process.env.REACT_APP_TRANSLATE_KEY;

    try {
      if (buttonText === "Translate to Urdu") {
        setButtonText("Translate to English");

        // Extract text from HTML before translation
        const plainTextTitle = extractTextFromHtml(data.title);
        const plainTextContent = extractTextFromHtml(data.content);

        // Translate plain text
        const transTitle = await translate(plainTextTitle, "ur");
        const transContent = await translate(plainTextContent, "ur");

        // Set translated content
        setDisplayedContent(transContent);
        setDisplayedTitle(transTitle);
      } else {
        setButtonText("Translate to Urdu");

        // Reset to original content
        setDisplayedContent(data.content);
        setDisplayedTitle(data.title);
      }
    } catch (error) {
      console.error("Error translating text:", error);
    }
  }

  console.log(
    "cond value",
    isAdmin || localStorage.getItem("id") == data?.author._id
  );

  return (
    <div>
      {canAccess && (
        <div className="post-page">
          {data && (
            <div>
              <div className="edit-row translate">
              </div>
              <div className="image">
                <img
                  style={{ width: "100%" }}
                  src={`http://localhost:4000/uploads/${
                    data.cover.split("\\")[1]
                  }`}
                />
              </div>

              {isAdmin || localStorage.getItem("id") == data.author._id ? (
                <div className="edit-row">
                  <Link to={`/edit/${data._id}`} className="Edit">
                    Edit
                  </Link>
                  <a href="#" className="Edit" onClick={handleDelete}>
                    Delete
                  </a>
                </div>
              ) : null}

              <h1>{displayedTitle}</h1>
                <button className="Edit" onClick={translateText} style={{marginTop: "10px", marginBottom: '10px'}}>
                  {buttonText}
                </button>
              <div dangerouslySetInnerHTML={{ __html: displayedContent }} />
              <div className="author">By: {data.author.username}</div>
              <time>{formatISO9075(data.createdAt)}</time>
              <button
                onClick={() => navigator(-1)}
                style={{ marginBottom: "20px" }}
              >
                Go Back
              </button>
            </div>
          )}
        </div>
      )}
      <Footer></Footer>
    </div>
  );
}
