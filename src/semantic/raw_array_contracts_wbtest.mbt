///|
fn raw_array_contract_test(source : Bytes) -> PlannedProgramLowering raise {
  let program = collect_program_manifest_with_standard_sources(
    2613UL,
    ProgramManifest::new([
      ManifestModule::new("app.raw", [ManifestFile::new("raw.dew", source)]),
    ]),
    StandardLibrarySources::new([]),
    true,
  )
  assert_eq(program.diagnostics, [])
  for module_ in program.modules {
    assert_eq(module_.diagnostics, [])
  }
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  plan_unoptimized_program_lowering(program, analyzed)
}

///|
test "raw array contracts bind renamed user declarations and exact element parameters" {
  let lowering = raw_array_contract_test(
    b"struct Padding {}\npub struct Storage<t> {}\nbuiltin create<unused, t>(length: U32, value: t) -> Storage<t> = \"array_new\"\nbuiltin read<t>(value: Storage<t>, index: U32) -> t = \"array_get\"\npub fn run() -> I64 {\n  read(create::<I32, I64>(2u32, 7i64), 0u32)\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics, [])
  assert_true(
    module_.raw_array_declarations.contains(
      make_semantic_id(module_.module_id, 1),
    ),
  )
  assert_false(
    module_.raw_array_declarations.contains(
      make_semantic_id(module_.module_id, 0),
    ),
  )
  assert_true(
    module_.expressions.any(fn(value) {
      value.kind is PlannedFixedArrayMake(_, _, I64PlannedValueShape)
    }),
  )
  assert_true(
    module_.expressions.any(fn(value) {
      value.kind is PlannedFixedArrayGetUnchecked(_, _, I64PlannedValueShape)
    }),
  )
}

///|
test "raw array contracts diagnose an invalid instruction signature" {
  let lowering = raw_array_contract_test(
    b"pub struct Storage<t> {}\nbuiltin read<t>(value: Storage<t>, index: I64) -> t = \"array_get\"\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics.length(), 1)
  match module_.diagnostics[0] {
    InvalidRawArrayContract(declaration, message, _) => {
      assert_eq(declaration, make_semantic_id(module_.module_id, 1))
      assert_eq(
        message, "raw array instruction signature does not match its element and scalar operand types",
      )
    }
    _ => abort("expected InvalidRawArrayContract")
  }
  assert_false(
    module_.raw_array_declarations.contains(
      make_semantic_id(module_.module_id, 0),
    ),
  )
}

///|
test "raw array contracts reject an owner with ordinary fields" {
  let lowering = raw_array_contract_test(
    b"pub struct Storage<t> {\n  value: t\n}\nbuiltin create<t>(length: U32, value: t) -> Storage<t> = \"array_new\"\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics.length(), 1)
  match module_.diagnostics[0] {
    InvalidRawArrayContract(_, message, _) =>
      assert_eq(
        message, "raw array owner must be an empty struct with one element parameter",
      )
    _ => abort("expected InvalidRawArrayContract")
  }
}

///|
test "raw array contracts reject ordinary struct allocation of raw storage" {
  let lowering = raw_array_contract_test(
    b"pub struct Storage<t> {}\nbuiltin create<t>(length: U32, value: t) -> Storage<t> = \"array_new\"\npub fn bad() -> Storage<I32> {\n  Storage::{}\n}\n",
  )
  let module_ = lowering.modules[0]
  assert_eq(module_.diagnostics.length(), 1)
  match module_.diagnostics[0] {
    InvalidRawArrayContract(_, message, _) =>
      assert_eq(
        message, "raw array storage must be allocated by an array instruction, not a struct constructor",
      )
    _ => abort("expected InvalidRawArrayContract")
  }
}
