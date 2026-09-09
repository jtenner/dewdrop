///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard preamble is a deterministic declaration prefix" {
  let source = b"pub fn identity(value: I32) -> I32 {\n  value\n}\n"
  let collected = collect_bytes_with_standard_preamble(995UL, source)
  let preamble = collect_program_files(995UL, [])
  assert_eq(preamble.diagnostics.length(), 0)
  assert_eq(
    collected.preamble_declaration_count,
    preamble.preamble_declaration_count,
  )
  assert_eq(collected.declarations.length(), preamble.declarations.length() + 1)
  for index, declaration in preamble.declarations {
    assert_eq(collected.declarations[index], declaration)
  }
  assert_eq(collected.diagnostics.length(), 0)
  let identity = collected.lookup_value("identity").unwrap()
  assert_eq(semantic_id_local(identity), collected.preamble_declaration_count)
  match collected.declaration(identity) {
    Some(TopLevelReference(declaration)) => assert_eq(declaration.offset, 0UL)
    _ => fail("expected user function declaration")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "required on-disk standard paths are selective and deterministic" {
  let scalar = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new("main.dew", b"pub fn main() -> I32 {\n  1\n}\n"),
    ]),
  ])
  let scalar_paths = required_standard_library_source_paths(scalar, true)
  assert_eq(scalar_paths.length(), 16)
  assert_eq(scalar_paths[0], "std/preamble/00-builtins.dew")
  assert_eq(scalar_paths[13], "std/result.dew")
  assert_eq(scalar_paths[14], "std/text_runtime.dew")
  assert_eq(scalar_paths[15], "std/wasm/intrinsics.dew")
  assert_eq(required_standard_library_source_paths(scalar, false), [])

  let wildcard = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new(
        "main.dew", b"open dew.std.*\npub fn main() -> Unit {}\n",
      ),
    ]),
  ])
  let wildcard_paths = required_standard_library_source_paths(wildcard, false)
  assert_eq(wildcard_paths.length(), 90)
  assert_eq(wildcard_paths[14], "std/fixed_array.dew")
  assert_eq(wildcard_paths[15], "std/array.dew")
  assert_eq(wildcard_paths[16], "std/map.dew")
  assert_eq(wildcard_paths[17], "std/set.dew")
  assert_eq(wildcard_paths[18], "std/collections/stack.dew")
  assert_eq(wildcard_paths[19], "std/queue.dew")
  assert_eq(wildcard_paths[20], "std/collections/circular_buffer.dew")
  assert_eq(wildcard_paths[21], "std/collections/deque.dew")
  assert_eq(wildcard_paths[22], "std/ordering.dew")
  assert_eq(wildcard_paths[23], "std/collections/binary_heap.dew")
  assert_eq(wildcard_paths[24], "std/collections/priority_queue.dew")
  assert_eq(wildcard_paths[25], "std/collections/red_black_tree.dew")
  assert_eq(wildcard_paths[26], "std/collections/ordered_map.dew")
  assert_eq(wildcard_paths[27], "std/collections/ordered_set.dew")
  assert_eq(wildcard_paths[28], "std/show.dew")
  assert_eq(wildcard_paths[29], "std/disposable.dew")
  assert_eq(wildcard_paths[30], "std/iter.dew")
  assert_eq(wildcard_paths[31], "std/math.dew")
  assert_eq(wildcard_paths[32], "std/io.dew")
  assert_eq(wildcard_paths[33], "std/testing.dew")
  assert_eq(wildcard_paths[34], "std/json.dew")
  assert_eq(wildcard_paths[35], "std/encode.dew")
  assert_eq(wildcard_paths[36], "std/decode.dew")
  assert_eq(wildcard_paths[37], "std/format.dew")
  assert_eq(wildcard_paths[38], "std/semver.dew")
  assert_eq(wildcard_paths[39], "std/package.dew")
  assert_eq(wildcard_paths[40], "std/package/artifact.dew")
  assert_eq(wildcard_paths[41], "std/bloom_filter.dew")
  assert_eq(wildcard_paths[42], "std/blake3.dew")
  assert_eq(wildcard_paths[43], "std/integrity/sha256.dew")
  assert_eq(wildcard_paths[44], "std/path.dew")
  assert_eq(wildcard_paths[45], "std/fs.dew")
  assert_eq(wildcard_paths[46], "std/process.dew")
  assert_eq(wildcard_paths[47], "std/fs/wasi.dew")
  assert_eq(wildcard_paths[48], "std/process/wasi.dew")
  assert_eq(wildcard_paths[49], "std/facet.dew")
  assert_eq(wildcard_paths[50], "std/facet/imports.dew")
  assert_eq(wildcard_paths[51], "std/facet/core.dew")
  assert_eq(wildcard_paths[52], "std/facet/fs.dew")
  assert_eq(wildcard_paths[56], "std/facet/poll.dew")
  assert_eq(wildcard_paths[57], "std/facet/net.dew")
  assert_eq(wildcard_paths[58], "std/text_runtime.dew")
  assert_eq(wildcard_paths[60], "std/string_fixed_array.dew")
  assert_eq(wildcard_paths[64], "std/text.dew")
  assert_eq(wildcard_paths[65], "std/encoding/utf8.dew")
  assert_eq(wildcard_paths[66], "std/wasm/wasi.dew")
  assert_eq(wildcard_paths[68], "std/wasm/intrinsics.dew")
  assert_eq(wildcard_paths[88], "std/f64x2.dew")
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects split module bits" {
  let module_id = 993UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.wasi\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      9, false, false, false, false, false, true, true, true, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects raw WebAssembly WASI" {
  let module_id = 1004UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"import dew.std.wasm.wasi as @wasi\npub fn run() -> U32 {\n  @wasi.sched_yield()\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, false, false, false, false, false, false, false,
      16384, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects scalar math dependencies" {
  let module_id = 998UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.math\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, true, false, false, false, false, false, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects portable IO dependencies" {
  let module_id = 999UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.io\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      12, false, false, false, true, false, false, true, true, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects testing dependencies" {
  let module_id = 1000UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.testing\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, true, false, false, false, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects Bloom filter" {
  let module_id = 1002UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.bloom_filter\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, false, false, false, false, false, false, false,
      4096, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects BLAKE3 dependencies" {
  let module_id = 1003UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.blake3\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      8, false, false, false, false, false, false, true, true, true, false, false,
      8192, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects SHA-256 dependencies" {
  let module_id = 1005UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.integrity.sha256\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      8, false, false, false, false, false, false, true, true, false, false, false,
      32768, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects filesystem and process WASI adapters" {
  let module_id = 1006UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.fs.wasi\nopen dew.std.process.wasi\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      15, false, false, false, false, false, false, true, true, true, false, false,
      3096576, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects grouped Facet namespaces" {
  let module_id = 1008UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.facet.fs\nopen dew.std.facet.net\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, false, false, true, true, false, false, false,
      0, 267, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects JSON dependencies" {
  let module_id = 1001UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.json\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      15, false, false, false, true, false, false, true, true, true, false, false,
      6144, 0, 2048,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects generic iterator dependencies" {
  let module_id = 997UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.iter\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, false, false, false, false, false, false, false,
      1024, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects text iteration dependencies" {
  let module_id = 996UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.text\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      17, false, false, false, false, false, false, true, true, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects UTF8 codec dependencies" {
  let module_id = 1007UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.encoding.utf8\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      43, false, false, false, false, false, false, true, true, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects Show and builder dependency" {
  let module_id = 994UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.show\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      3, true, false, false, false, false, false, true, true, true, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects Disposable" {
  let module_id = 995UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.disposable\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, true, false, false, false, false, false, false, false, false, false,
      0, 0, 0,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "standard import prepass selects lane module bits" {
  let module_id = 992UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.i8x4\nopen dew.std.f64x2\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (
      0, false, false, false, false, false, false, false, false, false, false, false,
      0, 0, 524289,
    ),
  )
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "one imported lane interface is selected without unrelated lane APIs" {
  let program = collect_program_manifest(
    991UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.i8x4\npub fn splat(value: I8) -> I8x4 {\n  i8x4_splat(value)\n}\n",
        ),
      ]),
    ]),
  )
  assert_true(program.module_index("dew.std.i8x4") is Some(_))
  assert_eq(program.module_index("dew.std.f64x2"), None)
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].names.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)

  let omitted = collect_program_manifest(
    990UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub fn splat(value: I8) -> I8x4 {\n  i8x4_splat(value)\n}\n",
        ),
      ]),
    ]),
  )
  let omitted_analysis = analyze_program_semantics(omitted)
  assert_eq(omitted_analysis.modules[0].names.diagnostics.length(), 1)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "immutable text interfaces do not expose public builder modules" {
  let string_only = collect_program_manifest(
    989UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\npub fn compact(value: String) -> String {\n  value.compact()\n}\n",
        ),
      ]),
    ]),
  )
  let string_analysis = analyze_program_semantics(string_only)
  assert_eq(string_analysis.modules[0].inferred.diagnostics.length(), 0)
  assert_true(string_only.module_index("dew.std.string") is Some(_))
  assert_eq(string_only.module_index("dew.std.string_builder"), None)

  let missing_builder = collect_program_manifest(
    988UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\npub fn build() -> StringBuilder {\n  StringBuilder::new()\n}\n",
        ),
      ]),
    ]),
  )
  let missing_analysis = analyze_program_semantics(missing_builder)
  assert_eq(missing_analysis.modules[0].inferred.diagnostics.length(), 1)
  match missing_analysis.modules[0].inferred.diagnostics[0] {
    NoMatchingMethod(_, _, _) => ()
    _ => fail("expected unimported StringBuilder API to remain unavailable")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "explicit text and WASI imports select frozen standard modules once" {
  let program = collect_program_manifest(
    994UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.string_builder\nopen dew.std.bytes\nopen dew.std.bytes_builder\nopen dew.std.wasi\npub fn keep(value: StringBuilder) -> StringBuilder {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.modules[0].preamble_declaration_count, 0)
  assert_true(program.module_index("dew.std.preamble") is Some(_))
  assert_true(program.module_index("dew.std.text_runtime") is Some(_))
  assert_true(program.module_index("dew.std.option") is Some(_))
  assert_true(program.module_index("dew.std.result") is Some(_))
  assert_true(program.module_index("dew.std.string") is Some(_))
  assert_true(program.module_index("dew.std.string_builder") is Some(_))
  assert_true(program.module_index("dew.std.bytes") is Some(_))
  assert_true(program.module_index("dew.std.bytes_builder") is Some(_))
  assert_true(program.module_index("dew.std.wasi") is Some(_))
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "single-module phase helper never injects optional standard sources" {
  let collected = collect_program_bytes(
    987UL, b"open dew.std.string_builder\npub fn build() -> StringBuilder {\n  StringBuilder::new()\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  let preamble = collect_program_files(987UL, [])
  assert_eq(
    collected.preamble_declaration_count,
    preamble.preamble_declaration_count,
  )
  assert_eq(collected.files.length(), preamble.files.length() + 1)
  assert_eq(collected.lookup_value("string_builder_new"), None)
  // Three missing-import errors belong to the embedded preamble byte helper.
  // The requested builder still has its own missing-method diagnostic.
  assert_eq(inferred.diagnostics.length(), 4)
  match inferred.diagnostics[3] {
    NoMatchingMethod(_, _, _) => ()
    _ => fail("expected optional standard APIs to require frozen imports")
  }
}

///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "ambient preamble resolves Fibonacci operators" {
  let program = compiler_test_single_module_program(
    996UL, b"pub fn fib(value: I32) -> I32 {\n  if value <= 1 {\n    value\n  } else {\n    fib(value - 1) + fib(value - 2)\n  }\n}\n",
  )
  let collected = program.modules[0]
  let analyzed = analyze_program_semantics(program)
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let inferred = analyzed.modules[0].inferred
  assert_eq(collected.diagnostics.length(), 0)
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(inferred.impl_index.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  let fib = collected.lookup_value("fib").unwrap()
  let body = collected.body_of(fib).unwrap()
  let mut selected = 0
  for
    expression in body.expressions.start..<(body.expressions.start +
    body.expressions.length) {
    match collected.expressions[expression] {
      HirBinaryExpr(_, _, _, _) =>
        match inferred.operator_targets[expression] {
          SelectedInferredCallTarget(declaration, _) => {
            assert_true(
              semantic_id_module(declaration) == standard_library_module_id(0),
            )
            selected += 1
          }
          _ => fail("expected ambient operator implementation")
        }
      _ => ()
    }
  }
  assert_eq(selected, 4)
}
