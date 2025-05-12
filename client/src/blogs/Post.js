import { formatISO9075 } from 'date-fns';
import {Link} from "react-router-dom";
import "./PostCard.css"

export default function Post({ _id, title, summary, cover, content, createdAt, author }) {
  return (
    <div className="post">
      <div>
        <img src={"http://localhost:4000/uploads/" + cover.split("\\")[1]} />
      </div>
      <div className="texts">
        <Link to={`/post/${_id}`}>{title}</Link>
        <p className="info">
          <a className="author">By: {author.username}</a>
          {/* {<time>{formatISO9075(createdAt)}</time>} */}
        </p>
      </div>
    </div>
  );
}
