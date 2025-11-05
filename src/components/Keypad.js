import React from "react";
import Button from "./Button";
import "./Keypad.css";

const Keypad = ({ onButtonClick }) => {
  const buttons = [
    ["C", "⌫", "(", ")"],
    ["sin", "cos", "tan", "÷"],
    ["7", "8", "9", "×"],
    ["4", "5", "6", "-"],
    ["1", "2", "3", "+"],
    ["0", ".", "xʸ", "="],
    ["√", "log", "π", "e"],
  ];

  return (
    <div className="calc-keypad">
      {buttons.flat().map((btn, idx) => (
        <Button
          key={idx}
          value={btn}
          className={
            btn === "C" ? "btn-clear" : btn === "=" ? "btn-equals" : ""
          }
          onClick={onButtonClick}
        />
      ))}
    </div>
  );
};

export default Keypad;
