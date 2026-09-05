import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";
import { execFileSync } from "node:child_process";
import { checkScalarConversions } from "./scalar-conversion-cases.mjs";
import { checkMemoryOperations } from "./memory-operation-cases.mjs";
import { checkSimdMemoryOperations } from "./simd-memory-operation-cases.mjs";
import { checkArithmeticOperations } from "./arithmetic-operation-cases.mjs";
import { checkMathOperations } from "./math-operation-cases.mjs";
import { checkSpecializationCallbacks } from "./specialization-callback-cases.mjs";
import { checkMemberCalls } from "./member-call-cases.mjs";
import { checkArrayOperations } from "./array-operation-cases.mjs";
import { specializationI64Values } from "./specialization-product-cases.mjs";
import { readSelfHostInvariantFailure, formatSelfHostInvariantFailure } from "./self-host-invariant-record.mjs";

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
  return compileProbeBytes(new TextEncoder().encode(fixture), "self_host_emission_probe_compile_source");
}

async function compileProbeBytes(input, entry) {
  const builder = compiler.exports.self_host_emission_probe_source_new();
  for (const byte of input) {
    compiler.exports.self_host_emission_probe_source_append(builder, byte);
  }
  let output;
  try {
    output = compiler.exports[entry](builder);
  } catch (error) {
    const failure = readSelfHostInvariantFailure(compiler.exports.memory);
    if (failure) throw new Error(formatSelfHostInvariantFailure(failure), { cause: error });
    throw error;
  }
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
{
  const start = performance.now();
  try {
    const math = await readFile(new URL("../std/math.dew", import.meta.url), "utf8");
    const floatStart = math.indexOf("pub builtin f32_to_bits(");
    assert.ok(floatStart >= 0, "math library float section is missing");
    const source = "builtin unreachable() -> Never = \"dew_unreachable\"\n" + math.slice(floatStart);
    assert.equal((source.match(/^pub builtin /gm) ?? []).length, 16, "math float instruction inventory differs");
    const checks = await checkMathOperations(
      (width, op) => compileSource(source + `\npub fn main(value: F${width}) -> F${width} {\n  f${width}_${op}(value)\n}\n`),
      (width, op) => {
        const parameters = op === "roundtrip" ? `value: U${width}` : `left: U${width}, right: U${width}`;
        const expression = op === "roundtrip" ? `f${width}_from_bits(value)` :
          `f${width}_${op}(f${width}_from_bits(left), f${width}_from_bits(right))`;
        return compileSource(source + `\npub fn main(${parameters}) -> U${width} {\n  f${width}_to_bits(${expression})\n}\n`);
      },
      width => compileSource(source + `\npub fn main(value: F${width}, lower: F${width}, upper: F${width}) -> F${width} {\n  f${width}_clamp(value, lower, upper)\n}\n`),
      async () => {
        const intrinsics = await readFile(new URL("../std/wasm/intrinsics.dew", import.meta.url), "utf8");
        const declaration = intrinsics.match(/^pub builtin wasm_u32_ctz\([^\n]+$/m);
        assert.ok(declaration, "raw count-trailing-zeros declaration is missing");
        return compileSource(declaration[0] + "\npub fn main(value: U32) -> U32 {\n  wasm_u32_ctz(value)\n}\n");
      },
    );
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host math operation checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    if (elapsed > 30) throw new Error("math compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host math operation probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const cases = JSON.parse(await readFile(new URL("./dew-test/simd-opcodes.json", import.meta.url), "utf8"));
    for (const [opcode, inputs, result] of cases) {
      const parameters = inputs.map((type, index) => `value${index}: ${type}`).join(", ");
      const arguments_ = inputs.map((_, index) => `value${index}`).join(", ");
      try {
        await compileSource(`builtin operation(${parameters}) -> ${result} = "${opcode}"\npub fn main(${parameters}) -> ${result} {\n  operation(${arguments_})\n}\n`);
      } catch (error) {
        throw new Error(`SIMD opcode ${opcode} failed self-host compilation or Wasm validation`, { cause: error });
      }
    }
    const memoryChecks = await checkSimdMemoryOperations(async (_, source) => {
      const exports = await compileSourceExports(source);
      return { operation: exports.main, memory: exports.memory };
    });
    console.log(`self-host SIMD memory operation checks passed: ${memoryChecks}`);
    const declarations = `
builtin splat8(value: I32) -> V128 = "i8x16.splat"
builtin splat16(value: I32) -> V128 = "i16x8.splat"
builtin splat32(value: I32) -> V128 = "i32x4.splat"
builtin splatf32(value: F32) -> V128 = "f32x4.splat"
builtin narrow_s(left: V128, right: V128) -> V128 = "i8x16.narrow_i16x8_s"
builtin narrow_u(left: V128, right: V128) -> V128 = "i8x16.narrow_i16x8_u"
builtin multiply(left: V128, right: V128) -> V128 = "i32x4.extmul_high_i16x8_s"
builtin swizzle(value: V128, indices: V128) -> V128 = "i8x16.swizzle"
builtin convert(value: V128) -> V128 = "i32x4.trunc_sat_f32x4_s"
builtin equal8(left: V128, right: V128) -> V128 = "i8x16.eq"
builtin equal32(left: V128, right: V128) -> V128 = "i32x4.eq"
builtin all(value: V128) -> I32 = "i8x16.all_true"
`;
    for (const [label, expression] of [
      ["signed narrow bound", "equal8(narrow_s(splat16(-200i32), splat16(-200i32)), splat8(-128i32))"],
      ["unsigned narrow negative bits", "equal8(narrow_u(splat16(65535i32), splat16(65535i32)), splat8(0i32))"],
      ["wide signed multiply", "equal32(multiply(splat16(-32768i32), splat16(-1i32)), splat32(32768i32))"],
      ["swizzle out of range", "equal8(swizzle(splat8(42i32), splat8(16i32)), splat8(0i32))"],
      ["float conversion upper bound", "equal32(convert(splatf32(2147483648.0f32)), splat32(2147483647i32))"],
      ["float conversion NaN", "equal32(convert(splatf32(0.0f32 / 0.0f32)), splat32(0i32))"],
    ]) {
      const main = await compileSource(declarations + `pub fn main() -> I32 {\n  all(${expression})\n}\n`);
      assert.equal(main(), 1, label);
    }
    const customShuffle = await compileSource(declarations + `
builtin shuffle(left: V128, right: V128) -> V128 = "i8x16.shuffle 31 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24"
builtin first(value: V128) -> I32 = "i8x16.extract_lane_s 0"
builtin third(value: V128) -> I32 = "i8x16.extract_lane_s 2"
builtin last(value: V128) -> I32 = "i8x16.extract_lane_s 15"
pub fn main() -> I32 {
  let value = shuffle(splat8(42i32), splat8(-7i32))
  if first(value) == -7i32 && third(value) == 42i32 && last(value) == -7i32 {
    1i32
  } else {
    0i32
  }
}
`);
    assert.equal(customShuffle(), 1, "custom shuffle indices and signed extraction");
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host SIMD opcode validation passed: ${cases.length}, cross-lane execution checks: 6, custom shuffle checks: 1 (${elapsed.toFixed(3)} seconds)`);
    assert.ok(elapsed <= 30, "SIMD opcode compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const memberSource = await readFile(new URL("./dew-test/member_calls.dew", import.meta.url), "utf8");
    console.log(`self-host member/index checks passed: ${checkMemberCalls(await compileSource(memberSource))}`);
    let checks = 0;
    for (const [name, declarations, body] of [
      ["scalar", "", "let callback = reader::<I64>()\n  callback(value)"],
      ["nominal", "struct Item {\n  value: I64\n}\n", "let callback = reader::<Item>()\n  callback(Item::{\n    value: value\n  }).value"],
      ["product", "", "let callback = reader::<(I32, I64)>()\n  let (_, result) = callback((7i32, value))\n  result"],
      ["lambda", "fn maker() -> fn(I64) -> I64 {\n  fn(value: I64) -> I64 {\n    value\n  }\n}\n", "let callback = maker()\n  callback(value)"],
      ["captured parameter", "fn maker(held: I64) -> fn() -> I64 {\n  fn() -> I64 {\n    held\n  }\n}\n", "let callback = maker(value)\n  callback()"],
      ["captured local", "", "let held = value\n  let callback = fn() -> I64 {\n    held\n  }\n  callback()"],
      ["shared capture", "", "let mut held = 0i64\n  let write = fn(next: I64) -> Unit {\n    held = next\n  }\n  let read = fn() -> I64 {\n    held\n  }\n  write(value)\n  read()"],
      ["forwarded capture", "fn maker(held: I64) -> fn() -> fn() -> I64 {\n  fn() -> fn() -> I64 {\n    fn() -> I64 {\n      held\n    }\n  }\n}\n", "let first = maker(value)\n  let second = first()\n  second()"],
      ["Unit parameters", "fn select(left: Unit, value: I64, right: Unit) -> I64 {\n  value\n}\n", "let callback = select\n  callback((), value, ())"],
      ["Unit lambda parameter", "", "let callback = fn(left: I32, effect: Unit, right: I64) -> I64 {\n    if left == 7i32 {\n      right\n    } else {\n      0i64\n    }\n  }\n  callback(7i32, (), value)"],
      ["Unit local and capture", "", "let effect = ()\n  let callback = fn() -> I64 {\n    effect\n    value\n  }\n  callback()"],
      ["Unit product field", "", "let (effect, selected) = ((), value)\n  effect\n  selected"],
      ["Unit product effects", "", "let mut order = 0i32\n  let first = fn() -> Unit {\n    order = order * 10i32 + 1i32\n  }\n  let last = fn() -> Unit {\n    order = order * 10i32 + 2i32\n  }\n  let (_, selected, _) = (first(), value, last())\n  if order == 12i32 {\n    selected\n  } else {\n    0i64\n  }"],
      ["generic captured scalar", "fn maker<t>(held: t) -> fn() -> t {\n  fn() -> t {\n    held\n  }\n}\n", "let callback = maker::<I64>(value)\n  callback()"],
      ["generic Unit callback", "", "let callback = reader::<Unit>()\n  callback(())\n  value"],
      ["two capture specializations", "fn maker<t>(held: t) -> fn() -> t {\n  fn() -> t {\n    held\n  }\n}\n", "let left = maker::<I32>(7i32)\n  let right = maker::<I64>(value)\n  if left() == 7i32 {\n    right()\n  } else {\n    0i64\n  }"],
      ["generic mutable capture", "fn maker<t>(seed: t) -> fn(t) -> t {\n  let mut held = seed\n  fn(next: t) -> t {\n    let previous = held\n    held = next\n    previous\n  }\n}\n", "let callback = maker::<I64>(value)\n  callback(0i64)"],
      ["generic Unit capture", "fn maker<t>(held: t) -> fn() -> t {\n  fn() -> t {\n    held\n  }\n}\n", "let callback = maker::<Unit>(())\n  callback()\n  value"],
      ["generic mutable Unit capture", "fn maker<t>(seed: t) -> fn(t) -> t {\n  let mut held = seed\n  fn(next: t) -> t {\n    held = next\n    held\n  }\n}\n", "let callback = maker::<Unit>(())\n  callback(())\n  value"],
      ["call inside generic lambda", "fn maker<t>() -> fn(t) -> t {\n  fn(value: t) -> t {\n    identity(value)\n  }\n}\n", "let callback = maker::<I64>()\n  callback(value)"],
      ["reference inside generic lambda", "fn maker<t>() -> fn() -> fn(t) -> t {\n  fn() -> fn(t) -> t {\n    identity\n  }\n}\n", "let outer = maker::<I64>()\n  let callback = outer()\n  callback(value)"],
      ["trait call inside generic lambda", "trait Read {\n  fn read(self) -> I64\n}\nstruct Item {\n  value: I64\n}\nimpl Read for Item {\n  fn read(self) -> I64 {\n    self.value\n  }\n}\nfn maker<t: Read>() -> fn(t) -> I64 {\n  fn(value: t) -> I64 {\n    value.read()\n  }\n}\n", "let callback = maker::<Item>()\n  callback(Item::{\n    value: value\n  })"],
      ["mutable tuple binding capture", "", "let mut (held, ignored) = (value, 0i32)\n  let callback = fn() -> I64 {\n    held = held\n    held\n  }\n  callback()"],
      ["discarded scalar match", "", "match value {\n    0i64 => 1i32\n    _ => 2i32\n  }\n  value"],
      ["discarded match effects", "", "let mut count = 0i32\n  let bump = fn() -> I32 {\n    count = count + 1i32\n    count\n  }\n  match value {\n    0i64 => bump()\n    _ => bump()\n  }\n  if count == 1i32 {\n    value\n  } else {\n    value + 1i64\n  }"],
      ["unused match binding", "", "let unused = match value {\n    0i64 => 1i32\n    _ => 2i32\n  }\n  value"],
      ["discarded conditional", "", "if value == 0i64 {\n    1i32\n  } else {\n    2i32\n  }\n  value"],
      ["I64 SIMD lane replacement", "builtin splat(value: I64) -> V128 = \"i64x2.splat\"\nbuiltin replace(value: V128, lane: I64) -> V128 = \"i64x2.replace_lane 1\"\nbuiltin extract(value: V128) -> I64 = \"i64x2.extract_lane 1\"\n", "extract(replace(splat(0i64), value))"],
    ]) {
      const source = declarations + "fn identity<t>(value: t) -> t {\n  value\n}\nfn reader<t>() -> fn(t) -> t {\n  identity\n}\npub fn main(value: I64) -> I64 {\n  " + body + "\n}\n";
      let main;
      try {
        main = await compileSource(source);
      } catch (error) {
        failures++;
        console.error(new Error(`${name} source probe failed`, { cause: error }));
        continue;
      }
      for (const value of specializationI64Values) {
        assert.equal(main(value), value, `${name} function reference(${value})`);
        checks++;
      }
    }
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host exact function reference checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    assert.ok(elapsed <= 30, "function reference compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host exact function reference probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const source = await readFile(new URL("./dew-test/specialization_callbacks.dew", import.meta.url), "utf8");
    // The self-host standalone entrypoint exports main, not all public source
    // functions. Compile a typed main wrapper for every shared oracle entry.
    const exports = Object.create(null);
    for (const [name, parameters, arguments_] of [
      ["pair_i32_i64", "left: I32, right: I64", "left, right"],
      ["pair_i64_i32", "left: I64, right: I32", "left, right"],
      ["nested_i32_i64", "left: I32, right: I64", "left, right"],
      ["nested_i64_i32", "left: I64, right: I32", "left, right"],
      ...["erased_product", "mixed_scalars", "nominal_callback", "generic_nominal_callback",
        "captured_nominal_callback", "captured_generic_nominal_callback", "callback_evaluation_order"]
        .map(name => [name, "value: I64", "value"]),
    ]) {
      exports[name] = await compileSource(source + `\npub fn main(${parameters}) -> I64 {\n  ${name}(${arguments_})\n}\n`);
    }
    const checks = checkSpecializationCallbacks(exports);
    const elapsed = (performance.now() - start) / 1000;
    console.log(`self-host specialization callback checks passed: ${checks} (${elapsed.toFixed(3)} seconds)`);
    assert.ok(elapsed <= 30, "callback compiler performance exceeds 30 seconds");
  } catch (error) {
    failures++;
    console.error("self-host specialization callback probe failed");
    console.error(error);
  }
}
{
  const start = performance.now();
  try {
    const request = await readFile(process.argv[3] ?? new URL("../.tmp/self-host-hardening/array.request.bin", import.meta.url));
    const exports = await compileProbeBytes(request, "self_host_emission_probe_compile_request");
    console.log(`self-host real-library array checks passed: ${checkArrayOperations(exports.main)} (${((performance.now() - start) / 1000).toFixed(3)} seconds)`);
  } catch (error) {
    failures++;
    console.error("self-host real-library array probe failed", error);
  }
}
if (failures) throw new Error(`${failures} self-host emission probe(s) failed`);
