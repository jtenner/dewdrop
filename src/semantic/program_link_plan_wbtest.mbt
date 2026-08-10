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
test "program linker exports one erased fallback for public generics" {
  let program = collect_program_manifest(
    2240UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub fn identity<t>(value: t) -> t {\n  value\n}\npub fn main() -> Unit {}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let identity = program.modules[0].lookup_value("identity").unwrap()
  let recipe = link.function_of(identity).unwrap()
  assert_true(recipe.elided)
  assert_eq(recipe.function_index, -1)
  let mut fallbacks = 0
  for function_ in link.functions {
    if function_.declaration == identity &&
      function_.specialization_abi_key == "\{identity}:eqref" {
      fallbacks += 1
      assert_eq(function_.visibility, Public)
      assert_eq(function_.name, b"identity")
      assert_eq(function_.parameters.length, 1)
      assert_eq(function_.results.length, 1)
      let module_ = link.modules[function_.module_index]
      assert_eq(
        module_.function_value_types[function_.parameters.start],
        WasmNullableEqRefValue,
      )
      assert_eq(
        module_.function_value_types[function_.results.start],
        WasmNullableEqRefValue,
      )
    }
  }
  assert_eq(fallbacks, 1)
}

///|
test "program linker adapts exact references to erased generic fallbacks" {
  let program = collect_program_manifest(
    2242UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Item {\n  value: I32\n}\npub fn identity<t>(value: t) -> t {\n  value\n}\nfn return_identity() -> fn(Item) -> Item {\n  identity\n}\npub fn main() -> Unit {}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let identity = program.modules[0].lookup_value("identity").unwrap()
  let mut fallback_index = -1
  let mut adapter_index = -1
  for function_ in link.functions {
    if function_.declaration == identity &&
      function_.specialization_abi_key == "\{identity}:eqref" {
      fallback_index = function_.function_index
    }
    if function_.declaration == identity && function_.erased_adapter_target >= 0 {
      adapter_index = function_.function_index
      assert_eq(function_.erased_adapter_target, fallback_index)
    }
  }
  assert_true(fallback_index >= 0)
  assert_true(adapter_index >= 0)
  assert_eq(link.function_reference_singletons.length(), 1)
  assert_eq(link.function_reference_singletons[0].function_index, adapter_index)
}

///|
test "program linker exports boxed scalar adapters for erased generics" {
  let program = collect_program_manifest(
    2244UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub fn identity<t>(value: t) -> t {\n  value\n}\npub fn choose<t>(condition: Bool, left: t, right: t) -> t {\n  if condition { left } else { right }\n}\nfn return_i32_identity() -> fn(I32) -> I32 {\n  identity\n}\nfn return_i64_identity() -> fn(I64) -> I64 {\n  identity\n}\nfn return_f32_identity() -> fn(F32) -> F32 {\n  identity\n}\nfn return_f64_identity() -> fn(F64) -> F64 {\n  identity\n}\nfn return_v128_identity() -> fn(V128) -> V128 {\n  identity\n}\npub fn main() -> Unit {\n  let a = return_i32_identity()\n  let b = return_i64_identity()\n  let c = return_f32_identity()\n  let d = return_f64_identity()\n  let e = return_v128_identity()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_true(link.erased_box_type_indices[0] >= 0)
  assert_true(link.erased_box_type_indices[1] >= 0)
  assert_true(link.erased_box_type_indices[2] >= 0)
  assert_true(link.erased_box_type_indices[3] >= 0)
  assert_true(link.erased_box_type_indices[4] >= 0)
  let mut i32_adapter = 0
  let mut i64_adapter = 0
  let mut f32_adapter = 0
  let mut f64_adapter = 0
  let mut v128_adapter = 0
  for function_ in link.functions {
    if function_.name == b"identity$dew$i32" {
      i32_adapter += 1
      assert_eq(function_.visibility, Public)
      assert_true(function_.erased_adapter_target >= 0)
    }
    if function_.name == b"identity$dew$i64" {
      i64_adapter += 1
      assert_eq(function_.visibility, Public)
      assert_true(function_.erased_adapter_target >= 0)
    }
    if function_.name == b"identity$dew$f32" {
      f32_adapter += 1
      assert_eq(function_.visibility, Public)
      assert_true(function_.erased_adapter_target >= 0)
    }
    if function_.name == b"identity$dew$f64" {
      f64_adapter += 1
      assert_eq(function_.visibility, Public)
      assert_true(function_.erased_adapter_target >= 0)
    }
    if function_.name == b"identity$dew$v128" {
      v128_adapter += 1
      assert_eq(function_.visibility, Public)
      assert_true(function_.erased_adapter_target >= 0)
    }
  }
  assert_eq(i32_adapter, 1)
  assert_eq(i64_adapter, 1)
  assert_eq(f32_adapter, 1)
  assert_eq(f64_adapter, 1)
  assert_eq(v128_adapter, 1)
}

///|
test "program linker plans recursive aggregate erased adapters" {
  let program = collect_program_manifest(
    2246UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box<t> {\n  value: t\n}\npub fn echo_box<t>(value: Box<t>) -> Box<t> {\n  Box {\n    value: value.value\n  }\n}\npub fn main() -> Unit {\n  let boxed = echo_box(Box {\n    value: 42\n  })\n  assert(boxed.value == 42, \"nested aggregate adapter demand\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let echo_box = program.modules[0].lookup_value("echo_box").unwrap()
  let mut fallback = 0
  let mut adapter = 0
  for function_ in link.functions {
    if function_.declaration == echo_box &&
      function_.specialization_abi_key == "\{echo_box}:eqref" {
      fallback += 1
      assert_eq(function_.name, b"echo_box")
    }
    if function_.name == b"echo_box$dew$i32" {
      adapter += 1
      assert_true(function_.erased_adapter_target >= 0)
    }
  }
  assert_eq(fallback, 1)
  assert_eq(adapter, 1)
  assert_true(link.erased_box_type_indices[0] >= 0)
}

///|
test "program linker plans recursive enum erased adapters" {
  let program = collect_program_manifest(
    2247UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"struct Box<t> {\n  value: t\n}\nstruct Envelope<t> {\n  payload: Maybe<t>\n}\nenum Maybe<t> {\n  None\n  Some(t)\n  Boxed(Box<t>)\n}\npub fn echo_maybe<t>(value: Maybe<t>) -> Maybe<t> {\n  match value {\n    Maybe::None => Maybe::None\n    Maybe::Some(item) => Maybe::Some(item)\n    Maybe::Boxed(box) => Maybe::Boxed(Box {\n      value: box.value\n    })\n  }\n}\npub fn echo_envelope<t>(value: Envelope<t>) -> Envelope<t> {\n  Envelope {\n    payload: echo_maybe(value.payload)\n  }\n}\npub fn main() -> Unit {\n  let maybe = echo_maybe(Maybe::Some(42))\n  let envelope = echo_envelope(Envelope {\n    payload: Maybe::Boxed(Box {\n      value: 43\n    })\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let echo_maybe = program.modules[0].lookup_value("echo_maybe").unwrap()
  let echo_envelope = program.modules[0].lookup_value("echo_envelope").unwrap()
  let mut maybe_fallback = 0
  let mut maybe_adapter = 0
  let mut envelope_fallback = 0
  let mut envelope_adapter = 0
  for function_ in link.functions {
    if function_.declaration == echo_maybe &&
      function_.specialization_abi_key == "\{echo_maybe}:eqref" {
      maybe_fallback += 1
    }
    if function_.name == b"echo_maybe$dew$i32" {
      maybe_adapter += 1
      assert_true(function_.erased_adapter_target >= 0)
    }
    if function_.declaration == echo_envelope &&
      function_.specialization_abi_key == "\{echo_envelope}:eqref" {
      envelope_fallback += 1
    }
    if function_.name == b"echo_envelope$dew$i32" {
      envelope_adapter += 1
      assert_true(function_.erased_adapter_target >= 0)
    }
  }
  assert_eq(maybe_fallback, 1)
  assert_eq(maybe_adapter, 1)
  assert_eq(envelope_fallback, 1)
  assert_eq(envelope_adapter, 1)
  assert_true(link.erased_box_type_indices[0] >= 0)
}

///|
test "program linker plans cyclic nominal erased adapters" {
  let program = collect_program_manifest(
    2248UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"enum List<t> {\n  Nil\n  Cons(t, List<t>)\n}\npub fn echo_list<t>(value: List<t>) -> List<t> {\n  match value {\n    List::Nil => List::Nil\n    List::Cons(head, tail) => List::Cons(head, tail)\n  }\n}\npub fn main() -> Unit {\n  let value = echo_list(List::Cons(1, List::Cons(2, List::Nil)))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let echo_list = program.modules[0].lookup_value("echo_list").unwrap()
  let mut fallback = 0
  let mut adapter = 0
  for function_ in link.functions {
    if function_.declaration == echo_list &&
      function_.specialization_abi_key == "\{echo_list}:eqref" {
      fallback += 1
    }
    if function_.name == b"echo_list$dew$i32" {
      adapter += 1
      assert_true(function_.erased_adapter_target >= 0)
    }
  }
  assert_eq(fallback, 1)
  assert_eq(adapter, 1)
  assert_eq(link.materialized_specialization_count(), 2)
  assert_true(link.erased_box_type_indices[0] >= 0)
}

///|
test "program linker plans structural callback erased adapters" {
  let program = collect_program_manifest(
    2247UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\npub fn invoke<t>(callback: fn(t) -> t, value: t) -> t {\n  let result = callback(value)\n  result\n}\nfn return_invoke() -> fn(fn(I32) -> I32, I32) -> I32 {\n  invoke\n}\npub fn main() -> Unit {\n  assert(invoke(increment, 41) == 42, \"direct structural callback demand\")\n  let callback = return_invoke()\n  assert(callback(increment, 41) == 42, \"structural callback adapter demand\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let invoke = program.modules[0].lookup_value("invoke").unwrap()
  let mut fallback = 0
  let mut adapter = 0
  for function_ in link.functions {
    if function_.declaration == invoke &&
      function_.specialization_abi_key == "\{invoke}:eqref" {
      fallback += 1
    }
    if function_.name == b"invoke$dew$i32" {
      adapter += 1
      assert_true(function_.erased_adapter_target >= 0)
    }
  }
  assert_eq(fallback, 1)
  assert_eq(adapter, 1)
  assert_true(link.erased_box_type_indices[0] >= 0)
}

///|
test "program linker coalesces generic specializations by physical carrier" {
  let program = collect_program_manifest(
    2245UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn choose<t>(condition: Bool, left: t, right: t) -> t {\n  if condition {\n    left\n  } else {\n    right\n  }\n}\npub fn main() -> Unit {\n  assert(choose(true, 1i8, 2i8) == 1i8, \"i8\")\n  assert(choose(true, 1, 2) == 1, \"i32\")\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let choose = program.modules[0].lookup_value("choose").unwrap()
  let mut specializations = 0
  let mut abi_key = ""
  for function_ in link.functions {
    if function_.declaration == choose &&
      function_.specialization_shapes.length > 0 {
      specializations += 1
      abi_key = function_.specialization_abi_key
    }
  }
  assert_eq(specializations, 1)
  assert_eq(link.materialized_specialization_count(), 1)
  assert_eq(abi_key, "\{choose}:i32")
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
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let result = callback(value)\n  result\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
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
    _ => fail("expected local-return callback wrapper directization")
  }
}

///|
test "public callback summaries discard only total effect-free preludes" {
  let program = collect_program_manifest(
    22801UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.library\nfn increment(value: I32) -> I32 {\n  value + 1\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
        ),
      ]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"pub fn marker() -> I32 {\n  token()\n}\npub fn token() -> I32 {\n  0\n}\npub fn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let ignored = marker()\n  let stored = callback\n  forward(stored, value)\n}\npub fn forward(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let stored = callback\n  stored(value)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = plan_program_lowering(program, analyzed)
  let root = program.modules[0]
  let main = root.lookup_value("main").unwrap()
  let body = root.body_of(main).unwrap()
  let call = body_calls(root, body)[0]
  let increment = root.lookup_value("increment").unwrap()
  match lowering.modules[0].expressions[call].kind {
    PlannedDirectCall(declaration, _, arguments, _) => {
      assert_eq(declaration, increment)
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected public callback summary directization")
  }
  let apply = program.modules[1].lookup_value("apply").unwrap()
  let mut retained_public_apply = false
  for function_ in plan_program_wasmgc_link(analyzed, lowering, 0).functions {
    if function_.declaration == apply && !function_.elided {
      retained_public_apply = true
    }
  }
  assert_true(retained_public_apply)
}

///|
test "public callback summaries retain trapping preludes" {
  let program = collect_program_manifest(
    22802UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\npub fn marker() -> I32 {\n  assert(false, \"observable callback prelude\")\n  0\n}\npub fn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  let ignored = marker()\n  callback(value)\n}\npub fn main() -> I32 {\n  apply(increment, 41)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let apply = collected.lookup_value("apply").unwrap()
  let mut retained_call = false
  for call in body_calls(collected, body) {
    match lowering.modules[0].expressions[call].kind {
      PlannedDirectCall(target, _, _, _) if target == apply =>
        retained_call = true
      _ => ()
    }
  }
  assert_true(retained_call)
}

///|
test "public callback summaries retain escaping and multiply called values" {
  let program = collect_program_manifest(
    22803UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn increment(value: I32) -> I32 {\n  value + 1\n}\npub fn escape(callback: fn(I32) -> I32) -> fn(I32) -> I32 {\n  callback\n}\npub fn twice(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value) + callback(value)\n}\npub fn main() -> I32 {\n  let stored = escape(increment)\n  stored(0) + twice(increment, 20)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let escape = collected.lookup_value("escape").unwrap()
  let twice = collected.lookup_value("twice").unwrap()
  let mut retained_escape = false
  let mut retained_twice = false
  for call in body_calls(collected, body) {
    match lowering.modules[0].expressions[call].kind {
      PlannedDirectCall(target, _, _, _) if target == escape =>
        retained_escape = true
      PlannedDirectCall(target, _, _, _) if target == twice =>
        retained_twice = true
      _ => ()
    }
  }
  assert_true(retained_escape)
  assert_true(retained_twice)
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

///|
test "program specializations distinguish and forward trait evidence" {
  let program = collect_program_manifest(
    2262UL,
    ProgramManifest::new([
      ManifestModule::new("evidence.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    1\n  }\n}\nimpl Value for U32 {\n  fn value(self) -> I32 {\n    2\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\nfn forward<t: Value>(value: t) -> I32 {\n  read(value)\n}\npub fn signed() -> I32 {\n  forward(0)\n}\npub fn unsigned() -> I32 {\n  forward(0u32)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_ = program.modules[0]
  let read = module_.lookup_value("read").unwrap()
  let forward = module_.lookup_value("forward").unwrap()
  let forward_body = module_.body_of(forward).unwrap()
  let forwarded_call = body_calls(module_, forward_body)[0]
  let read_keys : Array[String] = []
  let forwarded_keys : Array[String] = []
  for function_ in link.functions {
    if function_.declaration == read &&
      function_.specialization_shapes.length > 0 &&
      !function_.elided {
      assert_eq(function_.specialization_evidence.length, 1)
      read_keys.push(function_.specialization_abi_key)
    }
    if function_.declaration == forward &&
      function_.specialization_shapes.length > 0 &&
      !function_.elided {
      assert_eq(function_.specialization_evidence.length, 1)
      let target = link
        .specialized_call_function(
          forward_body.id,
          function_.specialization_abi_key,
          forwarded_call,
        )
        .unwrap()
      assert_eq(target.declaration, read)
      forwarded_keys.push(target.specialization_abi_key)
    }
  }
  assert_eq(read_keys.length(), 2)
  assert_true(read_keys[0] != read_keys[1])
  assert_eq(forwarded_keys.length(), 2)
  assert_true(forwarded_keys[0] != forwarded_keys[1])
  assert_true(
    (forwarded_keys[0] == read_keys[0] && forwarded_keys[1] == read_keys[1]) ||
    (forwarded_keys[0] == read_keys[1] && forwarded_keys[1] == read_keys[0]),
  )
}

///|
test "closed generic trait coercion forwarding erases dynamic artifacts" {
  let program = collect_program_manifest(
    21965UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn erase<t: Value>(value: t) -> Value {\n  value\n}\nfn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(erase(42))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let erase = program.modules[0].lookup_value("erase").unwrap()
  let erase_body = program.modules[0].body_of(erase).unwrap()
  let mut bound_coercions = 0
  for
    expression in erase_body.expressions.start..<(erase_body.expressions.start +
    erase_body.expressions.length) {
    match lowering.modules[0].expressions[expression].trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, evidence) =>
        match lowering.modules[0].trait_evidence[evidence].kind {
          BoundInferredTraitEvidence(0) => bound_coercions += 1
          _ => ()
        }
      _ => ()
    }
  }
  assert_eq(bound_coercions, 1)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut erase_specializations = 0
  for function_ in link.functions {
    if function_.declaration == erase &&
      function_.specialization_shapes.length > 0 &&
      !function_.elided {
      erase_specializations += 1
    }
  }
  assert_eq(erase_specializations, 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 0)
  assert_eq(link.modules[0].trait_methods.length(), 0)
  assert_eq(link.trait_dictionary_globals.length(), 0)
  let mut direct_impl_calls = 0
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedDirectCall(target, receiver, _, _) if receiver >= 0 =>
        match lowering.modules[0].functions.callable_of(target) {
          Some({ kind: PlannedImplMethodCallable(_, _), .. }) =>
            direct_impl_calls += 1
          _ => ()
        }
      _ => ()
    }
  }
  assert_eq(direct_impl_calls, 1)
}

///|
fn open_generic_selector_chain_test_source(depth : Int) -> Bytes {
  let source = Buffer(size_hint=depth * 96 + 512)
  source.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\n",
  )
  for index in 0..<depth {
    source.write_string_utf8("fn select_")
    source.write_string_utf8(index.to_string())
    source.write_string_utf8("<t: Value>(value: t) -> Value {\n  ")
    if index == 0 {
      source.write_string_utf8("value")
    } else {
      source.write_string_utf8("select_")
      source.write_string_utf8((index - 1).to_string())
      source.write_string_utf8("(value)")
    }
    source.write_string_utf8("\n}\n")
  }
  source.write_string_utf8(
    "fn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(select_",
  )
  source.write_string_utf8((depth - 1).to_string())
  source.write_string_utf8("(42))\n}\n")
  source.to_bytes()
}

///|
test "deep generic trait selector chains devirtualize completely" {
  let program = collect_program_manifest(
    21965UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew",
          open_generic_selector_chain_test_source(64),
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.materialized_specialization_count(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 0)
  assert_eq(link.modules[0].trait_methods.length(), 0)
  assert_eq(link.trait_dictionary_globals.length(), 0)
  let mut direct_impl_calls = 0
  for expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedDirectCall(target, receiver, _, _) if receiver >= 0 =>
        match lowering.modules[0].functions.callable_of(target) {
          Some({ kind: PlannedImplMethodCallable(_, _), .. }) =>
            direct_impl_calls += 1
          _ => ()
        }
      _ => ()
    }
  }
  assert_eq(direct_impl_calls, 1)
}

///|
test "open generic trait branches materialize exact specialization dictionaries" {
  let program = collect_program_manifest(
    21966UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub fn choose<t: Value>(flag: Bool, value: t) -> Value {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\nfn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(choose(true, 42))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let choose = program.modules[0].lookup_value("choose").unwrap()
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut choose_specializations = 0
  let mut evidence_free_public_fallbacks = 0
  let mut runtime_evidence_public_fallbacks = 0
  for function_ in link.functions {
    if function_.declaration == choose &&
      function_.specialization_shapes.length > 0 &&
      !function_.elided {
      assert_eq(function_.specialization_evidence.length, 1)
      let fragments = link.modules[function_.module_index]
      let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
      match fragments.specialization_trait_evidence[root].kind {
        PlannedConcreteTraitEvidence(_, _) => choose_specializations += 1
        PlannedRuntimeTraitEvidence(_, _) => ()
      }
    }
    if function_.declaration == choose &&
      function_.visibility == Public &&
      function_.specialization_evidence.length == 0 &&
      !function_.elided {
      evidence_free_public_fallbacks += 1
    }
    if function_.declaration == choose &&
      function_.visibility == Public &&
      function_.specialization_evidence.length == 1 &&
      !function_.elided {
      assert_eq(function_.parameters.length, 3)
      let fragments = link.modules[function_.module_index]
      let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
      match fragments.specialization_trait_evidence[root].kind {
        PlannedRuntimeTraitEvidence(trait_, parameter) => {
          assert_eq(trait_, program.modules[0].lookup_trait("Value").unwrap())
          assert_eq(parameter, 2)
        }
        _ => fail("expected runtime trait evidence fallback")
      }
      runtime_evidence_public_fallbacks += 1
    }
  }
  assert_eq(choose_specializations, 1)
  assert_eq(evidence_free_public_fallbacks, 0)
  assert_eq(runtime_evidence_public_fallbacks, 1)
  assert_eq(link.modules[0].trait_dictionaries.length(), 1)
  assert_eq(link.modules[0].trait_methods.length(), 1)
  assert_eq(link.trait_dictionary_globals.length(), 1)
  assert_eq(
    link.modules[0].trait_dictionaries[0].implementation,
    program.modules[0].impls[0].declaration,
  )
}

///|
test "public bound call fallbacks remain evidence carrying without scalar adapters" {
  let program = collect_program_manifest(
    21970UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nstruct Item {}\nimpl Value for Item {\n  fn value(self) -> I32 {\n    41\n  }\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub fn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  read(Item {}) + read(1)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let read = program.modules[0].lookup_value("read").unwrap()
  let mut closed = 0
  let mut public_fallbacks = 0
  let mut public_adapters = 0
  for function_ in link.functions {
    if function_.declaration != read || function_.elided {
      continue
    }
    if function_.specialization_shapes.length > 0 &&
      function_.visibility == ModuleVisible {
      closed += 1
    }
    if function_.visibility == Public {
      assert_eq(function_.parameters.length, 2)
      assert_eq(function_.specialization_evidence.length, 1)
      let fragments = link.modules[function_.module_index]
      let root = fragments.specialization_evidence_roots[function_.specialization_evidence.start]
      match fragments.specialization_trait_evidence[root].kind {
        PlannedRuntimeTraitEvidence(_, parameter) => assert_eq(parameter, 1)
        _ => fail("expected runtime bound-call fallback evidence")
      }
      public_fallbacks += 1
    }
    if function_.erased_adapter_target >= 0 {
      public_adapters += 1
    }
  }
  assert_eq(closed, 2)
  assert_eq(public_fallbacks, 1)
  assert_eq(public_adapters, 0)
}

///|
test "public generic fallbacks forward runtime evidence through nested calls" {
  let program = collect_program_manifest(
    21971UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn finish_read<t: Value>(prefix: I32, suffix: I32, value: t) -> I32 {\n  prefix + suffix + value.value()\n}\nfn forwarded_read<t: Value>(prefix: I32, value: t) -> I32 {\n  finish_read(prefix, 0, value)\n}\npub fn read<t: Value>(value: t) -> I32 {\n  forwarded_read(0, value)\n}\npub fn main() -> I32 {\n  read(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let forwarded = program.modules[0].lookup_value("forwarded_read").unwrap()
  let finish = program.modules[0].lookup_value("finish_read").unwrap()
  let mut forwarded_calls = 0
  let mut finish_calls = 0
  for call in fragments.specialized_calls {
    if call.runtime_evidence_parameters.length != 1 {
      continue
    }
    let parameter = fragments.specialized_call_runtime_evidence_parameters[call.runtime_evidence_parameters.start]
    if call.target == forwarded {
      assert_eq(parameter, 1)
      forwarded_calls += 1
    } else if call.target == finish {
      assert_eq(parameter, 2)
      finish_calls += 1
    }
  }
  assert_eq(forwarded_calls, 1)
  assert_eq(finish_calls, 1)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut forwarded_fallbacks = 0
  let mut finish_fallbacks = 0
  for function_ in link.functions {
    if function_.specialization_evidence.length != 1 || function_.elided {
      continue
    }
    let owner = link.modules[function_.module_index]
    let root = owner.specialization_evidence_roots[function_.specialization_evidence.start]
    match owner.specialization_trait_evidence[root].kind {
      PlannedRuntimeTraitEvidence(_, _) =>
        if function_.declaration == forwarded {
          assert_eq(function_.parameters.length, 3)
          forwarded_fallbacks += 1
        } else if function_.declaration == finish {
          assert_eq(function_.parameters.length, 4)
          finish_fallbacks += 1
        }
      _ => ()
    }
  }
  assert_eq(forwarded_fallbacks, 1)
  assert_eq(finish_fallbacks, 1)
}

///|
test "external generic fallback forwards runtime prerequisites through static evidence" {
  let program = collect_program_manifest(
    21972UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn consume<t: Read>(value: t) -> I32 {\n  value.read()\n}\nfn helper<t: Value>(value: t) -> I32 {\n  consume(Box {\n    value: value\n  })\n}\npub fn outer<t: Value>(value: t) -> I32 {\n  helper(value)\n}\npub fn main() -> I32 {\n  outer(42)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let outer = program.modules[0].lookup_value("outer").unwrap()
  let mut public_fallbacks = 0
  let mut closed = 0
  for function_ in link.functions {
    if function_.declaration != outer || function_.elided {
      continue
    }
    if function_.visibility == Public {
      public_fallbacks += 1
    } else if function_.specialization_shapes.length > 0 {
      closed += 1
    }
  }
  assert_eq(public_fallbacks, 1)
  assert_eq(closed, 1)
}

///|
test "external generic fallback forwards recursive static prerequisite trees" {
  let program = collect_program_manifest(
    21974UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\ntrait Inspect {\n  fn inspect(self) -> I32\n}\nstruct Wrap<t> {\n  value: t\n}\nimpl<t: Read> Inspect for Wrap<t> {\n  fn inspect(self) -> I32 {\n    self.value.read()\n  }\n}\nfn consume_inspect<t: Inspect>(value: t) -> I32 {\n  value.inspect()\n}\npub fn nested_read<t: Value>(value: t) -> I32 {\n  consume_inspect(Wrap {\n    value: Box {\n      value: value\n    }\n  })\n}\npub fn main() -> I32 {\n  42\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let consume = program.modules[0].lookup_value("consume_inspect").unwrap()
  let nested_read = program.modules[0].lookup_value("nested_read").unwrap()
  let mut inspect_method = 0UL
  let mut read_method = 0UL
  for callable in lowering.modules[0].functions.callables {
    match callable.kind {
      PlannedImplMethodCallable(_, _) if callable.name == b"inspect" =>
        inspect_method = callable.declaration
      PlannedImplMethodCallable(_, _) if callable.name == b"read" =>
        read_method = callable.declaration
      _ => ()
    }
  }
  assert_true(inspect_method > 0UL)
  assert_true(read_method > 0UL)
  let mut public_fallbacks = 0
  let mut consume_calls = 0
  let mut inspect_calls = 0
  let mut read_calls = 0
  for function_ in link.functions {
    if function_.declaration == nested_read &&
      function_.visibility == Public &&
      !function_.elided {
      public_fallbacks += 1
    }
  }
  for call in fragments.specialized_calls {
    if call.target == consume {
      consume_calls += 1
    }
    if call.target == inspect_method {
      inspect_calls += 1
    }
    if call.target == read_method {
      read_calls += 1
    }
  }
  assert_eq(public_fallbacks, 1)
  assert_eq(consume_calls, 1)
  assert_eq(inspect_calls, 1)
  assert_eq(read_calls, 1)
}

///|
test "external generic fallback captures erased concrete runtime prerequisites" {
  let program = collect_program_manifest(
    21973UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn erase_read<t: Read>(value: t) -> Read {\n  value\n}\nfn helper<t: Value>(value: t) -> Read {\n  erase_read(Box {\n    value: value\n  })\n}\npub fn outer<t: Value>(value: t) -> Read {\n  helper(value)\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  invoke(outer(42))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let module_lookup : Map[ModuleId, Int] = Map::default()
  module_lookup[lowering.modules[0].module_id] = 0
  let outer = program.modules[0].lookup_value("outer").unwrap()
  let helper = program.modules[0].lookup_value("helper").unwrap()
  let erase_read = program.modules[0].lookup_value("erase_read").unwrap()
  assert_true(
    program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      module_lookup,
      erase_read,
      [ProgramExternalCapturedRuntimeEvidence],
      Map::default(),
    ),
  )
  assert_true(
    program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      module_lookup,
      helper,
      [ProgramExternalDirectRuntimeEvidence],
      Map::default(),
    ),
  )
  assert_true(
    program_runtime_trait_callable_supports_external_evidence_for_classes(
      lowering,
      module_lookup,
      outer,
      [ProgramExternalDirectRuntimeEvidence],
      Map::default(),
    ),
  )
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  let mut captured_dictionaries = 0
  let mut template_dictionaries = 0
  let mut captured_methods = 0
  let mut captured_method_target = 0UL
  let mut captured_method_key = ""
  for module_ in link.modules {
    for dictionary in module_.trait_dictionaries {
      if !dictionary.runtime_materialized {
        template_dictionaries += 1
      }
      if dictionary.runtime_evidence_parameters.length > 0 {
        assert_eq(dictionary.runtime_evidence_parameters.length, 1)
        captured_dictionaries += 1
        for index in 0..<dictionary.methods.length {
          let method_info = module_.trait_methods[dictionary.methods.start +
            index]
          assert_true(method_info.implementation_specialization_abi_key != "")
          captured_method_target = method_info.implementation_method
          captured_method_key = method_info.implementation_specialization_abi_key
          captured_methods += 1
        }
      }
    }
  }
  assert_eq(captured_dictionaries, 1)
  assert_eq(template_dictionaries, 1)
  assert_eq(captured_methods, 1)
  for dictionary_global in link.trait_dictionary_globals {
    assert_true(
      link.modules[dictionary_global.module_index].trait_dictionaries[dictionary_global.dictionary_index].runtime_materialized,
    )
  }
  let mut captured_targets = 0
  for function_ in link.functions {
    if function_.declaration == captured_method_target &&
      function_.specialization_abi_key == captured_method_key &&
      !function_.elided {
      captured_targets += 1
    }
  }
  assert_eq(captured_targets, 1)
  let mut public_fallbacks = 0
  let mut closed = 0
  for function_ in link.functions {
    if function_.declaration != outer || function_.elided {
      continue
    }
    if function_.visibility == Public {
      public_fallbacks += 1
    } else if function_.specialization_shapes.length > 0 {
      closed += 1
    }
  }
  assert_eq(public_fallbacks, 1)
  assert_eq(closed, 1)
}

///|
test "bounded generic function references capture caller runtime evidence" {
  let program = collect_program_manifest(
    21975UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\nfn read<t: Value>(value: t) -> I32 {\n  value.value()\n}\npub fn reader<t: Value>() -> fn(t) -> I32 {\n  read\n}\nfn invoke(callback: fn(I32) -> I32) -> I32 {\n  callback(42)\n}\npub fn main() -> I32 {\n  invoke(reader())\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let read = program.modules[0].lookup_value("read").unwrap()
  let mut bound_references = 0
  for expression_index, expression in lowering.modules[0].expressions {
    match expression.kind {
      PlannedFunctionReference(target, _) if target == read => {
        let roots = lowering.modules[0].expression_evidence[expression_index]
        assert_eq(roots.length, 1)
        let root = lowering.modules[0].trait_evidence_roots[roots.start]
        match lowering.modules[0].trait_evidence[root].kind {
          BoundInferredTraitEvidence(0) => bound_references += 1
          _ => fail("expected caller-bound function-reference evidence")
        }
      }
      _ => ()
    }
  }
  assert_eq(bound_references, 1)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.evidence_function_references.length(), 2)
  let mut captured = 0
  let mut closed = 0
  for reference in link.evidence_function_references {
    assert_eq(reference.target, read)
    if reference.runtime_evidence_parameters.length == 1 {
      captured += 1
    } else {
      assert_eq(reference.runtime_evidence_parameters.length, 0)
      closed += 1
    }
  }
  assert_eq(captured, 1)
  assert_eq(closed, 1)
}

///|
test "open generic trait dictionaries preserve recursive prerequisite evidence" {
  let program = collect_program_manifest(
    21968UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn choose<t: Read>(flag: Bool, value: t) -> Read {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  invoke(choose(true, Box {\n    value: 42\n  }))\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 1)
  assert_eq(link.modules[0].trait_methods.length(), 1)
  assert_eq(link.trait_dictionary_globals.length(), 1)
  let dictionary = link.modules[0].trait_dictionaries[0]
  assert_eq(dictionary.implementation, program.modules[0].impls[1].declaration)
  assert_true(dictionary.evidence_key.length() > 0)
  assert_true(
    dictionary.evidence_key.contains(
      program.modules[0].impls[0].declaration.to_string(),
    ),
  )
}

///|
test "imported open generic trait branches link exact dictionaries" {
  let program = collect_program_manifest(
    21969UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open app.provider\nfn invoke(value: Value) -> I32 {\n  value.value()\n}\npub fn main() -> I32 {\n  invoke(choose(true, 42))\n}\n",
        ),
      ]),
      ManifestModule::new("app.provider", [
        ManifestFile::new(
          "provider.dew", b"pub trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\npub fn choose<t: Value>(flag: Bool, value: t) -> Value {\n  if flag {\n    value\n  } else {\n    value\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics.length(), 0)
  }
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 0)
  assert_eq(link.modules[1].trait_dictionaries.length(), 1)
  assert_eq(link.modules[1].trait_methods.length(), 1)
  assert_eq(link.trait_dictionary_globals.length(), 1)
  let consumer_layout = link.modules[0].trait_layouts[0]
  let provider_layout = link.modules[1].trait_layouts[0]
  assert_eq(
    link.physical_type_index(0, consumer_layout.vtable_type_index),
    link.physical_type_index(1, provider_layout.vtable_type_index),
  )
  assert_eq(
    link.physical_type_index(0, consumer_layout.object_type_index),
    link.physical_type_index(1, provider_layout.object_type_index),
  )
  let choose = program.modules[1].lookup_value("choose").unwrap()
  let mut specializations = 0
  for function_ in link.functions {
    if function_.declaration == choose &&
      function_.specialization_shapes.length > 0 &&
      !function_.elided {
      specializations += 1
    }
  }
  assert_eq(specializations, 1)
}

///|
test "generic trait coercions accept nominal implementation evidence" {
  let program = collect_program_manifest(
    21967UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nstruct Item {}\nimpl Value for Item {\n  fn value(self) -> I32 {\n    42\n  }\n}\nfn erase<t: Value>(value: t) -> Value {\n  value\n}\npub fn main() -> Value {\n  erase(Item {})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let generic = program.modules[0].generic_parameters[0]
  assert_eq(
    resolved.types[resolved.generic_bound_types[generic.bounds.start]],
    resolved.types[resolved.impl_trait_types[0]],
  )
  assert_eq(analyzed.modules[0].inferred.impl_index.diagnostics.length(), 0)
  let implementation = program.modules[0].impls[0].declaration
  let mut valid = false
  for candidate in analyzed.modules[0].inferred.impl_index.implementations {
    if candidate.declaration == implementation {
      valid = candidate.valid && candidate.coherent
      break
    }
  }
  assert_true(valid)
  let trait_declaration = program.modules[0].lookup_trait("Value").unwrap()
  let item_declaration = program.modules[0].lookup_type("Item").unwrap()
  let mut bucketed = false
  for bucket in analyzed.modules[0].inferred.impl_index.buckets {
    if bucket.kind == TraitImplBucket(trait_declaration) &&
      bucket.target_head == NominalImplTargetHead(item_declaration) {
      bucketed = bucket.implementations.length == 1
      break
    }
  }
  assert_true(bucketed)
  let main = program.modules[0].lookup_value("main").unwrap()
  let call = body_calls(
      program.modules[0],
      program.modules[0].body_of(main).unwrap(),
    )[0]
  match analyzed.modules[0].inferred.call_targets[call] {
    SelectedInferredCallTarget(_, arguments) =>
      match
        analyzed.modules[0].inferred.type_term(
          analyzed.modules[0].inferred.call_type_arguments[arguments.start],
        ) {
        BodyResolvedType(type_) =>
          assert_eq(
            resolved.types[type_],
            NominalType(program.modules[0].lookup_type("Item").unwrap()),
          )
        _ => fail("expected resolved nominal generic call argument")
      }
    _ => fail("expected selected generic call")
  }
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "transparent runtime trait wrappers devirtualize exact call-site evidence" {
  let program = collect_program_manifest(
    2197UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {\n  value: I32\n}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    self.value\n  }\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read()\n}\npub fn main() -> I32 {\n  invoke(Item {\n    value: 35\n  }) + invoke(7)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let module_ = lowering.modules[0]
  let collected = program.modules[0]
  let body = collected.body_of(collected.lookup_value("main").unwrap()).unwrap()
  let mut direct_impl_calls = 0
  for call in body_calls(collected, body) {
    match module_.expressions[call].kind {
      PlannedDirectCall(target, receiver, _, _) if receiver >= 0 =>
        match module_.functions.callable_of(target) {
          Some({ kind: PlannedImplMethodCallable(_, _), .. }) =>
            direct_impl_calls += 1
          _ => ()
        }
      _ => ()
    }
  }
  assert_eq(direct_impl_calls, 2)
  for expression in module_.expressions {
    assert_eq(expression.trait_object_coercion, NoInferredTraitObjectCoercion)
  }
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 0)
  assert_eq(link.trait_dictionary_globals.length(), 0)
}

///|
test "exact runtime trait flows erase generic prerequisite forwarding chains" {
  let program = collect_program_manifest(
    21975UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Value {\n  fn value(self) -> I32\n}\nimpl Value for I32 {\n  fn value(self) -> I32 {\n    self\n  }\n}\ntrait Read {\n  fn read(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t: Value> Read for Box<t> {\n  fn read(self) -> I32 {\n    self.value.value()\n  }\n}\nfn identity(value: Read) -> Read {\n  value\n}\nfn invoke(value: Read) -> I32 {\n  let selected = if true {\n    value\n  } else {\n    value\n  }\n  selected.read()\n}\nfn forward(value: Read) -> I32 {\n  invoke(identity(value))\n}\npub fn main() -> I32 {\n  let selected = identity(Box {\n    value: 42\n  })\n  forward(selected)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let module_ = lowering.modules[0]
  let identity = program.modules[0].lookup_value("identity").unwrap()
  let invoke = program.modules[0].lookup_value("invoke").unwrap()
  let forward = program.modules[0].lookup_value("forward").unwrap()
  assert_true(lowering.elided_trait_wrappers.contains(identity))
  assert_true(lowering.elided_trait_wrappers.contains(invoke))
  assert_true(lowering.elided_trait_wrappers.contains(forward))
  for expression_index, expression in module_.expressions {
    assert_eq(expression.trait_object_coercion, NoInferredTraitObjectCoercion)
    match expression.kind {
      PlannedDynamicTraitCall(_, _, _, _, _, _) =>
        fail(
          "exact forwarding chain retained dynamic dispatch at \{expression_index}",
        )
      _ => ()
    }
  }
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 0)
  assert_eq(link.modules[0].trait_methods.length(), 0)
  assert_eq(link.trait_dictionary_globals.length(), 0)
  let mut adapters = 0
  let mut wrappers = 0
  for function_ in link.functions {
    match function_.kind {
      PlannedWasmTraitAdapterFunction(_, _) => adapters += 1
      _ => ()
    }
    if (
        function_.declaration == identity ||
        function_.declaration == invoke ||
        function_.declaration == forward
      ) &&
      !function_.elided {
      wrappers += 1
    }
  }
  assert_eq(adapters, 0)
  assert_eq(wrappers, 0)
  let repeated = plan_program_lowering(program, analyzed)
  assert_eq(repeated.elided_trait_wrappers, lowering.elided_trait_wrappers)
  assert_eq(
    repeated.modules[0].call_type_arguments.length(),
    lowering.modules[0].call_type_arguments.length(),
  )
  assert_eq(
    repeated.modules[0].trait_evidence_roots.length(),
    lowering.modules[0].trait_evidence_roots.length(),
  )
}

///|
test "runtime trait flow joins retain differing implementation evidence" {
  let program = collect_program_manifest(
    21976UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Read {\n  fn read(self) -> I32\n}\nstruct Left {}\nstruct Right {}\nimpl Read for Left {\n  fn read(self) -> I32 {\n    1\n  }\n}\nimpl Read for Right {\n  fn read(self) -> I32 {\n    2\n  }\n}\nfn invoke(flag: Bool, left: Read, right: Read) -> I32 {\n  let selected = if flag {\n    left\n  } else {\n    right\n  }\n  selected.read()\n}\npub fn main() -> I32 {\n  invoke(true, Left {}, Right {})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let module_ = lowering.modules[0]
  let mut dynamic_calls = 0
  let mut coercions = 0
  for expression in module_.expressions {
    match expression.kind {
      PlannedDynamicTraitCall(_, _, _, _, _, _) => dynamic_calls += 1
      _ => ()
    }
    match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, _) => coercions += 1
      _ => ()
    }
  }
  assert_eq(dynamic_calls, 1)
  assert_eq(coercions, 2)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 2)
  assert_eq(link.modules[0].trait_methods.length(), 2)
}

///|
test "public runtime trait summaries discard total effect-free preludes" {
  let program = collect_program_manifest(
    21977UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\npub fn condition() -> Bool {\n  true\n}\npub fn invoke(value: Read) -> I32 {\n  let selected = if condition() {\n    value\n  } else {\n    value\n  }\n  selected.read()\n}\npub fn main() -> I32 {\n  invoke(Item {})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let invoke = collected.lookup_value("invoke").unwrap()
  assert_false(lowering.elided_trait_wrappers.contains(invoke))
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let call = body_calls(collected, body)[0]
  match lowering.modules[0].expressions[call].kind {
    PlannedDirectCall(target, receiver, _, _) if receiver >= 0 =>
      match lowering.modules[0].functions.callable_of(target) {
        Some({ kind: PlannedImplMethodCallable(_, _), .. }) => ()
        _ => fail("expected exact public trait implementation call")
      }
    _ => fail("expected public trait summary directization")
  }
  let mut coercions = 0
  for expression in lowering.modules[0].expressions {
    match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, _) => coercions += 1
      _ => ()
    }
  }
  assert_eq(coercions, 0)
}

///|
test "public runtime trait summaries retain trapping preludes" {
  let program = collect_program_manifest(
    21978UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\npub fn condition() -> Bool {\n  assert(false, \"observable prelude\")\n  true\n}\npub fn invoke(value: Read) -> I32 {\n  let selected = if condition() {\n    value\n  } else {\n    value\n  }\n  selected.read()\n}\npub fn main() -> I32 {\n  invoke(Item {})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let collected = program.modules[0]
  let main = collected.lookup_value("main").unwrap()
  let body = collected.body_of(main).unwrap()
  let invoke = collected.lookup_value("invoke").unwrap()
  let mut retained_call = false
  for call in body_calls(collected, body) {
    match lowering.modules[0].expressions[call].kind {
      PlannedDirectCall(target, _, _, _) if target == invoke =>
        retained_call = true
      _ => ()
    }
  }
  assert_true(retained_call)
  let mut coercions = 0
  for expression in lowering.modules[0].expressions {
    match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(_, _) => coercions += 1
      _ => ()
    }
  }
  assert_eq(coercions, 1)
}

///|
test "runtime trait link executes imported traits and implementations" {
  let program = collect_program_manifest(
    2198UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open fixture.library\nfn invoke(value: Mark) -> I32 {\n  value.mark() + 0\n}\npub fn main() -> I32 {\n  invoke(item())\n}\n",
        ),
      ]),
      ManifestModule::new("fixture.library", [
        ManifestFile::new(
          "library.dew", b"pub struct Item {\n  value: I32\n}\npub trait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for Item {\n  fn mark(self) -> I32 {\n    self.value + 1\n  }\n}\npub fn item() -> Item {\n  Item {\n    value: 41\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let consumer_index = program.module_index("app.main").unwrap()
  let analyzed = analyze_program_semantics(program)
  assert_eq(
    analyzed.modules[consumer_index].inferred.impl_index.diagnostics.length(),
    0,
  )
  assert_eq(analyzed.modules[consumer_index].inferred.diagnostics.length(), 0)
  let lowering = plan_program_lowering(program, analyzed)
  let consumer = lowering.modules[consumer_index]
  let consumer_module = program.modules[consumer_index]
  let main = consumer_module.lookup_value("main").unwrap()
  let main_body = consumer_module.body_of(main).unwrap()
  let invoke = consumer_module.lookup_value("invoke").unwrap()
  let mut invoke_calls = 0
  for call in body_calls(consumer_module, main_body) {
    match consumer.expressions[call].kind {
      PlannedDirectCall(declaration, _, arguments, _) if declaration == invoke => {
        assert_eq(arguments.length, 1)
        invoke_calls += 1
      }
      _ => ()
    }
  }
  assert_eq(invoke_calls, 1)
  let mut trait_declaration = 0UL
  let mut evidence_index = -1
  for expression in consumer.expressions {
    match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, evidence) => {
        trait_declaration = trait_
        evidence_index = evidence
      }
      _ => ()
    }
  }
  assert_true(trait_declaration != 0UL)
  let requirements = wasmgc_trait_requirements(
    consumer.functions,
    Some(analyzed.modules[consumer_index].imports),
    trait_declaration,
  )
  assert_eq(requirements.length(), 1)
  let implementation = wasmgc_trait_evidence_implementation(
    consumer, evidence_index,
  ).unwrap()
  let implementation_method = wasmgc_trait_implementation_method(
    consumer.functions,
    Some(analyzed.modules[consumer_index].imports),
    implementation,
    requirements[0],
  ).unwrap()
  let (receiver_shape, receiver_nominal) = wasmgc_trait_implementation_receiver(
    analyzed.frozen.interfaces[consumer_index].resolved_types,
    consumer.functions,
    Some(analyzed.modules[consumer_index].imports),
    implementation,
    implementation_method,
  )
  assert_eq(receiver_shape, RefPlannedValueShape)
  assert_true(receiver_nominal != 0UL)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[consumer_index].trait_layouts.length(), 1)
  assert_eq(link.modules[consumer_index].trait_layouts[0].methods.length, 1)
  assert_eq(link.modules[consumer_index].trait_dictionaries.length(), 1)
  assert_eq(
    link.modules[consumer_index].trait_dictionaries[0].methods.length,
    1,
  )
}

///|
test "runtime trait dictionaries distinguish generic prerequisite evidence" {
  let program = collect_program_manifest(
    21985UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Marker {\n  fn marker(self) -> I32\n}\ntrait Value {\n  fn value(self) -> I32\n}\nstruct Yes {}\nstruct Other {}\nstruct Box<t> {\n  value: t\n}\nimpl Marker for Yes {\n  fn marker(self) -> I32 {\n    42\n  }\n}\nimpl Marker for Other {\n  fn marker(self) -> I32 {\n    7\n  }\n}\nimpl<t: Marker> Value for Box<t> {\n  fn value(self) -> I32 {\n    self.value.marker()\n  }\n}\nfn invoke(value: Value) -> I32 {\n  value.value() + 0\n}\npub fn main() -> I32 {\n  invoke(Box {\n    value: Yes {}\n  }) + invoke(Box {\n    value: Other {}\n  })\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_dictionaries.length(), 2)
  assert_true(
    link.modules[0].trait_dictionaries[0].evidence_key !=
    link.modules[0].trait_dictionaries[1].evidence_key,
  )
  assert_eq(link.modules[0].trait_methods.length(), 2)
  assert_true(
    link.modules[0].trait_methods[0].implementation_specialization_abi_key != "",
  )
  assert_true(
    link.modules[0].trait_methods[1].implementation_specialization_abi_key != "",
  )
  assert_true(
    link.modules[0].trait_methods[0].implementation_specialization_abi_key !=
    link.modules[0].trait_methods[1].implementation_specialization_abi_key,
  )
}

///|
test "runtime trait link maps typed dictionary signatures" {
  let program = collect_program_manifest(
    2199UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    42\n  }\n}\nfn invoke(value: Read) -> I32 {\n  value.read() + 0\n}\npub fn main() -> I32 {\n  invoke(Item {})\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(link.diagnostics.length(), 0)
  assert_eq(link.modules[0].trait_layouts.length(), 1)
  assert_eq(link.modules[0].trait_dictionaries.length(), 1)
  for field in link.modules[0].fields {
    match field.storage {
      WasmFunctionRefStorage(local_signature) => {
        let final_signature = link.signature_type_index(0, local_signature)
        assert_true(final_signature >= 0)
        assert_true(final_signature < link.type_count)
      }
      _ => ()
    }
  }
  for function_ in link.functions {
    if function_.signature_type_index >= 0 {
      assert_true(function_.signature_type_index < link.type_count)
    }
  }
}
