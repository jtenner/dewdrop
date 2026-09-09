///|
// Validate startup inputs before any schedule or storage lookup.
fn module_initialization_failure(
  module_id : ModuleId,
  declaration : DeclId,
  code : Int,
  expected : UInt64,
  actual : UInt64,
  detail : UInt64,
) -> ProgramFunctionLookupFailure {
  {
    code,
    phase: 3,
    module_id,
    declaration,
    body: 0UL,
    expression: 0xffffffffU,
    expected,
    actual,
    detail,
  }
}

///|
fn check_module_initializer_source_body(
  collected : CollectedModule,
  declaration : DeclId,
) -> Result[HirBody, ProgramFunctionLookupFailure] {
  let failure = fn(code, expected, actual, detail) {
    module_initialization_failure(
      collected.module_id,
      declaration,
      code,
      expected,
      actual,
      detail,
    )
  }
  let local = semantic_id_local(declaration)
  guard local >= 0 && local < collected.body_by_declaration.length() else {
    return Err(
      failure(
        101,
        collected.body_by_declaration.length().to_uint64(),
        local.reinterpret_as_uint().to_uint64(),
        12UL,
      ),
    )
  }
  let index = collected.body_by_declaration[local]
  guard index >= 0 && index < collected.bodies.length() else {
    return Err(failure(610, 1UL, 0UL, 12UL))
  }
  let body = collected.bodies[index]
  let expected = (collected.module_id << 32) | index.to_uint64()
  guard body.id == expected else {
    return Err({ ..failure(106, expected, body.id, 14UL), body: body.id, })
  }
  guard body.declaration == declaration else {
    return Err({
      ..failure(106, declaration, body.declaration, 13UL),
      body: body.id,
    })
  }
  guard body.kind == ModuleLetBody else {
    return Err({
      ..failure(106, 0UL, program_initializer_body_kind_code(body.kind), 15UL),
      body: body.id,
    })
  }
  Ok(body)
}

///|
fn check_module_initialization_value_index(
  collected : CollectedModule,
  indices : Array[Int],
  declaration : DeclId,
) -> Result[Int, ProgramFunctionLookupFailure] {
  let failure = fn(code, expected, actual) {
    module_initialization_failure(
      collected.module_id,
      declaration,
      code,
      expected,
      actual,
      16UL,
    )
  }
  guard semantic_id_module(declaration) == collected.module_id else {
    return Err(
      failure(107, collected.module_id, semantic_id_module(declaration)),
    )
  }
  let local = semantic_id_local(declaration)
  guard local >= 0 && local < indices.length() else {
    return Err(
      failure(
        101,
        indices.length().to_uint64(),
        local.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  let index = indices[local]
  guard index >= 0 && index < collected.lets.length() else {
    return Err(
      failure(
        106,
        collected.lets.length().to_uint64(),
        index.reinterpret_as_uint().to_uint64(),
      ),
    )
  }
  guard collected.lets[index].declaration == declaration else {
    return Err(failure(106, declaration, collected.lets[index].declaration))
  }
  Ok(index)
}

///|
fn check_module_initialization_inputs(
  collected : CollectedModule,
  inferred : InferredModuleValues,
) -> Result[(Array[Int], Array[HirBody]), ProgramFunctionLookupFailure] {
  let dependencies = inferred.dependencies
  let module_id = collected.module_id
  let failure = fn(code, expected, actual, detail) {
    module_initialization_failure(
      module_id, 0UL, code, expected, actual, detail,
    )
  }
  guard inferred.module_id == module_id else {
    return Err(failure(107, module_id, inferred.module_id, 1UL))
  }
  guard dependencies.module_id == module_id else {
    return Err(failure(107, module_id, dependencies.module_id, 2UL))
  }
  let count = collected.lets.length()
  for
    entry in [
      (inferred.let_declarations.length(), 3UL),
      (inferred.let_types.length(), 4UL),
      (dependencies.let_dependencies.length(), 5UL),
    ] {
    let (actual, detail) = entry
    guard actual == count else {
      return Err(failure(103, count.to_uint64(), actual.to_uint64(), detail))
    }
  }
  guard dependencies.scc_declarations.length() == count else {
    return Err(
      failure(
        501,
        count.to_uint64(),
        dependencies.scc_declarations.length().to_uint64(),
        6UL,
      ),
    )
  }
  guard collected.declaration_files.length() ==
    collected.declaration_locations.length() else {
    return Err(
      failure(
        103,
        collected.declaration_locations.length().to_uint64(),
        collected.declaration_files.length().to_uint64(),
        17UL,
      ),
    )
  }
  let indices = Array::make(collected.declaration_locations.length(), -1)
  let ranks = Array::make(count, -1)
  let bodies : Array[HirBody] = []
  for index, value in collected.lets {
    let declaration = value.declaration
    let source_failure = fn(code, expected, actual, detail) {
      module_initialization_failure(
        module_id, declaration, code, expected, actual, detail,
      )
    }
    guard semantic_id_module(declaration) == module_id else {
      return Err(
        source_failure(107, module_id, semantic_id_module(declaration), 18UL),
      )
    }
    let local = semantic_id_local(declaration)
    guard local >= 0 && local < indices.length() else {
      return Err(
        source_failure(
          101,
          indices.length().to_uint64(),
          local.reinterpret_as_uint().to_uint64(),
          18UL,
        ),
      )
    }
    guard indices[local] == -1 else {
      return Err(source_failure(106, 1UL, 2UL, 18UL))
    }
    let location = collected.declaration_locations[local]
    guard location >= 0 && location < collected.declarations.length() else {
      return Err(
        source_failure(
          101,
          collected.declarations.length().to_uint64(),
          location.reinterpret_as_uint().to_uint64(),
          19UL,
        ),
      )
    }
    let entry = collected.declarations[location]
    guard entry.id == declaration else {
      return Err(source_failure(106, declaration, entry.id, 19UL))
    }
    guard entry.kind == LetDecl else {
      return Err(source_failure(106, 1UL, 0UL, 20UL))
    }
    guard inferred.let_declarations[index] == declaration else {
      return Err(
        source_failure(106, declaration, inferred.let_declarations[index], 21UL),
      )
    }
    match check_module_initializer_source_body(collected, declaration) {
      Ok(body) => bodies.push(body)
      Err(error) => return Err(error)
    }
    indices[local] = index
  }
  let mut seen = 0
  for rank, scc in dependencies.sccs {
    guard scc.start >= 0 &&
      scc.start <= dependencies.scc_declarations.length() &&
      scc.length >= 0 &&
      scc.length <= dependencies.scc_declarations.length() - scc.start else {
      return Err(
        failure(
          101,
          dependencies.scc_declarations.length().to_uint64(),
          scc.length.reinterpret_as_uint().to_uint64(),
          (7UL << 32) | scc.start.reinterpret_as_uint().to_uint64(),
        ),
      )
    }
    guard scc.length > 0 else {
      return Err(failure(501, 1UL, 0UL, (10UL << 32) | rank.to_uint64()))
    }
    for offset in 0..<scc.length {
      let declaration = dependencies.scc_declarations[scc.start + offset]
      let value = match
        check_module_initialization_value_index(collected, indices, declaration) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      guard ranks[value] == -1 else {
        return Err(
          module_initialization_failure(
            module_id, declaration, 501, 1UL, 2UL, 9UL,
          ),
        )
      }
      ranks[value] = rank
      seen += 1
    }
  }
  guard seen == count else {
    return Err(failure(501, count.to_uint64(), seen.to_uint64(), 8UL))
  }
  for index, edges in dependencies.let_dependencies {
    let declaration = collected.lets[index].declaration
    guard edges.start >= 0 &&
      edges.start <= dependencies.dependency_declarations.length() &&
      edges.length >= 0 &&
      edges.length <=
      dependencies.dependency_declarations.length() - edges.start else {
      return Err(
        module_initialization_failure(
          module_id,
          declaration,
          101,
          dependencies.dependency_declarations.length().to_uint64(),
          edges.length.reinterpret_as_uint().to_uint64(),
          (22UL << 32) | edges.start.reinterpret_as_uint().to_uint64(),
        ),
      )
    }
    for offset in 0..<edges.length {
      let dependency = dependencies.dependency_declarations[edges.start + offset]
      let target = match
        check_module_initialization_value_index(collected, indices, dependency) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      guard ranks[target] <= ranks[index] else {
        return Err(
          module_initialization_failure(
            module_id,
            declaration,
            501,
            ranks[index].to_uint64(),
            ranks[target].to_uint64(),
            dependency,
          ),
        )
      }
    }
  }
  Ok((indices, bodies))
}
