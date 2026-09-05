import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { checkMemoryOperations } from "./memory-operation-cases.mjs";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const imports = Object.create(null);
for (const entry of WebAssembly.Module.imports(module)) {
  assert.deepEqual(entry, { module: "wasi_snapshot_preview1", name: "fd_write", kind: "function" });
  imports.wasi_snapshot_preview1 = { fd_write() { throw new Error("unexpected memory probe host call"); } };
}
const instance = await WebAssembly.instantiate(module, imports);
instance.exports.__dew_init?.();
const checks = await checkMemoryOperations(
  type => ({ operation: instance.exports[`probe_${type.toLowerCase()}`], memory: instance.exports.memory }),
  () => ({ copy: instance.exports.probe_vector_copy, memory: instance.exports.memory }),
);
console.log(`native memory operation checks passed: ${checks}`);
