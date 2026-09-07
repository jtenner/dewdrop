import { readFile } from "node:fs/promises";
import { debugDispatchProbe } from "./debug-dispatch-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = debugDispatchProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native Debug dispatch checks passed: ${probe.check(instance.exports)}`);
