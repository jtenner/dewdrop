///|
test "transform context has structured parameters and result types" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\nopen dew.std.array\n\ntransform fn inspect(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let first = ctx.parameters[0u32]\n  let answer = match (first.name, first.type_.kind, first.type_.name, ctx.return_type.name) {\n    (\"value\", \"named\", \"I32\", \"I32\") => 42i32\n    _ => 0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n\n#inspect\npub fn reflected(value: I32) -> I32 {\n  value\n}\n\npub fn main() -> I32 {\n  reflected(0i32)\n}\n",
    ) {
    Ok(compiled) =>
      assert_true(
        compiled.program.modules[0].file_sources.any(fn(source) {
          source == b"pub fn reflected(value: I32) -> I32 {\n42i32\n}"
        }),
      )
    Err(error) => fail(error.message())
  }
}

///|
test "transform context retains generic bounds and nested type structure" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.string\nopen dew.std.array\n\ntransform fn inspect(node: @ast.FnNode, ctx: @transform.TransformContext) -> Result<@ast.FnNode, @transform.TransformError> {\n  let pair = ctx.parameters[1u32].type_\n  let callback = ctx.parameters[2u32].type_\n  let generic = ctx.type_parameters[0u32]\n  let result = ctx.return_type\n  match (ctx.parameters.length(), generic.name, generic.bounds[0u32].name, pair.kind, callback.kind, result.kind, result.arguments[0u32].name) {\n    (3u32, \"t\", \"Eq\", \"tuple\", \"function\", \"applied\", \"Option\") => Result::Ok(node)\n    _ => Result::Err(@transform.error(\"wrong structured signature\"))\n  }\n}\n\n#inspect\nfn shape<t: Eq>(value: t, pair: (I32, Bool), callback: fn(I32) -> I32) -> Option<I32> {\n  Some(callback(match pair {\n    (number, _) => number\n  }))\n}\n\npub fn main() -> I32 {\n  match shape(1i32, (42i32, true), fn(value: I32) -> I32 {\n    value\n  }) {\n    Some(value) => value\n    None => 0i32\n  }\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}
