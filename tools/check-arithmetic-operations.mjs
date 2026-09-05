import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkArithmeticOperations } from "./arithmetic-operation-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = await checkArithmeticOperations((_type, _op, name) => exports[`probe_${name}`]);
console.log(`native arithmetic operation checks passed: ${checks}`);
