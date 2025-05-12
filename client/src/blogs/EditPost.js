import { useNavigate, useParams } from "react-router-dom";
import { useEffect } from "react";
import { useContext, useState } from "react";
import ReactQuill from "react-quill";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";

export default function EditPost() {
  // Verifying if user is logged in or not
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(null);
  const { postId } = useParams();
  const [title, setTitle] = useState(null);
  const [summary, setSummary] = useState(null);
  const [content, setContent] = useState(null);
  const [files, setFiles] = useState(null);

  useEffect(() => {
    // SECURE THE ENDPOINT, even on browser window reload
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);

    // Fetch data for one post
    const fetchData = async () => {
      const response = await fetch(`http://localhost:4000/posts/${postId}`);
      if (response.status === 200) {
        const data = await response.json();
        setTitle(data.title);
        setSummary(data.summary);
        setContent(data.content);
      } else {
        alert("Could not fetch data!");
      }
    };

    fetchData();
  }, []);

  async function updatePost(e) {
    e.preventDefault();
    const formData = new FormData();
    formData.set("title", title);
    formData.set("summary", summary);
    formData.set("content", content);
    formData.set("file", files?.[0]);
    formData.set("userId", localStorage.getItem('id'));
    

    const apiUrl = `http://localhost:4000/posts/edit/${postId}`;
    const request = {
      method: "PUT",
      body: formData,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.status === 200) {
      navigator(`/post/${postId}`);
    } else {
      alert("Error updating the post!");
    }
  }

  return (
    <div className="edit-post-container">
      {canAccess && (
        <div>
          <h1>Edit post</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
          <form onSubmit={updatePost}>
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
            <button style={{ marginTop: "20px" }}>Update</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
