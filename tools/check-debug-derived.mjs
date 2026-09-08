import { readFile } from "node:fs/promises";
import { debugDerivedProbe } from "./debug-derived-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugDerivedProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native derived Debug checks passed: ${probe.check(instance.exports)}`);
