import React, { useState } from "react";
import { evaluate } from "mathjs";
import Display from "./components/Display";
import Keypad from "./components/Keypad";
import "./App.css";

function App() {
  const [input, setInput] = useState("");
  const [output, setOutput] = useState("");

  const handleButtonClick = (btn) => {
    if (output === "Error") setOutput("");
    switch (btn) {
      case "C":
        setInput("");
        setOutput("");
        break;
      case "⌫":
        setInput(input.slice(0, -1));
        break;
      case "=":
        try {
          let exp = input
            .replace(/÷/g, "/")
            .replace(/×/g, "*")
            .replace(/π/g, "pi")
            .replace(/e/g, "e")
            .replace(/xʸ/g, "^")
            .replace(/√/g, "sqrt")
            .replace(/log/g, "log10");

          // append missing closing parentheses to balance expression
          const openParens = (exp.match(/\(/g) || []).length;
          const closeParens = (exp.match(/\)/g) || []).length;

          if (openParens > closeParens) {
            exp += ")".repeat(openParens - closeParens);
          }

          const result = evaluate(exp);
          setOutput(result);
        } catch {
          setOutput("Error");
        }
        break;
      case "π":
        setInput(input + "π");
        break;
      case "e":
        setInput(input + "e");
        break;
      case "(":
        setInput(input + "(");
        break;
      case ")":
        setInput(input + ")");
        break;
      case "+":
        setInput(input + "+");
        break;
      case "-":
        setInput(input + "-");
        break;
      case "÷":
        setInput(input + "÷");
        break;
      case "×":
        setInput(input + "×");
        break;
      case "xʸ":
        setInput(input + "^"); // caret for exponent in mathjs
        break;
      case "√":
        setInput(input + "√("); // add opening paren immediately
        break;
      case "sin":
      case "cos":
      case "tan":
      case "log":
        setInput(input + btn + "(");
        break;
      default:
        setInput(input + btn);
    }
  };

  return (
    <div className="calc-container">
      <h2 className="calc-title">Scientific Calculator</h2>
      <Display input={input} output={output} />
      <Keypad onButtonClick={handleButtonClick} />
    </div>
  );
}

export default App;
