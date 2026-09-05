import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import { performance } from "node:perf_hooks";

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
let failures = 0;
for (const [name, expected] of [
  ["self_host_emit_raw_bitcast_probe", -1],
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
if (failures) throw new Error(`${failures} self-host emission probe(s) failed`);
