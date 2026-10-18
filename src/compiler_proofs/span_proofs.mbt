///|
/// Keep one proved carrier from source through emission.
pub fn proven_physical_carrier(
  source : Int32,
  planned : Int32,
  emitted : Int32,
) -> Int32 where {
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
  start : Int32,
  length : Int32,
) -> Int32 where {
  proof_require: 0 <= start,
  proof_require: 0 <= length,
  proof_require: length <= 2147483647 - start,
  proof_ensure: result => result >= start,
  proof_ensure: result => result >= length,
  proof_ensure: result => result == start + length,
} {
  start + length
}
