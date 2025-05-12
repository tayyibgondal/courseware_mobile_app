import { useNavigate, useParams } from "react-router-dom";
import { useEffect } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css"; // import styles
import { useContext, useState } from "react";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";
import './forms.css'

export default function EditCourse() {
  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);
  const [name, setName] = useState("");
  const [instructor, setInstructor] = useState("");
  const [email, setEmail] = useState("");
  const [university, setUniversity] = useState("");
  const [year, setYear] = useState("");
  const [description, setDescription] = useState("");
  const [files, setFiles] = useState(null);
  const { courseId } = useParams();

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);

    const fetchData = async () => {
      const response = await fetch(`http://localhost:4000/courses/${courseId}`);
      if (response.status === 200) {
        const data = await response.json();
        console.log(data);
        setName(data.name);
        setInstructor(data.instructor);
        setEmail(data.email);
        setUniversity(data.university);
        setYear(data.year);
        setDescription(data.description);
      } else {
        alert("Could not fetch data!");
      }
    };

    fetchData();
  }, []);

  async function updateCourse(e) {
    e.preventDefault();
    const data = new FormData();
    data.set("name", name);
    data.set("instructor", instructor);
    data.set("email", email);
    data.set("university", university);
    data.set("year", year);
    data.set("description", description);

    const apiUrl = `http://localhost:4000/courses/edit/${courseId}`;
    const request = {
      method: "PUT",
      body: data,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.status === 200) {
      navigator(`/courses/${courseId}`);
      // alert('successfully updated the course!')
    } else {
      alert("Error updating the course!");
    }
  }

  return (
    <div>
      <div className="add-career-path-container">
        {canAccess && (
          <div>
            <h1>Edit course information</h1>
            <button onClick={() => navigator(-1)}>Go Back</button>
            <form onSubmit={updateCourse}>
              <input
                type="title"
                placeholder="Name"
                value={name}
                onChange={(e) => setName(e.target.value)}
              />
              <input
                type="text"
                placeholder="Instructor"
                value={instructor}
                onChange={(e) => setInstructor(e.target.value)}
              />
              <input
                type="email"
                placeholder="Email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
              />
              <input
                type="text"
                placeholder="University"
                value={university}
                onChange={(e) => setUniversity(e.target.value)}
              />
              <input
                type="text"
                placeholder="Year"
                value={year}
                onChange={(e) => setYear(e.target.value)}
              />
              <input type="file" onChange={(e) => setFiles(e.target.files)} />
              <ReactQuill
                value={description}
                placeholder=" Add description"
                onChange={(newValue) => setDescription(newValue)}
              />

              <button style={{ marginTop: "5px" }}>
                Update course details
              </button>
            </form>
          </div>
        )}
      </div>
        <Footer></Footer>
    </div>
  );
}
