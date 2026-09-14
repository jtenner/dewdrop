///|
fn semantic_large_array_source(length : Int) -> Bytes {
  let output = Buffer(size_hint=length * 2 + 64)
  output.write_string_utf8(
    "open dew.std.array\nfn values() -> Array<I32> {\n  [",
  )
  for index in 0..<length {
    if index > 0 {
      output.write_byte(b',')
    }
    output.write_byte(b'1')
  }
  output.write_string_utf8("]\n}\n")
  output.to_bytes()
}

///|
test "products keep compact spans and arrays lower into ordinary calls" {
  let collected = collect_bytes(
    28101UL, b"fn pair() -> (I32, Bool) {\n  (1, true)\n}\nfn values() -> Unit {\n  let items = [1, 2, 3]\n}\n",
  )
  assert_eq(collected.diagnostics.length(), 0)
  let pair_body = collected.bodies[0]
  let pair_root = match pair_body.root {
    BlockBodyRoot(block) => collected.blocks[block].items
    _ => abort("expected pair block")
  }
  let pair_expression = match collected.block_items[pair_root.start] {
    HirExpressionItem(value, _) => value
    _ => abort("expected pair expression")
  }
  match collected.expressions[pair_expression] {
    HirProductExpr(fields, 29UL) => assert_eq(fields.length, 2)
    _ => fail("expected product HIR")
  }
  let array_body = collected.bodies[1]
  let array_root = match array_body.root {
    BlockBodyRoot(block) => collected.blocks[block].items
    _ => abort("expected array block")
  }
  let array_expression = match collected.block_items[array_root.start] {
    HirLetItem(_, _, _, value, _) => value
    _ => abort("expected array binding")
  }
  match collected.expressions[array_expression] {
    HirBlockExpr(block, _) => {
      let items = collected.blocks[block].items
      assert_eq(items.length, 5)
      for index in 1..<4 {
        match collected.block_items[items.start + index] {
          HirExpressionItem(call, _) =>
            match collected.expressions[call] {
              HirCallExpr(_, arguments, _) => assert_eq(arguments.length, 1)
              _ => fail("expected append call")
            }
          _ => fail("expected append item")
        }
      }
    }
    _ => fail("expected array construction block")
  }
}

///|
test "array literals unify elements and use expected types for empties" {
  let valid_program = collect_program_manifest(
    28103UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"open dew.std.array\nfn empty() -> Array<I32> {\n  []\n}\nfn values() -> Array<I32> {\n  [1, 2, 3]\n}\n",
        ),
      ]),
    ]),
  )
  let valid = analyze_program_semantics(valid_program)
  assert_eq(valid.modules[0].inferred.diagnostics.length(), 0)
  let mismatched = collect_bytes(
    28104UL, b"fn values() -> Unit {\n  let items = [1, true]\n}\n",
  )
  let mismatched_inferred = infer_module_bodies(
    mismatched,
    resolve_module_types(mismatched),
    resolve_module_names(mismatched),
  )
  assert_true(mismatched_inferred.diagnostics.length() > 0)
  let unconstrained = collect_bytes(
    28105UL, b"fn values() -> Unit {\n  let items = []\n}\n",
  )
  let unconstrained_inferred = infer_module_bodies(
    unconstrained,
    resolve_module_types(unconstrained),
    resolve_module_names(unconstrained),
  )
  assert_true(unconstrained_inferred.diagnostics.length() > 0)
}

///|
test "large array literal inference remains iterative" {
  let program = collect_program_manifest(
    28106UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new("main.dew", semantic_large_array_source(2048)),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  assert_eq(analyzed.modules[0].inferred.diagnostics.length(), 0)
}

///|
test "product and array expressions infer structural types" {
  let program = collect_program_manifest(
    28102UL,
    ProgramManifest::new([
      ManifestModule::new("app.main", [
        ManifestFile::new(
          "main.dew", b"fn pair() -> (I32, Bool) {\n  (1, true)\n}\nfn values() -> Unit {\n  let items = [1, 2, 3]\n}\n",
        ),
      ]),
    ]),
  )
  let analyzed = analyze_program_semantics(program)
  let collected = program.modules[0]
  let resolved = analyzed.frozen.interfaces[0].resolved_types
  let inferred = analyzed.modules[0].inferred
  assert_eq(resolved.diagnostics.length(), 0)
  assert_eq(inferred.diagnostics.length(), 0)
  match resolved.types[resolved.callable_return_types[0]] {
    ProductType(fields) => {
      assert_eq(fields.length, 2)
      assert_eq(
        resolved.type_arguments[fields.start],
        resolved.primitive(I32Type),
      )
      assert_eq(
        resolved.type_arguments[fields.start + 1],
        resolved.primitive(BoolType),
      )
    }
    _ => fail("expected resolved product type")
  }
  let array_body = collected.bodies[1]
  let items = match array_body.root {
    BlockBodyRoot(block) => collected.blocks[block].items
    _ => abort("expected array block")
  }
  let array_expression = match collected.block_items[items.start] {
    HirLetItem(_, _, _, value, _) => value
    _ => abort("expected array binding")
  }
  match inferred.type_term(inferred.expression_types[array_expression]) {
    BodyAppliedType(base, arguments) => {
      match inferred.type_term(base) {
        BodyResolvedType(resolved_base) =>
          match resolved.types[resolved_base] {
            NominalType(declaration) =>
              assert_eq(declaration, standard_array_type_declaration())
            _ => fail("expected Array constructor")
          }
        _ => fail("expected resolved Array base")
      }
      assert_eq(arguments.length, 1)
    }
    _ => fail("expected inferred Array type")
  }
}
