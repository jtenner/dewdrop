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

///|
fn generic_bound_body_operator_benchmark_source(
  operator_count : Int,
  symbolic : Bool,
) -> Bytes {
  let output = Buffer(size_hint=operator_count * 40 + 512)
  output.write_string_utf8(
    "trait Eq {\n  fn eq(self, right: Self) -> Bool\n}\nstruct Item {}\nimpl Eq for Item {\n  fn eq(self, right: Item) -> Bool {\n    true\n  }\n}\nfn compare",
  )
  if symbolic {
    output.write_string_utf8("<t: Eq>(left: t, right: t)")
  } else {
    output.write_string_utf8("(left: Item, right: Item)")
  }
  output.write_string_utf8(" -> Bool {\n")
  for index in 0..<operator_count {
    output.write_string_utf8("  let result_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = left == right\n")
  }
  output.write_string_utf8("  result_0\n}\n")
  output.to_bytes()
}

///|
test "bench concrete generic-bound body operators n=256" (it : @bench.T) {
  let collected = collect_bytes(
    2732UL,
    generic_bound_body_operator_benchmark_source(256, false),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.operator_targets.length())
  })
}

///|
test "bench symbolic generic-bound body operators n=256" (it : @bench.T) {
  let collected = collect_bytes(
    2733UL,
    generic_bound_body_operator_benchmark_source(256, true),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.operator_targets.length())
  })
}

///|
fn recursive_generic_evidence_benchmark_source(call_count : Int) -> Bytes {
  let output = Buffer(size_hint=call_count * 36 + 512)
  output.write_string_utf8(
    "trait Marker {}\ntrait Value {}\nstruct Yes {}\nstruct Box<t> {\n  value: t\n}\nimpl Marker for Yes {}\nimpl<t: Marker> Value for Box<t> {}\nfn require<t: Value>(value: t) -> t {\n  value\n}\nfn run(value: Box<Yes>) -> Box<Yes> {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = require(value)\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
test "bench recursive generic evidence trees n=256" (it : @bench.T) {
  let collected = collect_bytes(
    2734UL,
    recursive_generic_evidence_benchmark_source(256),
  )
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.trait_evidence.length())
  })
}
