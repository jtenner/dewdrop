import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkTypeQueries } from "./type-query-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native type query checks passed: ${checkTypeQueries(exports.main)}`);
