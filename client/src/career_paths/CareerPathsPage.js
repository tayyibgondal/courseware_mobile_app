import { useEffect, useState } from "react";
import useFetch from "../useFetch";
import { Link } from "react-router-dom";
import CareerPath from "./CareerPath";
import "./Careers.css";
import Footer from "../Footer";

export default function CareerPathsPage() {
  const isAdmin = localStorage.getItem('isAdmin');
  const [query, setQuery] = useState("");
  const [canAccess, setCanAccess] = useState(false);
  // First of all fetch data
  const { data: careerPaths, setData: setCareerPaths } = useFetch(
    "http://localhost:4000/careerpaths"
  );

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function searchCareerPaths(e) {
    e.preventDefault();
    if (!query.trim()) {
      // If empty query made.
      // Make a fetch req to /posts endpoint
      const response = await fetch("http://localhost:4000/careerpaths");
      if (response.ok) {
        const newData = await response.json();
        setCareerPaths(newData);
        console.log("done");
      }
      // setPosts(updatedPosts);
      return;
    }

    try {
      const apiUrl = `http://localhost:4000/careerpaths/search/${query}`;
      const response = await fetch(apiUrl);
      if (response.ok) {
        const newData = await response.json();
        setCareerPaths(newData);
      } else {
        alert("No results found!");
      }
    } catch (e) {
      alert("Could not resolve query!");
    }
  }

  return (
    <div>
      {canAccess && (
        <div className="list-page-career-path">
          <div className="edit-row">
            <h1>Career Paths</h1>
            {isAdmin && (
              <div>
                <Link to={`/careers/create`} className="create">
                  Add new career path
                </Link>
              </div>
            )}
          </div>

          <form className="search" onSubmit={searchCareerPaths}>
            <input
              className="search"
              type="text"
              placeholder="Search career paths"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
            />
            <div>
              <input type="submit" value="Search" />
            </div>
          </form>

          {careerPaths &&
            careerPaths.map((careerPath) => <CareerPath {...careerPath} />)}
          {careerPaths && <Footer />}
        </div>
      )}
    </div>
  );
}
