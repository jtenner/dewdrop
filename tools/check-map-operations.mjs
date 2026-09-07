import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkMapOperations } from "./map-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native Map operation checks passed: ${checkMapOperations(exports.main)}`);
