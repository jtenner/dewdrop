///|
fn transform_variant_key(
  program : CollectedProgram,
  selected : VariantId,
) -> String? {
  for mi, module_ in program.modules {
    if module_.module_id != semantic_id_module(selected) {
      continue
    }
    for variant in module_.variants {
      if variant.id == selected {
        if module_.declaration(variant.declaration)
          is Some(TopLevelReference(owner)) {
          return Some(
            program.module_paths[mi] +
            "::" +
            module_.name(owner.name) +
            "::" +
            module_.name(variant.name),
          )
        }
      }
    }
  }
  None
}

///|
pub fn compile_time_pattern_proofs(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
) -> Array[(Int32, FileId, UInt64, String)] {
  let result : Array[(Int32, FileId, UInt64, String)] = []
  for mi, collected in program.modules {
    let inferred = analyzed.modules[mi].inferred
    for pi, pattern in collected.patterns {
      let key = match inferred.pattern_constructors[pi] {
        NoInferredPatternConstructor => Some("")
        StructInferredPatternConstructor(selected, _) => {
          let mut key : String? = None
          for owner_mi, owner in program.modules {
            if owner.declaration(selected)
              is Some(TopLevelReference(declaration)) {
              key = Some(
                program.module_paths[owner_mi] +
                "::" +
                owner.name(declaration.name),
              )
              break
            }
          }
          key
        }
        VariantInferredPatternConstructor(selected, _) =>
          transform_variant_key(program, selected)
        _ => None
      }
      if key is Some(key) {
        result.push((mi, collected.pattern_files[pi], pattern.offset(), key))
      }
    }
  }
  result
}
