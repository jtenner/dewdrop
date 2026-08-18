///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interfaces serialize and decode byte-identically" {
  let program = collect_program_manifest(
    7750UL,
    ProgramManifest::new([
      ManifestModule::new("cache.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\npub trait LocalBound {\n  fn accept(self) -> Bool\n}\npub struct Item {\n  text: String\n}\npub fn keep(value: Option<U32>) -> Option<U32> {\n  value\n}\npub fn passthrough(callback: fn(I32) -> I64) -> fn(I32) -> I64 {\n  callback\n}\npub fn bounded<t: LocalBound>(value: t) -> t {\n  value\n}\npub fn phantom<t>() -> I32 {\n  1\n}\npub fn explicit() -> I32 {\n  phantom::<Bool>()\n}\npub struct Box<t> {\n  value: t\n}\nimpl<t: LocalBound> LocalBound for Box<t> {\n  fn accept(self) -> Bool {\n    true\n  }\n}\n",
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
  assert_eq(
    frozen.interfaces[0].resolved_types.explicit_call_type_arguments.length(),
    1,
  )
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
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interface cache preserves derived implementation evidence" {
  let program = collect_program_manifest(
    7752UL,
    ProgramManifest::new([
      ManifestModule::new("cache.derived", [
        ManifestFile::new(
          "derived.dew", b"pub struct Box<t> {\n  value: t\n} derive(Eq, Debug, Hash)\n",
        ),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  let decoded = deserialize_frozen_interfaces(encoded).unwrap()
  assert_eq(decoded, frozen.interfaces)
  assert_eq(decoded[0].implementations.length(), 4)
  for implementation in decoded[0].implementations {
    assert_eq(implementation.generic_parameters.length, 1)
    assert_eq(
      decoded[0].generic_parameter_bounds[implementation.generic_parameters.start].length,
      1,
    )
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interface decoder rejects orphan implementation evidence" {
  let program = collect_program_manifest(
    7753UL,
    ProgramManifest::new([
      ManifestModule::new("cache.orphan", [
        ManifestFile::new(
          "orphan.dew", b"open cache.traits\nopen cache.types\nimpl Read for Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
        ),
      ]),
      ManifestModule::new("cache.traits", [
        ManifestFile::new(
          "traits.dew", b"pub trait Read {\n  fn read(self) -> I32\n}\n",
        ),
      ]),
      ManifestModule::new("cache.types", [
        ManifestFile::new("types.dew", b"pub struct Item {}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  assert_eq(frozen.interfaces[0].implementations.length(), 0)
  let collected = program.modules[0]
  let implementation_index = collected.impls.length() - 1
  let implementation = collected.impls[implementation_index]
  frozen.interfaces[0].implementations.push({
    declaration: implementation.declaration,
    generic_parameters: collected.generic_parameters_of(
      implementation.declaration,
    ),
    trait_type: frozen.interfaces[0].resolved_types.impl_trait_types[implementation_index],
    target_type: frozen.interfaces[0].resolved_types.impl_target_types[implementation_index],
    location: collected
    .declaration_location(implementation.declaration)
    .unwrap(),
  })
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  assert_eq(
    deserialize_frozen_interfaces(encoded),
    Err("frozen-interface cache contains orphan implementation evidence"),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interface decoder rejects invalid implementation type IDs" {
  let program = collect_program_manifest(
    7754UL,
    ProgramManifest::new([
      ManifestModule::new("cache.invalid_impl", [
        ManifestFile::new("main.dew", b"pub fn main() -> I32 {\n  1\n}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let declaration = frozen.interfaces[0].declarations[0]
  let invalid_type = frozen.interfaces[0].resolved_types.types.length()
  frozen.interfaces[0].implementations.push({
    declaration: declaration.declaration,
    generic_parameters: { start: 0, length: 0 },
    trait_type: invalid_type,
    target_type: invalid_type,
    location: declaration.location,
  })
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  assert_eq(
    deserialize_frozen_interfaces(encoded),
    Err("frozen-interface cache contains invalid implementation evidence"),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interface decoder rejects cyclic implementation heads" {
  let program = collect_program_manifest(
    7755UL,
    ProgramManifest::new([
      ManifestModule::new("cache.cyclic_impl", [
        ManifestFile::new("main.dew", b"pub fn main() -> I32 {\n  1\n}\n"),
      ]),
    ]),
  )
  let frozen = freeze_program_interfaces(program)
  let declaration = frozen.interfaces[0].declarations[0]
  let cyclic_type = frozen.interfaces[0].resolved_types.types.length()
  frozen.interfaces[0].resolved_types.types.push(
    AppliedType(cyclic_type, { start: 0, length: 0 }),
  )
  frozen.interfaces[0].implementations.push({
    declaration: declaration.declaration,
    generic_parameters: { start: 0, length: 0 },
    trait_type: cyclic_type,
    target_type: cyclic_type,
    location: declaration.location,
  })
  let encoded = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  assert_eq(
    deserialize_frozen_interfaces(encoded),
    Err("frozen-interface cache contains invalid implementation evidence"),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "frozen interface decoder rejects sampled corruption and trailing bytes" {
  assert_true(deserialize_frozen_interfaces(b"bad") is Err(_))
  let oversized = @cache_binary.Writer::new()
  oversized.write_raw(frozen_interface_cache_magic)
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
  let cuts = [
    0,
    1,
    2,
    3,
    encoded.length() / 4,
    encoded.length() / 2,
    encoded.length() * 3 / 4,
    encoded.length() - 1,
  ]
  for cut in cuts {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(encoded[index])
    }
    assert_true(deserialize_frozen_interfaces(truncated.to_bytes()) is Err(_))
  }
  for iteration in 0..<16 {
    let selected = (iteration * 3571 + 23) % encoded.length()
    let mutated = Buffer(size_hint=encoded.length())
    for index in 0..<encoded.length() {
      mutated.write_byte(
        if index == selected {
          encoded[index] ^ 0x20
        } else {
          encoded[index]
        },
      )
    }
    let mutated = mutated.to_bytes()
    match deserialize_frozen_interfaces(mutated) {
      Ok(value) =>
        assert_eq(serialize_frozen_interfaces(value).unwrap(), mutated)
      Err(_) => ()
    }
  }
  let with_trailing = Buffer()
  with_trailing.write_bytes(encoded)
  with_trailing.write_byte(0)
  assert_true(deserialize_frozen_interfaces(with_trailing.to_bytes()) is Err(_))
}
