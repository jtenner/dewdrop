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

///|
test "body-family artifacts round trip and mix cached and fresh jobs" {
  let original = collect_bytes(
    23101UL, b"fn first() -> I32 {\n  1\n}\nfn changed() -> I32 {\n  2\n}\nfn later() -> I32 {\n  first() + 3\n}\n",
  )
  let original_resolved = resolve_module_types(original)
  let original_names = resolve_module_names(original)
  let cold = infer_module_bodies_with_family_cache(
    original,
    original_resolved,
    original_names,
    Array::make(original.bodies.length(), None),
  ).unwrap()
  assert_eq(cold.family_hits, 0)
  assert_eq(cold.family_misses, 3)
  let encoded = serialize_body_inference_family_artifact(
    cold.families[2].unwrap(),
  ).unwrap()
  assert_eq(
    deserialize_body_inference_family_artifact(encoded).unwrap(),
    cold.families[2].unwrap(),
  )
  let first_fingerprint = @crypto.bytes_to_hex_string(@crypto.sha256(b"first"))
  let later_fingerprint = @crypto.bytes_to_hex_string(@crypto.sha256(b"later"))
  let bundle = make_body_inference_family_bundle(
    original.module_id,
    [first_fingerprint, later_fingerprint],
    [cold.families[0].unwrap(), cold.families[2].unwrap()],
  ).unwrap()
  let bundle_bytes = serialize_body_inference_family_bundle(bundle).unwrap()
  assert_eq(
    deserialize_body_inference_family_bundle(bundle_bytes).unwrap(),
    bundle,
  )
  assert_true(
    make_body_inference_family_bundle(
      original.module_id,
      [first_fingerprint, first_fingerprint],
      [cold.families[0].unwrap(), cold.families[2].unwrap()],
    )
    is Err(_),
  )

  let edited = collect_bytes(
    23101UL, b"fn first() -> I32 {\n  1\n}\nfn changed() -> I32 {\n  if true {\n    20\n  } else {\n    2\n  }\n}\nfn later() -> I32 {\n  first() + 3\n}\n",
  )
  let edited_resolved = resolve_module_types(edited)
  let edited_names = resolve_module_names(edited)
  let cached : Array[BodyInferenceFamilyArtifact?] = [
    cold.families[0],
    None,
    cold.families[2],
  ]
  let mixed = infer_module_bodies_with_family_cache(
    edited, edited_resolved, edited_names, cached,
  ).unwrap()
  let fresh = infer_module_bodies(edited, edited_resolved, edited_names)
  assert_eq(mixed.family_hits, 2)
  assert_eq(mixed.family_misses, 1)
  assert_eq(mixed.inferred, fresh)
  let reverse = infer_module_bodies_with_family_cache_in_order(
    edited,
    edited_resolved,
    edited_names,
    cached,
    [2, 1, 0],
  ).unwrap()
  let shuffled = infer_module_bodies_with_family_cache_in_order(
    edited,
    edited_resolved,
    edited_names,
    cached,
    [1, 2, 0],
  ).unwrap()
  assert_eq(reverse.inferred, fresh)
  assert_eq(shuffled.inferred, fresh)
  assert_eq(reverse.families, mixed.families)
  assert_eq(shuffled.families, mixed.families)
}

///|
test "cached body families rebase nested lambda and diagnostic expression ids" {
  let original = collect_bytes(
    23103UL, b"fn changing() -> I32 {\n  1\n}\nfn owner(seed: I32) -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + seed\n  }\n  apply(1)\n}\nfn invalid() -> I32 {\n  missing()\n}\n",
  )
  let original_resolved = resolve_module_types(original)
  let original_names = resolve_module_names(original)
  let cold = infer_module_bodies_with_family_cache(
    original,
    original_resolved,
    original_names,
    Array::make(original.bodies.length(), None),
  ).unwrap()
  let edited = collect_bytes(
    23103UL, b"fn changing() -> I32 {\n  if true {\n    10\n  } else {\n    1\n  }\n}\nfn owner(seed: I32) -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + seed\n  }\n  apply(1)\n}\nfn invalid() -> I32 {\n  missing()\n}\n",
  )
  let edited_resolved = resolve_module_types(edited)
  let edited_names = resolve_module_names(edited)
  let cached : Array[BodyInferenceFamilyArtifact?] = [
    None,
    cold.families[1],
    cold.families[2],
  ]
  let mixed = infer_module_bodies_with_family_cache(
    edited, edited_resolved, edited_names, cached,
  ).unwrap()
  let fresh = infer_module_bodies(edited, edited_resolved, edited_names)
  assert_eq(mixed.family_hits, 2)
  assert_eq(mixed.family_misses, 1)
  assert_eq(mixed.inferred, fresh)
  assert_eq(mixed.inferred.diagnostics.length(), 1)
}

///|
test "body-family artifacts include nested lambdas and reject incompatible owners" {
  let collected = collect_bytes(
    23102UL, b"fn owner(seed: I32) -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + seed\n  }\n  apply(1)\n}\nfn independent() -> I32 {\n  42\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let cold = infer_module_bodies_with_family_cache(
    collected,
    resolved,
    names,
    Array::make(collected.bodies.length(), None),
  ).unwrap()
  assert_eq(cold.families[0].unwrap().lambdas.length(), 1)
  let incompatible : Array[BodyInferenceFamilyArtifact?] = [
    cold.families[1],
    cold.families[0],
  ]
  assert_true(
    infer_module_bodies_with_family_cache(
      collected, resolved, names, incompatible,
    )
    is Err(_),
  )
  let owner = cold.families[0].unwrap()
  let invalid_types = owner.root.types.copy()
  invalid_types.push(BodyAppliedType(-2, { start: 999, length: 1 }))
  let invalid_owner = {
    ..owner,
    root: {
      ..owner.root,
      types: invalid_types,
      result_type: invalid_types.length() - 1,
    },
  }
  let corrupt : Array[BodyInferenceFamilyArtifact?] = [
    Some(invalid_owner),
    cold.families[1],
  ]
  assert_true(
    infer_module_bodies_with_family_cache(collected, resolved, names, corrupt)
    is Err(_),
  )
}
