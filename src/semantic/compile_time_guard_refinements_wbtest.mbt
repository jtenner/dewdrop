///|
test "compile time Unit proof permits a Unit call without a hard bound" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn accept(value: Unit) -> I32 {\n  7i32\n}\nfn guarded<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    accept(value)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded::<Unit>(()) + guarded::<I64>(8i64)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time equal proof permits scalar operations and a generic return" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn guarded<t>(value: t) -> t {\n  if type_equal::<t, I32>() {\n    return value + 1i32\n  } else {\n    return value\n  }\n}\npub fn main() -> I32 {\n  guarded::<I32>(7i32)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time Unit proof joins a generic result without an early return" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn guarded<t>(fallback: t) -> t {\n  if is_unit::<t>() {\n    ()\n  } else {\n    fallback\n  }\n}\npub fn main() -> I64 {\n  guarded::<I64>(7i64)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time equality proofs preserve transitive aliases" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn guarded<a, b>(value: a) -> I32 {\n  if type_equal::<a, b>() && type_equal::<b, I32>() && type_equal::<b, a>() {\n    value + 1i32\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded::<I32, I32>(7i32)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time Unit proof does not leak to a sibling branch" {
  let program = collect_program_manifest(
    24011UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nfn accept(value: Unit) -> I32 {\n  7i32\n}\nfn guarded<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    accept(value)\n  } else {\n    accept(value)\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(program.modules[0].diagnostics, [])
  assert_eq(analyzed.modules[0].names.diagnostics, [])
  assert_true(
    analyzed.modules[0].inferred.diagnostics.any(diagnostic => {
      diagnostic is BodyConstraintDiagnostic(LocalTypeMismatch(_, _, _)) ||
      diagnostic is NoMatchingCallOverload(_, _, _)
    }),
  )
}
