///|
test "module inference cache rejects a trait target outside the resolved arena" {
  let program = @semantic.collect_program_manifest(
    23803UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("trait.cache", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Read {\n fn read(self) -> I32\n}\nstruct Value {}\nimpl Read for Value {\n fn read(self) -> I32 {\n 42i32\n }\n}\nfn invoke(value: Read) -> I32 {\n value.read()\n}\nfn main() -> I32 {\n invoke(Value::{})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let module_ = analyzed.modules[0]
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  assert_eq(module_.inferred.diagnostics, [])
  let mut found = false
  for coercion in module_.inferred.trait_object_coercions {
    if coercion
      is @semantic.SelectedInferredTraitObjectCoercion(
        trait_,
        evidence,
        expected
      ) {
      found = true
      for bad in [-resolved.types.length() - 2, -2147483648] {
        let token = fn(type_) {
          let writer = @cache_binary.Writer::new()
          writer.write_byte(2)
          writer.write_u64_le(trait_)
          writer.write_zigzag_int(evidence)
          writer.write_zigzag_int(type_)
          writer.to_bytes()
        }
        let original = token(expected)
        let encoded = @semantic.serialize_inferred_module_bodies(
          module_.inferred,
        ).unwrap()
        let matches = []
        for start in 0..<(encoded.length() - original.length() + 1) {
          let mut same = true
          for index in 0..<original.length() {
            if encoded[start + index] != original[index] {
              same = false
              break
            }
          }
          if same {
            matches.push(start)
          }
        }
        assert_eq(matches.length(), 1)
        let changed = @cache_binary.Writer::new()
        changed.write_raw(encoded[:matches[0]].to_owned())
        changed.write_raw(token(bad))
        changed.write_raw(encoded[matches[0] + original.length():].to_owned())
        // Negative IDs need the resolved arena, which the raw codec does not own.
        let decoded = @semantic.deserialize_inferred_module_bodies(
          changed.to_bytes(),
        ).unwrap()
        assert_true(
          validate_cached_inferred_module(
            program.modules[0],
            resolved,
            module_.imports,
            module_.names,
            decoded,
          )
          is Err(_),
        )
      }
    }
  }
  assert_true(found)
}

///|
test "body-inference cache envelope verifies checksum and provenance" {
  let key = @crypto.sha256(b"key")
  let source = @crypto.sha256(b"source")
  let interface_ = @crypto.sha256(b"interface")
  let payload = b"payload"
  let wrapped = wrap_body_inference_cache_payload(
    key, source, interface_, payload,
  ).unwrap()
  assert_eq(
    unwrap_body_inference_cache_payload(wrapped, key, source, interface_).unwrap(),
    payload,
  )
  for cut in 0..<wrapped.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(wrapped[index])
    }
    assert_true(
      unwrap_body_inference_cache_payload(
        truncated.to_bytes(),
        key,
        source,
        interface_,
      )
      is Err(_),
    )
  }
  for selected in 0..<wrapped.length() {
    let mutated = Buffer(size_hint=wrapped.length())
    for index in 0..<wrapped.length() {
      mutated.write_byte(
        if index == selected {
          wrapped[index] ^ 0x80
        } else {
          wrapped[index]
        },
      )
    }
    assert_true(
      unwrap_body_inference_cache_payload(
        mutated.to_bytes(),
        key,
        source,
        interface_,
      )
      is Err(_),
    )
  }
  let changed = @crypto.sha256(b"changed")
  match unwrap_body_inference_cache_payload(wrapped, key, source, changed) {
    Err(error) => assert_true(error.contains("provenance mismatch"))
    Ok(_) => fail("expected interface provenance mismatch")
  }
  let corrupt = Buffer()
  for index in 0..<(wrapped.length() - 1) {
    corrupt.write_byte(wrapped[index])
  }
  corrupt.write_byte(b'x')
  match
    unwrap_body_inference_cache_payload(
      corrupt.to_bytes(),
      key,
      source,
      interface_,
    ) {
    Err(error) => assert_true(error.contains("checksum mismatch"))
    Ok(_) => fail("expected checksum mismatch")
  }
  let family = wrap_body_inference_family_cache_payload(
    key, source, interface_, payload,
  ).unwrap()
  assert_eq(
    unwrap_body_inference_family_cache_payload(family, key, source, interface_).unwrap(),
    payload,
  )
  for cut in 0..<family.length() {
    let truncated = Buffer(size_hint=cut)
    for index in 0..<cut {
      truncated.write_byte(family[index])
    }
    assert_true(
      unwrap_body_inference_family_cache_payload(
        truncated.to_bytes(),
        key,
        source,
        interface_,
      )
      is Err(_),
    )
  }
  for selected in 0..<family.length() {
    let mutated = Buffer(size_hint=family.length())
    for index in 0..<family.length() {
      mutated.write_byte(
        if index == selected {
          family[index] ^ 0x40
        } else {
          family[index]
        },
      )
    }
    assert_true(
      unwrap_body_inference_family_cache_payload(
        mutated.to_bytes(),
        key,
        source,
        interface_,
      )
      is Err(_),
    )
  }
  match
    unwrap_body_inference_family_cache_payload(
      family, changed, source, interface_,
    ) {
    Err(error) => assert_true(error.contains("provenance mismatch"))
    Ok(_) => fail("expected body-family key mismatch")
  }
}

///|
test "body-inference cache keys include exact source and interface evidence" {
  let program = @semantic.collect_program_manifest(
    23110UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.body", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub fn main() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
  )
  let frozen = @semantic.freeze_program_interfaces(program)
  let (key, key_digest, source, interface_) = body_inference_cache_key(
    program, frozen, 0,
  ).unwrap()
  assert_eq(key, @crypto.bytes_to_hex_string(key_digest))
  let changed_program = @semantic.collect_program_manifest(
    23110UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.body", [
        @semantic.ManifestFile::new(
          "main.dew", b"pub fn main() -> I32 {\n  2\n}\n",
        ),
      ]),
    ]),
  )
  let changed_frozen = @semantic.freeze_program_interfaces(changed_program)
  let (changed_key, _, changed_source, changed_interface) = body_inference_cache_key(
    changed_program, changed_frozen, 0,
  ).unwrap()
  assert_true(changed_key != key)
  assert_true(changed_source != source)
  assert_eq(changed_interface, interface_)
}

///|
test "body-inference pack entries match the persisted final interface state" {
  let prior_body = @sys.get_env_var("DEW_BODY_CACHE").unwrap_or("")
  let prior_family = @sys.get_env_var("DEW_BODY_FAMILY_CACHE").unwrap_or("")
  let prior_compiler = @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or(
    "",
  )
  @sys.set_env_var("DEW_BODY_CACHE", "1")
  @sys.set_env_var("DEW_BODY_FAMILY_CACHE", "0")
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", "body-final-interface-test")
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("main", [
      @semantic.ManifestFile::new(
        "main.dew", b"pub fn main() -> I32 {\n  1\n}\n",
      ),
    ]),
  ])
  let loaded : StandardLibraryLoad = {
    sources: @semantic.StandardLibrarySources::bootstrap(),
    fingerprint: "body-final-interface-standard",
    dependency_fingerprint: "",
    cacheable: true,
  }
  let program = @semantic.collect_program_manifest_with_standard_sources(
    23113UL,
    manifest,
    loaded.sources,
    true,
  )
  let session = program_output_test_session()
  let cold = analyze_program_with_interface_bundle_cache(
    program,
    loaded,
    pack=Some(session),
  ).unwrap()
  assert_true(cold.body_cache_status.misses > 0)
  let warm = analyze_program_with_interface_bundle_cache(
    program,
    loaded,
    pack=Some(session),
  ).unwrap()
  assert_eq(warm.body_cache_status.hits, program.modules.length())
  assert_eq(warm.body_cache_status.misses, 0)
  @sys.set_env_var("DEW_BODY_CACHE", prior_body)
  @sys.set_env_var("DEW_BODY_FAMILY_CACHE", prior_family)
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", prior_compiler)
}

///|
test "body-family cache keys isolate private declaration edits" {
  let original = @semantic.collect_program_manifest(
    23111UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.family", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn first() -> I32 {\n  1\n}\nfn changed() -> I32 {\n  2\n}\npub fn later() -> I32 {\n  first() + 3\n}\n",
        ),
      ]),
    ]),
  )
  let edited = @semantic.collect_program_manifest(
    23111UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.family", [
        @semantic.ManifestFile::new(
          "main.dew", b"fn first() -> I32 {\n  1\n}\nfn changed() -> I32 {\n  if true {\n    20\n  } else {\n    2\n  }\n}\npub fn later() -> I32 {\n  first() + 3\n}\n",
        ),
      ]),
    ]),
  )
  let original_keys = body_inference_family_cache_keys(
    original,
    @semantic.freeze_program_interfaces(original),
    0,
  ).unwrap()
  let edited_keys = body_inference_family_cache_keys(
    edited,
    @semantic.freeze_program_interfaces(edited),
    0,
  ).unwrap()
  assert_eq(original_keys.length(), 3)
  assert_eq(
    original_keys[0].unwrap().fingerprint,
    edited_keys[0].unwrap().fingerprint,
  )
  assert_true(
    original_keys[1].unwrap().fingerprint != edited_keys[1].unwrap().fingerprint,
  )
  assert_eq(
    original_keys[2].unwrap().fingerprint,
    edited_keys[2].unwrap().fingerprint,
  )
}

///|
test "body-family cache keys include lambda families and module values" {
  let original = @semantic.collect_program_manifest(
    23112UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.family", [
        @semantic.ManifestFile::new(
          "main.dew", b"let base = 1\nfn owner() -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + base\n  }\n  apply(1)\n}\nfn independent() -> I32 {\n  42\n}\n",
        ),
      ]),
    ]),
  )
  let changed_lambda = @semantic.collect_program_manifest(
    23112UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.family", [
        @semantic.ManifestFile::new(
          "main.dew", b"let base = 1\nfn owner() -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + base + 1\n  }\n  apply(1)\n}\nfn independent() -> I32 {\n  42\n}\n",
        ),
      ]),
    ]),
  )
  let changed_value = @semantic.collect_program_manifest(
    23112UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.family", [
        @semantic.ManifestFile::new(
          "main.dew", b"let base = 2\nfn owner() -> I32 {\n  let apply = fn(value: I32) -> I32 {\n    value + base\n  }\n  apply(1)\n}\nfn independent() -> I32 {\n  42\n}\n",
        ),
      ]),
    ]),
  )
  let original_keys = body_inference_family_cache_keys(
    original,
    @semantic.freeze_program_interfaces(original),
    0,
  ).unwrap()
  let lambda_keys = body_inference_family_cache_keys(
    changed_lambda,
    @semantic.freeze_program_interfaces(changed_lambda),
    0,
  ).unwrap()
  let value_keys = body_inference_family_cache_keys(
    changed_value,
    @semantic.freeze_program_interfaces(changed_value),
    0,
  ).unwrap()
  assert_true(
    original_keys[1].unwrap().fingerprint != lambda_keys[1].unwrap().fingerprint,
  )
  assert_eq(
    original_keys[2].unwrap().fingerprint,
    lambda_keys[2].unwrap().fingerprint,
  )
  assert_true(
    original_keys[1].unwrap().fingerprint != value_keys[1].unwrap().fingerprint,
  )
  assert_true(
    original_keys[2].unwrap().fingerprint != value_keys[2].unwrap().fingerprint,
  )
}

///|
test "body-inference dependency evidence ignores private bodies and tracks public identities" {
  let private_program = @semantic.collect_program_manifest(
    23120UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.dep", [
        @semantic.ManifestFile::new(
          "dep.dew", b"fn hidden() -> I32 {\n  1\n}\npub fn value() -> I32 {\n  42\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("cache.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open cache.dep\npub fn main() -> I32 {\n  value()\n}\n",
        ),
      ]),
    ]),
  )
  let changed_private_program = @semantic.collect_program_manifest(
    23120UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.dep", [
        @semantic.ManifestFile::new(
          "dep.dew", b"fn hidden() -> I32 {\n  2\n}\npub fn value() -> I32 {\n  42\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("cache.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open cache.dep\npub fn main() -> I32 {\n  value()\n}\n",
        ),
      ]),
    ]),
  )
  let public_program = @semantic.collect_program_manifest(
    23120UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("cache.dep", [
        @semantic.ManifestFile::new(
          "dep.dew", b"pub fn added() -> I32 {\n  1\n}\npub fn value() -> I32 {\n  42\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("cache.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open cache.dep\npub fn main() -> I32 {\n  value()\n}\n",
        ),
      ]),
    ]),
  )
  let private_frozen = @semantic.freeze_program_interfaces(private_program)
  let changed_private_frozen = @semantic.freeze_program_interfaces(
    changed_private_program,
  )
  let public_frozen = @semantic.freeze_program_interfaces(public_program)
  assert_eq(
    body_inference_interface_digest(private_frozen, 1).unwrap(),
    body_inference_interface_digest(changed_private_frozen, 1).unwrap(),
  )
  assert_true(
    body_inference_interface_digest(private_frozen, 1).unwrap() !=
    body_inference_interface_digest(public_frozen, 1).unwrap(),
  )
  let private_keys = body_inference_family_cache_keys(
    private_program, private_frozen, 1,
  ).unwrap()
  let changed_private_keys = body_inference_family_cache_keys(
    changed_private_program, changed_private_frozen, 1,
  ).unwrap()
  let public_keys = body_inference_family_cache_keys(
    public_program, public_frozen, 1,
  ).unwrap()
  assert_eq(
    private_keys[0].unwrap().fingerprint,
    changed_private_keys[0].unwrap().fingerprint,
  )
  assert_true(
    private_keys[0].unwrap().fingerprint != public_keys[0].unwrap().fingerprint,
  )
}
