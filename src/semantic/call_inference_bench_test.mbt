///|
fn call_bench_functions(
  prefix : String,
  function_count : Int,
  body : String,
  return_type : String,
) -> Bytes {
  let output = Buffer(size_hint=function_count * (body.length() + 64))
  for index in 0..<function_count {
    output.write_string_utf8("fn ")
    output.write_string_utf8(prefix)
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(value: I32) -> ")
    output.write_string_utf8(return_type)
    output.write_string_utf8(" {\n  ")
    output.write_string_utf8(body)
    output.write_string_utf8("\n}\n")
  }
  output.to_bytes()
}

///|
fn direct_call_bench_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 80 + 64)
  output.write_string_utf8("fn identity(value: I32) -> I32 {\n  value\n}\n")
  output.write_bytes(
    call_bench_functions("direct_", function_count, "identity(value)", "I32"),
  )
  output.to_bytes()
}

///|
fn generic_call_bench_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 80 + 64)
  output.write_string_utf8("fn identity<t>(value: t) -> t {\n  value\n}\n")
  output.write_bytes(
    call_bench_functions("generic_", function_count, "identity(value)", "I32"),
  )
  output.to_bytes()
}

///|
fn overload_call_bench_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 80 + 160)
  output.write_string_utf8(
    "builtin convert(value: I32) -> I64 = \"i32_to_i64\"\n",
  )
  output.write_string_utf8(
    "builtin convert(value: F32) -> F64 = \"f32_to_f64\"\n",
  )
  output.write_bytes(
    call_bench_functions("overload_", function_count, "convert(value)", "I64"),
  )
  output.to_bytes()
}

///|
fn wide_overload_call_bench_source(
  generic_candidate_count : Int,
  function_count : Int,
) -> Bytes {
  let output = Buffer(
    size_hint=function_count * 80 + generic_candidate_count * 160,
  )
  for candidate in 1..<=generic_candidate_count {
    output.write_string_utf8("builtin choose<")
    for generic in 0..<candidate {
      if generic > 0 {
        output.write_string_utf8(", ")
      }
      output.write_string_utf8("t")
      output.write_string_utf8(generic.to_string())
    }
    output.write_string_utf8(">(value: t0) -> t0 = \"generic_")
    output.write_string_utf8(candidate.to_string())
    output.write_string_utf8("\"\n")
  }
  output.write_string_utf8(
    "builtin choose(value: I32) -> I32 = \"exact_i32\"\n",
  )
  output.write_bytes(
    call_bench_functions("wide_", function_count, "choose(value)", "I32"),
  )
  output.to_bytes()
}

///|
fn nested_overload_call_bench_source(function_count : Int) -> Bytes {
  let output = Buffer(size_hint=function_count * 96 + 256)
  output.write_string_utf8(
    "builtin convert(value: I32) -> I64 = \"i32_to_i64\"\n",
  )
  output.write_string_utf8(
    "builtin convert(value: F32) -> F64 = \"f32_to_f64\"\n",
  )
  output.write_string_utf8("builtin wrap(value: I64) -> Bool = \"wrap_i64\"\n")
  output.write_string_utf8("builtin wrap(value: F64) -> Bool = \"wrap_f64\"\n")
  output.write_bytes(
    call_bench_functions(
      "nested_", function_count, "wrap(convert(value))", "Bool",
    ),
  )
  output.to_bytes()
}

///|
fn infer_call_bench_module(collected : CollectedModule) -> InferredModuleBodies {
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  infer_module_bodies(collected, resolved, names)
}

///|
test "bench call inference direct functions n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, direct_call_bench_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench call inference generic functions n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, generic_call_bench_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_type_arguments.length())
  })
}

///|
test "bench call inference overload pairs n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, overload_call_bench_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench call inference wide overload candidates=17 calls=256" (
  it : @bench.T,
) {
  let collected = collect_bytes(1UL, wide_overload_call_bench_source(16, 256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench call inference nested overload worklist n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, nested_overload_call_bench_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench call inference generic full pipeline n=256" (it : @bench.T) {
  let source = generic_call_bench_source(256)
  it.bench(fn() {
    let inferred = infer_call_bench_module(collect_bytes(1UL, source))
    it.keep(inferred.call_type_arguments.length())
  })
}
