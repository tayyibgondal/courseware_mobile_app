/*
STEPS TO DO IF YOU WANT TO ACHIEVE TRANSLATION
 
1. If you want to translate a particular field, make a state 'displayedContent'.
2. Use this state in your jsx.
3. Make another state for showing translate button message.
4. Now generally displayedContent = actual content. 
5. When button is clicked, displayedContent = translated(actual content) or the actual content, depending upon the button msg.

*/

import { useState } from "react";
import { useEffect } from "react";
import { useContext } from "react";
import { UserContext } from "../authentication/UserContext";
import { useNavigate } from "react-router-dom";
import translate from "translate";
import Footer from "../Footer";
import "./chat.css";

export default function Chat() {
  const secretKey = process.env.REACT_APP_TUTOR_KEY;
  // Verifying if user is logged in or note
  const { userInfo } = useContext(UserContext);
  const navigator = useNavigate();
  const [canAccess, setCanAccess] = useState(null);

  // Secure the endpoints
  useEffect(() => {
    if (!localStorage.getItem("id")) {
      navigator("/");
    }
    setCanAccess(true);
  });

  const [files, setFiles] = useState(null);
  // States to be updated when user uploads a file
  const [uploaded, setUploaded] = useState(null);
  const [message, setMessage] = useState(null);
  const [srcId, setSrcId] = useState(null);
  // States to be updated when a user prompts the ai bot
  const [reply, setReply] = useState(null);
  const [prompt, setPrompt] = useState(null);
  // States regarding translations
  const [btnMsg, setBtnMsg] = useState("Can't understand? Translate to Urdu!");
  const [displayedReply, setDisplayedReply] = useState(null);

  // Fired when user uploads a file
  async function handleUpload(e) {
    // 1. Stop default behaviour on form submissino
    e.preventDefault();

    // 2. Make request ready
    const apiUrl = "https://api.chatpdf.com/v1/sources/add-file";

    const data = new FormData();
    try {
      data.set("file", files[0]);
    } catch {
      alert("You must upload a file!");
      return;
    }
    const req = {
      method: "POST",
      body: data,
      headers: {
        "x-api-key": secretKey,
      },
    };

    // 3. Make fetch call
    try {
      // Get response from the server, await blocks the main thread
      const response = await fetch(apiUrl, req);
      // Extract data
      const apiData = await response.json();

      // set src id, and uploaded
      setSrcId(apiData.sourceId);
      setUploaded(true);
      setMessage("File has been uploaded, you can now prompt the tutor!");
    } catch (e) {
      alert("Api is not responding!");
    }
  }

  // When user enters a prompt and clicks enter, this is fired
  async function handleChat(e) {
    // 1. Stop the default behaviour
    e.preventDefault();

    // 2. Make request ready
    // Specify url
    const apiUrl = "https://api.chatpdf.com/v1/chats/message";
    // Specify data
    const data = {
      // sourceId: "src_mX8I102536ZivxkYdV9js", // hard coding for now, change this to:
      sourceId: srcId,
      messages: [
        {
          role: "user",
          content: prompt,
        },
      ],
    };
    // Make request
    const request = {
      method: "POST",
      headers: {
        "x-api-key": secretKey,
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    };

    // 3. Do fetch request
    try {
      const apiResponse = await fetch(apiUrl, request);
      if (apiResponse.ok) {
        const apiData = await apiResponse.json();
        console.log(apiData);
        setReply(apiData.content);
        setDisplayedReply(apiData.content);
        setBtnMsg("Can't understand? Translate to Urdu!");
        return;
      } else {
        alert("Bad response from the AI bot, try again!");
      }
    } catch (e) {
      alert("Api is not responding!");
    }
  }

  // Another way to use ChatPDF api, by adding our own server as intermdeiary
  // Function for sending user prompt to our server, which will then get response back from chatPDF api
  //   async function handleChat(e) {
  //     e.preventDefault();

  //     const apiUrl = "http://localhost:4000/chatpdf-request";
  //     const data = {
  //     sourceId: "src_mX8I102536ZivxkYdV9js", // hard coding for now, change this to:
  //     // sourceId: srcId,
  //       messages: [
  //         {
  //           role: "user",
  //           content: prompt,
  //         },
  //       ],
  //     };

  //     try {
  //       const apiResponse = await fetch(apiUrl, {
  //         method: "POST",
  //         headers: {
  //           "Content-Type": "application/json",
  //         },
  //         body: JSON.stringify(data),
  //       });

  //       if (apiResponse.ok) {
  //         const apiData = await apiResponse.json();
  //         setReply(apiData.content);
  //       } else {
  //         alert("Bad response from the AI bot, try again!");
  //       }
  //     } catch (e) {
  //       alert("Api is not responding!");
  //     }
  //   }

  async function translateText() {
    translate.engine = process.env.REACT_APP_TRANSLATE_ENGINE;
    translate.key = process.env.REACT_APP_TRANSLATE_KEY;
    try {
      if (btnMsg == "Can't understand? Translate to Urdu!") {
        const text = await translate(reply, "ur");
        setDisplayedReply(text);
        setBtnMsg("See the english version");
      } else {
        setDisplayedReply(reply);
        setBtnMsg("Can't understand? Translate to Urdu!");
      }
    } catch (error) {
      console.error("Error translating text:", error);
    }
  }

  return (
    <div className="tutor">
      {canAccess && (
        <div className="chat-container">
          <div className="toprow">
            <h1>Chat</h1>
            <div>
              <button onClick={() => navigator(-1)}>Go Back</button>
            </div>
          </div>
          <p className="message">{message}</p>
          <form className="upload-file-form" onSubmit={handleUpload}>
            <label className="file-label">
              <input
                type="file"
                onChange={(e) => setFiles(e.target.files)}
                style={{ width: "100%" }}
              />
            </label>
            <button style={{ marginTop: "10px" }}>
              Give to Language model
            </button>
          </form>

          {uploaded && (
            <form onSubmit={handleChat} className="chat-prompt-form">
              <input
                type="text"
                placeholder="Prompt the tutor..."
                value={prompt}
                onChange={(e) => setPrompt(e.target.value)}
              />
              <input type="submit" value="Ask" />
            </form>
          )}

          {reply && (
            <div className="response-section">
              <h2>Response</h2>
              <div className="response">{displayedReply}</div>
              <button onClick={translateText} className="translateButton">
                {btnMsg}
              </button>
            </div>
          )}
        </div>
      )}
      <Footer></Footer>
    </div>
  );
}
