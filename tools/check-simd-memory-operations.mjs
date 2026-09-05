import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSimdMemoryOperations } from "./simd-memory-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = await checkSimdMemoryOperations(index => ({ operation: exports[`probe_${index}`], memory: exports.memory }));
console.log(`native SIMD memory operation checks passed: ${checks}`);
