import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { decodeDewTestMetadata } from "./dew-test/metadata.mjs";

// These probes must trap for the intended reason, not merely trap somewhere.
function solverProbe(name, code, expected, actual, detail) {
  return {
    name,
    expected: [code, 2, 80n, 0n, 0n, 4294967295, BigInt(expected), BigInt(actual), BigInt(detail)],
  };
}
const probes = [
  {
    name: "LNK-504 two named physical functions cannot own one declaration",
    expected: [504, 5, 77n, (77n << 32n) + 11n, 0n, 4294967295, 4n, 5n, 5n],
  },
  ...[
    ["generic", 1n], ["erroneous", 2n],
    ["nested generic", 1n], ["nested erroneous", 2n],
  ].map(([kind, error]) => ({
    name: `SPC-301 ${kind} request shape is rejected`,
    expected: [301, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, 0n, error, 1n],
  })),
  {
    name: "SPC-303 one call key cannot select two targets",
    expected: [303, 5, 0n, 0n, 17n, 19, 23n, 29n, 3n],
  },
  {
    name: "INV-001 trap preserves complete numeric context",
    expected: [701, 7, 11n, 13n, 17n, 19, 23n, 29n, 31n],
  },
  {
    // The fixture has one module (5100), declaration/body zero, and literal
    // expression zero. Linked physical functions start after two imports.
    name: "BOD-605 emission cannot rewrite a frozen carrier",
    expected: [605, 6, 5100n, 5100n << 32n, 5100n << 32n, 0, 4n, 5n, 2n],
  },
  solverProbe("SOL-204 nested snapshots with identical state are distinct", 204, 1, 0, 2),
  solverProbe("SOL-204 a committed snapshot cannot be replayed", 204, 1, 0, 1),
  solverProbe("SOL-204 commit requires an open snapshot", 204, 1, 0, 0),
  solverProbe("SOL-205 undo arrays must remain parallel", 205, 1, 0, 1),
  solverProbe("SOL-205 undo kind must be valid", 205, 2, 3, 0),
  solverProbe("SOL-205 undo index must be in its arena", 205, 1, 1, 2),
  solverProbe("SOL-206 reset requires closed snapshots", 206, 0, 1, 0),
  solverProbe("SOL-206 zonk requires closed snapshots", 206, 0, 1, 1),
  solverProbe("SOL-201 variable arrays must remain parallel", 201, 1, 0, 1),
  solverProbe("SOL-202 parent cycles have a bounded walk", 202, 2, 2, 0),
  solverProbe("SOL-202 parents must stay in the variable arena", 202, 1, 1, 0),
  solverProbe("SOL-203 union size cannot overflow", 203, 4294967294, 4294967295, 0),
  solverProbe("SOL-207 resolved type encoding cannot overflow", 207, 2147483646, 2147483647, 0),
];
const module = await WebAssembly.compile(await readFile(process.argv[2]));
const sections = WebAssembly.Module.customSections(module, "dew.tests");
assert.equal(sections.length, 1, "one Dew test manifest is required");
const tests = decodeDewTestMetadata(sections[0]);
for (const probe of probes) {
  const matches = tests.filter((test) => test.name === probe.name);
  assert.equal(matches.length, 1, `missing or duplicate probe: ${probe.name}`);
  let instance;
  const output = [];
  instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: {
      fd_write(_fd, iovs, count, written) {
        const memory = instance.exports.memory;
        const view = new DataView(memory.buffer);
        let total = 0;
        for (let i = 0; i < count; i++) {
          const address = view.getUint32(iovs + i * 8, true);
          const length = view.getUint32(iovs + i * 8 + 4, true);
          output.push(Buffer.from(new Uint8Array(memory.buffer, address, length)));
          total += length;
        }
        view.setUint32(written, total, true);
        return 0;
      },
    },
  });
  instance.exports.__dew_init?.();
  assert.throws(
    () => instance.exports[matches[0].export](),
    (error) => error instanceof WebAssembly.RuntimeError && /unreachable/.test(error.message),
    probe.name,
  );
  const view = new DataView(instance.exports.memory.buffer);
  const context = `${probe.name}: ${Buffer.concat(output).toString("utf8")}`;
  assert.equal(view.getBigUint64(0, true), 4919706420659244884n, context);
  assert.equal(view.getBigUint64(8, true), 1n, context);
  assert.deepEqual([
    view.getUint32(16, true), view.getUint32(20, true),
    view.getBigUint64(24, true), view.getBigUint64(32, true),
    view.getBigUint64(40, true), view.getUint32(48, true),
    view.getBigUint64(56, true), view.getBigUint64(64, true),
    view.getBigUint64(72, true),
  ], probe.expected, context);
}
console.log(`self-host invariant trap records passed: ${probes.length}`);
