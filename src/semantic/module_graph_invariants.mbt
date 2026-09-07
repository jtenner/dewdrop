///|
priv struct ModuleGraphInvariantFailure {
  module_index : Int
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///|
// Linear in modules plus import edges. SCC member spans must partition their
// arena in schedule order; every module belongs to exactly one component.
fn verify_module_dependency_graph(
  graph : ModuleDependencyGraph,
) -> Result[Unit, ModuleGraphInvariantFailure] {
  let count = graph.module_ids.length()
  if graph.dependencies.length() != count {
    return Err({
      module_index: -1,
      expected: count,
      actual: graph.dependencies.length(),
      detail: 0,
    })
  }
  if graph.scc_modules.length() != count {
    return Err({
      module_index: -1,
      expected: count,
      actual: graph.scc_modules.length(),
      detail: 1,
    })
  }
  let owners = Array::make(count, -1)
  let mut cursor = 0
  for component, span in graph.sccs {
    if span.length <= 0 {
      return Err({
        module_index: component,
        expected: 1,
        actual: span.length,
        detail: 2,
      })
    }
    if span.start != cursor {
      return Err({
        module_index: component,
        expected: cursor,
        actual: span.start,
        detail: 3,
      })
    }
    if !program_specialization_span_is_valid(span, count) {
      return Err({
        module_index: component,
        expected: count,
        actual: span.length,
        detail: 4,
      })
    }
    for slot in span.start..<(span.start + span.length) {
      let member = graph.scc_modules[slot]
      if member < 0 || member >= count {
        return Err({
          module_index: component,
          expected: count,
          actual: member,
          detail: 5,
        })
      }
      if owners[member] != -1 {
        return Err({
          module_index: member,
          expected: -1,
          actual: owners[member],
          detail: 6,
        })
      }
      owners[member] = component
    }
    cursor += span.length
  }
  if cursor != count {
    return Err({
      module_index: -1,
      expected: count,
      actual: cursor,
      detail: 11,
    })
  }
  for source, span in graph.dependencies {
    if !program_specialization_span_is_valid(
        span,
        graph.dependency_modules.length(),
      ) {
      return Err({
        module_index: source,
        expected: graph.dependency_modules.length(),
        actual: span.start,
        detail: 8,
      })
    }
    for slot in span.start..<(span.start + span.length) {
      let dependency = graph.dependency_modules[slot]
      if dependency < 0 || dependency >= count {
        return Err({
          module_index: source,
          expected: count,
          actual: dependency,
          detail: 9,
        })
      }
      if owners[dependency] > owners[source] {
        return Err({
          module_index: source,
          expected: owners[source],
          actual: owners[dependency],
          detail: 10,
        })
      }
    }
  }
  Ok(())
}

///|
fn assert_module_dependency_graph(graph : ModuleDependencyGraph) -> Unit {
  match verify_module_dependency_graph(graph) {
    Ok(_) => ()
    Err(error) => abort("LNK-501 " + @debug.to_string(error))
  }
}
