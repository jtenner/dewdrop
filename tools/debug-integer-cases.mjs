import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugIntegerProbe() {
  return debugOutputProbe([
    "0", "-128", "127", "-32768", "32767", "-2147483648", "2147483647",
    "-9223372036854775808", "9223372036854775807", "255", "65535",
    "4294967295", "18446744073709551615", "Swar32(4294967295)",
    "Swar64(18446744073709551615)", "-101", "0", "-128", "-32768",
    "255", "65535",
  ], "integer Debug", 12);
}
