import { readFile } from "node:fs/promises";
import { builtinReferenceProbe } from "./builtin-reference-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = builtinReferenceProbe({testWrapper: true});
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native builtin reference checks passed: ${probe.check(instance.exports)}`);
