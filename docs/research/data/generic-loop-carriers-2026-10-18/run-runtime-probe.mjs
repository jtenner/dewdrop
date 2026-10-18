import assert from "node:assert/strict";
import { readFileSync, writeFileSync } from "node:fs";
import { performance } from "node:perf_hooks";
function imports(module) {
  const imports = {};
  for (const item of WebAssembly.Module.imports(module)) {
    assert.equal(item.kind, "function");
    (imports[item.module] ??= {})[item.name] = () => { throw new Error(`unexpected call ${item.module}.${item.name}`); };
  }
  return imports;
}
const start = performance.now();
const module = new WebAssembly.Module(readFileSync(process.argv[2]));
const compiler = new WebAssembly.Instance(module, imports(module)).exports;
compiler.__dew_init?.();
const result = compiler.self_host_emit_generic_loop_carrier_probe();
const length = compiler.pattern_bytes_length ?? compiler.self_host_emission_probe_bytes_length;
const byteAt = compiler.pattern_byte_at ?? compiler.self_host_emission_probe_byte_at;
const bytes = Uint8Array.from({length: length(result)}, (_, i) => byteAt(result, i));
writeFileSync(process.argv[3], bytes);
const generated_ms = performance.now()-start;
const userModule = new WebAssembly.Module(bytes);
const user = new WebAssembly.Instance(userModule, imports(userModule)).exports;
user.__dew_init?.();
assert.equal(user.main(), 42);
console.log(JSON.stringify({result:42, generated_ms, total_ms:performance.now()-start, wasm_bytes:bytes.length}));
