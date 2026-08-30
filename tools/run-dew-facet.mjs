#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const [wasmArgument, requestArgument] = process.argv.slice(2);
if (!wasmArgument || !requestArgument) {
  console.error("usage: run-dew-facet.mjs COMPILER.wasm REQUEST");
  process.exit(2);
}

const wasmPath = path.resolve(wasmArgument);
const requestPath = path.resolve(requestArgument);
const workingDirectory = process.cwd();
const requestName = path.relative(workingDirectory, requestPath);
const guestArgs = [wasmPath, requestName];
const encoder = new TextEncoder();
const decoder = new TextDecoder("utf-8", { fatal: true });
const handles = new Map();
const traceFacet = process.env.DEW_FACET_TRACE === "1";
let nextHandle = 4;
let instance;

const ERR_OK = 0;
const ERR_NO_ENTRY = 2;
const ERR_IO = 3;
const ERR_BAD_HANDLE = 4;
const ERR_ACCESS = 7;
const ERR_EXISTS = 9;
const ERR_INVALID = 12;
const FILE_REGULAR = 1;
const FILE_DIRECTORY = 2;
const FILE_CHAR = 4;
const RIGHT_WRITE = 1n << 1n;
const OPEN_CREATE = 1 << 0;
const OPEN_EXCLUSIVE = 1 << 1;
const OPEN_TRUNCATE = 1 << 2;
const OPEN_DIRECTORY = 1 << 3;
const OPEN_APPEND = 1 << 5;

class FacetExit extends Error {
  constructor(status) {
    super(`Facet exit ${status}`);
    this.status = status >>> 0;
  }
}

function errno(error) {
  if (error?.code === "ENOENT") return ERR_NO_ENTRY;
  if (error?.code === "EACCES" || error?.code === "EPERM") return ERR_ACCESS;
  if (error?.code === "EEXIST") return ERR_EXISTS;
  if (error?.code === "EBADF") return ERR_BAD_HANDLE;
  if (error?.code === "EINVAL") return ERR_INVALID;
  return ERR_IO;
}

function memoryBytes(pointer, length) {
  const memory = instance?.exports?.memory;
  if (!(memory instanceof WebAssembly.Memory)) {
    throw new Error("compiler memory is not exported");
  }
  return new Uint8Array(memory.buffer, pointer >>> 0, length >>> 0);
}

function checkedPath(pointer, length) {
  const relative = decoder.decode(memoryBytes(pointer, length));
  const resolved = path.resolve(workingDirectory, relative);
  const prefix = workingDirectory.endsWith(path.sep)
    ? workingDirectory
    : `${workingDirectory}${path.sep}`;
  if (resolved !== workingDirectory && !resolved.startsWith(prefix)) {
    throw Object.assign(new Error("path escapes preopen"), { code: "EACCES" });
  }
  return resolved;
}

function timeParts(milliseconds) {
  return [
    BigInt(Math.floor(milliseconds / 1000)),
    Math.floor((milliseconds % 1000) * 1_000_000),
  ];
}

function statResult(stat, error = ERR_OK) {
  if (!stat) return [0, 0, 0n, 0n, 0, 0n, 0, 0n, 0, error];
  const type = stat.isDirectory()
    ? FILE_DIRECTORY
    : stat.isFile()
      ? FILE_REGULAR
      : FILE_CHAR;
  const [atimeS, atimeNS] = timeParts(stat.atimeMs);
  const [mtimeS, mtimeNS] = timeParts(stat.mtimeMs);
  const [ctimeS, ctimeNS] = timeParts(stat.ctimeMs);
  return [
    type,
    0,
    BigInt(stat.size),
    atimeS,
    atimeNS,
    mtimeS,
    mtimeNS,
    ctimeS,
    ctimeNS,
    error,
  ];
}

const facet = {
  handle_close(handle) {
    handle >>>= 0;
    if (handle <= 3) return ERR_OK;
    const entry = handles.get(handle);
    if (!entry) return ERR_BAD_HANDLE;
    try {
      fs.closeSync(entry.fd);
      handles.delete(handle);
      return ERR_OK;
    } catch (error) {
      return errno(error);
    }
  },

  proc_exit(status) {
    throw new FacetExit(status);
  },

  stdio_stderr() {
    return [2, ERR_OK];
  },

  args_count() {
    const result = [guestArgs.length, ERR_OK];
    if (traceFacet) console.error("facet args_count", result);
    return result;
  },

  args_len_i8(index, _wtf) {
    index >>>= 0;
    const result = index >= guestArgs.length
      ? [0n, ERR_INVALID]
      : [BigInt(encoder.encode(guestArgs[index]).length), ERR_OK];
    if (traceFacet) console.error("facet args_len_i8", index, result);
    return result;
  },

  args_read_mem32_i8(index, _wtf, _memory, pointer, capacity) {
    index >>>= 0;
    if (index >= guestArgs.length) {
      const result = [0n, ERR_INVALID];
      if (traceFacet) console.error("facet args_read_mem32_i8", index, result);
      return result;
    }
    const value = encoder.encode(guestArgs[index]);
    const count = Math.min(value.length, capacity >>> 0);
    memoryBytes(pointer, count).set(value.subarray(0, count));
    const result = [BigInt(count), ERR_OK];
    if (traceFacet) {
      console.error(
        "facet args_read_mem32_i8",
        index,
        pointer >>> 0,
        capacity >>> 0,
        result,
        decoder.decode(memoryBytes(pointer, count)),
      );
    }
    return result;
  },

  fs_preopen_get(index) {
    return index === 0 ? [3, ERR_OK] : [0, ERR_NO_ENTRY];
  },

  fd_stat(handle) {
    handle >>>= 0;
    try {
      if (handle === 2) {
        return statResult({
          isDirectory: () => false,
          isFile: () => false,
          size: 0,
          atimeMs: 0,
          mtimeMs: 0,
          ctimeMs: 0,
        });
      }
      if (handle === 3) return statResult(fs.statSync(workingDirectory));
      const entry = handles.get(handle);
      if (!entry) return statResult(null, ERR_BAD_HANDLE);
      return statResult(fs.fstatSync(entry.fd));
    } catch (error) {
      return statResult(null, errno(error));
    }
  },

  fd_read_mem32(handle, _memory, pointer, length) {
    const entry = handles.get(handle >>> 0);
    if (!entry) return [0n, ERR_BAD_HANDLE];
    try {
      const destination = memoryBytes(pointer, length);
      const read = fs.readSync(entry.fd, destination, 0, destination.length, null);
      return [BigInt(read), ERR_OK];
    } catch (error) {
      return [0n, errno(error)];
    }
  },

  fd_write_mem32(handle, _memory, pointer, length) {
    handle >>>= 0;
    const source = memoryBytes(pointer, length);
    try {
      if (handle === 2) {
        const written = fs.writeSync(process.stderr.fd, source, 0, source.length);
        return [BigInt(written), ERR_OK];
      }
      const entry = handles.get(handle);
      if (!entry) return [0n, ERR_BAD_HANDLE];
      const written = fs.writeSync(entry.fd, source, 0, source.length, null);
      return [BigInt(written), ERR_OK];
    } catch (error) {
      return [0n, errno(error)];
    }
  },

  fd_sync(handle) {
    const entry = handles.get(handle >>> 0);
    if (!entry) return handle === 2 ? ERR_OK : ERR_BAD_HANDLE;
    try {
      fs.fsyncSync(entry.fd);
      return ERR_OK;
    } catch (error) {
      return errno(error);
    }
  },

  path_open_mem32_i8(directory, _memory, pointer, length, _wtf, flags, rights) {
    if ((directory >>> 0) !== 3) return [0, ERR_BAD_HANDLE];
    try {
      const target = checkedPath(pointer, length);
      flags >>>= 0;
      if ((flags & OPEN_DIRECTORY) !== 0) {
        const stat = fs.statSync(target);
        if (!stat.isDirectory()) return [0, ERR_INVALID];
      }
      const writable = (BigInt(rights) & RIGHT_WRITE) !== 0n;
      let nodeFlags = "r";
      if (writable) {
        if ((flags & OPEN_APPEND) !== 0) nodeFlags = "a+";
        else if ((flags & OPEN_EXCLUSIVE) !== 0) nodeFlags = "wx+";
        else if ((flags & (OPEN_CREATE | OPEN_TRUNCATE)) !== 0) nodeFlags = "w+";
        else nodeFlags = "r+";
      }
      const fd = fs.openSync(target, nodeFlags);
      const handle = nextHandle++;
      handles.set(handle, { fd });
      return [handle, ERR_OK];
    } catch (error) {
      return [0, errno(error)];
    }
  },
};

try {
  const module = await WebAssembly.compile(fs.readFileSync(wasmPath));
  instance = await WebAssembly.instantiate(module, {
    facet,
    __moonbit_time_unstable: {
      now() {
        return BigInt(Date.now());
      },
    },
  });
  if (!(instance.exports.memory instanceof WebAssembly.Memory)) {
    throw new Error("compiler must export memory for the Node Facet runner");
  }
  process.exitCode = Number(instance.exports.main());
} catch (error) {
  if (error instanceof FacetExit) {
    process.exitCode = error.status;
  } else {
    console.error(error instanceof Error && error.stack ? error.stack : String(error));
    process.exitCode = 1;
  }
} finally {
  for (const entry of handles.values()) {
    try {
      fs.closeSync(entry.fd);
    } catch {}
  }
}
