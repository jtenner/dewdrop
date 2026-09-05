import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

export async function loadPureLibraryProbe(path) {
  const module = await WebAssembly.compile(await readFile(path));
  const imports = Object.create(null);
  for (const entry of WebAssembly.Module.imports(module)) {
    // Test modules include an unused diagnostic writer. It must not execute.
    assert.deepEqual(entry, { module: "wasi_snapshot_preview1", name: "fd_write", kind: "function" });
    imports.wasi_snapshot_preview1 = { fd_write() { throw new Error(`unexpected host call in ${path}`); } };
  }
  const instance = await WebAssembly.instantiate(module, imports);
  instance.exports.__dew_init?.();
  return instance.exports;
}
