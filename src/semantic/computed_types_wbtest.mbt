///|
test "computed types preserve fields aliases generic arguments and variant order" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Pair<a, b> {\n  first: a\n  second: b\n}\ntype Alias<t> = Pair<t, U8>\ntype First<t> = field_type<Alias<t>>(\"first\")\nenum Event<t> {\n  Empty\n  Value(t, I64)\n  Named {\n    left: U8\n    right: t\n  }\n}\nfn identity<t>(value: t) -> t {\n  value\n}\npub fn main() -> Bool {\n  type_equal::<First<I8>, I8>() &&\n  type_equal::<field_type<Pair<I8, U8>>(\"second\"), U8>() &&\n  type_equal::<variant_payload_types<Event<I32>>(\"Value\"), (I32, I64)>() &&\n  type_equal::<variant_payload_types<Event<I64>>(\"Named\"), (U8, I64)>() &&\n  tuple_length::<variant_payload_types<Event<I32>>(\"Empty\")>() == 0u32\n}\npub fn typed(value: field_type<Pair<I64, U8>>(\"first\")) -> First<I64> {\n  identity::<First<I64>>(value)\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let mut yes = false
  for expression in lowering.modules[0].expressions {
    if expression.kind == PlannedBoolConst(true) {
      yes = true
    }
    assert_false(expression.kind == PlannedBoolConst(false))
  }
  assert_true(yes)
}

///|
test "computed type errors remain source diagnostics" {
  for
    entry in [
      (
        b"open dew.std.types\nstruct Record {\n  item: I32\n}\ntype Item = field_type<Record>(\"absent\")\n",
        "CT-032",
      ),
      (
        b"open dew.std.types\nstruct Record {\n  item: Item\n}\ntype Item = field_type<Record>(\"item\")\n",
        "AliasCycle",
      ),
      (
        b"open dew.std.types\ntype Item<t> = field_type<t>(\"item\")\ntype Bad = Item<I32>\n",
        "CT-032",
      ),
      (
        b"open dew.std.types\nstruct Record {\n  item: field_type<Record>(\"item\")\n}\n",
        "CT-033",
      ),
      (
        b"fn field_type<t>(name: String) -> I32 {\n  0i32\n}\nstruct Record {\n  item: I32\n}\ntype Item = field_type<Record>(\"item\")\n",
        "CT-030",
      ),
      (
        b"builtin field_type<t>(name: String) -> I32 = \"types.field_type\"\nstruct Record {\n  item: I32\n}\ntype Item = field_type<Record>(\"item\")\n",
        "CT-031",
      ),
    ] {
    let (source, code) = entry
    let program = collect_program_manifest(
      24030UL,
      ProgramManifest::new([
        ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
      ]),
    )
    assert_eq(program.modules[0].diagnostics, [])
    let analyzed = analyze_program_semantics(program)
    let mut found = false
    for diagnostic in analyzed.frozen.interfaces[0].resolved_types.diagnostics {
      if diagnostic is ComputedTypeFailure(_, message, _) &&
        message.has_prefix(code) {
        found = true
      }
      if code == "AliasCycle" && diagnostic is AliasCycle(_, _) {
        found = true
      }
    }
    assert_true(
      found,
      msg="missing computed type diagnostic " +
        code +
        ": " +
        @debug.to_string(
          analyzed.frozen.interfaces[0].resolved_types.diagnostics,
        ) +
        " source=" +
        @debug.to_string(source),
    )
  }
}

///|
test "computed types read imported fields and payloads through a module alias" {
  let program = collect_program_manifest(
    24031UL,
    ProgramManifest::new([
      ManifestModule::new("lib.model", [
        ManifestFile::new(
          "model.dew", b"pub struct Box<t> {\n  item: t\n}\npub enum Message<t> {\n  Value(t, U8)\n}\n",
        ),
      ]),
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open lib.model\nimport dew.std.types as @types\ntype Item = @types.field_type::<Box<I64>>(\"item\")\ntype Payload = @types.variant_payload_types<Message<I32>>(\"Value\")\npub fn main() -> Bool {\n  @types.type_equal::<Item, I64>() && @types.type_equal::<Payload, (I32, U8)>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  for interface_ in analyzed.frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[1].diagnostics, [])
  let body = program.modules[1]
    .body_of(program.modules[1].lookup_value("main").unwrap())
    .unwrap()
  assert_eq(
    lowering.modules[1].expressions[optimization_test_body_tail(
      lowering.modules[1],
      body.id,
    )].kind,
    PlannedBoolConst(true),
  )
}

///|
test "computed types cannot become runtime reference storage" {
  for
    source in [
      b"struct Invalid {\n  value: Type\n}\n", b"type Meta = Type\npub fn invalid(value: Meta) -> Unit {\n}\n",
      b"pub fn invalid() -> Type {\n}\n", b"enum Invalid {\n  Payload(Type)\n}\n",
    ] {
    let program = collect_program_manifest(
      24032UL,
      ProgramManifest::new([
        ManifestModule::new("app.main", [ManifestFile::new("main.dew", source)]),
      ]),
    )
    let analyzed = analyze_program_semantics(program)
    let mut found = false
    for diagnostic in analyzed.frozen.interfaces[0].resolved_types.diagnostics {
      if diagnostic is ComputedTypeFailure(_, message, _) &&
        message.has_prefix("CT-037") {
        found = true
      }
    }
    assert_true(found)
  }
  assert_eq(
    planned_value_shape_from_resolved_types(
      [PrimitiveType(CompileTimeTypeType)],
      [],
      0,
    ),
    ErrorPlannedValueShape,
  )
}

///|
test "computed types use builtin identity and survive frozen interfaces" {
  let (program, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nbuiltin member<t>(name: String) -> Type = \"types.field_type\"\nstruct Box<t> {\n  value: t\n}\ntype Item = member<Box<I64>>(\"value\")\npub fn main() -> Bool {\n  type_equal::<Item, I64>()\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  let frozen = freeze_program_interfaces(program)
  let bytes = serialize_frozen_interfaces(frozen.interfaces).unwrap()
  let restored = deserialize_frozen_interfaces(bytes).unwrap()
  assert_eq(restored, frozen.interfaces)
  assert_eq(serialize_frozen_interfaces(restored).unwrap(), bytes)
}

///|
test "computed type queries cannot run as value expressions" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box {\n  value: I64\n}\npub fn main() -> Unit {\n  let value = field_type::<Box>(\"value\")\n}\n",
  )
  let mut found = false
  for diagnostic in lowering.modules[0].diagnostics {
    if diagnostic is CompileTimeQueryDiagnostic(_, message, _) &&
      message.has_prefix("CT-036") {
      found = true
    }
  }
  assert_true(found)
}
