///| Both sources use one checked structural identity format.
priv enum TraitEvidenceKeySource {
  LoweringEvidenceKey(PlannedModuleLowering)
  RequestEvidenceKey(ProgramTraitEvidenceRequest)
}

///|
priv enum TraitEvidenceKeyKind {
  ConcreteKey(DeclId)
  BoundKey(Int)
  GuardedKey(Int, Int)
  RuntimeKey(DeclId, Int)
}

///|
priv struct TraitEvidenceKeyNode {
  kind : TraitEvidenceKeyKind
  arguments : HirSpan
  children : HirSpan
}

///|
priv struct TraitEvidenceKeyFailure {
  code : Int
  module_id : ModuleId
  root : Int
  expected : Int
  actual : Int
  detail : Int
} derive(Eq, Debug)

///|
fn TraitEvidenceKeySource::count(self : TraitEvidenceKeySource) -> Int {
  match self {
    LoweringEvidenceKey(value) => value.trait_evidence.length()
    RequestEvidenceKey(value) => value.evidence.length()
  }
}

///| Caller checks the node index before this projection.
fn TraitEvidenceKeySource::node(self : TraitEvidenceKeySource, index : Int) -> TraitEvidenceKeyNode {
  let empty = { start: 0, length: 0 }
  match self {
    LoweringEvidenceKey(value) => {
      let node = value.trait_evidence[index]
      let (kind, arguments) = match node.kind {
        ConcreteInferredTraitEvidence(declaration, arguments) => (ConcreteKey(declaration), arguments)
        BoundInferredTraitEvidence(slot) => (BoundKey(slot), empty)
        GuardedInferredTraitEvidence(target, bound) => (GuardedKey(target, bound), empty)
      }
      { kind, arguments, children: node.prerequisites }
    }
    RequestEvidenceKey(value) => {
      let node = value.evidence[index]
      let (kind, arguments) = match node.kind {
        PlannedConcreteTraitEvidence(declaration, arguments) => (ConcreteKey(declaration), arguments)
        PlannedRuntimeTraitEvidence(declaration, parameter) => (RuntimeKey(declaration, parameter), empty)
      }
      { kind, arguments, children: node.prerequisites }
    }
  }
}

///|
fn TraitEvidenceKeySource::children(self : TraitEvidenceKeySource) -> Array[Int] {
  match self {
    LoweringEvidenceKey(value) => value.trait_evidence_children
    RequestEvidenceKey(value) => value.children
  }
}

///|
fn TraitEvidenceKeySource::argument_count(self : TraitEvidenceKeySource) -> Int {
  match self {
    LoweringEvidenceKey(value) => value.trait_evidence_arguments.length()
    RequestEvidenceKey(value) => value.arguments.length()
  }
}

///|
fn TraitEvidenceKeySource::argument(self : TraitEvidenceKeySource, index : Int) -> InferredTraitEvidenceArgument {
  match self {
    LoweringEvidenceKey(value) => value.trait_evidence_arguments[index]
    RequestEvidenceKey(value) => ShapeInferredTraitEvidenceArgument(value.arguments[index])
  }
}

///|
fn TraitEvidenceKeySource::failure(self : TraitEvidenceKeySource, root : Int, code : Int, expected : Int, actual : Int, detail : Int) -> TraitEvidenceKeyFailure {
  let module_id = match self {
    LoweringEvidenceKey(value) => value.module_id
    RequestEvidenceKey(_) => if root >= 0 && root < self.count() {
      match self.node(root).kind {
        ConcreteKey(declaration) | RuntimeKey(declaration, _) => semantic_id_module(declaration)
        _ => 0UL
      }
    } else { 0UL }
  }
  { code, module_id, root, expected, actual, detail }
}

///| Validate the whole graph before producing any usable key.
fn check_trait_evidence_key_graph(source : TraitEvidenceKeySource, root : Int) -> Result[Unit, TraitEvidenceKeyFailure] {
  let states : Map[Int, Int] = {}
  let work = [(root, false)]
  let children = source.children()
  while work.length() > 0 {
    let (index, finish) = work.pop().unwrap()
    if index < 0 || index >= source.count() {
      return Err(source.failure(root, 104, source.count(), index, 0))
    }
    if finish {
      states[index] = 2
      continue
    }
    match states.get(index) {
      Some(1) => return Err(source.failure(root, 211, 0, index, 1))
      Some(2) => continue
      _ => ()
    }
    if states.length() >= 65536 {
      return Err(source.failure(root, 213, 65536, states.length(), 1))
    }
    states[index] = 1
    work.push((index, true))
    let node = source.node(index)
    if !program_specialization_span_is_valid(node.arguments, source.argument_count()) {
      return Err(source.failure(root, 101, source.argument_count(), node.arguments.start, node.arguments.length))
    }
    if !program_specialization_span_is_valid(node.children, children.length()) {
      return Err(source.failure(root, 101, children.length(), node.children.start, node.children.length))
    }
    match node.kind {
      ConcreteKey(_) => ()
      _ => if node.children.length != 0 {
        return Err(source.failure(root, 212, 0, node.children.length, index))
      }
    }
    if node.children.length > 65536 - work.length() {
      return Err(source.failure(root, 213, 65536 - work.length(), node.children.length, 1))
    }
    let mut offset = node.children.length
    while offset > 0 {
      offset -= 1
      work.push((children[node.children.start + offset], false))
    }
  }
  Ok(())
}

///|
priv enum TraitEvidenceKeyWrite {
  WriteEvidenceKeyNode(Int)
  WriteEvidenceKeyArgument(Int)
  WriteEvidenceKeyShape(PlannedValueShape)
  WriteEvidenceKeyText(String)
}

///| Check growth before pushing a wide field list onto the work stack.
fn check_evidence_key_work_room(source : TraitEvidenceKeySource, root : Int, current : Int, items : Int, overhead : Int) -> Result[Unit, TraitEvidenceKeyFailure] {
  let remaining = 65536 - current
  if overhead > remaining || items > (remaining - overhead) / 2 {
    return Err(source.failure(root, 213, remaining, items, 3))
  }
  Ok(())
}

///| A resource limit reports an error; it never publishes a truncated key.
// Count serialization work as well as graph nodes: shared DAGs can otherwise
// expand to exponential tree text, and malformed shape objects can be cyclic.
fn check_trait_evidence_key(source : TraitEvidenceKeySource, root : Int) -> Result[String, TraitEvidenceKeyFailure] {
  match check_trait_evidence_key_graph(source, root) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let output = Buffer()
  let work = [WriteEvidenceKeyNode(root)]
  let mut steps = 0
  while work.length() > 0 {
    if steps >= 65536 {
      return Err(source.failure(root, 213, 65536, steps, 2))
    }
    steps += 1
    match work.pop().unwrap() {
      WriteEvidenceKeyText(value) => output.write_string_utf8(value)
      WriteEvidenceKeyShape(shape) => {
        output.write_string_utf8(wasmgc_trait_evidence_shape_code(shape).to_string())
        if shape is ProductPlannedValueShape(fields) {
          match check_evidence_key_work_room(source, root, work.length(), fields.length(), 1) {
            Err(error) => return Err(error)
            Ok(_) => ()
          }
          output.write_string_utf8("(")
          work.push(WriteEvidenceKeyText(")"))
          let mut offset = fields.length()
          while offset > 0 {
            offset -= 1
            work.push(WriteEvidenceKeyShape(fields[offset]))
            if offset > 0 { work.push(WriteEvidenceKeyText(",")) }
          }
        }
      }
      WriteEvidenceKeyArgument(index) => match source.argument(index) {
        ShapeInferredTraitEvidenceArgument(shape) => {
          output.write_string_utf8("s")
          work.push(WriteEvidenceKeyShape(shape))
        }
        GenericInferredTraitEvidenceArgument(parameter) => {
          output.write_string_utf8("g")
          output.write_string_utf8(parameter.to_string())
        }
      }
      WriteEvidenceKeyNode(index) => {
        let node = source.node(index)
        match node.kind {
          BoundKey(slot) => output.write_string_utf8("b\{slot}")
          GuardedKey(target, bound) => output.write_string_utf8("g\{target}:\{bound}")
          RuntimeKey(declaration, parameter) => output.write_string_utf8("r\{declaration}@\{parameter}")
          ConcreteKey(declaration) => {
            match check_evidence_key_work_room(source, root, work.length(), node.children.length, 2) {
              Err(error) => return Err(error)
              Ok(_) => ()
            }
            output.write_string_utf8("i\{declaration}[")
            work.push(WriteEvidenceKeyText("}"))
            let mut offset = node.children.length
            while offset > 0 {
              offset -= 1
              work.push(WriteEvidenceKeyNode(source.children()[node.children.start + offset]))
              if offset > 0 { work.push(WriteEvidenceKeyText(",")) }
            }
            work.push(WriteEvidenceKeyText("]{"))
            match check_evidence_key_work_room(source, root, work.length(), node.arguments.length, 0) {
              Err(error) => return Err(error)
              Ok(_) => ()
            }
            let mut offset = node.arguments.length
            while offset > 0 {
              offset -= 1
              work.push(WriteEvidenceKeyArgument(node.arguments.start + offset))
              if offset > 0 { work.push(WriteEvidenceKeyText(",")) }
            }
          }
        }
      }
    }
  }
  Ok(@utf8.decode_lossy(output.to_bytes()))
}

///|
fn trait_evidence_key(source : TraitEvidenceKeySource, root : Int) -> String {
  match check_trait_evidence_key(source, root) {
    Ok(key) => key
    Err(error) => abort("trait evidence key invariant: " + @debug.to_string(error))
  }
}
