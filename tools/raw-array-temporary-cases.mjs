import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";

export async function checkRawArrayTemporaryFlow(compile) {
  const prefix = `builtin unreachable() -> Never = "unreachable"
pub struct Storage<t> {}
builtin allocate<t>(length: U32, value: t) -> Storage<t> = "array_new"
fn unexpected() -> I64 {
  unreachable()
}
`;
  for (const arguments_ of ["return 42i64, unexpected()", "1u32, return 42i64"]) {
    const source = `${prefix}pub fn main() -> I64 {
  let storage = allocate::<I64>(${arguments_})
  unexpected()
}
`;
    let inspected = false;
    const exports = await compile(source, bytes => {
      const wat = execFileSync("wasm-tools", ["print", "-"], { input: bytes, encoding: "utf8" });
      assert.equal(/\barray\.new(?:\s|$)/.test(wat), false, "a Never argument must prevent the array.new instruction");
      inspected = true;
    });
    assert.equal(inspected, true, "inspect the validated emitted module");
    assert.equal(exports.main(), 42n, `array.new(${arguments_}) must stop at the return`);
  }
  return 2;
}
