import { formatISO9075 } from 'date-fns';
import {Link} from "react-router-dom";
import './book.css'

export default function Book({ _id, title, summary, author, uploader, book, createdAt }) {
  return (
    <div className="book">
      <div className="texts">
        <Link to={`/library/${_id}`}>{title}</Link>
        <p className="info">
          <p>{summary}</p>
          <p className="author">By: {author}</p>
          <time>{formatISO9075(createdAt)}</time>
        </p>
      </div>
    </div>
  );
}
