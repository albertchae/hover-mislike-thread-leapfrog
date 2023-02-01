// Entry point for the build script in your package.json

import React from 'react'
import { createRoot } from 'react-dom/client';

const App = () => {
  return (<div>Hello, Rails 7 from Rails!</div>)
}

document.addEventListener('DOMContentLoaded', () => {
  const container = document.getElementById('app');
  const root = createRoot(container); // createRoot(container!) if you use TypeScript
  root.render(<App />);
})

