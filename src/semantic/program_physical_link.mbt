///|
fn program_body_resolved_type(
  module_ : PlannedModuleLowering,
  type_ : BodyTypeId,
) -> ResolvedTypeId {
  if type_ < -1 {
    return -type_ - 2
  }
  if type_ >= 0 && type_ < module_.types.length() {
    match module_.types[type_] {
      BodyResolvedType(value) => return value
      _ => ()
    }
  }
  -1
}

///|
fn program_erased_adapter_reference_type(type_ : PlannedWasmValueType) -> Bool {
  match type_ {
    WasmNullableEqRefValue
    | WasmFunctionRefValue(_)
    | WasmNominalRefValue(_)
    | WasmExternalNominalRefValue(_)
    | WasmFixedArrayRefValue(_)
    | WasmNullableNominalRefValue(_)
    | WasmNullableExternalNominalRefValue(_) => true
    _ => false
  }
}

///|
fn program_erased_adapter_value_type(type_ : PlannedWasmValueType) -> Bool {
  program_erased_adapter_reference_type(type_) ||
  program_erased_box_slot_for_value(type_) >= 0
}

///|
fn program_erased_adapter_compatible(
  source_module : PlannedModuleWasmGCFragments,
  source : PlannedWasmFunctionTypeFragment,
  target_module : PlannedModuleWasmGCFragments,
  target : PlannedProgramWasmFunction,
) -> Bool {
  if source.parameters.length != target.parameters.length ||
    source.results.length != target.results.length {
    return false
  }
  for index in 0..<source.parameters.length {
    let source_type = source_module.function_value_types[source.parameters.start +
      index]
    let target_type = target_module.function_value_types[target.parameters.start +
      index]
    if source_type != target_type &&
      !(target_type == WasmNullableEqRefValue &&
      program_erased_adapter_value_type(source_type)) &&
      !(program_erased_adapter_reference_type(source_type) &&
      program_erased_adapter_reference_type(target_type)) {
      return false
    }
  }
  for index in 0..<source.results.length {
    let source_type = source_module.function_value_types[source.results.start +
      index]
    let target_type = target_module.function_value_types[target.results.start +
      index]
    if source_type != target_type &&
      !(target_type == WasmNullableEqRefValue &&
      program_erased_adapter_value_type(source_type)) &&
      !(program_erased_adapter_reference_type(source_type) &&
      program_erased_adapter_reference_type(target_type)) {
      return false
    }
  }
  true
}

///|
fn program_erased_box_slot_for_shape(shape : PlannedValueShape) -> Int {
  match program_canonical_specialization_shape(shape) {
    I32PlannedValueShape => 0
    I64PlannedValueShape => 1
    F32PlannedValueShape => 2
    F64PlannedValueShape => 3
    V128PlannedValueShape => 4
    _ => -1
  }
}

///|
fn program_mark_product_erased_boxes(
  shape : PlannedValueShape,
  used : Array[Bool],
) -> Unit {
  match shape {
    ProductPlannedValueShape(fields) =>
      for field in fields {
        program_mark_product_erased_boxes(field, used)
      }
    GenericPlannedValueShape =>
      for slot in 0..<used.length() {
        used[slot] = true
      }
    _ => {
      let slot = program_erased_box_slot_for_shape(shape)
      if slot >= 0 {
        used[slot] = true
      }
    }
  }
}

///|
fn program_erased_box_slot_for_value(type_ : PlannedWasmValueType) -> Int {
  match type_ {
    WasmI32Value => 0
    WasmI64Value => 1
    WasmF32Value => 2
    WasmF64Value => 3
    WasmV128Value => 4
    _ => -1
  }
}

///|
fn program_erased_adapter_export_name(
  name : Bytes,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> Bytes {
  let output = Buffer(size_hint=name.length() + 16 + span.length * 8)
  output.write_bytes(name)
  output.write_string_utf8("$dew$")
  for index in 0..<span.length {
    if index > 0 {
      output.write_string_utf8("_")
    }
    output.write_string_utf8(
      program_specialization_shape_name(shapes[span.start + index]),
    )
  }
  output.to_bytes()
}

///|
fn program_test_export_name(ordinal : Int) -> Bytes {
  let output = Buffer(size_hint=24)
  output.write_string_utf8("__dew_test_")
  output.write_string_utf8(ordinal.to_string())
  output.to_bytes()
}

///|
fn program_initializer_dependencies(
  lowering : PlannedProgramLowering,
  initializer : PlannedProgramModuleInitializer,
  initializer_lookup : Map[DeclId, Int],
) -> Array[Int] {
  let module_lookup = lowering.index.module_lookup
  let dependencies : Array[Int] = []
  let seen_dependencies : Map[Int, Bool] = Map::default()
  let seen_bodies : Map[BodyId, Bool] = Map::default()
  let body_modules : Array[Int] = [initializer.module_index]
  let body_tasks : Array[BodyId] = [initializer.body]
  while body_tasks.length() > 0 {
    let body_id = body_tasks.pop().unwrap()
    let module_index = body_modules.pop().unwrap()
    if seen_bodies.contains(body_id) {
      continue
    }
    seen_bodies[body_id] = true
    let module_ = lowering.modules[module_index]
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= module_.bodies.length() {
      continue
    }
    let body = module_.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match module_.expressions[expression].kind {
        PlannedModuleValueGet(declaration, _) =>
          match initializer_lookup.get(declaration) {
            Some(dependency) if !seen_dependencies.contains(dependency) => {
              seen_dependencies[dependency] = true
              dependencies.push(dependency)
            }
            _ => ()
          }
        PlannedDirectCall(target, _, _, _)
        | PlannedTailCall(target, _, _, _)
        | PlannedOperatorCall(target, _, _, _, _)
        | PlannedIndexCall(target, _, _, _)
        | PlannedIndexSetCall(target, _, _, _, _) => {
          let owner = match module_lookup.get(semantic_id_module(target)) {
            Some(value) => value
            None => continue
          }
          let callable = match
            lowering.modules[owner].functions.callable_of(target) {
            Some(value) => value
            None => continue
          }
          let target_body = match callable.kind {
            PlannedFunctionCallable(body)
            | PlannedImplMethodCallable(_, Some(body)) => body
            _ => continue
          }
          if !seen_bodies.contains(target_body) {
            body_modules.push(owner)
            body_tasks.push(target_body)
          }
        }
        _ => ()
      }
    }
  }
  dependencies
}

///|
fn program_schedule_initializers(
  lowering : PlannedProgramLowering,
  candidates : Array[PlannedProgramModuleInitializer],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> Array[PlannedProgramModuleInitializer] {
  let lookup : Map[DeclId, Int] = Map::default()
  for index, initializer in candidates {
    lookup[initializer.declaration] = index
  }
  let dependencies : Array[Array[Int]] = []
  let remaining_dependencies = Array::make(candidates.length(), 0)
  for index, initializer in candidates {
    let values = program_initializer_dependencies(lowering, initializer, lookup)
    dependencies.push(values)
    remaining_dependencies[index] = values.length()
  }
  let scheduled = Array::make(candidates.length(), false)
  let output : Array[PlannedProgramModuleInitializer] = []
  while output.length() < candidates.length() {
    let mut selected = -1
    for index in 0..<candidates.length() {
      if !scheduled[index] && remaining_dependencies[index] == 0 {
        selected = index
        break
      }
    }
    if selected < 0 {
      let mut first = -1
      for index in 0..<candidates.length() {
        if !scheduled[index] {
          first = index
          break
        }
      }
      if first >= 0 {
        let mut second = first
        for dependency in dependencies[first] {
          if !scheduled[dependency] {
            second = dependency
            break
          }
        }
        diagnostics.push(
          EagerProgramInitializationCycle(
            candidates[first].declaration,
            candidates[second].declaration,
          ),
        )
      }
      for index in 0..<candidates.length() {
        if !scheduled[index] {
          scheduled[index] = true
          output.push(candidates[index])
        }
      }
      break
    }
    scheduled[selected] = true
    output.push(candidates[selected])
    for dependent in 0..<candidates.length() {
      if scheduled[dependent] {
        continue
      }
      for dependency in dependencies[dependent] {
        if dependency == selected {
          remaining_dependencies[dependent] -= 1
          break
        }
      }
    }
  }
  output
}

///|
fn program_physical_type_sccs(
  dependencies : Array[Array[Int]],
) -> (Array[HirSpan], Array[Int]) {
  let count = dependencies.length()
  if count == 0 {
    return ([], [])
  }
  let visited = Array::make(count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<count {
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
      let mut edge = edges.length()
      while edge > 0 {
        edge -= 1
        let dependency = edges[edge]
        if !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }
  let reverse_counts = Array::make(count, 0)
  for source in 0..<count {
    for dependency in dependencies[source] {
      reverse_counts[dependency] += 1
    }
  }
  let reverse_offsets = Array::make(count + 1, 0)
  for index in 0..<count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(count, 0)
  for index in 0..<count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[count], 0)
  for source in 0..<count {
    for dependency in dependencies[source] {
      let destination = reverse_cursor[dependency]
      reverse_edges[destination] = source
      reverse_cursor[dependency] += 1
    }
  }
  let finish_rank = Array::make(count, 0)
  for rank, entity in finish_order {
    finish_rank[entity] = rank
  }
  let assigned = Array::make(count, false)
  let component : Array[Int] = []
  let raw_spans : Array[HirSpan] = []
  let raw_members : Array[Int] = []
  let raw_ranks : Array[Int] = []
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
    let mut rank = finish_rank[start]
    while work.length() > 0 {
      let entity = work.pop().unwrap()
      component.push(entity)
      if finish_rank[entity] < rank {
        rank = finish_rank[entity]
      }
      for edge in reverse_offsets[entity]..<reverse_offsets[entity + 1] {
        let dependent = reverse_edges[edge]
        if !assigned[dependent] {
          assigned[dependent] = true
          work.push(dependent)
        }
      }
    }
    component.sort()
    let start = raw_members.length()
    for entity in component {
      raw_members.push(entity)
    }
    raw_spans.push({ start, length: raw_members.length() - start, })
    raw_ranks.push(rank)
  }
  let order : Array[Int] = []
  for index in 0..<raw_spans.length() {
    order.push(index)
  }
  order.sort_by(fn(left, right) {
    let rank = raw_ranks[left] - raw_ranks[right]
    if rank != 0 {
      rank
    } else {
      raw_members[raw_spans[left].start] - raw_members[raw_spans[right].start]
    }
  })
  let spans : Array[HirSpan] = []
  let members : Array[Int] = []
  for component_index in order {
    let source = raw_spans[component_index]
    let start = members.length()
    for index in 0..<source.length {
      members.push(raw_members[source.start + index])
    }
    spans.push({ start, length: members.length() - start, })
  }
  (spans, members)
}

///|
fn program_cross_module_type_groups(
  fragments : PlannedProgramSpecializationPlan,
  module_lookup : Map[ModuleId, Int],
  diagnostics : Array[ProgramWasmGCLinkDiagnostic],
) -> (
  Array[Array[Int]],
  Array[PlannedProgramWasmRecursiveGroup],
  Array[PlannedProgramWasmPhysicalType],
  Map[DeclId, Int],
) {
  let node_by_module_type : Array[Array[Int]] = []
  for module_ in fragments.modules {
    node_by_module_type.push(Array::make(module_.physical_types.length(), -1))
  }
  let nodes : Array[PlannedProgramWasmPhysicalType] = []
  let mut canonical_closure_node = -1
  let trait_method_nodes : Map[DeclId, Int] = Map::default()
  let trait_vtable_nodes : Map[DeclId, Int] = Map::default()
  let trait_object_nodes : Map[DeclId, Int] = Map::default()
  for scc in fragments.graph.sccs {
    for member_index in 0..<scc.length {
      let module_index = fragments.graph.scc_modules[scc.start + member_index]
      let module_ = fragments.modules[module_index]
      for fragment_index, physical in module_.physical_types {
        match physical.kind {
          PlannedWasmClosureType if canonical_closure_node >= 0 =>
            node_by_module_type[module_index][fragment_index] = canonical_closure_node
          PlannedWasmClosureType => {
            canonical_closure_node = nodes.length()
            node_by_module_type[module_index][fragment_index] = canonical_closure_node
            nodes.push({ module_index, fragment_index, })
          }
          PlannedWasmTraitMethodSignatureType(requirement) =>
            match trait_method_nodes.get(requirement) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_method_nodes[requirement] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index, })
              }
            }
          PlannedWasmTraitVTableType(trait_) =>
            match trait_vtable_nodes.get(trait_) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_vtable_nodes[trait_] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index, })
              }
            }
          PlannedWasmTraitObjectType(trait_) =>
            match trait_object_nodes.get(trait_) {
              Some(node) =>
                node_by_module_type[module_index][fragment_index] = node
              None => {
                let node = nodes.length()
                trait_object_nodes[trait_] = node
                node_by_module_type[module_index][fragment_index] = node
                nodes.push({ module_index, fragment_index, })
              }
            }
          _ => {
            node_by_module_type[module_index][fragment_index] = nodes.length()
            nodes.push({ module_index, fragment_index, })
          }
        }
      }
    }
  }
  let dependencies : Array[Array[Int]] = []
  for node in nodes {
    let module_ = fragments.modules[node.module_index]
    let physical = module_.physical_types[node.fragment_index]
    let values : Array[Int] = []
    let marks : Map[Int, Bool] = Map::default()
    let add_local = fn(local_type_index : Int) {
      if local_type_index < 0 ||
        local_type_index >= node_by_module_type[node.module_index].length() {
        return
      }
      let dependency = node_by_module_type[node.module_index][local_type_index]
      if dependency >= 0 && !marks.contains(dependency) {
        marks[dependency] = true
        values.push(dependency)
      }
    }
    let add_external = fn(declaration : DeclId) {
      let owner = match module_lookup.get(semantic_id_module(declaration)) {
        Some(value) => value
        None => {
          diagnostics.push(MissingProgramType(module_.module_id, declaration))
          return
        }
      }
      let local_type_index = match
        fragments.modules[owner].type_index_of(declaration) {
        Some(value) => value
        None => {
          diagnostics.push(MissingProgramType(module_.module_id, declaration))
          return
        }
      }
      let dependency = node_by_module_type[owner][local_type_index]
      if dependency >= 0 && !marks.contains(dependency) {
        marks[dependency] = true
        values.push(dependency)
      }
    }
    match physical.kind {
      PlannedWasmEnumSubtypeType(declaration, _, _) => add_external(declaration)
      PlannedWasmLambdaClosureType(_) => add_local(module_.closure_type_index)
      _ => ()
    }
    for index in 0..<physical.fields.length {
      match module_.fields[physical.fields.start + index].storage {
        WasmNominalRefStorage(WasmModuleTypeReference(local_type_index))
        | WasmNullableNominalRefStorage(
          WasmModuleTypeReference(local_type_index)
        ) => add_local(local_type_index)
        WasmNominalRefStorage(WasmRecursiveTypeReference(group_member))
        | WasmNullableNominalRefStorage(
          WasmRecursiveTypeReference(group_member)
        ) => {
          let group = module_.type_groups[physical.group_index]
          add_local(group.first_type_index + group_member)
        }
        WasmExternalNominalRefStorage(declaration)
        | WasmNullableExternalNominalRefStorage(declaration) =>
          add_external(declaration)
        _ => ()
      }
    }
    values.sort()
    dependencies.push(values)
  }
  let (component_spans, component_members) = program_physical_type_sccs(
    dependencies,
  )
  let module_type_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_type_indices.push(Array::make(module_.physical_types.length(), -1))
  }
  let groups : Array[PlannedProgramWasmRecursiveGroup] = []
  let physical_types : Array[PlannedProgramWasmPhysicalType] = []
  let type_lookup : Map[DeclId, Int] = Map::default()
  let final_index_by_node = Array::make(nodes.length(), -1)
  for component in component_spans {
    let first_type_index = physical_types.length()
    let start = physical_types.length()
    for index in 0..<component.length {
      let node = nodes[component_members[component.start + index]]
      let final_type_index = physical_types.length()
      final_index_by_node[component_members[component.start + index]] = final_type_index
      module_type_indices[node.module_index][node.fragment_index] = final_type_index
      let physical = fragments.modules[node.module_index].physical_types[node.fragment_index]
      match physical.kind {
        PlannedWasmStructType(declaration)
        | PlannedWasmForeignMarkerType(declaration)
        | PlannedWasmEnumBaseType(declaration) =>
          type_lookup[declaration] = final_type_index
        PlannedWasmEnumSubtypeType(_, _, _)
        | PlannedWasmClosureType
        | PlannedWasmCaptureCellType(_)
        | PlannedWasmLambdaClosureType(_)
        | PlannedWasmTraitMethodSignatureType(_)
        | PlannedWasmTraitVTableType(_)
        | PlannedWasmTraitObjectType(_) => ()
      }
      physical_types.push(node)
    }
    groups.push({
      types: { start, length: physical_types.length() - start, },
      first_type_index,
    })
  }
  for module_index, indices in node_by_module_type {
    for fragment_index, node in indices {
      if node >= 0 {
        module_type_indices[module_index][fragment_index] = final_index_by_node[node]
      }
    }
  }
  (module_type_indices, groups, physical_types, type_lookup)
}

///|
priv struct PlannedProgramValueTypePair {
  left_module : Int
  left : PlannedWasmValueType
  right_module : Int
  right : PlannedWasmValueType
}

///|
fn planned_program_function_type_fragment(
  modules : Array[PlannedModuleWasmGCFragments],
  module_index : Int,
  signature_type_index : Int,
) -> PlannedWasmFunctionTypeFragment? {
  for function_type in modules[module_index].function_types {
    if function_type.signature_type_index == signature_type_index {
      return Some(function_type)
    }
  }
  None
}

///|
fn planned_program_local_nominal_declaration(
  modules : Array[PlannedModuleWasmGCFragments],
  module_index : Int,
  type_index : Int,
) -> DeclId? {
  if type_index < 0 ||
    type_index >= modules[module_index].physical_types.length() {
    return None
  }
  match modules[module_index].physical_types[type_index].kind {
    PlannedWasmStructType(declaration)
    | PlannedWasmForeignMarkerType(declaration)
    | PlannedWasmEnumBaseType(declaration) => Some(declaration)
    PlannedWasmEnumSubtypeType(_, _, _)
    | PlannedWasmClosureType
    | PlannedWasmCaptureCellType(_)
    | PlannedWasmLambdaClosureType(_)
    | PlannedWasmTraitMethodSignatureType(_)
    | PlannedWasmTraitVTableType(_)
    | PlannedWasmTraitObjectType(_) => None
  }
}

///|
fn planned_program_function_types_equal(
  modules : Array[PlannedModuleWasmGCFragments],
  left_module : Int,
  left : PlannedWasmFunctionTypeFragment,
  right_module : Int,
  right : PlannedWasmFunctionTypeFragment,
) -> Bool {
  if left.parameters.length != right.parameters.length ||
    left.results.length != right.results.length {
    return false
  }
  let work : Array[PlannedProgramValueTypePair] = []
  for index in 0..<left.parameters.length {
    work.push({
      left_module,
      left: modules[left_module].function_value_types[left.parameters.start +
      index],
      right_module,
      right: modules[right_module].function_value_types[right.parameters.start +
      index],
    })
  }
  for index in 0..<left.results.length {
    work.push({
      left_module,
      left: modules[left_module].function_value_types[left.results.start + index],
      right_module,
      right: modules[right_module].function_value_types[right.results.start +
      index],
    })
  }
  while work.length() > 0 {
    let pair = work.pop().unwrap()
    match (pair.left, pair.right) {
      (WasmI32Value, WasmI32Value)
      | (WasmI64Value, WasmI64Value)
      | (WasmF32Value, WasmF32Value)
      | (WasmF64Value, WasmF64Value)
      | (WasmV128Value, WasmV128Value)
      | (WasmStringRefValue, WasmStringRefValue)
      | (WasmNullableEqRefValue, WasmNullableEqRefValue) => ()
      (WasmFixedArrayRefValue(left), WasmFixedArrayRefValue(right)) =>
        if left != right {
          return false
        }
      (WasmExternalNominalRefValue(left), WasmExternalNominalRefValue(right)) =>
        if left != right {
          return false
        }
      (WasmNominalRefValue(left), WasmNominalRefValue(right)) => {
        let left_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) {
          Some(value) => value
          None => return false
        }
        let right_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          Some(value) => value
          None => return false
        }
        if left_declaration != right_declaration {
          return false
        }
      }
      (WasmNominalRefValue(left), WasmExternalNominalRefValue(right)) =>
        if planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) !=
          Some(right) {
          return false
        }
      (WasmExternalNominalRefValue(left), WasmNominalRefValue(right)) =>
        if Some(left) !=
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          return false
        }
      (
        WasmNullableExternalNominalRefValue(left),
        WasmNullableExternalNominalRefValue(right),
      ) => if left != right { return false }
      (WasmNullableNominalRefValue(left), WasmNullableNominalRefValue(right)) => {
        let left_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) {
          Some(value) => value
          None => return false
        }
        let right_declaration = match
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          Some(value) => value
          None => return false
        }
        if left_declaration != right_declaration {
          return false
        }
      }
      (
        WasmNullableNominalRefValue(left),
        WasmNullableExternalNominalRefValue(right),
      ) =>
        if planned_program_local_nominal_declaration(
            modules,
            pair.left_module,
            left,
          ) !=
          Some(right) {
          return false
        }
      (
        WasmNullableExternalNominalRefValue(left),
        WasmNullableNominalRefValue(right),
      ) =>
        if Some(left) !=
          planned_program_local_nominal_declaration(
            modules,
            pair.right_module,
            right,
          ) {
          return false
        }
      (WasmFunctionRefValue(left), WasmFunctionRefValue(right)) => {
        let left_type = match
          planned_program_function_type_fragment(
            modules,
            pair.left_module,
            left,
          ) {
          Some(value) => value
          None => return false
        }
        let right_type = match
          planned_program_function_type_fragment(
            modules,
            pair.right_module,
            right,
          ) {
          Some(value) => value
          None => return false
        }
        if left_type.parameters.length != right_type.parameters.length ||
          left_type.results.length != right_type.results.length {
          return false
        }
        for index in 0..<left_type.parameters.length {
          work.push({
            left_module: pair.left_module,
            left: modules[pair.left_module].function_value_types[left_type.parameters.start +
            index],
            right_module: pair.right_module,
            right: modules[pair.right_module].function_value_types[right_type.parameters.start +
            index],
          })
        }
        for index in 0..<left_type.results.length {
          work.push({
            left_module: pair.left_module,
            left: modules[pair.left_module].function_value_types[left_type.results.start +
            index],
            right_module: pair.right_module,
            right: modules[pair.right_module].function_value_types[right_type.results.start +
            index],
          })
        }
      }
      _ => return false
    }
  }
  true
}

///|
/// Assigns final program-wide type and function indices without mutating any
/// module-local fragment plan. Module-local recursive groups remain intact
/// unless physical dependencies form an SCC across module boundaries.
pub fn link_program_wasmgc_fragments(
  fragments : PlannedProgramSpecializationPlan,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink {
  assert_module_dependency_graph(fragments.graph)
  guard root_module_index >= 0 && root_module_index < lowering.modules.length() else {
    abort("program root module index is outside the manifest")
  }
  // Preserve numeric source context before generic arena validation or
  // signature interning can consume a malformed fragment table.
  for module_ in fragments.modules {
    match verify_module_physical_type_fragments(module_) {
      Ok(_) => ()
      Err(error) => abort(@debug.to_string(error))
    }
  }
  match validate_program_specialization_plan(fragments, lowering) {
    Ok(_) => ()
    Err(error) => abort(error)
  }
  let module_type_bases = Array::make(lowering.modules.length(), -1)
  let module_type_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_type_indices.push(Array::make(module_.physical_types.length(), -1))
  }
  let functions : Array[PlannedProgramWasmFunction] = []
  let function_lookup : Map[DeclId, Int] = Map::default()
  let type_lookup : Map[DeclId, Int] = Map::default()
  let module_lookup = lowering.index.module_lookup
  let diagnostics : Array[ProgramWasmGCLinkDiagnostic] = []
  match lowering.compile_time {
    Some(context) =>
      for module_ in fragments.modules {
        for function_ in module_.functions {
          match context.instances.get(function_.specialization_abi_key) {
            Some(instance) =>
              for diagnostic in instance.module_.diagnostics {
                match diagnostic {
                  CompileTimeQueryDiagnostic(expression, message, offset) =>
                    diagnostics.push(
                      ProgramCompileTimeFailure(
                        module_.module_id,
                        function_.declaration,
                        function_.specialization_abi_key,
                        expression,
                        message,
                        offset,
                      ),
                    )
                  _ =>
                    abort(
                      "INV-001 unexpected diagnostic in compile-time instance",
                    )
                }
              }
            None => ()
          }
        }
      }
    None => ()
  }
  let test_ordinals : Map[DeclId, Int] = Map::default()
  let mut next_test_ordinal = 0
  for module_ in fragments.modules {
    for function_ in module_.functions {
      if function_.is_test_entry {
        test_ordinals[function_.declaration] = next_test_ordinal
        next_test_ordinal += 1
      }
    }
  }
  let mut uses_fixed_array_types = false
  for module_ in fragments.modules {
    if module_.uses_fixed_array_runtime {
      uses_fixed_array_types = true
      break
    }
    for value in module_.function_value_types {
      match value {
        WasmFixedArrayRefValue(_) => {
          uses_fixed_array_types = true
          break
        }
        _ => ()
      }
    }
    if uses_fixed_array_types {
      break
    }
  }
  let mut type_count = 0
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_fragments = fragments.modules[module_index]
      module_type_bases[module_index] = type_count
      for physical in module_fragments.physical_types {
        module_type_indices[module_index][physical.type_index] = type_count +
          physical.type_index
        match physical.kind {
          PlannedWasmStructType(declaration)
          | PlannedWasmForeignMarkerType(declaration)
          | PlannedWasmEnumBaseType(declaration) =>
            type_lookup[declaration] = type_count + physical.type_index
          PlannedWasmEnumSubtypeType(_, _, _)
          | PlannedWasmClosureType
          | PlannedWasmCaptureCellType(_)
          | PlannedWasmLambdaClosureType(_)
          | PlannedWasmTraitMethodSignatureType(_)
          | PlannedWasmTraitVTableType(_)
          | PlannedWasmTraitObjectType(_) => ()
        }
      }
      type_count += module_fragments.physical_types.length()
    }
  }
  let mut closure_base_count = 0
  for module_ in fragments.modules {
    if module_.closure_type_index >= 0 {
      closure_base_count += 1
    }
  }
  let mut cross_module_type_scc = closure_base_count > 1
  let trait_method_owners : Map[DeclId, Int] = Map::default()
  let trait_vtable_owners : Map[DeclId, Int] = Map::default()
  let trait_object_owners : Map[DeclId, Int] = Map::default()
  for module_index, module_ in fragments.modules {
    for physical in module_.physical_types {
      let owners = match physical.kind {
        PlannedWasmTraitMethodSignatureType(_) => trait_method_owners
        PlannedWasmTraitVTableType(_) => trait_vtable_owners
        PlannedWasmTraitObjectType(_) => trait_object_owners
        _ => continue
      }
      let declaration = match physical.kind {
        PlannedWasmTraitMethodSignatureType(value)
        | PlannedWasmTraitVTableType(value)
        | PlannedWasmTraitObjectType(value) => value
        _ => continue
      }
      match owners.get(declaration) {
        Some(owner) if owner != module_index => cross_module_type_scc = true
        Some(_) => ()
        None => owners[declaration] = module_index
      }
    }
  }
  for reference in fragments.external_type_references {
    match type_lookup.get(reference.declaration) {
      Some(index) =>
        if index >= module_type_bases[reference.module_index] {
          cross_module_type_scc = true
        }
      None => ()
    }
  }
  let program_type_groups : Array[PlannedProgramWasmRecursiveGroup] = []
  let program_physical_types : Array[PlannedProgramWasmPhysicalType] = []
  let mut fixed_array_type_base = -1
  if cross_module_type_scc {
    let (cross_indices, cross_groups, cross_types, cross_lookup) = program_cross_module_type_groups(
      fragments, module_lookup, diagnostics,
    )
    for module_index in 0..<module_type_indices.length() {
      module_type_indices[module_index] = cross_indices[module_index]
    }
    for group in cross_groups {
      program_type_groups.push(group)
    }
    for physical in cross_types {
      program_physical_types.push(physical)
    }
    for declaration, index in cross_lookup {
      type_lookup[declaration] = index
    }
    type_count = program_physical_types.length()
    if uses_fixed_array_types {
      fixed_array_type_base = type_count
      type_count += 8
    }
  } else {
    program_link_validate_types(fragments, type_lookup, diagnostics)
    if uses_fixed_array_types {
      fixed_array_type_base = 0
      type_count = 8
    } else {
      type_count = 0
    }
  }
  let module_signature_indices : Array[Array[Int]] = []
  for module_ in fragments.modules {
    module_signature_indices.push(Array::make(module_.signature_type_count, -1))
  }
  let program_signature_types : Array[PlannedProgramWasmSignatureType] = []
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_ = fragments.modules[module_index]
      if !cross_module_type_scc {
        module_type_bases[module_index] = type_count
        for physical in module_.physical_types {
          module_type_indices[module_index][physical.type_index] = type_count +
            physical.type_index
          match physical.kind {
            PlannedWasmStructType(declaration)
            | PlannedWasmForeignMarkerType(declaration)
            | PlannedWasmEnumBaseType(declaration) =>
              type_lookup[declaration] = type_count + physical.type_index
            PlannedWasmEnumSubtypeType(_, _, _)
            | PlannedWasmClosureType
            | PlannedWasmCaptureCellType(_)
            | PlannedWasmLambdaClosureType(_)
            | PlannedWasmTraitMethodSignatureType(_)
            | PlannedWasmTraitVTableType(_)
            | PlannedWasmTraitObjectType(_) => ()
          }
        }
        type_count += module_.physical_types.length()
      }
      for function_type_index, function_type in module_.function_types {
        let local_signature = function_type.signature_type_index -
          module_.physical_types.length()
        let mut representative_type_index = -1
        for candidate in program_signature_types {
          match candidate.kind {
            PlannedProgramFunctionType(candidate_function_type_index) => {
              let candidate_type = fragments.modules[candidate.module_index].function_types[candidate_function_type_index]
              if planned_program_function_types_equal(
                  fragments.modules,
                  module_index,
                  function_type,
                  candidate.module_index,
                  candidate_type,
                ) {
                representative_type_index = candidate.type_index
                break
              }
            }
            PlannedProgramFunctionSignature(_) => ()
          }
        }
        if representative_type_index < 0 {
          representative_type_index = type_count
          program_signature_types.push({
            module_index,
            type_index: representative_type_index,
            kind: PlannedProgramFunctionType(function_type_index),
          })
          type_count += 1
        }
        module_signature_indices[module_index][local_signature] = representative_type_index
      }
      for function_index, function_ in module_.functions {
        if function_.signature_type_index < module_.physical_types.length() {
          continue
        }
        let local_signature = function_.signature_type_index -
          module_.physical_types.length()
        if module_signature_indices[module_index][local_signature] < 0 {
          module_signature_indices[module_index][local_signature] = type_count
          program_signature_types.push({
            module_index,
            type_index: type_count,
            kind: PlannedProgramFunctionSignature(function_index),
          })
          type_count += 1
        }
      }
    }
  }
  let erased_box_used = Array::make(5, false)
  for module_index, module_ in fragments.modules {
    for method_info in module_.trait_methods {
      let slot = wasmgc_trait_receiver_box_slot(method_info.receiver_shape)
      if slot >= 0 {
        erased_box_used[slot] = true
      }
    }
    let module_lowering = lowering.modules[module_index]
    for capture in module_lowering.captures {
      match capture.shape {
        ProductPlannedValueShape(_) =>
          program_mark_product_erased_boxes(capture.shape, erased_box_used)
        _ => ()
      }
    }
    for step in module_lowering.initialization.steps {
      let body_id = match step.kind {
        PlannedInitializeModuleValue(_, body, _) => body
        PlannedCyclicModuleValues(_) => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index >= 0 && body_index < module_lowering.bodies.length() {
        match module_lowering.bodies[body_index].result_shape {
          ProductPlannedValueShape(_) =>
            program_mark_product_erased_boxes(
              module_lowering.bodies[body_index].result_shape,
              erased_box_used,
            )
          _ => ()
        }
      }
    }
    for function_ in module_.functions {
      for index in 0..<function_.specialization_shapes.length {
        let shape = module_.specialization_shapes[function_.specialization_shapes.start +
          index]
        match shape {
          ProductPlannedValueShape(_) | GenericPlannedValueShape =>
            program_mark_product_erased_boxes(shape, erased_box_used)
          _ => ()
        }
      }
    }
    for expression in module_lowering.expressions {
      match expression.kind {
        PlannedArrayLiteral(_, _, shape) =>
          match shape {
            ProductPlannedValueShape(_) =>
              program_mark_product_erased_boxes(shape, erased_box_used)
            _ => ()
          }
        PlannedFieldGet(_, _, _) =>
          match expression.shape {
            ProductPlannedValueShape(_) =>
              program_mark_product_erased_boxes(
                expression.shape,
                erased_box_used,
              )
            _ => ()
          }
        PlannedFieldSet(_, _, value) =>
          match module_lowering.expressions[value].shape {
            ProductPlannedValueShape(_) =>
              program_mark_product_erased_boxes(
                module_lowering.expressions[value].shape,
                erased_box_used,
              )
            _ => ()
          }
        PlannedStructNew(_, _, fields)
        | PlannedVariantStructNew(_, _, fields) =>
          for field_index in 0..<fields.length {
            let value = module_lowering.object_fields[fields.start + field_index].value
            match module_lowering.expressions[value].shape {
              ProductPlannedValueShape(_) =>
                program_mark_product_erased_boxes(
                  module_lowering.expressions[value].shape,
                  erased_box_used,
                )
              _ => ()
            }
          }
        PlannedVariantTupleNew(_, _, arguments) =>
          for argument_index in 0..<arguments.length {
            let value = module_lowering.expression_children[arguments.start +
              argument_index]
            match module_lowering.expressions[value].shape {
              ProductPlannedValueShape(_) =>
                program_mark_product_erased_boxes(
                  module_lowering.expressions[value].shape,
                  erased_box_used,
                )
              _ => ()
            }
          }
        _ => ()
      }
    }
  }
  let root_lowering = lowering.modules[root_module_index]
  let root_fragments = fragments.modules[root_module_index]
  for function_ in root_fragments.functions {
    if function_.specialization_shapes.length == 0 {
      continue
    }
    let callable = match
      root_lowering.functions.callable_of(function_.declaration) {
      Some(value) => value
      None => continue
    }
    if callable.visibility != Public {
      continue
    }
    for index in 0..<function_.specialization_shapes.length {
      let slot = program_erased_box_slot_for_shape(
        root_fragments.specialization_shapes[function_.specialization_shapes.start +
        index],
      )
      if slot >= 0 {
        erased_box_used[slot] = true
      }
    }
  }
  let erased_box_type_indices = Array::make(5, -1)
  for slot in 0..<erased_box_used.length() {
    if erased_box_used[slot] {
      erased_box_type_indices[slot] = type_count
      type_count += 1
    }
  }
  for scc in lowering.graph.sccs {
    for index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + index]
      let module_fragments = fragments.modules[module_index]
      for physical in module_fragments.physical_types {
        match physical.kind {
          PlannedWasmStructType(declaration)
          | PlannedWasmForeignMarkerType(declaration)
          | PlannedWasmEnumBaseType(declaration) =>
            match
              lowering.modules[module_index].type_layouts.layout_of(declaration) {
              Some(layout) if layout.generic_parameters.length > 0 => ()
              _ => ()
            }
          PlannedWasmEnumSubtypeType(_, _, _)
          | PlannedWasmClosureType
          | PlannedWasmCaptureCellType(_)
          | PlannedWasmLambdaClosureType(_)
          | PlannedWasmTraitMethodSignatureType(_)
          | PlannedWasmTraitVTableType(_)
          | PlannedWasmTraitObjectType(_) => ()
        }
      }
      for fragment_index, function_ in module_fragments.functions {
        let entry = functions.length()
        if function_.specialization_shapes.length == 0 {
          function_lookup[function_.declaration] = entry
        }
        functions.push({
          declaration: function_.declaration,
          lambda: function_.lambda,
          module_index,
          fragment_index,
          name: match test_ordinals.get(function_.declaration) {
            Some(ordinal) => program_test_export_name(ordinal)
            None => function_.name
          },
          visibility: function_.visibility,
          is_test: function_.is_test,
          is_test_entry: function_.is_test_entry,
          test_name: function_.test_name,
          kind: function_.kind,
          direct_builtin: function_.direct_builtin,
          elided: function_.elided,
          signature_type_index: if function_.signature_type_index >=
            module_fragments.physical_types.length() {
            module_signature_indices[module_index][function_.signature_type_index -
            module_fragments.physical_types.length()]
          } else if function_.signature_type_index >= 0 {
            module_type_indices[module_index][function_.signature_type_index]
          } else {
            -1
          },
          function_index: -1,
          parameters: function_.parameters,
          results: function_.results,
          specialization_shapes: function_.specialization_shapes,
          specialization_evidence: function_.specialization_evidence,
          specialization_abi_key: function_.specialization_abi_key,
          erased_adapter_target: -1,
          offset: function_.offset,
        })
      }
    }
  }
  let mut imported_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmImportedFunction(_) =>
        if !function_.elided {
          function_.function_index = imported_function_count
          imported_function_count += 1
        } else {
          function_.function_index = -1
        }
      PlannedWasmInlineBuiltinFunction(_)
      | PlannedWasmOutlinedBuiltinFunction(_)
      | PlannedWasmRuntimeFunction(_)
      | PlannedWasmDefinedFunction(_)
      | PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmTraitAdapterFunction(_, _)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  let mut defined_function_count = 0
  for function_ in functions {
    match function_.kind {
      PlannedWasmDefinedFunction(_)
      | PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmOutlinedBuiltinFunction(_)
      | PlannedWasmRuntimeFunction(_)
      | PlannedWasmTraitAdapterFunction(_, _) =>
        if !function_.elided {
          function_.function_index = imported_function_count +
            defined_function_count
          defined_function_count += 1
        }
      PlannedWasmImportedFunction(_)
      | PlannedWasmInlineBuiltinFunction(_)
      | PlannedWasmSignatureOnlyFunction => ()
    }
  }
  let root_function_count = functions.length()
  for callable in root_lowering.functions.callables {
    if callable.visibility != Public ||
      program_callable_generic_parameters(callable).length == 0 {
      continue
    }
    let mut fallback_index = -1
    for index in 0..<root_function_count {
      let candidate = functions[index]
      if candidate.declaration != callable.declaration ||
        candidate.visibility != Public ||
        candidate.specialization_shapes.length !=
        program_callable_generic_parameters(callable).length {
        continue
      }
      let candidate_module = fragments.modules[candidate.module_index]
      let mut all_ref = true
      for shape_index in 0..<candidate.specialization_shapes.length {
        if program_canonical_specialization_shape(
            candidate_module.specialization_shapes[candidate.specialization_shapes.start +
            shape_index],
          ) !=
          RefPlannedValueShape {
          all_ref = false
          break
        }
      }
      if all_ref {
        fallback_index = index
        break
      }
    }
    if fallback_index < 0 || functions[fallback_index].function_index < 0 {
      continue
    }
    let fallback = functions[fallback_index]
    for specialization_index in 0..<root_function_count {
      let specialization = functions[specialization_index]
      if specialization.declaration != callable.declaration ||
        specialization.specialization_shapes.length == 0 ||
        specialization.function_index < 0 ||
        specialization_index == fallback_index {
        continue
      }
      let specialization_module = fragments.modules[specialization.module_index]
      let mut has_scalar = false
      for shape_index in 0..<specialization.specialization_shapes.length {
        if program_erased_box_slot_for_shape(
            specialization_module.specialization_shapes[specialization.specialization_shapes.start +
            shape_index],
          ) >=
          0 {
          has_scalar = true
          break
        }
      }
      if !has_scalar {
        continue
      }
      let source = {
        resolved_type: -1,
        signature_type_index: specialization.signature_type_index,
        parameters: specialization.parameters,
        results: specialization.results,
      }
      if !program_erased_adapter_compatible(
          specialization_module,
          source,
          fragments.modules[fallback.module_index],
          fallback,
        ) {
        continue
      }
      functions.push({
        declaration: callable.declaration,
        lambda: -1,
        module_index: root_module_index,
        fragment_index: -1,
        name: program_erased_adapter_export_name(
          callable.name,
          specialization_module.specialization_shapes,
          specialization.specialization_shapes,
        ),
        visibility: Public,
        is_test: false,
        is_test_entry: false,
        test_name: b"",
        kind: PlannedWasmRuntimeFunction(b""),
        direct_builtin: b"",
        elided: false,
        signature_type_index: specialization.signature_type_index,
        function_index: imported_function_count + defined_function_count,
        parameters: specialization.parameters,
        results: specialization.results,
        specialization_shapes: specialization.specialization_shapes,
        specialization_evidence: specialization.specialization_evidence,
        specialization_abi_key: specialization.specialization_abi_key,
        erased_adapter_target: fallback.function_index,
        offset: callable.offset,
      })
      defined_function_count += 1
    }
  }
  let initializer_candidates : Array[PlannedProgramModuleInitializer] = []
  let global_lookup : Map[DeclId, Int] = Map::default()
  let mut global_index = 0
  for scc in lowering.graph.sccs {
    for member_index in 0..<scc.length {
      let module_index = lowering.graph.scc_modules[scc.start + member_index]
      let module_ = lowering.modules[module_index]
      for step in module_.initialization.steps {
        match step.kind {
          PlannedInitializeModuleValue(declaration, body, _) => {
            if step.test_only && !fragments.modules[module_index].emit_tests {
              continue
            }
            let source = assert_program_initializer_source(module_, declaration, body)
            let shape = source.root_shape
            let value_global = match shape {
              UnitPlannedValueShape | NeverPlannedValueShape => -1
              _ => {
                let index = global_index
                global_lookup[declaration] = index
                global_index += 1
                index
              }
            }
            let constant = match source.root {
              ExpressionBodyRoot(expression) =>
                match module_.expressions[expression].kind {
                  PlannedI8Const(_)
                  | PlannedI16Const(_)
                  | PlannedI32Const(_)
                  | PlannedI64Const(_)
                  | PlannedU8Const(_)
                  | PlannedU16Const(_)
                  | PlannedU32Const(_)
                  | PlannedU64Const(_)
                  | PlannedF32Const(_)
                  | PlannedF64Const(_)
                  | PlannedBoolConst(_) => true
                  _ => false
                }
              BlockBodyRoot(_) => false
            }
            initializer_candidates.push({
              declaration,
              module_index,
              body,
              shape,
              test_only: step.test_only,
              constant,
              global_index: value_global,
              function_index: -1,
            })
          }
          PlannedCyclicModuleValues(_) => ()
        }
      }
    }
  }
  let function_reference_singletons : Array[
    PlannedProgramFunctionReferenceSingleton,
  ] = []
  let singleton_functions : Map[Int, Bool] = Map::default()
  for module_index, module_ in lowering.modules {
    for expression_index, expression in module_.expressions {
      match expression.kind {
        PlannedFunctionReference(declaration, arguments) => {
          let target = if arguments.length > 0 {
            let mut selected = None
            for function_ in functions {
              if function_.declaration == declaration &&
                function_.specialization_shapes.length > 0 &&
                program_specialization_shapes_equal(
                  fragments.modules[function_.module_index].specialization_shapes,
                  function_.specialization_shapes,
                  module_.expression_type_argument_shapes,
                  arguments,
                ) {
                selected = Some(function_)
                break
              }
            }
            selected
          } else {
            match function_lookup.get(declaration) {
              Some(index) => Some(functions[index])
              None => None
            }
          }
          let resolved_type = program_body_resolved_type(
            module_,
            expression.type_,
          )
          let local_signature = if resolved_type >= 0 &&
            resolved_type <
            fragments.modules[module_index].function_type_by_resolved.length() {
            fragments.modules[module_index].function_type_by_resolved[resolved_type]
          } else {
            -1
          }
          let signature_type_index = if local_signature >=
            fragments.modules[module_index].physical_types.length() {
            module_signature_indices[module_index][local_signature -
            fragments.modules[module_index].physical_types.length()]
          } else {
            -1
          }
          match target {
            Some(function_) if function_.function_index >= 0 => {
              let mut reference_function = function_
              if signature_type_index >= 0 &&
                signature_type_index != function_.signature_type_index {
                let mut source_signature = None
                for candidate in fragments.modules[module_index].function_types {
                  if candidate.signature_type_index == local_signature {
                    source_signature = Some(candidate)
                    break
                  }
                }
                match source_signature {
                  Some(source) if !planned_program_function_types_equal(
                      fragments.modules,
                      module_index,
                      source,
                      function_.module_index,
                      {
                        resolved_type: -1,
                        signature_type_index: function_.signature_type_index,
                        parameters: function_.parameters,
                        results: function_.results,
                      },
                    ) &&
                    program_erased_adapter_compatible(
                      fragments.modules[module_index],
                      source,
                      fragments.modules[function_.module_index],
                      function_,
                    ) => {
                    let mut adapter_index = -1
                    for index, candidate in functions {
                      if candidate.erased_adapter_target ==
                        function_.function_index &&
                        candidate.signature_type_index == signature_type_index {
                        adapter_index = index
                        break
                      }
                    }
                    if adapter_index < 0 {
                      adapter_index = functions.length()
                      functions.push({
                        declaration,
                        lambda: -1,
                        module_index,
                        fragment_index: -1,
                        name: b"",
                        visibility: ModuleVisible,
                        is_test: false,
                        is_test_entry: false,
                        test_name: b"",
                        kind: PlannedWasmRuntimeFunction(b""),
                        direct_builtin: b"",
                        elided: false,
                        signature_type_index,
                        function_index: imported_function_count +
                        defined_function_count,
                        parameters: source.parameters,
                        results: source.results,
                        specialization_shapes: { start: 0, length: 0, },
                        specialization_evidence: { start: 0, length: 0, },
                        specialization_abi_key: "",
                        erased_adapter_target: function_.function_index,
                        offset: expression.offset,
                      })
                      defined_function_count += 1
                    }
                    reference_function = functions[adapter_index]
                  }
                  _ => ()
                }
              }
              if !singleton_functions.contains(
                  reference_function.function_index,
                ) {
                singleton_functions[reference_function.function_index] = true
                function_reference_singletons.push({
                  module_index,
                  declaration,
                  function_index: reference_function.function_index,
                  specialization_module_index: function_.module_index,
                  specialization_shapes: function_.specialization_shapes,
                  signature_type_index,
                  global_index,
                })
                global_index += 1
              }
            }
            _ => ()
          }
        }
        _ => ()
      }
      ignore(expression_index)
    }
  }
  // References in generic bodies need their caller-specific target, not the
  // unspecialized expression shape. Keep one singleton per physical function.
  let function_by_specialization : Map[String, Int] = Map::default()
  for index, function_ in functions {
    if function_.specialization_abi_key != "" && function_.function_index >= 0 {
      function_by_specialization[function_.specialization_abi_key] = index
    }
  }
  for call in fragments.specialized_calls {
    if call.caller_specialization_abi_key == "" {
      // The concrete source reference scan above also selects exact-reference
      // adapters. Do not add an unused raw singleton beside that adapter.
      continue
    }
    let module_index = lowering.index.body_owner(call.caller_body).unwrap()
    let source = lowering.modules[module_index].expressions[call.expression]
    if !(source.kind is PlannedFunctionReference(_, _)) ||
      call.runtime_evidence_parameters.length > 0 {
      continue
    }
    match function_by_specialization.get(call.target_specialization_abi_key) {
      Some(index) => {
        let target = functions[index]
        guard target.declaration == call.target else {
          abort("SPC-302 function reference key changed declaration identity")
        }
        if !singleton_functions.contains(target.function_index) {
          singleton_functions[target.function_index] = true
          function_reference_singletons.push({
            module_index,
            declaration: target.declaration,
            function_index: target.function_index,
            specialization_module_index: target.module_index,
            specialization_shapes: target.specialization_shapes,
            signature_type_index: target.signature_type_index,
            global_index,
          })
          global_index += 1
        }
      }
      None => () // The link verifier reports the absent exact target.
    }
  }
  let trait_dictionary_globals : Array[PlannedProgramTraitDictionaryGlobal] = []
  for module_index, module_ in fragments.modules {
    for dictionary_index in 0..<module_.trait_dictionaries.length() {
      if !module_.trait_dictionaries[dictionary_index].runtime_materialized {
        continue
      }
      trait_dictionary_globals.push({
        module_index,
        dictionary_index,
        global_index,
      })
      global_index += 1
    }
  }
  let scheduled_initializers = program_schedule_initializers(
    lowering, initializer_candidates, diagnostics,
  )
  let initializers : Array[PlannedProgramModuleInitializer] = []
  let mut runtime_initializer_count = 0
  for initializer in scheduled_initializers {
    if initializer.constant {
      initializers.push(initializer)
    } else {
      initializers.push({
        ..initializer,
        function_index: imported_function_count + defined_function_count,
      })
      defined_function_count += 1
      runtime_initializer_count += 1
    }
  }
  let needs_startup = runtime_initializer_count > 0 ||
    function_reference_singletons.length() > 0 ||
    trait_dictionary_globals.length() > 0
  let initializer_type_index = if needs_startup {
    let index = type_count
    type_count += 1
    index
  } else {
    -1
  }
  let startup_function_index = if needs_startup {
    let index = imported_function_count + defined_function_count
    defined_function_count += 1
    index
  } else {
    -1
  }
  program_link_validate_calls(
    lowering,
    fragments.modules,
    functions,
    function_lookup,
    fragments.specialized_calls,
    fragments.evidence_function_references,
    diagnostics,
  )
  let specialized_call_lookup : Map[ProgramSpecializedCallKey, Int] = Map::default()
  let specialized_call_targets : Map[
    ProgramSpecializedCallKey,
    PlannedProgramPhysicalCallTarget,
  ] = Map::default()
  let specialized_call_runtime_evidence_lookup : Map[
    ProgramSpecializedCallKey,
    HirSpan,
  ] = Map::default()
  for call in fragments.specialized_calls {
    let mut target_index = -1
    if call.target_specialization_abi_key.length() == 0 {
      match function_lookup.get(call.target) {
        Some(index) => target_index = index
        None => ()
      }
    } else {
      for index, function_ in functions {
        if function_.declaration == call.target &&
          function_.specialization_abi_key == call.target_specialization_abi_key {
          target_index = index
          break
        }
      }
    }
    if target_index >= 0 {
      match
        record_program_physical_call_target(
          specialized_call_targets, call, target_index, functions[target_index],
          fragments.specialized_call_runtime_evidence_parameters,
        ) {
        Ok(_) => ()
        Err(failure) => abort(@debug.to_string(failure))
      }
      let key = program_specialized_call_key(
        call.caller_body,
        call.caller_specialization_abi_key,
        call.expression,
      )
      specialized_call_lookup[key] = target_index
      if call.runtime_evidence_parameters.length > 0 {
        specialized_call_runtime_evidence_lookup[key] = call.runtime_evidence_parameters
      }
    }
  }
  let imported_function_indices : Map[Bytes, Int] = Map::default()
  let runtime_function_indices : Map[Bytes, Int] = Map::default()
  let module_runtime_function_indices : Array[Map[Bytes, Int]] = []
  for _ in fragments.modules {
    module_runtime_function_indices.push(Map::default())
  }
  for function_ in functions {
    if function_.elided || function_.function_index < 0 {
      continue
    }
    match function_.kind {
      PlannedWasmImportedFunction(identity) =>
        imported_function_indices[identity.lookup_name()] = function_.function_index
      PlannedWasmRuntimeFunction(name) => {
        runtime_function_indices[name] = function_.function_index
        if function_.module_index >= 0 &&
          function_.module_index < module_runtime_function_indices.length() {
          module_runtime_function_indices[function_.module_index][name] = function_.function_index
        }
      }
      _ => ()
    }
  }
  verify_program_compile_time_closure(lowering, functions, diagnostics)
  let link : PlannedProgramWasmGCLink = {
    root_module_index,
    graph: lowering.graph,
    modules: fragments.modules,
    module_type_bases,
    module_signature_indices,
    module_type_indices,
    program_type_groups,
    program_signature_types,
    program_physical_types,
    functions,
    function_lookup,
    specialized_call_lookup,
    specialized_call_targets,
    specialized_call_runtime_evidence_lookup,
    specialized_call_runtime_evidence_parameters: fragments.specialized_call_runtime_evidence_parameters,
    evidence_function_references: fragments.evidence_function_references,
    evidence_function_reference_runtime_evidence_parameters: fragments.evidence_function_reference_runtime_evidence_parameters,
    initializers,
    global_lookup,
    function_reference_singletons,
    trait_dictionary_globals,
    initializer_type_index,
    startup_function_index,
    type_lookup,
    module_lookup,
    erased_box_type_indices,
    fixed_array_type_base,
    type_count,
    imported_function_count,
    defined_function_count,
    imported_function_indices,
    runtime_function_indices,
    module_runtime_function_indices,
    diagnostics,
  }
  if diagnostics.is_empty() {
    assert_program_physical_type_fragments(link)
    assert_program_function_indices(link)
    assert_program_source_function_fragments(link)
    assert_program_named_function_lookups(link)
    assert_program_specialized_call_lookups(link)
    assert_program_call_evidence_recipes(link)
  }
  link
}

///|
pub fn plan_program_wasmgc_link_with_options(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
  options : WasmGCPlanningOptions,
) -> PlannedProgramWasmGCLink {
  link_program_wasmgc_fragments(
    plan_program_wasmgc_fragments_for_root(
      analyzed,
      lowering,
      options,
      root_module_index,
      Array::make(lowering.modules.length(), None),
      fn(_, _) { () },
    ),
    lowering,
    root_module_index,
  )
}

///|
pub fn plan_program_wasmgc_link(
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  root_module_index : Int,
) -> PlannedProgramWasmGCLink {
  plan_program_wasmgc_link_with_options(
    analyzed,
    lowering,
    root_module_index,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
}
