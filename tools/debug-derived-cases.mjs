import { debugOutputProbe } from "./debug-output-probe.mjs";

export function debugDerivedProbe() {
  return debugOutputProbe([
    "Empty {}",
    "Point { value: -17, active: true }",
    "Envelope { value: Point { value: 42, active: false } }",
    "Event::Idle",
    "Event::Pair(-9, ())",
    "Event::Named { count: 19 }",
  ], "derived Debug");
}
