import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSpecializationCallbacks } from "./specialization-callback-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = checkSpecializationCallbacks(exports);
console.log(`native specialization callback checks passed: ${checks}`);
