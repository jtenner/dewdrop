import { loadPureLibraryProbe } from "../pure-library-probe.mjs";
import { checkBytesStaging } from "./staging-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`Bytes staging checks passed: ${checkBytesStaging(exports)}`);
