///|
test "dynamic transform traits preserve aliases and checked generic erasure" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Answer {\n\n  fn answer(self) -> I32\n\n}\nstruct Counter {\n\n  mut value: I32\n\n}\nimpl Answer for Counter {\n\n  fn answer(self) -> I32 {\n\n    self.value = self.value + 1i32\n    self.value\n  \n}\n\n}\nimpl Answer for I32 {\n\n  fn answer(self) -> I32 {\n\n    self + 2i32\n  \n}\n\n}\nfn read(value: Answer) -> I32 {\n\n  value.answer()\n\n}\nfn erase<t: Answer>(value: t) -> Answer {\n\n  value\n\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n\n  let counter = Counter::{\n\n    value: 18i32\n  \n}\n  let first = read(counter)\n  let erased = erase(counter)\n  let second = read(erased)\n  let third = read(20i32)\n  node.with_body(@ast.integer(if first == 19i32 && second == 20i32 && counter.value == 20i32 && third == 22i32 {\n\n    42i32\n  \n} else {\n\n    0i32\n  \n}))\n\n}\n#calculate\npub fn main() -> I32 {\n\n  0i32\n\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform traits preserve slot and argument order" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Pair {\n\n  fn first(self, amount: I32) -> I32\n  fn second(self, amount: I32) -> I32\n\n}\nstruct Counter {\n mut value: I32 \n}\nimpl Pair for Counter {\n\n  fn first(self, amount: I32) -> I32 {\n self.value = self.value + amount\n self.value \n}\n  fn second(self, amount: I32) -> I32 {\n self.value = self.value - amount\n self.value \n}\n\n}\nfn view(counter: Counter) -> Pair {\n counter.value = counter.value + 1i32\n counter \n}\nfn amount(counter: Counter) -> I32 {\n counter.value = counter.value * 2i32\n 2i32 \n}\nfn alias(value: Pair) -> Pair {\n  value\n}\nfn calculate_value(counter: Counter) -> I32 {\n\n  let a = view(counter).first(amount(counter))\n  let b = alias(counter)\n  let c = b.second(2i32)\n  if a == 42i32 && c == 40i32 && counter.value == 40i32 {\n 42i32 \n} else {\n 0i32 \n}\n\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n\n  node.with_body(@ast.integer(calculate_value(Counter::{\n value: 19i32 \n})))\n\n}\n#calculate\npub fn main() -> I32 {\n\n  0i32\n\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform traits survive explicit return branch and closure capture" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Answer {\n fn answer(self) -> I32 \n}\nimpl Answer for I32 {\n fn answer(self) -> I32 {\n self \n} \n}\nfn erase(value: I32, choose: Bool) -> Answer {\n\n  if choose {\n return value \n}\n  value + 1i32\n\n}\nfn callback(value: Answer) -> fn() -> I32 {\n fn() -> I32 {\n value.answer() \n} \n}\nfn result() -> I32 {\n\n  let first = callback(erase(20i32, true))\n  let second = callback(erase(21i32, false))\n  first() + second()\n\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n\n  node.with_body(@ast.integer(result()))\n\n}\n#calculate\npub fn main() -> I32 {\n\n  0i32\n\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform traits retain generic implementation prerequisites" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Answer {\n fn answer(self) -> I32 \n}\nimpl Answer for I32 {\n fn answer(self) -> I32 {\n self \n} \n}\nstruct Box<t> {\n value: t \n}\nimpl<t: Answer> Answer for Box<t> {\n fn answer(self) -> I32 {\n self.value.answer() \n} \n}\nfn read(value: Answer) -> I32 {\n value.answer() \n}\nfn erase<t: Answer>(value: t) -> Answer {\n value \n}\nfn result() -> I32 {\n read(erase(Box::{\n value: 42i32 \n})) \n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n\n  node.with_body(@ast.integer(result()))\n\n}\n#calculate\npub fn main() -> I32 {\n\n  0i32\n\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform traits reject generic methods" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Bad {\n fn answer<t>(self, value: t) -> I32 \n}\nimpl Bad for I32 {\n fn answer<t>(self, value: t) -> I32 {\n self \n} \n}\nfn read(value: Bad) -> I32 {\n value.answer(1i32) \n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(read(42i32))) \n}\n#calculate\npub fn main() -> I32 {\n 0i32 \n}\n",
    ) {
    Ok(_) => fail("unsafe dynamic method must fail checking")
    Err(error) =>
      assert_true(
        error.message().contains("NoMatchingMethod"),
        msg=error.message(),
      )
  }
}

///|
test "dynamic transform traits reject Self result" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntrait Bad {\n fn answer(self) -> Self \n}\nimpl Bad for I32 {\n fn answer(self) -> I32 {\n self \n} \n}\nfn read(value: Bad) -> I32 {\n let _ = value.answer()\n 42i32 \n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(read(42i32))) \n}\n#calculate\npub fn main() -> I32 {\n 0i32 \n}\n",
    ) {
    Ok(_) => fail("unsafe dynamic method must fail checking")
    Err(error) =>
      assert_true(
        error.message().contains("NoMatchingMethod"),
        msg=error.message(),
      )
  }
}

///|
test "dynamic transform traits retain imported implementation and prerequisite identities" {
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new(
        "main.dew", b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport traits.helper as @helper\nfn read(value: @helper.Answer) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(@helper.value())))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
      ),
    ]),
    @semantic.ManifestModule::new("traits.helper", [
      @semantic.ManifestFile::new(
        "helper.dew", b"pub trait Answer {\n  fn answer(self) -> I32\n}\npub struct Box<t> {\n  value: t\n}\nimpl Answer for I32 {\n  fn answer(self) -> I32 {\n    self\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    self.value.answer()\n  }\n}\npub fn erase<t: Answer>(value: t) -> Answer {\n  value\n}\npub fn value() -> Answer {\n  erase(Box::{\n    value: 42i32\n  })\n}\n",
      ),
    ]),
  ])
  match
    compile_manifest_uncached(
      manifest,
      @semantic.StandardLibrarySources::bootstrap(),
      CompilerPipelineOptions::production(5100UL, 0, true),
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform generic methods retain logical query types" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      20i32\n    } else {\n      22i32\n    }\n  }\n}\nfn read(value: Answer) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(Box::{\n    value: 0i32\n  }) + read(Box::{\n    value: 0u32\n  })))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform generic methods distinguish equal reference carriers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nstruct Left {}\nstruct Right {}\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, Left>() {\n      20i32\n    } else {\n      22i32\n    }\n  }\n}\nfn read(value: Answer) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(Box::{\n    value: Left::{}\n  }) + read(Box::{\n    value: Right::{}\n  })))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform generic trait arguments come from the checked target" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\ntrait Answer<t> {\n  fn answer(self) -> I32\n}\nstruct Marker {}\nimpl<t> Answer<t> for Marker {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      20i32\n    } else {\n      22i32\n    }\n  }\n}\nfn read_i(value: Answer<I32>) -> I32 {\n  value.answer()\n}\nfn read_u(value: Answer<U32>) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read_i(Marker::{}) + read_u(Marker::{})))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform nested generic methods keep helpers and returned traits" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nstruct Left {}\nstruct Right {}\ntrait Read {\n  fn read(self) -> I32\n}\nimpl Read for I32 {\n  fn read(self) -> I32 {\n    self\n  }\n}\ntrait Outer {\n  fn inner(self) -> Read\n}\nstruct Box<t> {\n  value: t\n}\nfn classify<t>() -> I32 {\n  if @types.type_equal::<t, Left>() {\n    20i32\n  } else {\n    22i32\n  }\n}\nimpl<t> Outer for Box<t> {\n  fn inner(self) -> Read {\n    classify::<t>()\n  }\n}\nfn read(value: Outer) -> I32 {\n  value.inner().read()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(Box::{\n    value: Left::{}\n  }) + read(Box::{\n    value: Right::{}\n  })))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform generic erasure retains logical query types" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      20i32\n    } else {\n      22i32\n    }\n  }\n}\nfn erase<t: Answer>(value: t) -> Answer {\n  value\n}\nfn read(value: Answer) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(erase(Box::{\n    value: 0i32\n  })) + read(erase(Box::{\n    value: 0u32\n  }))))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "dynamic transform generic erasure distinguishes equal reference carriers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nstruct Left {}\nstruct Right {}\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl<t> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, Left>() {\n      20i32\n    } else {\n      22i32\n    }\n  }\n}\nfn erase<t: Answer>(value: t) -> Answer {\n  value\n}\nfn read(value: Answer) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(erase(Box::{\n    value: Left::{}\n  })) + read(erase(Box::{\n    value: Right::{}\n  }))))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(source => {
          source == b"pub fn main() -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}
