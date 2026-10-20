///|
fn compiler_register_signature_calls(
  plan : @transforms.Plan,
  program : @semantic.CollectedProgram,
  analyzed : @semantic.AnalyzedProgramSemantics,
  calls : Array[@semantic.CompileTimeCall],
  diagnostics : Array[@semantic.CompilerSourceDiagnostic],
) -> Unit {
  let errors : Map[(@semantic.FileId, UInt64), Bool] = {}
  for diagnostic in diagnostics {
    if diagnostic.severity is @semantic.CompilerError && diagnostic.has_primary {
      errors[(diagnostic.primary.file, diagnostic.primary.offset)] = true
    }
  }
  let invalid : Map[(Int32, @semantic.FileId, UInt64), Bool] = {}
  let callees : Map[(Int32, @semantic.FileId, UInt64), UInt64] = {}
  for mi, source in program.modules {
    // Some constraints point at the header or return keyword. Their source ID
    // still identifies the value whose old type failed the checked context.
    for diagnostic in analyzed.modules[mi].inferred.diagnostics {
      let origin = match diagnostic {
        @semantic.BodyConstraintDiagnostic(
          @semantic.LocalTypeMismatch(_, _, origin)
          | @semantic.InfiniteLocalType(_, _, origin)
          | @semantic.InvalidLocalMemberProjection(_, _, origin)
        ) => Some(origin)
        _ => None
      }
      if origin is Some(origin) &&
        (
          origin.kind is @semantic.ExpressionTypeConstraint ||
          origin.kind is @semantic.ReturnTypeConstraint ||
          origin.kind is @semantic.CallTypeConstraint ||
          origin.kind is @semantic.OperatorTypeConstraint
        ) &&
        origin.source >= 0 &&
        origin.source < source.expressions.length() {
        errors[(
          source.expression_files[origin.source],
          source.expressions[origin.source].offset(),
        )] = true
      }
    }
    for ei, expression in source.expressions {
      if expression is @semantic.HirCallExpr(callee, _, _) {
        let file = source.expression_files[ei]
        let offset = source.expressions[callee].offset()
        callees[(mi, file, expression.offset())] = offset
        if errors.contains((file, expression.offset())) ||
          errors.contains((file, offset)) {
          invalid[(mi, file, offset)] = true
        }
      }
    }
  }
  for call in calls {
    if call.target_module < 0 {
      continue
    }
    let offset = if call.reference {
      call.offset
    } else {
      callees
      .get((call.module_index, call.file, call.offset))
      .unwrap_or(call.offset)
    }
    if invalid.contains((call.module_index, call.file, offset)) ||
      errors.contains((call.file, offset)) {
      continue
    }
    if program.source_file(call.file) is Some(source) &&
      program.source_file(call.target_file) is Some(target) {
      plan.add_signature_call(
        call.module_index,
        source.path,
        offset,
        call.target_module,
        target.path,
        call.target_offset,
      )
    }
  }
}
