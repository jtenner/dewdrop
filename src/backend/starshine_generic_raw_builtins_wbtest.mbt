///|
test "generic raw reference equality has direct and outlined checked instances" {
  let stages = backend_test_single_module_stages(
    28261UL, b"struct Left {\n  value: I32\n}\nstruct Right {\n  value: I64\n}\nbuiltin same<a, b>(left: a, right: b) -> Bool = \"ref.eq\"\npub fn direct(left: Left, right: Right) -> Bool {\n  same(left, right)\n}\npub fn callback() -> fn(Left, Right) -> Bool {\n  same\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_true(stages.link.materialized_specialization_count() > 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "generic numeric builtins use the exact raw instruction catalog" {
  let stages = backend_test_single_module_stages(
    28262UL, b"builtin plus<t>(left: t, right: t) -> t = \"i32.add\"\npub fn main() -> I32 {\n  plus(20i32, 22i32)\n}\n",
  )
  assert_eq(stages.diagnostic_count(), 0)
  assert_eq(stages.link.imported_function_count, 0)
  assert_eq(@validate.validate_module(stages.emit_module()), Ok(()))
}

///|
test "generic raw builtins reject scalar references counts and wrong results" {
  for
    (source, expected) in [
      (
        b"builtin same<a, b>(left: a, right: b) -> Bool = \"ref.eq\"\npub fn main() -> Bool {\n  same(1i32, 2i32)\n}\n",
        b"ref.eq",
      ),
      (
        b"builtin same<a, b>(left: a, right: b) -> Bool = \"ref.eq\"\npub fn main(value: String) -> Bool {\n  same(value, 2i64)\n}\n",
        b"ref.eq",
      ),
      (
        b"builtin same<a, b>(left: a, right: b) -> I64 = \"ref.eq\"\npub fn main(left: String, right: Bytes) -> I64 {\n  same(left, right)\n}\n",
        b"ref.eq",
      ),
      (
        b"builtin same<t>(value: t) -> Bool = \"ref.eq\"\npub fn main(value: String) -> Bool {\n  same(value)\n}\n",
        b"ref.eq",
      ),
      (
        b"builtin plus<t>(left: t, right: t) -> t = \"i32.add\"\npub fn main() -> I64 {\n  plus(20i64, 22i64)\n}\n",
        b"i32.add",
      ),
    ] {
    let stages = backend_test_single_module_stages(28263UL, source)
    assert_eq(stages.diagnostic_count(), 0)
    match emit_starshine_program_module(stages.lowering, stages.link) {
      Err(InvalidBuiltinSignature(name, _, _)) => assert_eq(name, expected)
      other =>
        fail(
          "generic raw instruction accepted an invalid concrete signature: " +
          @debug.to_string(other),
        )
    }
  }
}
