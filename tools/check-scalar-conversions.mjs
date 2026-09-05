import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkScalarConversions } from "./scalar-conversion-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = await checkScalarConversions((_source, _target, name) => exports[`probe_${name}`]);
console.log(`native scalar Into conversion checks passed: ${checks}`);
