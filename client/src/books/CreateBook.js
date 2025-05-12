import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { useContext } from "react";
import { UserContext } from "../authentication/UserContext";
import Footer from "../Footer";

export default function BookCreate() {
  // Verifying if user is logged in or note
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(null);

  // Make the endpoint secure
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const [title, setTitle] = useState("");
  const [summary, setSummary] = useState("");
  const [author, setAuthor] = useState("");
  const [files, setFiles] = useState(null);

  async function createNewPost(e) {
    e.preventDefault();
    const data = new FormData();
    data.set("title", title);
    data.set("summary", summary);
    data.set("author", author);
    data.set("userId", localStorage.getItem('id'));
    try {
      data.set("file", files[0]);
    } catch (err) {
      alert("Enter data for all fields including the image!");
      return;
    }

    const apiUrl = "http://localhost:4000/library/create";
    const request = {
      method: "POST",
      body: data,
      credentials: "include",
    };
    const response = await fetch(apiUrl, request);
    if (response.ok) {
      navigator("/library");
    } else {
      alert("Error creating the post!");
    }
  }

  return (
    <div className="add-book-container">
      {canAccess && (
        <div>
          <h1>Add new book</h1>
          <button onClick={() => navigator(-1)}>Go Back</button>
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
            <input
              type="text"
              placeholder="author"
              value={author}
              onChange={(e) => setAuthor(e.target.value)}
            />
            <input type="file" onChange={(e) => setFiles(e.target.files)} />

            <button style={{ marginTop: "5px" }}>Add to library</button>
          </form>
          <Footer></Footer>
        </div>
      )}
    </div>
  );
}
