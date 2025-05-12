import { useContext, useEffect } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { Link } from "react-router-dom";
import { formatISO9075 } from "date-fns";
import useFetch from "../useFetch";
import { UserContext } from "../authentication/UserContext";
import { useState } from "react";
import Footer from "../Footer";
import './details.css'

export default function BookDetails() {
  const isAdmin = localStorage.getItem("isAdmin");
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  // Can access variable allows us to save data to be leaked to unauthorized accounts momentarialy
  const [canAccess, setCanAccess] = useState(false);
  const { bookId } = useParams();
  const { data } = useFetch(`http://localhost:4000/library/${bookId}`);

  // Make the endpoint secure
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function handleDelete() {
    try {
      const apiUrl = `http://localhost:4000/library/delete/${bookId}`;
      const req = {
        method: "DELETE",
      };
      const response = await fetch(apiUrl, req);
      if (response.ok) {
        navigator("/library");
      } else {
        alert("The book could not be deleted!");
      }
    } catch (error) {
      console.error("Error deleting book:", error);
    }
  }

  return (
    <div>
      <button onClick={() => navigator(-1)} style={{marginBottom: "20px"}}>Go Back</button>
      <div className="book-page">
        {canAccess && data && (
          <div>
            <h1>{data.title}</h1>
            <p>
              Author:&nbsp;
              {data.author}
            </p>

            {isAdmin || localStorage.getItem("id") == data.uploader._id ? (
              <div className="edit-row">
                <Link to={`/library/edit/${data._id}`} className="Edit">
                  Edit
                </Link>
                <button onClick={handleDelete} className="Delete">
                  Delete
                </button>
              </div>
            ) : null}

            <div className="summary">{data.summary}</div>
            <div className="author">
              By:&nbsp;
              {data.uploader.username}
            </div>
            <time>
              Created at:&nbsp;
              {formatISO9075(data.createdAt)}
            </time>
            <div className="download">
              <a
                href={`http://localhost:4000/uploads/${
                  data.book.split("\\")[1]
                }`}
                download
                target="_blank"
              >
                Click to download!
              </a>
            </div>
          </div>
        )}
      </div>
        <Footer></Footer>
    </div>
  );
}
