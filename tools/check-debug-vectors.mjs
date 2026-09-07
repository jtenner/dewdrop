import { readFile } from "node:fs/promises";
import { debugVectorProbe } from "./debug-vector-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugVectorProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native V128 Debug checks passed: ${probe.check(instance.exports)}`);
