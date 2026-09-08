import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkUnitBranches } from "./unit-branch-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native Unit branch checks passed: ${checkUnitBranches(exports)}`);
