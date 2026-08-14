///|
/// Complete inferred-module and declaration-family persistent artifact kinds.
let body_inference_artifact_kind = 4

///|
let body_family_artifact_kind = 5

///|
let body_inference_envelope_version = 2U

///|
let body_family_envelope_version = 2U

///|
fn wrap_body_inference_cache_payload(
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    body_inference_artifact_kind,
    body_inference_envelope_version,
    [key, source, interface_],
    payload,
  )
}

///|
fn unwrap_body_inference_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  interface_ : FixedArray[Byte],
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    body_inference_artifact_kind,
    body_inference_envelope_version,
    [key, source, interface_],
  )
}

///|
fn wrap_body_inference_family_cache_payload(
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  context : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    body_family_artifact_kind,
    body_family_envelope_version,
    [key, source, context],
    payload,
  )
}

///|
fn unwrap_body_inference_family_cache_payload(
  bytes : Bytes,
  key : FixedArray[Byte],
  source : FixedArray[Byte],
  context : FixedArray[Byte],
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    body_family_artifact_kind,
    body_family_envelope_version,
    [key, source, context],
  )
}
