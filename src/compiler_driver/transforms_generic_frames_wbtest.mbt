///|
test "checked generic query frames keep each logical instance" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\n\nfn width<t>() -> U32 {\n  @types.bit_width::<t>()\n}\n\nfn forwarded<t>() -> U32 {\n  width::<t>()\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let valid = width::<I32>() == 32u32 && width::<F64>() == 64u32 && forwarded::<U8>() == 8u32 && forwarded::<I64>() == 64u32\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "checked generic trait frames keep nominal witnesses" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\ntrait Answer {\n  fn answer(self) -> I32\n}\n\nstruct Left {\n  value: I32\n}\nstruct Right {\n  value: I32\n}\n\nimpl Answer for Left {\n  fn answer(self) -> I32 {\n    self.value + 1i32\n  }\n}\nimpl Answer for Right {\n  fn answer(self) -> I32 {\n    self.value + 2i32\n  }\n}\n\nfn read<t: Answer>(value: t) -> I32 {\n  value.answer()\n}\nfn forward<t: Answer>(value: t) -> I32 {\n  read(value)\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let a = forward(Left::{\n    value: 19i32\n  })\n  let b = forward(Right::{\n    value: 20i32\n  })\n  node.with_body(@ast.integer(if a == 20i32 && b == 22i32 {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "returned generic closures retain their logical query frame" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\n\nfn width<t>() -> fn() -> U32 {\n  fn() -> U32 {\n    @types.bit_width::<t>()\n  }\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let narrow = width::<U8>()\n  let wide = width::<U64>()\n  let valid = narrow() == 8u32 && wide() == 64u32 && narrow() == 8u32\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "generic frames preserve computed types and fresh query arrays" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nopen dew.std.array\nopen dew.std.string\n\nstruct Payload {\n  value: I32\n  flag: Bool\n}\nenum Message<t> {\n  Value(t, I64)\n}\ntrait Marker {\n  fn mark(self) -> Bool\n}\nimpl Marker for Payload {\n  fn mark(self) -> Bool {\n    true\n  }\n}\n\nfn fields<t>() -> Bool {\n  let names = @types.field_names::<t>()\n  let _ = names.pop()\n  let fresh = @types.field_names::<t>()\n  fresh.length() == 2u32 && fresh[0u32] == \"value\" && @types.implements::<t, Marker>()\n}\nfn projection<t>() -> Bool {\n  type Item = @types.field_type<t>(\"value\")\n  @types.type_equal::<Item, I32>()\n}\nfn payload<t>() -> Bool {\n  type Parts = @types.variant_payload_types<t>(\"Value\")\n  @types.type_equal::<Parts, (U8, I64)>()\n}\nfn numeric<t>() -> Bool {\n  @types.static_assert(@types.is_integer::<t>(), \"expected integer\")\n  @types.is_signed_integer::<t>() && @types.bit_width::<t>() == 32u32 && @types.size_of::<(U8, t)>() == 8u32 && @types.align_of::<(U8, t)>() == 4u32 && @types.field_offset::<(U8, t)>(1u32) == 4u32\n}\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let valid = fields::<Payload>() && projection::<Payload>() && payload::<Message<U8>>() && numeric::<I32>()\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "generic frames preserve float and vector default carriers" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\nbuiltin vector_empty(value: V128) -> I32 = \"v128.any_true\"\n\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let valid = default_slot::<F32>() == 0.0f32 && default_slot::<F64>() == 0.0f64 && vector_empty(default_slot::<V128>()) == 0i32\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "transform generic instance planning has a finite bound" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nimport dew.std.types as @types\nopen dew.std.array\nfn recurse<t>() -> Bool {\n  if @types.type_equal::<t, Unit>() {\n    true\n  } else {\n    recurse::<Array<t>>()\n  }\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(if recurse::<I32>() {\n    42i32\n  } else {\n    0i32\n  }))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("recursive type growth must fail")
    Err(error) =>
      assert_true(
        error.message().contains("transform generic instance limit exceeded"),
        msg=error.message(),
      )
  }
}

///|
test "generic frames export rechecked nongeneric methods" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.types\n\nimpl I32 {\n  fn answer(self) -> I32 {\n    self\n  }\n}\nfn read<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    0i32\n  } else {\n    value.answer()\n  }\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(()) + read(42i32)))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "generic frames export rechecked primitive operators" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.types\nfn twice<t>(value: t) -> t {\n  if is_integer::<t>() {\n    value + value\n  } else {\n    value\n  }\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = twice(())\n  node.with_body(@ast.integer(twice(21i32)))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "invalid selected generic bodies cannot execute" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.types\nfn accept(value: I64) -> I32 {\n  42i32\n}\nfn read<t>(value: t) -> I32 {\n  if is_unit::<t>() {\n    0i32\n  } else {\n    accept(value)\n  }\n}\ntransform fn calculate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(read(1i32)))\n}\n#calculate\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("an invalid selected call must not run")
    Err(error) =>
      assert_true(
        error.message().contains("selected generic body failed checking"),
        msg=error.message(),
      )
  }
}
