#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { readSync, writeSync } from "node:fs";

const [binaryPath] = process.argv.slice(2);
if (!binaryPath) {
  console.error("usage: dew-run.mjs BINARY");
  process.exit(2);
}

let instance;

const readErrno = { EACCES: 2, EAGAIN: 6, EBADF: 8, EFAULT: 21,
  EINTR: 27, EINVAL: 28, EIO: 29, EISDIR: 31, EOVERFLOW: 61, EPERM: 63 };

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
    fd_read(fd, iovs, count, read) {
      if (fd !== 0) return 8;
      iovs >>>= 0;
      count >>>= 0;
      read >>>= 0;
      const memory = new DataView(instance.exports.memory.buffer);
      if (read + 4 > memory.byteLength || iovs + count * 8 > memory.byteLength) return 21;
      // Validate all guest ranges before consuming any input.
      for (let index = 0; index < count; index++) {
        const iovec = iovs + index * 8;
        if (memory.getUint32(iovec, true) + memory.getUint32(iovec + 4, true) > memory.byteLength) return 21;
      }
      let total = 0;
      for (let index = 0; index < count; index++) {
        const iovec = iovs + index * 8;
        const pointer = memory.getUint32(iovec, true);
        const length = memory.getUint32(iovec + 4, true);
        if (length === 0) continue;
        let received;
        for (;;) {
          try {
            received = readSync(0, new Uint8Array(memory.buffer, pointer, length));
            break;
          } catch (error) {
            if (error.code === "EINTR") continue;
            memory.setUint32(read, total, true);
            return total > 0 ? 0 : (readErrno[error.code] ?? 29);
          }
        }
        total += received;
        if (received < length) break;
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
