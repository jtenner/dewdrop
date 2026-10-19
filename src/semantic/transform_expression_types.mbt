///|
pub struct CompileTimeReflectedType {
  identity : UInt64
  kind : String
  name : String
  arguments : Array[CompileTimeReflectedType]
} derive(Eq, Debug)

///|
pub struct CompileTimeExpressionType {
  module_index : Int32
  file : FileId
  offset : UInt64
  kind : String
  type_ : CompileTimeReflectedType
} derive(Eq, Debug)

///|
fn transform_reflected_name(program : CollectedProgram, id : DeclId) -> String {
  for mi, module_ in program.modules {
    if module_.module_id == semantic_id_module(id) {
      match module_.declaration(id) {
        Some(TopLevelReference(value)) =>
          return program.module_paths[mi] + "::" + module_.name(value.name)
        _ => return ""
      }
    }
  }
  ""
}

///|
fn transform_reflected_parameter(
  program : CollectedProgram,
  id : GenericParameterId,
) -> String {
  for module_ in program.modules {
    if module_.module_id == semantic_id_module(id) {
      let index = semantic_id_local(id)
      if index >= 0 && index < module_.generic_parameters.length() {
        let value = module_.generic_parameters[index]
        guard value.id == id else {
          abort("reflection generic parameter identity changed")
        }
        return module_.name(value.name)
      }
    }
  }
  ""
}

///|
fn transform_reflected_type(
  program : CollectedProgram,
  module_ : PlannedModuleLowering,
  root : BodyTypeId,
  cache : Map[BodyTypeId, CompileTimeReflectedType?],
  depth : Int32,
) -> CompileTimeReflectedType? {
  guard depth < 128 else { return None }
  if cache.get(root) is Some(value) {
    return value
  }
  let (kind, name, children) : (String, String, Array[BodyTypeId]) = if root <
    -1 {
    match module_.resolved_types[-(root + 2)] {
      ErrorType => return None
      PrimitiveType(value) => {
        let rendered = @debug.to_string(value)
        (
          "named",
          if value is CompileTimeTypeType {
            "Type"
          } else {
            rendered.substring(end=rendered.length() - 4).to_string()
          },
          [],
        )
      }
      GenericParameterType(id) =>
        ("parameter", transform_reflected_parameter(program, id), [])
      SelfType(_) => ("self", "Self", [])
      NominalType(id) => ("nominal", transform_reflected_name(program, id), [])
      TraitType(id) => ("trait", transform_reflected_name(program, id), [])
      ProductType(span) | AppliedType(_, span) | FunctionType(span, _) => {
        let children : Array[BodyTypeId] = []
        if module_.resolved_types[-(root + 2)] is AppliedType(base, _) {
          children.push(-base - 2)
        }
        for i in 0..<span.length {
          children.push(-module_.resolved_type_arguments[span.start + i] - 2)
        }
        match module_.resolved_types[-(root + 2)] {
          ProductType(_) => ("tuple", "", children)
          AppliedType(_, _) => ("applied", "", children)
          FunctionType(_, result) => {
            children.push(-result - 2)
            ("function", "", children)
          }
          _ => abort("reflection resolved type changed kind")
        }
      }
      MemberTypeProjection(base, operation, selector) =>
        (
          "projection",
          @utf8.decode_lossy(operation) + ":" + selector,
          [-base - 2],
        )
    }
  } else if root >= 0 && root < module_.types.length() {
    match module_.types[root] {
      BodyErrorType | BodyVariableType(_) => return None
      BodyResolvedType(id) =>
        return transform_reflected_type(
          program,
          module_,
          -id - 2,
          cache,
          depth + 1,
        )
      BodyMemberTypeProjection(base, operation, selector) =>
        ("projection", @utf8.decode_lossy(operation) + ":" + selector, [base])
      BodyProductType(span)
      | BodyAppliedType(_, span)
      | BodyFunctionType(span, _) => {
        let children : Array[BodyTypeId] = []
        if module_.types[root] is BodyAppliedType(base, _) {
          children.push(base)
        }
        for i in 0..<span.length {
          children.push(module_.type_arguments[span.start + i])
        }
        match module_.types[root] {
          BodyProductType(_) => ("tuple", "", children)
          BodyAppliedType(_, _) => ("applied", "", children)
          BodyFunctionType(_, result) => {
            children.push(result)
            ("function", "", children)
          }
          _ => abort("reflection body type changed kind")
        }
      }
    }
  } else {
    return None
  }
  let arguments = []
  for child in children {
    match transform_reflected_type(program, module_, child, cache, depth + 1) {
      Some(value) => arguments.push(value)
      None => return None
    }
  }
  let identity = (module_.module_id << 32) |
    root.reinterpret_as_uint().to_uint64()
  let value = Some({ identity, kind, name, arguments, })
  cache[root] = value
  value
}

///|
fn transform_expression_kind(value : HirExpr) -> String {
  match value {
    HirI8Expr(_, _) => "I8"
    HirI16Expr(_, _) => "I16"
    HirI32Expr(_, _) => "I32"
    HirI64Expr(_, _) => "I64"
    HirU8Expr(_, _) => "U8"
    HirU16Expr(_, _) => "U16"
    HirU32Expr(_, _) => "U32"
    HirU64Expr(_, _) => "U64"
    HirF32Expr(_, _) => "F32"
    HirF64Expr(_, _) => "F64"
    HirBoolExpr(_, _) => "Bool"
    HirStringExpr(_, _) => "String"
    HirBytesExpr(_, _) => "Bytes"
    HirNameExpr(_, _) => "name"
    HirImportAliasExpr(_, _) => "import"
    HirProductExpr(_, _) => "tuple"
    HirArrayExpr(_, _) => "array"
    HirLambdaExpr(_, _) => "lambda"
    HirObjectExpr(_, _) => "record"
    HirConstructExpr(_, _, _) => "construct"
    HirBlockExpr(_, _) => "block"
    HirIfExpr(_, _, _, _) => "if"
    HirMatchExpr(_, _, _) => "match"
    HirWhileExpr(_, _, _) => "while"
    HirReturnExpr(_, _) => "return"
    HirBreakExpr(_, _) => "break"
    HirContinueExpr(_, _) => "continue"
    HirPrefixExpr(_, _, _) => "prefix"
    HirBinaryExpr(_, _, _, _) => "binary"
    HirCallExpr(_, _, _) => "call"
    HirFieldExpr(_, _, _) => "field"
    HirQualifiedExpr(_, _, _) => "qualified"
    HirProductFieldExpr(_, _, _, _) => "tuple_field"
    HirIndexExpr(_, _, _) => "index"
    HirAssignmentExpr(_, _, _) => "assign"
    HirIndexSetExpr(_, _, _, _) => "index_set"
    HirTypeBindingExpr(_, _) => "type_bind"
  }
}

///|
pub fn compile_time_expression_types(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  targets : Array[(Int32, String, UInt64, UInt64)],
) -> Array[CompileTimeExpressionType] {
  let result = []
  for mi, source in program.modules {
    let spans : Map[FileId, Array[(UInt64, UInt64)]] = {}
    for (target_mi, path, start, end) in targets {
      if mi == target_mi {
        for fi, file in source.file_paths {
          if file == path {
            let entries = spans.get_or_init(source.files[fi], fn() { [] })
            entries.push((start, end))
          }
        }
      }
    }
    if spans.is_empty() {
      continue
    }
    let cache : Map[BodyTypeId, CompileTimeReflectedType?] = {}
    let module_ = lowering.modules[mi]
    for ei, expression in source.expressions {
      let offset = expression.offset()
      let file = source.expression_files[ei]
      guard spans.get(file) is Some(ranges) &&
        ranges.any(fn(range) { offset >= range.0 && offset < range.1 }) else {
        continue
      }
      if transform_reflected_type(
          program,
          module_,
          analyzed.modules[mi].inferred.expression_types[ei],
          cache,
          0,
        )
        is Some(type_) {
        result.push({
          module_index: mi,
          file,
          offset,
          kind: transform_expression_kind(expression),
          type_,
        })
      }
    }
    for bi, block in source.blocks {
      let offset = block.offset
      let file = source.block_files[bi]
      guard spans.get(file) is Some(ranges) &&
        ranges.any(fn(range) { offset >= range.0 && offset < range.1 }) else {
        continue
      }
      if transform_reflected_type(
          program,
          module_,
          analyzed.modules[mi].inferred.block_types[bi],
          cache,
          0,
        )
        is Some(type_) {
        result.push({ module_index: mi, file, offset, kind: "block", type_, })
      }
    }
  }
  result.sort_by(fn(a, b) { a.offset.compare(b.offset) })
  result
}
