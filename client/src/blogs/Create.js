import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css"; // import styles
import { useContext, useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";

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

export default function Create() {
  // Verifying if user is logged in or note
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(true);

  useEffect(() => {
    // SECURE THE ENDPOINT
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    // Otherwise set canAccess to true.
    setCanAccess(true);
  });

  const [title, setTitle] = useState("");
  const [summary, setSummary] = useState("");
  const [content, setContent] = useState("");
  const [files, setFiles] = useState(null);

  async function createNewPost(e) {
    e.preventDefault();
    const data = new FormData();
    data.set("title", title);
    data.set("summary", summary);
    data.set("content", content);
    data.set("userId", localStorage.getItem("id"));
    try {
      data.set("file", files[0]);
    } catch (e) {
      alert("Enter data for all fields including the image!");
      return;
    }

    const apiUrl = "http://localhost:4000/posts/create";
    const request = {
      method: "POST",
      body: data,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.ok) {
      navigator("/posts");
    } else {
      alert("Error creating the post!");
    }
  }

  return (
    <div className="create-post-container">
  {canAccess && (
    <div>
      <div>
        <h1>Create new post</h1>
        <button onClick={() => navigator(-1)}>Go Back</button>
      </div>
      <form onSubmit={createNewPost}>
            <input
              type="title"
              placeholder="Title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
            />
            <input
              type="summary"
              placeholder="Summary"
              value={summary}
              onChange={(e) => setSummary(e.target.value)}
            />
            <input type="file" onChange={(e) => setFiles(e.target.files)} />
            <ReactQuill
              value={content}
              onChange={(newValue) => setContent(newValue)}
            />
            <button style={{ marginTop: "5px" }}>Create</button>
          </form>
      <Footer></Footer>
    </div>
  )}
</div>)
}
