import { checkGenericQueryOrder } from "./generic-query-order-cases.mjs";
import { loadPureLibraryProbe } from "./pure-library-probe.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native generic query order checks passed: ${checkGenericQueryOrder(exports)}`);
