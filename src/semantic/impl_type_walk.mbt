///| Malformed compiler type graphs are not ordinary signature mismatches.
priv struct ImplTypeWalkFailure {
  code : Int
  module_id : ModuleId
  root : ResolvedTypeId
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///| Validate every reachable edge, including context substitution edges.
// The result maps each visited type to its final substituted root. Structural
// children retain their IDs and are translated through the same map on use.
fn check_impl_type_graph(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  context : ImplTypeContext,
) -> Result[Map[ResolvedTypeId, ResolvedTypeId], ImplTypeWalkFailure] {
  fn failure(code : Int, expected : Int, actual : Int, detail : Int) -> ImplTypeWalkFailure {
    { code, module_id: resolved.module_id, root, expected, actual, detail }
  }
  for span in [context.generic_parameters, context.method_parameters, context.method_arguments] {
    if !program_specialization_span_is_valid(span, resolved.generic_parameter_types.length()) {
      return Err(failure(101, resolved.generic_parameter_types.length(), span.start, span.length))
    }
  }
  let arguments = context.generic_arguments
  if !program_specialization_span_is_valid(arguments, resolved.type_arguments.length()) {
    return Err(failure(101, resolved.type_arguments.length(), arguments.start, arguments.length))
  }
  let states : Map[ResolvedTypeId, Int] = {}
  let translated : Map[ResolvedTypeId, ResolvedTypeId] = {}
  let work = [(root, false)]
  while work.length() > 0 {
    let (id, finish) = work.pop().unwrap()
    if id < 0 || id >= resolved.types.length() {
      return Err(failure(104, resolved.types.length(), id, 0))
    }
    if finish {
      let next = translated.get(id).unwrap()
      if next != id {
        translated[id] = translated.get(next).unwrap()
      }
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
    let next = match node {
      GenericParameterType(parameter) => {
        let slot = semantic_id_local(parameter)
        let owner = context.generic_parameters
        let method_span = context.method_parameters
        if slot >= owner.start && slot - owner.start < owner.length && slot - owner.start < arguments.length {
          resolved.type_arguments[arguments.start + slot - owner.start]
        } else if slot >= method_span.start && slot - method_span.start < method_span.length && slot - method_span.start < context.method_arguments.length {
          resolved.generic_parameter_types[context.method_arguments.start + slot - method_span.start]
        } else {
          id
        }
      }
      SelfType(owner) if owner == context.self_owner => context.self_type
      _ => id
    }
    translated[id] = next
    if next != id {
      work.push((next, false))
      continue
    }
    let fields = match node {
      ProductType(span) | AppliedType(_, span) | FunctionType(span, _) => span
      _ => { start: 0, length: 0 }
    }
    if !program_specialization_span_is_valid(fields, resolved.type_arguments.length()) {
      return Err(failure(101, resolved.type_arguments.length(), fields.start, fields.length))
    }
    match node {
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
  Ok(translated)
}

///| Check both complete graphs before using identity or Error recovery.
fn check_impl_signature_types_equal(
  resolved : ResolvedModuleTypes,
  left_root : ResolvedTypeId,
  left_context : ImplTypeContext,
  right_root : ResolvedTypeId,
  right_context : ImplTypeContext,
) -> Result[Bool, ImplTypeWalkFailure] {
  let left_types = match check_impl_type_graph(resolved, left_root, left_context) {
    Ok(types) => types
    Err(error) => return Err(error)
  }
  let right_types = match check_impl_type_graph(resolved, right_root, right_context) {
    Ok(types) => types
    Err(error) => return Err(error)
  }
  let seen : Map[(Int, Int), Bool] = {}
  let work = [(left_root, right_root)]
  while work.length() > 0 {
    let (left_id, right_id) = work.pop().unwrap()
    let left = left_types.get(left_id).unwrap()
    let right = right_types.get(right_id).unwrap()
    if seen.contains((left, right)) {
      continue
    }
    seen[(left, right)] = true
    let (left_fields, right_fields) = match (resolved.types[left], resolved.types[right]) {
      (ErrorType, _) | (_, ErrorType) => continue
      (ProductType(a), ProductType(b)) => (a, b)
      (AppliedType(a, fields_a), AppliedType(b, fields_b)) => {
        work.push((a, b))
        (fields_a, fields_b)
      }
      (FunctionType(fields_a, a), FunctionType(fields_b, b)) => {
        work.push((a, b))
        (fields_a, fields_b)
      }
      (MemberTypeProjection(a, query_a, member_a), MemberTypeProjection(b, query_b, member_b)) => {
        if query_a != query_b || member_a != member_b {
          return Ok(false)
        }
        work.push((a, b))
        continue
      }
      (a, b) => if a == b { continue } else { return Ok(false) }
    }
    if left_fields.length != right_fields.length {
      return Ok(false)
    }
    let mut offset = left_fields.length
    while offset > 0 {
      offset -= 1
      work.push((resolved.type_arguments[left_fields.start + offset], resolved.type_arguments[right_fields.start + offset]))
    }
  }
  Ok(true)
}
