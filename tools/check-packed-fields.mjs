import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkPackedFields } from "./packed-field-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native packed field checks passed: ${checkPackedFields(exports.main)}`);
