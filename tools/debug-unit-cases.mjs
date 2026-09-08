import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugUnitProbe() {
  return debugOutputProbe(["()", "()", "()"], "Unit Debug");
}
