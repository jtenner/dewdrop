///|
enum ProgramSpecializationShapeTask {
  VisitSpecializationShape(PlannedValueShape)
  FinishSpecializationProduct(Int)
}

///|
fn program_canonical_specialization_scalar(
  shape : PlannedValueShape,
) -> PlannedValueShape {
  match shape {
    // Packed array storage and signed reads distinguish narrow shapes even
    // though all four use i32 at a function boundary.
    I32PlannedValueShape | U32PlannedValueShape | Swar32PlannedValueShape =>
      I32PlannedValueShape
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      I64PlannedValueShape
    _ => shape
  }
}

///|
fn program_canonical_specialization_shape(
  root : PlannedValueShape,
) -> PlannedValueShape {
  if !(root is ProductPlannedValueShape(_)) {
    return program_canonical_specialization_scalar(root)
  }
  let work = [VisitSpecializationShape(root)]
  let results : Array[PlannedValueShape] = []
  while work.length() > 0 {
    match work.pop().unwrap() {
      VisitSpecializationShape(ProductPlannedValueShape(fields)) => {
        work.push(FinishSpecializationProduct(results.length()))
        for index = fields.length() - 1; index >= 0; index = index - 1 {
          work.push(VisitSpecializationShape(fields[index]))
        }
      }
      VisitSpecializationShape(shape) =>
        results.push(program_canonical_specialization_scalar(shape))
      FinishSpecializationProduct(start) => {
        let fields : Array[PlannedValueShape] = []
        for index in start..<results.length() {
          fields.push(results[index])
        }
        results.truncate(start)
        results.push(ProductPlannedValueShape(fields))
      }
    }
  }
  guard results.length() == 1 else {
    abort("SPC-305 specialization normalization must produce one result")
  }
  results[0]
}

///|
enum ProgramSpecializationShapeNameTask {
  WriteSpecializationShape(PlannedValueShape)
  WriteSpecializationSeparator
  CloseSpecializationProduct
}

///|
// The grammar is structural: scalar names contain no product delimiters.
// Keep missing and erroneous logical shapes distinct even in debug keys.
fn program_specialization_shape_name(root : PlannedValueShape) -> String {
  let output = Buffer()
  let work = [WriteSpecializationShape(root)]
  while work.length() > 0 {
    match work.pop().unwrap() {
      WriteSpecializationSeparator => output.write_string_utf8(",")
      CloseSpecializationProduct => output.write_string_utf8("]")
      WriteSpecializationShape(source) =>
        match program_canonical_specialization_scalar(source) {
          ProductPlannedValueShape(fields) => {
            output.write_string_utf8("product[")
            work.push(CloseSpecializationProduct)
            for index = fields.length() - 1; index >= 0; index = index - 1 {
              work.push(WriteSpecializationShape(fields[index]))
              if index > 0 {
                work.push(WriteSpecializationSeparator)
              }
            }
          }
          shape =>
            output.write_string_utf8(
              match shape {
                UnitPlannedValueShape => "unit"
                NeverPlannedValueShape => "never"
                I8PlannedValueShape => "i8"
                U8PlannedValueShape => "u8"
                I16PlannedValueShape => "i16"
                U16PlannedValueShape => "u16"
                I32PlannedValueShape => "i32"
                I64PlannedValueShape => "i64"
                F32PlannedValueShape => "f32"
                F64PlannedValueShape => "f64"
                V128PlannedValueShape => "v128"
                RefPlannedValueShape => "eqref"
                GenericPlannedValueShape => "generic"
                ErrorPlannedValueShape => "error"
                _ => abort("SPC-305 specialization scalar was not normalized")
              },
            )
        }
    }
  }
  @utf8.decode_lossy(output.to_bytes())
}

///|
fn program_specialization_shape_error(root : PlannedValueShape) -> String? {
  let work = [root]
  while work.length() > 0 {
    match work.pop().unwrap() {
      GenericPlannedValueShape => return Some("generic")
      ErrorPlannedValueShape => return Some("error")
      ProductPlannedValueShape(fields) =>
        for field in fields {
          work.push(field)
        }
      _ => ()
    }
  }
  None
}

///|
fn validate_program_specialization_request_shapes(
  declaration : DeclId,
  shapes : Array[PlannedValueShape],
  span : HirSpan,
) -> Result[Unit, String] {
  if !program_specialization_span_is_valid(span, shapes.length()) {
    return Err(
      "SPC-301 declaration=\{declaration} invalid shape span start=\{span.start} length=\{span.length} arena=\{shapes.length()}",
    )
  }
  for index in 0..<span.length {
    match program_specialization_shape_error(shapes[span.start + index]) {
      Some(error) =>
        return Err(
          "SPC-301 declaration=\{declaration} argument=\{index} invalid physical shape=\{error}",
        )
      None => ()
    }
  }
  Ok(())
}
