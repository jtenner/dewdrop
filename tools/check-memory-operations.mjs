import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkMemoryOperations } from "./memory-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = await checkMemoryOperations(
  type => ({ operation: exports[`probe_${type.toLowerCase()}`], memory: exports.memory }),
  () => ({ copy: exports.probe_vector_copy, memory: exports.memory }),
);
console.log(`native memory operation checks passed: ${checks}`);
