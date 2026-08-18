#!/usr/bin/env node

import { WASI } from "node:wasi";
import { dirname, basename, resolve } from "node:path";
import { readFile } from "node:fs/promises";

const [wasmArgument, requestArgument] = process.argv.slice(2);
if (!wasmArgument || !requestArgument) {
  console.error("usage: run-dew-wasi.mjs COMPILER.wasm REQUEST");
  process.exit(2);
}

const wasmPath = resolve(wasmArgument);
const requestPath = resolve(requestArgument);
const workingDirectory = dirname(requestPath);
const requestName = basename(requestPath);
const wasi = new WASI({
  version: "preview1",
  args: [wasmPath, requestName],
  env: {},
  preopens: { ".": workingDirectory },
  returnOnExit: true,
});

try {
  const module = await WebAssembly.compile(await readFile(wasmPath));
  const instance = await WebAssembly.instantiate(module, {
    wasi_snapshot_preview1: wasi.wasiImport,
    __moonbit_time_unstable: {
      now() {
        return BigInt(Date.now());
      },
    },
  });
  wasi.initialize(instance);
  if (typeof instance.exports.__dew_init === "function") {
    instance.exports.__dew_init();
  }
  if (typeof instance.exports.main !== "function") {
    throw new Error("compiler does not export main");
  }
  const status = Number(instance.exports.main());
  process.exitCode = status;
} catch (error) {
  console.error(`dew WASI run failed: ${String(error)}`);
  process.exitCode = 1;
}
