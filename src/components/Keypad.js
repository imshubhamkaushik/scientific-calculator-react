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

  return (
    <div className="calc-keypad" aria-label="Calculator keypad">
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

Keypad.propTypes = {
  onButtonClick: PropTypes.func.isRequired,
};

export default Keypad;
