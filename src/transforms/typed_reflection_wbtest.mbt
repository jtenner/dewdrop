///|
test "type reflection creates fresh mutable argument arrays" {
  let machine = builder_machine()
  let type_ : ReflectedType = {
    kind: "tuple",
    name: "",
    arguments: [{ kind: "named", name: "I32", arguments: [], }],
  }
  let first = machine.reflected_type(type_, 0)
  let arguments = machine.sequence_values(field(first, "arguments"))
  arguments[0] = Unit
  let second = machine.reflected_type(type_, 0)
  assert_eq(
    string(
      field(machine.sequence_values(field(second, "arguments"))[0], "name"),
    ),
    "I32",
  )
}

///|
test "shared nested type prototypes stop at visible resource limits" {
  let machine = builder_machine()
  let mut type_ : ReflectedType = { kind: "named", name: "I32", arguments: [], }
  for _ in 0..<60 {
    type_ = { kind: "function", name: "", arguments: [type_, type_], }
  }
  try {
    let _ = machine.reflected_type(type_, 0)
    fail("a shared type graph must not bypass VM resource limits")
  } catch {
    Failed(message) =>
      assert_true(message.contains("limit exceeded"), msg=message)
    _ => fail("expected visible type reflection resource limit")
  }
}
