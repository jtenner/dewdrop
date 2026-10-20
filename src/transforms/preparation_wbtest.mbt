///|
test "annotation preparation keeps byte positions spans and transform markers" {
  let source = "// λ🧪\r\n\n\t#first\n  #second\n// kept gap\npub fn sample() -> Unit {\n}\nfn ordinary() -> Unit {\n}\npub transform fn marked() -> Unit {\n}\ntransform fn other() -> Unit {\n}\n"
  let file = match
    scan({ path: "positions.dew", source: bytes(source), }, 0, 0) {
    Ok(file) => file
    Err(error) => {
      fail(error)
      abort("invalid fixture")
    }
  }
  assert_eq(file.annotations.length(), 2)
  assert_eq(file.annotations[0].line_no, 3UL)
  assert_eq(file.annotations[0].col_no, 2UL)
  assert_eq(file.annotations[1].line_no, 4UL)
  assert_eq(file.annotations[1].col_no, 3UL)
  assert_eq(file.functions.length(), 4)
  assert_eq(file.functions[0].annotation_start, 0)
  assert_eq(file.functions[0].annotation_count, 2)
  assert_eq(file.functions[1].annotation_count, 0)
  assert_false(file.functions[0].transform)
  assert_false(file.functions[1].transform)
  assert_true(file.functions[2].transform)
  assert_true(file.functions[3].transform)
  for function in file.functions {
    let old = file.annotations.filter(a => {
      a.target >= function.start &&
      a.target < function.declaration.name_offset.to_int()
    })
    assert_eq(function.annotation_count, old.length())
    for i in 0..<old.length() {
      assert_eq(
        file.annotations[function.annotation_start + i].offset,
        old[i].offset,
      )
    }
  }
}

///|
test "fresh name index keeps raw substring and digit prefix semantics" {
  let names : Map[String, Int32] = {}
  index_fresh_names(
    b"// __dew_transform_12345___\n\"__dew_transform_12_\" __dew_transform_12345_ __dew_transform_01__ __dew_transform___dew_transform_7__ __dew_transform_8___dew_transform_9_ __dew_transform_42949672950__",
    names,
  )
  assert_eq(names.get("__dew_transform_1"), Some(0))
  assert_eq(names.get("__dew_transform_12"), Some(1))
  assert_eq(names.get("__dew_transform_12345"), Some(3))
  assert_eq(names.get("__dew_transform_01"), Some(2))
  assert_eq(names.get("__dew_transform_7"), Some(2))
  assert_eq(names.get("__dew_transform_8"), Some(3))
  assert_eq(names.get("__dew_transform_9"), Some(1))
  assert_eq(names.get("__dew_transform_4294967295"), Some(0))
  assert_eq(names.get("__dew_transform_42949672950"), None)
}

///|
test "fresh name charges each collision before final output" {
  let (machine, _) = bytecode_machine(
    "// __dew_transform_12___\nfn compute() -> Unit {\n}\n", false,
  )
  assert_eq(machine.fresh_name(0, 12U), "__dew_transform_12____")
  assert_eq(100000 - machine.steps, 4)
  assert_eq(machine.allocated, 64)
  assert_eq(machine.fresh_name(0, 99U), "__dew_transform_99")
  assert_eq(100000 - machine.steps, 4)
  machine.steps = 2
  machine.allocated = 0
  try {
    let _ = machine.fresh_name(0, 12U)
    fail("exhausted fresh name must fail")
  } catch {
    Failed(message) => assert_eq(message, "transform work limit exceeded")
    error => raise error
  }
  assert_eq(machine.steps, 0)
  assert_eq(machine.allocated, 32)
}

///|
test "preparation index keeps first cold target and transform set" {
  let (machine, _) = bytecode_machine(
    "fn compute() -> I32 {\n 42i32\n}\nfn compute() -> I32 {\n 7i32\n}\n#marker\nfn annotated() -> Unit {\n}\n",
    false,
  )
  let index = machine.plan.source_index()
  assert_true(index.transforms.contains("app::marker"))
  assert_false(index.transforms.contains("app::compute"))
  assert_eq(raw_bits(machine.call("app::compute", [])), 42UL)
  try {
    let _ = machine.call("app::annotated", [])
    fail("cold annotated target must fail")
  } catch {
    Failed(message) => assert_true(message.contains("annotated"))
    error => raise error
  }
}

///|
test "long fresh suffix fails within the work bound" {
  let (machine, _) = bytecode_machine(
    "// __dew_transform_12" +
    "_".repeat(65536) +
    "\nfn compute() -> Unit {\n}\n",
    false,
  )
  machine.steps = 2
  try {
    let _ = machine.fresh_name(0, 12U)
    fail("long collision must exhaust work")
  } catch {
    Failed(message) => assert_eq(message, "transform work limit exceeded")
    error => raise error
  }
  assert_eq(machine.steps, 0)
  assert_eq(machine.allocated, 32)
}

///|
test "annotation roots reject only their own saved body errors" {
  for selected in [false, true] {
    let annotation = if selected { "broken" } else { "good" }
    let plan = fixture(
      "transform fn broken() -> I32 {\n 0i32\n}\ntransform fn good() -> I32 {\n 0i32\n}\n#" +
      annotation +
      "\nfn answer() -> I32 {\n 0i32\n}\n",
    )
    assert_true(
      plan.add_body_error(
        0,
        "main.dew",
        plan.files[0][0].functions[0].declaration.offset,
        "specific saved source error",
      ),
    )
    match plan.annotation_entries() {
      Err(message) => {
        assert_true(selected, msg=message)
        assert_true(
          message.contains("compile-time helper failed source checking"),
          msg=message,
        )
        assert_true(
          message.contains("specific saved source error"),
          msg=message,
        )
      }
      Ok(entries) => {
        assert_false(
          selected,
          msg="invalid selected transform body was accepted",
        )
        assert_eq(entries, [(0, "good")])
      }
    }
  }
}
