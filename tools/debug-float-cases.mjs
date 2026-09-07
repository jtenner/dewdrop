import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugFloatProbe() {
  return debugOutputProbe([
    "f32(0x00000000)", "f32(0x80000000)", "f32(0x3f800000)",
    "f32(0x7f800000)", "f32(0xff800000)", "f32(0x7fc12345)",
    "f32(0x00000001)", "f32(0x7f7fffff)",
    "f64(0x0000000000000000)", "f64(0x8000000000000000)",
    "f64(0x3ff0000000000000)", "f64(0x7ff0000000000000)",
    "f64(0xfff0000000000000)", "f64(0x7ff8123456789abc)",
    "f64(0x0000000000000001)", "f64(0x7fefffffffffffff)",
    "f32(0xffc12345)", "f64(0xfff8123456789abc)",
  ], "float Debug");
}
