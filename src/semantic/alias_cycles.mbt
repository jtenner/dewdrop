///|
fn TypeResolver::alias_offset(self : TypeResolver, alias_index : Int) -> UInt64 {
  let declaration = self.collected.aliases[alias_index].declaration
  match self.collected.declaration(declaration) {
    Some(TopLevelReference(value)) => value.offset
    _ => abort("alias declaration is not top-level")
  }
}

///|
fn TypeResolver::alias_has_self_edge(
  self : TypeResolver,
  alias_index : Int,
) -> Bool {
  let declaration = self.collected.aliases[alias_index].declaration
  let span = self.alias_dependencies[alias_index]
  for index in span.start..<(span.start + span.length) {
    if self.alias_dependency_declarations[index] == declaration {
      return true
    }
  }
  false
}

///|
fn TypeResolver::find_alias_cycles(self : TypeResolver) -> Unit {
  let alias_count = self.collected.aliases.length()
  if alias_count == 0 {
    return
  }
  let visited = Array::make(alias_count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<alias_count {
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
      let dependencies = self.alias_dependencies[item]
      let mut index = dependencies.length
      while index > 0 {
        index -= 1
        let declaration = self.alias_dependency_declarations[dependencies.start +
          index]
        let dependency = self.alias_indices[declaration]
        if !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }

  let reverse_counts = Array::make(alias_count, 0)
  for alias_index in 0..<alias_count {
    let dependencies = self.alias_dependencies[alias_index]
    for edge in dependencies.start..<(dependencies.start + dependencies.length) {
      let declaration = self.alias_dependency_declarations[edge]
      reverse_counts[self.alias_indices[declaration]] += 1
    }
  }
  let reverse_offsets = Array::make(alias_count + 1, 0)
  for index in 0..<alias_count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(alias_count, 0)
  for index in 0..<alias_count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[alias_count], 0)
  for alias_index in 0..<alias_count {
    let dependencies = self.alias_dependencies[alias_index]
    for edge in dependencies.start..<(dependencies.start + dependencies.length) {
      let declaration = self.alias_dependency_declarations[edge]
      let dependency = self.alias_indices[declaration]
      let destination = reverse_cursor[dependency]
      reverse_edges[destination] = alias_index
      reverse_cursor[dependency] += 1
    }
  }

  let assigned = Array::make(alias_count, false)
  let component : Array[Int] = []
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
    while work.length() > 0 {
      let alias_index = work.pop().unwrap()
      component.push(alias_index)
      for
        edge_index in reverse_offsets[alias_index]..<reverse_offsets[alias_index +
        1] {
        let dependency = reverse_edges[edge_index]
        if !assigned[dependency] {
          assigned[dependency] = true
          work.push(dependency)
        }
      }
    }
    let cyclic = component.length() > 1 ||
      (component.length() == 1 && self.alias_has_self_edge(component[0]))
    if cyclic {
      component.sort()
      let cycle_start = self.alias_cycle_declarations.length()
      let mut offset = 0xffffffffffffffffUL
      for alias_index in component {
        self.alias_is_cyclic[alias_index] = true
        self.alias_cycle_declarations.push(
          self.collected.aliases[alias_index].declaration,
        )
        let alias_offset = self.alias_offset(alias_index)
        if alias_offset < offset {
          offset = alias_offset
        }
      }
      let span = {
        start: cycle_start,
        length: self.alias_cycle_declarations.length() - cycle_start,
      }
      self.alias_cycles.push(span)
      self.diagnose(AliasCycle(span, offset))
    }
  }
  self.alias_cycles.sort_by(fn(left, right) {
    let left_declaration = self.alias_cycle_declarations[left.start]
    let right_declaration = self.alias_cycle_declarations[right.start]
    self.alias_indices[left_declaration] - self.alias_indices[right_declaration]
  })
}
