///|
priv struct PendingBodyMemberEquation {
  left : BodyTypeId
  right : BodyTypeId
  origin : TypeConstraintOrigin
}

///|
fn BasicBodyInferencer::constrain_pending_member_equations(
  self : BasicBodyInferencer,
  final_ : Bool,
) -> Bool {
  let mut kept = 0
  let mut progress = false
  for equation in self.pending_member_equations {
    if !final_ &&
      (
        self.solver.has_pending_member_projection(equation.left) ||
        self.solver.has_pending_member_projection(equation.right)
      ) {
      self.pending_member_equations[kept] = equation
      kept += 1
    } else {
      ignore(self.solver.unify(equation.left, equation.right, equation.origin))
      progress = true
    }
  }
  self.pending_member_equations.truncate(kept)
  progress
}

///|
fn LocalTypeSolver::has_pending_member_projection(
  self : LocalTypeSolver,
  root : BodyTypeId,
) -> Bool {
  let work = [root]
  let seen : Map[BodyTypeId, Bool] = {}
  while !work.is_empty() {
    let type_ = self.representative_type(work.pop().unwrap())
    if type_ <= 0 || seen.contains(type_) {
      continue
    }
    seen[type_] = true
    let span = match self.type_term(type_) {
      BodyMemberTypeProjection(owner, _, _) => {
        match self.reduce_member_type(type_, 0) {
          Ok(reduced) if reduced != type_ => {
            work.push(reduced)
            continue
          }
          Err(_) => continue // Not pending: unification must report this error.
          _ => ()
        }
        if self.has_unresolved_variable(owner) {
          return true
        }
        work.push(owner)
        continue
      }
      BodyProductType(span) => span
      BodyAppliedType(base, span) => {
        work.push(base)
        span
      }
      BodyFunctionType(span, result) => {
        work.push(result)
        span
      }
      _ => continue
    }
    guard program_specialization_span_is_valid(
      span,
      self.type_arguments.length(),
    ) else {
      abort("ARN-101 pending member projection children")
    }
    for index in 0..<span.length {
      work.push(self.type_arguments[span.start + index])
    }
  }
  false
}

///|
fn LocalTypeSolver::projection_parameter_order(
  self : LocalTypeSolver,
  parameters : Array[BodyTypeId],
) -> Array[Int]? {
  if self.member_types is None {
    return None
  }
  let ready = []
  let deferred = []
  for index, parameter in parameters {
    if self.has_pending_member_projection(parameter) {
      deferred.push(index)
    } else {
      ready.push(index)
    }
  }
  if deferred.is_empty() {
    return None
  }
  ready.append(deferred)
  Some(ready)
}

///|
fn LocalTypeSolver::zonk_member_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> BodyTypeId {
  match self.reduce_member_type(type_, 0) {
    Ok(value) => value
    Err(message) => {
      self.diagnostics.push(
        InvalidLocalMemberProjection(type_, message, origin),
      )
      self.error_type()
    }
  }
}

///|
pub fn LocalTypeSolver::member_projection_type(
  self : LocalTypeSolver,
  owner : BodyTypeId,
  operation : Bytes,
  selector : String,
) -> BodyTypeId {
  let owner = self.representative_type(owner)
  // Reuse a frozen symbolic projection when substitution leaves it unchanged.
  if self.type_term(owner) is BodyResolvedType(resolved_owner) {
    for index, type_ in self.resolved.types {
      if type_ == MemberTypeProjection(resolved_owner, operation, selector) {
        return self.resolved_type(index)
      }
    }
  }
  self.push_type_term(BodyMemberTypeProjection(owner, operation, selector))
}

///|
fn LocalTypeSolver::member_projection(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> (BodyTypeId, Bytes, String)? {
  match self.type_term(type_) {
    BodyMemberTypeProjection(owner, operation, selector) =>
      Some((owner, operation, selector))
    BodyResolvedType(resolved) =>
      match self.resolved.types[resolved] {
        MemberTypeProjection(owner, operation, selector) =>
          Some((self.resolved_type(owner), operation, selector))
        _ => None
      }
    _ => None
  }
}

///|
fn LocalTypeSolver::substitute_member_type(
  self : LocalTypeSolver,
  type_ : ResolvedTypeId,
  bindings : Map[GenericParameterId, BodyTypeId],
  depth : Int,
) -> Result[BodyTypeId, String] {
  if depth >= 256 {
    return Err("CT-034 member projection limit exceeded")
  }
  match self.resolved.types[type_] {
    GenericParameterType(parameter) | SelfType(parameter) =>
      Ok(bindings.get(parameter).unwrap_or(self.resolved_type(type_)))
    ProductType(span) | AppliedType(_, span) | FunctionType(span, _) => {
      guard program_specialization_span_is_valid(
        span,
        self.resolved.type_arguments.length(),
      ) else {
        abort("ARN-101 member projection substitution arguments")
      }
      let values = []
      for offset in 0..<span.length {
        match
          self.substitute_member_type(
            self.resolved.type_arguments[span.start + offset],
            bindings,
            depth + 1,
          ) {
          Ok(value) => values.push(value)
          Err(error) => return Err(error)
        }
      }
      match self.resolved.types[type_] {
        AppliedType(base, _) =>
          match self.substitute_member_type(base, bindings, depth + 1) {
            Ok(base) => Ok(self.applied_type(base, values))
            Err(error) => Err(error)
          }
        FunctionType(_, result) =>
          match self.substitute_member_type(result, bindings, depth + 1) {
            Ok(result) => Ok(self.function_type(values, result))
            Err(error) => Err(error)
          }
        _ => Ok(self.product_type(values))
      }
    }
    MemberTypeProjection(owner, operation, selector) =>
      match self.substitute_member_type(owner, bindings, depth + 1) {
        Ok(owner) =>
          self.reduce_member_type(
            self.member_projection_type(owner, operation, selector),
            depth + 1,
          )
        Err(error) => Err(error)
      }
    _ => Ok(self.resolved_type(type_))
  }
}

///|
fn LocalTypeSolver::reduce_member_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
  depth : Int,
) -> Result[BodyTypeId, String] {
  if depth >= 256 {
    return Err("CT-034 member projection limit exceeded")
  }
  let type_ = self.representative_type(type_)
  let (owner, operation, selector) = match self.member_projection(type_) {
    Some(value) => value
    None => return Ok(type_)
  }
  if !computed_type_builtin(operation) {
    return Err("CT-033 invalid member projection operation")
  }
  let owner = match self.reduce_member_type(owner, depth + 1) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let arguments = []
  let base = match self.type_term(owner) {
    BodyAppliedType(base, span) => {
      guard program_specialization_span_is_valid(
        span,
        self.type_arguments.length(),
      ) else {
        abort("ARN-101 inferred member owner arguments")
      }
      for offset in 0..<span.length {
        arguments.push(self.type_arguments[span.start + offset])
      }
      base
    }
    BodyResolvedType(index) =>
      match self.resolved.types[index] {
        AppliedType(base, span) => {
          guard program_specialization_span_is_valid(
            span,
            self.resolved.type_arguments.length(),
          ) else {
            abort("ARN-101 resolved member owner arguments")
          }
          for offset in 0..<span.length {
            arguments.push(
              self.resolved_type(
                self.resolved.type_arguments[span.start + offset],
              ),
            )
          }
          self.resolved_type(base)
        }
        _ => owner
      }
    _ => owner
  }
  let declaration = match self.type_term(self.representative_type(base)) {
    BodyVariableType(_) | BodyMemberTypeProjection(_, _, _) => return Ok(type_)
    BodyResolvedType(index) =>
      match self.resolved.types[index] {
        NominalType(declaration) => declaration
        GenericParameterType(_) | SelfType(_) | MemberTypeProjection(_, _, _) =>
          return Ok(type_)
        _ => return Err("CT-032 member type query requires a struct or enum")
      }
    _ => return Err("CT-032 member type query requires a struct or enum")
  }
  let recipe = match self.member_types {
    Some(context) =>
      match context.declarations.get(declaration) {
        Some(value) => value
        None => return Err("CT-032 missing member type declaration")
      }
    None => return Err("CT-032 missing member type context")
  }
  if arguments.length() != recipe.parameters.length() {
    return Err("CT-031 member owner has the wrong generic arity")
  }
  let templates = if operation == b"types.field_type" {
    match recipe.fields.get(selector) {
      Some(value) => [value]
      None => return Err("CT-032 no such field: " + selector)
    }
  } else {
    match recipe.variants.get(selector) {
      Some(value) => value
      None => return Err("CT-032 no such variant: " + selector)
    }
  }
  let bindings : Map[GenericParameterId, BodyTypeId] = {}
  for index, parameter in recipe.parameters {
    bindings[parameter] = arguments[index]
  }
  let values = []
  for template in templates {
    match self.substitute_member_type(template, bindings, depth + 1) {
      Ok(value) => values.push(value)
      Err(error) => return Err(error)
    }
  }
  Ok(
    if operation == b"types.field_type" {
      values[0]
    } else {
      self.product_type(values)
    },
  )
}
