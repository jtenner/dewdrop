///|
test "compile time discarded generic constructors do not demand nominal storage" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nenum Ghost<t> {\n  Value(t)\n}\nfn choose<t>() -> I32 {\n  if is_unit::<t>() {\n    7i32\n  } else {\n    let value = Ghost::Value(8i64)\n    match value {\n      Ghost::Value(_) => 9i32\n    }\n  }\n}\npub fn main() -> I32 {\n  choose::<Unit>()\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(lowering.modules[0].diagnostics, [])
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  let ghost = program.modules[0].lookup_type("Ghost").unwrap()
  assert_false(
    plan.modules[0].type_index_by_declaration[semantic_id_local(ghost)] >= 0,
  )
}

///|
test "compile time selected generic constructors retain their nominal storage" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nenum Ghost<t> {\n  Value(t)\n}\nfn choose<t>() -> I32 {\n  if is_unit::<t>() {\n    7i32\n  } else {\n    let value = Ghost::Value(8i64)\n    match value {\n      Ghost::Value(_) => 9i32\n    }\n  }\n}\npub fn main() -> I32 {\n  choose::<I64>()\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  let ghost = program.modules[0].lookup_type("Ghost").unwrap()
  assert_true(
    plan.modules[0].type_index_by_declaration[semantic_id_local(ghost)] >= 0,
  )
}

///|
test "compile time nominal demand follows recursive fields once" {
  let (program, lowering) = compile_time_evidence_test(
    b"struct Leaf {\n  value: I64\n}\nstruct Node {\n  leaf: Leaf\n  next: Node\n}\npub fn read(value: Node) -> I64 {\n  value.leaf.value\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  for name in ["Leaf", "Node"] {
    let declaration = program.modules[0].lookup_type(name).unwrap()
    assert_true(
      plan.modules[0].type_index_by_declaration[semantic_id_local(declaration)] >=
      0,
    )
  }
}

///|
test "compile time member owners do not create unused runtime records" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: field_type<t>(\"item\")) -> field_type<t>(\"item\") {\n  value\n}\npub fn main() -> I64 {\n  keep::<Box<I64>>(42i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  let plan = plan_program_wasmgc_fragments(analyzed, lowering)
  let box = program.modules[0].lookup_type("Box").unwrap()
  assert_eq(
    plan.modules[0].type_index_by_declaration[semantic_id_local(box)],
    -1,
  )
}
