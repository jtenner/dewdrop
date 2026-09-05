import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkConstructorEvaluations } from "./constructor-evaluation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native constructor evaluation checks passed: ${checkConstructorEvaluations(exports.main)}`);
