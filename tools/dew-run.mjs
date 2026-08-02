#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { readFileSync, writeSync } from "node:fs";

const [binaryPath] = process.argv.slice(2);
if (!binaryPath) {
  console.error("usage: dew-run.mjs BINARY");
  process.exit(2);
}

const stdin = new Uint8Array(readFileSync(0));
let stdinOffset = 0;
let instance;

function iovecCapacity(memory, iovs, count) {
  let total = 0;
  for (let index = 0; index < count; index++) {
    total += memory.getUint32(iovs + index * 8 + 4, true);
  }
  return total;
}

const imports = {
  wasi_snapshot_preview1: {
    fd_write(fd, iovs, count, written) {
      const memory = new DataView(instance.exports.memory.buffer);
      let total = 0;
      for (let index = 0; index < count; index++) {
        const iovec = iovs + index * 8;
        const pointer = memory.getUint32(iovec, true);
        const length = memory.getUint32(iovec + 4, true);
        if (length > 0) {
          writeSync(fd === 2 ? 2 : 1, new Uint8Array(instance.exports.memory.buffer, pointer, length));
          total += length;
        }
      }
      memory.setUint32(written, total, true);
      return 0;
    },
    fd_read(_fd, iovs, count, read) {
      const memory = new DataView(instance.exports.memory.buffer);
      const available = stdin.length - stdinOffset;
      let remaining = Math.min(iovecCapacity(memory, iovs, count), available);
      const total = remaining;
      for (let index = 0; index < count && remaining > 0; index++) {
        const iovec = iovs + index * 8;
        const pointer = memory.getUint32(iovec, true);
        const length = Math.min(memory.getUint32(iovec + 4, true), remaining);
        new Uint8Array(instance.exports.memory.buffer, pointer, length).set(
          stdin.subarray(stdinOffset, stdinOffset + length),
        );
        stdinOffset += length;
        remaining -= length;
      }
      memory.setUint32(read, total, true);
      return 0;
    },
  },
};

try {
  const binary = await readFile(binaryPath);
  const module = await WebAssembly.compile(binary);
  instance = await WebAssembly.instantiate(module, imports);
  if (typeof instance.exports.__dew_init === "function") {
    instance.exports.__dew_init();
  }
  if (typeof instance.exports.main !== "function") {
    throw new Error("module does not export main");
  }
  instance.exports.main();
} catch (error) {
  console.error(`dew run: ${String(error)}`);
  process.exit(1);
}
