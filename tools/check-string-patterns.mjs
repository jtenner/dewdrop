import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkStringPatterns } from "./string-pattern-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native String pattern checks passed: ${checkStringPatterns(exports.main)}`);
