import assert from "node:assert/strict";

// WebAssembly.compile validates the complete module before this observer runs.
// Compare the code section only: source names may change debug custom sections.
function codeSection(bytes) {
  let offset = 8;
  let code;
  const u32 = () => {
    let value = 0;
    for (let shift = 0; shift < 35; shift += 7) {
      assert.ok(offset < bytes.length, "truncated Wasm section length");
      const byte = bytes[offset++];
      value += (byte & 127) * 2 ** shift;
      if (!(byte & 128)) return value;
    }
    throw new Error("invalid Wasm section length");
  };
  while (offset < bytes.length) {
    const id = bytes[offset++];
    const size = u32();
    const end = offset + size;
    assert.ok(end <= bytes.length, "Wasm section exceeds module");
    if (id === 10) {
      assert.equal(code, undefined, "duplicate code section");
      code = bytes.slice(offset, end);
    }
    offset = end;
  }
  assert.ok(code, "missing code section");
  return code;
}

export async function checkTemporaryLocalLayout(compile) {
  let reference;
  for (const name of ["plain_user_identity", "self_host_array_pop"]) {
    const source = `fn ${name}(value: I64) -> I64 {
  value
}
pub fn main() -> I64 {
  ${name}(42i64)
}
`;
    let code;
    const exports = await compile(source, bytes => { code = codeSection(bytes); });
    assert.equal(exports.main(), 42n, `${name}: ordinary call result`);
    assert.ok(code, "compiler must provide the emitted bytes");
    if (reference) {
      assert.deepEqual(code, reference, "ordinary source spelling must not add collection locals or change code");
    } else {
      reference = code;
    }
  }
  return 2;
}
