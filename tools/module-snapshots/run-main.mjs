#!/usr/bin/env node
import { readFile } from "node:fs/promises";

const [binaryPath, hostJson = "{}", mode = "production"] = process.argv.slice(2);
if (!binaryPath) {
  console.error("usage: run-main.mjs BINARY [HOST_JSON] [production|test]");
  process.exit(2);
}

let host;
try {
  host = JSON.parse(hostJson);
} catch (error) {
  console.error(`invalid host JSON: ${String(error)}`);
  process.exit(2);
}
if (mode !== "production" && mode !== "test") {
  console.error("runtime mode must be production or test");
  process.exit(2);
}
if (host === null || Array.isArray(host) || typeof host !== "object") {
  console.error("host configuration must be an object");
  process.exit(2);
}

function decodeHex(value) {
  if (value === undefined) return new Uint8Array();
  if (typeof value !== "string" || value.length % 2 !== 0 || !/^[0-9a-fA-F]*$/.test(value)) {
    throw new TypeError("stdin_hex must contain an even number of hexadecimal digits");
  }
  return Uint8Array.from(Buffer.from(value, "hex"));
}

let stdinBytes;
try {
  stdinBytes = decodeHex(host.stdin_hex);
} catch (error) {
  console.error(String(error));
  process.exit(2);
}
let stdinOffset = 0;
const stdoutChunks = [];
let instance;

function configuredInteger(name, fallback) {
  const value = host[name];
  if (value === undefined) return fallback;
  if (!Number.isSafeInteger(value) || value < 0) {
    throw new TypeError(`${name} must be a nonnegative safe integer`);
  }
  return value;
}

function iovecCapacity(memory, iovs, iovsLength) {
  let total = 0;
  for (let index = 0; index < iovsLength; index++) {
    total += memory.getUint32(iovs + index * 8 + 4, true);
  }
  return total;
}

function captureIovecs(memory, iovs, iovsLength, count) {
  let remaining = count;
  for (let index = 0; index < iovsLength && remaining > 0; index++) {
    const iovec = iovs + index * 8;
    const pointer = memory.getUint32(iovec, true);
    const length = Math.min(memory.getUint32(iovec + 4, true), remaining);
    if (length > 0) {
      const bytes = new Uint8Array(instance.exports.memory.buffer, pointer, length);
      stdoutChunks.push(Uint8Array.from(bytes));
      remaining -= length;
    }
  }
}

function fillIovecs(memory, iovs, iovsLength, count) {
  let remaining = count;
  for (let index = 0; index < iovsLength && remaining > 0; index++) {
    const iovec = iovs + index * 8;
    const pointer = memory.getUint32(iovec, true);
    const length = Math.min(memory.getUint32(iovec + 4, true), remaining);
    if (length > 0) {
      const target = new Uint8Array(instance.exports.memory.buffer, pointer, length);
      target.set(stdinBytes.subarray(stdinOffset, stdinOffset + length));
      stdinOffset += length;
      remaining -= length;
    }
  }
}

const preview1ParameterCounts = Object.freeze({
  args_get: 2,
  args_sizes_get: 2,
  environ_get: 2,
  environ_sizes_get: 2,
  clock_res_get: 2,
  clock_time_get: 3,
  fd_advise: 4,
  fd_allocate: 3,
  fd_close: 1,
  fd_datasync: 1,
  fd_fdstat_get: 2,
  fd_fdstat_set_flags: 2,
  fd_fdstat_set_rights: 3,
  fd_filestat_get: 2,
  fd_filestat_set_size: 2,
  fd_filestat_set_times: 4,
  fd_pread: 5,
  fd_prestat_get: 2,
  fd_prestat_dir_name: 3,
  fd_pwrite: 5,
  fd_read: 4,
  fd_readdir: 5,
  fd_renumber: 2,
  fd_seek: 4,
  fd_sync: 1,
  fd_tell: 2,
  fd_write: 4,
  path_create_directory: 3,
  path_filestat_get: 5,
  path_filestat_set_times: 7,
  path_link: 7,
  path_open: 9,
  path_readlink: 6,
  path_remove_directory: 3,
  path_rename: 6,
  path_symlink: 5,
  path_unlink_file: 3,
  poll_oneoff: 4,
  proc_exit: 1,
  proc_raise: 1,
  sched_yield: 0,
  random_get: 2,
  sock_accept: 3,
  sock_recv: 6,
  sock_send: 5,
  sock_shutdown: 2,
});
const preview1Calls = new Set();

function markPreview1Call(name, count) {
  if (host.preview1_smoke !== true) return;
  const expected = preview1ParameterCounts[name];
  if (count !== expected) {
    throw new Error(`${name} received ${count} parameters, expected ${expected}`);
  }
  preview1Calls.add(name);
}

function requirePreview1SmokeComplete() {
  if (host.preview1_smoke !== true) return;
  const missing = Object.keys(preview1ParameterCounts).filter((name) => !preview1Calls.has(name));
  if (missing.length > 0) throw new Error(`WASI Preview 1 calls not observed: ${missing.join(", ")}`);
}

const wasiSnapshotPreview1 = {
    fd_write(fd, iovs, iovsLength, written) {
      markPreview1Call("fd_write", arguments.length);
      const memory = new DataView(instance.exports.memory.buffer);
      const errno = configuredInteger("write_errno", 0);
      if (errno !== 0) return errno;
      const requested = iovecCapacity(memory, iovs, iovsLength);
      let count;
      if (host.write_overreport === true) {
        count = requested + 1;
      } else if (host.write_zero === true) {
        count = 0;
      } else {
        count = Math.min(requested, configuredInteger("write_limit", requested));
      }
      if (fd === 1 && count <= requested) captureIovecs(memory, iovs, iovsLength, count);
      memory.setUint32(written, count, true);
      return 0;
    },
    fd_read(_fd, iovs, iovsLength, read) {
      markPreview1Call("fd_read", arguments.length);
      const memory = new DataView(instance.exports.memory.buffer);
      const errno = configuredInteger("read_errno", 0);
      if (errno !== 0) return errno;
      const requested = iovecCapacity(memory, iovs, iovsLength);
      let count;
      if (host.read_overreport === true) {
        count = requested + 1;
      } else {
        count = Math.min(
          requested,
          stdinBytes.length - stdinOffset,
          configuredInteger("read_limit", requested),
        );
        fillIovecs(memory, iovs, iovsLength, count);
      }
      memory.setUint32(read, count, true);
      return 0;
    },
};
for (const [name, parameterCount] of Object.entries(preview1ParameterCounts)) {
  if (name in wasiSnapshotPreview1) continue;
  wasiSnapshotPreview1[name] = (...parameters) => {
    markPreview1Call(name, parameters.length);
    return name === "proc_exit" ? undefined : 0;
  };
}
const imports = { wasi_snapshot_preview1: wasiSnapshotPreview1 };

function capturedStdout() {
  let length = 0;
  for (const chunk of stdoutChunks) length += chunk.length;
  if (length === 0) return [];
  const bytes = new Uint8Array(length);
  let offset = 0;
  for (const chunk of stdoutChunks) {
    bytes.set(chunk, offset);
    offset += chunk.length;
  }
  const text = new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  const lines = text.split("\n").map((line) => line.endsWith("\r") ? line.slice(0, -1) : line);
  if (lines.at(-1) === "") lines.pop();
  return lines;
}

function normalizedTrap(error) {
  if (!(error instanceof WebAssembly.RuntimeError)) return null;
  const message = error.message.toLowerCase();
  if (message.includes("unreachable")) return "unreachable";
  if (message.includes("memory access out of bounds") || message.includes("out of bounds memory")) {
    return "memory-out-of-bounds";
  }
  if (message.includes("array element access out of bounds") || message.includes("array out of bounds")) {
    return "array-out-of-bounds";
  }
  if (message.includes("divide by zero")) return "integer-divide-by-zero";
  if (message.includes("integer overflow")) return "integer-overflow";
  if (message.includes("invalid conversion to integer")) return "invalid-conversion-to-integer";
  return null;
}

const binary = await readFile(binaryPath);
const module = await WebAssembly.compile(binary);
instance = await WebAssembly.instantiate(module, imports);
if (typeof instance.exports.__dew_init === "function") {
  instance.exports.__dew_init();
}
const main = instance.exports.main;
if (typeof main !== "function") {
  console.error("fixture must export a main function");
  process.exit(2);
}

try {
  if (mode === "test") {
    for (const [name, test] of Object.entries(instance.exports)) {
      if (name.startsWith("__dew_test_") && typeof test === "function") test();
    }
  }
  main();
  requirePreview1SmokeComplete();
  process.stdout.write(JSON.stringify({ output: capturedStdout(), trap: null }));
} catch (error) {
  const trap = normalizedTrap(error);
  if (trap === null) {
    console.error(`fixture main failed with unsupported error: ${String(error)}`);
    process.exit(2);
  }
  process.stdout.write(JSON.stringify({ output: capturedStdout(), trap }));
}
