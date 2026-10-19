///|
pub struct CompileTimeCall {
  reference : Bool
  module_index : Int32
  file : FileId
  offset : UInt64
  target_module : Int32
  target_file : FileId
  target_offset : UInt64
  result_kind : String
  constructor_key : String
}

///|
/// Negative target modules retain unsupported checked call kinds. They must
/// never fall through to source-spelling lookup.
pub fn compile_time_calls(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> Array[CompileTimeCall] {
  let targets : Map[DeclId, (Int32, FileId, UInt64)] = Map::default()
  for mi, module_ in program.modules {
    for declaration in module_.declarations {
      if declaration.kind is FunctionDecl ||
        declaration.kind is BuiltinDecl ||
        declaration.kind is LetDecl {
        targets[declaration.id] = (
          mi,
          module_.declaration_files[semantic_id_local(declaration.id)],
          declaration.offset,
        )
      }
    }
    for method in module_.methods {
      targets[method.id] = (
        mi,
        module_.declaration_files[semantic_id_local(method.id)],
        method.offset,
      )
    }
  }
  let result : Array[CompileTimeCall] = []
  for mi, source in program.modules {
    let inferred = analyzed.modules[mi].inferred
    for ei, expression in source.expressions {
      if lowering.modules[mi].expressions[ei].kind
        is PlannedModuleValueGet(selected, _) {
        if targets.get(selected)
          is Some((target_module, target_file, target_offset)) {
          result.push({
            reference: true,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module,
            target_file,
            target_offset,
            result_kind: "",
            constructor_key: "",
          })
        }
      }
      if inferred.expression_selections[ei]
        is FunctionReferenceSelection(selected, _) {
        if targets.get(selected)
          is Some((target_module, target_file, target_offset)) {
          result.push({
            reference: true,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module,
            target_file,
            target_offset,
            constructor_key: "",
            result_kind: transform_scalar_kind(
              lowering.modules[mi].resolved_types,
              lowering.modules[mi].resolved_type_arguments,
              inferred,
              inferred.expression_types[ei],
              true,
            ),
          })
        }
      }
      if inferred.expression_selections[ei]
        is UnitVariantValueSelection(selected, _) {
        if transform_variant_key(program, selected) is Some(key) {
          result.push({
            reference: true,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module: -4,
            target_file: source.expression_files[ei],
            target_offset: 0UL,
            result_kind: "",
            constructor_key: key,
          })
        }
      }
      if expression is HirCallExpr(_, _, _) &&
        inferred.expression_selections[ei]
        is VariantConstructionSelection(selected, _) {
        if transform_variant_key(program, selected) is Some(key) {
          result.push({
            reference: false,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module: -3,
            target_file: source.expression_files[ei],
            target_offset: 0UL,
            result_kind: "",
            constructor_key: key,
          })
          continue
        }
      }
      let scalar_read = match expression {
        HirNameExpr(_, _) | HirFieldExpr(_, _, _) => true
        _ => false
      }
      if scalar_read {
        let kind = transform_scalar_kind(
          lowering.modules[mi].resolved_types,
          lowering.modules[mi].resolved_type_arguments,
          inferred,
          inferred.expression_types[ei],
          false,
        )
        if kind != "" && !kind.has_prefix("array:") {
          result.push({
            reference: false,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module: -5,
            target_file: source.expression_files[ei],
            target_offset: 0UL,
            result_kind: kind,
            constructor_key: "",
          })
        }
      }
      let target = match expression {
        HirCallExpr(_, _, _) => Some(inferred.call_targets[ei])
        HirPrefixExpr(_, _, _) => Some(NoInferredCallTarget)
        HirBinaryExpr(_, _, _, _) | HirIndexExpr(_, _, _) =>
          Some(inferred.operator_targets[ei])
        _ => None
      }
      if target is Some(target) {
        let location = if expression is HirPrefixExpr(_, _, _) {
          Some((-5, source.expression_files[ei], 0UL))
        } else {
          match target {
            SelectedInferredCallTarget(declaration, _) =>
              match inferred.expression_selections[ei] {
                VariantConstructionSelection(selected, _) =>
                  Some((-3, source.expression_files[ei], selected))
                _ => targets.get(declaration)
              }
            SelectedFunctionValueCallTarget(_) =>
              Some((-2, source.expression_files[ei], 0UL))
            NoInferredCallTarget => None
            _ => Some((-1, source.expression_files[ei], 0UL))
          }
        }
        if location is Some((target_module, target_file, target_offset)) {
          result.push({
            reference: false,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module,
            target_file,
            target_offset,
            constructor_key: if target_module == -3 {
              transform_variant_key(program, target_offset).unwrap_or("")
            } else {
              ""
            },
            result_kind: transform_scalar_kind(
              lowering.modules[mi].resolved_types,
              lowering.modules[mi].resolved_type_arguments,
              inferred,
              inferred.expression_types[ei],
              false,
            ),
          })
        }
      }
    }
  }
  result
}

///|
fn transform_scalar_kind(
  resolved : Array[ResolvedType],
  resolved_arguments : Array[ResolvedTypeId],
  inferred : InferredModuleBodies,
  root : BodyTypeId,
  reference : Bool,
) -> String {
  let mut current = root
  let mut unwrap_function = reference
  while true {
    match inferred.type_term(current) {
      BodyFunctionType(_, result) if unwrap_function => {
        unwrap_function = false
        current = result
      }
      BodyAppliedType(_, arguments) if arguments.length == 1 && !unwrap_function => {
        let kind = transform_scalar_kind(
          resolved,
          resolved_arguments,
          inferred,
          inferred.type_arguments[arguments.start],
          false,
        )
        return if kind == "" { "" } else { "array:" + kind }
      }
      BodyResolvedType(type_) => {
        let mut resolved_type = type_
        while true {
          match resolved[resolved_type] {
            FunctionType(_, result) if unwrap_function => {
              unwrap_function = false
              resolved_type = result
            }
            AppliedType(_, arguments) if arguments.length == 1 &&
              !unwrap_function => {
              let kind = transform_scalar_kind(
                resolved,
                resolved_arguments,
                inferred,
                -resolved_arguments[arguments.start] - 2,
                false,
              )
              return if kind == "" { "" } else { "array:" + kind }
            }
            PrimitiveType(primitive) =>
              return match primitive {
                F32Type => "unsupported:F32"
                F64Type => "unsupported:F64"
                BoolType => "Bool"
                I8Type => "I8"
                U8Type => "U8"
                I16Type => "I16"
                U16Type => "U16"
                I32Type => "I32"
                U32Type => "U32"
                I64Type => "I64"
                U64Type => "U64"
                _ => ""
              }
            _ => return ""
          }
        }
      }
      _ => return ""
    }
  }
  ""
}
