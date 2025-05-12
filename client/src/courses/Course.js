import { formatISO9075 } from "date-fns";
import { Link } from "react-router-dom";

export default function Course({
  _id,
  name,
  instructor,
  email,
  university,
  year,
  createdAt,
}) {
  return (
    <div className="course-card">
      <h2 className="course-title">{name}</h2>
      <p className="course-info">
        <span className="info-label">Instructor:</span> {instructor}
      </p>
      <p className="course-info">
        <span className="info-label">Email:</span> {email}
      </p>
      <p className="course-info">
        <span className="info-label">University:</span> {university}
      </p>
      <p className="course-info">
        <span className="info-label">Year:</span> {year}
      </p>
      <p className="course-info">
        <span className="info-label">Uploaded on:</span>{" "}
        {formatISO9075(new Date(createdAt))}
      </p>
      <Link to={`/courses/${_id}`} className="details-link">
        View Details
      </Link>
    </div>
  );
}
