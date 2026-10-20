///|
test "source index keeps visibility shadow and overload errors" {
  let (machine, _) = bytecode_machine(
    "fn hidden() -> I32 {\n 1i32\n}\npub fn shown() -> I32 {\n 2i32\n}\n", false,
  )
  assert_eq(machine.local_member(0, "hidden", true), None)
  assert_eq(machine.local_member(0, "hidden", false), Some("app::hidden"))
  assert_eq(machine.local_member(0, "shown", true), Some("app::shown"))
  for
    (source, expected) in [
      (
        "fn same() -> I32 {\n 1i32\n}\nfn same(x: I32) -> I32 {\n x\n}\nlet same = 0i32\n",
        "overloaded compile-time names",
      ),
      (
        "let same = 0i32\nfn same() -> I32 {\n 1i32\n}\n", "unsupported compile-time declaration shadows name",
      ),
    ] {
    let (machine, _) = bytecode_machine(source, false)
    try {
      let _ = machine.local_member(0, "same", false)
      fail("invalid name must fail")
    } catch {
      Failed(message) => assert_true(message.contains(expected))
      error => raise error
    }
  }
}

///|
test "source index rebuilds after checked modules and retains query fees" {
  let (machine, _) = bytecode_machine(
    "import dependency as @d\nfn helper() -> Unit {}\n", false,
  )
  assert_eq(machine.module_index("app"), 0)
  machine.plan
  .add_checked_module({
    path: "dependency",
    files: [
      {
        path: "dependency.dew",
        source: b"pub fn value() -> I32 {\n 42i32\n}\n",
      },
    ],
  })
  .unwrap()
  for _ in 0..<2 {
    let before = machine.steps
    let allocation = machine.allocated
    assert_eq(machine.resolve(0, "value", Some("d")), "dependency::value")
    assert_eq(before - machine.steps, 3)
    assert_eq(machine.allocated - allocation, 48)
  }
}

///|
test "source index retains alias conflicts" {
  let (machine, _) = bytecode_machine(
    "import first as @d\nimport second as @d\nfn helper() -> Unit {}\n", false,
  )
  try {
    let _ = machine.resolve(0, "value", Some("d"))
    fail("ambiguous alias must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("ambiguous transform import alias"))
    error => raise error
  }
}

///|
test "bulk annotations keep checked helper guards and costs" {
  let source = StringBuilder::new()
  source.write_string("fn compute() -> I32 {\n 42i32\n}\n")
  for _ in 0..<600 {
    source.write_string("#marker\n")
  }
  source.write_string("fn annotated() -> I32 {\n 0i32\n}\n")
  let (machine, function) = bytecode_machine(source.to_string(), false)
  let before = machine.steps
  let allocation = machine.allocated
  assert_true(machine.source_call(0, 0, function, []) is Number(42UL, "I32"))
  assert_eq(before - machine.steps, 4)
  assert_eq(machine.allocated - allocation, 64)
  let annotated = machine.plan.files[0][0].functions[1].declaration
  try {
    let _ = machine.source_call(0, 0, annotated, [])
    fail("annotated helper must fail")
  } catch {
    Failed(message) =>
      assert_true(message.contains("annotated functions cannot execute"))
    error => raise error
  }
}
