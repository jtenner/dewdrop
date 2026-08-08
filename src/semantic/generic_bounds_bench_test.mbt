///|
fn generic_bound_calls_benchmark_source(
  call_count : Int,
  bounded : Bool,
) -> Bytes {
  let output = Buffer(size_hint=call_count * 32 + 256)
  output.write_string_utf8(
    "trait Marker {}\nstruct Item {}\nimpl Marker for Item {}\nfn keep<t",
  )
  if bounded {
    output.write_string_utf8(": Marker")
  }
  output.write_string_utf8(
    ">(value: t) -> t {\n  value\n}\nfn run(value: Item) -> Item {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = keep(value)\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
test "bench unbounded generic calls n=256" (it : @bench.T) {
  let collected = collect_bytes(
    2730UL,
    generic_bound_calls_benchmark_source(256, false),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench bounded generic calls n=256" (it : @bench.T) {
  let collected = collect_bytes(
    2731UL,
    generic_bound_calls_benchmark_source(256, true),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}
