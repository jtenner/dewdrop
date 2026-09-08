///|
fn call_frame_test_data() -> (
  @semantic.PlannedProgramWasmGCLink,
  @semantic.ProgramSpecializedCallKey,
  @semantic.DeclId,
  @semantic.HirSpan,
  StarshineCallFrameParameters,
) raise {
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
  let callers : Array[Int] = []
  for index, function_ in link.functions {
    if function_.specialization_abi_key == key.specialization_abi_key &&
      !function_.elided {
      match function_.kind {
        @semantic.PlannedWasmDefinedFunction(body) if body == key.body =>
          callers.push(index)
        _ => ()
      }
    }
  }
  assert_eq(callers.length(), 1)
  let caller = link.functions[callers[0]]
  let frame = starshine_call_frame_parameters(
    link.modules[caller.module_index],
    caller.parameters,
  )
  assert_eq(frame.length, 4)
  (link, key, declaration, span, frame)
}

///|
test "emission reports a changed trait operand with complete numeric context" {
  let (link, key, declaration, span, frame) = call_frame_test_data()
  assert_eq(
    starshine_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
      frame,
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
      frame,
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

///|
test "trait operands must fit the emitted caller parameter frame" {
  let (link, key, declaration, span, frame) = call_frame_test_data()
  assert_eq(
    starshine_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
      frame,
    ),
    Ok(Some(span)),
  )
  let shorter = { ..frame, length: 2, }
  assert_eq(
    starshine_call_runtime_evidence(
      link,
      key.body,
      key.specialization_abi_key,
      key.expression,
      shorter,
    ),
    Err(
      CompilerInvariantFailure({
        code: 704U,
        phase: 7U,
        module_id: 28122UL,
        declaration,
        body: key.body,
        expression: key.expression.reinterpret_as_uint(),
        expected: 2UL,
        actual: 2UL,
        detail: 0UL,
      }),
    ),
  )
}

///|
test "each trait operand is checked against the caller frame" {
  let (link, key, declaration, _, frame) = call_frame_test_data()
  for item in [(0, 2UL, 0UL), (3, 3UL, 1UL)] {
    let (length, actual, ordinal) = item
    let changed = { ..frame, length, }
    assert_eq(
      starshine_call_runtime_evidence(
        link,
        key.body,
        key.specialization_abi_key,
        key.expression,
        changed,
      ),
      Err(
        CompilerInvariantFailure({
          code: 704U,
          phase: 7U,
          module_id: 28122UL,
          declaration,
          body: key.body,
          expression: key.expression.reinterpret_as_uint(),
          expected: length.to_uint64(),
          actual,
          detail: ordinal,
        }),
      ),
    )
  }
}

///|
test "caller parameter spans are checked before their types can be read" {
  let (link, key, declaration, _, frame) = call_frame_test_data()
  for
    changed in [
      { ..frame, start: -1, },
      { ..frame, start: 2147483647, },
      { ..frame, length: -1, },
      { ..frame, length: frame.values.length() - frame.start + 1, },
      { ..frame, values: [], },
    ] {
    assert_eq(
      starshine_call_runtime_evidence(
        link,
        key.body,
        key.specialization_abi_key,
        key.expression,
        changed,
      ),
      Err(
        CompilerInvariantFailure({
          code: 101U,
          phase: 7U,
          module_id: 28122UL,
          declaration,
          body: key.body,
          expression: key.expression.reinterpret_as_uint(),
          expected: changed.values.length().to_uint64(),
          actual: (changed.start.reinterpret_as_uint().to_uint64() << 32) |
          changed.length.reinterpret_as_uint().to_uint64(),
          detail: 1UL << 32,
        }),
      ),
    )
  }
}
