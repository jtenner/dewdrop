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
    b"unreachable" => Some({ inputs: [], result: None, })
    b"i32.reinterpret_f32" =>
      Some({ inputs: [WasmF32Value], result: Some(WasmI32Value), })
    b"f32.reinterpret_i32" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmF32Value), })
    b"f32.abs"
    | b"f32.neg"
    | b"f32.sqrt"
    | b"f32.ceil"
    | b"f32.floor"
    | b"f32.trunc"
    | b"f32.nearest" =>
      Some({ inputs: [WasmF32Value], result: Some(WasmF32Value), })
    b"i64.reinterpret_f64" =>
      Some({ inputs: [WasmF64Value], result: Some(WasmI64Value), })
    b"f64.reinterpret_i64" =>
      Some({ inputs: [WasmI64Value], result: Some(WasmF64Value), })
    b"f64.abs"
    | b"f64.neg"
    | b"f64.sqrt"
    | b"f64.ceil"
    | b"f64.floor"
    | b"f64.trunc"
    | b"f64.nearest" =>
      Some({ inputs: [WasmF64Value], result: Some(WasmF64Value), })
    b"i32.ctz" | b"i32.popcnt" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmI32Value), })
    b"i32.add"
    | b"i32.sub"
    | b"i32.le_s"
    | b"i32.eq"
    | b"i32.ne"
    | b"i32.lt_s"
    | b"i32.gt_s"
    | b"i32.ge_s"
    | b"i32.shl"
    | b"i32.shr_s"
    | b"i32.mul"
    | b"i32.div_s"
    | b"i32.rem_s"
    | b"i32.lt_u"
    | b"i32.le_u"
    | b"i32.gt_u"
    | b"i32.ge_u"
    | b"i32.shr_u"
    | b"i32.div_u"
    | b"i32.rem_u" =>
      Some({ inputs: [WasmI32Value, WasmI32Value], result: Some(WasmI32Value), })
    b"i64.eq"
    | b"i64.ne"
    | b"i64.lt_s"
    | b"i64.le_s"
    | b"i64.gt_s"
    | b"i64.ge_s"
    | b"i64.lt_u"
    | b"i64.le_u"
    | b"i64.gt_u"
    | b"i64.ge_u" =>
      Some({ inputs: [WasmI64Value, WasmI64Value], result: Some(WasmI32Value), })
    b"i64.shl"
    | b"i64.shr_s"
    | b"i64.add"
    | b"i64.sub"
    | b"i64.mul"
    | b"i64.div_s"
    | b"i64.rem_s"
    | b"i64.shr_u"
    | b"i64.div_u"
    | b"i64.rem_u" =>
      Some({ inputs: [WasmI64Value, WasmI64Value], result: Some(WasmI64Value), })
    b"f32.eq" | b"f32.ne" | b"f32.lt" | b"f32.le" | b"f32.gt" | b"f32.ge" =>
      Some({ inputs: [WasmF32Value, WasmF32Value], result: Some(WasmI32Value), })
    b"f32.add" | b"f32.sub" | b"f32.mul" | b"f32.div" =>
      Some({ inputs: [WasmF32Value, WasmF32Value], result: Some(WasmF32Value), })
    b"f64.eq" | b"f64.ne" | b"f64.lt" | b"f64.le" | b"f64.gt" | b"f64.ge" =>
      Some({ inputs: [WasmF64Value, WasmF64Value], result: Some(WasmI32Value), })
    b"f64.add" | b"f64.sub" | b"f64.mul" | b"f64.div" =>
      Some({ inputs: [WasmF64Value, WasmF64Value], result: Some(WasmF64Value), })
    b"i32.extend8_s" | b"i32.extend16_s" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmI32Value), })
    b"i32.wrap_i64" =>
      Some({ inputs: [WasmI64Value], result: Some(WasmI32Value), })
    b"i64.extend_i32_s" | b"i64.extend_i32_u" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmI64Value), })
    b"f32.convert_i32_s" | b"f32.convert_i32_u" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmF32Value), })
    b"i32.trunc_f32_s" | b"i32.trunc_f32_u" =>
      Some({ inputs: [WasmF32Value], result: Some(WasmI32Value), })
    b"f32.convert_i64_s" | b"f32.convert_i64_u" =>
      Some({ inputs: [WasmI64Value], result: Some(WasmF32Value), })
    b"i64.trunc_f32_s" | b"i64.trunc_f32_u" =>
      Some({ inputs: [WasmF32Value], result: Some(WasmI64Value), })
    b"f64.convert_i32_s" | b"f64.convert_i32_u" =>
      Some({ inputs: [WasmI32Value], result: Some(WasmF64Value), })
    b"i32.trunc_f64_s" | b"i32.trunc_f64_u" =>
      Some({ inputs: [WasmF64Value], result: Some(WasmI32Value), })
    b"f64.convert_i64_s" | b"f64.convert_i64_u" =>
      Some({ inputs: [WasmI64Value], result: Some(WasmF64Value), })
    b"i64.trunc_f64_s" | b"i64.trunc_f64_u" =>
      Some({ inputs: [WasmF64Value], result: Some(WasmI64Value), })
    b"f32.demote_f64" =>
      Some({ inputs: [WasmF64Value], result: Some(WasmF32Value), })
    b"f64.promote_f32" =>
      Some({ inputs: [WasmF32Value], result: Some(WasmF64Value), })
    b"i32.and" | b"i32.or" | b"i32.xor" =>
      Some({ inputs: [WasmI32Value, WasmI32Value], result: Some(WasmI32Value), })
    b"i64.and" | b"i64.or" | b"i64.xor" =>
      Some({ inputs: [WasmI64Value, WasmI64Value], result: Some(WasmI64Value), })
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
    _ => raw_wasm_simd_signature(name)
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
