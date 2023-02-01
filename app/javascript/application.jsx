// Entry point for the build script in your package.json

import React, { useState } from "react";
import { createRoot } from "react-dom/client";

const App = () => {
  const [question, setQuestion] = useState("");
  function handleChange(event) {
    setQuestion(event.target.value);
  }
  function handleSubmit(event) {
    alert("A question was submitted: " + question);
    event.preventDefault();
  }

  return (
    <div className="main">
      <p className="credits">
        This is an experiment in using AI to make my book's content more
        accessible. Ask a question and AI'll answer it in real-time:
      </p>

      <form onSubmit={handleSubmit}>
        <textarea value={question} onChange={handleChange} />{" "}
        <input type="submit" value="Ask question" />
      </form>
    </div>
  );
};

document.addEventListener("DOMContentLoaded", () => {
  const container = document.getElementById("app");
  const root = createRoot(container);
  root.render(<App />);
});
