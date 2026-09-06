///|
test "compile time member projection substitutes ordered variant payloads" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nenum Message<t> {\n  Value(t, I32)\n}\nfn keep<t>(value: variant_payload_types<t>(\"Value\")) -> variant_payload_types<t>(\"Value\") {\n  value\n}\npub fn main() -> (I64, I32) {\n  keep::<Message<I64>>((42i64, 7i32))\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
}

///|
test "compile time member projection can infer an owner from a later argument" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: field_type<t>(\"item\"), owner: t) -> field_type<t>(\"item\") {\n  value\n}\npub fn main() -> I64 {\n  keep(42i64, Box::{\n    item: 0i64\n  })\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
}

///|
test "compile time member projection instantiates runtime call signatures" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: field_type<t>(\"item\")) -> field_type<t>(\"item\") {\n  value\n}\npub fn main() -> I64 {\n  keep::<Box<I64>>(42i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let keep = program.modules[0].lookup_value("keep").unwrap()
  assert_eq(
    lowering.modules[0].functions.callable_of(keep).unwrap().result_shape,
    GenericPlannedValueShape,
  )
  let mut count = 0
  for function_ in fragments.modules[0].functions {
    if function_.declaration == keep &&
      !function_.elided &&
      function_.specialization_shapes.length > 0 {
      assert_eq(function_.parameters.length, 1)
      assert_eq(function_.results.length, 1)
      assert_eq(
        fragments.modules[0].function_value_types[function_.parameters.start],
        WasmI64Value,
      )
      assert_eq(
        fragments.modules[0].function_value_types[function_.results.start],
        WasmI64Value,
      )
      count += 1
      let instance = program_function_lowering(
        lowering,
        0,
        function_.specialization_abi_key,
      )
      assert_eq(
        instance.functions.callable_of(keep).unwrap().result_shape,
        I64PlannedValueShape,
      )
      assert_eq(instance.diagnostics, [])
      let selected = program_function_fragments(
        instance,
        fragments.modules[0],
        function_.specialization_abi_key,
      )
      assert_eq(
        selected.closure_entry_type_by_resolved.length(),
        instance.resolved_types.length(),
      )
    }
  }
  assert_eq(count, 1)
  assert_eq(
    lowering.modules[0].functions.callable_of(keep).unwrap().result_shape,
    GenericPlannedValueShape,
  )
  let second = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(second.modules[0].functions, fragments.modules[0].functions)
}

///|
test "compile time member projection preserves generic forwarding owners" {
  let (program, _) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n  item: t\n}\nfn keep<t>(value: field_type<t>(\"item\")) -> field_type<t>(\"item\") {\n  value\n}\nfn forward<u>(value: field_type<u>(\"item\")) -> field_type<u>(\"item\") {\n  keep::<u>(value)\n}\npub fn main() -> I64 {\n  forward::<Box<I64>>(42i64)\n}\n",
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
}

///|
test "compile time imported member projection keeps declaration arguments" {
  let program = collect_program_manifest(
    24920UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open lib.model\npub fn main() -> I64 {\n  keep::<Box<I64>>(42i64)\n}\n",
        ),
      ]),
      ManifestModule::new("lib.model", [
        ManifestFile::new(
          "model.dew", b"open dew.std.types\npub struct Box<t> {\n  item: t\n}\npub fn keep<t>(value: field_type<t>(\"item\")) -> field_type<t>(\"item\") {\n  value\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  for interface_ in analyzed.frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
}

///|
test "compile time member projection cannot infer its owner or hide a cycle" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let owner = solver.fresh_variable()
  let projection = solver.member_projection_type(
    owner, b"types.field_type", "item",
  )
  let origin = synthetic_type_origin(7, 91UL)
  let snapshot = solver.snapshot()
  assert_false(solver.unify(owner, projection, origin))
  assert_true(solver.diagnostics[0] is InfiniteLocalType(_, _, _))
  solver.rollback(snapshot)
  assert_true(solver.has_unresolved_variable(projection))
  assert_eq(solver.zonk_type(projection), projection)
  let scalar = solver.resolved_type(resolved.primitive(I64Type))
  assert_false(solver.unify(projection, scalar, origin))
  assert_eq(solver.representative_type(owner), owner)
}

///|
test "compile time projection equation worklist waits for owners and rolls back exactly" {
  let collected = collect_bytes(24020UL, b"struct Record {\n  item: I64\n}\n")
  let resolved = resolve_module_types(collected)
  let declaration = collected.declarations[0].id
  let context : BodyMemberTypeContext = {
    declarations: Map([
      (
        declaration,
        {
          parameters: [],
          fields: { "item": resolved.primitive(I64Type) },
          variants: {},
        },
      ),
    ]),
  }
  let solver = LocalTypeSolver::new(resolved, member_types=Some(context))
  let owner = solver.fresh_variable()
  let projection = solver.member_projection_type(
    owner, b"types.field_type", "item",
  )
  let scalar = solver.resolved_type(resolved.primitive(I64Type))
  let record = solver.resolved_type(resolved.declaration_type(declaration))
  let left = solver.product_type([projection, owner])
  let right = solver.product_type([scalar, record])
  let parents = solver.variable_parents.copy()
  let sizes = solver.variable_sizes.copy()
  let bindings = solver.variable_bindings.copy()
  let types = solver.types.copy()
  let arguments = solver.type_arguments.copy()
  let origin = call_type_origin(19, 47UL)
  let snapshot = solver.snapshot()
  assert_true(solver.unify(left, right, origin))
  assert_eq(solver.representative_type(owner), record)
  assert_eq(solver.reduce_member_type(projection, 0), Ok(scalar))
  assert_eq(solver.diagnostics, [])
  solver.rollback(snapshot)
  assert_eq(solver.variable_parents, parents)
  assert_eq(solver.variable_sizes, sizes)
  assert_eq(solver.variable_bindings, bindings)
  assert_eq(solver.types, types)
  assert_eq(solver.type_arguments, arguments)
  assert_false(solver.unify(projection, scalar, origin))
  assert_eq(solver.representative_type(owner), owner)
  assert_true(
    solver.diagnostics[0] is LocalTypeMismatch(_, _, actual) && actual == origin,
  )
}

///|
test "compile time member projection codec retains owner and error origin" {
  let type_ = BodyMemberTypeProjection(
    -7, b"types.variant_payload_types", "Value",
  )
  let origin = call_type_origin(17, 92UL)
  let diagnostic = InvalidLocalMemberProjection(
    5, "CT-032 no such field: item", origin,
  )
  let writer = @cache_binary.Writer::new(size_hint=128)
  ib_write_body_type(writer, type_)
  ib_write_local_diagnostic(writer, diagnostic)
  let reader = @cache_binary.Reader::new(
    writer.to_bytes(),
    context="member projection test",
  )
  assert_eq(ib_read_body_type(reader, "type"), type_)
  assert_eq(ib_read_local_diagnostic(reader, "diagnostic"), diagnostic)
  assert_true(ib_validate_type_graph([BodyErrorType, type_], []))
  assert_false(
    ib_validate_type_graph(
      [BodyErrorType, BodyMemberTypeProjection(1, b"types.field_type", "item")],
      [],
    ),
  )
  assert_false(
    ib_validate_type_graph(
      [BodyErrorType, BodyMemberTypeProjection(-7, b"not.a.query", "item")],
      [],
    ),
  )
}

///|
test "compile time member projection errors retain their call origin" {
  let (_, resolved) = unification_test_types()
  let solver = LocalTypeSolver::new(resolved)
  let scalar = solver.resolved_type(resolved.primitive(I64Type))
  let projection = solver.member_projection_type(
    scalar, b"types.field_type", "item",
  )
  let origin = call_type_origin(11, 73UL)
  assert_false(solver.unify(projection, scalar, origin))
  assert_eq(solver.diagnostics, [
    InvalidLocalMemberProjection(
      projection, "CT-032 member type query requires a struct or enum", origin,
    ),
  ])
}
