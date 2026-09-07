///|
test "specialized call replay checks declaration ABI and hidden operands" {
  let calls : Array[PlannedProgramSpecializedCall] = []
  let evidence : Array[Int] = []
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i32",
      [2, 3],
    ),
    Ok(()),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i32",
      [2, 3],
    ),
    Ok(()),
  )
  assert_eq(calls.length(), 1)
  assert_eq(evidence, [2, 3])
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      29UL,
      "i32",
      [2, 3],
    ),
    Err(
      "SPC-303 body=17 caller=caller expression=19 expected=23:i32 actual=29:i32",
    ),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i64",
      [2, 3],
    ),
    Err(
      "SPC-303 body=17 caller=caller expression=19 expected=23:i32 actual=23:i64",
    ),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i32",
      [2],
    ),
    Err(
      "SPC-303 body=17 caller=caller expression=19 expected evidence count=2 actual=1",
    ),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i32",
      [3, 2],
    ),
    Err(
      "SPC-303 body=17 caller=caller expression=19 evidence=0 expected=2 actual=3",
    ),
  )
  assert_eq(calls.length(), 1)
  assert_eq(evidence, [2, 3])
  // Every part of the source key matters.
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      18UL,
      "caller",
      19,
      29UL,
      "i64",
      [],
    ),
    Ok(()),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "other",
      19,
      29UL,
      "i64",
      [],
    ),
    Ok(()),
  )
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      20,
      29UL,
      "i64",
      [],
    ),
    Ok(()),
  )
  assert_eq(calls.length(), 4)
}

///|
test "specialized call replay checks its owned evidence span" {
  let calls : Array[PlannedProgramSpecializedCall] = []
  let evidence : Array[Int] = []
  record_program_specialized_call(
    calls,
    evidence,
    17UL,
    "caller",
    19,
    23UL,
    "i32",
    [2, 3],
  )
  calls[0] = {
    ..calls[0],
    runtime_evidence_parameters: { start: 1, length: 2, },
  }
  assert_eq(
    try_record_program_specialized_call(
      calls,
      evidence,
      17UL,
      "caller",
      19,
      23UL,
      "i32",
      [2, 3],
    ),
    Err("ARN-101 body=17 caller=caller expression=19 evidence span=1:2 arena=2"),
  )
}
