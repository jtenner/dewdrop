///| Immutable logical keys survive solver rollback. Body arena positions do not.
priv enum TraitSearchTypeKey {
  SearchError
  SearchVariable(Int)
  SearchPrimitive(Int)
  SearchParameter(GenericParameterId)
  SearchNominal(DeclId)
  SearchTrait(DeclId)
  SearchSelf(DeclId)
  SearchProduct(Array[Int])
  SearchApplied(Int, Array[Int])
  SearchFunction(Array[Int], Int)
  SearchProjection(Int, Bytes, String)
} derive(Eq, Hash, Debug)

///|
priv struct BodyTraitSearch {
  types : Map[TraitSearchTypeKey, Int]
  active : Array[(Int, Int, DeclId)]
  mut steps : Int
  mut failure : String?
}

///|
fn BodyTraitSearch::new() -> BodyTraitSearch {
  { types: {}, active: [], steps: 0, failure: None }
}

///| A recursive obligation must not replace its caller's generic environment.
priv struct TraitCandidateFrame {
  arguments : Array[BodyTypeId]
  generics : HirSpan
  method_generics : HirSpan
  self_owner : DeclId
  self_type : BodyTypeId
}

///|
fn BasicBodyInferencer::assert_trait_instantiation_idle(self : BasicBodyInferencer) -> Unit {
  let scratch = self.call_scratch
  for count in [scratch.instantiation_task_types.length(), scratch.instantiation_task_states.length(), scratch.instantiation_result_starts.length()] {
    if count != 0 {
      abort("trait instantiation work invariant: " + @debug.to_string(self.solver.solver_failure(206, 0, count, 0)))
    }
  }
}

///|
fn BasicBodyInferencer::save_trait_candidate(self : BasicBodyInferencer) -> TraitCandidateFrame {
  self.assert_trait_instantiation_idle()
  let scratch = self.call_scratch
  {
    arguments: scratch.candidate_type_arguments.copy(),
    generics: scratch.instantiation_generics,
    method_generics: scratch.instantiation_method_generics,
    self_owner: scratch.instantiation_self_owner,
    self_type: scratch.instantiation_self_type,
  }
}

///|
fn BasicBodyInferencer::restore_trait_candidate(self : BasicBodyInferencer, saved : TraitCandidateFrame) -> Unit {
  self.assert_trait_instantiation_idle()
  let scratch = self.call_scratch
  scratch.candidate_type_arguments.clear()
  for argument in saved.arguments { scratch.candidate_type_arguments.push(argument) }
  scratch.instantiation_generics = saved.generics
  scratch.instantiation_method_generics = saved.method_generics
  scratch.instantiation_self_owner = saved.self_owner
  scratch.instantiation_self_type = saved.self_type
  scratch.instantiation_results.clear()
  scratch.instantiation_arguments.clear()
  // Inner candidates can leave cached IDs from transactions now rolled back.
  self.next_instantiation_generation()
}

///|
fn BodyTraitSearch::admit(self : BodyTraitSearch, target : Int, bound : Int, trait_ : DeclId) -> Result[Unit, String] {
  let obligation = (target, bound, trait_)
  if self.active.contains(obligation) {
    return Err("CT-013 cyclic trait prerequisite")
  }
  if self.steps >= 65536 || self.active.length() >= 256 {
    return Err("CT-012 trait evidence search limit exceeded")
  }
  self.steps += 1
  self.active.push(obligation)
  Ok(())
}

///| Read live solver facts without zonking or retaining rollback-local IDs.
fn BodyTraitSearch::type_key(
  self : BodyTraitSearch,
  solver : LocalTypeSolver,
  root : BodyTypeId,
) -> Result[Int, SolverInvariantFailure] {
  fn source(id : BodyTypeId) -> Result[BodyTypeId, SolverInvariantFailure] {
    let id = match solver.check_representative_type(id) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    match solver.type_term(id) {
      BodyResolvedType(type_) => solver.check_resolved_type_encoding(type_)
      _ => Ok(id)
    }
  }
  let root = match source(root) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let work = [(root, false)]
  let states : Map[Int, Int] = {}
  let values : Map[Int, Int] = {}
  let children : Map[Int, Array[Int]] = {}
  while work.length() > 0 {
    let (id, finish) = work.pop().unwrap()
    if finish {
      let fields = children.get(id).unwrap().map(child => values.get(child).unwrap())
      let node = match solver.type_term(id) {
        BodyErrorType => SearchError
        BodyVariableType(variable) => SearchVariable(variable)
        BodyProductType(_) => SearchProduct(fields)
        BodyAppliedType(_, _) => SearchApplied(fields[0], fields[1:].to_array())
        BodyFunctionType(_, _) => SearchFunction(fields[1:].to_array(), fields[0])
        BodyMemberTypeProjection(_, query, member) => SearchProjection(fields[0], query, member)
        BodyResolvedType(type_) => match solver.resolved.types[type_] {
          ErrorType => SearchError
          PrimitiveType(primitive) => SearchPrimitive(primitive.rank())
          GenericParameterType(parameter) => SearchParameter(parameter)
          NominalType(declaration) => SearchNominal(declaration)
          TraitType(declaration) => SearchTrait(declaration)
          SelfType(declaration) => SearchSelf(declaration)
          ProductType(_) => SearchProduct(fields)
          AppliedType(_, _) => SearchApplied(fields[0], fields[1:].to_array())
          FunctionType(_, _) => SearchFunction(fields[1:].to_array(), fields[0])
          MemberTypeProjection(_, query, member) => SearchProjection(fields[0], query, member)
        }
      }
      let key = match self.types.get(node) {
        Some(key) => key
        None => {
          let key = self.types.length()
          self.types[node] = key
          key
        }
      }
      values[id] = key
      states[id] = 2
      continue
    }
    match states.get(id) {
      Some(1) => return Err(solver.solver_failure(211, 0, id, root))
      Some(2) => continue
      _ => ()
    }
    states[id] = 1
    work.push((id, true))
    let (span, extra, resolved) = match solver.type_term(id) {
      BodyProductType(span) => (span, None, false)
      BodyAppliedType(base, span) => (span, Some(base), false)
      BodyFunctionType(span, result) => (span, Some(result), false)
      BodyMemberTypeProjection(owner, _, _) => ({ start: 0, length: 0 }, Some(owner), false)
      BodyResolvedType(type_) => match solver.resolved.types[type_] {
        ProductType(span) => (span, None, true)
        AppliedType(base, span) => (span, Some(base), true)
        FunctionType(span, result) => (span, Some(result), true)
        MemberTypeProjection(owner, _, _) => ({ start: 0, length: 0 }, Some(owner), true)
        _ => ({ start: 0, length: 0 }, None, true)
      }
      _ => ({ start: 0, length: 0 }, None, false)
    }
    let arena = if resolved { solver.resolved.type_arguments } else { solver.type_arguments }
    if !program_specialization_span_is_valid(span, arena.length()) {
      return Err(solver.solver_failure(101, arena.length(), span.start, span.length))
    }
    let raw = []
    if extra is Some(child) { raw.push(child) }
    for offset in 0..<span.length {
      raw.push(arena[span.start + offset])
    }
    let fields = []
    for child in raw {
      let child = if resolved {
        match solver.check_resolved_type_encoding(child) {
          Ok(value) => value
          Err(error) => return Err(error)
        }
      } else { child }
      match source(child) {
        Ok(value) => fields.push(value)
        Err(error) => return Err(error)
      }
    }
    children[id] = fields
    let mut offset = fields.length()
    while offset > 0 {
      offset -= 1
      work.push((fields[offset], false))
    }
  }
  Ok(values.get(root).unwrap())
}

///|
fn BasicBodyInferencer::enter_trait_search(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_ : DeclId,
  origin : TypeConstraintOrigin,
) -> Bool {
  let search = self.trait_search
  if search.active.is_empty() {
    search.types.clear()
    search.steps = 0
    search.failure = None
  }
  let target = match search.type_key(self.solver, target) {
    Ok(value) => value
    Err(error) => abort("trait search type invariant: " + @debug.to_string(error))
  }
  let bound = match search.type_key(self.solver, bound) {
    Ok(value) => value
    Err(error) => abort("trait search type invariant: " + @debug.to_string(error))
  }
  match search.admit(target, bound, trait_) {
    Err(message) => {
      if search.failure is None {
        search.failure = Some(message)
        let diagnostic = TraitObligationFailure(trait_, origin.source, message, origin.offset)
        if !self.diagnostics.contains(diagnostic) { self.diagnose(diagnostic) }
      }
      false
    }
    Ok(_) => true
  }
}

///|
fn BasicBodyInferencer::trait_obligation_satisfied(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_ : DeclId,
  origin : TypeConstraintOrigin,
) -> Bool {
  if !self.enter_trait_search(target, bound, trait_, origin) { return false }
  let saved = self.save_trait_candidate()
  let satisfied = self.trait_obligation_candidates(target, bound, trait_, origin)
  self.restore_trait_candidate(saved)
  ignore(self.trait_search.active.pop().unwrap())
  satisfied && self.trait_search.failure is None
}

///|
fn BasicBodyInferencer::select_trait_obligation_evidence_in_search(
  self : BasicBodyInferencer,
  target : BodyTypeId,
  bound : BodyTypeId,
  trait_ : DeclId,
  origin : TypeConstraintOrigin,
) -> Int? {
  if !self.enter_trait_search(target, bound, trait_, origin) { return None }
  let saved = self.save_trait_candidate()
  let evidence = self.trait_obligation_candidate_evidence(target, bound, trait_, origin)
  self.restore_trait_candidate(saved)
  ignore(self.trait_search.active.pop().unwrap())
  if self.trait_search.failure is None { evidence } else { None }
}
