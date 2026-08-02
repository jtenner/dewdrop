import { readFile } from "node:fs/promises";
import assert from "node:assert/strict";

const wasm = await readFile(new URL("./wasi_parity.wasm", import.meta.url));
const module = await WebAssembly.compile(wasm);
const imports = WebAssembly.Module.imports(module);
assert.deepEqual(
  imports.map(({ module, name, kind }) => ({ module, name, kind })),
  [
    { module: "wasi_snapshot_preview1", name: "fd_write", kind: "function" },
    { module: "wasi_snapshot_preview1", name: "fd_read", kind: "function" },
  ],
);

let instance;
const state = {
  input: new Uint8Array(),
  inputOffset: 0,
  output: [],
  writeMax: Infinity,
  readMax: Infinity,
  writeMode: "ok",
  readMode: "ok",
  writeCalls: 0,
  readCalls: 0,
  writePointers: [],
};

function view() {
  return new DataView(instance.exports.memory.buffer);
}

function bytes() {
  return new Uint8Array(instance.exports.memory.buffer);
}

function fdWrite(fd, iovs, iovsLength, written) {
  state.writeCalls++;
  if (state.writeMode === "errno" || (state.writeMode === "errno_after" && state.writeCalls > 1)) return 5;
  const memory = view();
  assert.equal(iovsLength, 1);
  const pointer = memory.getUint32(iovs, true);
  const length = memory.getUint32(iovs + 4, true);
  assert.ok(length <= 65520);
  assert.ok(pointer >= 16 && pointer + length <= 65536);
  state.writePointers.push(pointer);
  if (state.writeMode === "zero") {
    memory.setUint32(written, 0, true);
    return 0;
  }
  if (state.writeMode === "over") {
    memory.setUint32(written, length + 1, true);
    return 0;
  }
  const count = Math.min(length, state.writeMax);
  state.output.push(Uint8Array.from(bytes().subarray(pointer, pointer + count)));
  memory.setUint32(written, count, true);
  return 0;
}

function fdRead(fd, iovs, iovsLength, read) {
  state.readCalls++;
  if (state.readMode === "errno" || (state.readMode === "errno_after" && state.readCalls > 1)) return 5;
  const memory = view();
  assert.equal(iovsLength, 1);
  const pointer = memory.getUint32(iovs, true);
  const length = memory.getUint32(iovs + 4, true);
  assert.equal(pointer, 16);
  assert.ok(length <= 65520);
  assert.ok(pointer + length <= 65536);
  if (state.readMode === "over") {
    memory.setUint32(read, length + 1, true);
    return 0;
  }
  const remaining = state.input.length - state.inputOffset;
  const count = Math.min(length, state.readMax, remaining);
  bytes().set(state.input.subarray(state.inputOffset, state.inputOffset + count), pointer);
  state.inputOffset += count;
  memory.setUint32(read, count, true);
  return 0;
}

instance = await WebAssembly.instantiate(module, {
  wasi_snapshot_preview1: {
    fd_write: fdWrite,
    fd_read: fdRead,
  },
});
assert.ok(instance.exports.memory instanceof WebAssembly.Memory);

function payload(length, salt) {
  return Uint8Array.from({ length }, (_, index) => (index * 131 + salt * 17 + 7) & 0xff);
}

function outputBytes() {
  const length = state.output.reduce((sum, chunk) => sum + chunk.length, 0);
  const result = new Uint8Array(length);
  let offset = 0;
  for (const chunk of state.output) {
    result.set(chunk, offset);
    offset += chunk.length;
  }
  return result;
}

function reset({ input = new Uint8Array(), writeMax = Infinity, readMax = Infinity } = {}) {
  state.input = input;
  state.inputOffset = 0;
  state.output = [];
  state.writeMax = writeMax;
  state.readMax = readMax;
  state.writeMode = "ok";
  state.readMode = "ok";
  state.writeCalls = 0;
  state.readCalls = 0;
  state.writePointers = [];
}

function assertBytes(actual, expected, label) {
  assert.deepEqual(Array.from(actual), Array.from(expected), label);
}

const boundaryLengths = [
  0, 1, 15, 16, 17, 4095, 4096, 4097, 8192, 8193, 10000,
  65519, 65520, 65521, 100000,
];
let checks = 0;
for (const length of boundaryLengths) {
  const expected = payload(length, length + 1);
  reset({ writeMax: [1, 15, 16, 17, 1023, 4096][length % 6] });
  const written = instance.exports[`write_boundary_${length}`](31);
  assert.equal(written, length);
  assertBytes(outputBytes(), expected, `write boundary ${length}`);
  if (length > 65520) assert.ok(state.writeCalls > 1);
  if (length === 10000) assert.ok(state.writePointers[1] > state.writePointers[0]);
  checks += 3;

  const input = payload(length, length + 101);
  reset({ input, writeMax: 997 });
  const copied = instance.exports[`copy_boundary_${length}`](32, 33);
  assert.equal(copied, length);
  assertBytes(outputBytes(), input, `read boundary ${length}`);
  assert.equal(state.inputOffset, length);
  if (length > 65520) assert.ok(state.readCalls > 1);
  checks += 4;
}

for (let alignment = 0; alignment < 16; alignment++) {
  const expected = payload(5003, 1000 + alignment);
  reset({ writeMax: [1, 7, 15, 16, 17, 255, 1024, 4096][alignment % 8] });
  const written = instance.exports[`write_alignment_${alignment}`](40);
  assert.equal(written, expected.length);
  assertBytes(outputBytes(), expected, `write alignment ${alignment}`);
  assert.ok(state.writeCalls > 1);
  checks += 3;
}

const dynamicCases = [
  { inputLength: 0, limit: 0, readMax: Infinity, expectedLength: 0 },
  { inputLength: 0, limit: 0xffffffff, readMax: Infinity, expectedLength: 0 },
  { inputLength: 10, limit: 100, readMax: Infinity, expectedLength: 10 },
  { inputLength: 10, limit: 0xffffffff, readMax: Infinity, expectedLength: 10 },
  { inputLength: 100, limit: 100, readMax: 17, expectedLength: 17 },
  { inputLength: 4096, limit: 8192, readMax: Infinity, expectedLength: 4096 },
  { inputLength: 10000, limit: 6000, readMax: Infinity, expectedLength: 6000 },
  { inputLength: 8192, limit: 8192, readMax: Infinity, expectedLength: 8192 },
  { inputLength: 12000, limit: 10000, readMax: Infinity, expectedLength: 10000 },
  { inputLength: 70000, limit: 70000, readMax: Infinity, expectedLength: 70000 },
  { inputLength: 140000, limit: 131040, readMax: Infinity, expectedLength: 131040 },
];
for (let index = 0; index < dynamicCases.length; index++) {
  const test = dynamicCases[index];
  const input = payload(test.inputLength, 2000 + index);
  reset({ input, readMax: test.readMax, writeMax: 613 });
  const copied = instance.exports.copy_dynamic(50, 51, test.limit);
  const expected = input.subarray(0, test.expectedLength);
  assert.equal(copied, expected.length);
  assertBytes(outputBytes(), expected, `dynamic copy ${index}`);
  assert.equal(state.inputOffset, expected.length);
  checks += 3;
}

// A prior full scratch fill must not leak into a later one-byte read.
reset({ input: payload(4096, 3000) });
assert.equal(instance.exports.copy_dynamic(60, 61, 4096), 4096);
reset({ input: Uint8Array.of(0xab) });
assert.equal(instance.exports.copy_dynamic(60, 61, 64), 1);
assertBytes(outputBytes(), Uint8Array.of(0xab), "scratch tail isolation");
checks += 3;

function expectTrap(label, action) {
  assert.throws(action, WebAssembly.RuntimeError, label);
  checks++;
}

reset();
state.writeMode = "errno";
expectTrap("fd_write errno", () => instance.exports.write_probe(70));
reset();
state.writeMode = "zero";
expectTrap("fd_write zero progress", () => instance.exports.write_probe(70));
reset();
state.writeMode = "over";
expectTrap("fd_write over-report", () => instance.exports.write_probe(70));
reset({ input: payload(16, 4000) });
state.readMode = "errno";
expectTrap("fd_read errno", () => instance.exports.read_probe(71));
reset({ input: payload(16, 4001) });
state.readMode = "over";
expectTrap("fd_read over-report", () => instance.exports.read_probe(71));
reset({ writeMax: 4096 });
state.writeMode = "errno_after";
expectTrap("fd_write errno after partial progress", () => instance.exports.write_boundary_4097(72));
reset({ input: payload(70000, 4002) });
state.readMode = "errno_after";
expectTrap("fd_read errno after one full window", () => instance.exports.copy_dynamic(73, 74, 70000));

console.log(`WASI parity passed: ${checks} checks`);
