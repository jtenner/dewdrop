///|
pub enum PlannedModuleInitializationStepKind {
  PlannedInitializeModuleValue(DeclId, BodyId, BodyTypeId)
  PlannedCyclicModuleValues(HirSpan)
} derive(Eq, Debug)

///|
pub struct PlannedModuleInitializationStep {
  kind : PlannedModuleInitializationStepKind
  test_only : Bool
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum ModuleInitializationDiagnostic {
  EagerModuleInitializationCycle(HirSpan, UInt64)
} derive(Eq, Debug)

///|
pub fn ModuleInitializationDiagnostic::offset(
  self : ModuleInitializationDiagnostic,
) -> UInt64 {
  match self {
    EagerModuleInitializationCycle(_, offset) => offset
  }
}

///|
pub struct PlannedModuleInitialization {
  module_id : ModuleId
  dependencies : ModuleValueDependencies
  steps : Array[PlannedModuleInitializationStep]
  declaration_steps : Array[Int]
  cycle_declarations : Array[DeclId]
  diagnostics : Array[ModuleInitializationDiagnostic]
} derive(Eq, Debug)

///|
pub fn PlannedModuleInitialization::step_of(
  self : PlannedModuleInitialization,
  declaration : DeclId,
) -> Int? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  let declaration_index = semantic_id_local(declaration)
  if declaration_index < 0 ||
    declaration_index >= self.declaration_steps.length() {
    return None
  }
  let step = self.declaration_steps[declaration_index]
  if step < 0 {
    None
  } else {
    Some(step)
  }
}

///|
fn module_initialization_offset(
  collected : CollectedModule,
  declaration : DeclId,
) -> UInt64 {
  match collected.declaration(declaration) {
    Some(TopLevelReference(value)) => value.offset
    _ => 0UL
  }
}

///|
fn module_initialization_scc_is_test_only(
  collected : CollectedModule,
  dependencies : ModuleValueDependencies,
  scc : HirSpan,
) -> Bool {
  if scc.length == 0 {
    return false
  }
  for member_index in scc.start..<(scc.start + scc.length) {
    if !collected.declaration_is_test_only(
        dependencies.scc_declarations[member_index],
      ) {
      return false
    }
  }
  true
}

///|
fn module_initialization_scc_is_cyclic(
  dependencies : ModuleValueDependencies,
  let_indices : Array[Int],
  scc : HirSpan,
) -> Bool {
  if scc.length > 1 {
    return true
  }
  if scc.length == 0 {
    return false
  }
  let declaration = dependencies.scc_declarations[scc.start]
  let declaration_index = semantic_id_local(declaration)
  if declaration_index < 0 || declaration_index >= let_indices.length() {
    return false
  }
  let let_index = let_indices[declaration_index]
  if let_index < 0 || let_index >= dependencies.let_dependencies.length() {
    return false
  }
  let edges = dependencies.let_dependencies[let_index]
  for edge in edges.start..<(edges.start + edges.length) {
    if dependencies.dependency_declarations[edge] == declaration {
      return true
    }
  }
  false
}

///|
pub fn plan_module_initialization(
  collected : CollectedModule,
  inferred : InferredModuleValues,
) -> PlannedModuleInitialization {
  if collected.module_id != inferred.module_id ||
    collected.module_id != inferred.dependencies.module_id {
    abort("module initialization inputs belong to different modules")
  }
  if collected.lets.length() == 0 {
    return {
      module_id: collected.module_id,
      dependencies: inferred.dependencies,
      steps: [],
      declaration_steps: [],
      cycle_declarations: [],
      diagnostics: [],
    }
  }
  let let_indices = module_let_indices_by_declaration(collected)
  let steps : Array[PlannedModuleInitializationStep] = []
  let declaration_steps = Array::make(
    collected.declaration_locations.length(),
    -1,
  )
  let cycle_declarations : Array[DeclId] = []
  let diagnostics : Array[ModuleInitializationDiagnostic] = []
  for scc in inferred.dependencies.sccs {
    let step_index = steps.length()
    if module_initialization_scc_is_cyclic(
        inferred.dependencies,
        let_indices,
        scc,
      ) {
      let cycle_start = cycle_declarations.length()
      let mut offset = 0xffffffffffffffffUL
      for member_index in scc.start..<(scc.start + scc.length) {
        let declaration = inferred.dependencies.scc_declarations[member_index]
        cycle_declarations.push(declaration)
        declaration_steps[semantic_id_local(declaration)] = step_index
        let declaration_offset = module_initialization_offset(
          collected, declaration,
        )
        if declaration_offset < offset {
          offset = declaration_offset
        }
      }
      let members = {
        start: cycle_start,
        length: cycle_declarations.length() - cycle_start,
      }
      steps.push({
        kind: PlannedCyclicModuleValues(members),
        test_only: module_initialization_scc_is_test_only(
          collected,
          inferred.dependencies,
          scc,
        ),
        offset,
      })
      diagnostics.push(EagerModuleInitializationCycle(members, offset))
    } else {
      let declaration = inferred.dependencies.scc_declarations[scc.start]
      let declaration_index = semantic_id_local(declaration)
      let let_index = let_indices[declaration_index]
      let body = collected.body_of(declaration).unwrap()
      declaration_steps[declaration_index] = step_index
      steps.push({
        kind: PlannedInitializeModuleValue(
          declaration,
          body.id,
          inferred.let_types[let_index],
        ),
        test_only: collected.declaration_is_test_only(declaration),
        offset: module_initialization_offset(collected, declaration),
      })
    }
  }
  diagnostics.sort_by(fn(left, right) { left.offset().compare(right.offset()) })
  {
    module_id: collected.module_id,
    dependencies: inferred.dependencies,
    steps,
    declaration_steps,
    cycle_declarations,
    diagnostics,
  }
}
