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
fn program_output_boundary_collision_manifests() -> (
  @semantic.ProgramManifest,
  @semantic.ProgramManifest,
) {
  let root_source = b"pub fn main() -> I32 { 1 }"
  let boundary = "type Alias = I32"
  let tail_source = b"pub fn tail() -> I32 { 2 }"
  let first = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.main", [
      @semantic.ManifestFile::new("main.dew", root_source),
    ]),
    @semantic.ManifestModule::new("moved.dew", [
      @semantic.ManifestFile::new(boundary, @utf8.encode(boundary)),
      @semantic.ManifestFile::new("tail.dew", tail_source),
    ]),
  ])
  let second = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app.main", [
      @semantic.ManifestFile::new("main.dew", root_source),
      @semantic.ManifestFile::new("moved.dew", @utf8.encode(boundary)),
    ]),
    @semantic.ManifestModule::new(boundary, [
      @semantic.ManifestFile::new("tail.dew", tail_source),
    ]),
  ])
  (first, second)
}

///|
test "cache identities preserve manifest module and file boundaries" {
  let (first, second) = program_output_boundary_collision_manifests()
  assert_true(first != second)
  assert_true(
    cache_pack_default_key(first, 0, true, 0) !=
    cache_pack_default_key(second, 0, true, 0),
  )
  assert_true(
    program_output_content_digest(first) !=
    program_output_content_digest(second),
  )
  let prior_compiler = @sys.get_env_var("DEW_COMPILER_FINGERPRINT").unwrap_or(
    "",
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", "counted-graph-test")
  let session = program_output_test_session()
  store_program_output_cache(
    session,
    first,
    0,
    true,
    1,
    0,
    [],
    [],
    b"first-output",
  ).unwrap()
  assert_eq(
    lookup_program_output_cache(session, second, 0, true, 1, 0, [], []).unwrap(),
    None,
  )
  @sys.set_env_var("DEW_COMPILER_FINGERPRINT", prior_compiler)
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
