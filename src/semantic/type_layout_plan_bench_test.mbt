///|
fn layout_structs_source(count : Int) -> Bytes {
  let output = Buffer(size_hint=count * 96)
  for index in 0..<count {
    output.write_string_utf8("struct Struct")
    output.write_string_utf8(index.to_string())
    output.write_string_utf8("<t> {\n  value: t\n  count: I64\n}\n")
  }
  output.to_bytes()
}

///|
fn layout_enum_source(variant_count : Int) -> Bytes {
  let output = Buffer(size_hint=variant_count * 32 + 64)
  output.write_string_utf8("enum Wide<t> {\n")
  for index in 0..<variant_count {
    output.write_string_utf8("  Variant")
    output.write_string_utf8(index.to_string())
    if index % 3 == 1 {
      output.write_string_utf8("(t, I64)")
    } else if index % 3 == 2 {
      output.write_string_utf8(" {\n    value: t\n    flag: Bool\n  }")
    }
    output.write_string_utf8("\n")
  }
  output.write_string_utf8("}\n")
  output.to_bytes()
}

///|
test "bench type layouts structs n=512" (it : @bench.T) {
  let collected = collect_bytes(1UL, layout_structs_source(512))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let layouts = plan_module_type_layouts(collected, resolved)
    it.keep(layouts.fields.length())
  })
}

///|
test "bench type layouts enum variants n=1024" (it : @bench.T) {
  let collected = collect_bytes(1UL, layout_enum_source(1024))
  let resolved = resolve_module_types(collected)
  it.bench(fn() {
    let layouts = plan_module_type_layouts(collected, resolved)
    it.keep(layouts.variants.length())
  })
}

///|
test "bench type layouts full pipeline structs n=256" (it : @bench.T) {
  let source = layout_structs_source(256)
  it.bench(fn() {
    let collected = collect_bytes(1UL, source)
    let resolved = resolve_module_types(collected)
    let layouts = plan_module_type_layouts(collected, resolved)
    it.keep(layouts.layouts.length())
  })
}
