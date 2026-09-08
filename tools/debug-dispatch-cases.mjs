import assert from "node:assert/strict";

export function debugDispatchProbe() {
  let memory;
  const output = [];
  return {
    imports(module) {
      const imports = {};
      for (const entry of WebAssembly.Module.imports(module)) {
        imports[entry.module] ??= {};
        imports[entry.module][entry.name] = () => {
          throw new Error(`unexpected host call: ${entry.module}.${entry.name}`);
        };
      }
      imports.wasi_snapshot_preview1 ??= {};
      imports.wasi_snapshot_preview1.fd_write = (fd, iovs, count, written) => {
        assert.equal(fd, 1, "Debug writes to stdout");
        assert.equal(count, 1);
        const view = new DataView(memory.buffer);
        const start = view.getUint32(iovs, true);
        const length = view.getUint32(iovs + 4, true);
        output.push(...new Uint8Array(memory.buffer, start, length));
        view.setUint32(written, length, true);
        return 0;
      };
      return imports;
    },
    check(exports) {
      memory = exports.memory;
      assert.equal(exports.main(0), 12, "custom Debug runs once per source call");
      assert.equal(exports.main(1), 31, "generic Debug keeps selected trait evidence");
      assert.equal(exports.main(2), 7, "Never argument prevents debug emission");
      assert.deepEqual(output, [], "custom and Never calls do not write to the host");
      assert.equal(exports.main(3), 0, "primitive Debug retains its foreign dependency");
      assert.equal(new TextDecoder().decode(Uint8Array.from(output)), "42");
      output.length = 0;
      assert.equal(exports.main(4), 6, "String formatter counts quoted bytes without imports");
      assert.equal(new TextDecoder().decode(Uint8Array.from(output)), '"core"');
      output.length = 0;
      assert.equal(exports.main(5), 0, "Bytes Debug needs no explicit library import");
      assert.equal(new TextDecoder().decode(Uint8Array.from(output)), 'b"core"');
      return 6;
    },
  };
}
