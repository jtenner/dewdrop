///|
test "deep concrete evidence does not become non-concrete after depth 64" {
  let (_, lowering) = wasmgc_test_inputs(6035UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 65)
  assert_true(trait_evidence_concrete(lowering, root))
  assert_true(program_runtime_trait_evidence_is_forwardable(lowering, root))
}

///|
test "pending evidence does not hide an erroneous sibling shape" {
  let (_, lowering) = wasmgc_test_inputs(6036UL, b"")
  lowering.trait_evidence_arguments.push(
    ShapeInferredTraitEvidenceArgument(GenericPlannedValueShape),
  )
  lowering.trait_evidence_arguments.push(
    ShapeInferredTraitEvidenceArgument(
      ProductPlannedValueShape([I64PlannedValueShape, ErrorPlannedValueShape]),
    ),
  )
  lowering.trait_evidence.push({
    kind: ConcreteInferredTraitEvidence(1UL, { start: 0, length: 2, }),
    prerequisites: { start: 0, length: 0, },
  })
  let source = LoweringEvidenceKey(lowering)
  let expected : Result[Bool, TraitEvidenceKeyFailure] = Err({
    code: 301,
    module_id: 6036UL,
    root: 0,
    expected: 1,
    actual: 0,
    detail: 1,
  })
  assert_eq(check_trait_evidence_concrete(source, 0), expected)
  assert_eq(check_trait_evidence_forwardable(source, 0), expected)
  lowering.trait_evidence_arguments[1] = ShapeInferredTraitEvidenceArgument(
    I64PlannedValueShape,
  )
  assert_eq(check_trait_evidence_concrete(source, 0), Ok(false))
  assert_eq(check_trait_evidence_forwardable(source, 0), Ok(true))
  lowering.trait_evidence_arguments[0] = GenericInferredTraitEvidenceArgument(
    -1,
  )
  assert_eq(
    check_trait_evidence_concrete(source, 0),
    Err({
      code: 212,
      module_id: 6036UL,
      root: 0,
      expected: 0,
      actual: -1,
      detail: 0,
    }),
  )
  lowering.trait_evidence_arguments[0] = GenericInferredTraitEvidenceArgument(0)
  assert_eq(check_trait_evidence_concrete(source, 0), Ok(false))
}

///|
test "pending evidence does not hide a later graph cycle" {
  let (_, lowering) = wasmgc_test_inputs(6037UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 1)
  lowering.trait_evidence[0] = {
    kind: BoundInferredTraitEvidence(0),
    prerequisites: { start: 0, length: 0, },
  }
  let source = LoweringEvidenceKey(lowering)
  assert_eq(check_trait_evidence_concrete(source, root), Ok(false))
  assert_eq(check_trait_evidence_forwardable(source, root), Ok(true))
  lowering.trait_evidence_children.push(root)
  lowering.trait_evidence[root] = {
    ..lowering.trait_evidence[root],
    prerequisites: { start: 0, length: 2, },
  }
  let expected : Result[Bool, TraitEvidenceKeyFailure] = Err({
    code: 211,
    module_id: 6037UL,
    root,
    expected: 0,
    actual: root,
    detail: 1,
  })
  assert_eq(check_trait_evidence_concrete(source, root), expected)
  assert_eq(check_trait_evidence_forwardable(source, root), expected)
  lowering.trait_evidence[root] = {
    ..lowering.trait_evidence[root],
    prerequisites: { start: 0, length: 1, },
  }
  lowering.trait_evidence[0] = {
    kind: GuardedInferredTraitEvidence(0, 0),
    prerequisites: { start: 0, length: 0, },
  }
  assert_eq(check_trait_evidence_forwardable(source, root), Ok(false))
}

///|
test "concrete evidence checks each shared node without expanding the tree" {
  let request = empty_program_trait_evidence_request()
  let mut root = key_test_request_chain(request, 1UL, 0)
  for _ in 0..<100 {
    let start = request.children.length()
    request.children.push(root)
    request.children.push(root)
    root = request.evidence.length()
    request.evidence.push({
      kind: PlannedConcreteTraitEvidence(7UL, { start: 0, length: 0, }),
      prerequisites: { start, length: 2, },
    })
  }
  assert_eq(
    check_trait_evidence_concrete(RequestEvidenceKey(request), root),
    Ok(true),
  )
}

///|
test "recursive shape checks report the resource record and recover" {
  let (_, lowering) = wasmgc_test_inputs(6038UL, b"")
  let fields : Array[PlannedValueShape] = [I32PlannedValueShape]
  let shape = ProductPlannedValueShape(fields)
  lowering.trait_evidence_arguments.push(
    ShapeInferredTraitEvidenceArgument(shape),
  )
  lowering.trait_evidence.push({
    kind: ConcreteInferredTraitEvidence(7UL, { start: 0, length: 1, }),
    prerequisites: { start: 0, length: 0, },
  })
  let source = LoweringEvidenceKey(lowering)
  assert_eq(check_trait_evidence_concrete(source, 0), Ok(true))
  fields[0] = shape
  let failure = check_trait_evidence_concrete(source, 0)
  fields[0] = I32PlannedValueShape
  assert_eq(
    failure,
    Err({
      code: 213,
      module_id: 6038UL,
      root: 0,
      expected: 65536,
      actual: 65536,
      detail: 4,
    }),
  )
  assert_eq(check_trait_evidence_concrete(source, 0), Ok(true))
}

///|
test "evidence predicates report exact missing roots and invalid owned spans" {
  let (_, lowering) = wasmgc_test_inputs(6039UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 0)
  let source = LoweringEvidenceKey(lowering)
  assert_eq(check_trait_evidence_concrete(source, root), Ok(true))
  assert_eq(
    check_trait_evidence_concrete(source, 1),
    Err({
      code: 104,
      module_id: 6039UL,
      root: 1,
      expected: 1,
      actual: 1,
      detail: 0,
    }),
  )
  let original = lowering.trait_evidence[root]
  lowering.trait_evidence[root] = {
    ..original,
    prerequisites: { start: 0, length: 1, },
  }
  assert_eq(
    check_trait_evidence_concrete(source, root),
    Err({
      code: 101,
      module_id: 6039UL,
      root,
      expected: 0,
      actual: 0,
      detail: 1,
    }),
  )
  lowering.trait_evidence[root] = original
  assert_eq(check_trait_evidence_concrete(source, root), Ok(true))
}

///|
test "deep runtime evidence retains direct and captured classifications" {
  let (_, lowering) = wasmgc_test_inputs(6040UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 100)
  let classes = [ProgramExternalDirectRuntimeEvidence]
  assert_eq(
    check_external_runtime_evidence_class(lowering, root, classes),
    Ok(Some(ProgramExternalConcreteEvidence)),
  )
  lowering.trait_evidence[0] = {
    kind: BoundInferredTraitEvidence(0),
    prerequisites: { start: 0, length: 0, },
  }
  assert_eq(
    check_external_runtime_evidence_class(lowering, 0, classes),
    Ok(Some(ProgramExternalDirectRuntimeEvidence)),
  )
  assert_eq(
    check_external_runtime_evidence_class(lowering, root, classes),
    Ok(Some(ProgramExternalCapturedRuntimeEvidence)),
  )
  lowering.trait_evidence[0] = {
    kind: BoundInferredTraitEvidence(1),
    prerequisites: { start: 0, length: 0, },
  }
  assert_eq(
    check_external_runtime_evidence_class(lowering, root, classes),
    Err({
      code: 212,
      module_id: 6040UL,
      root,
      expected: 1,
      actual: 1,
      detail: 0,
    }),
  )
  lowering.trait_evidence[0] = {
    kind: GuardedInferredTraitEvidence(0, 0),
    prerequisites: { start: 0, length: 0, },
  }
  assert_eq(
    check_external_runtime_evidence_class(lowering, root, classes),
    Ok(None),
  )
}

///|
test "bound guarded and runtime evidence cannot forward negative slots" {
  let (_, lowering) = wasmgc_test_inputs(6041UL, b"")
  let root = key_test_lowering_chain(lowering, 1UL, 0)
  let source = LoweringEvidenceKey(lowering)
  for
    kind in [
      BoundInferredTraitEvidence(-1),
      GuardedInferredTraitEvidence(-1, 0),
      GuardedInferredTraitEvidence(0, -1),
    ] {
    lowering.trait_evidence[root] = {
      kind,
      prerequisites: { start: 0, length: 0, },
    }
    let expected : Result[Bool, TraitEvidenceKeyFailure] = Err({
      code: 212,
      module_id: 6041UL,
      root,
      expected: 0,
      actual: -1,
      detail: root,
    })
    assert_eq(check_trait_evidence_concrete(source, root), expected)
    assert_eq(check_trait_evidence_forwardable(source, root), expected)
  }
  let request = empty_program_trait_evidence_request()
  request.evidence.push({
    kind: PlannedRuntimeTraitEvidence(make_semantic_id(6041UL, 0), -1),
    prerequisites: { start: 0, length: 0, },
  })
  assert_eq(
    check_trait_evidence_concrete(RequestEvidenceKey(request), 0),
    Err({
      code: 212,
      module_id: 6041UL,
      root: 0,
      expected: 0,
      actual: -1,
      detail: 0,
    }),
  )
}
