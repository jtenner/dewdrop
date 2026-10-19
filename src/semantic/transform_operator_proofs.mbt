///|
/// Return only source operators whose selected implementation has a proved
/// primitive meaning. Keep source locations from collection: lowering can fold
/// constants and replace the operator expression.
pub fn compile_time_scalar_operator_proofs(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
) -> Array[(Int32, FileId, UInt64, Bytes)] {
  let intrinsics = program_fold_operator_intrinsics(lowering.modules)
  let result : Array[(Int32, FileId, UInt64, Bytes)] = []
  for mi, collected in program.modules {
    let inferred = analyzed.modules[mi].inferred
    for ei, expression in collected.expressions {
      if expression is HirBinaryExpr(_, _, _, offset) {
        let opcode = match inferred.operator_targets[ei] {
          NoInferredCallTarget => b"primitive"
          SelectedInferredCallTarget(target, arguments) if arguments.length == 0 =>
            intrinsics.get(target).unwrap_or(b"")
          _ => b""
        }
        if opcode.length() > 0 {
          result.push((mi, collected.expression_files[ei], offset, opcode))
        }
      }
    }
  }
  result
}
