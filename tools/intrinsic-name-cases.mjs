import assert from "node:assert/strict";

export function intrinsicNameProbe({ testWrapper = false } = {}) {
  return {
    imports(module) {
      const entries = WebAssembly.Module.imports(module);
      if (!testWrapper) assert.deepEqual(entries, [], "pure source acquired host imports");
      // The native test wrapper may retain its assertion writer. Neither
      // the source nor a pure intrinsic needs the old sixteen-import prefix.
      assert.ok(entries.length <= 1, "pure intrinsic names added hidden imports");
      for (const entry of entries) {
        assert.deepEqual(entry, { module: "wasi_snapshot_preview1", name: "fd_write", kind: "function" });
      }
      return { wasi_snapshot_preview1: { fd_write() {
        throw new Error("an arithmetic intrinsic called the host by source spelling");
      } } };
    },
    check(exports) {
      for (let index = 0; index < 17; index++) {
        assert.equal(exports.main(index), 100 + index, `intrinsic name case ${index}`);
      }
      return 17;
    },
  };
}
