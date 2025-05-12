import "./App.css";
import Header from "./Header";
import IndexPage from "./blogs/IndexPage";
import Login from "./authentication/Login";
import Register from "./authentication/Register";
import { Route, Routes } from "react-router-dom";
import { UserContext } from "./authentication/UserContext";
import { UserContextProvider } from "./authentication/UserContext";
import PostDetails from "./blogs/PostDetails";
import Create from "./blogs/Create";
import EditPost from "./blogs/EditPost";
import BooksPage from "./books/BooksPage";
import CreateBook from "./books/CreateBook";
import EditBook from "./books/EditBook";
import BookDetailsPage from "./books/BookDetailsPage";
import CoursesPage from "./courses/CoursesPage";
import CreateCourse from "./courses/CreateCourse";
import EditCourse from "./courses/EditCourse";
import CourseDetails from "./courses/CourseDetailsPage";
import Chat from "./chatbot/Chat";
import CareerPath from "./career_paths/CareerPath";
import CareerPathsPage from "./career_paths/CareerPathsPage";
import CareerPathDetails from "./career_paths/CareerPathDetails";
import CreateCareerPath from "./career_paths/CreateCareerPath";
import EditCareerPath from "./career_paths/EditCareerPath";
import Contact from "./contact/Contact";
import FaqsPage from "./faqs/FaqsPage";
import FaqDetails from "./faqs/FaqDetails";
import CreateFaq from "./faqs/CreateFaq";
import EditFaq from "./faqs/EditFaq";
import Donate from "./donate/Donate";

function App() {
  window.addEventListener("load", function() {
    document.body.classList.add("loaded");
  });
  return (
    <UserContextProvider>
      <main>
        <Header></Header>
        <Routes>
          {/* Routes for authentication and homepage */}
          <Route path="/" element={<Login />} />
          <Route path="/posts" element={<IndexPage />} />
          <Route path="/register" element={<Register />} />
          {/* Routes for blogs */}
          <Route path="/create" element={<Create />}></Route>
          <Route path="/post/:postId" element={<PostDetails />}></Route>
          <Route path="/edit/:postId" element={<EditPost />}></Route>
          {/* Routes for books */}
          <Route exact path="/library" element={<BooksPage />}></Route>
          <Route path="/library/:bookId" element={<BookDetailsPage />}></Route>
          <Route path="/library/create" element={<CreateBook />}></Route>
          <Route path="/library/edit/:bookId" element={<EditBook />}></Route>
          {/* Routes for courses */}
          <Route exact path="/courses" element={<CoursesPage />}></Route>
          <Route path="/courses/:courseId" element={<CourseDetails />}></Route>
          <Route path="/courses/create" element={<CreateCourse />}></Route>
          <Route
            path="/courses/edit/:courseId"
            element={<EditCourse />}
          ></Route>
          {/* Route for donation */}
          <Route path="/donate" element={<Donate />}></Route>
          {/* Ai tutor */}
          <Route path="/tutor" element={<Chat />}></Route>
          {/* Career paths */}
          <Route exact path="/careers" element={<CareerPathsPage />}></Route>
          <Route
            path="/careers/:careerId"
            element={<CareerPathDetails />}
          ></Route>
          <Route path="/careers/create" element={<CreateCareerPath />}></Route>
          <Route
            path="/careers/edit/:careerId"
            element={<EditCareerPath />}
          ></Route>
          {/* Contact */}
          <Route path="/contact" element={<Contact />}></Route>
          {/* Frequently asked questions */}
          <Route path="/faqs" element={<FaqsPage />}></Route>
          <Route path="/faqs/:faqId" element={<FaqDetails />}></Route>
          <Route path="/faqs/create" element={<CreateFaq />}></Route>
          <Route path="/faqs/edit/:faqId" element={<EditFaq />}></Route>
        </Routes>
      </main>
    </UserContextProvider>
  );
}

export default App;
