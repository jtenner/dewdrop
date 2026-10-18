import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import { closeSync, mkdtempSync, openSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";
import { after, test } from "node:test";

const directory = mkdtempSync(join(tmpdir(), "dew-run-test-"));
const runner = fileURLToPath(new URL("./dew-run.mjs", import.meta.url));
after(() => rmSync(directory, { recursive: true, force: true }));

function unsigned(value) {
  const bytes = [];
  do {
    const byte = value & 127;
    value >>>= 7;
    bytes.push(byte | (value ? 128 : 0));
  } while (value);
  return bytes;
}

function constant(value) {
  const bytes = [0x41];
  for (;;) {
    const byte = value & 127;
    value >>= 7;
    const done = (value === 0 && !(byte & 64)) || (value === -1 && (byte & 64));
    bytes.push(byte | (done ? 0 : 128));
    if (done) return bytes;
  }
}

const text = (value) => [...unsigned(value.length), ...Buffer.from(value)];
const section = (id, bytes) => [id, ...unsigned(bytes.length), ...bytes];
const call = (index, ...args) => [...args.flatMap(constant), 0x10, index];
const store = (address, value) => [...constant(address), ...constant(value), 0x36, 2, 0];
const read = (fd = 0, iovs = 0, count = 1, result = 16, errno = 20) => [
  ...constant(errno), ...call(0, fd, iovs, count, result), 0x36, 2, 0,
];
const write = (iovs = 32, count = 1) => [...call(1, 1, iovs, count, 24), 0x1a];

// Build tiny Core Wasm fixtures directly. Tests need Node only, not a Dew build.
function fixture(name, instructions, words = {}, data = []) {
  const initialLength = Math.max(512,
    ...Object.keys(words).map((address) => Number(address) + 4),
    ...data.map(([address, bytes]) => address + bytes.length));
  const initial = Buffer.alloc(initialLength);
  for (const [address, value] of Object.entries(words)) initial.writeUInt32LE(value, Number(address));
  for (const [address, bytes] of data) initial.set(bytes, address);
  const body = [0, ...instructions, 0x0b];
  const bytes = Buffer.from([
    0, 97, 115, 109, 1, 0, 0, 0,
    ...section(1, [2, 0x60, 4, 0x7f, 0x7f, 0x7f, 0x7f, 1, 0x7f, 0x60, 0, 0]),
    ...section(2, [2, ...text("wasi_snapshot_preview1"), ...text("fd_read"), 0, 0,
      ...text("wasi_snapshot_preview1"), ...text("fd_write"), 0, 0]),
    ...section(3, [1, 1]),
    ...section(5, [1, 0, 1]),
    ...section(7, [2, ...text("main"), 0, 2, ...text("memory"), 2, 0]),
    ...section(10, [1, ...unsigned(body.length), ...body]),
    ...section(11, [1, 0, ...constant(0), 0x0b, ...unsigned(initial.length), ...initial]),
  ]);
  assert.equal(WebAssembly.validate(bytes), true, `invalid fixture ${name}`);
  const path = join(directory, `${name}.wasm`);
  writeFileSync(path, bytes);
  return path;
}

function run(path, stdin = "pipe", execArgv = []) {
  const child = spawn(process.execPath, [...execArgv, runner, path], { stdio: [stdin, "pipe", "pipe"] });
  const chunks = [];
  let stderr = "";
  let output = Buffer.alloc(0);
  const waiters = [];
  child.stdout.on("data", (chunk) => {
    chunks.push(chunk);
    output = Buffer.concat(chunks);
    for (const wake of waiters.splice(0)) wake();
  });
  child.stderr.on("data", (chunk) => { stderr += chunk; });
  const finished = new Promise((resolve, reject) => {
    child.on("error", reject);
    child.on("close", (code, signal) => {
      if (code !== 0) reject(new Error(`runner exit ${code}, signal ${signal}: ${stderr}`));
      else resolve(output);
    });
  });
  // A timeout must leave a clear failure and must not leave a child behind.
  const timeout = setTimeout(() => child.kill("SIGKILL"), 5000);
  finished.finally(() => clearTimeout(timeout)).catch(() => {});
  return {
    child, finished,
    async bytes(count) {
      while (output.length < count) await Promise.race([
        new Promise((resolve) => waiters.push(resolve)),
        finished.then(() => { throw new Error(`expected ${count} output bytes, got ${output.length}`); }),
      ]);
      return output;
    },
  };
}

test("main returns with stdin still open", async () => {
  const process = run(fixture("empty", []));
  assert.deepEqual(await process.finished, Buffer.alloc(0));
});

test("output precedes input, short reads return without EOF, and bytes stay exact", async () => {
  const path = fixture("incremental", [
    ...write(), ...read(), ...write(40), ...read(), ...write(40),
  ], { 0: 128, 4: 8, 32: 100, 36: 1, 40: 16, 44: 120 }, [[100, [82]]]);
  const process = run(path);
  assert.equal((await process.bytes(1))[0], 82);
  process.child.stdin.write(Buffer.from([0, 255, 128]));
  const first = await process.bytes(121);
  assert.equal(first.readUInt32LE(1), 3);
  assert.equal(first.readUInt32LE(5), 0);
  assert.deepEqual(first.subarray(113, 116), Buffer.from([0, 255, 128]));
  process.child.stdin.write(Buffer.from([10, 13]));
  const output = await process.finished;
  assert.equal(output.readUInt32LE(121), 2);
  assert.equal(output.readUInt32LE(125), 0);
  assert.deepEqual(output.subarray(233, 235), Buffer.from([10, 13]));
});

test("multiple and empty iovecs, repeated reads, and EOF report exact counts", async () => {
  const windowsPrefix = process.platform === "win32";
  const instructions = [...read(0, 0, 3, 64, 68), ...write(48), ...write(40)];
  if (windowsPrefix) instructions.push(...store(0, 131), ...store(4, 4));
  instructions.push(...read(0, 0, 3, 64, 68), ...write(48));
  if (windowsPrefix) instructions.push(...write(56), ...read(0, 0, 3, 64, 68), ...write(48));
  const corrected = fixture("iovecs-correct", instructions,
    { 0: 128, 4: 3, 8: 131, 12: 0, 16: 131, 20: 4,
      40: 128, 44: 7, 48: 64, 52: 4, 56: 131, 60: 4 });
  const input = join(directory, "input.bin");
  const bytes = Buffer.from([0, 255, 128, 10, 13, 1, 2]);
  writeFileSync(input, bytes);
  const descriptor = openSync(input, "r");
  try {
    const output = await run(corrected, descriptor).finished;
    assert.equal(output.readUInt32LE(0), windowsPrefix ? 3 : 7);
    if (windowsPrefix) {
      assert.deepEqual(output.subarray(4, 7), bytes.subarray(0, 3));
      assert.deepEqual(output.subarray(7, 11), Buffer.alloc(4));
      assert.equal(output.readUInt32LE(11), 4);
      assert.deepEqual(output.subarray(15, 19), bytes.subarray(3));
      assert.equal(output.readUInt32LE(19), 0);
    } else {
      assert.deepEqual(output.subarray(4, 11), bytes);
      assert.equal(output.readUInt32LE(11), 0);
    }
  } finally { closeSync(descriptor); }
});

test("zero iovecs do not read stdin", async () => {
  const path = fixture("zero", [...read(0, 0, 0), ...write()], { 32: 16, 36: 8 });
  const output = await run(path).finished;
  assert.deepEqual(output, Buffer.alloc(8));
});

test("a short first iovec does not wait for the next iovec", async () => {
  const path = fixture("short-iovec", [...read(0, 0, 2), ...write()], {
    0: 128, 4: 8, 8: 144, 12: 8, 32: 16, 36: 8,
  });
  const process = run(path);
  process.child.stdin.write(Buffer.from([1, 2, 3]));
  const output = await process.finished;
  assert.equal(output.readUInt32LE(0), 3);
  assert.equal(output.readUInt32LE(4), 0);
});

test("a full first iovec does not wait for more input in the next iovec", async () => {
  const path = fixture("full-first-iovec", [...read(0, 0, 2), ...write(), ...write(40), ...write(48)], {
    0: 128, 4: 3, 8: 144, 12: 4, 32: 16, 36: 8,
    40: 128, 44: 3, 48: 144, 52: 4,
  });
  const process = run(path);
  process.child.stdin.write(Buffer.from([1, 2, 3]));
  const output = await process.finished;
  assert.equal(output.readUInt32LE(0), 3);
  assert.equal(output.readUInt32LE(4), 0);
  assert.deepEqual(output.subarray(8, 11), Buffer.from([1, 2, 3]));
  assert.deepEqual(output.subarray(11, 15), Buffer.alloc(4));
});

test("bounded vector reads leave the remaining bytes for the caller", async () => {
  const offered = process.platform === "win32" ? 1 : 64;
  const words = { 1040: 1024, 1044: 8, 1048: 2048, 1052: 65, 1056: 0, 1060: 1 };
  for (let index = 0; index < 65; index++) {
    words[index * 8] = 2048 + index;
    words[index * 8 + 4] = 1;
  }
  const instructions = [...read(0, 0, 65, 1024, 1028), ...write(1040), ...write(1048)];
  for (let index = offered; index < 65; index++) {
    instructions.push(...store(0, 2048 + index), ...read(0, 0, 1, 1024, 1028),
      ...write(1040), ...store(1056, 2048 + index), ...write(1056));
  }
  instructions.push(...read(0, 0, 1, 1024, 1028), ...write(1040));
  const path = fixture("bounded-vectors", instructions, words);
  const input = join(directory, "bounded-input.bin");
  const bytes = Buffer.from(Array.from({ length: 65 }, (_, index) => index + 1));
  writeFileSync(input, bytes);
  const descriptor = openSync(input, "r");
  try {
    const output = await run(path, descriptor).finished;
    assert.equal(output.readUInt32LE(0), offered);
    assert.equal(output.readUInt32LE(4), 0);
    assert.deepEqual(output.subarray(8, 8 + offered), bytes.subarray(0, offered));
    assert.deepEqual(output.subarray(8 + offered, 73), Buffer.alloc(65 - offered));
    let offset = 73;
    for (let index = offered; index < 65; index++, offset += 9) {
      assert.equal(output.readUInt32LE(offset), 1);
      assert.equal(output.readUInt32LE(offset + 4), 0);
      assert.equal(output[offset + 8], bytes[index]);
    }
    assert.equal(output.readUInt32LE(offset), 0);
    assert.equal(output.readUInt32LE(offset + 4), 0);
  } finally { closeSync(descriptor); }
});

test("guest ranges beyond the vector read limit are checked before input", async () => {
  const words = { 1040: 1028, 1044: 4 };
  for (let index = 0; index < 65; index++) {
    words[index * 8] = index === 64 ? 65535 : 2048 + index;
    words[index * 8 + 4] = index === 64 ? 2 : 1;
  }
  const path = fixture("invalid-vector-tail", [...read(0, 0, 65, 1024, 1028), ...write(1040)], words);
  assert.equal((await run(path).finished).readUInt32LE(0), 21);
});

function preload(name, source) {
  const path = join(directory, `${name}.cjs`);
  writeFileSync(path, source);
  return ["--require", path];
}

test("an interrupted vector read retries without losing bytes", async () => {
  const hook = preload("read-eintr", `
    const fs = require("node:fs");
    const readv = fs.readvSync;
    let interrupted = false;
    fs.readvSync = (...args) => {
      if (!interrupted) {
        interrupted = true;
        const error = new Error("interrupted test read");
        error.code = "EINTR";
        throw error;
      }
      return readv(...args);
    };
    require("node:module").syncBuiltinESMExports();
  `);
  const path = fixture("eintr", [...read(), ...write()], { 0: 128, 4: 8, 32: 16, 36: 8 });
  const process = run(path, "pipe", hook);
  process.child.stdin.write(Buffer.from([1, 2, 3]));
  const output = await process.finished;
  assert.equal(output.readUInt32LE(0), 3);
  assert.equal(output.readUInt32LE(4), 0);
});

test("the Windows prefix rule passes only one view to the host read", async () => {
  const hook = preload("windows-prefix", `
    Object.defineProperty(process, "platform", { value: "win32" });
    const fs = require("node:fs");
    const readv = fs.readvSync;
    fs.readvSync = (fd, buffers, position) => {
      require("node:assert/strict").equal(buffers.length, 1);
      return readv(fd, buffers, position);
    };
    require("node:module").syncBuiltinESMExports();
  `);
  const path = fixture("windows-prefix", [...read(0, 0, 2), ...write()], {
    0: 128, 4: 3, 8: 144, 12: 4, 32: 16, 36: 8,
  });
  const process = run(path, "pipe", hook);
  process.child.stdin.write(Buffer.from([1, 2, 3]));
  const output = await process.finished;
  assert.equal(output.readUInt32LE(0), 3);
  assert.equal(output.readUInt32LE(4), 0);
});

test("empty iovecs do not wait for input", async () => {
  const path = fixture("empty-iovecs", [...read(0, 0, 2), ...write()], {
    0: 65536, 4: 0, 8: 128, 12: 0, 32: 16, 36: 8,
  });
  assert.deepEqual(await run(path).finished, Buffer.alloc(8));
});

test("invalid descriptors return WASI BADF without waiting for input", async () => {
  const path = fixture("bad-fd", [...read(99), ...write()], { 0: 128, 4: 1, 32: 20, 36: 4 });
  const output = await run(path).finished;
  assert.equal(output.readUInt32LE(0), 8);
});

test("invalid guest ranges return WASI FAULT before input is consumed", async () => {
  for (const [name, operation, words] of [
    ["table", read(0, 65532, 1), {}],
    ["buffer", read(), { 0: 65535, 4: 2 }],
    ["result", read(0, 0, 1, 65535), { 0: 128, 4: 1 }],
    ["unsigned", read(0, -1, 1), {}],
  ]) {
    const path = fixture(name, [...operation, ...write()], { ...words, 32: 20, 36: 4 });
    assert.equal((await run(path).finished).readUInt32LE(0), 21, name);
  }
});

test("host read errors return a WASI errno", { skip: process.platform !== "linux" }, async () => {
  const path = fixture("host-error", [...read(), ...write()], { 0: 128, 4: 1, 32: 20, 36: 4 });
  const descriptor = openSync(directory, "r");
  try {
    assert.equal((await run(path, descriptor).finished).readUInt32LE(0), 31);
  } finally { closeSync(descriptor); }
});
