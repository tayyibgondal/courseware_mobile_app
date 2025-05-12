import { formatISO9075 } from "date-fns";
import { Link } from "react-router-dom";
import { useParams } from "react-router-dom";
import { useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import useFetch from "../useFetch";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";
import "./details.css";
  
export default function CourseDetails() {
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const isAdmin = localStorage.getItem("isAdmin");

  const { courseId } = useParams();
  const { data } = useFetch(`http://localhost:4000/courses/${courseId}`);
  const [canAccess, setCanAccess] = useState(false);

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function handleDelete() {
    try {
      const apiUrl = `http://localhost:4000/courses/delete/${courseId}`;
      const req = {
        method: "DELETE",
      };
      const response = await fetch(apiUrl, req);
      if (response.ok) {
        navigator("/courses");
      } else {
        alert("The course could not be deleted!");
      }
    } catch (error) {
      console.error("Error deleting course:", error);
    }
  }

  return (
    <div>
      <div>
        {canAccess && data && (
          <div className="course-details">
            <div>
              <h1>{data.name}</h1>
              <p>
                Instructor:&nbsp;
                {data.instructor}
              </p>
              <p>
                Email:&nbsp;
                {data.email}
              </p>
              <p>
                University:&nbsp;
                {data.university}
              </p>
              <p>
                Year:&nbsp;
                {data.year}
              </p>
              <div className="course-info">
                {isAdmin || localStorage.getItem("id") == data.uploader._id ? (
                  <div className="edit-row">
                    <Link to={`/courses/edit/${data._id}`} className="Edit">
                      Edit
                    </Link>
                    <button onClick={handleDelete} className="Delete">
                      Delete
                    </button>
                  </div>
                ) : null}
                <h2>Description</h2>
                <div
                  className="summary"
                  dangerouslySetInnerHTML={{ __html: data.description }}
                />
                <div className="download">
                  <a
                    href={`http://localhost:4000/uploads/${
                      data.content.split("\\")[1]
                    }`}
                    download
                    target="_blank"
                  >
                    Click to download!
                  </a>
                </div>
                <div className="author">
                  By:&nbsp;
                  {data.uploader.username}
                </div>
                <time>
                  Created at:&nbsp;
                  {formatISO9075(new Date(data.createdAt))}
                </time>
              </div>
            </div>
            <button
              onClick={() => navigator(-1)}
              style={{ marginTop: "20px", marginBottom: "10px" }}
            >
              Go Back
            </button>
          </div>
        )}
      </div>
      <Footer></Footer>
    </div>
  );
}
