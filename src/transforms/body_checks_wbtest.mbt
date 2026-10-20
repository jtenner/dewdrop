///|
fn guarded_machine(enabled : Bool) -> Machine {
  let plan = prepare([
    {
      path: "app",
      files: [
        {
          path: "caller.dew",
          source: b"transform fn marker() -> I32 {\n 0i32\n}\nfn compute() -> I32 {\n 42i32\n}\n",
        },
        { path: "value.dew", source: b"let value = 42i32\n", },
      ],
    },
  ]).unwrap()
  {
    plan,
    steps: 100_000,
    depth: 0,
    allocated: 0,
    file_index: 0,
    frame: "",
    functions: {},
    imports: {},
    globals: {},
    initializing: {},
    text_storage: {},
    memory: None,
    render_source: DefaultValue,
    render_replacement: "",
    bytecode_enabled: enabled,
    bytecode: {},
    bytecode_compile_work: 1048576,
    bytecode_bytes_left: 8388608,
  }
}

///|
test "body check precedes cached tree or bytecode execution" {
  for enabled in [false, true] {
    let machine = guarded_machine(enabled)
    let function = machine.plan.files[0][0].functions[1].declaration
    assert_true(machine.source_body(0, function, []) is Number(42UL, "I32"))
    assert_true(
      machine.plan.add_body_error(
        0,
        "caller.dew",
        function.offset,
        "saved callable error",
      ),
    )
    let steps = machine.steps
    let allocated = machine.allocated
    let rejected = try {
      let _ = machine.source_body(0, function, [])
      false
    } catch {
      Failed(message) => {
        assert_true(message.contains("saved callable error"), msg=message)
        true
      }
      error => raise error
    }
    assert_true(rejected)
    assert_eq(machine.steps, steps)
    assert_eq(machine.allocated, allocated)
  }
}

///|
test "body check precedes cached global read in another file" {
  let machine = guarded_machine(true)
  let declaration = match machine.plan.files[0][1].declarations[0] {
    @parser.Let(value) => value
    _ => abort("missing global test declaration")
  }
  machine.globals["app::value"] = Number(42UL, "I32")
  assert_true(
    machine.plan.add_body_error(
      0,
      "value.dew",
      declaration.offset,
      "saved initializer error",
    ),
  )
  let rejected = try {
    let _ = machine.global_value(0, 1, declaration)
    false
  } catch {
    Failed(message) => {
      assert_true(message.contains("saved initializer error"), msg=message)
      true
    }
    error => raise error
  }
  assert_true(rejected)
  assert_eq(machine.file_index, 0)
}
