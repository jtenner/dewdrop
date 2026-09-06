///|
test "compile time selected binding: unused generic bindings are checked in selected bodies" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nfn check<T>() -> I32 {\n  type Item = field_type<T>(\"value\")\n  42i32\n}\npub fn main() -> I32 {\n  check::<I64>()\n}\n",
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
          expression >= 0 && message.has_prefix("CT-043")
        _ => false
      }
    }),
  )
}

///|
test "compile time selected binding: discarded generic bindings need no member layout" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Record {\n  value: I32\n}\nfn check<T>() -> I32 {\n  if is_unit::<T>() {\n    0i32\n  } else {\n    type Item = field_type<T>(\"value\")\n    42i32\n  }\n}\npub fn main() -> I32 {\n  check::<Unit>() + check::<Record>()\n}\n",
  )
  let fragments = plan_program_wasmgc_fragments(
    analyze_program_semantics(program),
    lowering,
  )
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
}

///|
test "compile time selected binding: selected generic payload bindings validate their variant" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nenum Choice {\n  Yes(I32)\n}\nfn check<T>() -> I32 {\n  type Payload = variant_payload_types<T>(\"Missing\")\n  42i32\n}\npub fn main() -> I32 {\n  check::<Choice>()\n}\n",
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
          expression >= 0 && message.has_prefix("CT-043")
        _ => false
      }
    }),
  )
}
