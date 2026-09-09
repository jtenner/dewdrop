import assert from "node:assert/strict";

export function productionAssertionProbe() {
  const effects = [];
  return {
    imports(module) {
      const entries = WebAssembly.Module.imports(module);
      assert.deepEqual(entries.filter(entry => entry.module === "assertion_probe"), [
        { module: "assertion_probe", name: "effect", kind: "function" },
      ], "the explicit effect function retains its foreign identity");
      const wasi = {};
      for (const entry of entries) {
        assert.ok(entry.kind === "function" && (
          (entry.module === "assertion_probe" && entry.name === "effect") ||
          entry.module === "wasi_snapshot_preview1"
        ), `unexpected import ${entry.module}.${entry.name}`);
        if (entry.module === "wasi_snapshot_preview1") {
          wasi[entry.name] = () => { throw new Error(`unexpected production assertion host call: ${entry.name}`); };
        }
      }
      return {
        assertion_probe: { effect(value) { effects.push(value); } },
        // The manifests can retain unused WASI dependencies. Every host call
        // except the explicit effect probe is an error on both paths.
        wasi_snapshot_preview1: wasi,
      };
    },
    check(exports) {
      effects.length = 0;
      assert.equal(exports.main(1), 255, "preamble-only imports reach the Dew byte access body");
      assert.deepEqual(effects, [1, 2, 3], "condition and message are evaluated once, in order");
      effects.length = 0;
      assert.throws(() => exports.main(0), error =>
        error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message));
      assert.deepEqual(effects, [1, 2], "a failed assertion stops later effects");
      return 2;
    },
  };
}
