///|
test "interface bundle envelope preserves payload and rejects corruption" {
  let payload = b"frozen interfaces"
  assert_eq(
    unwrap_interface_cache_payload(wrap_interface_cache_payload(payload)),
    Ok(payload),
  )
  match unwrap_interface_cache_payload(b"bad") {
    Err(error) =>
      assert_eq(error, "truncated standard-interface cache envelope")
    Ok(_) => fail("expected corrupt cache envelope")
  }
}

///|
test "interface bundle policy selects standard and dependency modules explicitly" {
  let program = @semantic.collect_program_manifest(
    23000UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("dep.value", [
        @semantic.ManifestFile::new(
          "dep.dew", b"pub fn value() -> I32 {\n  1\n}\n",
        ),
      ]),
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"open dep.value\npub fn run() -> I32 {\n  value()\n}\n",
        ),
      ]),
    ]),
  )
  let policy : InterfaceBundlePolicy = {
    enabled: true,
    store_on_miss: true,
    root_module_index: 1,
    include_dependencies: true,
  }
  assert_true(interface_bundle_module_is_cacheable(program, 0, policy))
  assert_false(interface_bundle_module_is_cacheable(program, 1, policy))
  for index in 2..<program.modules.length() {
    assert_true(interface_bundle_module_is_cacheable(program, index, policy))
  }
}

///|
test "interface bundle cache key includes dependency provenance" {
  let base : StandardLibraryLoad = {
    sources: @semantic.StandardLibrarySources::bootstrap(),
    fingerprint: "standard",
    dependency_fingerprint: "",
    cacheable: true,
  }
  let dependency = { ..base, dependency_fingerprint: "dependency" }
  assert_eq(interface_bundle_cache_key(base).fingerprint, "standard")
  assert_true(interface_bundle_cache_key(dependency).fingerprint != "standard")
}
