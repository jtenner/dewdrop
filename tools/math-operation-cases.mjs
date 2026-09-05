import assert from "node:assert/strict";

export const unaryMathOperations = ["abs", "sqrt", "ceil", "floor", "trunc", "nearest"];

function nearest(value) {
  if (!Number.isFinite(value) || value === 0) return value;
  const lower = Math.floor(value);
  const fraction = value - lower;
  const rounded = fraction < 0.5 ? lower : fraction > 0.5 ? lower + 1 : lower % 2 === 0 ? lower : lower + 1;
  return rounded === 0 && value < 0 ? -0 : rounded;
}

export async function checkMathOperations(getUnary, getBits, getClamp, getCtz) {
  let checks = 0;
  for (const width of [32, 64]) {
    for (const op of unaryMathOperations) {
      const operation = await getUnary(width, op);
      assert.equal(typeof operation, "function", `f${width}_${op}: missing export`);
      for (const value of [-Infinity, -4, -2.5, -1.5, -1, -0.5, -0, 0, 0.5, 1.5, 2.5, 4, Infinity, NaN]) {
        let expected = op === "nearest" ? nearest(value) : Math[op](value);
        if (width === 32) expected = Math.fround(expected);
        assert.equal(operation(value), expected, `f${width}_${op}(${value})`);
        checks++;
      }
    }
    const sign = 1n << BigInt(width - 1);
    const infinity = width === 32 ? 0x7f800000n : 0x7ff0000000000000n;
    const quiet = width === 32 ? 0x00400000n : 0x0008000000000000n;
    const one = width === 32 ? 0x3f800000n : 0x3ff0000000000000n;
    const nan1 = infinity | quiet | 1n;
    const nan2 = sign | infinity | quiet | 0x42n;
    const argument = bits => width === 32 ? Number(bits) : bits;
    const physical = bits => width === 32 ? Number(BigInt.asIntN(32, bits)) : BigInt.asIntN(64, bits);
    const roundtrip = await getBits(width, "roundtrip");
    assert.equal(typeof roundtrip, "function", `f${width}: missing bit roundtrip`);
    for (const bits of [0n, sign, 1n, one, infinity, sign | infinity, nan1, nan2, infinity | 1n]) {
      assert.equal(roundtrip(argument(bits)), physical(bits), `f${width}: exact bit roundtrip ${bits}`);
      checks++;
    }
    // Keep NaNs entirely inside Wasm so JS cannot canonicalize their payloads.
    for (const op of ["min", "max", "copysign"]) {
      const operation = await getBits(width, op);
      assert.equal(typeof operation, "function", `f${width}_${op}: missing bitwise probe`);
      const pairs = [[0n, sign], [sign, 0n], [nan1, nan2], [nan1, one], [one, nan2]];
      for (const [left, right] of pairs) {
        const expected = op === "copysign" ? (left & (sign - 1n)) | (right & sign) :
          left === nan1 ? left : right === nan2 ? right : op === "min" ? sign : 0n;
        assert.equal(operation(argument(left), argument(right)), physical(expected), `f${width}_${op}: payload/sign preservation`);
        checks++;
      }
    }
    const clamp = await getClamp(width);
    assert.equal(typeof clamp, "function", `f${width}: missing clamp`);
    for (const [value, expected] of [[1.5, 1.5], [-3, -2], [3, 2], [-0, -0], [NaN, NaN]]) {
      assert.equal(clamp(value, -2, 2), expected, `f${width}_clamp(${value})`);
      checks++;
    }
    for (const [lower, upper] of [[2, 1], [NaN, 1], [0, NaN]]) {
      assert.throws(() => clamp(0, lower, upper), WebAssembly.RuntimeError, `f${width}: invalid clamp bounds`);
      checks++;
    }
  }
  const ctz = await getCtz();
  assert.equal(typeof ctz, "function", "missing count-trailing-zeros export");
  for (const [value, expected] of [[0, 32], [1, 0], [2, 1], [4, 2], [0x80000000, 31], [0xffffffff, 0]]) {
    assert.equal(ctz(value), expected, `i32.ctz(${value})`);
    checks++;
  }
  return checks;
}
