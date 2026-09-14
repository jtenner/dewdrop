///|
fn constructor_value_names(module_ : CollectedModule) -> Map[String, Bool] {
  let consumed : Map[ExprId, Bool] = Map::new()
  for expression in module_.expressions {
    match expression {
      HirCallExpr(target, _, _) | HirConstructExpr(target, _, _) =>
        consumed[target] = true
      HirQualifiedExpr(base, _, _) => consumed[base] = true
      _ => ()
    }
  }
  let names : Map[String, Bool] = Map::new()
  for index, expression in module_.expressions {
    if consumed.contains(index) {
      continue
    }
    match expression {
      HirNameExpr(name, _) | HirQualifiedExpr(_, name, _) =>
        names[module_.name(name)] = true
      _ => ()
    }
  }
  names
}

///|
fn CollectedModule::constructor_intern(
  self : CollectedModule,
  name : String,
) -> NameId {
  match self.name_lookup.get(name) {
    Some(id) => id
    None => {
      let id = self.names.length()
      self.names.push(name)
      self.name_lookup[name] = id
      id
    }
  }
}

///|
fn CollectedModule::constructor_expression(
  self : CollectedModule,
  expression : HirExpr,
  file : FileId,
) -> ExprId {
  let id = self.expressions.length()
  self.expressions.push(expression)
  self.expression_files.push(file)
  self.explicit_call_type_argument_spans.push(
    empty_hir_span(self.explicit_call_type_arguments.length()),
  )
  id
}

///|
fn CollectedModule::constructor_type(
  self : CollectedModule,
  type_ : HirTypeSyntax,
  file : FileId,
) -> HirTypeId {
  let id = self.type_syntax.length()
  self.type_syntax.push(type_)
  self.type_syntax_files.push(file)
  id
}

///|
fn CollectedModule::install_constructor_wrappers(
  self : CollectedModule,
  demanded : Map[String, Bool],
) -> Unit {
  for variant in self.variants {
    if variant.kind != TupleVariantDecl ||
      !demanded.contains(self.name(variant.name)) ||
      self.constructor_wrappers.contains(variant.id) {
      continue
    }
    let owner = match self.declaration(variant.declaration) {
      Some(TopLevelReference(owner)) => owner
      _ => abort("constructor wrapper requires an enum declaration")
    }
    let file = self.declaration_files[semantic_id_local(owner.id)]
    let declaration = make_semantic_id(
      self.module_id,
      self.declaration_files.length(),
    )
    let name = self.constructor_intern("$constructor$" + variant.id.to_string())
    self.declaration_locations.push(self.declarations.length())
    self.declarations.push({
      id: declaration,
      kind: FunctionDecl,
      name,
      visibility: ModuleVisible,
      offset: variant.offset,
    })
    self.declaration_files.push(file)
    self.body_by_declaration.push(self.bodies.length())
    self.constructor_wrappers[variant.id] = declaration
    // The wrapper is addressed only through the variant's exact metadata.
    // Its generated name cannot be written as a Dew source identifier.
    let generics = self.generic_parameters_of(owner.id)
    let generic_start = self.generic_parameters.length()
    let arguments : Array[HirTypeId] = []
    for index in 0..<generics.length {
      let parameter = self.generic_parameters[generics.start + index]
      let id = make_semantic_id(
        self.module_id,
        self.generic_parameters.length(),
      )
      self.generic_parameters.push({ ..parameter, id, declaration, })
      arguments.push(
        self.constructor_type(
          NamedTypeSyntax(parameter.name, variant.offset),
          file,
        ),
      )
    }
    self.generic_parameter_spans.push({
      start: generic_start,
      length: generics.length,
    })
    let nominal = self.constructor_type(
      NamedTypeSyntax(owner.name, variant.offset),
      file,
    )
    let result = if arguments.is_empty() {
      nominal
    } else {
      let start = self.type_arguments.length()
      self.type_arguments.append(arguments)
      self.constructor_type(
        AppliedTypeSyntax(
          nominal,
          { start, length: arguments.length(), },
          variant.offset,
        ),
        file,
      )
    }
    let parameter_start = self.parameters.length()
    let expression_start = self.expressions.length()
    let child_start = self.expression_children.length()
    let root = self.constructor_expression(
      HirNameExpr(owner.name, variant.offset),
      file,
    )
    let target = self.constructor_expression(
      HirQualifiedExpr(root, variant.name, variant.offset),
      file,
    )
    for index in 0..<variant.payload_types.length {
      let name = self.constructor_intern("$argument$" + index.to_string())
      self.parameters.push({
        id: make_semantic_id(self.module_id, self.parameters.length()),
        declaration,
        index,
        kind: ValueParameterDecl,
        name,
        type_: self.type_arguments[variant.payload_types.start + index],
        offset: variant.offset,
      })
      self.expression_children.push(
        self.constructor_expression(HirNameExpr(name, variant.offset), file),
      )
    }
    self.parameter_spans.push({
      start: parameter_start,
      length: variant.payload_types.length,
    })
    self.callables.push({ declaration, return_type: result, })
    let call = self.constructor_expression(
      HirCallExpr(
        target,
        { start: child_start, length: variant.payload_types.length, },
        variant.offset,
      ),
      file,
    )
    let block = self.blocks.length()
    let item = self.block_items.length()
    self.block_items.push(HirExpressionItem(call, variant.offset))
    self.block_item_files.push(file)
    self.blocks.push({
      items: { start: item, length: 1, },
      offset: variant.offset,
    })
    self.block_files.push(file)
    self.body_files.push(file)
    self.bodies.push({
      id: make_semantic_id(self.module_id, self.bodies.length()),
      declaration,
      kind: FunctionBody,
      root: BlockBodyRoot(block),
      expressions: {
        start: expression_start,
        length: self.expressions.length() - expression_start,
      },
      expression_children: {
        start: child_start,
        length: variant.payload_types.length,
      },
      blocks: { start: block, length: 1, },
      block_items: { start: item, length: 1, },
      patterns: empty_hir_span(self.patterns.length()),
      pattern_children: empty_hir_span(self.pattern_children.length()),
      pattern_arms: empty_hir_span(self.pattern_arms.length()),
      arm_children: empty_hir_span(self.arm_children.length()),
      object_fields: empty_hir_span(self.object_fields.length()),
      pattern_fields: empty_hir_span(self.pattern_fields.length()),
      offset: variant.offset,
    })
  }
}

///|
fn install_program_constructor_wrappers(program : CollectedProgram) -> Unit {
  let demanded : Map[String, Bool] = Map::new()
  for module_ in program.modules {
    for name, _ in constructor_value_names(module_) {
      demanded[name] = true
    }
  }
  for module_ in program.modules {
    module_.install_constructor_wrappers(demanded)
  }
}

///|
fn CollectedModule::public_constructor_wrappers(
  self : CollectedModule,
) -> Map[DeclId, Bool] {
  let result : Map[DeclId, Bool] = Map::new()
  for variant in self.variants {
    match
      (
        self.constructor_wrappers.get(variant.id),
        self.declaration(variant.declaration),
      ) {
      (Some(wrapper), Some(TopLevelReference(owner))) if owner.visibility ==
        Public => result[wrapper] = true
      _ => ()
    }
  }
  result
}

///|
/// Synthesis depends on function-value use in the program, so source bytes alone
/// are insufficient provenance for a cached producer interface.
pub fn CollectedModule::constructor_evidence_fingerprint(
  self : CollectedModule,
) -> String {
  let output = StringBuilder::new()
  for variant in self.variants {
    match self.constructor_wrappers.get(variant.id) {
      Some(wrapper) => output.write_string("\{variant.id}:\{wrapper};")
      None => ()
    }
  }
  output.to_string()
}

///|
pub fn CollectedModule::constructor_interface_matches(
  self : CollectedModule,
  interface_ : FrozenModuleInterface,
) -> Bool {
  if self.declaration_files.length() !=
    interface_.resolved_types.declaration_types.length() ||
    self.type_syntax.length() != interface_.resolved_types.syntax_types.length() {
    return false
  }
  for variant in interface_.variants {
    if self.constructor_wrappers.get(variant.variant) != variant.constructor {
      return false
    }
  }
  true
}
