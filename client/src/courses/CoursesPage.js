import { useEffect, useState } from "react";
import useFetch from "../useFetch";
import { Link, useNavigate } from "react-router-dom";
import Course from "./Course";
import Footer from "../Footer";

export default function CoursesPage() {
  const [query, setQuery] = useState("");
  const navigator = useNavigate();
  const { data: courses, setData: setCourses } = useFetch(
    "http://127.0.0.1:4000/courses"
  );
  const [canAccess, setCanAccess] = useState(false);

  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  async function searchCourses(e) {
    e.preventDefault();

    if (!query.trim()) {
      // If empty query made.
      // Make a fetch req to /posts endpoint
      const response = await fetch("http://localhost:4000/courses");
      if (response.ok) {
        const newData = await response.json();
        setCourses(newData);
        console.log("done");
      }
      // setPosts(updatedPosts);
      return;
    }

    try {
      const apiUrl = `http://localhost:4000/courses/search/${query}`;
      const response = await fetch(apiUrl);
      if (response.ok) {
        const newData = await response.json(); // new worker does the work, main thread can move on. (but doesn't when we use await)
        setCourses(newData);
      } else {
        alert("No results found!");
      }
    } catch (e) {
      alert("Could not resolve query!");
    }
  }

  return (
    <div>
      <div>
        {canAccess && (
          <div className="list-page-book">
            <div className="edit-row">
              <h1>Courses</h1>
              <div>
                <Link to={`/courses/create`} className="create">
                  Add new course
                </Link>
              </div>
            </div>

            <form className="search" onSubmit={searchCourses}>
              <input
                className="search"
                type="text"
                placeholder="Search courses"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
              />
              <div>
                <input type="submit" value="Search" />
              </div>
            </form>

            {courses && courses.map((course) => <Course {...course} />)}
          </div>
        )}
      </div>
      {courses && <Footer />}
    </div>
  );
}
