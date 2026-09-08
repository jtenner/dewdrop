import { readFile } from "node:fs/promises";
import { intrinsicNameProbe } from "./intrinsic-name-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const probe = intrinsicNameProbe({ testWrapper: true });
const instance = await WebAssembly.instantiate(module, probe.imports(module));
instance.exports.__dew_init?.();
console.log(`native intrinsic name checks passed: ${probe.check(instance.exports)}`);
