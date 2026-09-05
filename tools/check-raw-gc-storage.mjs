import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkRawGcStorage } from "./raw-gc-storage-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native raw Wasm array storage checks passed: ${checkRawGcStorage(exports.main)}`);
