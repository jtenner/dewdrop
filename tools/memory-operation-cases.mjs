import assert from "node:assert/strict";

export const memoryTypes = ["I8", "U8", "I16", "U16", "I32", "U32", "I64", "U64", "F32", "F64", "Swar32", "Swar64"];

export async function checkMemoryOperations(getProbe, getVectorCopy) {
  let checks = 0;
  for (const type of memoryTypes) {
    const { operation, memory } = await getProbe(type);
    assert.equal(typeof operation, "function", `${type}: missing memory probe`);
    assert.ok(memory instanceof WebAssembly.Memory, `${type}: missing memory export`);
    const width = Number(type.match(/\d+/)[0]);
    const bytes = width / 8;
    const signed = type[0] === "I" || type.startsWith("Swar");
    const float = type[0] === "F";
    const wide = !float && width === 64;
    const values = float ? [0, -0, 42.75, -123.5, Infinity, -Infinity, NaN] :
      wide ? [0n, -1n, 0x123456789abcdefn, -(1n << 63n)] : [0, 1, -1, 0x12345678];
    const view = new DataView(memory.buffer);
    const method = float ? `Float${width}` : `${signed ? "Int" : "Uint"}${width}`;
    const setter = `set${wide ? "Big" : ""}${method}`;
    const getter = `get${wide ? "Big" : ""}${method}`;
    for (const value of values) {
      // Deliberately unaligned. The host oracle determines the exact byte order,
      // narrow truncation, and signed/unsigned extension independently.
      const address = 257;
      view[setter](address + 32, value, true);
      let expected = view[getter](address + 32, true);
      if (wide) expected = BigInt.asIntN(64, expected);
      else if (!float && width === 32) expected |= 0;
      assert.equal(operation(address, value, 1), expected, `${type}: store/load result`);
      assert.deepEqual(new Uint8Array(memory.buffer, address, bytes), new Uint8Array(memory.buffer, address + 32, bytes), `${type}: little-endian bytes`);
      assert.equal(operation(address + 32, value, 0), expected, `${type}: independent load`);
      checks += 3;
    }
    const value = values[0];
    const end = memory.buffer.byteLength;
    assert.equal(operation(end - bytes, value, 1), value, `${type}: last valid store/load`);
    assert.throws(() => operation(end - bytes + 1, value, 1), WebAssembly.RuntimeError, `${type}: store bounds`);
    assert.throws(() => operation(end - bytes + 1, value, 0), WebAssembly.RuntimeError, `${type}: load bounds`);
    checks += 3;
  }
  const { copy, memory } = await getVectorCopy();
  assert.equal(typeof copy, "function", "missing vector memory probe");
  assert.ok(memory instanceof WebAssembly.Memory, "missing vector memory export");
  const vector = new Uint8Array(memory.buffer, 257, 16);
  for (let index = 0; index < 16; index++) vector[index] = index * 17;
  copy(257, 291);
  assert.deepEqual(new Uint8Array(memory.buffer, 291, 16), vector, "unaligned V128 copy");
  const end = memory.buffer.byteLength;
  assert.throws(() => copy(end - 15, 291), WebAssembly.RuntimeError, "V128 load bounds");
  assert.throws(() => copy(257, end - 15), WebAssembly.RuntimeError, "V128 store bounds");
  return checks + 3;
}
