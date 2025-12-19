/* global globalThis */ // tell ESLint that globalThis is a known global

import React, { useState, useEffect, useCallback } from "react";
import Display from "./components/Display";
import Keypad from "./components/Keypad";
import { evaluateExpression } from "./utils/evaluator";
import "./App.css";

const HISTORY_KEY = "scientific_calculator_history_v1";
const MAX_HISTORY_ITEMS = 50;
const MAX_INPUT_LENGTH = 60;

function App() {
  const [input, setInput] = useState("");
  const [output, setOutput] = useState("");
  const [history, setHistory] = useState([]);
  const [error, setError] = useState("");

  //Load history from localStorage on mount
  useEffect(() => {
    try {
      const raw = localStorage.getItem(HISTORY_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) {
          setHistory(parsed.slice(0, MAX_HISTORY_ITEMS));
        }
      }
    } catch (err) {
      console.error("Failed to load history from localStorage", err);
    }
  }, []);

  // Persist history to localStorage whenever it changes
  useEffect(() => {
    try {
      localStorage.setItem(HISTORY_KEY, JSON.stringify(history));
    } catch (err) {
      console.error("Failed to save history to localStorage", err);
    }
  }, [history]);

  const handleButtonClick = useCallback(
    (btn) => {
      // Clear "Error" on next input
      if (error) setError("");

      const appendToken = (token) => {
        setInput((prev) =>
          prev.length < MAX_INPUT_LENGTH ? prev + token : prev
        );
        setOutput("");
      };

      switch (btn) {
        case "C":
          setInput("");
          setOutput("");
          setError("");
          break;

        case "⌫":
          setInput((prev) => prev.slice(0, -1));
          setOutput("");
          break;

        case "=":
          if (input.trim()) return;
          handleEvaluate();
          break;

        case "π":
        case "e":
        case "(":
        case ")":
        case "+":
        case "-":
        case "÷":
        case "×":
          appendToken(btn);
          break;

        case "xʸ":
          // show pretty "xʸ" in input; convert to "^" in normalizeExpression for mathjs
          appendToken("xʸ");
          break;

        case "√":
          appendToken("√(");
          break;

        case "sin":
        case "cos":
        case "tan":
        case "log":
          appendToken(btn + "(");
          break;

        case ".":
        case "0":
        case "1":
        case "2":
        case "3":
        case "4":
        case "5":
        case "6":
        case "7":
        case "8":
        case "9":
        default:
          // Fallback: append raw token
          appendToken(btn);
          break;
      }
    },
    [error, input, evaluateExpression]
  );

  const handleEvaluate = useCallback(() => {
    const { result, error } = evaluateExpression(input);

    if (error) {
      setOutput("");
      setError(error);
      return;
    }

    setOutput(result);
    setError("");

    const entry = {
      id: Date.now(),
      expression: input,
      result,
      createdAt: new Date().toISOString(),
    };

    setHistory((prev) => [entry, ...prev].slice(0, MAX_HISTORY_ITEMS));
  }, [input]);
  
  const handleClearHistory = () => {
    setHistory([]);
  };

  // Keyboard support
  useEffect(() => {
    const onKeyDown = (event) => {
      const { key } = event;

      // digits + decimal
      if (/^[0-9.]$/.test(key)) {
        event.preventDefault();
        handleButtonClick(key);
        return;
      }

      // operators
      if (key === "+") {
        event.preventDefault();
        handleButtonClick("+");
        return;
      }
      if (key === "-") {
        event.preventDefault();
        handleButtonClick("-");
        return;
      }
      if (key === "*") {
        event.preventDefault();
        handleButtonClick("×");
        return;
      }
      if (key === "/") {
        event.preventDefault();
        handleButtonClick("÷");
        return;
      }

      if (key === "(" || key === ")") {
        event.preventDefault();
        handleButtonClick(key);
        return;
      }

      if (key === "^") {
        event.preventDefault();
        handleButtonClick("xʸ");
        return;
      }

      if (key.toLowerCase() === "e") {
        event.preventDefault();
        handleButtonClick("e");
        return;
      }

      if (key === "Enter" || key === "=") {
        event.preventDefault();
        handleButtonClick("=");
        return;
      }

      if (key === "Backspace") {
        event.preventDefault();
        handleButtonClick("⌫");
        return;
      }

      if (key === "Escape") {
        event.preventDefault();
        handleButtonClick("C");
      }
    };

    globalThis.addEventListener("keydown", onKeyDown);
    return () => globalThis.removeEventListener("keydown", onKeyDown);
  }, [handleButtonClick]);

  return (
    <div className="calc-container">
      <h2 className="calc-title">Scientific Calculator</h2>

      <Display input={input} output={output} error={error} />

      <Keypad onButtonClick={handleButtonClick} />

      <div className="calc-footer">
        <button
          type="button"
          className="btn-footer"
          onClick={handleClearHistory}
        >
          Clear History
        </button>
      </div>

      <div
        style={{
          marginTop: 16,
          width: "100%",
          color: "#ddd",
          fontSize: "0.9rem",
        }}
      >
        <h3 style={{ marginBottom: 8, fontSize: "1rem" }}>
          Recent Calculations
        </h3>
        {history.length === 0 ? (
          <div>No history yet</div>
        ) : (
          <ul
            style={{
              listStyle: "none",
              padding: 0,
              maxHeight: 160,
              overflowY: "auto",
            }}
          >
            {history.map((h) => (
              <li key={h.id} style={{ marginBottom: 6 }}>
                <strong>{h.expression}</strong> = {String(h.result)}{" "}
                {h.createdAt && (
                  <small style={{ color: "#888" }}>
                    ({new Date(h.createdAt).toLocaleString()})
                  </small>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}

export default App;
