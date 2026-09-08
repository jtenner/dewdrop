///|
test "module path spelling cannot publish private declarations or functions" {
  let collected = collect_program_bytes(
    28123UL, b"pub struct Visible {}\nstruct Hidden {}\npub fn shown(value: I32) -> I32 {\n  value\n}\nfn hidden(value: I32) -> I32 {\n  value\n}\n",
  )
  assert_eq(collected.diagnostics, [])
  let resolved = resolve_module_types(collected)
  assert_eq(resolved.diagnostics, [])
  let functions = plan_module_functions(collected, resolved)
  for
    path in [
      "app.api", "dew.std.custom", "dew.std.string", "dew.std.string.custom",
    ] {
    let interface_ = freeze_module_interface(
      path, collected, resolved, functions,
    )
    assert_eq(interface_.declarations.map(value => value.name), [
      "Visible", "shown",
    ])
    assert_eq(interface_.callables.map(value => value.name), ["shown"])
  }
}

///|
test "interface exports follow source visibility across the module ID range" {
  for module_id in [28123UL, 0xfffeffffUL, 0xffff0000UL, 0xffffffffUL] {
    let collected = collect_program_bytes(
      module_id, b"pub builtin add(left: I32, right: I32) -> I32 = \"i32.add\"\npub fn shown(value: I32) -> I32 {\n  value\n}\nfn hidden(value: I32) -> I32 {\n  value\n}\n",
    )
    assert_eq(collected.diagnostics, [])
    let resolved = resolve_module_types(collected)
    assert_eq(resolved.diagnostics, [])
    let functions = plan_module_functions(collected, resolved)
    for path in ["app.api", "dew.std.custom"] {
      let interface_ = freeze_module_interface(
        path, collected, resolved, functions,
      )
      assert_eq(interface_.declarations.map(value => value.name), [
        "add", "shown",
      ])
      assert_eq(interface_.callables.map(value => value.name), ["add", "shown"])
    }
  }
}
