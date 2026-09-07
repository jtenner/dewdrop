import assert from "node:assert/strict";

// Shared output contract for primitive Debug migration tests. Host errors are
// tested only after compilation and instantiation have succeeded.
export function debugOutputProbe(expected, label, negativeCase = 0) {
  let memory;
  let output;
  let calls;
  let mode;
  return {
    imports(module) {
      const imports = {};
      for (const entry of WebAssembly.Module.imports(module)) {
        assert.equal(entry.kind, "function");
        imports[entry.module] ??= {};
        imports[entry.module][entry.name] = () => {
          throw new Error(`unexpected host call: ${entry.module}.${entry.name}`);
        };
      }
      imports.wasi_snapshot_preview1 ??= {};
      imports.wasi_snapshot_preview1.fd_write = (fd, iovs, count, result) => {
        assert.equal(fd, 1);
        assert.equal(count, 1);
        const view = new DataView(memory.buffer);
        const address = view.getUint32(iovs, true);
        const length = view.getUint32(iovs + 4, true);
        assert.ok(length > 0 && address >= 16 && address + length <= 65536);
        calls++;
        if (mode === "error") return 29;
        const progress = mode === "zero" ? 0 : mode === "excess" ? length + 1 : Math.min(3, length);
        if (mode === "partial") output.push(...new Uint8Array(memory.buffer, address, progress));
        view.setUint32(result, progress, true);
        return 0;
      };
      return imports;
    },
    check(exports) {
      memory = exports.memory;
      assert.ok(memory instanceof WebAssembly.Memory);
      mode = "partial";
      for (let which = 0; which < expected.length; which++) {
        calls = 0;
        output = [];
        assert.equal(exports.main(which), 0);
        assert.equal(new TextDecoder().decode(Uint8Array.from(output)), expected[which], `${label} case ${which}`);
        assert.ok(calls >= Math.ceil(expected[which].length / 3), "partial host writes keep all bytes");
      }
      for (const invalid of ["error", "zero", "excess"]) {
        calls = 0;
        output = [];
        mode = invalid;
        assert.throws(() => exports.main(negativeCase), WebAssembly.RuntimeError);
        assert.equal(calls, 1, `reject ${invalid} without another host call`);
      }
      return expected.length + 3;
    },
  };
}
