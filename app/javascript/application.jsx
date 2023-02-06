// Entry point for the build script in your package.json

import React, { useState } from "react";
import { createRoot } from "react-dom/client";
import bookImage from "./images/book.png";

const App = () => {
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  function handleChange(event) {
    setQuestion(event.target.value);
  }
  async function handleSubmit(event) {
    event.preventDefault();
    const response = await fetch("/question", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ question_text: question }),
    });
    const body = await response.json();
    setAnswer(body.answer_text);
  }

  return (
    <>
      <div className="header">
        <div className="logo">
          <a href="https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397">
            <img src={bookImage} loading="lazy" />
          </a>
          <h1>Ask My Book</h1>
        </div>
      </div>
      <div className="main">
        <p className="credits">
          This is an experiment in using AI to make my book's content more
          accessible. Ask a question and AI'll answer it in real-time:
        </p>

        <form onSubmit={handleSubmit}>
          <textarea
            id="question"
            name="question"
            value={question}
            onChange={handleChange}
          ></textarea>
          <div className="buttons">
            <button id="ask-button">Ask question</button>
          </div>
        </form>
        {answer ? <div>{answer}</div> : <></>}
      </div>
    </>
  );
};

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app");
  const root = createRoot(container);
  root.render(<App />);
});
