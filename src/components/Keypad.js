import React from "react";
import PropTypes from "prop-types";
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

  const getButtonClass = (btn) => {
    if (btn === "C") return "btn-clear";
    if (btn === "=") return "btn-equals";
    return "";
  };

  return (
    <div className="calc-keypad" aria-label="Calculator keypad">
      {buttons.flat().map((btn) => (
        <Button
          key={btn}
          value={btn}
          className={getButtonClass(btn)}
          onClick={onButtonClick}
        />
      ))}
    </div>
  );
};

Keypad.propTypes = {
  onButtonClick: PropTypes.func.isRequired,
};

export default Keypad;
