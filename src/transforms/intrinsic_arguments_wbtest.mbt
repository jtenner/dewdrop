///|
test "intrinsic arguments flatten only explicit product parameters" {
  let left = Number(40UL, "I32")
  let right = Number(2UL, "I32")
  let tuple = Sequence([left, right])
  let mut builtin = None
  for event in @parser.parse_bytes(b"builtin sample<t>(pair: (I32, I32), generic: t) -> I32 = \"i32.add\"\n") {
    if event is @parser.Declaration(@parser.Builtin(value)) {
      builtin = Some(value)
    }
  }
  guard builtin is Some(builtin) else { fail("builtin fixture must parse") }
  let output = []
  append_intrinsic_argument(output, builtin.parameters[0].type_, tuple)
  assert_eq(output.length(), 2)
  assert_eq(raw_bits(output[0]), 40UL)
  assert_eq(raw_bits(output[1]), 2UL)
  let generic = []
  append_intrinsic_argument(generic, builtin.parameters[1].type_, tuple)
  assert_eq(generic.length(), 1)
  assert_true(physical_equal(generic[0], tuple))
}
