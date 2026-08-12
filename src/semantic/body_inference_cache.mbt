///|
let body_inference_cache_magic : Bytes = b"DEW_INFERRED_MODULE_BODIES_V1\x00"

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
