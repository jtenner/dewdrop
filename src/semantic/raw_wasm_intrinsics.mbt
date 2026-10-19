///|
pub struct RawWasmIntrinsicSignature {
  inputs : Array[PlannedWasmValueType]
  result : PlannedWasmValueType?
} derive(Eq, Debug)

///|
fn raw_wasm_nonreference_carrier(
  shape : PlannedValueShape,
) -> PlannedWasmValueType? {
  match shape {
    I8PlannedValueShape
    | U8PlannedValueShape
    | I16PlannedValueShape
    | U16PlannedValueShape
    | I32PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => Some(WasmI32Value)
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      Some(WasmI64Value)
    F32PlannedValueShape => Some(WasmF32Value)
    F64PlannedValueShape => Some(WasmF64Value)
    V128PlannedValueShape => Some(WasmV128Value)
    _ => None
  }
}

///|
// Opcode identity, not a Dew declaration name or a standard-module ordinal.
pub fn raw_wasm_builtin_signature(name : Bytes) -> RawWasmIntrinsicSignature? {
  match name {
    b"ref.eq" =>
      Some({
        inputs: [WasmNullableEqRefValue, WasmNullableEqRefValue],
        result: Some(WasmI32Value),
      })
    b"unreachable" => Some({ inputs: [], result: None, })
    b"v128.and" | b"v128.or" | b"v128.xor" =>
      Some({
        inputs: [WasmV128Value, WasmV128Value],
        result: Some(WasmV128Value),
      })
    b"i32.load"
    | b"i32.load8_s"
    | b"i32.load8_u"
    | b"i32.load16_s"
    | b"i32.load16_u" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmI32Value), })
    b"f32.load" => Some({ inputs: [WasmI32Value], result: Some(WasmF32Value), })
    b"f32.store" =>
      Some({ inputs: [WasmI32Value, WasmF32Value], result: None, })
    b"f64.load" => Some({ inputs: [WasmI32Value], result: Some(WasmF64Value), })
    b"f64.store" =>
      Some({ inputs: [WasmI32Value, WasmF64Value], result: None, })
    b"i64.load" => Some({ inputs: [WasmI32Value], result: Some(WasmI64Value), })
    b"v128.load" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmV128Value), })
    b"i32.store" | b"i32.store8" | b"i32.store16" =>
      Some({ inputs: [WasmI32Value, WasmI32Value], result: None, })
    b"i64.store" =>
      Some({ inputs: [WasmI32Value, WasmI64Value], result: None, })
    b"v128.store" =>
      Some({ inputs: [WasmI32Value, WasmV128Value], result: None, })
    _ => match raw_wasm_scalar_signature(name) {
      Some(signature) => Some(signature)
      None => raw_wasm_simd_signature(name)
    }
  }
}

///|
fn raw_wasm_builtin_is_inline(name : Bytes) -> Bool {
  if raw_wasm_builtin_signature(name) is Some(_) {
    return true
  }
  // A malformed Wasm opcode is not a host import. Keep it on the intrinsic
  // path so emission reports UnsupportedBuiltin before producing a module.
  if name.length() < 4 ||
    (name[0] != b'i' && name[0] != b'f' && name[0] != b'v') {
    return false
  }
  for
    prefix in [
      b"i32.", b"i64.", b"f32.", b"f64.", b"v128.", b"i8x16.", b"i16x8.", b"i32x4.",
      b"i64x2.", b"f32x4.", b"f64x2.",
    ] {
    if name.length() >= prefix.length() {
      let mut matches = true
      for index in 0..<prefix.length() {
        if name[index] != prefix[index] {
          matches = false
          break
        }
      }
      if matches {
        return true
      }
    }
  }
  false
}
