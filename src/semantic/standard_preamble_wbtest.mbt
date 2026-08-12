///|
test "standard preamble is a deterministic declaration prefix" {
  let source = b"pub fn identity(value: I32) -> I32 {\n  value\n}\n"
  let collected = collect_bytes_with_standard_preamble(995UL, source)
  assert_eq(collected.preamble_declaration_count, 1311)
  assert_eq(collected.declarations.length(), 812)
  assert_eq(collected.diagnostics.length(), 0)
  let identity = collected.lookup_value("identity").unwrap()
  assert_eq(semantic_id_local(identity), collected.preamble_declaration_count)
  match collected.declaration(identity) {
    Some(TopLevelReference(declaration)) => assert_eq(declaration.offset, 0UL)
    _ => fail("expected user function declaration")
  }
}

///|
test "required on-disk standard paths are selective and deterministic" {
  let scalar = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new("main.dew", b"pub fn main() -> I32 {\n  1\n}\n"),
    ]),
  ])
  let scalar_paths = required_standard_library_source_paths(scalar, true)
  assert_eq(scalar_paths.length(), 14)
  assert_eq(scalar_paths[0], "std/preamble/00-builtins.dew")
  assert_eq(scalar_paths[13], "std/result.dew")
  assert_eq(required_standard_library_source_paths(scalar, false), [])

  let wildcard = ProgramManifest::new([
    ManifestModule::new("app.main", [
      ManifestFile::new(
        "main.dew", b"open dew.std.*\npub fn main() -> Unit {}\n",
      ),
    ]),
  ])
  let wildcard_paths = required_standard_library_source_paths(wildcard, false)
  assert_eq(wildcard_paths.length(), 60)
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
  assert_eq(wildcard_paths[32], "std/text_runtime.dew")
  assert_eq(wildcard_paths[37], "std/text.dew")
  assert_eq(wildcard_paths[39], "std/wasm/intrinsics.dew")
  assert_eq(wildcard_paths[59], "std/f64x2.dew")
}

///|
test "standard import prepass selects split module bits" {
  let module_id = 993UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.wasi\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (9, false, false, false, true, false, false, false, false, false, 0, 0),
  )
}

///|
test "standard import prepass selects scalar math dependencies" {
  let module_id = 998UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.math\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (0, false, false, true, false, false, false, false, false, false, 0, 0),
  )
}

///|
test "standard import prepass selects generic iterator dependencies" {
  let module_id = 997UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.iter\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (0, false, false, false, false, false, false, false, false, false, 1024, 0),
  )
}

///|
test "standard import prepass selects text iteration dependencies" {
  let module_id = 996UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.text\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (17, false, false, false, false, false, true, false, false, false, 0, 0),
  )
}

///|
test "standard import prepass selects Show and builder dependency" {
  let module_id = 994UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.show\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (3, true, false, false, false, false, false, false, false, false, 0, 0),
  )
}

///|
test "standard import prepass selects Disposable" {
  let module_id = 995UL
  assert_eq(
    selected_standard_modules([
      ProgramFile::new(
        make_program_file_id(module_id, 0),
        b"open dew.std.disposable\npub fn run() -> Unit {\n}\n",
      ),
    ]),
    (0, false, true, false, false, false, false, false, false, false, 0, 0),
  )
}

///|
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
      0, false, false, false, false, false, false, false, false, false, 0, 524289,
    ),
  )
}

///|
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
test "single-module phase helper never injects optional standard sources" {
  let collected = collect_program_bytes(
    987UL, b"open dew.std.string_builder\npub fn build() -> StringBuilder {\n  StringBuilder::new()\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
  assert_eq(collected.preamble_declaration_count, 1311)
  assert_eq(inferred.diagnostics.length(), 1)
  match inferred.diagnostics[0] {
    NoMatchingMethod(_, _, _) => ()
    _ => fail("expected optional standard APIs to require frozen imports")
  }
}

///|
test "ambient preamble resolves Fibonacci operators" {
  let collected = collect_bytes_with_standard_preamble(
    996UL, b"pub fn fib(value: I32) -> I32 {\n  if value <= 1 {\n    value\n  } else {\n    fib(value - 1) + fib(value - 2)\n  }\n}\n",
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  let inferred = infer_module_bodies(collected, resolved, names)
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
              semantic_id_local(declaration) <
              collected.preamble_declaration_count,
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
