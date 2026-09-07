///|
fn associated_trait_query_test(source : Bytes, expected : Bool) -> Unit raise {
  let program = collect_program_manifest(
    28130UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
      ManifestModule::new("app.library", [
        ManifestFile::new(
          "library.dew", b"open dew.std.types\npub trait Mark {}\npub trait Read {}\npub fn has<t>() -> Bool {\n  implements::<t, Read>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let library = program.module_index("app.library").unwrap()
  let declaration = program.modules[library].lookup_value("has").unwrap()
  let body = program.modules[library].body_of(declaration).unwrap()
  let mut count = 0
  for function_ in fragments.modules[library].functions {
    if function_.declaration == declaration &&
      function_.specialization_shapes.length > 0 {
      let instance = program_function_lowering(
        lowering,
        library,
        function_.specialization_abi_key,
      )
      assert_eq(instance.diagnostics, [])
      assert_eq(
        instance.expressions[optimization_test_body_tail(instance, body.id)].kind,
        PlannedBoolConst(expected),
      )
      count += 1
    }
  }
  assert_eq(count, 1)
}

///|
test "associated query finds a module-visible nominal implementation" {
  associated_trait_query_test(
    b"open app.library\nstruct Key {}\nimpl Read for Key {}\npub fn main() -> Bool {\n  has::<Key>()\n}\n",
    true,
  )
}

///|
test "associated query does not import a defining module foreign implementation" {
  associated_trait_query_test(
    b"open app.library\nstruct Key {}\nforeign impl Read for Key {}\npub fn main() -> Bool {\n  has::<Key>()\n}\n",
    false,
  )
}

///|
test "associated query prerequisites do not acquire foreign scope" {
  associated_trait_query_test(
    b"open app.library\nstruct Box<t> {\n  value: t\n}\nforeign impl Mark for I32 {}\nimpl<t: Mark> Read for Box<t> {}\npub fn main() -> Bool {\n  has::<Box<I32>>()\n}\n",
    false,
  )
}

///|
test "Self and generic parameters have separate signature binding identities" {
  let (_, lowering) = compile_time_evidence_test(
    b"pub fn main() -> I32 {\n  0i32\n}\n",
  )
  let module_ = lowering.modules[0]
  let self_id = module_.resolved_types.length()
  module_.resolved_types.push(SelfType(42UL))
  let parameter_id = module_.resolved_types.length()
  module_.resolved_types.push(GenericParameterType(42UL))
  let start = module_.resolved_type_arguments.length()
  module_.resolved_type_arguments.push(self_id)
  module_.resolved_type_arguments.push(parameter_id)
  let product = module_.resolved_types.length()
  module_.resolved_types.push(ProductType({ start, length: 2, }))
  assert_eq(
    compile_time_read_type(
      module_,
      -product - 2,
      { 42UL: CtPrimitive(I32Type) },
      self_binding=Some((42UL, CtPrimitive(I64Type))),
    ),
    Ok(CtProduct([CtPrimitive(I64Type), CtPrimitive(I32Type)])),
  )
}
