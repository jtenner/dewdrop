///|
let normalize_visit = 0

///|
let normalize_finish_application = 1

///|
let normalize_finish_alias_arguments = 2

///|
let normalize_finish_alias_expansion = 3

///|
let normalize_finish_function = 4

///|
let substitute_visit = 0

///|
let substitute_finish_application = 1

///|
let substitute_finish_function = 2

///|
fn TypeResolver::ensure_normalization_slots(self : TypeResolver) -> Unit {
  while self.normalizations.length() < self.interner.types.length() {
    self.normalizations.push(-1)
  }
}

///|
fn TypeResolver::ensure_substitution_slots(self : TypeResolver) -> Unit {
  while self.substitution_marks.length() < self.interner.types.length() {
    self.substitution_marks.push(0)
    self.substitution_values.push(-1)
  }
}

///|
fn TypeResolver::push_normalization_task(
  self : TypeResolver,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.normalization_task_types.push(type_)
  self.normalization_task_states.push(state)
  self.normalization_result_starts.push(result_start)
}

///|
fn TypeResolver::push_substitution_task(
  self : TypeResolver,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.substitution_task_types.push(type_)
  self.substitution_task_states.push(state)
  self.substitution_result_starts.push(result_start)
}

///|
fn TypeResolver::alias_index_for_constructor(
  self : TypeResolver,
  type_ : ResolvedTypeId,
) -> Int? {
  match self.interner.types[type_] {
    NominalType(declaration) => self.alias_indices.get(declaration)
    _ => None
  }
}

///|
fn TypeResolver::alias_parameter_argument(
  self : TypeResolver,
  alias_index : Int,
  parameter : GenericParameterId,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId? {
  let declaration = self.collected.aliases[alias_index].declaration
  guard semantic_id_module(parameter) == self.collected.module_id else {
    return None
  }
  let parameters = self.collected.generic_parameters_of(declaration)
  let local_index = semantic_id_local(parameter)
  if local_index < parameters.start ||
    local_index >= parameters.start + parameters.length {
    None
  } else {
    Some(arguments[local_index - parameters.start])
  }
}

///|
fn TypeResolver::substitute_alias_target(
  self : TypeResolver,
  alias_index : Int,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId {
  self.substitution_generation += 1
  if self.substitution_generation == 0 {
    self.substitution_marks.fill(0)
    self.substitution_generation = 1
  }
  self.ensure_substitution_slots()
  self.substitution_task_types.clear()
  self.substitution_task_states.clear()
  self.substitution_result_starts.clear()
  self.substitution_results.clear()
  self.push_substitution_task(
    self.alias_target_types[alias_index],
    substitute_visit,
    0,
  )
  while self.substitution_task_types.length() > 0 {
    let current = self.substitution_task_types.pop().unwrap()
    let state = self.substitution_task_states.pop().unwrap()
    let result_start = self.substitution_result_starts.pop().unwrap()
    if state == substitute_visit {
      if self.substitution_marks[current] == self.substitution_generation {
        self.substitution_results.push(self.substitution_values[current])
        continue
      }
      match self.interner.types[current] {
        GenericParameterType(parameter) => {
          let result = self
            .alias_parameter_argument(alias_index, parameter, arguments)
            .unwrap_or(current)
          self.substitution_marks[current] = self.substitution_generation
          self.substitution_values[current] = result
          self.substitution_results.push(result)
        }
        AppliedType(base, span) => {
          self.push_substitution_task(
            current,
            substitute_finish_application,
            self.substitution_results.length(),
          )
          let mut index = span.length
          while index > 0 {
            index -= 1
            self.push_substitution_task(
              self.interner.arguments[span.start + index],
              substitute_visit,
              0,
            )
          }
          self.push_substitution_task(base, substitute_visit, 0)
        }
        FunctionType(parameters, result) => {
          self.push_substitution_task(
            current,
            substitute_finish_function,
            self.substitution_results.length(),
          )
          self.push_substitution_task(result, substitute_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_substitution_task(
              self.interner.arguments[parameters.start + index],
              substitute_visit,
              0,
            )
          }
        }
        _ => {
          self.substitution_marks[current] = self.substitution_generation
          self.substitution_values[current] = current
          self.substitution_results.push(current)
        }
      }
    } else if state == substitute_finish_application {
      let base = self.substitution_results[result_start]
      self.substitution_application_scratch.clear()
      for index in (result_start + 1)..<self.substitution_results.length() {
        self.substitution_application_scratch.push(
          self.substitution_results[index],
        )
      }
      let result = self.interner.intern_applied(
        base,
        self.substitution_application_scratch,
      )
      self.ensure_substitution_slots()
      self.substitution_marks[current] = self.substitution_generation
      self.substitution_values[current] = result
      self.substitution_results.truncate(result_start)
      self.substitution_results.push(result)
    } else {
      let parameter_count = match self.interner.types[current] {
        FunctionType(parameters, _) => parameters.length
        _ => abort("function substitution task expected a function type")
      }
      self.finish_substituted_function(current, result_start, parameter_count)
    }
  }
  guard self.substitution_results.length() == 1 else {
    abort("invalid alias substitution result")
  }
  self.substitution_results[0]
}

///|
fn imported_alias_parameter_argument(
  binding : ImportedDeclarationBinding,
  parameter : GenericParameterId,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId? {
  guard semantic_id_module(parameter) == semantic_id_module(binding.declaration) else {
    return None
  }
  let local_index = semantic_id_local(parameter)
  if local_index < binding.generic_parameters.start ||
    local_index >=
    binding.generic_parameters.start + binding.generic_parameters.length {
    None
  } else {
    Some(arguments[local_index - binding.generic_parameters.start])
  }
}

///|
fn TypeResolver::substitute_imported_alias_target(
  self : TypeResolver,
  binding : ImportedDeclarationBinding,
  target : ResolvedTypeId,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId {
  self.substitution_generation += 1
  if self.substitution_generation == 0 {
    self.substitution_marks.fill(0)
    self.substitution_generation = 1
  }
  self.ensure_substitution_slots()
  self.substitution_task_types.clear()
  self.substitution_task_states.clear()
  self.substitution_result_starts.clear()
  self.substitution_results.clear()
  self.push_substitution_task(target, substitute_visit, 0)
  while self.substitution_task_types.length() > 0 {
    let current = self.substitution_task_types.pop().unwrap()
    let state = self.substitution_task_states.pop().unwrap()
    let result_start = self.substitution_result_starts.pop().unwrap()
    if state == substitute_visit {
      if self.substitution_marks[current] == self.substitution_generation {
        self.substitution_results.push(self.substitution_values[current])
        continue
      }
      match self.interner.types[current] {
        GenericParameterType(parameter) => {
          let result = imported_alias_parameter_argument(
            binding, parameter, arguments,
          ).unwrap_or(current)
          self.substitution_marks[current] = self.substitution_generation
          self.substitution_values[current] = result
          self.substitution_results.push(result)
        }
        AppliedType(base, span) => {
          self.push_substitution_task(
            current,
            substitute_finish_application,
            self.substitution_results.length(),
          )
          let mut index = span.length
          while index > 0 {
            index -= 1
            self.push_substitution_task(
              self.interner.arguments[span.start + index],
              substitute_visit,
              0,
            )
          }
          self.push_substitution_task(base, substitute_visit, 0)
        }
        FunctionType(parameters, result) => {
          self.push_substitution_task(
            current,
            substitute_finish_function,
            self.substitution_results.length(),
          )
          self.push_substitution_task(result, substitute_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_substitution_task(
              self.interner.arguments[parameters.start + index],
              substitute_visit,
              0,
            )
          }
        }
        _ => {
          self.substitution_marks[current] = self.substitution_generation
          self.substitution_values[current] = current
          self.substitution_results.push(current)
        }
      }
    } else if state == substitute_finish_application {
      let base = self.substitution_results[result_start]
      self.substitution_application_scratch.clear()
      for index in (result_start + 1)..<self.substitution_results.length() {
        self.substitution_application_scratch.push(
          self.substitution_results[index],
        )
      }
      let result = self.interner.intern_applied(
        base,
        self.substitution_application_scratch,
      )
      self.ensure_substitution_slots()
      self.substitution_marks[current] = self.substitution_generation
      self.substitution_values[current] = result
      self.substitution_results.truncate(result_start)
      self.substitution_results.push(result)
    } else {
      let parameter_count = match self.interner.types[current] {
        FunctionType(parameters, _) => parameters.length
        _ => abort("function substitution task expected a function type")
      }
      self.finish_substituted_function(current, result_start, parameter_count)
    }
  }
  guard self.substitution_results.length() == 1 else {
    abort("invalid imported alias substitution result")
  }
  self.substitution_results[0]
}

///|
fn TypeResolver::can_expand_alias(
  self : TypeResolver,
  alias_index : Int,
) -> Bool {
  if self.alias_is_cyclic[alias_index] {
    return false
  }
  if self.alias_expansion_work < self.alias_expansion_limit {
    self.alias_expansion_work += 1
    return true
  }
  if !self.alias_expansion_limited[alias_index] {
    self.alias_expansion_limited[alias_index] = true
    let declaration = self.collected.aliases[alias_index].declaration
    self.diagnose(
      AliasExpansionLimit(
        declaration,
        self.alias_expansion_limit,
        self.alias_offset(alias_index),
      ),
    )
  }
  false
}

///|
fn TypeResolver::finish_substituted_function(
  self : TypeResolver,
  original : ResolvedTypeId,
  result_start : Int,
  parameter_count : Int,
) -> Unit {
  self.substitution_application_scratch.clear()
  for index in 0..<parameter_count {
    self.substitution_application_scratch.push(
      self.substitution_results[result_start + index],
    )
  }
  let result = self.interner.intern_function(
    self.substitution_application_scratch,
    self.substitution_results[result_start + parameter_count],
  )
  self.ensure_substitution_slots()
  self.substitution_marks[original] = self.substitution_generation
  self.substitution_values[original] = result
  self.substitution_results.truncate(result_start)
  self.substitution_results.push(result)
}

///|
fn TypeResolver::finish_normal_function(
  self : TypeResolver,
  original : ResolvedTypeId,
  result_start : Int,
  parameter_count : Int,
) -> Unit {
  self.normalization_application_scratch.clear()
  let mut poisoned = false
  for index in 0..<parameter_count {
    let parameter = self.normalization_results[result_start + index]
    if parameter == self.interner.error_type {
      poisoned = true
    }
    self.normalization_application_scratch.push(parameter)
  }
  let result_type = self.normalization_results[result_start + parameter_count]
  if result_type == self.interner.error_type {
    poisoned = true
  }
  let result = if poisoned {
    self.interner.error_type
  } else {
    self.interner.intern_function(
      self.normalization_application_scratch,
      result_type,
    )
  }
  self.ensure_normalization_slots()
  self.normalizations[original] = result
  if result >= 0 && self.normalizations[result] < 0 {
    self.normalizations[result] = result
  }
  self.normalization_results.truncate(result_start)
  self.normalization_results.push(result)
}

///|
fn TypeResolver::finish_normal_application(
  self : TypeResolver,
  original : ResolvedTypeId,
  result_start : Int,
) -> Unit {
  let base = self.normalization_results[result_start]
  self.normalization_application_scratch.clear()
  let mut poisoned = base == self.interner.error_type
  for index in (result_start + 1)..<self.normalization_results.length() {
    let argument = self.normalization_results[index]
    if argument == self.interner.error_type {
      poisoned = true
    }
    self.normalization_application_scratch.push(argument)
  }
  let result = if poisoned {
    self.interner.error_type
  } else {
    self.interner.intern_applied(base, self.normalization_application_scratch)
  }
  self.ensure_normalization_slots()
  self.normalizations[original] = result
  if result >= 0 && self.normalizations[result] < 0 {
    self.normalizations[result] = result
  }
  self.normalization_results.truncate(result_start)
  self.normalization_results.push(result)
}

///|
fn TypeResolver::finish_alias_arguments(
  self : TypeResolver,
  original : ResolvedTypeId,
  result_start : Int,
) -> Unit {
  let alias_index = match self.interner.types[original] {
    NominalType(_) => self.alias_index_for_constructor(original).unwrap()
    AppliedType(base, _) => self.alias_index_for_constructor(base).unwrap()
    _ => abort("alias normalization expected an alias type")
  }
  self.normalization_application_scratch.clear()
  let mut poisoned = false
  for index in result_start..<self.normalization_results.length() {
    let argument = self.normalization_results[index]
    if argument == self.interner.error_type {
      poisoned = true
    }
    self.normalization_application_scratch.push(argument)
  }
  self.normalization_results.truncate(result_start)
  if poisoned || !self.can_expand_alias(alias_index) {
    self.normalizations[original] = self.interner.error_type
    self.normalization_results.push(self.interner.error_type)
    return
  }
  let instantiated = self.substitute_alias_target(
    alias_index,
    self.normalization_application_scratch,
  )
  self.ensure_normalization_slots()
  self.push_normalization_task(
    original, normalize_finish_alias_expansion, result_start,
  )
  self.push_normalization_task(instantiated, normalize_visit, 0)
}

///|
fn TypeResolver::normalize_type(
  self : TypeResolver,
  root : ResolvedTypeId,
) -> ResolvedTypeId {
  self.ensure_normalization_slots()
  if self.normalizations[root] >= 0 {
    return self.normalizations[root]
  }
  self.normalization_task_types.clear()
  self.normalization_task_states.clear()
  self.normalization_result_starts.clear()
  self.normalization_results.clear()
  self.push_normalization_task(root, normalize_visit, 0)
  while self.normalization_task_types.length() > 0 {
    let current = self.normalization_task_types.pop().unwrap()
    let state = self.normalization_task_states.pop().unwrap()
    let result_start = self.normalization_result_starts.pop().unwrap()
    if state == normalize_visit {
      self.ensure_normalization_slots()
      if self.normalizations[current] >= 0 {
        self.normalization_results.push(self.normalizations[current])
        continue
      }
      match self.interner.types[current] {
        ErrorType
        | PrimitiveType(_)
        | GenericParameterType(_)
        | TraitType(_)
        | SelfType(_) => {
          self.normalizations[current] = current
          self.normalization_results.push(current)
        }
        NominalType(declaration) =>
          match self.alias_indices.get(declaration) {
            Some(_) => {
              let arity = self.declaration_arity(declaration)
              if arity == 0 {
                self.push_normalization_task(
                  current,
                  normalize_finish_alias_arguments,
                  self.normalization_results.length(),
                )
              } else {
                self.normalizations[current] = current
                self.normalization_results.push(current)
              }
            }
            None => {
              self.normalizations[current] = current
              self.normalization_results.push(current)
            }
          }
        AppliedType(base, span) =>
          match self.alias_index_for_constructor(base) {
            Some(_) => {
              self.push_normalization_task(
                current,
                normalize_finish_alias_arguments,
                self.normalization_results.length(),
              )
              let mut index = span.length
              while index > 0 {
                index -= 1
                self.push_normalization_task(
                  self.interner.arguments[span.start + index],
                  normalize_visit,
                  0,
                )
              }
            }
            None => {
              self.push_normalization_task(
                current,
                normalize_finish_application,
                self.normalization_results.length(),
              )
              let mut index = span.length
              while index > 0 {
                index -= 1
                self.push_normalization_task(
                  self.interner.arguments[span.start + index],
                  normalize_visit,
                  0,
                )
              }
              self.push_normalization_task(base, normalize_visit, 0)
            }
          }
        FunctionType(parameters, result) => {
          self.push_normalization_task(
            current,
            normalize_finish_function,
            self.normalization_results.length(),
          )
          self.push_normalization_task(result, normalize_visit, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_normalization_task(
              self.interner.arguments[parameters.start + index],
              normalize_visit,
              0,
            )
          }
        }
      }
    } else if state == normalize_finish_application {
      self.finish_normal_application(current, result_start)
    } else if state == normalize_finish_alias_arguments {
      self.finish_alias_arguments(current, result_start)
    } else if state == normalize_finish_function {
      let parameter_count = match self.interner.types[current] {
        FunctionType(parameters, _) => parameters.length
        _ => abort("function normalization task expected a function type")
      }
      self.finish_normal_function(current, result_start, parameter_count)
    } else {
      let result = self.normalization_results[result_start]
      self.normalizations[current] = result
    }
  }
  guard self.normalization_results.length() == 1 else {
    abort("invalid alias normalization result")
  }
  self.normalization_results[0]
}

///|
fn TypeResolver::normalize_signature_tables(self : TypeResolver) -> Unit {
  for index in 0..<self.parameter_types.length() {
    self.parameter_types[index] = self.normalize_type(
      self.parameter_types[index],
    )
  }
  for index in 0..<self.callable_return_types.length() {
    self.callable_return_types[index] = self.normalize_type(
      self.callable_return_types[index],
    )
  }
  for index in 0..<self.lambda_parameter_types.length() {
    self.lambda_parameter_types[index] = self.normalize_type(
      self.lambda_parameter_types[index],
    )
  }
  for index in 0..<self.lambda_return_types.length() {
    self.lambda_return_types[index] = self.normalize_type(
      self.lambda_return_types[index],
    )
  }
  for index in 0..<self.field_types.length() {
    self.field_types[index] = self.normalize_type(self.field_types[index])
  }
  for index in 0..<self.signature_type_lists.length() {
    self.signature_type_lists[index] = self.normalize_type(
      self.signature_type_lists[index],
    )
  }
  for index in 0..<self.impl_trait_types.length() {
    if self.impl_trait_types[index] >= 0 {
      self.impl_trait_types[index] = self.normalize_type(
        self.impl_trait_types[index],
      )
    }
    self.impl_target_types[index] = self.normalize_type(
      self.impl_target_types[index],
    )
  }
}

///|
fn TypeResolver::resolve_callable_function_types(self : TypeResolver) -> Unit {
  for index, callable in self.collected.callables {
    let parameters = self.collected.parameters_of(callable.declaration)
    self.application_scratch.clear()
    for
      parameter_index in parameters.start..<(parameters.start +
      parameters.length) {
      self.application_scratch.push(self.parameter_types[parameter_index])
    }
    self.callable_function_types[index] = self.interner.intern_function(
      self.application_scratch,
      self.callable_return_types[index],
    )
  }
  for index, lambda in self.collected.lambdas {
    self.application_scratch.clear()
    for
      parameter_index in lambda.parameters.start..<(lambda.parameters.start +
      lambda.parameters.length) {
      self.application_scratch.push(
        self.lambda_parameter_types[parameter_index],
      )
    }
    self.lambda_function_types[index] = self.interner.intern_function(
      self.application_scratch,
      self.lambda_return_types[index],
    )
  }
}

///|
fn TypeResolver::normalize_aliases(
  self : TypeResolver,
  requested_limit : Int,
) -> Unit {
  let scaled_limit = self.interner.types.length() * 64
  self.alias_expansion_limit = if requested_limit >= 0 {
    requested_limit
  } else if scaled_limit > 4096 {
    scaled_limit
  } else {
    4096
  }
  self.ensure_normalization_slots()
  self.normalize_signature_tables()
  self.resolve_callable_function_types()
}
