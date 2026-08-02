///|
fn object_bench_module(
  source : Bytes,
) -> (CollectedModule, ResolvedModuleTypes, ResolvedModuleNames) {
  let collected = collect_bytes(1UL, source)
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  (collected, resolved, names)
}

///|
fn wide_object_bench_source(field_count : Int) -> Bytes {
  let output = Buffer(size_hint=field_count * 48 + 128)
  output.write_string_utf8("struct Wide {\n")
  for index in 0..<field_count {
    output.write_string_utf8("  field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": I32\n")
  }
  output.write_string_utf8("}\nfn make() -> Wide {\n  Wide {\n")
  for index in 0..<field_count {
    output.write_string_utf8("    field_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(": ")
    output.write_string_utf8(index.to_string())
    output.write_byte(b'\n')
  }
  output.write_string_utf8("  }\n}\n")
  output.to_bytes()
}

///|
fn nested_object_bench_source(depth : Int, fields : Bool) -> Bytes {
  let output = Buffer(size_hint=depth * 64 + 256)
  output.write_string_utf8("struct Node0 {\n  value: I32\n}\n")
  for index in 1..<=depth {
    output.write_string_utf8("struct Node")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  next: Node")
    output.write_string_utf8((index - 1).to_string())
    output.write_string_utf8("\n}\n")
  }
  if fields {
    output.write_string_utf8("fn read(value: Node")
    output.write_string_utf8(depth.to_string())
    output.write_string_utf8(") -> I32 {\n  value")
    for _ in 0..<depth {
      output.write_string_utf8(".next")
    }
    output.write_string_utf8(".value\n}\n")
  } else {
    output.write_string_utf8("fn make() -> Node")
    output.write_string_utf8(depth.to_string())
    output.write_string_utf8(" {\n")
    for _ in 0..<depth {
      output.write_string_utf8("  {\n    next: ")
    }
    output.write_string_utf8("{\n  value: 1\n}")
    for _ in 0..<depth {
      output.write_string_utf8("\n  }\n")
    }
    output.write_string_utf8("}\n")
  }
  output.to_bytes()
}

///|
fn tuple_variant_bench_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 72 + 96)
  output.write_string_utf8("enum Maybe<t> {\n  None\n  Some(t)\n}\n")
  for index in 0..<function_count {
    output.write_string_utf8("fn make_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      "(value: I32) -> Maybe<I32> {\n  Maybe::Some(value)\n}\n",
    )
  }
  output.to_bytes()
}

///|
fn object_overload_bench_source(call_count : Int) -> Bytes {
  let output = Buffer(size_hint=call_count * 64 + 192)
  output.write_string_utf8(
    "struct Point {\n  x: I32\n}\nbuiltin choose(value: I32) -> Bool = \"number\"\nbuiltin choose(value: Point) -> Bool = \"point\"\nfn use() -> Bool {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = choose({\n    x: ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  })\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
test "bench construction fields n=128" (it : @bench.T) {
  let (collected, resolved, names) = object_bench_module(
    wide_object_bench_source(128),
  )
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.object_field_targets.length())
  })
}

///|
test "bench nested expected objects depth=256" (it : @bench.T) {
  let (collected, resolved, names) = object_bench_module(
    nested_object_bench_source(256, false),
  )
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_selections.length())
  })
}

///|
test "bench field access chain depth=512" (it : @bench.T) {
  let (collected, resolved, names) = object_bench_module(
    nested_object_bench_source(512, true),
  )
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_selections.length())
  })
}

///|
test "bench tuple variant construction functions n=256" (it : @bench.T) {
  let (collected, resolved, names) = object_bench_module(
    tuple_variant_bench_source(256),
  )
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.expression_type_arguments.length())
  })
}

///|
test "bench object overload calls n=256" (it : @bench.T) {
  let (collected, resolved, names) = object_bench_module(
    object_overload_bench_source(256),
  )
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_type_arguments.length())
  })
}

///|
test "bench construction full pipeline fields n=128" (it : @bench.T) {
  let source = wide_object_bench_source(128)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.object_field_targets.length())
  })
}
