///|
/// Persistent type-layout and WasmGC-fragment artifact kinds.
let type_layout_artifact_kind = 8

///|
let wasmgc_fragment_artifact_kind = 9

///|
let type_layout_envelope_version = 1U

///|
let wasmgc_fragment_envelope_version = 1U

///|
fn wrap_type_layout_cache_payload(
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    type_layout_artifact_kind,
    type_layout_envelope_version,
    [key, source, interface_],
    payload,
  )
}

///|
fn unwrap_type_layout_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    type_layout_artifact_kind,
    type_layout_envelope_version,
    [key, source, interface_],
  )
}

///|
fn wrap_wasmgc_fragment_cache_payload(
  key : FixedArray[Byte],
  module_source : FixedArray[Byte],
  program_context : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    wasmgc_fragment_artifact_kind,
    wasmgc_fragment_envelope_version,
    [key, module_source, program_context],
    payload,
  )
}

///|
fn unwrap_wasmgc_fragment_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  module_source : FixedArray[Byte],
  program_context : FixedArray[Byte],
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    wasmgc_fragment_artifact_kind,
    wasmgc_fragment_envelope_version,
    [key, module_source, program_context],
  )
}
