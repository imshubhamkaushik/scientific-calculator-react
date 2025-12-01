import React from "react";
import PropTypes from "prop-types";
import "./Button.css";

const Button = ({ value, onClick, className = "" }) => {
  const handleClick = () => {
    if (typeof onClick === "function") {
      onClick(value);
    }
  };

  return (
    <button type="button" className={`btn ${className}`} onClick={handleClick}>
      {value}
    </button>
  );
};

Button.propTypes = {
  value: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  className: PropTypes.string,
};

export default Button;
