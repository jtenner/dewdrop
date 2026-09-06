///|
fn evaluate_compile_time_names(
  context : CompileTimeProgramContext,
  operation : Bytes,
  types : Array[CompileTimeType],
) -> Result[CompileTimeConstant?, String] {
  if types.length() != 1 {
    return Err("CT-031 name queries require one type argument")
  }
  match compile_time_types_are_concrete(types) {
    Ok(false) => return Ok(None)
    Err(_) => return Err("CT-033 invalid reflected type")
    Ok(true) => ()
  }
  let declaration = match types[0] {
    CtNominal(declaration) | CtApplied(CtNominal(declaration), _) => declaration
    _ => return Err("CT-032 name query requires a struct or enum")
  }
  let fields = operation == b"types.field_names"
  for collected in context.program.modules {
    if collected.module_id != semantic_id_module(declaration) {
      continue
    }
    let kind = match collected.declaration(declaration) {
      Some(TopLevelReference(value)) => value.kind
      _ => return Err("CT-032 missing reflected declaration")
    }
    if (fields && kind != StructDecl) || (!fields && kind != EnumDecl) {
      return Err(
        "CT-032 field_names requires a struct; variant_names requires an enum",
      )
    }
    let names = []
    if fields {
      for field in collected.fields {
        if field.declaration == declaration && field.variant is None {
          names.push(@utf8.encode(collected.name(field.name)))
        }
      }
    } else {
      for variant in collected.variants {
        if variant.declaration == declaration {
          names.push(@utf8.encode(collected.name(variant.name)))
        }
      }
    }
    return Ok(Some(CtStringArray(names)))
  }
  Err("CT-032 missing reflected module")
}
