import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkFixedArrayOperations } from "./fixed-array-operations-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native FixedArray checks passed: ${checkFixedArrayOperations(exports.main)}`);
