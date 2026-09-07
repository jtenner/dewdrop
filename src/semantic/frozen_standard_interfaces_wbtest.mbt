///|
test "frozen standard runtime calls remain reachable" {
  let program = collect_program_manifest(
    3900UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.string\nopen dew.std.string_builder\nopen dew.std.wasi\nopen dew.std.bytes\npub fn main() -> U32 {\n  let builder = StringBuilder::with_capacity(1u32)\n  builder.append(\"build\")\n  wasi_fd_write(1u32, builder.finish().as_bytes())\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let lowering = plan_program_lowering(program, analyzed)
  let roots = program_reachable_callable_roots(
    analyzed,
    lowering,
    false,
    compile_time_demand_instances(lowering),
  )
  let fragments = plan_program_wasmgc_fragments(analyzed, lowering)
  let runtime_index = program.module_index("dew.std.text_runtime").unwrap()
  let declaration = program.modules[runtime_index]
    .lookup_value("string_as_bytes_unchecked")
    .unwrap()
  let mut referenced = false
  for module_ in lowering.modules {
    for body in module_.bodies {
      for
        expression_index in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        match module_.expressions[expression_index].kind {
          PlannedDirectCall(target, _, _, _)
          | PlannedOperatorCall(target, _, _, _, _) =>
            if target == declaration {
              referenced = true
            }
          _ => ()
        }
      }
    }
  }
  assert_true(referenced)
  assert_true(roots.contains(declaration))
  let function_ = fragments.modules[runtime_index]
    .function_of(declaration)
    .unwrap()
  assert_false(function_.elided)
}
