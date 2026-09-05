import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkRawGcUnit } from "./raw-gc-unit-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native raw Unit array checks passed: ${checkRawGcUnit(exports.main)}`);
