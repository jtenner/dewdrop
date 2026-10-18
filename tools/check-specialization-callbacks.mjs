import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSpecializationCallbacks, checkErasedMutableCapture } from "./specialization-callback-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = checkSpecializationCallbacks(exports) + checkErasedMutableCapture(exports);
console.log(`native specialization callback checks passed: ${checks}`);
