///|
pub struct CompileTimeCall {
  reference : Bool
  constant : CompileTimeTransformConstant?
  function_identity : CompileTimeFunctionIdentity?
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
      if expression is HirCallExpr(_, _, _) {
        let saved = match lowering.compile_time {
          Some(context) => context.query_constants.get((source.module_id, ei))
          None => None
        }
        let constant = match saved {
          Some(_) => saved
          None =>
            transform_folded_constant(lowering.modules[mi].expressions[ei].kind)
        }
        if constant is Some(_) {
          result.push({
            reference: false,
            constant,
            function_identity: None,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module: -6,
            target_file: source.expression_files[ei],
            target_offset: 0UL,
            result_kind: "",
            constructor_key: "",
          })
          continue
        }
      }
      if lowering.modules[mi].expressions[ei].kind
        is PlannedModuleValueGet(selected, _) {
        if targets.get(selected)
          is Some((target_module, target_file, target_offset)) {
          result.push({
            reference: true,
            constant: None,
            function_identity: transform_function_identity(
              lowering.modules[target_module],
              selected,
            ),
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
            constant: None,
            function_identity: transform_function_identity(
              lowering.modules[target_module],
              selected,
            ),
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
              raw_arrays=lowering.modules[mi].raw_array_declarations,
            ),
          })
        }
      }
      if inferred.expression_selections[ei]
        is UnitVariantValueSelection(selected, _) {
        if transform_variant_key(program, selected) is Some(key) {
          result.push({
            reference: true,
            constant: None,
            function_identity: None,
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
            constant: None,
            function_identity: None,
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
          raw_arrays=lowering.modules[mi].raw_array_declarations,
        )
        if kind != "" && !kind.has_prefix("array:") {
          result.push({
            reference: false,
            constant: None,
            function_identity: None,
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
            SelectedDynamicTraitCallTarget(_, requirement, _, _) =>
              Some((-8, source.expression_files[ei], requirement))
            NoInferredCallTarget => None
            _ => Some((-1, source.expression_files[ei], 0UL))
          }
        }
        if location is Some((target_module, target_file, target_offset)) {
          result.push({
            reference: false,
            constant: None,
            function_identity: None,
            module_index: mi,
            file: source.expression_files[ei],
            offset: expression.offset(),
            target_module,
            target_file,
            target_offset,
            constructor_key: if target_module == -8 {
              match target {
                SelectedDynamicTraitCallTarget(trait_, _, slot, _) =>
                  trait_.to_string() + ":" + slot.to_string()
                _ => ""
              }
            } else if target_module == -3 {
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
              raw_arrays=lowering.modules[mi].raw_array_declarations,
            ),
          })
        }
      }
    }
  }
  result
}

///|
struct TransformKindBudget {
  mut remaining : Int32
}

///|
fn transform_product_kind(kinds : Array[String]) -> String {
  let result = StringBuilder::new()
  result.write_string("(")
  for kind in kinds {
    if kind.has_prefix("unsupported:") {
      return kind
    }
  }
  for kind in kinds {
    if kind == "Unit" {
      result.write_string("u")
    } else if kind.has_prefix("unit-product:") {
      result.write_string(kind.substring(start=13).to_string())
    } else {
      return if kind.has_prefix("unsupported:") { kind } else { "product" }
    }
  }
  result.write_string(")")
  "unit-product:" + result.to_string()
}

///|
fn transform_scalar_kind(
  resolved : Array[ResolvedType],
  resolved_arguments : Array[ResolvedTypeId],
  inferred : InferredModuleBodies,
  root : BodyTypeId,
  reference : Bool,
  raw_arrays~ : Map[DeclId, Bool] = {},
  budget~ : TransformKindBudget = { remaining: 65536, },
  depth~ : Int32 = 0,
) -> String {
  if budget.remaining <= 0 || depth >= 128 {
    return "unsupported:type metadata limit exceeded"
  }
  budget.remaining -= 1
  let nested = fn(type_) {
    transform_scalar_kind(
      resolved,
      resolved_arguments,
      inferred,
      type_,
      false,
      raw_arrays~,
      budget~,
      depth=depth + 1,
    )
  }
  let nominal = fn(declaration, arguments : Array[BodyTypeId]) {
    if declaration == standard_nullable_ref_type_declaration() &&
      arguments.length() == 1 {
      "nullable"
    } else if raw_arrays.contains(declaration) && arguments.length() == 1 {
      "array:" + nested(arguments[0])
    } else {
      "record:" + declaration.to_string()
    }
  }
  let mut current = root
  let mut unwrap_function = reference
  while true {
    match inferred.type_term(current) {
      BodyFunctionType(_, result) if unwrap_function => {
        unwrap_function = false
        current = result
      }
      BodyFunctionType(_, _) => return "function"
      BodyProductType(arguments) => {
        let kinds = []
        for offset in 0..<arguments.length {
          kinds.push(nested(inferred.type_arguments[arguments.start + offset]))
        }
        return transform_product_kind(kinds)
      }
      BodyAppliedType(base, arguments) if !unwrap_function => {
        let arguments = Array::makei(arguments.length, fn(index) {
          inferred.type_arguments[arguments.start + index]
        })
        return match inferred.type_term(base) {
          BodyResolvedType(id) =>
            match resolved[id] {
              NominalType(declaration) => nominal(declaration, arguments)
              TraitType(declaration) => "trait:" + declaration.to_string()
              _ => ""
            }
          _ => ""
        }
      }
      BodyResolvedType(type_) => {
        let mut resolved_type = type_
        while true {
          match resolved[resolved_type] {
            FunctionType(_, result) if unwrap_function => {
              unwrap_function = false
              resolved_type = result
            }
            FunctionType(_, _) => return "function"
            ProductType(arguments) => {
              let kinds = []
              for offset in 0..<arguments.length {
                kinds.push(
                  nested(-resolved_arguments[arguments.start + offset] - 2),
                )
              }
              return transform_product_kind(kinds)
            }
            AppliedType(base, arguments) if !unwrap_function => {
              let arguments = Array::makei(arguments.length, fn(index) {
                -resolved_arguments[arguments.start + index] - 2
              })
              return match resolved[base] {
                NominalType(declaration) => nominal(declaration, arguments)
                TraitType(declaration) => "trait:" + declaration.to_string()
                _ => ""
              }
            }
            PrimitiveType(primitive) =>
              return match primitive {
                UnitType => "Unit"
                NeverType => "Never"
                F32Type => "F32"
                F64Type => "F64"
                BoolType => "Bool"
                I8Type => "I8"
                U8Type => "U8"
                I16Type => "I16"
                U16Type => "U16"
                Swar32Type => "U32"
                Swar64Type => "U64"
                I32Type => "I32"
                U32Type => "U32"
                I64Type => "I64"
                U64Type => "U64"
                StringType => "String"
                BytesType => "Bytes"
                StringViewType => "StringView"
                StringBuilderType => "StringBuilder"
                BytesBuilderType => "BytesBuilder"
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
                | F64x2Type => "V128"
                _ => ""
              }
            NominalType(declaration) => return nominal(declaration, [])
            TraitType(declaration) => return "trait:" + declaration.to_string()
            _ => return ""
          }
        }
      }
      _ => return ""
    }
  }
  ""
}
