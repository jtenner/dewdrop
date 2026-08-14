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
  let changed = @crypto.sha256(b"changed")
  match unwrap_body_inference_cache_payload(wrapped, key, source, changed) {
    Err(error) =>
      assert_eq(error, "body-inference cache interface provenance mismatch")
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
    Err(error) => assert_eq(error, "body-inference cache checksum mismatch")
    Ok(_) => fail("expected checksum mismatch")
  }
  let family = wrap_body_inference_family_cache_payload(
    key, source, interface_, payload,
  ).unwrap()
  assert_eq(
    unwrap_body_inference_family_cache_payload(family, key, source, interface_).unwrap(),
    payload,
  )
  match
    unwrap_body_inference_family_cache_payload(
      family, changed, source, interface_,
    ) {
    Err(error) => assert_eq(error, "body-family cache key provenance mismatch")
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
