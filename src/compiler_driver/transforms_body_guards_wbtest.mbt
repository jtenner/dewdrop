///|
test "transform body guard new ordinary call" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  let body = changed.with_body(@ast.name(\"value\").binary(\"+\", @ast.name(\"bonus\")))\n  body.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(2i32)]))\n}\n#extend\nfn answer(value: I32) -> I32 {\n  value\n}\npub fn main() -> I32 {\n  answer(40i32, 2i32)\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard mixed old and new ordinary calls" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn extend(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_parameters([ctx.parameters[0u32], @ast.parameter(\"bonus\", @ast.named_type(\"I32\"))])\n  let body = changed.with_body(@ast.name(\"value\").binary(\"+\", @ast.name(\"bonus\")))\n  body.repair_calls_with(@ast.name(node.name).call([@ast.name(\"value\"), @ast.integer(2i32)]))\n}\n#extend\nfn answer(value: I32) -> I32 {\n  value\n}\npub fn main() -> I32 {\n  answer(20i32, 20i32) + answer(0i32)\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard new result used in a condition" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.integer(42i32))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\npub fn main() -> I32 {\n  if answer() {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard invalid executed helper" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  true\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("invalid helper was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("compile-time helper failed source checking"),
        msg=error.message(),
      )
  }
}

///|
test "transform body guard invalid untaken helper branch" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  if false {\n    true\n  } else {\n    42i32\n  }\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("invalid helper was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("compile-time helper failed source checking"),
        msg=error.message(),
      )
  }
}

///|
test "transform body guard invalid closure body" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn compute() -> I32 {\n  let callback = fn() -> I32 {\n    true\n  }\n  callback()\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("invalid helper was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("compile-time helper failed source checking"),
        msg=error.message(),
      )
  }
}

///|
test "transform body guard invalid method body" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nstruct Value {\n  value: I32\n}\nimpl Value {\n  fn read(self) -> I32 {\n    true\n  }\n}\nfn compute() -> I32 {\n  let value = Value::{\n    value: 42i32\n  }\n  value.read()\n}\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  node.with_body(@ast.integer(compute()))\n}\n#replace\npub fn main() -> I32 {\n  0i32\n}\n",
    ) {
    Ok(_) => fail("invalid helper was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("compile-time helper failed source checking"),
        msg=error.message(),
      )
  }
}

///|
test "transform body guard unused runtime error remains fatal" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\nfn unused() -> I32 {\n true\n}\n",
    ) {
    Ok(_) => fail("invalid source was accepted")
    Err(error) =>
      assert_true(
        error.message().contains("BodyConstraintDiagnostic"),
        msg=error.message(),
      )
  }
}

///|
test "transform body guard invalid header remains fatal" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn replace(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n node.with_body(@ast.integer(42i32))\n}\n#replace\npub fn main() -> I32 {\n 0i32\n}\nfn unused(value: Missing) -> I32 {\n 42i32\n}\n",
    ) {
    Ok(_) => fail("invalid source was accepted")
    Err(error) =>
      assert_true(error.message().contains("UnknownType"), msg=error.message())
  }
}

///|
test "transform body guard new result in tail return" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.integer(42i32))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\nfn old() -> I32 {\n  answer()\n}\nfn changed() -> Bool {\n  answer()\n}\npub fn main() -> I32 {\n  if changed() && old() == 42i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard new result in explicit return" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.integer(42i32))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\nfn old() -> I32 {\n  answer()\n}\nfn changed() -> Bool {\n  return answer()\n}\npub fn main() -> I32 {\n  if changed() && old() == 42i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard new result in tail function value return" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.integer(42i32))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\nfn old() -> fn() -> I32 {\n  answer\n}\nfn changed() -> fn() -> Bool {\n  answer\n}\npub fn main() -> I32 {\n  if changed()() && old()() == 42i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}

///|
test "transform body guard new result in explicit function value return" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn predicate(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let changed = node.with_return_type(@ast.named_type(\"Bool\")).with_body(@ast.boolean(true))\n  changed.repair_calls_with(@ast.integer(42i32))\n}\n#predicate\nfn answer() -> I32 {\n  0i32\n}\nfn old() -> fn() -> I32 {\n  answer\n}\nfn changed() -> fn() -> Bool {\n  return answer\n}\npub fn main() -> I32 {\n  if changed()() && old()() == 42i32 {\n    42i32\n  } else {\n    0i32\n  }\n}\n",
    ) {
    Ok(compiled) => assert_true(compiled.emit_binary().unwrap().length() > 8)
    Err(error) => fail(error.message())
  }
}
