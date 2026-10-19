///|
test "checked mutable captures remain lexical through nested shadows" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  let mut count = 20i32\n  let tick = fn() -> I32 {\n    count = count + 1i32\n    count\n  }\n  let first = tick()\n  let second = if true {\n    let count = 200i32\n    let local = tick()\n    if count == 200i32 {\n      local\n    } else {\n      0i32\n    }\n  } else {\n    0i32\n  }\n  if first == 21i32 && second == 22i32 && count == 22i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
