#!/usr/bin/env node
import { readFile } from "node:fs/promises";
import { decodeDewAbi } from "./dew-abi-metadata.mjs";

function usage(message) {
  if (message) console.error(`dew abi: ${message}`);
  console.error("usage:");
  console.error("  dew-abi.mjs BINARY interface");
  console.error("  dew-abi.mjs BINARY list");
  console.error("  dew-abi.mjs BINARY call SOURCE CARRIERS PARAM_TYPES RESULT_TYPE ARGS_JSON");
  process.exit(2);
}

const [binaryPath, command, ...arguments_] = process.argv.slice(2);
if (!binaryPath || !command) usage();

const carrierPattern = /^(i32|i64|f32|f64|v128|eqref)$/;

function parseTypeList(value, label, allowEmpty = true) {
  if (value === "-" && allowEmpty) return [];
  const values = value.split(",");
  if (values.some((entry) => !carrierPattern.test(entry))) {
    usage(`${label} must contain comma-separated i32, i64, f32, f64, v128, or eqref carriers`);
  }
  return values;
}

function adapterRecords(module) {
  const records = [];
  for (const descriptor of WebAssembly.Module.exports(module)) {
    if (descriptor.kind !== "function") continue;
    const marker = descriptor.name.lastIndexOf("$dew$");
    if (marker <= 0) continue;
    const source = descriptor.name.slice(0, marker);
    const carriers = descriptor.name.slice(marker + 5).split("_");
    if (carriers.length === 0 || carriers.some((carrier) => !carrierPattern.test(carrier))) continue;
    records.push({ source, carriers, export: descriptor.name });
  }
  records.sort((left, right) => left.export.localeCompare(right.export));
  return records;
}

function convertArgument(type, value, index) {
  switch (type) {
    case "i32":
      if (!Number.isInteger(value) || value < -0x80000000 || value > 0xffffffff) {
        usage(`argument ${index} is not an i32-compatible integer`);
      }
      return value | 0;
    case "i64":
      if ((typeof value !== "string" && typeof value !== "number") ||
          (typeof value === "number" && !Number.isSafeInteger(value))) {
        usage(`argument ${index} must be a decimal string or safe integer for i64`);
      }
      try {
        return BigInt(value);
      } catch {
        usage(`argument ${index} is not a valid i64`);
      }
      break;
    case "f32":
      if (typeof value !== "number" || !Number.isFinite(value)) usage(`argument ${index} is not a finite f32`);
      return Math.fround(value);
    case "f64":
      if (typeof value !== "number" || !Number.isFinite(value)) usage(`argument ${index} is not a finite f64`);
      return value;
    case "v128":
      usage("the JavaScript WebAssembly API cannot invoke v128 adapter parameters");
      break;
    case "eqref":
      usage("eqref adapter parameters require a Wasm package consumer, not the JavaScript CLI");
      break;
  }
}

function normalizeResult(type, value) {
  switch (type) {
    case "-":
      return null;
    case "i64":
      return { type, value: value.toString() };
    case "i32":
    case "f32":
    case "f64":
      return { type, value };
    case "v128":
      usage("the JavaScript WebAssembly API cannot return v128 adapter results");
      break;
    case "eqref":
      usage("eqref adapter results require a Wasm package consumer, not the JavaScript CLI");
      break;
    default:
      usage("result type must be -, i32, i64, f32, f64, v128, or eqref");
  }
}

const binary = await readFile(binaryPath);
const module = await WebAssembly.compile(binary);
let abi;
try {
  abi = decodeDewAbi(module);
} catch (error) {
  usage(error instanceof Error ? error.message : String(error));
}
const records = adapterRecords(module);

if (command === "interface") {
  if (arguments_.length !== 0) usage("interface accepts no additional arguments");
  process.stdout.write(`${JSON.stringify(abi)}\n`);
  process.exit(0);
}

if (command === "list") {
  if (arguments_.length !== 0) usage("list accepts no additional arguments");
  process.stdout.write(`${JSON.stringify(records)}\n`);
  process.exit(0);
}

if (command !== "call") usage(`unknown command ${command}`);
if (arguments_.length !== 5) usage("call requires SOURCE CARRIERS PARAM_TYPES RESULT_TYPE ARGS_JSON");
const [source, carrierText, parameterText, resultType, argumentJson] = arguments_;
const carriers = parseTypeList(carrierText, "carrier vector", false);
const parameterTypes = parseTypeList(parameterText, "parameter types");
let values;
try {
  values = JSON.parse(argumentJson);
} catch (error) {
  usage(`ARGS_JSON is invalid: ${String(error)}`);
}
if (!Array.isArray(values) || values.length !== parameterTypes.length) {
  usage(`ARGS_JSON must be an array with ${parameterTypes.length} values`);
}
const exportName = `${source}$dew$${carriers.join("_")}`;
if (!records.some((record) => record.export === exportName)) {
  usage(`module does not export ${exportName}`);
}

let instance;
const imports = {
  wasi_snapshot_preview1: {
    fd_write(_fd, _iovs, _count, written) {
      if (instance?.exports?.memory) new DataView(instance.exports.memory.buffer).setUint32(written, 0, true);
      return 0;
    },
    fd_read(_fd, _iovs, _count, read) {
      if (instance?.exports?.memory) new DataView(instance.exports.memory.buffer).setUint32(read, 0, true);
      return 0;
    },
  },
};
instance = await WebAssembly.instantiate(module, imports);
if (typeof instance.exports.__dew_init === "function") instance.exports.__dew_init();
const adapter = instance.exports[exportName];
if (typeof adapter !== "function") usage(`${exportName} is not callable`);
const converted = values.map((value, index) => convertArgument(parameterTypes[index], value, index));
const result = adapter(...converted);
process.stdout.write(`${JSON.stringify({ export: exportName, result: normalizeResult(resultType, result) })}\n`);
