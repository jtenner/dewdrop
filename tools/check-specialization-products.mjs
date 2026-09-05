import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkSpecializationProducts } from "./specialization-product-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
const checks = checkSpecializationProducts(exports);
console.log(`native specialization product checks passed: ${checks}`);
