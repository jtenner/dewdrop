///|
test "selected inference keeps source IDs and excludes dead fields calls and locals" {
  let program = collect_program_manifest(
    24041UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"pub fn main() -> I32 {\n  if true {\n    let value = 42i32\n    value\n  } else {\n    let dead = ().missing\n    dead.absent()\n  }\n}\n",
        ),
      ]),
    ]),
  )
  let collected = program.modules[0]
  let analyzed = analyze_program_semantics(program)
  assert_true(analyzed.modules[0].inferred.diagnostics.length() > 0)
  assert_eq(analyzed.modules[0].names.diagnostics, [])
  let conditions = {}
  for expression, source in collected.expressions {
    if source is HirIfExpr(_, _, _, _) {
      conditions[expression] = true
    }
  }
  let originals = collected.expressions.copy()
  let (selected, live) = selected_inference_source(
    collected,
    analyzed.modules[0].names,
    collected.lookup_value("main").unwrap(),
    conditions,
  )
  let order = []
  for index in 0..<collected.bodies.length() {
    order.push(index)
  }
  let checked = infer_module_bodies_with_imports_in_order_and_family_cache(
    selected,
    analyzed.frozen.interfaces[0].resolved_types,
    Some(analyzed.modules[0].imports),
    analyzed.modules[0].names,
    order,
    Array::make(collected.bodies.length(), None),
    reachability=Some(live),
  ).unwrap()
  assert_eq(checked.inferred.diagnostics, [])
  assert_eq(collected.expressions, originals)
  assert_eq(selected.expressions.length(), originals.length())
  assert_true(live.expressions.contains(false))
  assert_true(live.locals.contains(false))
}
