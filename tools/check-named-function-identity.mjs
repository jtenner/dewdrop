import assert from 'node:assert/strict';
import fs from 'node:fs';

const module_ = new WebAssembly.Module(fs.readFileSync(process.argv[2]));
assert.deepEqual(WebAssembly.Module.imports(module_), []);
const instance = new WebAssembly.Instance(module_, {});
// Dew uses a start section. Native output can expose a separate initializer.
instance.exports.__dew_init?.();
assert.equal(instance.exports.main(), 42);
assert.equal(instance.exports.main(), 42);
console.log('one instance, one startup, main() twice = 42');
