///|
pub enum RawReferenceOperation {
  RawRefNull
  RawRefIsNull
  RawRefAsNonNull
} derive(Eq, Debug)

///|
fn raw_reference_operation(name : Bytes) -> RawReferenceOperation? {
  match name {
    b"ref_null" => Some(RawRefNull)
    b"ref_is_null" => Some(RawRefIsNull)
    b"ref_as_non_null" => Some(RawRefAsNonNull)
    _ => None
  }
}

///|
fn collect_raw_reference_operations(
  modules : Array[CollectedModule],
) -> Map[DeclId, RawReferenceOperation] {
  let operations : Map[DeclId, RawReferenceOperation] = {}
  for module_ in modules {
    for builtin in module_.builtins {
      match raw_reference_operation(builtin.builtin_name) {
        Some(operation) => operations[builtin.declaration] = operation
        None => ()
      }
    }
  }
  operations
}
