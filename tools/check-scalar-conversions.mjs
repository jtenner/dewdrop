import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { checkScalarConversions } from "./scalar-conversion-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const imports = Object.create(null);
for (const entry of WebAssembly.Module.imports(module)) {
  // The test module carries an unused diagnostic writer. Any call is a failure.
  assert.deepEqual(entry, { module: "wasi_snapshot_preview1", name: "fd_write", kind: "function" });
  imports.wasi_snapshot_preview1 = { fd_write() { throw new Error("unexpected scalar probe host call"); } };
}
const instance = await WebAssembly.instantiate(module, imports);
instance.exports.__dew_init?.();
const checks = await checkScalarConversions((_source, _target, name) => instance.exports[`probe_${name}`]);
console.log(`native scalar Into conversion checks passed: ${checks}`);
