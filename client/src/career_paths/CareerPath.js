import { formatISO9075 } from "date-fns";
import Footer from "../Footer";
import { Link } from "react-router-dom";

export default function CareerPath({ _id, title, description, createdAt }) {
  return (
    <div className="career-path-card">
      <h2 className="career-path-title">{title}</h2>
      <p className="career-path-info">
        <span className="info-label">Uploaded on:</span>{" "}
        {formatISO9075(new Date(createdAt))}
      </p>
      <Link to={`/careers/${_id}`} className="details-link">
        View Details
      </Link>
    </div>
  );
}
