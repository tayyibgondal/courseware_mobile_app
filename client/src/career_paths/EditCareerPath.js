import { useNavigate, useParams } from "react-router-dom";
import { useEffect, useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";
import { useContext } from "react";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";
import './forms.css'

export default function EditCareerPath() {
  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);
  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [files, setFiles] = useState(null);
  const { careerId } = useParams();

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);

    const fetchData = async () => {
      try {
        const response = await fetch(
          `http://localhost:4000/careerpaths/${careerId}`
        );

        if (response.ok) {
          const data = await response.json();
          setTitle(data.title);
          setDescription(data.description);
        } else {
          alert("Could not fetch data!");
        }
      } catch (error) {
        console.error("Error fetching data:", error);
        alert("An error occurred while fetching data!");
      }
    };

    fetchData();
  }, []);

  async function updateCareerPath(e) {
    e.preventDefault();

    const data = new FormData();
    data.set("title", title);
    data.set("description", description);

    try {
      if (files) {
        data.set("file", files[0]);
      }
    } catch (err) {
      console.error("Error setting file:", err);
    }

    const apiUrl = `http://localhost:4000/careerpaths/edit/${careerId}`;
    const request = {
      method: "PUT",
      body: data,
      credentials: "include",
    };

    try {
      const response = await fetch(apiUrl, request);

      if (response.ok) {
        navigator(`/careers/${careerId}`);
      } else {
        alert("Error updating the career path!");
      }
    } catch (error) {
      console.error("Error updating career path:", error);
      alert("An error occurred while updating the career path!");
    }
  }

  return (
    <div className="add-career-path-container">
      {canAccess && (
        <div>
          <h1>Edit career path information</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={updateCareerPath}>
            <input type="file" onChange={(e) => setFiles(e.target.files)} />
            <input
              type="text"
              placeholder="Title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
            <ReactQuill
              value={description}
              placeholder="Add description"
              onChange={(newValue) => setDescription(newValue)}
            />

            <button style={{ marginTop: "5px" }}>
              Update career path details
            </button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
