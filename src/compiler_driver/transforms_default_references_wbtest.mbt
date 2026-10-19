///|
test "reference and unit product defaults" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\n\nforeign type FirstHandle\nforeign type SecondHandle\nbuiltin cast_nullable(value: NullableRef<FirstHandle>) -> NullableRef<SecondHandle> = \"ref.cast\"\n\ntrait Answer {\n  fn answer(self) -> I32\n}\nbuiltin reference_is_null<t>(value: t) -> Bool = \"ref_is_null\"\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let units = match default_slot::<(Unit, (Unit, Unit))>() {\n    ((), ((), ())) => true\n    _ => false\n  }\n  let missing = cast_nullable(wasm_ref_null::<FirstHandle>())\n  let valid = wasm_ref_is_null(missing) && units && reference_is_null(default_slot::<fn() -> I32>()) && reference_is_null(default_slot::<Answer>()) && reference_is_null(default_slot::<WasmArray<I32>>())\n  node.with_body(@ast.integer(if valid {\n    42i32\n  } else {\n    0i32\n  }))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "two argument records reject null defaults" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nstruct Pair<t, u> {\n  left: t\n  right: u\n}\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = default_slot::<Pair<I32, I64>>()\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("null non-null value must not execute")
    Err(error) => assert_true(error.message().contains("null reference"))
  }
}

///|
test "one argument records retain record identity" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nstruct Pair<t> {\n  left: t\n}\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = default_slot::<Pair<I32>>()\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("null non-null value must not execute")
    Err(error) => assert_true(error.message().contains("null reference"))
  }
}

///|
test "nonunit product defaults trap during unboxing" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.wasm.intrinsics\nstruct Pair<t, u> {\n  left: t\n  right: u\n}\nfn default_slot<t>() -> t {\n  wasm_array_get(wasm_array_new_default::<t>(1u32), 0u32)\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let _ = default_slot::<(I32, I64)>()\n  node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("null non-null value must not execute")
    Err(error) => assert_true(error.message().contains("null reference"))
  }
}
