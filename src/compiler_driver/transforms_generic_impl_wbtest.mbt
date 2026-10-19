///|
test "checked transform generic_trait_impl" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\n\ntrait Answer {\n  fn answer(self) -> I32\n}\nstruct Left {\n  value: I32\n}\nstruct Right {\n  value: I32\n}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer(self) -> I32 {\n    self.value + 1i32\n  }\n}\nimpl Answer for Right {\n  fn answer(self) -> I32 {\n    self.value + 2i32\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer(self) -> I32 {\n    self.value.answer() + if @types.type_equal::<t, Left>() {\n      1i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer>(value: t) -> I32 {\n  value.answer()\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let left = Box::{\n    value: Left::{\n      value: 18i32\n    }\n  }\n  let right = Box::{\n    value: Right::{\n      value: 18i32\n    }\n  }\n  let a = read(left)\n  let b = read(right)\n  node.with_body(@ast.integer(if a == 20i32 && b == 22i32 {\n    42i32\n  } else {\n    0i32\n  }))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "checked transform generic_trait_method_bounds" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\ntrait Mark {\n  fn mark(self) -> I32\n}\nimpl Mark for U8 {\n  fn mark(self) -> I32 {\n    40i32\n  }\n}\nimpl Mark for U64 {\n  fn mark(self) -> I32 {\n    2i32\n  }\n}\ntrait Answer {\n  fn answer<u: Mark>(self, value: u) -> I32\n}\nstruct Left {}\nstruct Right {}\nstruct Box<t> {\n  value: t\n}\nimpl Answer for Left {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl Answer for Right {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    value.mark()\n  }\n}\nimpl<t: Answer> Answer for Box<t> {\n  fn answer<u: Mark>(self, value: u) -> I32 {\n    let _ = @types.type_equal::<t, Left>()\n    let _ = @types.type_equal::<u, U8>()\n    self.value.answer(value)\n  }\n}\nfn read<t: Answer, u: Mark>(value: t, other: u) -> I32 {\n  value.answer(other)\n}\nfn compute() -> I32 {\n  let left = Box::{\n    value: Left::{}\n  }\n  let right = Box::{\n    value: Right::{}\n  }\n  read(left, 1u8) + read(right, 1u64)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "checked transform generic_trait_trait_arguments" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\ntrait Answer<u> {\n  fn answer(self) -> I32\n}\nstruct Marker {}\nimpl<t> Answer<t> for Marker {\n  fn answer(self) -> I32 {\n    if @types.type_equal::<t, I32>() {\n      40i32\n    } else {\n      2i32\n    }\n  }\n}\nfn read<t: Answer<u>, u>(value: t) -> I32 {\n  value.answer()\n}\nfn compute() -> I32 {\n  read::<Marker, I32>(Marker::{}) + read::<Marker, I64>(Marker::{})\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
