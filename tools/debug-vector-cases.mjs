import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugVectorProbe() {
  return debugOutputProbe([
    "v128(0x00000000000000000000000000000000)",
    "v128(0xffffffffffffffffffffffffffffffff)",
    "v128(0x00000000000000000000000000000001)",
    "v128(0x00000000000000010000000000000000)",
    "v128(0xfedcba98765432100123456789abcdef)",
    "v128(0x0123456789abcdeffedcba9876543210)",
    "v128(0xffffffffffffffffffffffffffffffff)",
  ], "V128 Debug");
}
