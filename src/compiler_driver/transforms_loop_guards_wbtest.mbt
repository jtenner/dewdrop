///|
test "checked loop control guard-break" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  while false {\n    _ if if true {\n      break 42i32\n    } else {\n      false\n    } => break 0i32\n    false => break 1i32\n    true => break 2i32\n  }\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "checked loop control guard-continue" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  while false {\n    state if if !state {\n      continue true\n    } else {\n      true\n    } => break 42i32\n    false => break 0i32\n    true => break 1i32\n  }\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
test "checked loop control initial-outer-break" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  while 0i32 {\n    _ => {\n      let _ = while if true {\n        break 42i32\n      } else {\n        0i32\n      } {\n        _ => break 0i32\n      }\n      break 1i32\n    }\n  }\n}\n\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
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
