import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkRawArrayContracts } from "./raw-array-contract-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native raw array checks passed: ${checkRawArrayContracts(exports.main)}`);
