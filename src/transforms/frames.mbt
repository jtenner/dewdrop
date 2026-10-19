///|
struct ExecutionFrame {
  scalar_proofs : Map[(Int32, Int32, Int32), Bytes]
  calls : Map[(Int32, Int32, Int32), CallTarget]
  references : Map[(Int32, Int32, Int32), FunctionReferenceProof]
  scalar_types : Map[(Int32, Int32, Int32), String]
}

///|
fn Plan::execution_frame(self : Plan, key : String) -> ExecutionFrame {
  self.frames.get_or_init(key, fn() {
    { scalar_proofs: {}, calls: {}, references: {}, scalar_types: {}, }
  })
}

///|
fn unframe_call(target : CallTarget?) -> (CallTarget?, String) {
  match target {
    Some(Framed(value, key)) => (Some(value), key)
    _ => (target, "")
  }
}

///|
fn Machine::call_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> CallTarget? {
  if self.plan.frames.get(self.frame) is Some(frame) &&
    frame.calls.get(site) is Some(value) {
    return Some(value)
  }
  self.plan.calls.get(site)
}

///|
fn Machine::reference_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> FunctionReferenceProof? {
  if self.plan.frames.get(self.frame) is Some(frame) &&
    frame.references.get(site) is Some(value) {
    return Some(value)
  }
  self.plan.references.get(site)
}

///|
fn Machine::has_reference_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> Bool {
  self.reference_proof(site) is Some(_)
}

///|
fn Machine::scalar_type_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> String? {
  if self.plan.frames.get(self.frame) is Some(frame) &&
    frame.scalar_types.get(site) is Some(value) {
    return Some(value)
  }
  self.plan.scalar_types.get(site)
}

///|
fn Plan::save_frame_call_proof(
  self : Plan,
  frame : String,
  site : (Int32, Int32, Int32),
  reference : Bool,
  target : CallTarget,
  identity : FunctionIdentity,
  target_frame : String,
) -> Unit {
  let target = if target_frame == "" {
    target
  } else {
    Framed(target, target_frame)
  }
  if frame == "" {
    self.save_call_proof(site, reference, target, identity)
    return
  }
  let proofs = self.execution_frame(frame)
  if reference {
    proofs.references[site] = { target, identity, }
  } else {
    proofs.calls[site] = target
  }
}

///|
fn Machine::scalar_operator_proof(
  self : Machine,
  site : (Int32, Int32, Int32),
) -> Bytes? {
  if self.plan.frames.get(self.frame) is Some(frame) &&
    frame.scalar_proofs.get(site) is Some(value) {
    return Some(value)
  }
  self.plan.scalar_proofs.get(site)
}
