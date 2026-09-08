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
  ...[
    ["aligned physical local tables cannot omit a logical local", 3n, 2n, 711n],
    ["physical local carriers remain complete", 3n, 2n, 712n],
    ["physical expressions cannot omit the body tail", 1n, 0n, 713n],
    ["physical control states require an owning loop", 0n, 1n, 714n],
    ["physical control state values require an owning loop", 0n, 1n, 715n],
    ["physical control results require an owning loop", 0n, 1n, 716n],
    ["physical control result values require an owning loop", 0n, 1n, 717n],
  ].map(([name, expected, actual, detail]) => ({
    name: `ARN-103 ${name}`,
    expected: [103, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, expected, actual, detail],
  })),
  ...[
    ["belong to an earlier body", 0], ["follow its body", 2],
    ["be the missing sentinel", 4294967295],
  ].map(([name, expression]) => ({
    name: `ARN-102 frozen expression cannot ${name}`,
    expected: [102, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, expression, 1n, BigInt(expression), 1n],
  })),
  {
    name: "ARN-106 physical expression table preserves stored identity",
    expected: [106, 6, 5100n, 5100n << 32n, 5100n << 32n, 1, 0n, 1n, 713n],
  },
  {
    name: "EVD-211 implementation type cycles retain the type identity",
    expected: [211, 3, 6014n, 0n, 0n, 3, 0n, 3n, 1n],
  },
  {
    name: "EVD-211 interface type cycles retain the type identity",
    expected: [211, 3, 6000n, 0n, 0n, 3, 0n, 3n, 1n],
  },
  {
    name: "ARN-101 interface type child spans are owned",
    expected: [101, 3, 6000n, 0n, 0n, 3, 0n, 0n, 1n],
  },
  ...[
    ["LNK-502 linked function index must match its table slot", 502, 1, 0n, 99n, 0n],
    ["LNK-504 linked function fragment must exist", 504, 1, 1n, 99n, 2n],
    ["LNK-504 linked declaration must match its fragment", 504, 2, (5100n << 32n) + 1n, (5100n << 32n) + 2n, 3n],
    ["LNK-503 module type base cannot be missing", 503, null, 0n, 4294967295n, 0n],
    ["LNK-502 linked type index must match its table slot", 502, null, 0n, 99n, 1n],
    ["LNK-504 linked type fragment must match its owner", 504, null, 0n, 99n, 5n],
  ].map(([name, code, declaration, expected, actual, detail]) => ({
    name,
    expected: [code, 5, 5100n, declaration === null ? 0n : (5100n << 32n) + BigInt(declaration), 0n, 0, expected, actual, detail],
  })),
  {
    name: "BOD-610 linked definition must have a body",
    expected: [610, 5, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 0, 5100n << 32n, 0n, 0n],
  },
  {
    name: "LNK-504 source bodies must have unique identities",
    expected: [504, 5, 5100n, (5100n << 32n) + 1n, 0n, 4294967295, 0n, 5100n << 32n, 12n],
  },
  {
    name: "ARN-101 physical body span must fit its arena",
    expected: [101, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, 4294967295, 2n, 1n, (1n << 32n) + 2n],
  },
  ...[
    ["physical expression cannot precede its body", 0],
    ["physical expression cannot follow its body", 2],
    ["missing expression cannot become a body slot", 4294967295],
  ].map(([name, expression]) => ({
    name: `ARN-102 ${name}`,
    expected: [102, 6, 5100n, (5100n << 32n) + 1n, (5100n << 32n) + 1n, expression, 1n, BigInt(expression), 1n],
  })),
  ...[
    ["repeated SCC module is rejected", 0, 4294967295, 0, 6],
    ["missing SCC module is rejected", 4294967295, 3, 2, 1],
    ["reversed dependency order is rejected", 1, 1, 2, 10],
    ["overlapping SCC spans are rejected", 1, 1, 0, 3],
    ["dependency span overflow is rejected", 1, 2, 4294967295, 8],
    ["out of range dependency is rejected", 1, 3, 3, 9],
    ["stored component identity must match", 1, 1, 2, 7],
  ].map(([name, expression, expected, actual, detail]) => ({
    name: `LNK-501 ${name}`,
    expected: [501, 5, 0n, 0n, 0n, expression, BigInt(expected), BigInt(actual), BigInt(detail)],
  })),
  {
    name: "SPC-303 source call declarations cannot disagree",
    expected: [303, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, (88n << 32n) + 11n, (88n << 32n) + 12n, 3n],
  },
  {
    name: "SPC-303 source call specializations cannot disagree",
    expected: [303, 5, 77n, (88n << 32n) + 11n, (77n << 32n) + 17n, 19, 7n, 9n, 3n],
  },
  {
    name: "ARN-104 compile-time storage requires prior child types",
    expected: [104, 2, 24702n, 0n, 0n, 4294967295, 1n, 1n, 0n],
  },
  {
    name: "ARN-101 compile-time storage rejects invalid spans",
    expected: [101, 2, 24702n, 0n, 0n, 4294967295, 1n, 2n, 1n],
  },
  ...["generic", "parameter"].map((kind, field) => ({
    name: `ARN-106 imported ${kind} spans cannot alias a local declaration`,
    expected: [106, 1, 5700n, 5701n << 32n, 0n, 4294967295, 5700n, 5701n, BigInt(field)],
  })),
  {
    name: "ARN-103 frozen physical local slots remain parallel",
    expected: [103, 6, 5100n, 5100n << 32n, 5100n << 32n, 4294967295, 3n, 2n, 710n],
  },
  {
    name: "FRG-401 lambda parameters cannot exceed their local span",
    expected: [401, 4, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 4294967295, 3n, 4n, 0n],
  },
  {
    name: "FRG-401 lambda parameters require parameter locals",
    expected: [401, 4, 5100n, (5100n << 32n) + 1n, 5100n << 32n, 4294967295, 0n, 0n, 0n],
  },
  {
    name: "BOD-610 a linked function requires a source body",
    expected: [610, 5, 5100n, 5100n << 32n, 5100n << 32n, 0, 5100n << 32n, 0n, 0n],
  },
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
  solverProbe("SOL-205 commit cannot discard an invalid undo record", 205, 2, 3, 0),
  solverProbe("SOL-206 reset cannot discard aligned pending work", 206, 0, 1, 40),
  solverProbe("SOL-205 reset cannot discard an unowned undo record", 205, 0, 1, 3),
  solverProbe("SOL-206 zonk rejects a later structural cycle", 206, 0, 1, 1),
  solverProbe("ARN-104 solver type reads cannot hide a missing sentinel", 104, 1, 4294967295, 0),
  solverProbe("ARN-104 unification cannot hide a missing sentinel", 104, 2, 4294967295, 0),
  solverProbe("SOL-201 representative checks the stored variable identity", 201, 0, 0, 4),
  {
    name: "ARN-102 name resolution checks body ownership before subtraction",
    expected: [102, 1, 6044n, (6044n << 32n) | 1n, (6044n << 32n) | 1n, 0, 1n, 0n, 1n],
  },
  {
    name: "ARN-101 name resolution checks spans before allocating work arrays",
    expected: [101, 1, 6045n, 6045n << 32n, 6045n << 32n, 4294967295, 1n, 4294967295n, 1n],
  },
  solverProbe("ARN-101 unification checks owned spans before identity", 101, 1, 1, 1),
  solverProbe("SOL-205 undo index must be in its arena", 205, 1, 1, 2),
  solverProbe("SOL-205 undo size must be positive", 205, 1, 0, 0),
  solverProbe("SOL-205 undo binding must name a present type", 205, 2, 2, 0),
  solverProbe("SOL-206 unify cannot discard a broken work stack", 206, 1, 0, 20),
  solverProbe("SOL-206 zonk cannot discard a broken work stack", 206, 1, 0, 21),
  solverProbe("SOL-206 type caches must remain parallel", 206, 1, 0, 12),
  solverProbe("SOL-206 zonk product must have its child results", 206, 1, 0, 23),
  solverProbe("ARN-101 zonk argument span must belong to its arena", 101, 1, 1, 1),
  solverProbe("SOL-206 zonk application must have the correct term", 206, 1, 0, 28),
  solverProbe("SOL-206 zonk function must have the correct term", 206, 2, 0, 28),
  solverProbe("SOL-206 zonk product must have the correct term", 206, 3, 0, 28),
  solverProbe("SOL-204 rollback cannot invent missing arena contents", 204, 1, 0, 12),
  solverProbe("SOL-206 reset requires closed snapshots", 206, 0, 1, 0),
  solverProbe("SOL-206 zonk requires closed snapshots", 206, 0, 1, 1),
  solverProbe("SOL-201 variable arrays must remain parallel", 201, 1, 0, 1),
  solverProbe("SOL-202 parent cycles have a bounded walk", 202, 2, 2, 0),
  solverProbe("SOL-202 parents must stay in the variable arena", 202, 1, 1, 0),
  solverProbe("SOL-202 type binding cycles have a bounded walk", 202, 2, 2, 1),
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
