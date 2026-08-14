///|
/// Frozen-interface persistent artifact kinds and envelope versions.
let standard_interface_artifact_kind = 2

///|
let workspace_interface_artifact_kind = 3

///|
let standard_interface_envelope_version = 13U

///|
let workspace_interface_envelope_version = 2U

///|
fn interface_cache_key_provenance(key : String) -> FixedArray[Byte] {
  @crypto.sha256(@utf8.encode(key))
}

///|
fn wrap_standard_interface_cache_payload(
  key : String,
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    standard_interface_artifact_kind,
    standard_interface_envelope_version,
    [interface_cache_key_provenance(key)],
    payload,
  )
}

///|
fn unwrap_standard_interface_cache_payload(
  bytes : Bytes,
  key : String,
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    standard_interface_artifact_kind,
    standard_interface_envelope_version,
    [interface_cache_key_provenance(key)],
  )
}

///|
fn wrap_workspace_interface_cache_payload(
  key : String,
  payload : Bytes,
) -> Result[Bytes, String] {
  @cache_binary.wrap_artifact(
    workspace_interface_artifact_kind,
    workspace_interface_envelope_version,
    [interface_cache_key_provenance(key)],
    payload,
  )
}

///|
fn unwrap_workspace_interface_cache_payload(
  bytes : Bytes,
  key : String,
) -> Result[Bytes, String] {
  @cache_binary.unwrap_artifact(
    bytes,
    workspace_interface_artifact_kind,
    workspace_interface_envelope_version,
    [interface_cache_key_provenance(key)],
  )
}
