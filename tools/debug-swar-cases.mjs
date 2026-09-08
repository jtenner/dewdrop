import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugSwarProbe() {
  return debugOutputProbe([
    "Swar32(0)", "Swar32(4294967295)", "Swar32(2147483648)", "Swar32(305419896)",
    "Swar64(0)", "Swar64(18446744073709551615)", "Swar64(9223372036854775808)",
    "Swar64(81985529216486895)",
  ], "SWAR Debug", 0, [1, 4, 5]);
}
