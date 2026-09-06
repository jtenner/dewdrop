///|
test "compile time implements guards a trait method without a hard bound" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    value.read()\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  read_or_zero::<I32>(42i32) + read_or_zero::<I64>(7i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  let link = link_program_wasmgc_fragments(plan, lowering, 0)
  assert_eq(link.diagnostics, [])
  let mut concrete_calls = 0
  for _, instance in lowering.compile_time.unwrap().instances {
    assert_eq(instance.module_.diagnostics, [])
    for expression in instance.module_.expressions {
      if expression.kind is PlannedDirectCall(target, _, _, _) {
        if instance.module_.functions.callable_of(target) is Some(callable) &&
          callable.kind is PlannedImplMethodCallable(_, _) {
          concrete_calls += 1
        }
      }
    }
  }
  assert_true(concrete_calls > 0)
}

///|
test "compile time implements guard does not leak into the false branch" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    0i32\n  } else {\n    value.read()\n  }\n}\npub fn main() -> I32 {\n  read_or_zero(7i64)\n}\n",
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
test "compile time implements negated guard checks the else branch" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn read_or_zero<t>(value: t) -> I32 {\n  if !implements::<t, Read>() {\n    0i32\n  } else {\n    value.read()\n  }\n}\npub fn main() -> I32 {\n  read_or_zero::<I32>(42i32)\n}\n",
  )
  let plan = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time implements proof satisfies a guarded ordinary function bound" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\nfn read<t: Read>(value: t) -> I32 {\n  value.read()\n}\nfn guarded<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    read(value)\n  } else {\n    0i32\n  }\n}\npub fn main() -> I32 {\n  guarded::<I32>(42i32) + guarded::<I64>(7i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let inferred = analyzed.modules[0].inferred
  assert_true(
    inferred.trait_evidence.any(evidence => {
      evidence.kind is GuardedInferredTraitEvidence(_, _)
    }),
  )
  assert_eq(
    deserialize_inferred_module_bodies(
      serialize_inferred_module_bodies(inferred).unwrap(),
    ),
    Ok(inferred),
  )
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(link_program_wasmgc_fragments(plan, lowering, 0).diagnostics, [])
}

///|
test "compile time implements proof cannot satisfy a sibling function call bound" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\ntrait Read {\n  fn read(self) -> I32\n}\nfn read<t: Read>(value: t) -> I32 {\n  value.read()\n}\nfn guarded<t>(value: t) -> I32 {\n  if implements::<t, Read>() {\n    0i32\n  } else {\n    read(value)\n  }\n}\npub fn main() -> I32 {\n  guarded(7i64)\n}\n",
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
