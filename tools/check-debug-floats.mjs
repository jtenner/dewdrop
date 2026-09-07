import { readFile } from "node:fs/promises";
import { debugFloatProbe } from "./debug-float-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugFloatProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native float Debug checks passed: ${probe.check(instance.exports)}`);
