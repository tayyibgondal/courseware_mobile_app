import { useContext, useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css"; // import styles
import { useNavigate } from "react-router-dom";
import { UserContext } from "../authentication/UserContext";
import { useEffect } from "react";
import Footer from "../Footer";
import "./forms.css";

const modules = {
  toolbar: [
    [{ header: [1, 2, false] }],
    ["bold", "italic", "underline", "strike", "blockquote"],
    [
      { list: "ordered" },
      { list: "bullet" },
      { indent: "-1" },
      { indent: "+1" },
    ],
    ["link", "image"],
    ["clean"],
  ],
};

const formats = [
  "header",
  "bold",
  "italic",
  "underline",
  "strike",
  "blockquote",
  "list",
  "bullet",
  "indent",
  "link",
  "image",
];

export default function CreateCourse() {
  // Verifying if user is logged in or not
  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const [name, setName] = useState("");
  const [instructor, setInstructor] = useState("");
  const [email, setEmail] = useState("");
  const [university, setUniversity] = useState("");
  const [year, setYear] = useState("");
  const [description, setDescription] = useState("");
  const [files, setFiles] = useState(null);

  async function createNewCourse(e) {
    e.preventDefault();
    const data = new FormData();
    data.set("name", name);
    data.set("instructor", instructor);
    data.set("email", email);
    data.set("university", university);
    data.set("year", year);
    data.set("description", description);
    data.set("userId", localStorage.getItem("id"));
    try {
      data.set("file", files[0]);
    } catch (err) {
      alert("Enter data for all fields including the image!");
      return;
    }

    const apiUrl = "http://localhost:4000/courses/create";
    const request = {
      method: "POST",
      body: data,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.ok) {
      navigator("/courses");
      // alert("Course added successfully!");
    } else {
      alert("Error creating the post!");
    }
  }

  return (
    <div>
      <div className="add-career-path-container">
        {canAccess && (
          <div>
            <h1>Add new course</h1>
            <button onClick={() => navigator(-1)}>Go Back</button>
            <form onSubmit={createNewCourse}>
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

              <button style={{ marginTop: "5px" }}>Add to courseware</button>
            </form>
          </div>
        )}
      </div>
        <Footer></Footer>
    </div>
  );
}
