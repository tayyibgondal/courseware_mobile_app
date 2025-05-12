import { useEffect, useState } from "react";
import Post from "./Book";
import useFetch from "../useFetch";
import { Link } from "react-router-dom";
import Book from "./Book";
import { UserContext } from "../authentication/UserContext";
import { useContext } from "react";
import { useNavigate } from "react-router-dom";
import Footer from "../Footer";

export default function BooksPage() {
  const navigator = useNavigate();
  const [query, setQuery] = useState("");
  const [canAccess, setCanAccess] = useState(false);
  const { data: books, setData: setBooks } = useFetch(
    "http://127.0.0.1:4000/library"
  );

  // Make the endpoint secure
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function searchBooks(e) {
    e.preventDefault();
    if (!query.trim()) {
      // If empty query made.
      // Make a fetch req to /posts endpoint
      const response = await fetch("http://localhost:4000/library");
      if (response.ok) {
        const newData = await response.json();
        setBooks(newData);
        console.log("done");
      }
      // setPosts(updatedPosts);
      return;
    }

    try {
      const apiUrl = `http://localhost:4000/library/search/${query}`;
      const response = await fetch(apiUrl);
      if (response.ok) {
        const newData = await response.json(); // new worker does the work, main thread can move on. (but doesn't when we use await)
        setBooks(newData);
      } else {
        alert("No results found!");
      }
    } catch (e) {
      alert("Could not resolve query!");
    }
  }
  return (
    <div>
      <div className="list-page-book">
        {canAccess && (
          <div>
            <div className="edit-row">
              <h1>Library</h1>
              <div>
                <Link to="/library/create" className="create">
                  Add new book
                </Link>
              </div>
            </div>
            <form className="search" onSubmit={searchBooks}>
              <input
                className="search"
                type="text"
                placeholder="Search books"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
              <div>
                <input type="submit" value="Search" />
              </div>
            </form>
            {books && books.map((book) => <Book key={book.id} {...book} />)}
          </div>
        )}
      </div>
        {books && <Footer />}
    </div>
  );
}
