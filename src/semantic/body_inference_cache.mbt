///|
let body_inference_cache_magic : Bytes = b"DEW_INFERRED_MODULE_BODIES_V1\x00"

///|
let body_inference_family_cache_magic : Bytes = b"DEW_INFERRED_BODY_FAMILY_V1\x00"

///|
let body_inference_family_bundle_magic : Bytes = b"DEW_INFERRED_BODY_FAMILY_BUNDLE_V1\x00"

///|
pub struct BodyInferenceFamilyBundleEntry {
  fingerprint : String
  artifact : BodyInferenceFamilyArtifact
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct BodyInferenceFamilyBundle {
  module_id : ModuleId
  entries : Array[BodyInferenceFamilyBundleEntry]
} derive(Eq, Debug, ToJson, FromJson)

///|
fn body_inference_family_fingerprint_is_valid(value : String) -> Bool {
  let bytes = @utf8.encode(value)
  if bytes.length() != 64 {
    return false
  }
  for byte in bytes {
    if !((byte >= b'0' && byte <= b'9') || (byte >= b'a' && byte <= b'f')) {
      return false
    }
  }
  true
}

///|
fn validate_body_inference_family_bundle(
  bundle : BodyInferenceFamilyBundle,
) -> Result[Unit, String] {
  for index, entry in bundle.entries {
    if !body_inference_family_fingerprint_is_valid(entry.fingerprint) {
      return Err("body-family bundle contains an invalid fingerprint")
    }
    if entry.artifact.module_id != bundle.module_id {
      return Err("body-family bundle artifact ownership mismatch")
    }
    if index > 0 && bundle.entries[index - 1].fingerprint >= entry.fingerprint {
      return Err("body-family bundle entries are unordered or duplicated")
    }
  }
  Ok(())
}

///|
pub fn make_body_inference_family_bundle(
  module_id : ModuleId,
  fingerprints : Array[String],
  artifacts : Array[BodyInferenceFamilyArtifact],
) -> Result[BodyInferenceFamilyBundle, String] {
  if fingerprints.length() != artifacts.length() {
    return Err("body-family bundle input length mismatch")
  }
  let entries : Array[BodyInferenceFamilyBundleEntry] = []
  for index, fingerprint in fingerprints {
    if !body_inference_family_fingerprint_is_valid(fingerprint) {
      return Err("body-family bundle contains an invalid fingerprint")
    }
    if artifacts[index].module_id != module_id {
      return Err("body-family bundle artifact ownership mismatch")
    }
    entries.push({ fingerprint, artifact: artifacts[index] })
  }
  entries.sort_by(fn(left, right) {
    left.fingerprint.compare(right.fingerprint)
  })
  for index in 1..<entries.length() {
    if entries[index - 1].fingerprint == entries[index].fingerprint {
      return Err("body-family bundle contains duplicate fingerprints")
    }
  }
  let bundle = { module_id, entries }
  match validate_body_inference_family_bundle(bundle) {
    Ok(_) => Ok(bundle)
    Err(error) => Err(error)
  }
}

///|
/// Serializes one complete module inference result. The persistent cache layer
/// owns provenance, checksums, and atomic publication; this private payload owns
/// only the deterministic inferred-body schema.
pub fn serialize_inferred_module_bodies(
  inferred : InferredModuleBodies,
) -> Result[Bytes, String] {
  let output = Buffer()
  output.write_bytes(body_inference_cache_magic)
  output.write_string_utf8(inferred.to_json().stringify())
  Ok(output.to_bytes())
}

///|
/// Decodes one previously validated inferred-body payload. Unsupported,
/// malformed, schema-incompatible, or trailing JSON fails visibly.
pub fn deserialize_inferred_module_bodies(
  payload : Bytes,
) -> Result[InferredModuleBodies, String] {
  if payload.length() < body_inference_cache_magic.length() {
    return Err("truncated body-inference payload header")
  }
  for index in 0..<body_inference_cache_magic.length() {
    if payload[index] != body_inference_cache_magic[index] {
      return Err("unsupported body-inference payload version")
    }
  }
  let body = Buffer(
    size_hint=payload.length() - body_inference_cache_magic.length(),
  )
  for index in body_inference_cache_magic.length()..<payload.length() {
    body.write_byte(payload[index])
  }
  let text = @utf8.decode(body.to_bytes()) catch {
    _ => return Err("body-inference payload is not UTF-8")
  }
  let json = @json.parse(text) catch {
    error => return Err("body-inference payload is not valid JSON: \{error}")
  }
  let inferred : InferredModuleBodies = @json.from_json(json) catch {
    error => return Err("body-inference payload schema mismatch: \{error}")
  }
  Ok(inferred)
}

///|
pub fn serialize_body_inference_family_artifact(
  artifact : BodyInferenceFamilyArtifact,
) -> Result[Bytes, String] {
  let output = Buffer()
  output.write_bytes(body_inference_family_cache_magic)
  output.write_string_utf8(artifact.to_json().stringify())
  Ok(output.to_bytes())
}

///|
pub fn deserialize_body_inference_family_artifact(
  payload : Bytes,
) -> Result[BodyInferenceFamilyArtifact, String] {
  if payload.length() < body_inference_family_cache_magic.length() {
    return Err("truncated body-family inference payload header")
  }
  for index in 0..<body_inference_family_cache_magic.length() {
    if payload[index] != body_inference_family_cache_magic[index] {
      return Err("unsupported body-family inference payload version")
    }
  }
  let body = Buffer(
    size_hint=payload.length() - body_inference_family_cache_magic.length(),
  )
  for index in body_inference_family_cache_magic.length()..<payload.length() {
    body.write_byte(payload[index])
  }
  let text = @utf8.decode(body.to_bytes()) catch {
    _ => return Err("body-family inference payload is not UTF-8")
  }
  let json = @json.parse(text) catch {
    error =>
      return Err("body-family inference payload is not valid JSON: \{error}")
  }
  let artifact : BodyInferenceFamilyArtifact = @json.from_json(json) catch {
    error =>
      return Err("body-family inference payload schema mismatch: \{error}")
  }
  Ok(artifact)
}

///|
pub fn serialize_body_inference_family_bundle(
  bundle : BodyInferenceFamilyBundle,
) -> Result[Bytes, String] {
  let output = Buffer()
  output.write_bytes(body_inference_family_bundle_magic)
  output.write_string_utf8(bundle.to_json().stringify())
  Ok(output.to_bytes())
}

///|
pub fn deserialize_body_inference_family_bundle(
  payload : Bytes,
) -> Result[BodyInferenceFamilyBundle, String] {
  if payload.length() < body_inference_family_bundle_magic.length() {
    return Err("truncated body-family bundle payload header")
  }
  for index in 0..<body_inference_family_bundle_magic.length() {
    if payload[index] != body_inference_family_bundle_magic[index] {
      return Err("unsupported body-family bundle payload version")
    }
  }
  let body = Buffer(
    size_hint=payload.length() - body_inference_family_bundle_magic.length(),
  )
  for index in body_inference_family_bundle_magic.length()..<payload.length() {
    body.write_byte(payload[index])
  }
  let text = @utf8.decode(body.to_bytes()) catch {
    _ => return Err("body-family bundle payload is not UTF-8")
  }
  let json = @json.parse(text) catch {
    error =>
      return Err("body-family bundle payload is not valid JSON: \{error}")
  }
  let bundle : BodyInferenceFamilyBundle = @json.from_json(json) catch {
    error => return Err("body-family bundle payload schema mismatch: \{error}")
  }
  match validate_body_inference_family_bundle(bundle) {
    Ok(_) => Ok(bundle)
    Err(error) => Err(error)
  }
}
