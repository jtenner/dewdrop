///|
pub struct ModuleValueDependencies {
  module_id : ModuleId
  let_dependencies : Array[HirSpan]
  dependency_declarations : Array[DeclId]
  sccs : Array[HirSpan]
  scc_declarations : Array[DeclId]
} derive(Eq, Debug)

///|
fn module_let_indices_by_declaration(collected : CollectedModule) -> Array[Int] {
  let indices = Array::make(collected.declaration_locations.length(), -1)
  for index, value in collected.lets {
    indices[semantic_id_local(value.declaration)] = index
  }
  indices
}

///|
fn module_value_declaration(
  collected : CollectedModule,
  name : NameId,
) -> DeclId? {
  match collected.value_bindings.get(name) {
    Some(binding) =>
      Some(collected.value_binding_candidates[binding.head].declaration)
    None => None
  }
}

///|
fn collect_module_let_dependencies(
  collected : CollectedModule,
  names : ResolvedModuleNames,
  let_indices : Array[Int],
) -> (Array[HirSpan], Array[DeclId]) {
  let spans : Array[HirSpan] = []
  let declarations : Array[DeclId] = []
  let marks = Array::make(collected.lets.length(), 0)
  let scratch : Array[Int] = []
  let mut generation = 0
  for value in collected.lets {
    generation += 1
    if generation == 0 {
      marks.fill(0)
      generation = 1
    }
    scratch.clear()
    let body = collected.body_of(value.declaration).unwrap()
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match names.expression_references[expression] {
        ModuleValueNameReference(name) =>
          match module_value_declaration(collected, name) {
            Some(declaration) => {
              let local_index = semantic_id_local(declaration)
              let dependency = if local_index >= 0 &&
                local_index < let_indices.length() {
                let_indices[local_index]
              } else {
                -1
              }
              if dependency >= 0 && marks[dependency] != generation {
                marks[dependency] = generation
                scratch.push(dependency)
              }
            }
            None => ()
          }
        _ => ()
      }
    }
    scratch.sort()
    let start = declarations.length()
    for dependency in scratch {
      declarations.push(collected.lets[dependency].declaration)
    }
    spans.push({ start, length: declarations.length() - start })
  }
  (spans, declarations)
}

///|
fn module_let_dependency_index(
  declaration : DeclId,
  let_indices : Array[Int],
) -> Int {
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= let_indices.length() {
    -1
  } else {
    let_indices[local_index]
  }
}

///|
fn find_module_value_sccs(
  collected : CollectedModule,
  let_indices : Array[Int],
  dependencies : Array[HirSpan],
  dependency_declarations : Array[DeclId],
) -> (Array[HirSpan], Array[DeclId]) {
  let value_count = collected.lets.length()
  if value_count == 0 {
    return ([], [])
  }
  let visited = Array::make(value_count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<value_count {
    if visited[start] {
      continue
    }
    work.push(start)
    while work.length() > 0 {
      let item = work.pop().unwrap()
      if item < 0 {
        finish_order.push(-item - 1)
        continue
      }
      if visited[item] {
        continue
      }
      visited[item] = true
      work.push(-item - 1)
      let edges = dependencies[item]
      let mut edge_index = edges.length
      while edge_index > 0 {
        edge_index -= 1
        let dependency = module_let_dependency_index(
          dependency_declarations[edges.start + edge_index],
          let_indices,
        )
        if dependency >= 0 && !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }

  let reverse_counts = Array::make(value_count, 0)
  for value_index in 0..<value_count {
    let edges = dependencies[value_index]
    for edge in edges.start..<(edges.start + edges.length) {
      let dependency = module_let_dependency_index(
        dependency_declarations[edge],
        let_indices,
      )
      if dependency >= 0 {
        reverse_counts[dependency] += 1
      }
    }
  }
  let reverse_offsets = Array::make(value_count + 1, 0)
  for index in 0..<value_count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(value_count, 0)
  for index in 0..<value_count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[value_count], 0)
  for value_index in 0..<value_count {
    let edges = dependencies[value_index]
    for edge in edges.start..<(edges.start + edges.length) {
      let dependency = module_let_dependency_index(
        dependency_declarations[edge],
        let_indices,
      )
      if dependency >= 0 {
        let destination = reverse_cursor[dependency]
        reverse_edges[destination] = value_index
        reverse_cursor[dependency] += 1
      }
    }
  }

  let finish_ranks = Array::make(value_count, 0)
  for rank, value_index in finish_order {
    finish_ranks[value_index] = rank
  }
  let assigned = Array::make(value_count, false)
  let component : Array[Int] = []
  let raw_spans : Array[HirSpan] = []
  let raw_members : Array[Int] = []
  let component_ranks : Array[Int] = []
  let mut order_index = finish_order.length()
  while order_index > 0 {
    order_index -= 1
    let start = finish_order[order_index]
    if assigned[start] {
      continue
    }
    component.clear()
    work.clear()
    work.push(start)
    assigned[start] = true
    let mut component_rank = finish_ranks[start]
    while work.length() > 0 {
      let value_index = work.pop().unwrap()
      component.push(value_index)
      if finish_ranks[value_index] < component_rank {
        component_rank = finish_ranks[value_index]
      }
      for
        edge in reverse_offsets[value_index]..<reverse_offsets[value_index + 1] {
        let dependent = reverse_edges[edge]
        if !assigned[dependent] {
          assigned[dependent] = true
          work.push(dependent)
        }
      }
    }
    component.sort()
    let component_start = raw_members.length()
    for value_index in component {
      raw_members.push(value_index)
    }
    raw_spans.push({
      start: component_start,
      length: raw_members.length() - component_start,
    })
    component_ranks.push(component_rank)
  }

  let component_order : Array[Int] = []
  for index in 0..<raw_spans.length() {
    component_order.push(index)
  }
  component_order.sort_by(fn(left, right) {
    let rank_order = component_ranks[left] - component_ranks[right]
    if rank_order != 0 {
      rank_order
    } else {
      raw_members[raw_spans[left].start] - raw_members[raw_spans[right].start]
    }
  })
  let sccs : Array[HirSpan] = []
  let scc_declarations : Array[DeclId] = []
  for component_index in component_order {
    let raw = raw_spans[component_index]
    let start = scc_declarations.length()
    for index in 0..<raw.length {
      scc_declarations.push(
        collected.lets[raw_members[raw.start + index]].declaration,
      )
    }
    sccs.push({ start, length: scc_declarations.length() - start })
  }
  (sccs, scc_declarations)
}

///|
/// Builds deterministic, deduplicated module-let dependencies and a
/// dependency-first SCC schedule. Members inside one SCC remain in source
/// order.
pub fn analyze_module_value_dependencies(
  collected : CollectedModule,
  names : ResolvedModuleNames,
) -> ModuleValueDependencies {
  guard collected.module_id == names.module_id else {
    abort("module value dependency inputs belong to different modules")
  }
  let let_indices = module_let_indices_by_declaration(collected)
  let (let_dependencies, dependency_declarations) = collect_module_let_dependencies(
    collected, names, let_indices,
  )
  let (sccs, scc_declarations) = find_module_value_sccs(
    collected, let_indices, let_dependencies, dependency_declarations,
  )
  {
    module_id: collected.module_id,
    let_dependencies,
    dependency_declarations,
    sccs,
    scc_declarations,
  }
}
