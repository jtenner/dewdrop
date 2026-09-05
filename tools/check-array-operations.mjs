import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkArrayOperations } from "./array-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native array operation checks passed: ${checkArrayOperations(exports.main)}`);
