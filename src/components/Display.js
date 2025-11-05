import React from "react";
import "./Display.css";

const Display = ({ input, output }) => {
  return (
    <div className="calc-display">
      <span>{output ? output : input || "0"}</span>
    </div>
  );
};

export default Display;
