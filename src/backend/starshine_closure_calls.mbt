///|
priv struct StarshineClosureCallPlan {
  expression : @semantic.ExprId
  direct_type : Int
  entry_type : Int
  erased_direct_type : Int
  erased_entry_type : Int
  closure_type : Int
  closure_local : Int
  result_shape : @semantic.PlannedValueShape
  result_local : Int
  result_cast_type : Int
  argument_casts : Array[Array[@lib.Instruction]]
}

///|
fn starshine_append_closure_pointer(
  output : Array[@lib.Instruction],
  plan : StarshineClosureCallPlan,
) -> Unit {
  output.push(
    @lib.Instruction::local_get(
      @lib.LocalIdx::new(plan.closure_local.reinterpret_as_uint()),
    ),
  )
  output.push(starshine_match_cast(plan.closure_type))
  output.push(
    @lib.Instruction::struct_get(
      @lib.TypeIdx::new(plan.closure_type.reinterpret_as_uint()),
      0U,
    ),
  )
}

///|
fn starshine_closure_call_branch(
  plan : StarshineClosureCallPlan,
  fragments : Array[Array[@lib.Instruction]],
  signature : Int,
  captured : Bool,
) -> Array[@lib.Instruction] {
  let output : Array[@lib.Instruction] = []
  if captured {
    output.push(
      @lib.Instruction::local_get(
        @lib.LocalIdx::new(plan.closure_local.reinterpret_as_uint()),
      ),
    )
  }
  // Each branch has the same logical schedule. Only the selected branch runs;
  // erased Unit arguments still run, and cannot add physical call operands.
  for index in 1..<fragments.length() {
    append_starshine_instructions(output, fragments[index])
    append_starshine_instructions(output, plan.argument_casts[index - 1])
  }
  starshine_append_closure_pointer(output, plan)
  output.push(starshine_match_cast(signature))
  output.push(
    @lib.Instruction::call_ref(
      @lib.TypeIdx::new(signature.reinterpret_as_uint()),
    ),
  )
  if plan.result_shape is @semantic.ProductPlannedValueShape(_) {
    starshine_append_product_local_sets(
      output,
      plan.result_local,
      plan.result_shape,
    )
  }
  output
}

///|
fn starshine_emit_closure_call(
  body : @semantic.BodyId,
  plan : StarshineClosureCallPlan,
  fragments : Array[Array[@lib.Instruction]],
) -> Result[Array[@lib.Instruction], StarshineCodeEmissionError] {
  if fragments.length() == 0 ||
    plan.argument_casts.length() != fragments.length() - 1 ||
    plan.closure_local < 0 ||
    plan.closure_type < 0 ||
    plan.direct_type < 0 ||
    plan.entry_type < 0 ||
    plan.erased_direct_type < 0 ||
    plan.erased_entry_type < 0 {
    return Err(UnsupportedExpression(body, plan.expression))
  }
  let product = plan.result_shape is @semantic.ProductPlannedValueShape(_)
  if product && plan.result_local < 0 {
    return Err(UnsupportedExpression(body, plan.expression))
  }
  let alternatives : Array[(Int, Bool)] = [(plan.direct_type, false)]
  if plan.erased_direct_type != plan.direct_type {
    alternatives.push((plan.erased_direct_type, false))
  }
  alternatives.push((plan.entry_type, true))
  if plan.erased_entry_type != plan.entry_type {
    alternatives.push((plan.erased_entry_type, true))
  }
  let (last_signature, last_captured) = alternatives.pop().unwrap()
  // The last branch still casts to its exact signature. An unrelated function
  // pointer is never accepted just because its values use reference carriers.
  let mut selected = starshine_closure_call_branch(
    plan, fragments, last_signature, last_captured,
  )
  while alternatives.length() > 0 {
    let (signature, captured) = alternatives.pop().unwrap()
    let branch = starshine_closure_call_branch(
      plan, fragments, signature, captured,
    )
    let condition : Array[@lib.Instruction] = []
    starshine_append_closure_pointer(condition, plan)
    condition.push(
      @lib.Instruction::ref_test(
        false,
        @lib.HeapType::new(@lib.TypeIdx::new(signature.reinterpret_as_uint())),
      ),
    )
    condition.push(
      @lib.Instruction::if_(
        if product {
          @lib.BlockType::void_()
        } else {
          starshine_block_type(plan.result_shape)
        },
        branch,
        Some(selected),
      ),
    )
    selected = condition
  }
  let output = fragments[0].copy()
  output.push(
    @lib.Instruction::local_set(
      @lib.LocalIdx::new(plan.closure_local.reinterpret_as_uint()),
    ),
  )
  append_starshine_instructions(output, selected)
  if product {
    starshine_append_product_local_gets(
      output,
      plan.result_local,
      plan.result_shape,
    )
  }
  if plan.result_cast_type >= 0 {
    output.push(starshine_match_cast(plan.result_cast_type))
  }
  Ok(output)
}
