///|
test "signature adapters avoid names of local bindings" {
  let machine = builder_machine()
  let plan = prepare([
    {
      path: "app",
      files: [
        {
          path: "main.dew",
          source: b"transform fn marker() -> I32 {\n 0i32\n}\n#marker\nfn answer() -> I32 {\n 42i32\n}\n",
        },
      ],
    },
  ]).unwrap()
  let function = plan.files[0][0].functions[1]
  let occupied = "__dew_transform_adapter_0_" +
    function.start.to_string() +
    "_0"
  // Include the collision in another function's local scope in the same module.
  let source = bytes(
    "transform fn marker() -> I32 {\n 0i32\n}\n#marker\nfn answer() -> I32 {\n 42i32\n}\nfn other() -> I32 {\n let " +
    occupied +
    " = 0i32\n 0i32\n}\n",
  )
  let plan = prepare([{ path: "app", files: [{ path: "main.dew", source, }], }]).unwrap()
  let function = plan.files[0][0].functions[1]
  let machine = { ..machine, plan, }
  let name = machine.adapter_name(function)
  assert_eq(name, occupied[:occupied.length() - 1].to_string() + "1")
}

///|
test "signature call repair bounds total inserted names before output" {
  let calls = StringBuilder::new()
  calls.write_string(
    "transform fn marker() -> I32 {\n 0i32\n}\n#marker\nfn answer() -> I32 {\n 42i32\n}\nfn main() -> I32 {\n",
  )
  let offsets = []
  let start = bytes(calls.to_string()).length()
  for index in 0..<1025 {
    offsets.push(start + index * 9)
    calls.write_string("answer()\n")
  }
  calls.write_string("42i32\n}\n")
  let plan = prepare([
    {
      path: "app",
      files: [{ path: "main.dew", source: bytes(calls.to_string()), }],
    },
  ]).unwrap()
  let target = plan.files[0][0].functions[1].declaration.offset
  for offset in offsets {
    plan.add_signature_call(
      0,
      "main.dew",
      offset.to_uint64(),
      0,
      "main.dew",
      target,
    )
  }
  let bridge = "x".repeat(1024)
  let rejected = try {
    let _ = plan.source_repairs(Map::from_array([((0, 0, target), bridge)]))
    false
  } catch {
    Failed(message) => {
      assert_eq(message, "generated call repair size limit exceeded")
      true
    }
    error => raise error
  }
  assert_true(rejected)
}

///|
test "signature repair keeps range edges and excludes neighboring repairs" {
  assert_eq(
    repaired_part(b"abcdef", 1, 5, [
      { start: 0, end: 1, name: "left", },
      { start: 2, end: 3, name: "X", },
      { start: 4, end: 5, name: "Y", },
      { start: 5, end: 6, name: "right", },
    ]),
    "bXdY",
  )
  assert_eq(repaired_part(b"abcdef", 3, 3, []), "")
}
