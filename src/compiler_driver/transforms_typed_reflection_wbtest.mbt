///|
test "checked body reflection distinguishes calls from callees" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.array\nopen dew.std.string\n\nfn identity(value: I32) -> I32 {\n  value\n}\n\ntransform fn check_types(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let sum = ctx.syntax.children[0u32]\n  let call = sum.children[0u32]\n  let callee = call.children[0u32]\n  let valid = match (ctx.type_of(call), ctx.type_of(callee), ctx.type_of(sum)) {\n    (Some(call_type), Some(callee_type), Some(sum_type)) => {\n      call_type.name == \"I32\" && callee_type.kind == \"function\" && sum_type.name == \"I32\"\n    }\n    _ => false\n  }\n  let answer = if valid && ctx.type_errors.length() == 0u32 {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n\n#check_types\npub fn main() -> I32 {\n  identity(20i32) + identity(22i32)\n}\n",
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
test "body reflection errors allow an original source repair" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.array\ntransform fn repair(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  let answer = if ctx.type_errors.length() > 0u32 && ctx.expression_types.length() == 0u32 {\n    42i32\n  } else {\n    0i32\n  }\n  node.with_body(@ast.integer(answer))\n}\n#repair\npub fn main() -> I32 {\n  missing_original_function()\n}\n",
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
test "checked body reflection retains generic and nominal identities" {
  match
    compile_transform_source(
      b"import dewdrop.ast as @ast\nimport dewdrop.transform as @transform\nopen dew.std.array\nopen dew.std.string\n\nstruct Box<t> {\n  value: t\n}\n\ntransform fn check_parameter(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  match ctx.type_of(ctx.syntax.children[0u32]) {\n    Some(type_) if type_.kind == \"parameter\" && type_.name == \"t\" => node\n    _ => node.with_body(@ast.source(\"invalid_reflected_parameter()\"))\n  }\n}\n\ntransform fn check_record(node: @ast.FnNode, ctx: @transform.TransformContext) -> @ast.FnNode {\n  match ctx.type_of(ctx.syntax.children[0u32]) {\n    Some(type_) if type_.kind == \"applied\" => {\n      if type_.arguments[0u32].kind == \"nominal\" && type_.arguments[0u32].name == \"app::Box\" && type_.arguments[1u32].kind == \"parameter\" && type_.arguments[1u32].name == \"t\" {\n        node\n      } else {\n        node.with_body(@ast.source(\"invalid_reflected_record()\"))\n      }\n    }\n    _ => node.with_body(@ast.source(\"missing_reflected_record()\"))\n  }\n}\n\n#check_parameter\nfn identity<t>(value: t) -> t {\n  value\n}\n\n#check_record\nfn boxed<t>(value: t) -> Box<t> {\n  Box::{\n    value: value\n  }\n}\n\npub fn main() -> I32 {\n  boxed(identity(42i32)).value\n}\n",
    ) {
    Ok(_) => ()
    Err(error) => fail(error.message())
  }
}

///|
test "body reflection caches shared type descriptions" {
  let source = b"fn main() -> I32 {\n1i32\n2i32\n3i32\n4i32\n5i32\n42i32\n}\n"
  let manifest = @semantic.ProgramManifest::new([
    @semantic.ManifestModule::new("app", [
      @semantic.ManifestFile::new("main.dew", source),
    ]),
  ])
  let program = @semantic.collect_program_manifest(8800UL, manifest)
  let analyzed = @semantic.analyze_program_semantics(program)
  let lowering = @semantic.plan_unoptimized_program_lowering(program, analyzed)
  let values = @semantic.compile_time_expression_types(
    program,
    analyzed,
    lowering,
    [(0, "main.dew", 0UL, source.length().to_uint64())],
  )
  let cache : Map[UInt64, @transforms.ReflectedType] = {}
  assert_true(values.length() > 6)
  for value in values {
    assert_eq(compiler_transform_reflected_type(value.type_, cache).name, "I32")
  }
  assert_eq(cache.length(), 1)
}
