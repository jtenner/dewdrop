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
