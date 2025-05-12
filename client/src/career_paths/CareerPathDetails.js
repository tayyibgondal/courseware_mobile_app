import { formatISO9075 } from "date-fns";
import { Link } from "react-router-dom";
import { useParams } from "react-router-dom";
import { useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import useFetch from "../useFetch";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";

export default function CareerPathDetails() {
  const { userInfo } = useContext(UserContext);
  const isAdmin = localStorage.getItem('isAdmin');
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(false);
  const { careerId } = useParams();
  const { data } = useFetch(`http://localhost:4000/careerpaths/${careerId}`);

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const handleDelete = async () => {
    const confirmDelete = window.confirm(
      "Are you sure you want to delete this career path?"
    );
    if (confirmDelete) {
      try {
        const apiUrl = `http://localhost:4000/careerpaths/delete/${careerId}`;
        const req = {
          method: "DELETE",
          credentials: "include",
        };
        const response = await fetch(apiUrl, req);
        if (response.ok) {
          navigator("/careers");
        } else {
          alert("The career path could not be deleted!");
        }
      } catch (error) {
        console.error(error);
        alert("Error deleting the career path!");
      }
    }
  };

  return (
    <div>
      <button onClick={() => navigator(-1)} style={{marginBottom: "20px"}}>Go Back</button>
      {canAccess && data && (
        <div className="course-details">
          <div>
            <h1>{data.title}</h1>
            <div
              className="summary"
              dangerouslySetInnerHTML={{ __html: data.description }}
            />

            {isAdmin && (
              <div className="button-container">
                <Link
                  to={`/careers/edit/${careerId}`}
                  className="button full-width Edit"
                >
                  Edit
                </Link>
                <button
                  onClick={handleDelete}
                  className="button full-width Delete"
                >
                  Delete
                </button>
              </div>
            )}
            <div className="download">
              <a
                href={`http://localhost:4000/uploads/${
                  data.file.split("\\")[1]
                }`}
                download
                target="_blank"
                className="button full-width"
              >
                Click to download!
              </a>
            </div>
          </div>
        </div>
      )}
      <Footer></Footer>
    </div>
  );
}
