///|
fn check_declared_storage_type(
  module_id : ModuleId,
  types : Array[ResolvedType],
  arguments : Array[ResolvedTypeId],
  owner : DeclId,
  root : ResolvedTypeId,
) -> Result[Unit, ProgramPhysicalTypeFailure] {
  let failure = fn(code, expected : Int, actual : Int, bad : Int) {
    ProgramPhysicalTypeFailure::{
      code, phase: 4, module_id, declaration: owner, body: 0UL,
      expression: 0xffffffffU,
      expected: expected.reinterpret_as_uint().to_uint64(),
      actual: actual.reinterpret_as_uint().to_uint64(),
      detail: (root.reinterpret_as_uint().to_uint64() << 32) | bad.reinterpret_as_uint().to_uint64(),
    }
  }
  // Nominals are leaves, including recursive nominal groups. Structural
  // arguments and callback signatures must retain valid logical evidence.
  let states : Map[Int, Int] = {}
  let work : Array[(Int, Bool)] = [(root, false)]
  while !work.is_empty() {
    let (id, finish) = work.pop().unwrap()
    guard id >= 0 && id < types.length() else {
      return Err(failure(101, types.length(), id, id))
    }
    if finish {
      states[id] = 2
      continue
    }
    match states.get(id) {
      Some(1) => return Err(failure(108, 0, 1, id))
      Some(2) => continue
      _ => ()
    }
    let node = types[id]
    let error = match node {
      ErrorType => 1
      MemberTypeProjection(_, _, _) => 2
      PrimitiveType(CompileTimeTypeType) => 3
      _ => 0
    }
    if error != 0 { return Err(failure(301, 0, error, id)) }
    states[id] = 1
    work.push((id, true))
    let span = match node {
      ProductType(span) | AppliedType(_, span) | FunctionType(span, _) => span
      _ => {start: 0, length: 0}
    }
    guard arena_span_is_valid(span, arguments.length()) else {
      return Err(failure(101, arguments.length(), span.length, id))
    }
    match node {
      AppliedType(base, _) => work.push((base, false))
      FunctionType(_, result) => work.push((result, false))
      _ => ()
    }
    for offset = span.length; offset > 0; offset = offset - 1 {
      work.push((arguments[span.start + offset - 1], false))
    }
  }
  Ok(())
}

///|
fn assert_declared_storage_type(resolved : ResolvedModuleTypes, owner : DeclId, root : ResolvedTypeId) -> Unit {
  match check_declared_storage_type(resolved.module_id, resolved.types, resolved.type_arguments, owner, root) {
    Ok(_) => ()
    Err(failure) => abort("declared storage invariant failure: " + @debug.to_string(failure))
  }
}
