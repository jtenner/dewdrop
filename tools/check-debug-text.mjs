import { readFile } from "node:fs/promises";
import { debugTextProbe } from "./debug-text-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugTextProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native text Debug checks passed: ${probe.check(instance.exports)}`);
