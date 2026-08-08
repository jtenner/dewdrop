///|
test "frozen interfaces serialize and decode byte-identically" {
  let program = collect_program_manifest(
    7750UL,
    ProgramManifest::new([
      ManifestModule::new("cache.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\npub trait LocalBound {\n  fn accept(self) -> Bool\n}\npub struct Item {\n  text: String\n}\npub fn keep(value: Option<U32>) -> Option<U32> {\n  value\n}\npub fn passthrough(callback: fn(I32) -> I64) -> fn(I32) -> I64 {\n  callback\n}\npub fn bounded<t: LocalBound>(value: t) -> t {\n  value\n}\npub struct Box<t> {\n  value: t\n}\nimpl<t: LocalBound> LocalBound for Box<t> {\n  fn accept(self) -> Bool {\n    true\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let mut bounded_implementations = 0
  for implementation in frozen.interfaces[0].implementations {
    if implementation.generic_parameters.length > 0 {
      bounded_implementations += 1
      assert_eq(implementation.generic_parameters.length, 1)
    }
  }
  assert_eq(bounded_implementations, 1)
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  let decoded = deserialize_frozen_interfaces(encoded).unwrap()
  assert_eq(decoded, frozen.interfaces)
  assert_eq(serialize_frozen_interfaces(decoded).unwrap(), encoded)
  let cached : Array[FrozenModuleInterface?] = Array::make(
    program.modules.length(),
    None,
  )
  for index, interface_ in decoded {
    if interface_.path.has_prefix("dew.std.") {
      cached[index] = Some(interface_)
    }
  }
  assert_eq(
    freeze_program_interfaces_with_cached(program, cached).interfaces,
    frozen.interfaces,
  )
}

///|
test "frozen interface decoder rejects corruption and trailing bytes" {
  assert_true(deserialize_frozen_interfaces(b"bad") is Err(_))
  let oversized = Buffer()
  oversized.write_bytes(frozen_interface_cache_magic)
  cache_write_int(oversized, 0x7fffffff)
  assert_true(deserialize_frozen_interfaces(oversized.to_bytes()) is Err(_))
  let program = collect_program_manifest(
    7751UL,
    ProgramManifest::new([
      ManifestModule::new("cache.main", [
        ManifestFile::new("main.dew", b"pub fn main() -> I32 {\n  1\n}\n"),
      ]),
    ]),
  )
  let encoded = serialize_frozen_interfaces(
    freeze_program_interfaces(program).interfaces,
  ).unwrap()
  let with_trailing = Buffer()
  with_trailing.write_bytes(encoded)
  with_trailing.write_byte(0)
  assert_true(deserialize_frozen_interfaces(with_trailing.to_bytes()) is Err(_))
}
