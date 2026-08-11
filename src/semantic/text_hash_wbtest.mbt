///|
test "String StringView and Bytes Hash evidence lowers into map use" {
  let program = collect_program_manifest(
    2643UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.bytes\nopen dew.std.map\nfn values() -> Map<String, I32> {\n  Map::empty()\n}\npub fn main() -> Unit {\n  let map = values()\n  map.insert(\"dew\", 7)\n  assert(map[\"dew\"] == 7, \"String map\")\n  assert(\"dew\".hash() == b\"dew\".hash(), \"hash parity\")\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  assert_eq(analyzed.modules[0].names.diagnostics, [])
  assert_eq(analyzed.modules[0].inferred.diagnostics, [])
  let lowered = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowered, 0)
  assert_eq(link.diagnostics, [])
}
