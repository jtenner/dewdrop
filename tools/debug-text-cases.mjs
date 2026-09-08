import { debugOutputProbe } from "./debug-output-probe.mjs";

function escapedByte(byte) {
  const escapes = new Map([[34, '\\"'], [92, "\\\\"], [10, "\\n"], [13, "\\r"], [9, "\\t"]]);
  if (escapes.has(byte)) return escapes.get(byte);
  if (byte < 32 || byte > 126) return `\\x${byte.toString(16).padStart(2, "0")}`;
  return String.fromCharCode(byte);
}

export function debugTextProbe() {
  return debugOutputProbe([
    '""', 'b""',
    '"quote\\" slash\\\\ newline\\n return\\r tab\\t λ 🌍"',
    'b"\\x00\\x01\\x1f \\"\\\\\\n\\r\\t~\\x7f\\x80\\xff"',
    '"hello£"', 'b"\\xff\\x00\\x7f"',
    '"generic"', 'b"generic\\xff"',
    `"${"a".repeat(65520)}"`,
    `b"${Array.from({ length: 256 }, (_, byte) => escapedByte(byte)).join("")}"`,
    `b"${"\\x00".repeat(17000)}"`,
    '"\\x00\\x1f\\x7f\u0080🌍"',
  ], "text Debug");
}
