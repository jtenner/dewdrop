///|
// Inference dependencies describe source constraints. Startup dependencies
// describe the selected logical IR. Build a new graph; never overwrite the
// frozen inference graph merely because a query removed an evaluation.
fn compile_time_initialization(
  context : CompileTimeProgramContext,
  module_index : Int,
  module_ : PlannedModuleLowering,
) -> PlannedModuleLowering {
  let collected = context.program.modules[module_index]
  if collected.lets.is_empty() {
    return module_
  }
  let indices = module_let_indices_by_declaration(collected)
  let spans : Array[HirSpan] = []
  let declarations : Array[DeclId] = []
  for value in collected.lets {
    let source = match collected.body_of(value.declaration) {
      Some(body) => body
      None => abort(@debug.to_string({
        ..program_function_lookup_failure(value.declaration, 610, 1UL, 0UL, 29UL),
        phase: 3,
      }))
    }
    let body = match check_program_link_body_identity(module_, value.declaration, source.id) {
      Ok(body) => body
      Err(failure) => abort(@debug.to_string({ ..failure, phase: 3, }))
    }
    guard body.kind == ModuleLetBody else {
      abort(@debug.to_string({
        ..program_initializer_dependency_failure(body.declaration, body.body,
          0xffffffffU, 106, 0UL, program_initializer_body_kind_code(body.kind), 22UL),
        phase: 3,
      }))
    }
    match check_planned_body_arenas(module_, body, 3) {
      Ok(_) => ()
      Err(failure) => abort(@debug.to_string(failure))
    }
    let selected : Array[Int] = []
    let seen : Map[DeclId, Bool] = {}
    for expression in body.expressions.start..<(body.expressions.start + body.expressions.length) {
      match module_.expressions[expression].kind {
        PlannedModuleValueGet(declaration, _) if semantic_id_module(declaration) == module_.module_id => {
          let local = semantic_id_local(declaration)
          guard local >= 0 && local < indices.length() else {
            abort(@debug.to_string({
              ..program_initializer_dependency_failure(body.declaration, body.body,
                expression.reinterpret_as_uint(), 101, indices.length().to_uint64(),
                local.reinterpret_as_uint().to_uint64(), declaration),
              phase: 3,
            }))
          }
          let index = indices[local]
          guard index >= 0 && index < collected.lets.length() else {
            abort(@debug.to_string({
              ..program_initializer_dependency_failure(body.declaration, body.body,
                expression.reinterpret_as_uint(), 106, 1UL, 0UL, declaration),
              phase: 3,
            }))
          }
          guard collected.lets[index].declaration == declaration else {
            abort(@debug.to_string({
              ..program_initializer_dependency_failure(body.declaration, body.body,
                expression.reinterpret_as_uint(), 106, declaration,
                collected.lets[index].declaration, declaration),
              phase: 3,
            }))
          }
          if !seen.contains(declaration) {
            seen[declaration] = true
            selected.push(index)
          }
        }
        _ => ()
      }
    }
    selected.sort()
    let start = declarations.length()
    for index in selected {
      declarations.push(collected.lets[index].declaration)
    }
    spans.push({ start, length: declarations.length() - start, })
  }
  let (sccs, scc_declarations) = find_module_value_sccs(collected, indices, spans, declarations)
  let dependencies : ModuleValueDependencies = {
    module_id: module_.module_id,
    let_dependencies: spans,
    dependency_declarations: declarations,
    sccs,
    scc_declarations,
  }
  let values = context.analyzed.modules[module_index].inferred.module_values
  {
    ..module_,
    initialization: plan_module_initialization(collected, { ..values, dependencies, }),
  }
}
