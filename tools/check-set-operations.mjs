import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSetOperations } from "./set-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native Set operation checks passed: ${checkSetOperations(exports.main)}`);
