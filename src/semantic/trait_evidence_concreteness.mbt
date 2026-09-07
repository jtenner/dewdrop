///|
priv enum TraitEvidenceConcreteWork {
  CheckConcreteEvidenceNode(Int)
  CheckConcreteEvidenceShape(PlannedValueShape, Int)
}

///|
/// Generic evidence is pending. Erroneous evidence is a diagnostic.
// Validate the whole graph first: an early generic or bound argument must not
// hide a malformed child or a cycle elsewhere in the evidence tree.
fn check_trait_evidence_concrete(
  source : TraitEvidenceKeySource,
  root : Int,
) -> Result[Bool, TraitEvidenceKeyFailure] {
  match check_trait_evidence_key_graph(source, root) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let work = [CheckConcreteEvidenceNode(root)]
  let seen : Map[Int, Bool] = {}
  let mut concrete = true
  let mut steps = 0
  fn room(
    current : Int,
    additional : Int,
  ) -> Result[Unit, TraitEvidenceKeyFailure] {
    if additional > 65536 - current {
      Err(source.failure(root, 213, 65536 - current, additional, 4))
    } else {
      Ok(())
    }
  }
  while work.length() > 0 {
    if steps >= 65536 {
      return Err(source.failure(root, 213, 65536, steps, 4))
    }
    steps += 1
    match work.pop().unwrap() {
      CheckConcreteEvidenceShape(shape, argument) =>
        match shape {
          GenericPlannedValueShape => concrete = false
          ErrorPlannedValueShape =>
            return Err(source.failure(root, 301, 1, 0, argument))
          ProductPlannedValueShape(fields) => {
            match room(work.length(), fields.length()) {
              Err(error) => return Err(error)
              Ok(_) => ()
            }
            let mut offset = fields.length()
            while offset > 0 {
              offset -= 1
              work.push(CheckConcreteEvidenceShape(fields[offset], argument))
            }
          }
          _ => ()
        }
      CheckConcreteEvidenceNode(index) => {
        if seen.contains(index) {
          continue
        }
        seen[index] = true
        let node = source.node(index)
        match node.kind {
          ConcreteKey(_) => ()
          _ => concrete = false
        }
        match room(work.length(), node.children.length) {
          Err(error) => return Err(error)
          Ok(_) => ()
        }
        let mut offset = node.children.length
        while offset > 0 {
          offset -= 1
          work.push(
            CheckConcreteEvidenceNode(
              source.children()[node.children.start + offset],
            ),
          )
        }
        match room(work.length(), node.arguments.length) {
          Err(error) => return Err(error)
          Ok(_) => ()
        }
        match room(steps, node.arguments.length) {
          Err(error) => return Err(error)
          Ok(_) => ()
        }
        steps += node.arguments.length
        let mut offset = node.arguments.length
        while offset > 0 {
          offset -= 1
          let argument = node.arguments.start + offset
          match source.argument(argument) {
            ShapeInferredTraitEvidenceArgument(shape) =>
              work.push(CheckConcreteEvidenceShape(shape, argument))
            GenericInferredTraitEvidenceArgument(parameter) => {
              if parameter < 0 {
                return Err(source.failure(root, 212, 0, parameter, argument))
              }
              concrete = false
            }
          }
        }
      }
    }
  }
  Ok(concrete)
}

///|
fn trait_evidence_concrete(
  lowering : PlannedModuleLowering,
  root : Int,
) -> Bool {
  match check_trait_evidence_concrete(LoweringEvidenceKey(lowering), root) {
    Ok(concrete) => concrete
    Err(error) =>
      abort("trait evidence concreteness invariant: " + @debug.to_string(error))
  }
}

///|
/// Bound evidence can be forwarded. Guarded evidence still needs a selection.
// Checking shapes as well as edges prevents a pending argument from hiding an
// erroneous sibling. Forwardability is not a concrete-carrier certificate.
fn check_trait_evidence_forwardable(
  source : TraitEvidenceKeySource,
  root : Int,
) -> Result[Bool, TraitEvidenceKeyFailure] {
  match check_trait_evidence_concrete(source, root) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let work = [root]
  let seen : Map[Int, Bool] = {}
  let mut forwardable = true
  while work.length() > 0 {
    let index = work.pop().unwrap()
    if seen.contains(index) {
      continue
    }
    seen[index] = true
    let node = source.node(index)
    match node.kind {
      GuardedKey(_, _) => forwardable = false
      _ => ()
    }
    // The complete checked walk above has already bounded this traversal.
    let mut offset = node.children.length
    while offset > 0 {
      offset -= 1
      work.push(source.children()[node.children.start + offset])
    }
  }
  Ok(forwardable)
}

///|
fn program_runtime_trait_evidence_is_forwardable(
  lowering : PlannedModuleLowering,
  root : Int,
) -> Bool {
  match check_trait_evidence_forwardable(LoweringEvidenceKey(lowering), root) {
    Ok(forwardable) => forwardable
    Err(error) =>
      abort("trait evidence forwarding invariant: " + @debug.to_string(error))
  }
}
