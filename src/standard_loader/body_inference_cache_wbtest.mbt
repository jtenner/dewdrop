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
}
