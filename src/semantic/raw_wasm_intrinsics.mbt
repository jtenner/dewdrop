///|
pub struct RawWasmIntrinsicSignature {
  first : PlannedWasmValueType
  second : PlannedWasmValueType?
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
    b"i32.extend8_s" | b"i32.extend16_s" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmI32Value), })
    b"i32.wrap_i64" =>
      Some({ first: WasmI64Value, second: None, result: Some(WasmI32Value), })
    b"i64.extend_i32_s" | b"i64.extend_i32_u" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmI64Value), })
    b"f32.convert_i32_s" | b"f32.convert_i32_u" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmF32Value), })
    b"i32.trunc_f32_s" | b"i32.trunc_f32_u" =>
      Some({ first: WasmF32Value, second: None, result: Some(WasmI32Value), })
    b"f32.convert_i64_s" | b"f32.convert_i64_u" =>
      Some({ first: WasmI64Value, second: None, result: Some(WasmF32Value), })
    b"i64.trunc_f32_s" | b"i64.trunc_f32_u" =>
      Some({ first: WasmF32Value, second: None, result: Some(WasmI64Value), })
    b"f64.convert_i32_s" | b"f64.convert_i32_u" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmF64Value), })
    b"i32.trunc_f64_s" | b"i32.trunc_f64_u" =>
      Some({ first: WasmF64Value, second: None, result: Some(WasmI32Value), })
    b"f64.convert_i64_s" | b"f64.convert_i64_u" =>
      Some({ first: WasmI64Value, second: None, result: Some(WasmF64Value), })
    b"i64.trunc_f64_s" | b"i64.trunc_f64_u" =>
      Some({ first: WasmF64Value, second: None, result: Some(WasmI64Value), })
    b"f32.demote_f64" =>
      Some({ first: WasmF64Value, second: None, result: Some(WasmF32Value), })
    b"f64.promote_f32" =>
      Some({ first: WasmF32Value, second: None, result: Some(WasmF64Value), })
    b"i32.and" | b"i32.or" | b"i32.xor" =>
      Some({
        first: WasmI32Value,
        second: Some(WasmI32Value),
        result: Some(WasmI32Value),
      })
    b"i64.and" | b"i64.or" | b"i64.xor" =>
      Some({
        first: WasmI64Value,
        second: Some(WasmI64Value),
        result: Some(WasmI64Value),
      })
    b"v128.and" | b"v128.or" | b"v128.xor" =>
      Some({
        first: WasmV128Value,
        second: Some(WasmV128Value),
        result: Some(WasmV128Value),
      })
    b"i32.load" | b"i32.load8_s" | b"i32.load8_u" | b"i32.load16_s" | b"i32.load16_u" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmI32Value), })
    b"f32.load" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmF32Value), })
    b"f32.store" =>
      Some({ first: WasmI32Value, second: Some(WasmF32Value), result: None, })
    b"f64.load" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmF64Value), })
    b"f64.store" =>
      Some({ first: WasmI32Value, second: Some(WasmF64Value), result: None, })
    b"i64.load" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmI64Value), })
    b"v128.load" =>
      Some({ first: WasmI32Value, second: None, result: Some(WasmV128Value), })
    b"i32.store" | b"i32.store8" | b"i32.store16" =>
      Some({ first: WasmI32Value, second: Some(WasmI32Value), result: None, })
    b"i64.store" =>
      Some({ first: WasmI32Value, second: Some(WasmI64Value), result: None, })
    b"v128.store" =>
      Some({ first: WasmI32Value, second: Some(WasmV128Value), result: None, })
    _ => None
  }
}

///|
fn raw_wasm_builtin_is_inline(name : Bytes) -> Bool {
  raw_wasm_builtin_signature(name) is Some(_)
}
