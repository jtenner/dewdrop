///|
pub struct CompileTimeRawLayout {
  key : String
  identity : String
  fields : Array[String]
  storage : Array[String]
}

///|
fn transform_raw_storage(
  module_ : PlannedModuleLowering,
  type_ : ResolvedTypeId,
) -> String {
  match module_.resolved_types[type_] {
    PrimitiveType(primitive) =>
      match primitive {
        BoolType | I32Type | U32Type => "i32"
        I8Type | U8Type => "i8"
        I16Type | U16Type => "i16"
        I64Type | U64Type => "i64"
        F32Type => "f32"
        F64Type => "f64"
        V128Type
        | I8x16Type
        | U8x16Type
        | I16x8Type
        | U16x8Type
        | I32x4Type
        | U32x4Type
        | I64x2Type
        | U64x2Type
        | F32x4Type
        | F64x2Type => "v128"
        StringType | BytesType | StringViewType => "text"
        _ => "unsupported"
      }
    NominalType(declaration) => "record:" + declaration.to_string()
    AppliedType(base, arguments) if arguments.length == 1 =>
      match module_.resolved_types[base] {
        NominalType(declaration) if module_.raw_array_declarations.contains(
            declaration,
          ) =>
          "array:" +
          transform_raw_storage(
            module_,
            module_.resolved_type_arguments[arguments.start],
          )
        _ => "unsupported"
      }
    _ => "unsupported"
  }
}

///|
pub fn compile_time_raw_layouts(
  program : CollectedProgram,
  lowering : PlannedProgramLowering,
) -> Array[CompileTimeRawLayout] {
  let result : Array[CompileTimeRawLayout] = []
  for mi, module_ in lowering.modules {
    let source = program.modules[mi]
    for layout in module_.type_layouts.layouts {
      guard layout.kind is PlannedStructLayout(fields) &&
        layout.generic_parameters.length == 0 else {
        continue
      }
      let names : Array[String] = []
      let storage : Array[String] = []
      for index in 0..<fields.length {
        let field = module_.type_layouts.fields[fields.start + index]
        names.push(field.name)
        storage.push(
          (if field.mutable_ { "mut:" } else { "" }) +
          transform_raw_storage(module_, field.type_),
        )
      }
      guard source.declaration(layout.declaration) is Some(declaration) else {
        abort("checked raw layout lost declaration " + layout.declaration.to_string() + " in " + program.module_paths[mi])
      }
      guard declaration is TopLevelReference(declaration) else { continue }
      result.push({
        key: program.module_paths[mi] + "::" + source.name(declaration.name),
        identity: "record:" + layout.declaration.to_string(),
        fields: names,
        storage,
      })
    }
  }
  result
}
