///|
/// Parser-event persistent artifact kind and V1 envelope schema.
let parse_event_artifact_kind = 1

///|
let parse_event_envelope_version = 1U

///|
fn wrap_parse_event_cache_payload(
  key_digest : FixedArray[Byte],
  source_digest : FixedArray[Byte],
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    parse_event_artifact_kind,
    parse_event_envelope_version,
    [key_digest, source_digest],
    payload,
  )
}

///|
fn unwrap_parse_event_cache_payload(
  bytes : Bytes,
  expected_key_digest : FixedArray[Byte],
  expected_source_digest : FixedArray[Byte],
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    parse_event_artifact_kind,
    parse_event_envelope_version,
    [expected_key_digest, expected_source_digest],
  )
}
