#!/usr/bin/env node

import { readFile } from "node:fs/promises";
import { requireDewAbi } from "./dew-abi-metadata.mjs";

function usage() {
  console.error(
    "usage: dew-wasm-consumer.mjs PROVIDER_WASM CONSUMER_WASM EXPORT RESULT_TYPE [EXPECTED_PROVIDER_PATH EXPECTED_INTERFACE_FINGERPRINT]",
  );
}

function normalizeResult(type, value) {
  switch (type) {
    case "void":
      if (value !== undefined) throw new Error("expected void consumer result");
      return null;
    case "i32":
      if (typeof value !== "number" || !Number.isInteger(value)) {
        throw new Error("expected i32 consumer result");
      }
      return value | 0;
    case "i64":
      if (typeof value !== "bigint") throw new Error("expected i64 consumer result");
      return value.toString(10);
    case "f32":
    case "f64":
      if (typeof value !== "number" || !Number.isFinite(value)) {
        throw new Error(`expected finite ${type} consumer result`);
      }
      return value;
    default:
      throw new Error(`unsupported consumer result type: ${type}`);
  }
}

async function main() {
  if (process.argv.length !== 6 && process.argv.length !== 8) {
    usage();
    process.exitCode = 2;
    return;
  }
  const [
    ,
    ,
    providerPath,
    consumerPath,
    exportName,
    resultType,
    expectedPath,
    expectedInterfaceFingerprint,
  ] = process.argv;
  const [providerBytes, consumerBytes] = await Promise.all([
    readFile(providerPath),
    readFile(consumerPath),
  ]);
  const providerModule = await WebAssembly.compile(providerBytes);
  requireDewAbi(
    providerModule,
    expectedPath === undefined
      ? undefined
      : { path: expectedPath, interfaceFingerprint: expectedInterfaceFingerprint },
  );
  const provider = await WebAssembly.instantiate(providerModule, {});
  const initialize = provider.exports.__dew_init;
  if (initialize !== undefined) {
    if (typeof initialize !== "function") {
      throw new Error("provider __dew_init export is not a function");
    }
    initialize();
  }
  const consumer = await WebAssembly.instantiate(consumerBytes, {
    dew: provider.exports,
  });
  const entry = consumer.instance.exports[exportName];
  if (typeof entry !== "function") {
    throw new Error(`consumer export is not a function: ${exportName}`);
  }
  const value = normalizeResult(resultType, entry());
  process.stdout.write(
    `${JSON.stringify({ export: exportName, result: { type: resultType, value } })}\n`,
  );
}

main().catch((error) => {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
});
