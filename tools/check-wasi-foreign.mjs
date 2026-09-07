import { readFile } from "node:fs/promises";
import { wasiForeignProbe } from "./wasi-foreign-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = wasiForeignProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native WASI foreign checks passed: ${probe.check(instance.exports)}`);
