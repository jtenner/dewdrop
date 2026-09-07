///|
let undo_parent = 0

///|
let undo_size = 1

///|
let undo_binding = 2

///|
let zonk_visit = 0

///|
let zonk_finish_application = 1

///|
let zonk_finish_function = 2

///|
let zonk_finish_product = 3

///|
let zonk_finish_projection = 4

///|
pub struct InferenceSnapshot {
  token : UInt64
  undo_start : Int
  variable_count : Int
  type_count : Int
  argument_count : Int
  diagnostic_count : Int
} derive(Eq, Debug)

///|
pub struct LocalTypeSolver {
  resolved : ResolvedModuleTypes
  member_types : BodyMemberTypeContext?
  types : Array[BodyTypeTerm]
  type_arguments : Array[BodyTypeId]
  variable_parents : Array[TypeVariableId]
  variable_sizes : Array[Int]
  variable_bindings : Array[BodyTypeId]
  variable_types : Array[BodyTypeId]
  diagnostics : Array[LocalInferenceDiagnostic]
  snapshots : Array[InferenceSnapshot]
  mut next_snapshot_token : UInt64
  undo_kinds : Array[Int]
  undo_indices : Array[Int]
  undo_values : Array[Int]
  unify_left : Array[BodyTypeId]
  unify_right : Array[BodyTypeId]
  occurs_stack : Array[BodyTypeId]
  occurs_local_marks : Array[Int]
  occurs_resolved_marks : Array[Int]
  mut occurs_generation : Int
  zonk_task_types : Array[BodyTypeId]
  zonk_task_states : Array[Int]
  zonk_result_starts : Array[Int]
  zonk_results : Array[BodyTypeId]
  zonk_application_scratch : Array[BodyTypeId]
  zonk_marks : Array[Int]
  zonk_values : Array[BodyTypeId]
  mut zonk_generation : Int
}

///|
pub fn LocalTypeSolver::new(
  resolved : ResolvedModuleTypes,
  member_types? : BodyMemberTypeContext? = None,
) -> LocalTypeSolver {
  {
    resolved,
    member_types,
    types: [BodyErrorType],
    type_arguments: [],
    variable_parents: [],
    variable_sizes: [],
    variable_bindings: [],
    variable_types: [],
    diagnostics: [],
    snapshots: [],
    next_snapshot_token: 0UL,
    undo_kinds: [],
    undo_indices: [],
    undo_values: [],
    unify_left: [],
    unify_right: [],
    occurs_stack: [],
    occurs_local_marks: [0],
    occurs_resolved_marks: [],
    occurs_generation: 0,
    zonk_task_types: [],
    zonk_task_states: [],
    zonk_result_starts: [],
    zonk_results: [],
    zonk_application_scratch: [],
    zonk_marks: [0],
    zonk_values: [0],
    zonk_generation: 0,
  }
}

///|
pub fn LocalTypeSolver::reset(self : LocalTypeSolver) -> Unit {
  guard self.snapshots.length() == 0 else {
    abort("cannot reset a solver with active inference snapshots")
  }
  self.types.clear()
  self.types.push(BodyErrorType)
  self.type_arguments.clear()
  self.variable_parents.clear()
  self.variable_sizes.clear()
  self.variable_bindings.clear()
  self.variable_types.clear()
  self.diagnostics.clear()
  self.undo_kinds.clear()
  self.undo_indices.clear()
  self.undo_values.clear()
  self.unify_left.clear()
  self.unify_right.clear()
  self.occurs_stack.clear()
  self.occurs_local_marks.clear()
  self.occurs_local_marks.push(0)
  self.occurs_resolved_marks.clear()
  self.occurs_generation = 0
  self.zonk_task_types.clear()
  self.zonk_task_states.clear()
  self.zonk_result_starts.clear()
  self.zonk_results.clear()
  self.zonk_application_scratch.clear()
  self.zonk_marks.clear()
  self.zonk_marks.push(0)
  self.zonk_values.clear()
  self.zonk_values.push(0)
  self.zonk_generation = 0
}

///|
pub fn LocalTypeSolver::error_type(_self : LocalTypeSolver) -> BodyTypeId {
  0
}

///|
pub fn LocalTypeSolver::resolved_type(
  self : LocalTypeSolver,
  type_ : ResolvedTypeId,
) -> BodyTypeId {
  match self.check_resolved_type_encoding(type_) {
    Ok(encoded) => encoded
    Err(error) =>
      abort("solver type encoding invariant: " + @debug.to_string(error))
  }
}

///|
fn LocalTypeSolver::decoded_resolved_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> ResolvedTypeId {
  guard type_ < -1 else { abort("body type is not a resolved type") }
  let resolved = -type_ - 2
  guard resolved >= 0 && resolved < self.resolved.types.length() else {
    abort("invalid resolved body type")
  }
  resolved
}

///|
pub fn LocalTypeSolver::type_term(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> BodyTypeTerm {
  if type_ < -1 {
    BodyResolvedType(self.decoded_resolved_type(type_))
  } else if type_ >= 0 && type_ < self.types.length() {
    self.types[type_]
  } else {
    abort("invalid body type ID")
  }
}

///|
fn LocalTypeSolver::push_type_term(
  self : LocalTypeSolver,
  term : BodyTypeTerm,
) -> BodyTypeId {
  let id = self.types.length()
  self.types.push(term)
  self.occurs_local_marks.push(0)
  self.zonk_marks.push(0)
  self.zonk_values.push(0)
  id
}

///|
pub fn LocalTypeSolver::fresh_variable(self : LocalTypeSolver) -> BodyTypeId {
  let variable = self.variable_parents.length()
  let type_ = self.push_type_term(BodyVariableType(variable))
  self.variable_parents.push(variable)
  self.variable_sizes.push(1)
  self.variable_bindings.push(-1)
  self.variable_types.push(type_)
  type_
}

///|
pub fn LocalTypeSolver::product_type(
  self : LocalTypeSolver,
  fields : Array[BodyTypeId],
) -> BodyTypeId {
  let start = self.type_arguments.length()
  for field in fields {
    self.type_arguments.push(field)
  }
  self.push_type_term(BodyProductType({ start, length: fields.length(), }))
}

///|
pub fn LocalTypeSolver::applied_type(
  self : LocalTypeSolver,
  base : BodyTypeId,
  arguments : Array[BodyTypeId],
) -> BodyTypeId {
  let start = self.type_arguments.length()
  for argument in arguments {
    self.type_arguments.push(argument)
  }
  self.push_type_term(
    BodyAppliedType(base, { start, length: arguments.length(), }),
  )
}

///|
pub fn LocalTypeSolver::function_type(
  self : LocalTypeSolver,
  parameters : Array[BodyTypeId],
  result : BodyTypeId,
) -> BodyTypeId {
  let start = self.type_arguments.length()
  for parameter in parameters {
    self.type_arguments.push(parameter)
  }
  self.push_type_term(
    BodyFunctionType({ start, length: parameters.length(), }, result),
  )
}

///|
fn LocalTypeSolver::find_variable_root(
  self : LocalTypeSolver,
  variable : TypeVariableId,
) -> TypeVariableId {
  let root = match self.check_variable_root(variable) {
    Ok(root) => root
    Err(failure) => abort("solver root invariant: " + @debug.to_string(failure))
  }
  self.compress_checked_variable_path(variable, root)
  root
}

///|
pub fn LocalTypeSolver::representative_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> BodyTypeId {
  match self.check_representative_type(type_) {
    Ok(type_) => type_
    Err(failure) => abort("solver root invariant: " + @debug.to_string(failure))
  }
}

///|
fn LocalTypeSolver::record_undo(
  self : LocalTypeSolver,
  kind : Int,
  index : Int,
  old_value : Int,
) -> Unit {
  self.assert_undo_arrays()
  if self.snapshots.length() > 0 {
    self.undo_kinds.push(kind)
    self.undo_indices.push(index)
    self.undo_values.push(old_value)
  }
}

///|
fn LocalTypeSolver::set_variable_parent(
  self : LocalTypeSolver,
  variable : TypeVariableId,
  parent : TypeVariableId,
) -> Unit {
  self.record_undo(undo_parent, variable, self.variable_parents[variable])
  self.variable_parents[variable] = parent
}

///|
fn LocalTypeSolver::set_variable_size(
  self : LocalTypeSolver,
  variable : TypeVariableId,
  size : Int,
) -> Unit {
  self.record_undo(undo_size, variable, self.variable_sizes[variable])
  self.variable_sizes[variable] = size
}

///|
fn LocalTypeSolver::set_variable_binding(
  self : LocalTypeSolver,
  variable : TypeVariableId,
  binding : BodyTypeId,
) -> Unit {
  self.record_undo(undo_binding, variable, self.variable_bindings[variable])
  self.variable_bindings[variable] = binding
}

///|
fn LocalTypeSolver::union_variables(
  self : LocalTypeSolver,
  left : TypeVariableId,
  right : TypeVariableId,
) -> TypeVariableId {
  let left_root = self.find_variable_root(left)
  let right_root = self.find_variable_root(right)
  if left_root == right_root {
    return left_root
  }
  let size = match self.check_union_size(left_root, right_root) {
    Ok(size) => size
    Err(error) => abort("solver union invariant: " + @debug.to_string(error))
  }
  let (larger, smaller) = if self.variable_sizes[left_root] >=
    self.variable_sizes[right_root] {
    (left_root, right_root)
  } else {
    (right_root, left_root)
  }
  self.set_variable_parent(smaller, larger)
  self.set_variable_size(larger, size)
  larger
}

///|
fn LocalTypeSolver::ensure_occurs_resolved_marks(
  self : LocalTypeSolver,
) -> Unit {
  while self.occurs_resolved_marks.length() < self.resolved.types.length() {
    self.occurs_resolved_marks.push(0)
  }
}

///|
fn LocalTypeSolver::next_occurs_generation(self : LocalTypeSolver) -> Unit {
  self.occurs_generation += 1
  if self.occurs_generation == 0 {
    self.occurs_local_marks.fill(0)
    self.occurs_resolved_marks.fill(0)
    self.occurs_generation = 1
  }
}

///|
fn LocalTypeSolver::occurs_in(
  self : LocalTypeSolver,
  variable_root : TypeVariableId,
  type_ : BodyTypeId,
) -> Bool {
  self.next_occurs_generation()
  self.occurs_stack.clear()
  self.occurs_stack.push(type_)
  while self.occurs_stack.length() > 0 {
    let current = self.representative_type(self.occurs_stack.pop().unwrap())
    if current < -1 {
      let resolved_id = self.decoded_resolved_type(current)
      match self.resolved.types[resolved_id] {
        ProductType(fields) => {
          self.ensure_occurs_resolved_marks()
          if self.occurs_resolved_marks[resolved_id] == self.occurs_generation {
            continue
          }
          self.occurs_resolved_marks[resolved_id] = self.occurs_generation
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.occurs_stack.push(
              self.resolved_type(
                self.resolved.type_arguments[fields.start + index],
              ),
            )
          }
        }
        AppliedType(base, arguments) => {
          self.ensure_occurs_resolved_marks()
          if self.occurs_resolved_marks[resolved_id] == self.occurs_generation {
            continue
          }
          self.occurs_resolved_marks[resolved_id] = self.occurs_generation
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.occurs_stack.push(
              self.resolved_type(
                self.resolved.type_arguments[arguments.start + index],
              ),
            )
          }
          self.occurs_stack.push(self.resolved_type(base))
        }
        FunctionType(parameters, result) => {
          self.ensure_occurs_resolved_marks()
          if self.occurs_resolved_marks[resolved_id] == self.occurs_generation {
            continue
          }
          self.occurs_resolved_marks[resolved_id] = self.occurs_generation
          self.occurs_stack.push(self.resolved_type(result))
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.occurs_stack.push(
              self.resolved_type(
                self.resolved.type_arguments[parameters.start + index],
              ),
            )
          }
        }
        _ => ()
      }
      continue
    }
    if self.occurs_local_marks[current] == self.occurs_generation {
      continue
    }
    self.occurs_local_marks[current] = self.occurs_generation
    match self.types[current] {
      BodyVariableType(variable) =>
        if self.find_variable_root(variable) == variable_root {
          return true
        }
      BodyMemberTypeProjection(owner, _, _) => self.occurs_stack.push(owner)
      BodyProductType(fields) => {
        let mut index = fields.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[fields.start + index])
        }
      }
      BodyAppliedType(base, arguments) => {
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[arguments.start + index])
        }
        self.occurs_stack.push(base)
      }
      BodyFunctionType(parameters, result) => {
        self.occurs_stack.push(result)
        let mut index = parameters.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[parameters.start + index])
        }
      }
      BodyErrorType | BodyResolvedType(_) => ()
    }
  }
  false
}

///|
fn LocalTypeSolver::poison_direct_variable(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> Unit {
  if type_ >= 0 {
    match self.types[type_] {
      BodyVariableType(variable) => {
        let root = self.find_variable_root(variable)
        self.set_variable_binding(root, self.error_type())
      }
      _ => ()
    }
  }
}

///|
/// Forces a body-local variable class to the shared error type. Rigid types
/// remain unchanged; this operation is intended for poison boundaries whose
/// original expression slot was allocated as a variable.
pub fn LocalTypeSolver::poison_type(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
) -> Unit {
  self.poison_direct_variable(type_)
}

///|
fn LocalTypeSolver::bind_variable(
  self : LocalTypeSolver,
  variable : TypeVariableId,
  other : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  let root = self.find_variable_root(variable)
  let other = self.representative_type(other)
  match self.type_term(other) {
    BodyVariableType(other_variable) => {
      ignore(self.union_variables(root, other_variable))
      true
    }
    _ =>
      if self.occurs_in(root, other) {
        self.diagnostics.push(InfiniteLocalType(root, other, origin))
        self.set_variable_binding(root, self.error_type())
        false
      } else {
        self.set_variable_binding(root, other)
        true
      }
  }
}

///|
fn LocalTypeSolver::push_unification_pair(
  self : LocalTypeSolver,
  left : BodyTypeId,
  right : BodyTypeId,
) -> Unit {
  self.unify_left.push(left)
  self.unify_right.push(right)
}

///|
fn LocalTypeSolver::push_body_product_pairs(
  self : LocalTypeSolver,
  left : HirSpan,
  right : HirSpan,
) -> Bool {
  if left.length != right.length {
    return false
  }
  let mut index = left.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.type_arguments[left.start + index],
      self.type_arguments[right.start + index],
    )
  }
  true
}

///|
fn LocalTypeSolver::push_resolved_product_pairs(
  self : LocalTypeSolver,
  left : HirSpan,
  right : HirSpan,
) -> Bool {
  if left.length != right.length {
    return false
  }
  let mut index = left.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.resolved_type(self.resolved.type_arguments[left.start + index]),
      self.resolved_type(self.resolved.type_arguments[right.start + index]),
    )
  }
  true
}

///|
fn LocalTypeSolver::push_mixed_product_pairs(
  self : LocalTypeSolver,
  body : HirSpan,
  resolved : HirSpan,
  body_on_left : Bool,
) -> Bool {
  if body.length != resolved.length {
    return false
  }
  let mut index = body.length
  while index > 0 {
    index -= 1
    let body_type = self.type_arguments[body.start + index]
    let resolved_type = self.resolved_type(
      self.resolved.type_arguments[resolved.start + index],
    )
    if body_on_left {
      self.push_unification_pair(body_type, resolved_type)
    } else {
      self.push_unification_pair(resolved_type, body_type)
    }
  }
  true
}

///|
fn LocalTypeSolver::push_body_application_pairs(
  self : LocalTypeSolver,
  left_base : BodyTypeId,
  left_arguments : HirSpan,
  right_base : BodyTypeId,
  right_arguments : HirSpan,
) -> Bool {
  if left_arguments.length != right_arguments.length {
    return false
  }
  let mut index = left_arguments.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.type_arguments[left_arguments.start + index],
      self.type_arguments[right_arguments.start + index],
    )
  }
  self.push_unification_pair(left_base, right_base)
  true
}

///|
fn LocalTypeSolver::push_resolved_application_pairs(
  self : LocalTypeSolver,
  left_base : ResolvedTypeId,
  left_arguments : HirSpan,
  right_base : ResolvedTypeId,
  right_arguments : HirSpan,
) -> Bool {
  if left_arguments.length != right_arguments.length {
    return false
  }
  let mut index = left_arguments.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.resolved_type(
        self.resolved.type_arguments[left_arguments.start + index],
      ),
      self.resolved_type(
        self.resolved.type_arguments[right_arguments.start + index],
      ),
    )
  }
  self.push_unification_pair(
    self.resolved_type(left_base),
    self.resolved_type(right_base),
  )
  true
}

///|
fn LocalTypeSolver::push_mixed_application_pairs(
  self : LocalTypeSolver,
  body_base : BodyTypeId,
  body_arguments : HirSpan,
  resolved_base : ResolvedTypeId,
  resolved_arguments : HirSpan,
  body_on_left : Bool,
) -> Bool {
  if body_arguments.length != resolved_arguments.length {
    return false
  }
  let mut index = body_arguments.length
  while index > 0 {
    index -= 1
    let body_argument = self.type_arguments[body_arguments.start + index]
    let resolved_argument = self.resolved_type(
      self.resolved.type_arguments[resolved_arguments.start + index],
    )
    if body_on_left {
      self.push_unification_pair(body_argument, resolved_argument)
    } else {
      self.push_unification_pair(resolved_argument, body_argument)
    }
  }
  if body_on_left {
    self.push_unification_pair(body_base, self.resolved_type(resolved_base))
  } else {
    self.push_unification_pair(self.resolved_type(resolved_base), body_base)
  }
  true
}

///|
fn LocalTypeSolver::push_body_function_pairs(
  self : LocalTypeSolver,
  left_parameters : HirSpan,
  left_result : BodyTypeId,
  right_parameters : HirSpan,
  right_result : BodyTypeId,
) -> Bool {
  if left_parameters.length != right_parameters.length {
    return false
  }
  self.push_unification_pair(left_result, right_result)
  let mut index = left_parameters.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.type_arguments[left_parameters.start + index],
      self.type_arguments[right_parameters.start + index],
    )
  }
  true
}

///|
fn LocalTypeSolver::push_resolved_function_pairs(
  self : LocalTypeSolver,
  left_parameters : HirSpan,
  left_result : ResolvedTypeId,
  right_parameters : HirSpan,
  right_result : ResolvedTypeId,
) -> Bool {
  if left_parameters.length != right_parameters.length {
    return false
  }
  self.push_unification_pair(
    self.resolved_type(left_result),
    self.resolved_type(right_result),
  )
  let mut index = left_parameters.length
  while index > 0 {
    index -= 1
    self.push_unification_pair(
      self.resolved_type(
        self.resolved.type_arguments[left_parameters.start + index],
      ),
      self.resolved_type(
        self.resolved.type_arguments[right_parameters.start + index],
      ),
    )
  }
  true
}

///|
fn LocalTypeSolver::push_mixed_function_pairs(
  self : LocalTypeSolver,
  body_parameters : HirSpan,
  body_result : BodyTypeId,
  resolved_parameters : HirSpan,
  resolved_result : ResolvedTypeId,
  body_on_left : Bool,
) -> Bool {
  if body_parameters.length != resolved_parameters.length {
    return false
  }
  if body_on_left {
    self.push_unification_pair(body_result, self.resolved_type(resolved_result))
  } else {
    self.push_unification_pair(self.resolved_type(resolved_result), body_result)
  }
  let mut index = body_parameters.length
  while index > 0 {
    index -= 1
    let body_parameter = self.type_arguments[body_parameters.start + index]
    let resolved_parameter = self.resolved_type(
      self.resolved.type_arguments[resolved_parameters.start + index],
    )
    if body_on_left {
      self.push_unification_pair(body_parameter, resolved_parameter)
    } else {
      self.push_unification_pair(resolved_parameter, body_parameter)
    }
  }
  true
}

///|
fn LocalTypeSolver::report_mismatch(
  self : LocalTypeSolver,
  left_original : BodyTypeId,
  right_original : BodyTypeId,
  left : BodyTypeId,
  right : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  self.diagnostics.push(LocalTypeMismatch(left, right, origin))
  self.poison_direct_variable(left_original)
  self.poison_direct_variable(right_original)
  false
}

///|
pub fn LocalTypeSolver::unify(
  self : LocalTypeSolver,
  left : BodyTypeId,
  right : BodyTypeId,
  origin : TypeConstraintOrigin,
) -> Bool {
  self.unify_left.clear()
  self.unify_right.clear()
  self.push_unification_pair(left, right)
  let mut deferred : Array[(BodyTypeId, BodyTypeId)]? = None
  let mut bound_since_retry = false
  while true {
    if self.unify_left.is_empty() {
      match deferred {
        Some(pairs) if !pairs.is_empty() => {
          if !bound_since_retry {
            let (left, right) = pairs[0]
            return self.report_mismatch(
              left,
              right,
              self.representative_type(left),
              self.representative_type(right),
              origin,
            )
          }
          for pair in pairs {
            let (left, right) = pair
            self.push_unification_pair(left, right)
          }
          pairs.clear()
          bound_since_retry = false
        }
        _ => break
      }
    }
    guard self.unify_left.length() == self.unify_right.length() else {
      abort("SOL-205 unification work arrays differ")
    }
    let left_original = self.unify_left.pop().unwrap()
    let right_original = self.unify_right.pop().unwrap()
    let left_type = match self.reduce_member_type(left_original, 0) {
      Ok(value) => value
      Err(error) => {
        self.diagnostics.push(
          InvalidLocalMemberProjection(left_original, error, origin),
        )
        return false
      }
    }
    let right_type = match self.reduce_member_type(right_original, 0) {
      Ok(value) => value
      Err(error) => {
        self.diagnostics.push(
          InvalidLocalMemberProjection(right_original, error, origin),
        )
        return false
      }
    }
    if left_type == right_type {
      continue
    }
    // Projection operators are not injective: equal member types do not prove
    // equal owners. Only an already identical symbolic owner discharges this
    // equation; never infer an owner by unifying through the projection.
    if self.member_projection(left_type)
      is Some((left_owner, left_op, left_name)) &&
      self.member_projection(right_type)
      is Some((right_owner, right_op, right_name)) &&
      self.representative_type(left_owner) ==
      self.representative_type(right_owner) &&
      left_op == right_op &&
      left_name == right_name {
      continue
    }
    match self.type_term(left_type) {
      BodyVariableType(variable) => {
        if !self.bind_variable(variable, right_type, origin) {
          return false
        }
        bound_since_retry = true
        continue
      }
      _ => ()
    }
    match self.type_term(right_type) {
      BodyVariableType(variable) => {
        if !self.bind_variable(variable, left_type, origin) {
          return false
        }
        bound_since_retry = true
        continue
      }
      _ => ()
    }
    if left_type == self.error_type() || right_type == self.error_type() {
      continue
    }
    // A member projection cannot reveal its owner. Let other equations bind
    // that owner, then retry this exact pair. Each retry round requires a new
    // variable binding, so the queue cannot spin on an unknown owner.
    if (
        self.member_projection(left_type) is Some(_) &&
        self.has_pending_member_projection(left_type)
      ) ||
      (
        self.member_projection(right_type) is Some(_) &&
        self.has_pending_member_projection(right_type)
      ) {
      match deferred {
        Some(pairs) => pairs.push((left_original, right_original))
        None => deferred = Some([(left_original, right_original)])
      }
      continue
    }
    let compatible = match
      (self.type_term(left_type), self.type_term(right_type)) {
      (BodyResolvedType(left_resolved), BodyResolvedType(right_resolved)) =>
        match
          (
            self.resolved.types[left_resolved],
            self.resolved.types[right_resolved],
          ) {
          (ProductType(left_fields), ProductType(right_fields)) =>
            self.push_resolved_product_pairs(left_fields, right_fields)
          (
            AppliedType(left_base, left_arguments),
            AppliedType(right_base, right_arguments),
          ) =>
            self.push_resolved_application_pairs(
              left_base, left_arguments, right_base, right_arguments,
            )
          (
            FunctionType(left_parameters, left_result),
            FunctionType(right_parameters, right_result),
          ) =>
            self.push_resolved_function_pairs(
              left_parameters, left_result, right_parameters, right_result,
            )
          _ => false
        }
      (BodyProductType(left_fields), BodyProductType(right_fields)) =>
        self.push_body_product_pairs(left_fields, right_fields)
      (
        BodyAppliedType(left_base, left_arguments),
        BodyAppliedType(right_base, right_arguments),
      ) =>
        self.push_body_application_pairs(
          left_base, left_arguments, right_base, right_arguments,
        )
      (
        BodyFunctionType(left_parameters, left_result),
        BodyFunctionType(right_parameters, right_result),
      ) =>
        self.push_body_function_pairs(
          left_parameters, left_result, right_parameters, right_result,
        )
      (BodyProductType(body_fields), BodyResolvedType(resolved_type)) =>
        match self.resolved.types[resolved_type] {
          ProductType(resolved_fields) =>
            self.push_mixed_product_pairs(body_fields, resolved_fields, true)
          _ => false
        }
      (BodyResolvedType(resolved_type), BodyProductType(body_fields)) =>
        match self.resolved.types[resolved_type] {
          ProductType(resolved_fields) =>
            self.push_mixed_product_pairs(body_fields, resolved_fields, false)
          _ => false
        }
      (
        BodyAppliedType(body_base, body_arguments),
        BodyResolvedType(resolved_type),
      ) =>
        match self.resolved.types[resolved_type] {
          AppliedType(resolved_base, resolved_arguments) =>
            self.push_mixed_application_pairs(
              body_base, body_arguments, resolved_base, resolved_arguments, true,
            )
          _ => false
        }
      (
        BodyResolvedType(resolved_type),
        BodyAppliedType(body_base, body_arguments),
      ) =>
        match self.resolved.types[resolved_type] {
          AppliedType(resolved_base, resolved_arguments) =>
            self.push_mixed_application_pairs(
              body_base, body_arguments, resolved_base, resolved_arguments, false,
            )
          _ => false
        }
      (
        BodyFunctionType(body_parameters, body_result),
        BodyResolvedType(resolved_type),
      ) =>
        match self.resolved.types[resolved_type] {
          FunctionType(resolved_parameters, resolved_result) =>
            self.push_mixed_function_pairs(
              body_parameters, body_result, resolved_parameters, resolved_result,
              true,
            )
          _ => false
        }
      (
        BodyResolvedType(resolved_type),
        BodyFunctionType(body_parameters, body_result),
      ) =>
        match self.resolved.types[resolved_type] {
          FunctionType(resolved_parameters, resolved_result) =>
            self.push_mixed_function_pairs(
              body_parameters, body_result, resolved_parameters, resolved_result,
              false,
            )
          _ => false
        }
      _ => false
    }
    if !compatible {
      return self.report_mismatch(
        left_original, right_original, left_type, right_type, origin,
      )
    }
  }
  true
}

///|
pub fn LocalTypeSolver::snapshot(self : LocalTypeSolver) -> InferenceSnapshot {
  self.assert_undo_arrays()
  guard self.next_snapshot_token < 18446744073709551615UL else {
    abort("SOL-204 inference snapshot identity space exhausted")
  }
  let snapshot = {
    token: self.next_snapshot_token,
    undo_start: self.undo_kinds.length(),
    variable_count: self.variable_parents.length(),
    type_count: self.types.length(),
    argument_count: self.type_arguments.length(),
    diagnostic_count: self.diagnostics.length(),
  }
  // Never reset this counter: a handle from a previous job must stay stale.
  self.next_snapshot_token += 1UL
  self.snapshots.push(snapshot)
  snapshot
}

///|
fn LocalTypeSolver::restore_undo(self : LocalTypeSolver, start : Int) -> Unit {
  match self.check_undo_restore(start) {
    Ok(_) => ()
    Err(error) => abort("solver undo invariant: " + @debug.to_string(error))
  }
  while self.undo_kinds.length() > start {
    let slot = self.undo_kinds.length() - 1
    let kind = self.undo_kinds[slot]
    let index = self.undo_indices[slot]
    let old_value = self.undo_values[slot]
    match kind {
      0 => self.variable_parents[index] = old_value
      1 => self.variable_sizes[index] = old_value
      2 => self.variable_bindings[index] = old_value
      _ => abort("invalid inference undo entry")
    }
    self.undo_kinds.truncate(slot)
    self.undo_indices.truncate(slot)
    self.undo_values.truncate(slot)
  }
}

///|
pub fn LocalTypeSolver::rollback(
  self : LocalTypeSolver,
  snapshot : InferenceSnapshot,
) -> Unit {
  guard self.snapshots.length() > 0 &&
    self.snapshots[self.snapshots.length() - 1] == snapshot else {
    abort("SOL-204 inference snapshots must roll back in LIFO order")
  }
  self.restore_undo(snapshot.undo_start)
  self.variable_parents.truncate(snapshot.variable_count)
  self.variable_sizes.truncate(snapshot.variable_count)
  self.variable_bindings.truncate(snapshot.variable_count)
  self.variable_types.truncate(snapshot.variable_count)
  self.types.truncate(snapshot.type_count)
  self.type_arguments.truncate(snapshot.argument_count)
  self.occurs_local_marks.truncate(snapshot.type_count)
  self.zonk_marks.truncate(snapshot.type_count)
  self.zonk_values.truncate(snapshot.type_count)
  self.diagnostics.truncate(snapshot.diagnostic_count)
  ignore(self.snapshots.pop())
  if self.snapshots.length() == 0 {
    self.undo_kinds.clear()
    self.undo_indices.clear()
    self.undo_values.clear()
  }
}

///|
pub fn LocalTypeSolver::commit(
  self : LocalTypeSolver,
  snapshot : InferenceSnapshot,
) -> Unit {
  guard self.snapshots.length() > 0 &&
    self.snapshots[self.snapshots.length() - 1] == snapshot else {
    abort("SOL-204 inference snapshots must commit in LIFO order")
  }
  match self.check_undo_restore(snapshot.undo_start) {
    Ok(_) => ()
    Err(error) => abort("solver undo invariant: " + @debug.to_string(error))
  }
  ignore(self.snapshots.pop())
  if self.snapshots.length() == 0 {
    self.undo_kinds.clear()
    self.undo_indices.clear()
    self.undo_values.clear()
  }
}

///|
fn LocalTypeSolver::next_zonk_generation(self : LocalTypeSolver) -> Unit {
  self.zonk_generation = next_traversal_generation(
    self.zonk_marks,
    self.zonk_generation,
  )
}

///|
fn LocalTypeSolver::push_zonk_task(
  self : LocalTypeSolver,
  type_ : BodyTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.zonk_task_types.push(type_)
  self.zonk_task_states.push(state)
  self.zonk_result_starts.push(result_start)
  assert_aligned_traversal_stacks(
    self.zonk_task_types.length(),
    self.zonk_task_states.length(),
    self.zonk_result_starts.length(),
  )
}

///|
pub fn LocalTypeSolver::zonk_type(
  self : LocalTypeSolver,
  root : BodyTypeId,
  origin? : TypeConstraintOrigin = synthetic_type_origin(-1, 0UL),
) -> BodyTypeId {
  guard self.snapshots.length() == 0 else {
    abort("cannot freeze a type while an inference snapshot is active")
  }
  let representative = self.zonk_member_type(root, origin)
  if representative <= 0 {
    return representative
  }
  match self.types[representative] {
    BodyProductType(_)
    | BodyAppliedType(_, _)
    | BodyFunctionType(_, _)
    | BodyMemberTypeProjection(_, _, _) => ()
    _ => return representative
  }
  self.next_zonk_generation()
  self.zonk_task_types.clear()
  self.zonk_task_states.clear()
  self.zonk_result_starts.clear()
  self.zonk_results.clear()
  self.push_zonk_task(root, zonk_visit, 0)
  while self.zonk_task_types.length() > 0 {
    let source = self.zonk_task_types.pop().unwrap()
    let state = self.zonk_task_states.pop().unwrap()
    let result_start = self.zonk_result_starts.pop().unwrap()
    let current = self.zonk_member_type(source, origin)
    if state == zonk_visit {
      if current < 0 {
        self.zonk_results.push(current)
        continue
      }
      if self.zonk_marks[current] == self.zonk_generation {
        self.zonk_results.push(self.zonk_values[current])
        continue
      }
      match self.types[current] {
        BodyMemberTypeProjection(owner, _, _) => {
          self.push_zonk_task(
            current,
            zonk_finish_projection,
            self.zonk_results.length(),
          )
          self.push_zonk_task(owner, zonk_visit, 0)
        }
        BodyProductType(fields) => {
          self.push_zonk_task(
            current,
            zonk_finish_product,
            self.zonk_results.length(),
          )
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_zonk_task(
              self.type_arguments[fields.start + index],
              zonk_visit,
              0,
            )
          }
        }
        BodyAppliedType(base, arguments) => {
          self.push_zonk_task(
            current,
            zonk_finish_application,
            self.zonk_results.length(),
          )
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_zonk_task(
              self.type_arguments[arguments.start + index],
              zonk_visit,
              0,
            )
          }
          self.push_zonk_task(base, zonk_visit, 0)
        }
        BodyFunctionType(parameters, result) => {
          self.push_zonk_task(
            current,
            zonk_finish_function,
            self.zonk_results.length(),
          )
          self.push_zonk_task(result, zonk_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_zonk_task(
              self.type_arguments[parameters.start + index],
              zonk_visit,
              0,
            )
          }
        }
        _ => {
          self.zonk_marks[current] = self.zonk_generation
          self.zonk_values[current] = current
          self.zonk_results.push(current)
        }
      }
    } else if state == zonk_finish_projection {
      let (owner, operation, selector) = match self.types[current] {
        BodyMemberTypeProjection(owner, operation, selector) =>
          (owner, operation, selector)
        _ => abort("INV-001 zonk projection task changed type")
      }
      let selected = self.zonk_results[result_start]
      let result = if selected == owner {
        current
      } else {
        self.member_projection_type(selected, operation, selector)
      }
      self.zonk_marks[current] = self.zonk_generation
      self.zonk_values[current] = result
      self.zonk_results.truncate(result_start)
      self.zonk_results.push(result)
    } else if state == zonk_finish_application {
      let original = match self.types[current] {
        BodyAppliedType(_, arguments) => arguments
        _ => abort("zonk finish expected an applied type")
      }
      let base = self.zonk_results[result_start]
      self.zonk_application_scratch.clear()
      let mut poisoned = base == self.error_type()
      let mut unchanged = true
      for index in 0..<original.length {
        let argument = self.zonk_results[result_start + index + 1]
        if argument == self.error_type() {
          poisoned = true
        }
        if argument != self.type_arguments[original.start + index] {
          unchanged = false
        }
        self.zonk_application_scratch.push(argument)
      }
      let original_base = match self.types[current] {
        BodyAppliedType(value, _) => value
        _ => abort("zonk finish expected an applied type")
      }
      if base != original_base {
        unchanged = false
      }
      let result = if poisoned {
        self.error_type()
      } else if unchanged {
        current
      } else {
        self.applied_type(base, self.zonk_application_scratch)
      }
      self.zonk_marks[current] = self.zonk_generation
      self.zonk_values[current] = result
      self.zonk_results.truncate(result_start)
      self.zonk_results.push(result)
    } else if state == zonk_finish_function {
      let (original_parameters, original_result) = match self.types[current] {
        BodyFunctionType(parameters, result) => (parameters, result)
        _ => abort("zonk finish expected a function type")
      }
      self.zonk_application_scratch.clear()
      let mut poisoned = false
      let mut unchanged = true
      for index in 0..<original_parameters.length {
        let parameter = self.zonk_results[result_start + index]
        if parameter == self.error_type() {
          poisoned = true
        }
        if parameter != self.type_arguments[original_parameters.start + index] {
          unchanged = false
        }
        self.zonk_application_scratch.push(parameter)
      }
      let frozen_result = self.zonk_results[result_start +
        original_parameters.length]
      if frozen_result == self.error_type() {
        poisoned = true
      }
      if frozen_result != original_result {
        unchanged = false
      }
      let result = if poisoned {
        self.error_type()
      } else if unchanged {
        current
      } else {
        self.function_type(self.zonk_application_scratch, frozen_result)
      }
      self.zonk_marks[current] = self.zonk_generation
      self.zonk_values[current] = result
      self.zonk_results.truncate(result_start)
      self.zonk_results.push(result)
    } else {
      let original = match self.types[current] {
        BodyProductType(fields) => fields
        _ => abort("zonk finish expected a product type")
      }
      self.zonk_application_scratch.clear()
      let mut poisoned = false
      let mut unchanged = true
      for index in 0..<original.length {
        let field = self.zonk_results[result_start + index]
        if field == self.error_type() {
          poisoned = true
        }
        if field != self.type_arguments[original.start + index] {
          unchanged = false
        }
        self.zonk_application_scratch.push(field)
      }
      let result = if poisoned {
        self.error_type()
      } else if unchanged {
        current
      } else {
        self.product_type(self.zonk_application_scratch)
      }
      self.zonk_marks[current] = self.zonk_generation
      self.zonk_values[current] = result
      self.zonk_results.truncate(result_start)
      self.zonk_results.push(result)
    }
  }
  guard self.zonk_results.length() == 1 else {
    abort("invalid frozen body type result")
  }
  self.zonk_results[0]
}

///|
pub fn LocalTypeSolver::has_unresolved_variable(
  self : LocalTypeSolver,
  root : BodyTypeId,
) -> Bool {
  let representative = self.representative_type(root)
  if representative <= 0 {
    return false
  }
  match self.types[representative] {
    BodyVariableType(_) => return true
    BodyProductType(_)
    | BodyAppliedType(_, _)
    | BodyFunctionType(_, _)
    | BodyMemberTypeProjection(_, _, _) => ()
    BodyErrorType | BodyResolvedType(_) => return false
  }
  self.next_occurs_generation()
  self.occurs_stack.clear()
  self.occurs_stack.push(representative)
  while self.occurs_stack.length() > 0 {
    let current = self.representative_type(self.occurs_stack.pop().unwrap())
    if current < -1 {
      let resolved_id = self.decoded_resolved_type(current)
      match self.resolved.types[resolved_id] {
        ProductType(fields) => {
          self.ensure_occurs_resolved_marks()
          if self.occurs_resolved_marks[resolved_id] == self.occurs_generation {
            continue
          }
          self.occurs_resolved_marks[resolved_id] = self.occurs_generation
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.occurs_stack.push(
              self.resolved_type(
                self.resolved.type_arguments[fields.start + index],
              ),
            )
          }
        }
        AppliedType(base, arguments) => {
          self.ensure_occurs_resolved_marks()
          if self.occurs_resolved_marks[resolved_id] == self.occurs_generation {
            continue
          }
          self.occurs_resolved_marks[resolved_id] = self.occurs_generation
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.occurs_stack.push(
              self.resolved_type(
                self.resolved.type_arguments[arguments.start + index],
              ),
            )
          }
          self.occurs_stack.push(self.resolved_type(base))
        }
        _ => ()
      }
      continue
    }
    if self.occurs_local_marks[current] == self.occurs_generation {
      continue
    }
    self.occurs_local_marks[current] = self.occurs_generation
    match self.types[current] {
      BodyVariableType(_) => return true
      BodyMemberTypeProjection(owner, _, _) => self.occurs_stack.push(owner)
      BodyProductType(fields) => {
        let mut index = fields.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[fields.start + index])
        }
      }
      BodyAppliedType(base, arguments) => {
        let mut index = arguments.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[arguments.start + index])
        }
        self.occurs_stack.push(base)
      }
      BodyFunctionType(parameters, result) => {
        self.occurs_stack.push(result)
        let mut index = parameters.length
        while index > 0 {
          index -= 1
          self.occurs_stack.push(self.type_arguments[parameters.start + index])
        }
      }
      BodyErrorType | BodyResolvedType(_) => ()
    }
  }
  false
}
