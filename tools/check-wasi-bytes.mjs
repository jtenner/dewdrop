import { readFile } from "node:fs/promises";
import { wasiBytesProbe } from "./wasi-bytes-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = wasiBytesProbe();
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native WASI Bytes checks passed: ${probe.check(instance.exports)}`);
