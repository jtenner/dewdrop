import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkMathOperations } from "./math-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = await checkMathOperations(
  (width, op) => exports[`probe_f${width}_${op}`],
  (width, op) => exports[`probe_f${width}_${op}_bits`],
  width => exports[`probe_f${width}_clamp`],
  () => exports.probe_ctz,
);
console.log(`native math operation checks passed: ${checks}`);
