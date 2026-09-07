import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkProductPatterns } from "./product-pattern-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native product pattern checks passed: ${checkProductPatterns(exports)}`);
