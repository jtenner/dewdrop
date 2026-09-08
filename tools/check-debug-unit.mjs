import { readFile } from "node:fs/promises";
import { debugUnitProbe } from "./debug-unit-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugUnitProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native Unit Debug checks passed: ${probe.check(instance.exports)}`);
