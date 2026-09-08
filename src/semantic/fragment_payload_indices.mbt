///|
priv struct FragmentPayloadFailure {
  code : Int
  phase : Int
  module_id : ModuleId
  declaration : DeclId
  body : BodyId
  expression : UInt
  expected : UInt64
  actual : UInt64
  detail : UInt64
} derive(Eq, Debug)

///|
fn fragment_payload_failure(
  layouts : PlannedModuleTypeLayouts,
  owner : VariantId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> FragmentPayloadFailure {
  {
    code,
    phase: 4,
    module_id: layouts.module_id,
    declaration: owner,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
fn check_fragment_payload_index(
  layouts : PlannedModuleTypeLayouts,
  owner : VariantId,
  payload : HirSpan,
  index : Int,
) -> Result[Int, FragmentPayloadFailure] {
  let length = layouts.payload_types.length()
  if layouts.payload_shapes.length() != length {
    return Err(
      fragment_payload_failure(
        layouts,
        owner,
        103,
        length.to_uint64(),
        layouts.payload_shapes.length().to_uint64(),
        1UL,
      ),
    )
  }
  if payload.start < 0 ||
    payload.length < 0 ||
    payload.start > length ||
    payload.length > length - payload.start {
    return Err(
      fragment_payload_failure(
        layouts,
        owner,
        101,
        length.to_uint64(),
        payload.length.reinterpret_as_uint().to_uint64(),
        (1UL << 32) | payload.start.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  if index < 0 || index >= payload.length {
    return Err(
      fragment_payload_failure(
        layouts,
        owner,
        403,
        payload.length.to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
        payload.start.to_uint64(),
      ),
    )
  }
  Ok(payload.start + index)
}

///|
fn assert_fragment_payload_index(
  layouts : PlannedModuleTypeLayouts,
  owner : VariantId,
  payload : HirSpan,
  index : Int,
) -> Int {
  match check_fragment_payload_index(layouts, owner, payload, index) {
    Ok(slot) => slot
    Err(failure) =>
      abort("fragment payload invariant failure: " + @debug.to_string(failure))
  }
}
