///|
fn program_output_test_session() -> CompilationCachePack {
  {
    enabled: true,
    path: "",
    pack: @cache_binary.ArtifactPack::empty(),
    dirty: false,
    hits: 0,
    misses: 0,
    reads: 0,
  }
}

///|
fn program_output_test_manifest(value : Int) -> @semantic.ProgramManifest {
  @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.main", [
      @semantic.ManifestFile::new(
        "main.dew",
        @utf8.encode("pub fn main() -> I32 {\n  \{value}\n}\n"),
      ),
    ]),
  ])
}

///|
test "exact program pack entries bind source mode dependencies and compiler" {
  let prior_compiler = @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or(
    "",
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", "compiler-a")
  let session = program_output_test_session()
  let first = program_output_test_manifest(1)
  store_program_output_cache(session, first, 0, true, 1, 0, [], [], b"wasm-a").unwrap()
  assert_eq(
    lookup_program_output_cache(session, first, 0, true, 1, 0, [], []).unwrap(),
    Some(b"wasm-a"),
  )
  assert_eq(
    lookup_program_output_cache(
      session,
      program_output_test_manifest(2),
      0,
      true,
      1,
      0,
      [],
      [],
    ).unwrap(),
    None,
  )
  assert_eq(
    lookup_program_output_cache(session, first, 0, false, 1, 0, [], []).unwrap(),
    None,
  )
  assert_eq(
    lookup_program_output_cache(session, first, 0, true, 1, 0, ["dep"], [
      "fingerprint",
    ]).unwrap(),
    None,
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", "compiler-b")
  assert_eq(
    lookup_program_output_cache(session, first, 0, true, 1, 0, [], []).unwrap(),
    None,
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", prior_compiler)
}

///|
test "exact program cache binds static-link provider and Wasm digest" {
  let prior_compiler = @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or(
    "",
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", "compiler-link")
  let session = program_output_test_session()
  let manifest = program_output_test_manifest(1)
  store_program_output_cache(
    session,
    manifest,
    0,
    true,
    1,
    0,
    [],
    [],
    b"linked",
    static_link_providers=["starshine"],
    static_link_modules=[b"guest-a"],
  ).unwrap()
  assert_eq(
    lookup_program_output_cache(
      session,
      manifest,
      0,
      true,
      1,
      0,
      [],
      [],
      static_link_providers=["starshine"],
      static_link_modules=[b"guest-a"],
    ).unwrap(),
    Some(b"linked"),
  )
  assert_eq(
    lookup_program_output_cache(
      session,
      manifest,
      0,
      true,
      1,
      0,
      [],
      [],
      static_link_providers=["starshine"],
      static_link_modules=[b"guest-b"],
    ).unwrap(),
    None,
  )
  assert_eq(
    lookup_program_output_cache(
      session,
      manifest,
      0,
      true,
      1,
      0,
      [],
      [],
      static_link_providers=["other"],
      static_link_modules=[b"guest-a"],
    ).unwrap(),
    None,
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", prior_compiler)
}
