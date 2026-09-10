import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const module = await WebAssembly.compile(await readFile(process.argv[2]));
const imports = WebAssembly.Module.imports(module);
assert.equal(imports.length, 261, "Facet import inventory changed");
let calls = 0;
const facet = Object.fromEntries(imports.map(entry => {
  assert.equal(entry.module, "facet");
  assert.equal(entry.kind, "function");
  return [entry.name, () => {
    assert.equal(entry.name, "abi_version", "unexpected Facet host call");
    calls++;
    return 1;
  }];
}));
const instance = await WebAssembly.instantiate(module, { facet });
instance.exports.__dew_init?.();
assert.equal(instance.exports.run(), 1);
assert.equal(calls, 1);
console.log("Facet: 261 imports, one ABI query, result 1");
