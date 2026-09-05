import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";

const fixtures = JSON.parse(await readFile(new URL("./dew-test/simd-memory-opcodes.json", import.meta.url), "utf8"));

function contract(opcode) {
  let match;
  if ((match = /^v128\.(load|store)(8|16|32|64)_lane (\d+)$/.exec(opcode))) {
    return { kind: match[1], width: Number(match[2]) / 8, lane: Number(match[3]) };
  }
  if ((match = /^v128\.load(8|16|32|64)_splat$/.exec(opcode))) {
    return { kind: "splat", width: Number(match[1]) / 8 };
  }
  if ((match = /^v128\.load(32|64)_zero$/.exec(opcode))) {
    return { kind: "zero", width: Number(match[1]) / 8 };
  }
  if ((match = /^v128\.load(8|16|32)x(8|4|2)_([su])$/.exec(opcode))) {
    return { kind: "extend", width: 8, element: Number(match[1]) / 8, signed: match[3] === "s" };
  }
  throw new Error(`missing SIMD memory oracle: ${opcode}`);
}

function widened(input, bytes, signed) {
  const result = new Uint8Array(16);
  for (let offset = 0; offset < input.length; offset += bytes) {
    let value = 0n;
    for (let byte = 0; byte < bytes; byte++) value |= BigInt(input[offset + byte]) << BigInt(byte * 8);
    if (signed) value = BigInt.asIntN(bytes * 8, value);
    value = BigInt.asUintN(bytes * 16, value);
    for (let byte = 0; byte < bytes * 2; byte++) result[offset * 2 + byte] = Number((value >> BigInt(byte * 8)) & 255n);
  }
  return result;
}

export async function checkSimdMemoryOperations(load) {
  let checks = 0;
  assert.equal(fixtures.length, 72, "complete SIMD memory descriptor coverage");
  for (const [index, fixture] of fixtures.entries()) {
    try {
      const { operation, memory } = await load(index, fixture.source);
      assert.equal(typeof operation, "function");
      assert.ok(memory instanceof WebAssembly.Memory);
      const bytes = new Uint8Array(memory.buffer);
      assert.ok(bytes.length >= 256);
      const spec = contract(fixture.opcode);
      const buffer = 128;
      const vector = Uint8Array.from({ length: 16 }, (_, lane) => (lane * 37 + index * 13 + 128) & 255);
      const input = Uint8Array.from({ length: spec.width }, (_, byte) => (byte * 53 + index * 29 + 128) & 255);
      for (const address of [1, 3, 17, bytes.length - spec.width]) {
        bytes.set(vector, buffer);
        bytes.set(input, address);
        bytes[address - 1] = 0xa5;
        if (address + spec.width < bytes.length) bytes[address + spec.width] = 0x5a;
        const expected = vector.slice();
        if (spec.kind === "load") expected.set(input, spec.lane * spec.width);
        else if (spec.kind === "splat") {
          for (let lane = 0; lane < 16; lane += spec.width) expected.set(input, lane);
        } else if (spec.kind === "zero") {
          expected.fill(0);
          expected.set(input);
        } else if (spec.kind === "extend") expected.set(widened(input, spec.element, spec.signed));
        operation(address, buffer);
        assert.deepEqual(bytes.slice(buffer, buffer + 16), expected, `${fixture.opcode}: vector bytes`);
        const expectedInput = spec.kind === "store" ? vector.slice(spec.lane * spec.width, (spec.lane + 1) * spec.width) : input;
        assert.deepEqual(bytes.slice(address, address + spec.width), expectedInput, `${fixture.opcode}: memory bytes`);
        assert.equal(bytes[address - 1], 0xa5, "write before memory operand");
        if (address + spec.width < bytes.length) assert.equal(bytes[address + spec.width], 0x5a, "write after memory operand");
        checks++;
      }
      for (const address of [bytes.length - spec.width + 1, 0xffffffff]) {
        const tail = bytes.slice(-32);
        const before = bytes.slice(buffer, buffer + 16);
        assert.throws(() => operation(address, buffer), WebAssembly.RuntimeError, `${fixture.opcode}: out-of-bounds access must trap`);
        assert.deepEqual(bytes.slice(-32), tail, "trapping instruction partly wrote memory");
        assert.deepEqual(bytes.slice(buffer, buffer + 16), before, "trapping load wrote its result");
        checks++;
      }
    } catch (error) {
      throw new Error(`SIMD memory case ${fixture.opcode} failed`, { cause: error });
    }
  }
  return checks;
}
