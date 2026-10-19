///|
test "checked function identity named-immediate" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n value\n}\nbuiltin same(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n if same(identity, identity) {\n 42i32\n } else {\n 0i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity named-stored" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n value\n}\nbuiltin same(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n let left = identity\n let right = identity\n if same(left, right) {\n 42i32\n } else {\n 0i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity named-returned" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn identity(value: I32) -> I32 {\n value\n}\nfn get() -> fn(I32) -> I32 {\n identity\n}\nbuiltin same(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n if same(get(), get()) {\n 42i32\n } else {\n 0i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity captured-alias" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn make(value: I64) -> fn() -> I64 {\n fn() -> I64 {\n value\n }\n}\nbuiltin same(left: fn() -> I64, right: fn() -> I64) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n let left = make(1i64)\n if same(left, left) {\n 42i32\n } else {\n 0i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity captured-fresh" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn make(value: I64) -> fn() -> I64 {\n fn() -> I64 {\n value\n }\n}\nbuiltin same(left: fn() -> I64, right: fn() -> I64) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n if same(make(1i64), make(1i64)) {\n 0i32\n } else {\n 42i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity uncaptured-fresh" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn make() -> fn() -> I64 {\n fn() -> I64 {\n 1i64\n }\n}\nbuiltin same(left: fn() -> I64, right: fn() -> I64) -> Bool = \"ref.eq\"\nfn answer() -> I32 {\n if same(make(), make()) {\n 0i32\n } else {\n 42i32\n }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(answer()))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity builtin-singleton" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nbuiltin operation(value: I32) -> I32 = \"i32.extend8_s\"\nbuiltin same(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let result = if same(operation, operation) {\n 42i32\n } else {\n 0i32\n }\n node.with_body(@ast.integer(result))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}

///|
test "checked function identity different-declarations" {
  match compile_transform_source(b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn first(value: I32) -> I32 {\n value\n}\nfn second(value: I32) -> I32 {\n value\n}\nbuiltin same(left: fn(I32) -> I32, right: fn(I32) -> I32) -> Bool = \"ref.eq\"\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n let result = if same(first, second) {\n 0i32\n } else {\n 42i32\n }\n node.with_body(@ast.integer(result))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\n") {
    Ok(compiled) => assert_true(compiled.program.modules[0].file_sources.any(source => source == b"pub fn main() -> I32 {\n42i32\n}"))
    Err(error) => fail(error.message())
  }
}
