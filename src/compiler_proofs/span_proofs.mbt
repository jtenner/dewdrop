///|
/// Keep one proved carrier from source through emission.
pub fn proven_physical_carrier(
  source : Int,
  planned : Int,
  emitted : Int,
) -> Int where {
  proof_require: certified_carrier_path(source, planned, emitted),
  proof_ensure: result => valid_physical_carrier(result),
  proof_ensure: result => result == source,
  proof_ensure: result => result == planned,
  proof_ensure: result => result == emitted,
} {
  source
}

///|
/// Get the exclusive end of a valid arena span.
pub fn proven_span_end(
  start : Int,
  length : Int,
) -> Int where {
  proof_require: 0 <= start,
  proof_require: 0 <= length,
  proof_ensure: result => result >= start,
  proof_ensure: result => result >= length,
  proof_ensure: result => result == start + length,
} {
  start + length
}
