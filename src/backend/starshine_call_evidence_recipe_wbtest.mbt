///|
test "emission reports a changed trait operand with complete numeric context" {
  let program = @semantic.collect_program_manifest(
    28122UL,
    @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app.main", [
        @semantic.ManifestFile::new(
          "main.dew", b"trait Left {\n  fn left(self) -> I32\n}\ntrait Right {\n  fn right(self) -> I32\n}\nimpl Left for I32 {\n  fn left(self) -> I32 {\n    self\n  }\n}\nimpl Right for I64 {\n  fn right(self) -> I32 {\n    2i32\n  }\n}\nfn need<a: Left, b: Right>(left: a, right: b) -> I32 {\n  left.left() + right.right()\n}\npub fn relay<a: Left, b: Right>(left: a, right: b) -> I32 {\n  need(left, right)\n}\npub fn main() -> I32 {\n  relay(1i32, 2i64)\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let link = @semantic.plan_program_wasmgc_link(analyzed, lowering, 0)
  assert_eq(
    @semantic.collect_compiler_source_diagnostics(
      program, analyzed, lowering, link,
    ),
    [],
  )
  assert_eq(
    @validate.validate_module(
      emit_starshine_program_module(lowering, link).unwrap(),
    ),
    Ok(()),
  )
  let declaration = program.modules[0].lookup_value("need").unwrap()
  let keys : Array[@semantic.ProgramSpecializedCallKey] = []
  for key, span in link.specialized_call_runtime_evidence_lookup {
    if span.length == 2 &&
      link.specialized_call_targets[key].declaration == declaration {
      keys.push(key)
    }
  }
  assert_eq(keys.length(), 1)
  let key = keys[0]
  let span = link.specialized_call_runtime_evidence_lookup[key]
  assert_eq(
    starshine_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Ok(Some(span)),
  )
  let expected = link.specialized_call_runtime_evidence_parameters[span.start]
  let actual = link.specialized_call_runtime_evidence_parameters[span.start + 1]
  assert_true(expected != actual)
  link.specialized_call_runtime_evidence_parameters[span.start] = actual
  assert_eq(
    starshine_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
    ),
    Err(
      CompilerInvariantFailure({
        code: 704U,
        phase: 7U,
        module_id: 28122UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: expected.to_uint64(),
        actual: actual.to_uint64(),
        detail: 0UL,
      }),
    ),
  )
}
