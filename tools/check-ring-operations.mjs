import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkRingOperations } from "./ring-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native ring operation checks passed: ${checkRingOperations(exports.main)}`);
