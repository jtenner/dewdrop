///|
/// Map body-owned diagnostics to original declaration sites. Headers, imports
/// and diagnostics without a concrete body node remain outside this set.
pub fn compile_time_body_diagnostics(
  program : CollectedProgram,
  analyzed : AnalyzedProgramSemantics,
  lowering : PlannedProgramLowering,
  diagnostics : Array[CompilerSourceDiagnostic],
) -> Array[(Int32, Int32, FileId, UInt64)] {
  let wanted : Map[(FileId, UInt64), Array[Int32]] = {}
  for index, diagnostic in diagnostics {
    if diagnostic.severity is CompilerError && diagnostic.has_primary {
      wanted
      .get_or_init((diagnostic.primary.file, diagnostic.primary.offset), fn() {
        []
      })
      .push(index)
    }
  }
  if wanted.is_empty() {
    return []
  }
  let result = []
  let seen : Map[Int32, DeclId] = {}
  for mi, source in program.modules {
    let module_ = lowering.modules[mi]
    for body in module_.bodies {
      let location = source.declaration_location(body.declaration).unwrap()
      let save = fn(file : FileId, offset : UInt64) {
        if wanted.get((file, offset)) is Some(indices) {
          for index in indices {
            match seen.get(index) {
              Some(previous) => {
                guard previous == body.declaration else {
                  abort("body diagnostic has conflicting checked owners")
                }
              }
              None => {
                seen[index] = body.declaration
                result.push((index, mi, location.file, location.offset))
              }
            }
          }
        }
      }
      // Return constraints use the declaration offset. Match the checked
      // inference diagnostic itself, so unrelated header errors stay fatal.
      let inferred = analyzed.modules[mi].inferred
      if inferred.body(body.body) is Some(job) {
        for
          di in job.diagnostics.start..<(job.diagnostics.start +
          job.diagnostics.length) {
          let diagnostic = inferred.diagnostics[di]
          let origin = match diagnostic {
            BodyConstraintDiagnostic(LocalTypeMismatch(_, _, origin))
            | BodyConstraintDiagnostic(InfiniteLocalType(_, _, origin)) =>
              if origin.kind == ReturnTypeConstraint {
                Some(origin)
              } else {
                None
              }
            _ => None
          }
          if origin is Some(origin) &&
            wanted.get((location.file, origin.offset)) is Some(indices) {
            let message = @debug.to_string(diagnostic)
            for index in indices {
              if diagnostics[index].message == message && !seen.contains(index) {
                seen[index] = body.declaration
                result.push((index, mi, location.file, location.offset))
              }
            }
          }
        }
      }
      for expression in compile_time_owned_expressions(module_, body) {
        save(
          source.expression_files[expression],
          source.expressions[expression].offset(),
        )
      }
      let block_spans = [body.blocks]
      let pattern_spans = [body.patterns]
      for lambda in module_.lambdas {
        if lambda.root_body == body.body {
          block_spans.push(lambda.blocks)
          pattern_spans.push(lambda.patterns)
        }
      }
      for span in block_spans {
        for index in span.start..<(span.start + span.length) {
          save(source.block_files[index], source.blocks[index].offset)
        }
      }
      for span in pattern_spans {
        for index in span.start..<(span.start + span.length) {
          save(source.pattern_files[index], source.patterns[index].offset())
        }
      }
    }
  }
  result
}
