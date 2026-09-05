///|
test "linear immutable locals reuse compatible physical slots" {
  let program = @semantic.collect_program_manifest(
    2608UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"struct Token {\n  value: I32\n}\nfn scalar(value: I32) -> I32 {\n  let first = value + 1\n  let second = first * 2\n  let third = second - 3\n  third\n}\nfn overlap(value: I32) -> I32 {\n  let first = value + 1\n  let second = first + 2\n  first + second\n}\nfn make_token(value: I32) -> Token {\n  Token::{\n    value: value\n  }\n}\nfn reference(value: I32) -> I32 {\n  let first = make_token(value)\n  let first_value = first.value\n  let second = make_token(first_value + 1)\n  second.value\n}\nfn generic<t>(value: t) -> t {\n  let first = value\n  let second = select(first)\n  second\n}\nfn select<t>(value: t) -> t {\n  value\n}\npub fn main() -> I32 {\n  scalar(5) + overlap(7) + reference(8) + generic(9)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(program.diagnostics.length(), 0)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
  assert_eq(link.diagnostics.length(), 0)
  let module_lowering = lowering.modules[0]
  let fragments = link.modules[0]
  let scalar = program.modules[0].lookup_value("scalar").unwrap()
  let overlap = program.modules[0].lookup_value("overlap").unwrap()
  let reference = program.modules[0].lookup_value("reference").unwrap()
  let generic = program.modules[0].lookup_value("generic").unwrap()
  let scalar_body = module_lowering.bodies[@semantic.semantic_id_local(
      program.modules[0].body_of(scalar).unwrap().id,
    )]
  let overlap_body = module_lowering.bodies[@semantic.semantic_id_local(
      program.modules[0].body_of(overlap).unwrap().id,
    )]
  let reference_body = module_lowering.bodies[@semantic.semantic_id_local(
      program.modules[0].body_of(reference).unwrap().id,
    )]
  let generic_body = module_lowering.bodies[@semantic.semantic_id_local(
      program.modules[0].body_of(generic).unwrap().id,
    )]
  let (_, scalar_types, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = starshine_body_locals(
    module_lowering,
    fragments,
    Some(link),
    None,
    scalar_body,
    0,
  )
  let (_, overlap_types, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = starshine_body_locals(
    module_lowering,
    fragments,
    Some(link),
    None,
    overlap_body,
    0,
  )
  let (_, reference_types, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = starshine_body_locals(
    module_lowering,
    fragments,
    Some(link),
    None,
    reference_body,
    0,
  )
  let (_, generic_types, _, _, _, _, _, _, _, _, _, _, _, _, _, _) = starshine_body_locals(
    module_lowering,
    fragments,
    Some(link),
    None,
    generic_body,
    0,
  )
  assert_eq(scalar_types.length(), 1)
  assert_eq(overlap_types.length(), 2)
  assert_eq(reference_types.length(), 2)
  assert_eq(generic_types.length(), 1)
  let module_ = emit_starshine_program_module(lowering, link).unwrap()
  assert_eq(@validate.validate_module(module_), Ok(()))
}
