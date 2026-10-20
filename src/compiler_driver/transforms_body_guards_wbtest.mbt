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

///|
test "transform frame root checks array method import before specialization" {
  for valid in [false, true] {
    let source = @utf8.encode(
      (if valid { "open dew.std.array\n" } else { "" }) +
      "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\ntransform fn inspect(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n if ctx.expression_types.length() == 0u32 {\n  return node\n }\n node\n}\n#inspect\npub fn main() -> I32 {\n 0i32\n}\n",
    )
    match compile_transform_source(source) {
      Ok(compiled) => {
        assert_true(valid, msg="missing array method import was accepted")
        assert_true(compiled.emit_binary().unwrap().length() > 8)
      }
      Err(error) => {
        assert_false(valid, msg=error.message())
        assert_true(
          error.message().contains("compile-time helper failed source checking"),
          msg=error.message(),
        )
      }
    }
  }
}

///|
test "bad helper bodies stay out of transform frame preparation" {
  for mode in [0, 1, 2] {
    let call = if mode == 0 {
      " let _ = bad_helper(ctx)\n"
    } else if mode == 2 {
      " if choose() {\n  let _ = bad_helper(ctx)\n }\n"
    } else {
      ""
    }
    let source = @utf8.encode(
      "import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nfn bad_helper(ctx: @transform.TransformContext) -> U32 {\n ctx.expression_types.length()\n}\nfn choose() -> Bool {\n false\n}\ntransform fn inspect(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n" +
      call +
      " node.with_body(@ast.integer(42i32))\n}\n#inspect\npub fn main() -> I32 {\n 0i32\n}\n",
    )
    let manifest = @semantic.ProgramManifest::new([
      @semantic.ManifestModule::new("app", [
        @semantic.ManifestFile::new("main.dew", source),
      ]),
    ])
    match
      expand_manifest_sources(
        manifest,
        @semantic.StandardLibrarySources::bootstrap(),
        CompilerPipelineOptions::production(5100UL, 0, true),
      ) {
      Err(error) => {
        assert_eq(mode, 0, msg=error.message())
        assert_true(
          error.message().contains("compile-time helper failed source checking"),
          msg=error.message(),
        )
      }
      Ok(expanded) => {
        assert_true(mode != 0, msg="called invalid helper was accepted")
        assert_true(
          expanded.modules[0].files.any(file => {
            file.source == b"pub fn main() -> I32 {\n42i32\n}"
          }),
        )
        match compile_transform_source(source) {
          Ok(_) => fail("final checking accepted an unchanged invalid helper")
          Err(error) =>
            assert_true(error.message().contains("length"), msg=error.message())
        }
      }
    }
  }
}
