///|
fn body_inference_cache_test_program() -> CollectedProgram {
  collect_program_manifest(
    23100UL,
    ProgramManifest::new([
      ManifestModule::new("cache.body", [
        ManifestFile::new(
          "main.dew", b"pub enum Value {\n  Empty\n  Number(I32)\n}\npub fn read(value: Value) -> I32 {\n  match value {\n    Value.Number(number) => number\n    Value.Empty => 0\n  }\n}\n",
        ),
      ]),
    ]),
  )
}

///|
test "inferred module bodies serialize and decode byte-identically" {
  let program = body_inference_cache_test_program()
  let analyzed = analyze_program_semantics(program)
  let inferred = analyzed.modules[0].inferred
  let encoded = serialize_inferred_module_bodies(inferred).unwrap()
  let decoded = deserialize_inferred_module_bodies(encoded).unwrap()
  assert_eq(decoded, inferred)
  assert_eq(serialize_inferred_module_bodies(decoded).unwrap(), encoded)
}

///|
test "inferred module body decoder rejects malformed payloads" {
  assert_true(deserialize_inferred_module_bodies(b"bad") is Err(_))
  let program = body_inference_cache_test_program()
  let inferred = analyze_program_semantics(program).modules[0].inferred
  let encoded = serialize_inferred_module_bodies(inferred).unwrap()
  let trailing = Buffer()
  trailing.write_bytes(encoded)
  trailing.write_byte(b'x')
  assert_true(deserialize_inferred_module_bodies(trailing.to_bytes()) is Err(_))
}
