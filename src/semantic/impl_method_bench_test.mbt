///|
fn bench_many_inherent_methods_source(method_count : Int) -> Bytes {
  let output = Buffer(size_hint=method_count * 96 + 160)
  output.write_string_utf8("struct Item {}\nimpl Item {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  fn method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("(self) -> I32 {\n    ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n")
  }
  output.write_string_utf8("}\nfn use(item: Item) -> I32 {\n")
  for index in 0..<method_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = item.method_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("()\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn bench_many_impl_buckets_source(implementation_count : Int) -> Bytes {
  let output = Buffer(size_hint=implementation_count * 144 + 96)
  for index in 0..<implementation_count {
    output.write_string_utf8("struct Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {}\nimpl Item")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" {\n  fn value(self) -> I32 {\n    ")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n}\n")
  }
  output.to_bytes()
}

///|
fn trait_method_calls_source(call_count : Int, generic : Bool) -> Bytes {
  let output = Buffer(size_hint=call_count * 48 + 256)
  if generic {
    output.write_string_utf8(
      "trait Read<t> {\n  fn read(self) -> t\n}\nstruct Box<a> {\n  value: a\n}\nimpl<a> Read<a> for Box<a> {\n  fn read(self) -> a {\n    self.value\n  }\n}\nfn use(value: Box<I32>) -> I32 {\n",
    )
  } else {
    output.write_string_utf8(
      "trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nfn use(value: Item) -> I32 {\n",
    )
  }
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value.read()\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn bounded_trait_method_calls_source(call_count : Int) -> Bytes {
  let output = Buffer(size_hint=call_count * 48 + 352)
  output.write_string_utf8(
    "trait Marker {}\ntrait Read<t> {\n  fn read(self) -> t\n}\nstruct Box<a> {\n  value: a\n}\nimpl Marker for I32 {}\nimpl<a: Marker> Read<a> for Box<a> {\n  fn read(self) -> a {\n    self.value\n  }\n}\nfn use(value: Box<I32>) -> I32 {\n",
  )
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(" = value.read()\n")
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn qualified_method_calls_source(call_count : Int, trait_ : Bool) -> Bytes {
  let output = Buffer(size_hint=call_count * 48 + 256)
  if trait_ {
    output.write_string_utf8(
      "trait Read {\n  fn read(self) -> I32\n}\nstruct Item {}\nimpl Read for Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nfn use(value: Item) -> I32 {\n",
    )
  } else {
    output.write_string_utf8(
      "struct Item {}\nimpl Item {\n  fn read(self) -> I32 {\n    1\n  }\n}\nfn use(value: Item) -> I32 {\n",
    )
  }
  for index in 0..<call_count {
    output.write_string_utf8("  let value_")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8(
      if trait_ {
        " = Read::read(value)\n"
      } else {
        " = Item::read(value)\n"
      },
    )
  }
  output.write_string_utf8("  value_0\n}\n")
  output.to_bytes()
}

///|
fn overlapping_impl_source(implementation_count : Int) -> Bytes {
  let output = Buffer(size_hint=implementation_count * 96 + 128)
  output.write_string_utf8(
    "trait Value {\n  fn value(self) -> I32\n}\nstruct Box<t> {}\n",
  )
  for index in 0..<implementation_count {
    output.write_string_utf8(
      "impl Value for Box<I32> {\n  fn value(self) -> I32 {\n    ",
    )
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("\n  }\n}\n")
  }
  output.to_bytes()
}

///|
test "bench impl index nominal buckets n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, bench_many_impl_buckets_source(512))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let index = build_module_impl_index(collected, resolved)
    it.keep(index.buckets.length())
  })
}

///|
test "bench impl index overlapping bucket n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, overlapping_impl_source(256))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let index = build_module_impl_index(collected, resolved)
    it.keep(index.diagnostics.length())
  })
}

///|
test "bench inherent method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, bench_many_inherent_methods_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench trait method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, trait_method_calls_source(256, false))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench generic trait method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, trait_method_calls_source(256, true))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_type_arguments.length())
  })
}

///|
test "bench bounded generic trait method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, bounded_trait_method_calls_source(256))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_type_arguments.length())
  })
}

///|
test "bench type-qualified method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, qualified_method_calls_source(256, false))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench trait-qualified method calls n=256" (it : @bench.T) {
  let collected = collect_bytes(1UL, qualified_method_calls_source(256, true))
  let resolved = resolve_module_types(collected)
  let names = resolve_module_names(collected)
  it.bench(fn() {
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}

///|
test "bench method full pipeline calls n=128" (it : @bench.T) {
  let source = trait_method_calls_source(128, true)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let names = resolve_module_names(collected)
    let inferred = infer_module_bodies(collected, resolved, names)
    it.keep(inferred.call_targets.length())
  })
}
