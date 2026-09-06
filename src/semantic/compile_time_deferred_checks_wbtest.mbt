///|
test "compile time deferred checks: a missing selected field reports its source error" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn read<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    0i32\n  } else {\n    value.value\n  }\n}\npub fn main() -> I32 {\n  read(42i64)\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_true(
    linked.diagnostics.any(diagnostic => {
      match diagnostic {
        ProgramCompileTimeFailure(_, _, _, expression, message, _) =>
          expression >= 0 && message.has_prefix("CT-041")
        _ => false
      }
    }),
  )
}

///|
test "compile time deferred checks: independent errors remain in unused generic branches" {
  let program = collect_program_manifest(
    24043UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn unused<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    0i32\n  } else {\n    1i32 + false\n  }\n}\npub fn main() -> I32 {\n  42i32\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is NoMatchingMethod(_, _, _)
    }),
  )
}

///|
test "compile time deferred checks: field lookup waits for the selected owner" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Record {\n  value: I32\n}\nfn read<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    0i32\n  } else {\n    value.value\n  }\n}\npub fn main() -> I32 {\n  read(()) + read(Record::{\n    value: 42i32\n  })\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let inferred = analyze_program_semantics(program).modules[0].inferred
  assert_true(
    inferred.expression_selections.contains(DeferredExpressionSelection),
  )
  assert_eq(
    deserialize_inferred_module_bodies(
      serialize_inferred_module_bodies(inferred).unwrap(),
    ),
    Ok(inferred),
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}

///|
test "compile time deferred checks: integer operators wait for the exact primitive" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn twice<t>(value: t) -> t {\n  if is_integer::<t>() {\n    value + value\n  } else {\n    value\n  }\n}\npub fn main() -> I64 {\n  twice(())\n  twice(21i64)\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}
