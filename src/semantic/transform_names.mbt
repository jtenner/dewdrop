///|
/// Imported nominal type names come from the checked scope, including implicit
/// imports. No standard type spelling has a separate evaluator rule.
pub fn compile_time_imported_type_names(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> Array[(Int32, String, String)] {
  let result : Array[(Int32, String, String)] = []
  for mi, scope in analyzed.frozen.import_scopes {
    for name, index in scope.type_bindings {
      if index < 0 || index >= scope.declarations.length() {
        continue
      }
      let binding = scope.declarations[index]
      if !(binding.source_kind is StructDecl || binding.source_kind is EnumDecl) {
        continue
      }
      let owner = semantic_id_module(binding.declaration)
      for oi, module_ in program.modules {
        if module_.module_id == owner {
          if module_.declaration(binding.declaration)
            is Some(TopLevelReference(declaration)) {
            result.push(
              (
                mi,
                name,
                program.module_paths[oi] + "::" + module_.name(declaration.name),
              ),
            )
          }
          break
        }
      }
    }
  }
  result
}
