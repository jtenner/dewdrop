import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkStringViewOperations } from "./string-view-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native StringView operation checks passed: ${checkStringViewOperations(exports.main)}`);
