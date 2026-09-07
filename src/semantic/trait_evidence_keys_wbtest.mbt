///|
test "evidence shape keys preserve scalar kind and nested field order" {
  let request = empty_program_trait_evidence_request()
  let shapes = [I32PlannedValueShape, U32PlannedValueShape, ProductPlannedValueShape([I32PlannedValueShape, ProductPlannedValueShape([I64PlannedValueShape, UnitPlannedValueShape])])]
  for index, shape in shapes {
    request.arguments.push(shape)
    request.evidence.push({ kind: PlannedConcreteTraitEvidence(7UL, { start: index, length: 1 }), prerequisites: { start: 0, length: 0 } })
  }
  let source = RequestEvidenceKey(request)
  assert_eq(check_trait_evidence_key(source, 0), Ok("i7[s4]{}"))
  assert_eq(check_trait_evidence_key(source, 1), Ok("i7[s8]{}"))
  assert_eq(check_trait_evidence_key(source, 2), Ok("i7[s18(4,18(5,1))]{}"))
}

///|
test "malformed recursive shape storage cannot publish a key" {
  let (_, lowering) = wasmgc_test_inputs(6034UL, b"")
  let fields : Array[PlannedValueShape] = [I32PlannedValueShape]
  let shape = ProductPlannedValueShape(fields)
  lowering.trait_evidence_arguments.push(ShapeInferredTraitEvidenceArgument(shape))
  lowering.trait_evidence.push({ kind: ConcreteInferredTraitEvidence(7UL, { start: 0, length: 1 }), prerequisites: { start: 0, length: 0 } })
  let source = LoweringEvidenceKey(lowering)
  assert_eq(check_trait_evidence_key(source, 0), Ok("i7[s18(4)]{}"))
  fields[0] = shape
  let failure = check_trait_evidence_key(source, 0)
  fields[0] = I32PlannedValueShape
  assert_eq(failure, Err({ code: 213, module_id: 6034UL, root: 0, expected: 2, actual: 1, detail: 3 }))
  assert_eq(check_trait_evidence_key(source, 0), Ok("i7[s18(4)]{}"))
}

///|
test "evidence keys reject exact cycle and owned-span mutations" {
  let (_, lowering) = wasmgc_test_inputs(6032UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 0)
  let source = LoweringEvidenceKey(lowering)
  assert_eq(check_trait_evidence_key(source, root), Ok("i1[]{}"))
  let original = lowering.trait_evidence[root]
  lowering.trait_evidence_children.push(root)
  lowering.trait_evidence[root] = { ..original, prerequisites: { start: 0, length: 1 } }
  assert_eq(check_trait_evidence_key(source, root), Err({ code: 211, module_id: 6032UL, root, expected: 0, actual: root, detail: 1 }))
  lowering.trait_evidence[root] = { ..original, prerequisites: { start: 1, length: 1 } }
  assert_eq(check_trait_evidence_key(source, root), Err({ code: 101, module_id: 6032UL, root, expected: 1, actual: 1, detail: 1 }))
  lowering.trait_evidence[root] = { ..original, kind: ConcreteInferredTraitEvidence(1UL, { start: 0, length: 1 }) }
  assert_eq(check_trait_evidence_key(source, root), Err({ code: 101, module_id: 6032UL, root, expected: 0, actual: 0, detail: 1 }))
  lowering.trait_evidence[root] = original
  assert_eq(check_trait_evidence_key(source, root), Ok("i1[]{}"))
  assert_eq(check_trait_evidence_key(source, 1), Err({ code: 104, module_id: 6032UL, root: 1, expected: 1, actual: 1, detail: 0 }))
}

///|
test "shared evidence is valid and expanded key limits are explicit" {
  let request = empty_program_trait_evidence_request()
  let mut root = key_test_request_chain(request, 1UL, 0)
  for _ in 0..<17 {
    let start = request.children.length()
    request.children.push(root)
    request.children.push(root)
    root = request.evidence.length()
    request.evidence.push({ kind: PlannedConcreteTraitEvidence(7UL, { start: 0, length: 0 }), prerequisites: { start, length: 2 } })
  }
  let source = RequestEvidenceKey(request)
  assert_eq(check_trait_evidence_key_graph(source, root), Ok(()))
  assert_true(check_trait_evidence_key(source, 2) is Ok(_))
  assert_eq(check_trait_evidence_key(source, root), Err({ code: 213, module_id: 0UL, root, expected: 65536, actual: 65536, detail: 2 }))
}

///|
test "runtime evidence cannot conceal prerequisite children" {
  let request = empty_program_trait_evidence_request()
  request.evidence.push({ kind: PlannedRuntimeTraitEvidence(make_semantic_id(6033UL, 1), 0), prerequisites: { start: 0, length: 0 } })
  let source = RequestEvidenceKey(request)
  assert_true(check_trait_evidence_key(source, 0) is Ok(_))
  request.children.push(0)
  request.evidence[0] = { ..request.evidence[0], prerequisites: { start: 0, length: 1 } }
  assert_eq(check_trait_evidence_key(source, 0), Err({ code: 212, module_id: 6033UL, root: 0, expected: 0, actual: 1, detail: 0 }))
}

///|
fn key_test_lowering_chain(lowering : PlannedModuleLowering, leaf : DeclId, depth : Int) -> Int {
  let empty = { start: 0, length: 0 }
  let mut root = lowering.trait_evidence.length()
  lowering.trait_evidence.push({ kind: ConcreteInferredTraitEvidence(leaf, empty), prerequisites: empty })
  for _ in 0..<depth {
    let start = lowering.trait_evidence_children.length()
    lowering.trait_evidence_children.push(root)
    root = lowering.trait_evidence.length()
    lowering.trait_evidence.push({ kind: ConcreteInferredTraitEvidence(7UL, empty), prerequisites: { start, length: 1 } })
  }
  root
}

///|
fn key_test_request_chain(request : ProgramTraitEvidenceRequest, leaf : DeclId, depth : Int) -> Int {
  let empty = { start: 0, length: 0 }
  let mut root = request.evidence.length()
  request.evidence.push({ kind: PlannedConcreteTraitEvidence(leaf, empty), prerequisites: empty })
  for _ in 0..<depth {
    let start = request.children.length()
    request.children.push(root)
    root = request.evidence.length()
    request.evidence.push({ kind: PlannedConcreteTraitEvidence(7UL, empty), prerequisites: { start, length: 1 } })
  }
  root
}

///|
test "deep lowering evidence retains the exact leaf identity" {
  let (_, lowering) = wasmgc_test_inputs(6030UL, b"")
  let first = key_test_lowering_chain(lowering, 1UL, 65)
  let second = key_test_lowering_chain(lowering, 2UL, 65)
  let same = key_test_lowering_chain(lowering, 1UL, 65)
  assert_eq(wasmgc_trait_evidence_key(lowering, first), wasmgc_trait_evidence_key(lowering, same))
  assert_true(wasmgc_trait_evidence_key(lowering, first) != wasmgc_trait_evidence_key(lowering, second))
}

///|
test "deep request evidence retains the exact leaf identity" {
  let request = empty_program_trait_evidence_request()
  let first = key_test_request_chain(request, 1UL, 65)
  let second = key_test_request_chain(request, 2UL, 65)
  let same = key_test_request_chain(request, 1UL, 65)
  assert_eq(program_trait_evidence_request_identity(request, first), program_trait_evidence_request_identity(request, same))
  assert_true(program_trait_evidence_request_identity(request, first) != program_trait_evidence_request_identity(request, second))
}

///|
test "lowering and request evidence keys include product field shapes" {
  let (_, lowering) = wasmgc_test_inputs(6031UL, b"")
  let request = empty_program_trait_evidence_request()
  let empty = { start: 0, length: 0 }
  let shapes = [ProductPlannedValueShape([I32PlannedValueShape, I64PlannedValueShape]), ProductPlannedValueShape([I64PlannedValueShape, I32PlannedValueShape])]
  for index, shape in shapes {
    lowering.trait_evidence_arguments.push(ShapeInferredTraitEvidenceArgument(shape))
    lowering.trait_evidence.push({ kind: ConcreteInferredTraitEvidence(7UL, { start: index, length: 1 }), prerequisites: empty })
    request.arguments.push(shape)
    request.evidence.push({ kind: PlannedConcreteTraitEvidence(7UL, { start: index, length: 1 }), prerequisites: empty })
  }
  assert_true(wasmgc_trait_evidence_key(lowering, 0) != wasmgc_trait_evidence_key(lowering, 1))
  assert_true(program_trait_evidence_request_identity(request, 0) != program_trait_evidence_request_identity(request, 1))
}
