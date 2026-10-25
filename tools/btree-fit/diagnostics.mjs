// Verify the exact expected assertions. Any other assertion remains a failure.
import fs from 'node:fs';
import assert from 'node:assert/strict';
import { decodeDewTestMetadata } from '../dew-test/metadata.mjs';

const [binary, output] = process.argv.slice(2);
const module = await WebAssembly.compile(fs.readFileSync(binary));
const sections = WebAssembly.Module.customSections(module, "dew.tests");
assert.equal(sections.length, 1);
const metadata = decodeDewTestMetadata(Buffer.from(sections[0]));
let instance;
let writes = [];
const imports = {
  'dewdrop.transform.workers': { capacity: () => 0 },
  wasi_snapshot_preview1: {
    fd_write(fd, vectors, length, written) {
      const memory = instance.exports.memory;
      const view = new DataView(memory.buffer);
      let total = 0;
      for (let i = 0; i < length; i++) {
        const address = view.getUint32(vectors + i * 8, true);
        const count = view.getUint32(vectors + i * 8 + 4, true);
        if (fd === 1) writes.push(Buffer.from(new Uint8Array(memory.buffer, address, count)));
        total += count;
      }
      view.setUint32(written, total, true);
      return 0;
    },
  },
};
instance = await WebAssembly.instantiate(module, imports);
if (instance.exports.__dew_init) instance.exports.__dew_init();
const expected = new Map([
  ['B-tree new key at U32 max is diagnostic', /BTree plain leaf insert: U32 length overflow; count=4294967295 capacity=61/],
  ['B-tree full root has a diagnostic checkpoint boundary', /BTree plain Unit leaf insert: full root leaf; step-3 checkpoint requires split support; count=251 capacity=251 index=251 head=false/],
]);
const messages = {};
for (const [name, pattern] of expected) {
  const test = metadata.find(test => test.name === name);
  assert.ok(test, `missing diagnostic case: ${name}`);
  writes = [];
  assert.throws(() => instance.exports[test.export](), WebAssembly.RuntimeError, name);
  const message = new TextDecoder('utf-8', { fatal: true }).decode(Buffer.concat(writes));
  assert.match(message, pattern, name);
  messages[name] = message;
}
fs.writeFileSync(output, JSON.stringify(messages, null, 2) + '\n');
console.log('Both exact count/capacity/operation diagnostics passed.');
