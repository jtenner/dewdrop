import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { performance } from 'node:perf_hooks';
import { readSelfHostInvariantFailure, formatSelfHostInvariantFailure } from './self-host-invariant-record.mjs';
const start = performance.now();
const module = await WebAssembly.compile(await readFile(process.argv[2]));
function importsFor(module) {
  const imports = Object.create(null);
  for (const entry of WebAssembly.Module.imports(module)) {
    assert.equal(entry.kind, 'function');
    imports[entry.module] ??= Object.create(null);
    imports[entry.module][entry.name] = () => { throw new Error(`Unexpected host call ${entry.module}.${entry.name}`); };
  }
  return imports;
}
const compiler = await WebAssembly.instantiate(module, importsFor(module));
compiler.exports.__dew_init?.();
for (const name of ['self_host_emit_inferred_values_probe', 'self_host_emit_short_unit_patterns_probe']) {
  let result;
  try {
    result = compiler.exports[name]();
  } catch (error) {
    const record = readSelfHostInvariantFailure(compiler.exports.memory);
    if (record) console.error(formatSelfHostInvariantFailure(record));
    throw error;
  }
  const bytes = new Uint8Array(compiler.exports.self_host_short_bytes_length(result));
  assert.ok(bytes.length >= 8, 'Missing emitted module');
  for (let index = 0; index < bytes.length; index++) bytes[index] = compiler.exports.self_host_short_byte_at(result, index);
  const emitted = await WebAssembly.compile(bytes);
  const instance = await WebAssembly.instantiate(emitted, importsFor(emitted));
  instance.exports.__dew_init?.();
  assert.equal(instance.exports.main(), 42, name);
}
const seconds = (performance.now() - start) / 1000;
console.log(`Short inference emission passed (${seconds.toFixed(3)} seconds)`);
assert.ok(seconds <= 30, 'Short inference compiler performance exceeds 30 seconds');
