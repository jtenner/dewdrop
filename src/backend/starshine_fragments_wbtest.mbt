///|
fn backend_test_plan(
  module_id : UInt64,
  source : Bytes,
) -> @semantic.PlannedModuleWasmGCFragments {
  let collected = @semantic.collect_bytes(module_id, source)
  let resolved = @semantic.resolve_module_types(collected)
  let layouts = @semantic.plan_module_type_layouts(collected, resolved)
  let functions = @semantic.plan_module_functions(collected, resolved)
  let names = @semantic.resolve_module_names(collected)
  let inferred = @semantic.infer_module_bodies(collected, resolved, names)
  let initialization = @semantic.plan_module_initialization(
    collected,
    inferred.module_values,
  )
  let flows = @semantic.analyze_module_flows(collected, resolved, inferred)
  let lowering = @semantic.plan_module_lowering(
    collected, resolved, layouts, initialization, functions, names, inferred, flows,
  )
  @semantic.plan_module_wasmgc_fragments(resolved, lowering)
}

///|
fn backend_const_field(value : @lib.ValType) -> @lib.FieldType {
  @lib.FieldType::new(@lib.StorageType::val_type(value), @lib.Mut::const_())
}

///|
fn backend_nonnull_ref(index : @lib.TypeIdx) -> @lib.ValType {
  @lib.ValType::ref_type(@lib.RefType::new(false, @lib.HeapType::new(index)))
}

///|
test "Starshine emission preserves mutual recursive group references" {
  let planned = backend_test_plan(
    981UL, b"struct Left {\n  right: Right\n}\nstruct Right {\n  left: Left\n}\n",
  )
  let actual = emit_starshine_type_section(planned)
  let expected = @lib.TypeSec::new([
    @lib.RecType::group([
      @lib.SubType::comp_type(
        @lib.CompType::struct_([
          backend_const_field(backend_nonnull_ref(@lib.TypeIdx::rec(1U))),
        ]),
      ),
      @lib.SubType::comp_type(
        @lib.CompType::struct_([
          backend_const_field(backend_nonnull_ref(@lib.TypeIdx::rec(0U))),
        ]),
      ),
    ]),
  ])
  assert_eq(actual, expected)
}

///|
test "Starshine emission uses a recursive group for a self reference" {
  let planned = backend_test_plan(982UL, b"struct Node {\n  next: Node\n}\n")
  let actual = emit_starshine_type_section(planned)
  let expected = @lib.TypeSec::new([
    @lib.RecType::group([
      @lib.SubType::comp_type(
        @lib.CompType::struct_([
          backend_const_field(backend_nonnull_ref(@lib.TypeIdx::rec(0U))),
        ]),
      ),
    ]),
  ])
  assert_eq(actual, expected)
}

///|
test "Starshine enum emission uses a base and direct payload subtype" {
  let planned = backend_test_plan(
    983UL, b"enum Step {\n  Done\n  Next(Node)\n}\nstruct Node {\n  step: Step\n}\n",
  )
  let actual = emit_starshine_type_section(planned)
  let expected = @lib.TypeSec::new([
    @lib.RecType::new(
      @lib.SubType::new(
        false,
        [],
        @lib.CompType::struct_([backend_const_field(@lib.ValType::i32())]),
      ),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(
        @lib.CompType::struct_([
          backend_const_field(backend_nonnull_ref(@lib.TypeIdx::new(0U))),
        ]),
      ),
    ),
    @lib.RecType::new(
      @lib.SubType::new(
        true,
        [@lib.TypeIdx::new(0U)],
        @lib.CompType::struct_([
          backend_const_field(@lib.ValType::i32()),
          backend_const_field(backend_nonnull_ref(@lib.TypeIdx::new(1U))),
        ]),
      ),
    ),
  ])
  assert_eq(actual, expected)
}

///|
test "Starshine validates emitted recursive and subtype type sections" {
  let recursive = backend_test_plan(
    985UL, b"struct Left {\n  right: Right\n}\nstruct Right {\n  left: Left\n}\n",
  )
  let subtype = backend_test_plan(
    986UL, b"enum Step {\n  Done\n  Next(Node)\n}\nstruct Node {\n  step: Step\n}\n",
  )
  assert_eq(validate_starshine_type_fragments(recursive), Ok(()))
  assert_eq(validate_starshine_type_fragments(subtype), Ok(()))
}

///|
test "Starshine callable sections keep all signatures but only definitions" {
  let planned = backend_test_plan(
    984UL, b"foreign import \"dew\" as Host {\n  fn host(value: I32) -> I32 = \"host\"\n}\ntrait Read {\n  fn read(self) -> I32\n}\nfn call(value: I32) -> I32 {\n  Host.host(value)\n}\nstruct Item {}\nimpl Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\n",
  )
  let type_section = emit_starshine_type_section(planned)
  let expected_types = @lib.TypeSec::new([
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_([]))),
    @lib.RecType::new(
      @lib.SubType::comp_type(
        @lib.CompType::func([@lib.ValType::i32()], [@lib.ValType::i32()]),
      ),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(
        @lib.CompType::func([@lib.ValType::i32()], [@lib.ValType::i32()]),
      ),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(
        @lib.CompType::func([backend_nonnull_ref(@lib.TypeIdx::new(0U))], [
          @lib.ValType::i32(),
        ]),
      ),
    ),
  ])
  assert_eq(type_section, expected_types)
  assert_eq(
    emit_starshine_import_section(planned),
    @lib.ImportSec::new([
      @lib.Import::new(
        @lib.Name::from_string("dew"),
        @lib.Name::from_string("host"),
        @lib.ExternType::func(@lib.TypeIdx::new(1U)),
      ),
    ]),
  )
  assert_eq(
    emit_starshine_function_section(planned),
    @lib.FuncSec::new([@lib.TypeIdx::new(2U), @lib.TypeIdx::new(3U)]),
  )
}
