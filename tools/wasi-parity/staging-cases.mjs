import assert from "node:assert/strict";

export function checkBytesStaging(exports) {
  assert.equal(typeof exports.main, "function", "staging probe main is missing");
  assert.ok(exports.memory instanceof WebAssembly.Memory, "staging memory is missing");
  const memory = new Uint8Array(exports.memory.buffer);
  const payload = (length, salt) => Uint8Array.from(
    { length }, (_, index) => (index * 131 + salt * 17 + 7) & 255,
  );
  let checks = 0;
  const lengths = [0, 1, 15, 16, 17, 4095, 4096, 4097, 65519, 65520];
  const cases = lengths.map(length => [length, length % 16]);
  for (let alignment = 0; alignment < 16; alignment++) cases.push([73, alignment]);
  for (const [length, alignment] of cases) {
    const salt = length + alignment + 1;
    const expected = payload(length, salt);
    memory.fill(0xa5);
    assert.equal(exports.main(0, length, alignment, salt), length, `write ${length}/${alignment}`);
    assert.deepEqual(memory.slice(16, 16 + length), expected, `write bytes ${length}/${alignment}`);
    assert.ok(memory.slice(0, 16).every(byte => byte === 0xa5), "write changed the header");
    assert.ok(memory.slice(16 + length, 65536).every(byte => byte === 0xa5), "write changed the tail");
    checks++;

    memory.fill(0xa5);
    memory.set(expected, 16);
    assert.equal(exports.main(1, length, 0, salt), 1, `read bytes/lifetime ${length}`);
    assert.ok(memory.slice(0, 16).every(byte => byte === 0xa5), "read changed the header");
    assert.ok(memory.slice(16 + length, 65536).every(byte => byte === 0xa5), "read changed the tail");
    checks++;
  }
  for (const operation of [0, 1]) {
    memory.fill(0xa5);
    const before = memory.slice();
    assert.throws(() => exports.main(operation, 65521, 0, 7), WebAssembly.RuntimeError,
      `operation ${operation} must reject an oversized scratch range`);
    assert.deepEqual(memory, before, "invalid range changed scratch before rejection");
    checks++;
  }
  return checks;
}
