import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
const module = new WebAssembly.Module(readFileSync(process.argv[2]));
assert.equal(WebAssembly.Module.customSections(module, 'dew.tests').length, 0);
const imports = Object.create(null);
for (const entry of WebAssembly.Module.imports(module)) {
  assert.deepEqual(entry, { module: 'dewdrop.transform.workers', name: 'capacity', kind: 'function' });
  imports[entry.module] = { capacity: () => 0 };
}
const instance = new WebAssembly.Instance(module, imports);
instance.exports.__dew_init?.();
assert.equal(instance.exports.main(), 10);
console.log('Production hex consumer passed: result 10, no test metadata or host I/O.');
