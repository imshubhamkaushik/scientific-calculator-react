// Convert calculator symbols to mathjs-compatible expressions

/* Why this is best practice

Pure functions
No React dependency
Easily testable
Clear domain responsibility*/

export function normalizeExpression(inputStr) {
  return inputStr
      .replaceAll("÷", "/")
      .replaceAll("×", "*")
      .replaceAll("π", "pi")
      // 'e' is already mathjs's constant, no replacement needed
      .replaceAll("xʸ", "^")
      .replaceAll("√", "sqrt")
      // replace "log" that is not already "log10"
      .replaceAll(/log(?!10)/g, "log10");
  // mathjs uses log for natural log, so we use log10 for base-10 log
  // 'e', 'sin', 'cos', 'tan' are already recognized by mathjs
}

// Balance missing closing parenthesies in expression
export function balanceParens(exp) {
    const openParens = (exp.match(/\(/g) || []).length;
    const closeParens = (exp.match(/\)/g) || []).length;

    if (openParens > closeParens) {
        return exp + ")".repeat(openParens - closeParens);
    }
    return exp;
}