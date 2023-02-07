// Entry point for the build script in your package.json

import React, { useState } from "react";
import { createRoot } from "react-dom/client";
import bookImage from "./images/book.png";
import lecturePdfImage from "./images/lecture.png";
import { MagnifyingGlass } from "react-loader-spinner";

const App = () => {
  const [question, setQuestion] = useState("");
  const [answer, setAnswer] = useState("");
  const [state, setState] = useState("initial");

  function resetState() {
    setState("initial");
    setQuestion("");
  }

  function handleChange(event) {
    setState("initial");
    setQuestion(event.target.value);
  }

  async function handleSubmit(event) {
    setState("loading");
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
    setState("answered");
  }

  let answerComponent;

  if (state === "initial") {
    answerComponent = <></>;
  } else if (state === "loading") {
    answerComponent = (
      <MagnifyingGlass
        visible={true}
        height="80"
        width="80"
        ariaLabel="MagnifyingGlass-loading"
        wrapperStyle={{}}
        wrapperClass="MagnifyingGlass-wrapper"
        glassColor="#c0efff"
        color="#e15b64"
      />
    );
  } else if (state === "answered") {
    answerComponent = (
      <>
        <div>
          <strong>Answer:</strong>
          {answer}
        </div>
        <button id="ask-button" onClick={resetState}>
          Ask another question
        </button>
      </>
    );
  }

  return (
    <>
      <div className="header">
        <div className="logo bookLogo">
          <a href="https://www.amazon.com/Minimalist-Entrepreneur-Great-Founders-More/dp/0593192397">
            <img src={bookImage} loading="lazy" />
          </a>
          <h1>
            <s>Ask My Book</s>
          </h1>
        </div>
        <div className="logo">
          <a href="https://web.archive.org/web/20210814083040/http://www.mit.edu/~6.s085/notes/lecture1.pdf">
            <img src={lecturePdfImage} loading="lazy" />
          </a>
          <h1>Actually, ask this PDF</h1>
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
          {state == "initial" ? (
            <div className="buttons">
              <button id="ask-button">Ask question</button>
            </div>
          ) : (
            <></>
          )}
        </form>
        {answerComponent}
      </div>
    </>
  );
};

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app");
  const root = createRoot(container);
  root.render(<App />);
});
