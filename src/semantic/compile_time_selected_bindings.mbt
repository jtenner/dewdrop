///|
fn compile_time_binding_type(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  module_index : Int,
  expression : ExprId,
) -> ResolvedTypeId? {
  let collected = program.modules[module_index]
  let syntax = match collected.expressions[expression] {
    HirTypeBindingExpr(syntax, _) => syntax
    _ => return None
  }
  let resolved = analyzed.frozen.interfaces[module_index].resolved_types
  guard syntax >= 0 && syntax < resolved.syntax_types.length() else {
    abort("ARN-104 compile-time type binding syntax")
  }
  Some(resolved.syntax_types[syntax])
}

///|
fn validate_compile_time_binding(
  context : CompileTimeProgramContext,
  module_index : Int,
  module_ : PlannedModuleLowering,
  expression : ExprId,
  bindings : Map[GenericParameterId, CompileTimeType],
) -> String? {
  let id = match
    compile_time_binding_type(
      context.program,
      context.analyzed,
      module_index,
      expression,
    ) {
    Some(id) => id
    None => return None
  }
  if !compile_time_has_projection(module_, -id - 2) {
    return None
  }
  let logical = match compile_time_read_type(module_, -id - 2, bindings) {
    Ok(value) => value
    Err(error) =>
      return Some("CT-043 selected type binding: " + @debug.to_string(error))
  }
  let concrete = match
    reduce_compile_time_projections(context, module_, logical, 0) {
    Ok(value) => value
    Err(error) => return Some("CT-043 selected type binding: " + error)
  }
  match compile_time_types_are_concrete([concrete]) {
    Ok(true) => None
    Ok(false) => Some("CT-043 selected type binding remains unresolved")
    Err(error) =>
      Some("CT-043 selected type binding: " + @debug.to_string(error))
  }
}
