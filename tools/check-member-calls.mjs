import { loadPureLibraryProbe } from "./pure-library-probe.mjs";
import { checkMemberCalls } from "./member-call-cases.mjs";

const exports = await loadPureLibraryProbe(process.argv[2]);
console.log(`native member/index checks passed: ${checkMemberCalls(exports.main)}`);
