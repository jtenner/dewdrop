///|
test "transforms call selected source methods and static methods" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Left {\n value: I32\n}\nstruct Right {\n value: I32\n}\nimpl Left {\n fn make(value: I32) -> Left {\n Left::{\n value: value\n }\n }\n fn answer(self) -> I32 {\n self.value + 2i32\n }\n}\nimpl Right {\n fn answer(self) -> I32 {\n self.value + 100i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let value = Left::make(40i32)\n node.with_body(@ast.integer(value.answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Ok(compiled) => {
      let module_ = compiled.program.modules[0]
      let mut found = false
      for fi, path in module_.file_paths {
        if path.has_prefix("main.dew::transform[main@") {
          found = true
          assert_eq(
            module_.file_sources[fi],
            b"pub fn main() -> I32 {\n42i32\n}",
          )
        }
      }
      assert_true(found)
    }
    Err(error) => fail(error.message())
  }
}

///|
test "transforms execute mutable aliases and captured callbacks" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Counter {\n mut value: I32\n}\nimpl Counter {\n fn increment(self) -> Unit {\n self.value = self.value + 1i32\n }\n}\nfn apply(callback: fn(I32) -> I32) -> I32 {\n callback(40i32)\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let counter = Counter::{\n value: 0i32\n }\n let alias = counter\n let callback = fn(value: I32) -> I32 {\n alias.increment()\n alias.increment()\n return value + counter.value\n }\n node.with_body(@ast.integer(apply(callback)))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transforms execute exact indexed-get source bodies" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Values {\n value: I32\n}\nimpl IndexedGet<U32, I32> for Values {\n fn indexed_get(self, index: U32) -> I32 {\n self.value\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let values = Values::{\n value: 42i32\n }\n node.with_body(@ast.integer(values[0u32]))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture collections" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.array\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let values = Array::new()\n  values.push(20i32)\n  values.push(21i32)\n  if values.length() != 2u32 || values.capacity() < 2u32 {\n    return node.with_body(@ast.integer(7i32))\n  }\n  let answer = match values.get(0u32) {\n    Some(value) => value + values[1u32]\n    None => 0i32\n  }\n  values.set(0u32, answer)\n  let last = match values.pop() {\n    Some(value) => value\n    None => 0i32\n  }\n  let literal = [values[0u32], last]\n  literal.clear()\n  let empty = match literal.pop() {\n    None => 1i32\n    Some(_) => 0i32\n  }\n  literal.push(answer + empty)\n  node.with_body(@ast.integer(literal[0u32]))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture casts" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nfn convert(callback: fn(U32) -> I32) -> I32 {\n  callback(0u32)\n}\n\nfn zero() -> I32 {\n  return wasm_array_get(wasm_array_new_default::<I32>(1u32), 0u32)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let cast = wasm_unsafe_bitcast(0u32)\n  let first = match cast {\n    0i32 => 40i32\n    _ => 0i32\n  }\n  let second = match convert(wasm_unsafe_bitcast) {\n    0i32 => 1i32\n    _ => 0i32\n  }\n  let third = match wasm_array_get(wasm_array_new_default::<I32>(1u32), 0u32) {\n    0i32 => 1i32\n    _ => 0i32\n  }\n  let flag = !wasm_array_get(wasm_array_new_default::<Bool>(1u32), 0u32)\n  node.with_body(@ast.integer(if flag { \n    first + second + third + zero()\n  } else {\n    0i32\n  }))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture raw_arrays" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let values = wasm_array_new::<I32>(3u32, 0i32)\n  wasm_array_set(values, 0u32, 40i32)\n  wasm_array_set(values, 1u32, 2i32)\n  wasm_array_copy(values, 1u32, values, 0u32, 2u32)\n  let answer = wasm_array_get(values, 1u32) + wasm_array_get(values, 2u32)\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture wrappers" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nfn finish(value: I32) -> I32 {\n  value + 1i32\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.prepend(@ast.unit()).wrap(@ast.path(\"finish\"))\n}\n\n#replace\npub fn main() -> I32 {\n  41i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture builders" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let items = @ast.array([@ast.integer(40i32), @ast.integer(2i32)])\n  let first = @ast.name(\"items\").index(@ast.source(\"0u32\"))\n  let second = @ast.name(\"items\").index(@ast.source(\"1u32\"))\n  let body = @ast.block([\n    items.bind(\"items\"),\n    @ast.integer(0i32).bind_mut(\"answer\"),\n    @ast.name(\"answer\").assign(first.binary(\"+\", second)),\n    @ast.name(\"answer\").returned(),\n  ])\n  node.with_body(body)\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture methods" {
  let source = b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nstruct Counter {\n  mut value: I32\n}\n\nimpl Counter {\n  fn new(value: I32) -> Counter {\n    Counter::{\n      value: value\n    }\n  }\n  fn add(self, amount: I32) -> Unit {\n    self.value = self.value + amount\n  }\n  fn answer(self) -> I32 {\n    self.value\n  }\n}\n\nfn twice(value: I32) -> I32 {\n  value * 2i32\n}\n\nfn apply(value: I32, callback: fn(I32) -> I32) -> I32 {\n  callback(value)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let counter = Counter::new(apply(10i32, twice))\n  let alias = counter\n  alias.add(20i32)\n  let mut extra = 1i32\n  let callback = fn(value: I32) -> I32 {\n    extra = extra + 1i32\n    return value + extra\n  }\n  node.with_body(@ast.integer(apply(counter.answer(), callback)))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n"
  match compile_transform_source(source) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_paths.any(fn(path) {
          path.contains("::transform[main@")
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transforms reject raw array bounds" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(wasm_array_get(wasm_array_new_default::<I32>(1u32), 1u32)))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("array index out of bounds"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid transform must fail")
  }
}

///|
test "transforms reject raw array allocation" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let values = wasm_array_new_default::<I32>(4294967295u32)\n node.with_body(@ast.integer(wasm_array_get(values, 0u32)))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("allocation limit exceeded"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid transform must fail")
  }
}

///|
test "transforms reject invalid field builder" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.name(\"value\").field(\"x) + 1\"))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("invalid generated field name"),
        msg=error.message(),
      )
    Ok(_) => fail("invalid transform must fail")
  }
}

///|
test "transform source fixture syntax" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nstruct Answer {\n  value: I32\n}\n\nimpl Answer {\n  fn new(value: I32) -> Answer {\n    Answer::{\n      value: value\n    }\n  }\n  fn plus(self, extra: I32) -> I32 {\n    self.value + extra\n  }\n}\n\ntransform fn empty(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.append(@ast.unit())\n}\n\n#empty\nfn prepare() -> Unit {\n  ()\n}\n\ntransform fn returning(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.returning(@ast.integer(2i32))\n}\n\n#returning\nfn extra() -> I32 {\n  0i32\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let signed = @ast.integer64(-1i64)\n  let unsigned = @ast.unsigned64(18446744073709551615u64)\n  node.with_body(@ast.block([\n    @ast.name(\"prepare\").call([]),\n    @ast.path(\"Answer::new\").call([@ast.integer(40i32)]).bind(\"answer\"),\n    @ast.name(\"answer\").field(\"value\").bind(\"original\"),\n    @ast.tuple([signed, unsigned]).bind(\"wide\"),\n    @ast.prefix(\"!\", @ast.boolean(false)).bind(\"ready\"),\n    @ast.text(\"source transform\").bind(\"label\"),\n    @ast.name(\"answer\").method_call(\"plus\", [@ast.name(\"extra\").call([])]).returned(),\n  ]))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "transform function value returns a callback" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nfn make() -> fn(I32) -> I32 {\n  fn(value: I32) -> I32 {\n    value + 1i32\n  }\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let factory = make\n  let callback = factory()\n  node.with_body(@ast.integer(callback(41i32)))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture evaluation" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nstruct Counter {\n  mut value: I32\n}\n\nimpl Counter {\n  fn receiver(self) -> Counter {\n    self.value = self.value + 1i32\n    self\n  }\n  fn tick(self) -> I32 {\n    self.value = self.value + 1i32\n    self.value\n  }\n  fn combine(self, left: I32, right: I32) -> I32 {\n    self.value * 100i32 + left * 10i32 + right\n  }\n}\n\nfn identity<t>(value: t) -> t {\n  value\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let counter = identity(Counter::{\n    value: 0i32\n  })\n  let answer = counter.receiver().combine(counter.tick(), counter.tick())\n  let count = match counter {\n    Counter {\n      value: value\n    } => value\n  }\n  node.with_body(@ast.integer(if answer == 323i32 && count == 3i32 {\n    42i32\n  } else {\n    7i32\n  }))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture operators" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nstruct Value {\n  value: I32\n}\n\ntrait Add {\n  fn add(self, other: Self) -> I32\n}\n\nimpl Add for Value {\n  fn add(self, other: Value) -> I32 {\n    77i32\n  }\n}\n\nimpl IndexedGet<U32, I32> for Value {\n  fn indexed_get(self, index: U32) -> I32 {\n    42i32\n  }\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let left = Value::{\n    value: 1i32\n  }\n  let right = Value::{\n    value: 41i32\n  }\n  let selected = left + right\n  node.with_body(@ast.integer(if selected == 77i32 {\n    left[0u32]\n  } else {\n    7i32\n  }))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform source fixture flow" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nfn keep(value: I32) -> I32 {\n  value\n}\n\nfn early() -> I32 {\n  keep(return 42i32)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(early()))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transforms keep checked generic types and raw array defaults" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nfn keep<Bool>(value: Bool) -> Bool {\n  value\n}\n\nfn first<t>(values: WasmArray<t>) -> Option<t> {\n  Some(wasm_array_get(values, 0u32))\n}\n\nfn make<t>() -> WasmArray<t> {\n  wasm_array_new_default::<t>(1u32)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let values = make::<I32>()\n  let answer = match first(values) {\n    Some(0i32) => keep(42i32)\n    _ => 7i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "generic raw defaults survive enum payloads and checked scalar uses" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nfn first_default<t>() -> Option<t> {\n  let values = wasm_array_new_default::<t>(1u32)\n  Some(wasm_array_get(values, 0u32))\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let first = match first_default::<I32>() {\n    Some(0i32) => 40i32\n    _ => 0i32\n  }\n  let value = match first_default::<I32>() {\n    Some(value) => value\n    None => 1i32\n  }\n  let flag = match first_default::<Bool>() {\n    Some(value) => !value\n    None => false\n  }\n  let wide = match first_default::<I64>() {\n    Some(value) => value\n    None => 1i64\n  }\n  let unsigned = match first_default::<U64>() {\n    Some(value) => value\n    None => 1u64\n  }\n  let signed = -value\n  let sum = value + value\n  node.with_body(@ast.block([\n    @ast.integer(value).bind(\"zero\"),\n    @ast.integer64(wide).bind(\"wide\"),\n    @ast.unsigned64(unsigned).bind(\"unsigned\"),\n    @ast.integer(first + signed + sum + if flag {\n      2i32\n    } else {\n      0i32\n    }),\n  ]))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "untyped defaults cannot use integer negation for floats" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nfn first<t>() -> Option<t> {\n Some(wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32))\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let value = match first::<F32>() {\n Some(value) => value\n None => 1.0f32\n }\n node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("unsupported scalar type"),
        msg=error.message(),
      )
    Ok(_) => fail("float negation is not supported by the interpreter")
  }
}

///|
test "float bitcasts cannot execute as integer values" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let value = wasm_unsafe_bitcast::<I32, F32>(1065353216i32)\n node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("unsupported scalar type"),
        msg=error.message(),
      )
    Ok(_) => fail("float values must not use integer execution")
  }
}

///|
test "generic boxed floats keep their checked prefix type" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nfn boxed_cast<a, b>(value: a) -> Option<b> {\n  Some(wasm_unsafe_bitcast::<a, b>(value))\n}\ntransform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let value = match boxed_cast::<I32, F32>(1065353216i32) {\n    Some(value) => value\n    None => 0.0f32\n  }\n  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(-value)))\n}\n#wrong\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("unsupported scalar type"),
        msg=error.message(),
      )
    Ok(_) => fail("boxed float must not use integer prefix execution")
  }
}

///|
test "generic scalar values retain checked types in records tuples and patterns" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nstruct Box<t> {\n  value: t\n}\n\nfn boxed_record<a, b>(value: a) -> Box<b> {\n  Box::{\n    value: wasm_unsafe_bitcast::<a, b>(value)\n  }\n}\n\nfn boxed_option<a, b>(value: a) -> Option<b> {\n  Some(wasm_unsafe_bitcast::<a, b>(value))\n}\n\nfn boxed_tuple<a, b>(value: a) -> (b, Bool) {\n  (wasm_unsafe_bitcast::<a, b>(value), true)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let first = match boxed_option::<U32, I32>(0u32) {\n    Some(0i32) => 2i32\n    _ => 0i32\n  }\n  let data = boxed_record::<U32, I32>(40u32)\n  let (tuple_value, tuple_flag) = boxed_tuple::<U32, I32>(0u32)\n  let flag = match boxed_option::<U32, Bool>(1u32) {\n    Some(value) => value\n    None => false\n  }\n  node.with_body(@ast.integer(if flag && tuple_flag {\n    data.value + tuple_value + first\n  } else {\n    0i32\n  }))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "generic float fields cannot execute integer binary operations" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nstruct Box<t> {\n  value: t\n}\nfn boxed<a, b>(value: a) -> Box<b> {\n  Box::{\n    value: wasm_unsafe_bitcast::<a, b>(value)\n  }\n}\ntransform fn wrong(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let data = boxed::<I32, F32>(1065353216i32)\n  node.with_body(@ast.integer(wasm_unsafe_bitcast::<F32, I32>(data.value + data.value)))\n}\n#wrong\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Err(error) =>
      assert_true(
        error.message().contains("unsupported scalar type"),
        msg=error.message(),
      )
    Ok(_) => fail("float fields must not use integer execution")
  }
}
