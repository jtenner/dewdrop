import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkBytesOperations } from "./bytes-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native Bytes operation checks passed: ${checkBytesOperations(exports.main)}`);
