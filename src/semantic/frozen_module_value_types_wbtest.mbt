///|
fn frozen_value_dag_source(
  depth : Int32,
  record : Bool,
  public_dag : Bool,
) -> Bytes {
  let source = Buffer(size_hint=depth * 96 + 256)
  if record {
    source.write_string_utf8("struct Pair<a, b> {\n  left: a\n  right: b\n}\n")
  }
  source.write_string_utf8("let node0 = 1i32\n")
  for index in 1..<=depth {
    let previous = "node" + (index - 1).to_string()
    source.write_string_utf8("let node" + index.to_string() + " = ")
    source.write_string_utf8(
      if record {
        "Pair::{\n  left: " + previous + "\n  right: " + previous + "\n}\n"
      } else {
        "(" + previous + ", " + previous + ")\n"
      },
    )
  }
  if public_dag {
    source.write_string_utf8(
      "pub let exported = node" +
      depth.to_string() +
      "\npub let same = node" +
      depth.to_string() +
      "\n",
    )
  } else {
    source.write_string_utf8("pub let exported = 42i32\n")
  }
  source.to_bytes()
}

///|
test "frozen public value type DAGs share one conversion memo" {
  let depth = 20
  for record in [false, true] {
    let collected = collect_program_bytes(
      28430UL,
      frozen_value_dag_source(depth, record, true),
    )
    assert_eq(collected.diagnostics, [])
    let resolved = resolve_module_types(collected)
    assert_eq(resolved.diagnostics, [])
    let values = infer_module_values(
      collected,
      resolved,
      resolve_module_names(collected),
    )
    assert_eq(values.diagnostics, [])
    let memo : Map[BodyTypeId, ResolvedTypeId] = {}
    let first = frozen_body_type_to_resolved(
      resolved,
      values,
      values.let_types[depth + 1],
      memo,
    )
    let count = memo.length()
    let type_count = resolved.types.length()
    let second = frozen_body_type_to_resolved(
      resolved,
      values,
      values.let_types[depth + 2],
      memo,
    )
    assert_eq(first, second)
    assert_eq(resolved.types.length(), type_count)
    assert_true(count >= depth + 1)
    assert_true(count <= depth * 2 + 4)
    let total = memo.length()
    assert_true(total <= depth * 4 + 8)
    assert_eq(
      frozen_body_type_to_resolved(
        resolved,
        values,
        values.let_types[depth + 1],
        memo,
      ),
      first,
    )
    assert_eq(memo.length(), total)
    assert_true(
      resolved.types[first] is ProductType(_) ||
      resolved.types[first] is AppliedType(_, _),
    )
  }
}

///|
test "frozen scalar exports do not convert private value type DAGs" {
  let collected = collect_program_bytes(
    28431UL,
    frozen_value_dag_source(16, false, false),
  )
  assert_eq(collected.diagnostics, [])
  let resolved = resolve_module_types(collected)
  let values = infer_module_values(
    collected,
    resolved,
    resolve_module_names(collected),
  )
  assert_eq(values.diagnostics, [])
  let type_count = resolved.types.length()
  let argument_count = resolved.type_arguments.length()
  let interface_ = freeze_module_interface(
    "app.values",
    collected,
    resolved,
    plan_module_functions(collected, resolved),
    module_values=Some(values),
  )
  assert_eq(interface_.declarations.map(value => value.name), ["exported"])
  assert_eq(resolved.types.length(), type_count)
  assert_eq(resolved.type_arguments.length(), argument_count)
}
