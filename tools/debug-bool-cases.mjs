import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugBoolProbe() {
  return debugOutputProbe(["true", "false", "true", "false", "false"], "Bool Debug", 1, [1, 2]);
}
