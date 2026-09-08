import assert from "node:assert/strict";

export function builtinReferenceProbe({ testWrapper = false } = {}) {
  return {
    imports(module) {
      const entries = WebAssembly.Module.imports(module);
      if (!testWrapper) assert.deepEqual(entries, [], "raw builtin references acquired imports");
      assert.ok(entries.length <= 1);
      for (const entry of entries) {
        assert.deepEqual(entry, {module: "wasi_snapshot_preview1", name: "fd_write", kind: "function"});
      }
      return {wasi_snapshot_preview1: {fd_write() {
        throw new Error("raw builtin reference called the host");
      }}};
    },
    check(exports) {
      for (let index = 0; index < 9; index++) {
        assert.equal(exports.main(index), 1, `builtin reference case ${index}`);
      }
      assert.throws(() => exports.main(9), error =>
        error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
        "an outlined unreachable instruction must trap at execution");
      return 10;
    },
  };
}
