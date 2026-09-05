import assert from "node:assert/strict";

export const scalarTypes = ["I8", "I16", "I32", "I64", "U8", "U16", "U32", "U64", "F32", "F64"];

// This oracle uses integer arithmetic, not compiler instruction tables.
function inputs(type) {
  if (type[0] === "F") return [-0, 0, -0.75, 42.75, -128, 127, 65535, NaN, Infinity, -Infinity];
  const width = Number(type.slice(1));
  const signed = type[0] === "I";
  const max = (1n << BigInt(width - (signed ? 1 : 0))) - 1n;
  return [...new Set([0n, 1n, 42n, 127n, signed ? -1n : 128n, signed ? -max - 1n : max - 1n, max])];
}

function expected(input, source, target) {
  if (target[0] === "F") {
    const value = Number(input);
    return target === "F32" ? Math.fround(value) : value;
  }
  const width = Number(target.slice(1));
  const signed = target[0] === "I";
  if (source[0] === "F") {
    if (!Number.isFinite(input)) return null;
    input = BigInt(Math.trunc(input));
    const min = signed ? -(1n << BigInt(width - 1)) : 0n;
    const max = (1n << BigInt(width - (signed ? 1 : 0))) - 1n;
    if (input < min || input > max) return null;
  }
  const value = signed ? BigInt.asIntN(width, input) : BigInt.asUintN(width, input);
  // JS exposes Wasm integers as signed physical values, even for Dew U32/U64.
  return width === 64 ? BigInt.asIntN(64, value) : Number(BigInt.asIntN(32, value));
}

export async function checkScalarConversions(getConversion) {
  let checks = 0;
  for (const source of scalarTypes) {
    for (const target of scalarTypes) {
      const name = `${source.toLowerCase()}_into_${target.toLowerCase()}`;
      const convert = await getConversion(source, target, name);
      assert.equal(typeof convert, "function", `${name}: missing conversion export`);
      for (const input of inputs(source)) {
        const want = expected(input, source, target);
        const argument = source.endsWith("64") && source[0] !== "F" ? input : Number(input);
        const label = `${name}(${input})`;
        if (want === null) assert.throws(() => convert(argument), WebAssembly.RuntimeError, label);
        else assert.equal(convert(argument), want, label);
        checks++;
      }
    }
  }
  return checks;
}
