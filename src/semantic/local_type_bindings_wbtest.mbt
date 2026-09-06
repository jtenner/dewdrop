///|
test "local compile time type bindings keep lexical scope and lambda capture" {
  let (_, lowering) = compile_time_evidence_test(
    b"open dew.std.types\nstruct Box<t> {\n item: t\n}\nfn identity<t>(value: t) -> t {\n value\n}\npub fn main() -> I64 {\n type Item = field_type<Box<I64>>(\"item\")\n let read = fn(value: Item) -> Item {\n type Inner = Item\n identity::<Inner>(value)\n }\n if true {\n type Item = I32\n identity::<Item>(1i32)\n } else {\n 0i32\n }\n read(identity::<Item>(2i64))\n}\n",
  )
  assert_eq(lowering.modules[0].diagnostics, [])
  assert_eq(lowering.modules[0].lambdas.length(), 1)
  assert_eq(lowering.modules[0].lambdas[0].result_shape, I64PlannedValueShape)
}

///|
test "unused local compile time types still report type errors" {
  let collected = collect_bytes(
    24030UL, b"fn main() -> Unit {\n type Missing = UnknownType\n}\n",
  )
  assert_eq(collected.diagnostics, [])
  let resolved = resolve_module_types(collected)
  assert_true(resolved.diagnostics.length() > 0)
}
