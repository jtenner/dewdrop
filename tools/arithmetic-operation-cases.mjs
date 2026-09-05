import assert from "node:assert/strict";

export const arithmeticTypes = ["I8", "U8", "I16", "U16", "I32", "U32", "I64", "U64", "F32", "F64"];
export const comparisons = ["eq", "ne", "lt", "lte", "gt", "gte"];
export function arithmeticOperations(type) {
  return type[0] === "F" ? [...comparisons, "add", "sub", "mul", "div"] :
    [...comparisons, "or", "xor", "and", "shl", "shr", "add", "sub", "mul", "div", "rem"];
}

function compare(op, a, b) {
  switch (op) {
    case "eq": return Number(a === b);
    case "ne": return Number(a !== b);
    case "lt": return Number(a < b);
    case "lte": return Number(a <= b);
    case "gt": return Number(a > b);
    case "gte": return Number(a >= b);
  }
  throw new Error(`unknown comparison ${op}`);
}

function inputs(type) {
  if (type[0] === "F") return [[0, 0], [-0, 1], [0, -1], [1, 0], [-1, 0], [NaN, 1], [Infinity, -Infinity], [1.5, 2.25], [2 ** 24, 1]];
  const width = Number(type.slice(1));
  const signed = type[0] === "I";
  const max = (1n << BigInt(width - (signed ? 1 : 0))) - 1n;
  const min = signed ? -max - 1n : 0n;
  const normalize = value => signed ? BigInt.asIntN(width, value) : BigInt.asUintN(width, value);
  return [[0n, 0n], [max, 1n], [min, -1n], [min, max], [max, max], [1n, BigInt(width - 1)], [1n, BigInt(width)], [max, BigInt(width + 1)], [max, -1n]]
    .map(pair => pair.map(normalize));
}

function expected(type, op, a, b) {
  if (comparisons.includes(op)) return compare(op, a, b);
  if (type[0] === "F") {
    let value;
    switch (op) {
      case "add": value = a + b; break;
      case "sub": value = a - b; break;
      case "mul": value = a * b; break;
      case "div": value = a / b; break;
      default: throw new Error(`unknown float operation ${op}`);
    }
    return type === "F32" ? Math.fround(value) : value;
  }
  const width = Number(type.slice(1));
  const signed = type[0] === "I";
  if ((op === "div" || op === "rem") && b === 0n) return null;
  if (op === "div" && signed && width >= 32 && a === -(1n << BigInt(width - 1)) && b === -1n) return null;
  const shift = b & BigInt(width - 1);
  let value;
  switch (op) {
    case "add": value = a + b; break;
    case "sub": value = a - b; break;
    case "mul": value = a * b; break;
    case "div": value = a / b; break;
    case "rem": value = a % b; break;
    case "or": value = a | b; break;
    case "xor": value = a ^ b; break;
    case "and": value = a & b; break;
    case "shl": value = a << shift; break;
    case "shr": value = a >> shift; break;
    default: throw new Error(`unknown integer operation ${op}`);
  }
  value = signed ? BigInt.asIntN(width, value) : BigInt.asUintN(width, value);
  return width === 64 ? BigInt.asIntN(64, value) : Number(BigInt.asIntN(32, value));
}

export async function checkArithmeticOperations(getOperation) {
  let checks = 0;
  for (const type of arithmeticTypes) {
    for (const op of arithmeticOperations(type)) {
      const name = `${type.toLowerCase()}_${op}`;
      const operation = await getOperation(type, op, name, comparisons.includes(op) ? "Bool" : type);
      assert.equal(typeof operation, "function", `${name}: missing arithmetic export`);
      for (const [a, b] of inputs(type)) {
        const want = expected(type, op, a, b);
        const argument = value => type.endsWith("64") && type[0] !== "F" ? value : Number(value);
        const label = `${name}(${a}, ${b})`;
        if (want === null) assert.throws(() => operation(argument(a), argument(b)), WebAssembly.RuntimeError, label);
        else assert.equal(operation(argument(a), argument(b)), want, label);
        checks++;
      }
    }
  }
  return checks;
}
