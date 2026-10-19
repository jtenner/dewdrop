///|
test "checked transform source executes overloads" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\n\nbuiltin adjust(value: I32) -> I32 = \"i32.extend8_s\"\nbuiltin adjust(value: Bool) -> Bool = \"i32.eqz\"\n\nfn flag_callback() -> fn(Bool) -> Bool {\n  adjust\n}\n\nfn apply(callback: fn(I32) -> I32, value: I32) -> I32 {\n  callback(value)\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let callback = flag_callback()\n  let answer = if callback(false) {\n    apply(adjust, 42i32)\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
