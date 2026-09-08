///|
fn function_lookup_test_link() -> (PlannedProgramWasmGCLink, DeclId, Int) raise {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics, [])
  let declaration = program.modules[0].lookup_value("run").unwrap()
  (link, declaration, link.function_lookup[declaration])
}

///|
test "all plain lookup entries retain their fragment identity" {
  let (link, _, _) = function_lookup_test_link()
  assert_eq(verify_program_named_function_lookups(link), Ok(()))
  for declaration, index in link.function_lookup {
    assert_eq(
      check_program_named_function_lookup(link, declaration),
      Ok(Some(link.functions[index])),
    )
  }
}

///|
test "missing named functions stay missing" {
  let (link, declaration, _) = function_lookup_test_link()
  let _ = link.function_lookup.remove(declaration)
  assert_eq(check_program_named_function_lookup(link, declaration), Ok(None))
  assert_eq(link.function_of(declaration), None)
}

///|
test "named function table bounds are checked before reads" {
  let (link, declaration, _) = function_lookup_test_link()
  for index in [-1, link.functions.length()] {
    link.function_lookup[declaration] = index
    assert_eq(
      check_program_named_function_lookup(link, declaration),
      Err({
        code: 101,
        phase: 5,
        module_id: 2100UL,
        declaration,
        body: 0UL,
        expression: 0xffffffffU,
        expected: link.functions.length().to_uint64(),
        actual: index.reinterpret_as_uint().to_uint64(),
        detail: 0UL,
      }),
    )
  }
}

///|
test "named function ownership and instance metadata remain exact" {
  let (link, declaration, index) = function_lookup_test_link()
  let original = link.functions[index]
  let module_ = link.modules[original.module_index]
  let cases : Array[(PlannedProgramWasmFunction, Int, UInt64, UInt64, UInt64)] = [
    (
      { ..original, module_index: -1, },
      101,
      link.modules.length().to_uint64(),
      0xffffffffUL,
      1UL,
    ),
    (
      { ..original, module_index: link.module_lookup[2101UL], },
      504,
      2100UL,
      2101UL,
      2UL,
    ),
    (
      { ..original, fragment_index: -1, },
      101,
      module_.functions.length().to_uint64(),
      0xffffffffUL,
      3UL,
    ),
    ({ ..original, lambda: 7, }, 504, 0xffffffffUL, 7UL, 6UL),
    ({ ..original, specialization_abi_key: "wrong-key", }, 504, 1UL, 0UL, 7UL),
    (
      { ..original, kind: PlannedWasmSignatureOnlyFunction, },
      504,
      1UL,
      0UL,
      8UL,
    ),
  ]
  for item in cases {
    let (mutated, code, expected, actual, role) = item
    link.functions[index] = mutated
    assert_eq(
      check_program_named_function_lookup(link, declaration),
      Err({
        code,
        phase: 5,
        module_id: 2100UL,
        declaration,
        body: 0UL,
        expression: 0xffffffffU,
        expected,
        actual,
        detail: (role << 32) | index.to_uint64(),
      }),
    )
  }
}

///|
test "imported trait requirements keep local signature fragments" {
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
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics, [])
  let mut imported = 0
  for declaration, index in link.function_lookup {
    let function_ = link.functions[index]
    if link.modules[function_.module_index].module_id !=
      semantic_id_module(declaration) {
      assert_true(function_.kind is PlannedWasmSignatureOnlyFunction)
      assert_eq(
        check_program_named_function_lookup(link, declaration),
        Ok(Some(function_)),
      )
      imported += 1
    }
  }
  assert_true(imported > 0)
  assert_eq(verify_program_named_function_lookups(link), Ok(()))
}

///|
test "named function fragment cannot claim another declaration" {
  let (link, declaration, index) = function_lookup_test_link()
  let selected = link.functions[index]
  let module_ = link.modules[selected.module_index]
  let original = module_.functions[selected.fragment_index]
  let other = 2101UL << 32
  module_.functions[selected.fragment_index] = {
    ..original,
    declaration: other,
  }
  assert_eq(
    check_program_named_function_lookup(link, declaration),
    Err({
      code: 504,
      phase: 5,
      module_id: 2100UL,
      declaration,
      body: 0UL,
      expression: 0xffffffffU,
      expected: declaration,
      actual: other,
      detail: (4UL << 32) | index.to_uint64(),
    }),
  )
}

///|
test "plain function lookup cannot select an exact specialization" {
  let program = collect_program_manifest(
    2110UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn identity<t>(value: t) -> t {\n  value\n}\npub fn run() -> I64 {\n  identity(7i64)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_unoptimized_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics, [])
  let declaration = program.modules[0].lookup_value("identity").unwrap()
  let mut checked = 0
  for index, function_ in link.functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 {
      link.function_lookup[declaration] = index
      assert_eq(
        check_program_named_function_lookup(link, declaration),
        Err({
          code: 304,
          phase: 5,
          module_id: 2110UL,
          declaration,
          body: 0UL,
          expression: 0xffffffffU,
          expected: 0UL,
          actual: function_.specialization_shapes.length.to_uint64(),
          detail: (5UL << 32) | index.to_uint64(),
        }),
      )
      checked += 1
    }
  }
  assert_eq(checked, 1)
}

///|
test "named function lookup cannot select another declaration" {
  let (program, analyzed) = scalar_link_program()
  let link = plan_program_wasmgc_link(
    analyzed,
    plan_program_lowering(program, analyzed),
    0,
  )
  assert_eq(link.diagnostics, [])
  let run = program.modules[0].lookup_value("run").unwrap()
  let double = program.modules[1].lookup_value("double").unwrap()
  assert_eq(run, 2100UL << 32)
  assert_eq(double, 2101UL << 32)
  let selected = link.function_lookup[double]
  assert_eq(
    check_program_named_function_lookup(link, run),
    Ok(Some(link.function_of(run).unwrap())),
  )
  link.function_lookup[run] = selected
  assert_eq(
    check_program_named_function_lookup(link, run),
    Err({
      code: 504,
      phase: 5,
      module_id: 2100UL,
      declaration: run,
      body: 0UL,
      expression: 0xffffffffU,
      expected: run,
      actual: double,
      detail: selected.to_uint64(),
    }),
  )
  match check_program_named_function_lookup(link, run) {
    Err(failure) =>
      assert_eq(verify_program_named_function_lookups(link), Err(failure))
    Ok(_) => fail("link freeze must reject the wrong table target too")
  }
}
