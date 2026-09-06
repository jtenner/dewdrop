///|
test "computed member aliases defer an unknown owner until concrete use" {
  let program = collect_program_manifest(
    24920UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\ntype Item<t> = field_type<t>(\"item\")\ntype Payload<t> = variant_payload_types<t>(\"Value\")\nstruct Box<t> {\n  item: t\n}\nenum Message<t> {\n  Value(t, I64)\n}\npub fn identity(value: Item<Box<I64>>) -> I64 {\n  value\n}\npub fn main() -> Bool {\n  type_equal::<Item<Box<I64>>, I64>() && type_equal::<Payload<Message<I32>>, (I32, I64)>()\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let bytes = serialize_frozen_interfaces(analyzed.frozen.interfaces).unwrap()
  assert_eq(
    deserialize_frozen_interfaces(bytes).unwrap(),
    analyzed.frozen.interfaces,
  )
  for interface_ in analyzed.frozen.interfaces {
    assert_eq(interface_.resolved_types.diagnostics, [])
  }
  for module_ in analyzed.modules {
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowering = plan_unoptimized_program_lowering(program, analyzed)
  assert_eq(lowering.modules[0].diagnostics, [])
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let linked = link_program_wasmgc_fragments(fragments, lowering, 0)
  assert_eq(linked.diagnostics, [])
}

///|
test "computed member projections preserve nested imported owners" {
  let program = collect_program_manifest(
    24921UL,
    ProgramManifest::new([
      ManifestModule::new("app.model", [
        ManifestFile::new(
          "model.dew", b"open dew.std.types\npub struct Box<t> {\n  item: t\n}\npub type Item<t> = field_type<t>(\"item\")\npub type Inner<t> = field_type<field_type<t>(\"item\")>(\"item\")\n",
        ),
      ]),
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.types\nimport app.model as @model\npub fn main() -> Bool {\n  type_equal::<@model.Item<@model.Box<I64>>, I64>() && type_equal::<@model.Inner<@model.Box<@model.Box<I32>>>, I32>()\n}\n",
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
  for module_ in lowering.modules {
    assert_eq(module_.diagnostics, [])
  }
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  assert_eq(link_program_wasmgc_fragments(fragments, lowering, 0).diagnostics, [])
}
