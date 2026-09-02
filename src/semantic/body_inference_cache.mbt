///|
pub struct BodyInferenceFamilyBundleEntry {
  fingerprint : String
  artifact : BodyInferenceFamilyArtifact
} derive(Eq, Debug)

///|
pub struct BodyInferenceFamilyBundle {
  module_id : ModuleId
  entries : Array[BodyInferenceFamilyBundleEntry]
} derive(Eq, Debug)

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
    entries.push({ fingerprint, artifact: artifacts[index], })
  }
  entries.sort_by(fn(left, right) {
    left.fingerprint.compare(right.fingerprint)
  })
  for index in 1..<entries.length() {
    if entries[index - 1].fingerprint == entries[index].fingerprint {
      return Err("body-family bundle contains duplicate fingerprints")
    }
  }
  let bundle = { module_id, entries, }
  match validate_body_inference_family_bundle(bundle) {
    Ok(_) => Ok(bundle)
    Err(error) => Err(error)
  }
}
