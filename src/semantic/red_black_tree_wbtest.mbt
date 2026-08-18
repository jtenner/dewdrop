///|
#skip("compiler integration case; run tools/test-integration-native.sh")
test "red black tree standard module has stable identities and generic lowering" {
  let program = collect_program_manifest(
    2636UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.ordering\nopen dew.std.collections.red_black_tree\nfn make() -> RedBlackTree<I32, I32, NaturalComparator> {\n  red_black_tree_new(natural_comparator())\n}\npub fn run() -> Unit {\n  let tree = make()\n  red_black_tree_insert(tree, 2, 20)\n  red_black_tree_insert(tree, 1, 10)\n  red_black_tree_remove(tree, 2)\n}\n",
        ),
      ]),
    ]),
  )
  assert_eq(program.diagnostics, [])
  let module_index = program
    .module_index("dew.std.collections.red_black_tree")
    .unwrap()
  let tree = program.modules[module_index]
  assert_eq(tree.diagnostics, [])
  let tree_type = tree.lookup_type("RedBlackTree").unwrap()
  assert_eq(semantic_id_module(tree_type), standard_library_module_id(41))
  assert_true(tree.lookup_type("RedBlackTreeIter") is Some(_))
  assert_true(tree.lookup_type("TreeEntry") is Some(_))
  assert_true(tree.lookup_value("red_black_tree_insert") is Some(_))
  assert_true(tree.lookup_value("red_black_tree_remove") is Some(_))
  assert_true(tree.lookup_value("red_black_tree_validate") is Some(_))
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.frozen.import_diagnostics, [])
  for module_ in analyzed.modules {
    assert_eq(module_.names.diagnostics, [])
    assert_eq(module_.inferred.diagnostics, [])
  }
  let lowered = plan_program_lowering(program, analyzed)
  let link = plan_program_wasmgc_link(analyzed, lowered, 0)
  assert_eq(link.diagnostics, [])
}
