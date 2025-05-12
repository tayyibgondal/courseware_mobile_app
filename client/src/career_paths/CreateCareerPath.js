import { useContext, useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css"; // import styles
import { useNavigate } from "react-router-dom";
import { UserContext } from "../authentication/UserContext";
import { useEffect } from "react";
import Footer from "../Footer";
import './forms.css'

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

export default function CreateCareerPath() {
  // Verifying if user is logged in or not
  const navigator = useNavigate();
  const { userInfo } = useContext(UserContext);
  const [canAccess, setCanAccess] = useState(null);

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [file, setFile] = useState(null);

  async function createNewCareerPath(e) {
    e.preventDefault();
    const data = new FormData();
    data.set("title", title);
    data.set("description", description);
    try {
      data.set("file", file[0]);
    } catch (err) {
      alert("Enter data for all fields including the file!");
      return;
    }

    const apiUrl = "http://localhost:4000/careerpaths/create";
    const request = {
      method: "POST",
      body: data,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.ok) {
      navigator("/careers");
      // alert("Career path added successfully!");
    } else {
      alert("Error creating the career path!");
    }
  }

  return (
    <div className="add-career-path-container">
      {canAccess && (
        <div>
          <h1>Add new career path</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={createNewCareerPath}>
            <input type="file" onChange={(e) => setFile(e.target.files)} />
            <input
              type="title"
              placeholder="Title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
            <br />
            <ReactQuill
              value={description}
              placeholder=" Add description"
              onChange={(newValue) => setDescription(newValue)}
            />
            <br />

            <button style={{ marginTop: "5px" }}>Add Career Path</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
