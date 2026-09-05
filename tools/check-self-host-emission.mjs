import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";
import { execFileSync } from "node:child_process";
import { checkScalarConversions } from "./scalar-conversion-cases.mjs";
import { checkMemoryOperations } from "./memory-operation-cases.mjs";
import { checkArithmeticOperations } from "./arithmetic-operation-cases.mjs";

// Imports in these pure probes must never execute. Do not hide a host call.
function unusedImports(module) {
  const imports = Object.create(null);
  for (const entry of WebAssembly.Module.imports(module)) {
    assert.equal(entry.kind, "function", `unsupported probe import ${entry.module}.${entry.name}`);
    imports[entry.module] ??= Object.create(null);
    imports[entry.module][entry.name] = () => {
      throw new Error(`unexpected probe host call ${entry.module}.${entry.name}`);
    };
  }
  return imports;
}

function checkFunctionNames(bytes) {
  let offset = 8;
  const number = () => {
    let value = 0;
    for (let shift = 0; shift < 35; shift += 7) {
      assert.ok(offset < bytes.length, "truncated Wasm integer");
      const byte = bytes[offset++];
      value += (byte & 127) * 2 ** shift;
      if (!(byte & 128)) return value;
    }
    throw new Error("invalid Wasm integer");
  };
  const string = () => {
    const length = number();
    const start = offset;
    offset += length;
    assert.ok(offset <= bytes.length, "truncated Wasm name");
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes.subarray(start, offset));
  };
  let main;
  const names = new Map();
  while (offset < bytes.length) {
    const kind = bytes[offset++];
    const length = number();
    const end = offset + length;
    assert.ok(end <= bytes.length, "truncated Wasm section");
    if (kind === 7) {
      const count = number();
      for (let index = 0; index < count; index++) {
        const name = string();
        const exportKind = bytes[offset++];
        const target = number();
        if (name === "main" && exportKind === 0) main = target;
      }
    } else if (kind === 0 && string() === "name") {
      while (offset < end) {
        const subsection = bytes[offset++];
        const sublength = number();
        const subend = offset + sublength;
        assert.ok(subend <= end, "truncated name subsection");
        if (subsection === 1) {
          const count = number();
          for (let index = 0; index < count; index++) {
            const target = number();
            assert.ok(!names.has(target), `duplicate function name index ${target}`);
            names.set(target, string());
          }
        }
        offset = subend;
      }
    }
    offset = end;
  }
  assert.match(names.get(main) ?? "", /^main#[0-9]+#[0-9]+$/, "debug name must identify the emitted main function");
}

const module = await WebAssembly.compile(await readFile(process.argv[2]));
let compiler;
const compilerImports = unusedImports(module);
if (compilerImports.wasi_snapshot_preview1?.fd_write) {
  compilerImports.wasi_snapshot_preview1.fd_write = (fd, vectors, count, written) => {
    assert.ok(fd === 1 || fd === 2, `unexpected diagnostic descriptor ${fd}`);
    const memory = compiler.exports.memory;
    const view = new DataView(memory.buffer);
    let total = 0;
    for (let index = 0; index < count; index++) {
      const pointer = view.getUint32(vectors + index * 8, true);
      const length = view.getUint32(vectors + index * 8 + 4, true);
      process.stderr.write(Buffer.from(memory.buffer, pointer, length));
      total += length;
    }
    view.setUint32(written, total, true);
    return 0;
  };
}
compiler = await WebAssembly.instantiate(module, compilerImports);
compiler.exports.__dew_init?.();
async function compileSourceExports(fixture) {
  const builder = compiler.exports.self_host_emission_probe_source_new();
  for (const byte of new TextEncoder().encode(fixture)) {
    compiler.exports.self_host_emission_probe_source_append(builder, byte);
  }
  const output = compiler.exports.self_host_emission_probe_compile_source(builder);
  const bytes = new Uint8Array(compiler.exports.self_host_emission_probe_bytes_length(output));
  for (let index = 0; index < bytes.length; index++) {
    bytes[index] = compiler.exports.self_host_emission_probe_byte_at(output, index);
  }
  const module = await WebAssembly.compile(bytes);
  const instance = await WebAssembly.instantiate(module, unusedImports(module));
  instance.exports.__dew_init?.();
  assert.equal(typeof instance.exports.main, "function", "source probe main export is missing");
  return instance.exports;
}

async function compileSource(fixture) {
  return (await compileSourceExports(fixture)).main;
}

let failures = 0;
for (const [name, expected] of [
  ["self_host_emit_raw_bitcast_probe", -1],
  ["self_host_emit_raw_opcode_probe", 42],
  ["self_host_emit_raw_function_value_probe", 42],
  ["self_host_emit_packed_into_probe", 42n],
  ["self_host_emit_raw_array_order_probe", 11],
  ["self_host_emit_nested_raw_array_probe", 307],
  ["self_host_emit_raw_array_name_collision_probe", 15],
  ["self_host_emit_pattern_guard_probe", 461],
  ["self_host_emit_literal_guard_probe", 205],
  ["self_host_emit_solver_control_probe", 1],
  ["self_host_emit_bound_dispatch_probe", 10],
  ["self_host_emit_fixed_array_field_probe", 7],
  ["self_host_emit_scalar_iterator_probe", 6],
  ["self_host_emit_erased_field_probe", 42n],
  ["self_host_emit_string_map_probe", 26],
  ["self_host_emit_string_equality_probe", 1],
  ["self_host_emit_nested_variant_probe", 12],
  ["self_host_emit_short_constructor_probe", 42],
  ["self_host_emit_nested_binding_probe", 42n],
  ["self_host_emit_nested_literal_probe", 235],
  ["self_host_emit_type_stack_probe", -507],
]) {
  const start = performance.now();
  try {
  const result = compiler.exports[name]();
  const length = compiler.exports.self_host_emission_probe_bytes_length(result);
  assert.ok(length >= 8, `${name}: missing Wasm output`);
  const bytes = new Uint8Array(length);
  for (let index = 0; index < length; index++) {
    bytes[index] = compiler.exports.self_host_emission_probe_byte_at(result, index);
  }
  checkFunctionNames(bytes);
  if (name === "self_host_emit_raw_opcode_probe") {
    const wat = execFileSync("wasm-tools", ["print", "-"], { input: bytes, encoding: "utf8" });
    assert.match(wat, /\bi32\.and\b/, "packed forwarding must emit the raw opcode");
    assert.doesNotMatch(wat, /^\s+(?:return_)?call(?:_ref|_indirect)?\s/m, "packed forwarding must not add function calls");
  }
  const emitted = await WebAssembly.compile(bytes);
  const instance = await WebAssembly.instantiate(emitted, unusedImports(emitted));
  instance.exports.__dew_init?.();
  assert.equal(instance.exports.main(), expected, `${name}: wrong emitted result`);
  const elapsed = (performance.now() - start) / 1000;
  console.log(`self-host emission probe passed: ${name} (${elapsed.toFixed(3)} seconds)`);
  if (elapsed > 30) throw new Error(`${name}: compiler performance exceeds 30 seconds`);
  } catch (error) {
    failures++;
    console.error(`self-host emission probe failed: ${name} (${((performance.now() - start) / 1000).toFixed(3)} seconds)`);
    console.error(error);
  }
}
// Compile the real library source, not a second copy of its conversion rules.
// Compilation failures and missing exports fail before any expected-trap check.
{
  const start = performance.now();
  try {
    const source = "builtin unsafe_bitcast<a, b>(value: a) -> b = \"unsafe.bitcast\"\n" +
      "builtin unreachable() -> Never = \"dew_unreachable\"\n" +
      await readFile(new URL("../std/preamble/70-into-builtins.dew", import.meta.url), "utf8");
    let checks = 0;
    for (const width of [32, 64]) {
      for (const [target, min, max] of [["i8", -128, 127], ["i16", -32768, 32767], ["u8", 0, 255], ["u16", 0, 65535]]) {
        const name = `f${width}_into_${target}`;
        const type = target.toUpperCase();
        const fixture = source + `\npub fn main(value: F${width}) -> I32 {\n  unsafe_bitcast::<${type}, I32>(${name}(value))\n}\n`;
        const convert = await compileSource(fixture);
        for (const [input, expected] of [[min, min], [max, max], [42.75, 42], [-0.75, 0]]) {
          assert.equal(convert(input), expected, `${name}(${input})`);
          checks++;
        }
        for (const input of [min - 1, max + 1, NaN, Infinity, -Infinity]) {
          assert.throws(() => convert(input), WebAssembly.RuntimeError, `${name}(${input}) must trap`);
          checks++;
        }
      }
    }
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host narrow float conversions passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    if (elapsed > 30) throw new Error("narrow float conversion compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host narrow float conversion probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const source = "builtin unsafe_bitcast<a, b>(value: a) -> b = \"unsafe.bitcast\"\n" +
      "builtin unreachable() -> Never = \"dew_unreachable\"\npub trait Into<t> {\n  fn into(self) -> t\n}\n" +
      await readFile(new URL("../std/preamble/70-into-builtins.dew", import.meta.url), "utf8") +
      await readFile(new URL("../std/preamble/80-into-impls.dew", import.meta.url), "utf8");
    const checks = await checkScalarConversions(async (origin, target) => {
      return compileSource(source + `\npub fn main(value: ${origin}) -> ${target} {\n  value.into()\n}\n`);
    });
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host scalar Into conversion checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    if (elapsed > 30) throw new Error("scalar conversion compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host scalar Into conversion probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const source = "builtin unsafe_bitcast<a, b>(value: a) -> b = \"unsafe.bitcast\"\n" +
      await readFile(new URL("../std/preamble/60-memory.dew", import.meta.url), "utf8");
    const checks = await checkMemoryOperations(async type => {
      const name = type.toLowerCase();
      const exports = await compileSourceExports(source + `\npub fn main(address: U32, value: ${type}, write: Bool) -> ${type} {\n  if write {\n    ${name}_store(address, value)\n  }\n  ${name}_load(address)\n}\n`);
      return { operation: exports.main, memory: exports.memory };
    }, async () => {
      const exports = await compileSourceExports(source + "\npub fn main(source: U32, destination: U32) -> Unit {\n  v128_store(destination, v128_load(source))\n}\n");
      return { copy: exports.main, memory: exports.memory };
    });
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host memory operation checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    if (elapsed > 30) throw new Error("memory operation compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host memory operation probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    let source = "builtin unsafe_bitcast<a, b>(value: a) -> b = \"unsafe.bitcast\"\n";
    for (const file of ["00-builtins.dew", "40-numeric-builtins.dew", "70-into-builtins.dew"]) {
      source += await readFile(new URL(`../std/preamble/${file}`, import.meta.url), "utf8");
    }
    const checks = await checkArithmeticOperations(async (type, _op, name, result) => {
      return compileSource(source + `\npub fn main(left: ${type}, right: ${type}) -> ${result} {\n  ${name}(left, right)\n}\n`);
    });
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host arithmetic operation checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    if (elapsed > 30) throw new Error("arithmetic compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host arithmetic operation probe failed");
    console.error(error);
  }
}
if (failures) throw new Error(`${failures} self-host emission probe(s) failed`);
