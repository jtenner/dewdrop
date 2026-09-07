import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkStringOperations } from "./string-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native String operation checks passed: ${checkStringOperations(exports.main)}`);
