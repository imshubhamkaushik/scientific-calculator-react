import { evaluate } from "mathjs";
import { normalizeExpression, balanceParens } from "./expression";

export function evaluateExpression(rawInput) {
    const trimmed = rawInput.trim();
        if (!trimmed) return;
    
        // Prepare a valid expression
        let exp = normalizeExpression(trimmed);
        exp = balanceParens(exp);
    
        try {
          const result = evaluate(exp);
          const formatted =
            typeof result === "number"
              ? Number(result.toPrecision(10)).toString()
              : String(result);
    
          setOutput(formatted);
          setError("");
    
          const entry = {
            id: Date.now(),
            expression: trimmed,
            result: formatted,
            createdAt: new Date().toISOString(),
          };
    
          setHistory((prev) => [entry, ...prev].slice(0, MAX_HISTORY_ITEMS));
        } catch (err) {
          console.error("Evaluation error:", err);
          setOutput("");
          setError("Error");
        }
}

/* Why this matters

App.js no longer evaluates math
Error handling centralized
Predictable behavior*/