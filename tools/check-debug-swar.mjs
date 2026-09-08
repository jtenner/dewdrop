import { readFile } from "node:fs/promises";
import { debugSwarProbe } from "./debug-swar-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugSwarProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native SWAR Debug checks passed: ${probe.check(instance.exports)}`);
