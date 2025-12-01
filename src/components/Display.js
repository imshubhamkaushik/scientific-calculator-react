import React from "react";
import PropTypes from "prop-types";
import "./Display.css";

const Display = ({ input, output, error }) => {
  let text = "0";
  let spanClass = "";

  if (error) {
    text = error;
    spanClass = "calc-display-error";
  } else if (output) {
    text = output;
  } else if (input) {
    text = input;
  }

  return (
    <div className="calc-display" aria-label="Calculator display">
      <span className={spanClass}>{text}</span>
    </div>
  );
};

Display.propTypes = {
input: PropTypes.string.isRequired,
output: PropTypes.string.isRequired,
error: PropTypes.string.isRequired,
};

export default Display;