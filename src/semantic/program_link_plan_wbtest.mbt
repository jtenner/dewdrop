///|
fn scalar_link_program() -> (CollectedProgram, AnalyzedProgramSemantics) {
  let program = collect_program_manifest(
    2100UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.math\npub fn run(value: I32) -> I32 {\n  double(value)\n}\n",
        ),
      ]),
      ManifestModule::new("app.math", [
        ManifestFile::new(
          "math.dew", b"pub fn double(value: I32) -> I32 {\n  value + value\n}\n",
        ),
      ]),
    ]),
  )
  (program, analyze_program_semantics(program))
}

///|
test "program link assigns dependency-first scalar function indices" {
  let (program, analyzed) = scalar_link_program()
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.imported_function_count, 0)
  assert_eq(link.defined_function_count, 2)
  let run = program.modules[0].lookup_value("run").unwrap()
  let double = program.modules[1].lookup_value("double").unwrap()
  assert_eq(link.function_of(double).unwrap().function_index, 0)
  assert_eq(link.function_of(run).unwrap().function_index, 1)
  let body = program.modules[0].body_of(run).unwrap()
  let call = body_calls(program.modules[0], body)[0]
  match lowering.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, _, _) => assert_eq(declaration, double)
    _ => fail("expected external direct-call lowering")
  }
}

///|
test "program test export ordinals follow manifest module order" {
  let program = collect_program_manifest(
    2150UL,
    ProgramManifest::new([
      ManifestModule::new("app.first", [
        ManifestFile::new("first.dew", b"open app.second\n"),
        ManifestFile::new("first_test.dew", b"test \"first\" {\n}\n"),
      ]),
      ManifestModule::new("app.second", [
        ManifestFile::new("second_test.dew", b"test \"second\" {\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    0,
    WasmGCPlanningOptions::test_mode(),
  )
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(
    link.function_of(program.modules[0].tests[0].declaration).unwrap().name,
    b"__dew_test_0",
  )
  assert_eq(
    link.function_of(program.modules[1].tests[0].declaration).unwrap().name,
    b"__dew_test_1",
  )
}

///|
test "program link assigns stable indices inside a module cycle" {
  let program = collect_program_manifest(
    2200UL,
    ProgramManifest::new([
      ManifestModule::new("cycle.a", [
        ManifestFile::new(
          "a.dew", b"open cycle.b\npub fn a(value: I32) -> I32 {\n  b(value)\n}\n",
        ),
      ]),
      ManifestModule::new("cycle.b", [
        ManifestFile::new(
          "b.dew", b"open cycle.a\npub fn b(value: I32) -> I32 {\n  a(value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.graph.sccs.length(), 4)
  let mut found_cycle = false
  for scc in link.graph.sccs {
    if scc.length == 2 {
      found_cycle = true
    }
  }
  assert_true(found_cycle)
  let a = program.modules[0].lookup_value("a").unwrap()
  let b = program.modules[1].lookup_value("b").unwrap()
  assert_eq(link.function_of(a).unwrap().function_index, 0)
  assert_eq(link.function_of(b).unwrap().function_index, 1)
}

///|
test "program linker rebases imported aggregate signatures" {
  let program = collect_program_manifest(
    2230UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library\npub fn run(value: Item) -> Item {\n  keep(value)\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Item {\n  value: I32\n}\npub fn keep(value: Item) -> Item {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let item = program.modules[1].lookup_type("Item").unwrap()
  assert_eq(link.type_lookup.get(item), Some(0))
  let run = link
    .function_of(program.modules[0].lookup_value("run").unwrap())
    .unwrap()
  let run_module = link.modules[run.module_index]
  assert_eq(
    run_module.function_value_types[run.parameters.start],
    WasmExternalNominalRefValue(item),
  )
}

///|
test "program linker merges cross module recursive type groups" {
  let program = collect_program_manifest(
    2240UL,
    ProgramManifest::new([
      ManifestModule::new("cycle.a", [
        ManifestFile::new("a.dew", b"open cycle.b\npub struct A {\n  b: B\n}\n"),
      ]),
      ManifestModule::new("cycle.b", [
        ManifestFile::new("b.dew", b"open cycle.a\npub struct B {\n  a: A\n}\n"),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut found_pair = false
  for group in link.program_type_groups {
    if group.types.length == 2 {
      found_pair = true
    }
  }
  assert_true(found_pair)
  let a = program.modules[0].lookup_type("A").unwrap()
  let b = program.modules[1].lookup_type("B").unwrap()
  let a_index = link.type_lookup.get(a).unwrap()
  let b_index = link.type_lookup.get(b).unwrap()
  assert_eq(link.physical_type_index(0, 0), a_index)
  assert_eq(link.physical_type_index(1, 0), b_index)
  assert_true(a_index != b_index)
}

///|
test "program enum fragments use subtype bases and direct payload subtypes" {
  let program = collect_program_manifest(
    2244UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library\npub fn make(value: I32) -> Maybe {\n  Maybe::Some(value)\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub enum Maybe {\n  None\n  Some(I32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let declaration = program.modules[1].lookup_type("Maybe").unwrap()
  let variants = lowering.modules[1].type_layouts.variants
  assert_eq(fragments.modules[1].type_index_of(declaration), Some(0))
  assert_eq(
    fragments.modules[1].payload_type_index_of(variants[0].variant),
    Some(0),
  )
  assert_true(
    fragments.modules[1].payload_type_index_of(variants[1].variant) != Some(0),
  )
}

///|
test "unused generic structs are eliminated before program linking" {
  let program = collect_program_manifest(
    2245UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub struct Box<t> {\n  value: t\n}\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  let box_declaration = program.modules[0].lookup_type("Box").unwrap()
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.type_lookup.get(box_declaration), None)
}

///|
test "program linker materializes generic control-flow specializations" {
  let program = collect_program_manifest(
    2250UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library\npub fn run() -> I32 {\n  choose(true, 1, 2)\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub fn choose<t>(condition: Bool, left: t, right: t) -> t {\n  if condition {\n    left\n  } else {\n    right\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  let choose = program.modules[1].lookup_value("choose").unwrap()
  assert_eq(link.diagnostics.length(), 0)
  let mut specializations = 0
  for function_ in link.functions {
    if function_.declaration == choose &&
      function_.specialization_shapes.length > 0 {
      specializations += 1
    }
  }
  assert_eq(specializations, 1)
}

///|
test "program linker eliminates unused physical aggregate types" {
  let program = collect_program_manifest(
    2300UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub struct Item {}\npub fn run() -> I32 {\n  1\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let item = program.modules[0].lookup_type("Item").unwrap()
  assert_eq(link.type_lookup.get(item), None)
}

///|
test "program lowering specializes generic parameter selectors" {
  let program = collect_program_manifest(
    2275UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn first<t>(left: t, right: t) -> t {\n  left\n}\npub fn main() -> I32 {\n  first(42, 7)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let call = body_calls(collected, body)[0]
  match lowering.modules[0].expressions[call].kind {
    PlannedParameterSelect(arguments, selected) => {
      assert_eq(arguments.length, 2)
      assert_eq(selected, 0)
    }
    _ => fail("expected generic parameter-selector specialization")
  }
}

///|
test "program lowering directizes transparent callback wrappers" {
  let program = collect_program_manifest(
    2280UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value)\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let call = body_calls(collected, body)[0]
  let increment = collected.lookup_value("increment").unwrap()
  match lowering.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, increment)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected transparent callback wrapper directization")
  }
}

///|
test "program link unifies closure bases and named singletons across modules" {
  let program = collect_program_manifest(
    2285UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library\npub fn choose() -> fn(I32) -> I32 {\n  increment\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub fn increment(value: I32) -> I32 {\n  value + 1\n}\npub let stored = increment\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let main_closure = link.modules[0].closure_type_index
  let library_closure = link.modules[1].closure_type_index
  assert_true(main_closure >= 0)
  assert_true(library_closure >= 0)
  assert_eq(
    link.physical_type_index(0, main_closure),
    link.physical_type_index(1, library_closure),
  )
  let mut closure_bases = 0
  for physical in link.program_physical_types {
    let module_ = link.modules[physical.module_index]
    match module_.physical_types[physical.fragment_index].kind {
      PlannedWasmClosureType => closure_bases += 1
      _ => ()
    }
  }
  assert_eq(closure_bases, 1)
  assert_eq(link.function_reference_singletons.length(), 1)
  let increment = program.modules[1].lookup_value("increment").unwrap()
  assert_eq(link.function_reference_singletons[0].declaration, increment)
}

///|
test "program link plans deterministic named function singleton globals" {
  let program = collect_program_manifest(
    2290UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn identity(value: I32) -> I32 {\n  value\n}\npub fn first() -> fn(I32) -> I32 {\n  identity\n}\npub fn second() -> fn(I32) -> I32 {\n  identity\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.function_reference_singletons.length(), 1)
  let identity = program.modules[0].lookup_value("identity").unwrap()
  let singleton = link.function_reference_singletons[0]
  assert_eq(singleton.module_index, 0)
  assert_eq(singleton.declaration, identity)
  assert_eq(singleton.global_index, 0)
  assert_eq(link.function_reference_singleton_global(0, identity), 0)
  assert_true(link.initializer_type_index >= 0)
  assert_true(link.startup_function_index >= 0)
}
