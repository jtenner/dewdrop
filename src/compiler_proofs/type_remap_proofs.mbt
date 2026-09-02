///|
/// Get the new index of one retained type after dense compaction.
///
/// The caller must count only removed types that occur before this type.
pub fn proven_dense_type_index(
  old_index : Int,
  removed_before : Int,
) -> Int where {
  proof_require: 0 <= removed_before,
  proof_require: removed_before <= old_index,
  proof_ensure: result => result == old_index - removed_before,
  proof_ensure: result => 0 <= result,
  proof_ensure: result => result <= old_index,
} {
  old_index - removed_before
}
