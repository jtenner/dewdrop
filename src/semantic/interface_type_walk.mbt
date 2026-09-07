///|
priv struct InterfaceTypeWalkFailure {
  code : Int
  module_id : ModuleId
  root : ResolvedTypeId
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///|
fn check_frozen_impl_type_visibility(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  exported : Map[DeclId, Bool],
) -> Result[Bool, InterfaceTypeWalkFailure] {
  let states : Map[ResolvedTypeId, Int] = {}
  let work = [(root, false)]
  let mut visible = true
  fn failure(code : Int, expected : Int, actual : Int, detail : Int) -> InterfaceTypeWalkFailure {
    { code, module_id: resolved.module_id, root, expected, actual, detail }
  }
  while work.length() > 0 {
    let (id, finish) = work.pop().unwrap()
    if id < 0 || id >= resolved.types.length() {
      return Err(failure(104, resolved.types.length(), id, 0))
    }
    if finish {
      states[id] = 2
      continue
    }
    match states.get(id) {
      Some(1) => return Err(failure(211, 0, id, 1))
      Some(2) => continue
      _ => ()
    }
    states[id] = 1
    work.push((id, true))
    let node = resolved.types[id]
    let fields = match node {
      ProductType(span) | AppliedType(_, span) | FunctionType(span, _) => span
      _ => { start: 0, length: 0 }
    }
    if !program_specialization_span_is_valid(fields, resolved.type_arguments.length()) {
      return Err(failure(101, resolved.type_arguments.length(), fields.start, fields.length))
    }
    match node {
      ErrorType => visible = false
      NominalType(declaration) | TraitType(declaration) =>
        if semantic_id_module(declaration) == resolved.module_id && !exported.contains(declaration) {
          visible = false
        }
      AppliedType(base, _) | MemberTypeProjection(base, _, _) => work.push((base, false))
      FunctionType(_, result) => work.push((result, false))
      _ => ()
    }
    let mut offset = fields.length
    while offset > 0 {
      offset -= 1
      work.push((resolved.type_arguments[fields.start + offset], false))
    }
  }
  Ok(visible)
}
