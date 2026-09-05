import assert from "node:assert/strict";

export const specializationI64Values = [0n, 42n, -1n, 2147483648n, -(1n << 63n), (1n << 63n) - 1n];

export function checkSpecializationProducts(exports) {
  let checks = 0;
  for (const value of specializationI64Values) {
    for (const [name, args] of [
      ["pair_i32_i64", [7, value]],
      ["pair_i64_i32", [value, 7]],
      ["nested_i32_i64", [7, value]],
      ["nested_i64_i32", [value, 7]],
      ["erased_product", [value]],
    ]) {
      assert.equal(typeof exports[name], "function", `missing export ${name}`);
      assert.equal(exports[name](...args), value, `${name}(${args})`);
      checks++;
    }
  }
  return checks;
}
