///|
pub struct CompileTimeArray {
  module_index : Int32
  file : FileId
  offset : UInt64
  key : String
  fields : Array[String]
}

///|
pub fn compile_time_arrays(
  program : CollectedProgram,
  lowering : PlannedProgramLowering,
) -> Array[CompileTimeArray] {
  let result : Array[CompileTimeArray] = []
  for mi, source in program.modules {
    for ei, expression in source.expressions {
      guard expression is HirBlockExpr(block, _) else { continue }
      let items = source.blocks[block].items
      if items.length < 2 {
        continue
      }
      guard source.block_items[items.start] is HirLetItem(_, name, _, _, _) &&
        source.name(name).has_prefix("$array_literal$") else {
        continue
      }
      let owner = lowering.modules[mi].expressions[ei].nominal
      for oi, module_ in program.modules {
        if module_.declaration(owner) is Some(TopLevelReference(declaration)) {
          let fields : Array[String] = []
          for field in module_.fields {
            if field.declaration == owner && field.variant is None {
              fields.push(module_.name(field.name))
            }
          }
          guard fields.length() == 3 else {
            abort(
              "checked array literal must have a three-field backing/count/capacity layout",
            )
          }
          result.push({
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            key: program.module_paths[oi] +
            "::" +
            module_.name(declaration.name),
            fields,
          })
          break
        }
      }
    }
  }
  result
}
