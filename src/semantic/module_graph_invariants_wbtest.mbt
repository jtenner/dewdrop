///|
fn graph_invariant_fixture() -> ModuleDependencyGraph {
  {
    module_ids: [11UL, 13UL, 17UL],
    dependencies: [
      { start: 0, length: 0, },
      { start: 0, length: 1, },
      { start: 1, length: 1, },
    ],
    dependency_modules: [0, 1],
    sccs: [
      { start: 0, length: 1, },
      { start: 1, length: 1, },
      { start: 2, length: 1, },
    ],
    scc_modules: [0, 1, 2],
    diagnostics: [],
  }
}

///|
test "SCC verifier accepts dependency order cycles and the empty graph" {
  let graph = graph_invariant_fixture()
  assert_eq(verify_module_dependency_graph(graph), Ok(()))
  // Both edges of the cycle belong to one component.
  graph.dependency_modules[0] = 2
  assert_eq(
    verify_module_dependency_graph({
      ..graph,
      sccs: [{ start: 0, length: 1, }, { start: 1, length: 2, }],
    }),
    Ok(()),
  )
  assert_eq(
    verify_module_dependency_graph({
      module_ids: [],
      dependencies: [],
      dependency_modules: [],
      sccs: [],
      scc_modules: [],
      diagnostics: [],
    }),
    Ok(()),
  )
}

///|
test "SCC verifier rejects a duplicate module and a missing module" {
  let graph = graph_invariant_fixture()
  graph.scc_modules[1] = 0
  assert_eq(
    verify_module_dependency_graph(graph),
    Err({ module_index: 0, expected: -1, actual: 0, detail: 6, }),
  )
  let graph = graph_invariant_fixture()
  assert_eq(
    verify_module_dependency_graph({ ..graph, scc_modules: [0, 1], }),
    Err({ module_index: -1, expected: 3, actual: 2, detail: 1, }),
  )
}

///|
test "SCC verifier rejects wrong order and invalid owned spans" {
  let graph = graph_invariant_fixture()
  graph.dependency_modules[0] = 2
  assert_eq(
    verify_module_dependency_graph(graph),
    Err({ module_index: 1, expected: 1, actual: 2, detail: 10, }),
  )
  let graph = graph_invariant_fixture()
  graph.sccs[1] = { start: 0, length: 1, }
  assert_eq(
    verify_module_dependency_graph(graph),
    Err({ module_index: 1, expected: 1, actual: 0, detail: 3, }),
  )
  let graph = graph_invariant_fixture()
  graph.dependencies[1] = { start: 2147483647, length: 1, }
  assert_eq(
    verify_module_dependency_graph(graph),
    Err({ module_index: 1, expected: 2, actual: 2147483647, detail: 8, }),
  )
  let graph = graph_invariant_fixture()
  graph.dependency_modules[0] = 3
  assert_eq(
    verify_module_dependency_graph(graph),
    Err({ module_index: 1, expected: 3, actual: 3, detail: 9, }),
  )
}
