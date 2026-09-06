///|
fn compile_time_match_type(
  pattern : CompileTimeType,
  actual : CompileTimeType,
  bindings : Map[GenericParameterId, CompileTimeType],
) -> Bool {
  let work = [(pattern, actual)]
  while work.length() > 0 {
    let (pattern, actual) = work.pop().unwrap()
    match (pattern, actual) {
      (CtParameter(parameter), value) =>
        match bindings.get(parameter) {
          Some(previous) if previous != value => return false
          Some(_) => ()
          None => bindings[parameter] = value
        }
      (CtProduct(left), CtProduct(right)) => {
        if left.length() != right.length() {
          return false
        }
        for index in 0..<left.length() {
          work.push((left[index], right[index]))
        }
      }
      (CtApplied(left_base, left), CtApplied(right_base, right)) => {
        if left.length() != right.length() {
          return false
        }
        work.push((left_base, right_base))
        for index in 0..<left.length() {
          work.push((left[index], right[index]))
        }
      }
      (CtFunction(left, left_result), CtFunction(right, right_result)) => {
        if left.length() != right.length() {
          return false
        }
        work.push((left_result, right_result))
        for index in 0..<left.length() {
          work.push((left[index], right[index]))
        }
      }
      _ => if pattern != actual { return false }
    }
  }
  true
}

///|
struct CompileTimeEvidenceSearch {
  collected : CollectedModule
  resolved : ResolvedModuleTypes
  module_ : PlannedModuleLowering
  imports : ResolvedModuleImports
  index : ModuleImplIndex
  active : Array[(CompileTimeType, CompileTimeType)]
  mut steps : Int
  mut include_test_impls : Bool
}

///|
fn CompileTimeEvidenceSearch::read(
  self : CompileTimeEvidenceSearch,
  type_ : ResolvedTypeId,
  bindings : Map[GenericParameterId, CompileTimeType],
) -> Result[CompileTimeType, String] {
  if type_ < 0 || type_ > 2147483646 {
    return Err("CT-010 invalid trait type index")
  }
  match compile_time_read_type(self.module_, -type_ - 2, bindings) {
    Ok(value) => Ok(value)
    Err(error) => Err("CT-010 " + @debug.to_string(error))
  }
}

///|
fn CompileTimeEvidenceSearch::prerequisites(
  self : CompileTimeEvidenceSearch,
  declaration : DeclId,
  bindings : Map[GenericParameterId, CompileTimeType],
) -> Result[Bool, String] {
  let obligations : Array[(GenericParameterId, ResolvedTypeId)] = []
  if semantic_id_module(declaration) == self.collected.module_id {
    let generics = self.collected.generic_parameters_of(declaration)
    for offset in 0..<generics.length {
      let generic = self.collected.generic_parameters[generics.start + offset]
      guard program_specialization_span_is_valid(
        generic.bounds,
        self.resolved.generic_bound_types.length(),
      ) else {
        return Err("CT-010 invalid local trait prerequisite span")
      }
      for bound in 0..<generic.bounds.length {
        obligations.push(
          (
            generic.id,
            self.resolved.generic_bound_types[generic.bounds.start + bound],
          ),
        )
      }
    }
  } else {
    let imported = match self.imports.implementation(declaration) {
      Some(value) => value
      None => return Err("CT-010 missing imported implementation identity")
    }
    guard program_specialization_span_is_valid(
        imported.generic_bounds,
        self.imports.generic_parameter_ids.length(),
      ) &&
      program_specialization_span_is_valid(
        imported.generic_bounds,
        self.imports.generic_parameter_bounds.length(),
      ) &&
      imported.generic_parameters.length == imported.generic_bounds.length else {
      return Err("CT-010 invalid imported generic parameter spans")
    }
    for offset in 0..<imported.generic_parameters.length {
      // generic_parameters belongs to the defining module. generic_bounds
      // indexes the consumer's parallel imported ID and bound arenas.
      let parameter = self.imports.generic_parameter_ids[imported.generic_bounds.start +
        offset]
      let bounds = self.imports.generic_parameter_bounds[imported.generic_bounds.start +
        offset]
      guard program_specialization_span_is_valid(
        bounds,
        self.imports.generic_bound_types.length(),
      ) else {
        return Err("CT-010 invalid imported trait prerequisite span")
      }
      for bound in 0..<bounds.length {
        obligations.push(
          (parameter, self.imports.generic_bound_types[bounds.start + bound]),
        )
      }
    }
  }
  for obligation in obligations {
    let (parameter, bound) = obligation
    let target = match bindings.get(parameter) {
      Some(value) => value
      None => return Err("CT-011 unresolved implementation type argument")
    }
    let trait_ = match self.read(bound, bindings) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match self.search(target, trait_) {
      Ok(true) => ()
      other => return other
    }
  }
  Ok(true)
}

///|
fn CompileTimeEvidenceSearch::search(
  self : CompileTimeEvidenceSearch,
  target : CompileTimeType,
  trait_ : CompileTimeType,
) -> Result[Bool, String] {
  self.steps += 1
  if self.steps > 65536 || self.active.length() >= 256 {
    return Err("CT-012 trait evidence search limit exceeded")
  }
  let obligation = (target, trait_)
  for active in self.active {
    if active == obligation {
      return Err("CT-013 cyclic trait prerequisite")
    }
  }
  let trait_declaration = match trait_ {
    CtTrait(declaration) | CtApplied(CtTrait(declaration), _) => declaration
    _ => return Err("CT-014 implements requires a trait as its second argument")
  }
  match compile_time_types_are_concrete([target, trait_]) {
    Ok(true) => ()
    _ => return Err("CT-011 unresolved trait prerequisite")
  }
  self.active.push(obligation)
  let result = self.search_candidates(target, trait_, trait_declaration)
  let _ = self.active.pop().unwrap()
  result
}

///|
fn CompileTimeEvidenceSearch::search_candidates(
  self : CompileTimeEvidenceSearch,
  target : CompileTimeType,
  trait_ : CompileTimeType,
  trait_declaration : DeclId,
) -> Result[Bool, String] {
  let mut matches = 0
  for implementation in self.index.implementations {
    if !self.include_test_impls && self.collected.declaration_is_test_only(implementation.declaration) {
      continue
    }
    if implementation.kind != TraitIndexedImpl(trait_declaration) {
      continue
    }
    let bindings : Map[GenericParameterId, CompileTimeType] = Map([])
    let candidate_target = match
      self.read(implementation.target_type, bindings) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    if !compile_time_match_type(candidate_target, target, bindings) {
      continue
    }
    let candidate_trait = match self.read(implementation.trait_type, bindings) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    if !compile_time_match_type(candidate_trait, trait_, bindings) {
      continue
    }
    if !implementation.valid || !implementation.coherent {
      return Err("CT-015 invalid or ambiguous trait implementation")
    }
    match self.prerequisites(implementation.declaration, bindings) {
      Ok(true) => matches += 1
      Ok(false) => ()
      Err(error) => return Err(error)
    }
    if matches > 1 {
      return Err("CT-015 multiple compatible trait implementations")
    }
  }
  Ok(matches == 1)
}

///|
fn evaluate_compile_time_implements(
  search : CompileTimeEvidenceSearch,
  types : Array[CompileTimeType],
) -> Result[CompileTimeConstant?, String] {
  if types.length() != 2 {
    return Err("CT-001 implements requires two type arguments")
  }
  match compile_time_types_are_concrete(types) {
    Ok(false) => return Ok(None)
    Err(error) => return Err("CT-002 " + @debug.to_string(error))
    Ok(true) => ()
  }
  search.steps = 0
  match search.search(types[0], types[1]) {
    Ok(value) => Ok(Some(CtBool(value)))
    Err(error) => Err(error)
  }
}
