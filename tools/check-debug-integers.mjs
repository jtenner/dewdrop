import { readFile } from "node:fs/promises";
import { debugIntegerProbe } from "./debug-integer-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugIntegerProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native integer Debug checks passed: ${probe.check(instance.exports)}`);
