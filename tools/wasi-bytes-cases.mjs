import assert from "node:assert/strict";

const capacity = 65520;
const payload = length => Uint8Array.from({ length }, (_, i) => i & 255);
const hash = bytes => (bytes.reduce((sum, byte) => (Math.imul(sum, 31) + byte) >>> 0, 0) + bytes.length) >>> 0;

export function wasiBytesProbe() {
  let memory;
  let mode;
  let calls;
  let output;
  let input;
  let position;
  const reset = next => { mode = next; calls = []; output = []; input = new Uint8Array(); position = 0; };
  return {
    imports(module) {
      const imports = {};
      for (const entry of WebAssembly.Module.imports(module)) {
        imports[entry.module] ??= {};
        imports[entry.module][entry.name] = () => { throw new Error(`unexpected host call: ${entry.module}.${entry.name}`); };
      }
      imports.wasi_snapshot_preview1 ??= {};
      for (const kind of ["write", "read"]) {
        imports.wasi_snapshot_preview1[`fd_${kind}`] = (fd, iovs, count, result) => {
          assert.equal(fd, kind === "write" ? 7 : 9);
          assert.equal(count, 1);
          const view = new DataView(memory.buffer);
          const address = view.getUint32(iovs, true);
          const length = view.getUint32(iovs + 4, true);
          assert.ok(length > 0 && length <= capacity, "bounded nonempty request");
          assert.ok(address >= 16 && address + length <= 65536, "scratch stays in its page");
          calls.push({ kind, length });
          if (mode === "error") return 29;
          if (mode === "excess") { view.setUint32(result, length + 1, true); return 0; }
          let progress;
          if (kind === "write") {
            progress = mode === "zero" ? 0 : mode === "partial" ? Math.min(97, length) : length;
            output.push(...new Uint8Array(memory.buffer, address, progress));
          } else {
            progress = Math.min(length, input.length - position);
            if (mode === "short") progress = Math.min(progress, 37);
            new Uint8Array(memory.buffer, address, progress).set(input.subarray(position, position + progress));
            position += progress;
          }
          view.setUint32(result, progress, true);
          return 0;
        };
      }
      return imports;
    },
    check(exports) {
      memory = exports.memory;
      assert.ok(memory instanceof WebAssembly.Memory);
      let checks = 0;
      for (const length of [0, 1, 17, capacity, capacity + 19, capacity * 2 + 7]) {
        reset("full");
        assert.equal(exports.main(0, length), length);
        assert.deepEqual(Uint8Array.from(output), payload(length), `write exact view: ${length}`);
        assert.equal(calls.length, Math.ceil(length / capacity));
        checks++;
      }
      reset("partial");
      assert.equal(exports.main(0, capacity + 19), capacity + 19);
      assert.deepEqual(Uint8Array.from(output), payload(capacity + 19));
      assert.ok(calls.length > 2, "retry partial host writes");
      checks++;
      for (const [limit, available, short] of [[0, 19, false], [100, 0, false], [100, 37, false], [37, 100, false], [capacity * 2 + 7, capacity * 2 + 7, false], [capacity + 19, capacity, false], [capacity + 19, capacity + 19, true]]) {
        reset(short ? "short" : "full");
        input = payload(available);
        const expected = Math.min(limit, available, short ? 37 : Infinity);
        assert.equal(exports.main(1, limit) >>> 0, hash(input.subarray(0, expected)));
        assert.equal(position, expected);
        if (limit === 0) assert.deepEqual(calls, []);
        if (short) assert.equal(calls.length, 1, "a short read ends this operation");
        checks++;
      }
      for (const kind of ["write", "read"]) {
        for (const invalid of kind === "write" ? ["error", "excess", "zero"] : ["error", "excess"]) {
          reset(invalid);
          // Compilation/instantiation errors are never accepted here. The only
          // expected trap is after this exact host call returns invalid progress.
          assert.throws(() => exports.main(kind === "write" ? 0 : 1, 19), WebAssembly.RuntimeError);
          assert.deepEqual(calls, [{ kind, length: 19 }], `${kind} rejects ${invalid} without retry`);
          checks++;
        }
      }
      return checks;
    },
  };
}
