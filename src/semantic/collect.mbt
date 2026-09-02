///|
priv struct CollectionBuilder {
  module_id : ModuleId
  mut current_file : FileId
  mut current_file_test_only : Bool
  mut preamble_declaration_count : Int
  files : Array[FileId]
  file_paths : Array[String]
  file_sources : Array[Bytes]
  test_files : Array[FileId]
  declaration_files : Array[FileId]
  body_files : Array[FileId]
  names : Array[String]
  declarations : Array[CollectedDeclaration]
  methods : Array[CollectedMethod]
  declaration_locations : Array[Int]
  fields : Array[CollectedField]
  variants : Array[CollectedVariant]
  generic_parameters : Array[CollectedGenericParameter]
  parameters : Array[CollectedParameter]
  generic_parameter_spans : Array[HirSpan]
  generic_bounds : Array[HirTypeId]
  parameter_spans : Array[HirSpan]
  callables : Array[CollectedCallable]
  tests : Array[CollectedTest]
  imports : Array[CollectedImport]
  builtins : Array[CollectedBuiltin]
  lets : Array[CollectedLet]
  aliases : Array[CollectedAlias]
  impls : Array[CollectedImpl]
  foreign_types : Array[CollectedForeignType]
  foreign_libraries : Array[CollectedForeignLibrary]
  foreign_functions : Array[CollectedForeignFunction]
  type_syntax : Array[HirTypeSyntax]
  type_syntax_files : Array[FileId]
  type_arguments : Array[HirTypeId]
  type_source_scratch : Array[@parser.TypeExpr]
  type_state_scratch : Array[Int]
  type_result_start_scratch : Array[Int]
  type_result_scratch : Array[HirTypeId]
  type_list_scratch : Array[HirTypeId]
  lambda_parameters : Array[HirLambdaParameter]
  lambda_parameter_files : Array[FileId]
  lambdas : Array[HirLambda]
  lambda_sources : Array[@parser.Block]
  lambda_parameter_spans : Array[HirSpan]
  lambda_return_types : Array[HirTypeId]
  lambda_files : Array[FileId]
  lambda_offsets : Array[UInt64]
  lambda_parents : Array[LambdaId]
  lambda_root_bodies : Array[BodyId]
  mut current_lambda : LambdaId
  mut current_root_body : BodyId
  bodies : Array[HirBody]
  body_by_declaration : Array[Int]
  expressions : Array[HirExpr]
  expression_files : Array[FileId]
  expression_children : Array[ExprId]
  explicit_call_type_argument_spans : Array[HirSpan]
  explicit_call_type_arguments : Array[HirTypeId]
  blocks : Array[HirBlock]
  block_files : Array[FileId]
  block_items : Array[HirBlockItem]
  block_item_files : Array[FileId]
  object_fields : Array[HirObjectField]
  object_field_files : Array[FileId]
  patterns : Array[HirPattern]
  pattern_files : Array[FileId]
  pattern_children : Array[PatternId]
  pattern_fields : Array[HirPatternField]
  pattern_field_files : Array[FileId]
  pattern_arms : Array[HirPatternArm]
  pattern_arm_files : Array[FileId]
  arm_children : Array[PatternArmId]
  body_task_kinds : Array[Int]
  body_task_sources : Array[Int]
  body_task_first_starts : Array[Int]
  body_task_second_starts : Array[Int]
  body_expr_sources : Array[@parser.Expr]
  body_block_sources : Array[@parser.Block]
  body_pattern_sources : Array[@parser.Pattern]
  body_arm_sources : Array[@parser.PatternArm]
  body_expr_results : Array[ExprId]
  body_block_results : Array[BlockId]
  body_pattern_results : Array[PatternId]
  body_arm_results : Array[PatternArmId]
  diagnostics : Array[CollectionDiagnostic]
  name_lookup : Map[String, NameId]
  type_bindings : Map[NameId, DeclId]
  trait_bindings : Map[NameId, DeclId]
  value_bindings : Map[NameId, ValueBinding]
  value_binding_candidates : Array[ValueBindingCandidate]
  foreign_library_by_alias : Map[NameId, DeclId]
  mut next_declaration_local : Int
}

///|
fn CollectionBuilder::new(module_id : ModuleId) -> CollectionBuilder {
  guard module_id <= 0xffffffffUL else {
    abort("semantic module ID exceeds 32 bits")
  }
  {
    module_id,
    current_file: make_file_id(module_id, 0),
    current_file_test_only: false,
    preamble_declaration_count: 0,
    files: [],
    file_paths: [],
    file_sources: [],
    test_files: [],
    declaration_files: [],
    body_files: [],
    names: [],
    declarations: [],
    methods: [],
    declaration_locations: [],
    fields: [],
    variants: [],
    generic_parameters: [],
    parameters: [],
    generic_parameter_spans: [],
    generic_bounds: [],
    parameter_spans: [],
    callables: [],
    tests: [],
    imports: [],
    builtins: [],
    lets: [],
    aliases: [],
    impls: [],
    foreign_types: [],
    foreign_libraries: [],
    foreign_functions: [],
    type_syntax: [],
    type_syntax_files: [],
    type_arguments: [],
    type_source_scratch: [],
    type_state_scratch: [],
    type_result_start_scratch: [],
    type_result_scratch: [],
    type_list_scratch: [],
    lambda_parameters: [],
    lambda_parameter_files: [],
    lambdas: [],
    lambda_sources: [],
    lambda_parameter_spans: [],
    lambda_return_types: [],
    lambda_files: [],
    lambda_offsets: [],
    lambda_parents: [],
    lambda_root_bodies: [],
    current_lambda: -1,
    current_root_body: 0UL,
    bodies: [],
    body_by_declaration: [],
    expressions: [],
    expression_files: [],
    expression_children: [],
    explicit_call_type_argument_spans: [],
    explicit_call_type_arguments: [],
    blocks: [],
    block_files: [],
    block_items: [],
    block_item_files: [],
    object_fields: [],
    object_field_files: [],
    patterns: [],
    pattern_files: [],
    pattern_children: [],
    pattern_fields: [],
    pattern_field_files: [],
    pattern_arms: [],
    pattern_arm_files: [],
    arm_children: [],
    body_task_kinds: [],
    body_task_sources: [],
    body_task_first_starts: [],
    body_task_second_starts: [],
    body_expr_sources: [],
    body_block_sources: [],
    body_pattern_sources: [],
    body_arm_sources: [],
    body_expr_results: [],
    body_block_results: [],
    body_pattern_results: [],
    body_arm_results: [],
    diagnostics: [],
    name_lookup: Map::default(),
    type_bindings: Map::default(),
    trait_bindings: Map::default(),
    value_bindings: Map::default(),
    value_binding_candidates: [],
    foreign_library_by_alias: Map::default(),
    next_declaration_local: 0,
  }
}

///|
fn CollectionBuilder::intern(self : CollectionBuilder, name : String) -> NameId {
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
fn CollectionBuilder::next_declaration_id(self : CollectionBuilder) -> DeclId {
  let id = make_semantic_id(self.module_id, self.next_declaration_local)
  self.next_declaration_local += 1
  self.declaration_files.push(self.current_file)
  self.generic_parameter_spans.push(
    empty_hir_span(self.generic_parameters.length()),
  )
  self.parameter_spans.push(empty_hir_span(self.parameters.length()))
  self.body_by_declaration.push(-1)
  id
}

///|
fn CollectionBuilder::record_duplicate(
  self : CollectionBuilder,
  space : BindingSpace,
  name : NameId,
  first : (UInt64, UInt64),
  first_file : FileId,
  duplicate : UInt64,
  duplicate_offset : UInt64,
) -> Unit {
  self.diagnostics.push(
    DuplicateName({
      space,
      name,
      first: first.0,
      duplicate,
      first_file,
      duplicate_file: self.current_file,
      first_offset: first.1,
      duplicate_offset,
    }),
  )
}

///|
fn CollectionBuilder::collected_declaration_offset(
  self : CollectionBuilder,
  declaration : DeclId,
) -> UInt64 {
  let location = self.declaration_locations[semantic_id_local(declaration)]
  if location >= 0 {
    self.declarations[location].offset
  } else {
    self.methods[-location - 1].offset
  }
}

///|
fn CollectionBuilder::bind_unique_module_name(
  self : CollectionBuilder,
  space : BindingSpace,
  bindings : Map[NameId, DeclId],
  name : NameId,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  match bindings.get(name) {
    Some(first) =>
      self.record_duplicate(
        space,
        name,
        (first, self.collected_declaration_offset(first)),
        self.declaration_files[semantic_id_local(first)],
        declaration,
        offset,
      )
    None => bindings[name] = declaration
  }
}

///|
fn CollectionBuilder::bind_value_name(
  self : CollectionBuilder,
  kind : CollectedDeclKind,
  name : NameId,
  declaration : DeclId,
  offset : UInt64,
) -> Unit {
  match self.value_bindings.get(name) {
    Some(binding) =>
      if kind == BuiltinDecl && binding.kind == BuiltinDecl {
        let candidate_index = self.value_binding_candidates.length()
        self.value_binding_candidates[binding.tail].next = candidate_index
        self.value_binding_candidates.push({ declaration, next: -1, })
        binding.tail = candidate_index
      } else {
        self.record_duplicate(
          ModuleValue,
          name,
          (
            self.value_binding_candidates[binding.head].declaration,
            binding.offset,
          ),
          self.declaration_files[semantic_id_local(
            self.value_binding_candidates[binding.head].declaration,
          )],
          declaration,
          offset,
        )
      }
    None => {
      let candidate_index = self.value_binding_candidates.length()
      self.value_binding_candidates.push({ declaration, next: -1, })
      self.value_bindings[name] = {
        head: candidate_index,
        tail: candidate_index,
        kind,
        offset,
      }
    }
  }
}

///|
fn CollectionBuilder::add_declaration(
  self : CollectionBuilder,
  kind : CollectedDeclKind,
  name : String?,
  visibility : SemanticVisibility,
  offset : UInt64,
) -> CollectedDeclaration {
  let id = self.next_declaration_id()
  let name = match name {
    Some(value) => self.intern(value)
    None => -1
  }
  let declaration = { id, kind, name, visibility, offset, }
  let location = self.declarations.length()
  self.declarations.push(declaration)
  self.declaration_locations.push(location)
  declaration
}

///|
fn CollectionBuilder::add_method(
  self : CollectionBuilder,
  parent : DeclId,
  kind : CollectedMethodKind,
  name : String,
  visibility : SemanticVisibility,
  offset : UInt64,
) -> CollectedMethod {
  let collected_method = {
    id: self.next_declaration_id(),
    parent,
    kind,
    name: self.intern(name),
    visibility,
    offset,
  }
  let location = self.methods.length()
  self.methods.push(collected_method)
  self.declaration_locations.push(-location - 1)
  collected_method
}

///|
fn CollectionBuilder::collect_generic_parameters(
  self : CollectionBuilder,
  declaration : DeclId,
  parameters : Array[@parser.TypeParameter],
) -> Unit {
  let start = self.generic_parameters.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if parameters.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  for index, parameter in parameters {
    let name = self.intern(parameter.name)
    let id = make_semantic_id(self.module_id, self.generic_parameters.length())
    let first = match seen {
      Some(table) => table.get(name)
      None => {
        let mut found = None
        let mut existing = start
        while existing < self.generic_parameters.length() {
          let candidate = self.generic_parameters[existing]
          if candidate.name == name {
            found = Some((candidate.id, candidate.offset))
            break
          }
          existing += 1
        }
        found
      }
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          GenericParameter,
          name,
          first,
          self.current_file,
          id,
          parameter.offset,
        )
      None =>
        match seen {
          Some(table) => table[name] = (id, parameter.offset)
          None => ()
        }
    }
    let bound_start = self.generic_bounds.length()
    for bound in parameter.bounds {
      self.generic_bounds.push(self.lower_type(bound))
    }
    self.generic_parameters.push({
      id,
      declaration,
      index,
      name,
      bounds: {
        start: bound_start,
        length: self.generic_bounds.length() - bound_start,
      },
      offset: parameter.offset,
    })
  }
  self.generic_parameter_spans[semantic_id_local(declaration)] = {
    start,
    length: self.generic_parameters.length() - start,
  }
}

///|
fn CollectionBuilder::collect_parameters(
  self : CollectionBuilder,
  declaration : DeclId,
  receiver : @parser.ReceiverParameter?,
  parameters : Array[@parser.FnParameter],
) -> Unit {
  let start = self.parameters.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if parameters.length() +
    (if receiver is Some(_) { 1 } else { 0 }) >
    8 {
    Some(Map::default())
  } else {
    None
  }
  let mut index = 0
  match receiver {
    Some(value) => {
      let name = self.intern("self")
      let id = make_semantic_id(self.module_id, self.parameters.length())
      match seen {
        Some(table) => table[name] = (id, value.offset)
        None => ()
      }
      self.parameters.push({
        id,
        declaration,
        index,
        kind: ReceiverParameterDecl,
        name,
        type_: match value.explicit_type {
          Some(type_) => self.lower_type(type_)
          None => -1
        },
        offset: value.offset,
      })
      index += 1
    }
    None => ()
  }
  for parameter in parameters {
    let name = self.intern(parameter.name)
    let id = make_semantic_id(self.module_id, self.parameters.length())
    let first = match seen {
      Some(table) => table.get(name)
      None => {
        let mut found = None
        let mut existing = start
        while existing < self.parameters.length() {
          let candidate = self.parameters[existing]
          if candidate.name == name {
            found = Some((candidate.id, candidate.offset))
            break
          }
          existing += 1
        }
        found
      }
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          Parameter,
          name,
          first,
          self.current_file,
          id,
          parameter.offset,
        )
      None =>
        match seen {
          Some(table) => table[name] = (id, parameter.offset)
          None => ()
        }
    }
    self.parameters.push({
      id,
      declaration,
      index,
      kind: ValueParameterDecl,
      name,
      type_: self.lower_type(parameter.type_),
      offset: parameter.offset,
    })
    index += 1
  }
  self.parameter_spans[semantic_id_local(declaration)] = {
    start,
    length: self.parameters.length() - start,
  }
}

///|
fn CollectionBuilder::collect_named_fields(
  self : CollectionBuilder,
  declaration : DeclId,
  variant : VariantId?,
  fields : Array[@parser.StructField],
  space : BindingSpace,
) -> Unit {
  let start = self.fields.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if fields.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  for field in fields {
    let name = self.intern(field.name)
    let id = make_semantic_id(self.module_id, self.fields.length())
    let first = match seen {
      Some(table) => table.get(name)
      None => {
        let mut found = None
        let mut existing = start
        while existing < self.fields.length() {
          let candidate = self.fields[existing]
          if candidate.name == name {
            found = Some((candidate.id, candidate.offset))
            break
          }
          existing += 1
        }
        found
      }
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          space,
          name,
          first,
          self.current_file,
          id,
          field.offset,
        )
      None =>
        match seen {
          Some(table) => table[name] = (id, field.offset)
          None => ()
        }
    }
    self.fields.push({
      id,
      declaration,
      variant,
      mutable_: field.mutable_,
      name,
      type_: self.lower_type(field.type_),
      offset: field.offset,
    })
  }
}

///|
fn CollectionBuilder::first_method_name(
  self : CollectionBuilder,
  start : Int,
  name : NameId,
) -> (UInt64, UInt64)? {
  let mut index = start
  while index + 1 < self.methods.length() {
    let candidate = self.methods[index]
    if candidate.name == name {
      return Some((candidate.id, candidate.offset))
    }
    index += 1
  }
  None
}

///|
fn CollectionBuilder::first_variant_name(
  self : CollectionBuilder,
  start : Int,
  name : NameId,
) -> (UInt64, UInt64)? {
  let mut index = start
  while index < self.variants.length() {
    let candidate = self.variants[index]
    if candidate.name == name {
      return Some((candidate.id, candidate.offset))
    }
    index += 1
  }
  None
}

///|
fn CollectionBuilder::collect_builtin(
  self : CollectionBuilder,
  value : @parser.BuiltinDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    BuiltinDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_value_name(
    BuiltinDecl,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  self.collect_parameters(declaration.id, None, value.parameters)
  self.callables.push({
    declaration: declaration.id,
    return_type: self.lower_type(value.return_type),
  })
  self.builtins.push({
    declaration: declaration.id,
    builtin_name: value.builtin_name,
  })
}

///|
fn CollectionBuilder::collect_let(
  self : CollectionBuilder,
  value : @parser.LetDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    LetDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_value_name(
    LetDecl,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.lets.push({ declaration: declaration.id, mutable_: value.mutable_, })
  self.lower_expression_body(
    declaration.id,
    ModuleLetBody,
    value.value,
    value.offset,
  )
}

///|
fn CollectionBuilder::collect_trait(
  self : CollectionBuilder,
  value : @parser.TraitDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    TraitDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_unique_module_name(
    ModuleTrait,
    self.trait_bindings,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  let method_start = self.methods.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if value.methods.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  for source_method in value.methods {
    let collected_method = self.add_method(
      declaration.id,
      TraitMethodDecl,
      source_method.name,
      ModuleVisible,
      source_method.offset,
    )
    let first = match seen {
      Some(table) => table.get(collected_method.name)
      None => self.first_method_name(method_start, collected_method.name)
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          TraitMethod,
          collected_method.name,
          first,
          self.current_file,
          collected_method.id,
          source_method.name_offset,
        )
      None =>
        match seen {
          Some(table) =>
            table[collected_method.name] = (
              collected_method.id,
              source_method.name_offset,
            )
          None => ()
        }
    }
    self.collect_generic_parameters(
      collected_method.id,
      source_method.type_parameters,
    )
    self.collect_parameters(
      collected_method.id,
      source_method.receiver,
      source_method.parameters,
    )
    self.callables.push({
      declaration: collected_method.id,
      return_type: self.lower_type(source_method.return_type),
    })
  }
}

///|
fn CollectionBuilder::collect_function(
  self : CollectionBuilder,
  value : @parser.FunctionDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    FunctionDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_value_name(
    FunctionDecl,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  self.collect_parameters(declaration.id, value.receiver, value.parameters)
  self.callables.push({
    declaration: declaration.id,
    return_type: self.lower_type(value.return_type),
  })
  self.lower_block_body(declaration.id, FunctionBody, value.body, value.offset)
}

///|
fn CollectionBuilder::collect_test(
  self : CollectionBuilder,
  value : @parser.TestDeclaration,
) -> Unit {
  if !self.current_file_test_only {
    self.diagnostics.push(
      TestDeclarationOutsideTestFile(self.current_file, value.offset),
    )
  }
  if !semantic_utf8_is_valid(value.name) {
    self.diagnostics.push(
      InvalidUtf8StringLiteral(self.current_file, value.name_offset),
    )
  }
  match value.expected_trap {
    Some(expected) =>
      if expected != b"unreachable" &&
        expected != b"memory-out-of-bounds" &&
        expected != b"array-out-of-bounds" &&
        expected != b"integer-divide-by-zero" &&
        expected != b"integer-overflow" &&
        expected != b"invalid-conversion-to-integer" {
        self.diagnostics.push(
          InvalidExpectedTestTrap(self.current_file, expected, value.offset),
        )
      }
    None => ()
  }
  for test_ in self.tests {
    if test_.file == self.current_file && test_.display_name == value.name {
      self.diagnostics.push(
        DuplicateTestIdentity({
          file: self.current_file,
          display_name: value.name,
          first_offset: test_.offset,
          duplicate_offset: value.offset,
        }),
      )
      break
    }
  }
  let generated_name = "__dew_test_" + self.tests.length().to_string()
  let declaration = self.add_declaration(
    TestDecl,
    Some(generated_name),
    ModuleVisible,
    value.offset,
  )
  self.callables.push({
    declaration: declaration.id,
    return_type: self.lower_type(value.return_type),
  })
  self.tests.push({
    declaration: declaration.id,
    display_name: value.name,
    expected_trap: value.expected_trap,
    file: self.current_file,
    offset: value.offset,
  })
  self.lower_block_body(declaration.id, FunctionBody, value.body, value.offset)
}

///|
fn CollectionBuilder::collect_foreign_type(
  self : CollectionBuilder,
  value : @parser.ForeignTypeDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    ForeignTypeDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_unique_module_name(
    ModuleType,
    self.type_bindings,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  match self.foreign_library_by_alias.get(declaration.name) {
    Some(first) =>
      self.record_duplicate(
        ModuleType,
        declaration.name,
        (first, self.collected_declaration_offset(first)),
        self.declaration_files[semantic_id_local(first)],
        declaration.id,
        value.name_offset,
      )
    None => ()
  }
  self.foreign_types.push({ declaration: declaration.id, })
}

///|
fn CollectionBuilder::collect_foreign_library(
  self : CollectionBuilder,
  value : @parser.ForeignLibraryDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    ForeignLibraryDecl,
    Some(value.namespace_alias),
    ModuleVisible,
    value.offset,
  )
  self.bind_value_name(
    ForeignLibraryDecl,
    declaration.name,
    declaration.id,
    value.alias_offset,
  )
  match self.type_bindings.get(declaration.name) {
    Some(first) =>
      self.record_duplicate(
        ModuleValue,
        declaration.name,
        (first, self.collected_declaration_offset(first)),
        self.declaration_files[semantic_id_local(first)],
        declaration.id,
        value.alias_offset,
      )
    None => ()
  }
  match self.foreign_library_by_alias.get(declaration.name) {
    Some(first) =>
      self.record_duplicate(
        ModuleValue,
        declaration.name,
        (first, self.collected_declaration_offset(first)),
        self.declaration_files[semantic_id_local(first)],
        declaration.id,
        value.alias_offset,
      )
    None => self.foreign_library_by_alias[declaration.name] = declaration.id
  }
  if value.logical_name.length() == 0 {
    self.diagnostics.push(
      EmptyForeignLogicalName(self.current_file, value.logical_name_offset),
    )
  } else if !semantic_utf8_is_valid(value.logical_name) {
    self.diagnostics.push(
      InvalidUtf8ForeignLogicalName(
        self.current_file,
        value.logical_name_offset,
      ),
    )
  }
  let member_start = self.foreign_functions.length()
  let method_start = self.methods.length()
  for source_member in value.members {
    let collected_method = self.add_method(
      declaration.id,
      ForeignLibraryMemberDecl,
      source_member.name,
      semantic_visibility(source_member.visibility),
      source_member.offset,
    )
    match self.first_method_name(method_start, collected_method.name) {
      Some(first) =>
        self.record_duplicate(
          ForeignLibraryMember,
          collected_method.name,
          first,
          self.current_file,
          collected_method.id,
          source_member.name_offset,
        )
      None => ()
    }
    self.collect_parameters(collected_method.id, None, source_member.parameters)
    self.callables.push({
      declaration: collected_method.id,
      return_type: self.lower_type(source_member.return_type),
    })
    if source_member.export_name.length() == 0 {
      self.diagnostics.push(
        EmptyForeignExportName(
          self.current_file,
          source_member.export_name_offset,
        ),
      )
    } else if !semantic_utf8_is_valid(source_member.export_name) {
      self.diagnostics.push(
        InvalidUtf8ForeignExportName(
          self.current_file,
          source_member.export_name_offset,
        ),
      )
    }
    self.foreign_functions.push({
      declaration: collected_method.id,
      library: declaration.id,
      export_name: source_member.export_name,
      export_name_offset: source_member.export_name_offset,
    })
  }
  self.foreign_libraries.push({
    declaration: declaration.id,
    logical_name: value.logical_name,
    logical_name_offset: value.logical_name_offset,
    members: {
      start: member_start,
      length: self.foreign_functions.length() - member_start,
    },
  })
}

///|
fn CollectionBuilder::collect_impl(
  self : CollectionBuilder,
  value : @parser.ImplDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    ImplDecl,
    None,
    ModuleVisible,
    value.offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  self.impls.push({
    declaration: declaration.id,
    foreign_: value.foreign_,
    trait_type: match value.trait_type {
      Some(type_) => Some(self.lower_type(type_))
      None => None
    },
    target_type: self.lower_type(value.target_type),
  })
  let method_start = self.methods.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if value.methods.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  for source_method in value.methods {
    let collected_method = self.add_method(
      declaration.id,
      ImplMethodDecl,
      source_method.name,
      ModuleVisible,
      source_method.offset,
    )
    let first = match seen {
      Some(table) => table.get(collected_method.name)
      None => self.first_method_name(method_start, collected_method.name)
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          ImplMethod,
          collected_method.name,
          first,
          self.current_file,
          collected_method.id,
          source_method.name_offset,
        )
      None =>
        match seen {
          Some(table) =>
            table[collected_method.name] = (
              collected_method.id,
              source_method.name_offset,
            )
          None => ()
        }
    }
    self.collect_generic_parameters(
      collected_method.id,
      source_method.type_parameters,
    )
    self.collect_parameters(
      collected_method.id,
      source_method.receiver,
      source_method.parameters,
    )
    self.callables.push({
      declaration: collected_method.id,
      return_type: self.lower_type(source_method.return_type),
    })
    self.lower_block_body(
      collected_method.id,
      ImplMethodBody,
      source_method.body,
      source_method.offset,
    )
  }
}

///|
priv struct CollectedDeriveOffsets {
  eq : UInt64?
  debug : UInt64?
  hash : UInt64?
  show : UInt64?
}

///|
fn CollectionBuilder::collect_derive_requests(
  self : CollectionBuilder,
  requests : Array[@parser.DeriveRequest],
) -> CollectedDeriveOffsets {
  if requests.length() == 0 {
    return { eq: None, debug: None, hash: None, show: None, }
  }
  let seen : Map[String, UInt64]? = if requests.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  let mut eq_offset : UInt64? = None
  let mut debug_offset : UInt64? = None
  let mut hash_offset : UInt64? = None
  let mut show_offset : UInt64? = None
  for index, request in requests {
    let first_offset = match seen {
      Some(table) => table.get(request.name)
      None => {
        let mut found = None
        for previous in 0..<index {
          if requests[previous].name == request.name {
            found = Some(requests[previous].offset)
            break
          }
        }
        found
      }
    }
    match first_offset {
      Some(first) => {
        self.diagnostics.push(
          DuplicateDerivedTrait(
            request.name,
            self.current_file,
            first,
            request.offset,
          ),
        )
        continue
      }
      None =>
        match seen {
          Some(table) => table[request.name] = request.offset
          None => ()
        }
    }
    if request.name == "Eq" {
      eq_offset = Some(request.offset)
    } else if request.name == "Debug" {
      debug_offset = Some(request.offset)
    } else if request.name == "Hash" {
      hash_offset = Some(request.offset)
    } else if request.name == "Show" {
      show_offset = Some(request.offset)
    } else {
      self.diagnostics.push(
        UnknownDerivedTrait(request.name, self.current_file, request.offset),
      )
    }
  }
  { eq: eq_offset, debug: debug_offset, hash: hash_offset, show: show_offset, }
}

///|
fn CollectionBuilder::collect_struct(
  self : CollectionBuilder,
  value : @parser.StructDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    StructDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_unique_module_name(
    ModuleType,
    self.type_bindings,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  self.collect_named_fields(declaration.id, None, value.fields, StructField)
  let derives = self.collect_derive_requests(value.derives)
  match derives.eq {
    Some(offset) =>
      for implementation in @parser.derived_struct_eq_impls(value, offset) {
        self.collect_impl(implementation)
      }
    None => ()
  }
  match derives.debug {
    Some(offset) =>
      self.collect_impl(@parser.derived_struct_debug_impl(value, offset))
    None => ()
  }
  match derives.hash {
    Some(offset) =>
      self.collect_impl(@parser.derived_struct_hash_impl(value, offset))
    None => ()
  }
  match derives.show {
    Some(offset) =>
      self.collect_impl(@parser.derived_struct_show_impl(value, offset))
    None => ()
  }
}

///|
fn CollectionBuilder::collect_enum(
  self : CollectionBuilder,
  value : @parser.EnumDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    EnumDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_unique_module_name(
    ModuleType,
    self.type_bindings,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  let variant_start = self.variants.length()
  let seen : Map[NameId, (UInt64, UInt64)]? = if value.variants.length() > 8 {
    Some(Map::default())
  } else {
    None
  }
  for source_variant in value.variants {
    let (kind, source_name, source_offset) = match source_variant {
      @parser.UnitVariant(name, offset) => (UnitVariantDecl, name, offset)
      @parser.TupleVariant(name, _, offset) => (TupleVariantDecl, name, offset)
      @parser.StructVariant(name, _, offset) =>
        (StructVariantDecl, name, offset)
    }
    let name = self.intern(source_name)
    let id = make_semantic_id(self.module_id, self.variants.length())
    let first = match seen {
      Some(table) => table.get(name)
      None => self.first_variant_name(variant_start, name)
    }
    match first {
      Some(first) =>
        self.record_duplicate(
          EnumVariant,
          name,
          first,
          self.current_file,
          id,
          source_offset,
        )
      None =>
        match seen {
          Some(table) => table[name] = (id, source_offset)
          None => ()
        }
    }
    let payload_types = match source_variant {
      @parser.TupleVariant(_, types, _) => self.lower_type_list(types)
      _ => empty_hir_span(self.type_arguments.length())
    }
    self.variants.push({
      id,
      declaration: declaration.id,
      kind,
      name,
      payload_types,
      offset: source_offset,
    })
    match source_variant {
      @parser.StructVariant(_, fields, _) =>
        self.collect_named_fields(
          declaration.id,
          Some(id),
          fields,
          VariantField,
        )
      _ => ()
    }
  }
  let derives = self.collect_derive_requests(value.derives)
  match derives.eq {
    Some(offset) =>
      for implementation in @parser.derived_enum_eq_impls(value, offset) {
        self.collect_impl(implementation)
      }
    None => ()
  }
  match derives.debug {
    Some(offset) =>
      self.collect_impl(@parser.derived_enum_debug_impl(value, offset))
    None => ()
  }
  match derives.hash {
    Some(offset) =>
      self.collect_impl(@parser.derived_enum_hash_impl(value, offset))
    None => ()
  }
  match derives.show {
    Some(offset) =>
      self.collect_impl(@parser.derived_enum_show_impl(value, offset))
    None => ()
  }
}

///|
fn CollectionBuilder::collect_type_alias(
  self : CollectionBuilder,
  value : @parser.TypeAliasDeclaration,
) -> Unit {
  let declaration = self.add_declaration(
    TypeAliasDecl,
    Some(value.name),
    semantic_visibility(value.visibility),
    value.offset,
  )
  self.bind_unique_module_name(
    ModuleType,
    self.type_bindings,
    declaration.name,
    declaration.id,
    value.name_offset,
  )
  self.collect_generic_parameters(declaration.id, value.type_parameters)
  self.aliases.push({
    declaration: declaration.id,
    target: self.lower_type(value.target),
  })
}

///|
fn CollectionBuilder::collect_import(
  self : CollectionBuilder,
  declaration : @parser.ImportDeclaration,
) -> Unit {
  let output = Buffer()
  for index, segment in declaration.path {
    if index > 0 {
      output.write_byte(b'.')
    }
    output.write_string_utf8(segment)
  }
  let import_alias = if declaration.wildcard || declaration.open_ {
    None
  } else {
    match declaration.import_alias {
      Some(name) => Some(name)
      None => Some(declaration.path[declaration.path.length() - 1])
    }
  }
  self.imports.push({
    path: @utf8.decode_lossy(output.to_bytes()),
    open_: declaration.open_,
    wildcard: declaration.wildcard,
    import_alias,
    import_alias_offset: declaration.import_alias_offset,
    file: self.current_file,
    offset: declaration.offset,
  })
}

///|
fn CollectionBuilder::collect_declaration(
  self : CollectionBuilder,
  declaration : @parser.Declaration,
) -> Unit {
  match declaration {
    @parser.Import(value) => self.collect_import(value)
    @parser.Builtin(value) => self.collect_builtin(value)
    @parser.Let(value) => self.collect_let(value)
    @parser.Trait(value) => self.collect_trait(value)
    @parser.Function(value) => self.collect_function(value)
    @parser.Test(value) => self.collect_test(value)
    @parser.Impl(value) => self.collect_impl(value)
    @parser.ForeignType(value) => self.collect_foreign_type(value)
    @parser.ForeignLibrary(value) => self.collect_foreign_library(value)
    @parser.Struct(value) => self.collect_struct(value)
    @parser.Enum(value) => self.collect_enum(value)
    @parser.TypeAlias(value) => self.collect_type_alias(value)
  }
}

///|
fn CollectionBuilder::finish(self : CollectionBuilder) -> CollectedModule {
  {
    module_id: self.module_id,
    preamble_declaration_count: self.preamble_declaration_count,
    files: self.files,
    file_paths: self.file_paths,
    file_sources: self.file_sources,
    test_files: self.test_files,
    declaration_files: self.declaration_files,
    body_files: self.body_files,
    names: self.names,
    declarations: self.declarations,
    methods: self.methods,
    declaration_locations: self.declaration_locations,
    fields: self.fields,
    variants: self.variants,
    generic_parameters: self.generic_parameters,
    parameters: self.parameters,
    generic_parameter_spans: self.generic_parameter_spans,
    generic_bounds: self.generic_bounds,
    parameter_spans: self.parameter_spans,
    callables: self.callables,
    tests: self.tests,
    imports: self.imports,
    builtins: self.builtins,
    lets: self.lets,
    aliases: self.aliases,
    impls: self.impls,
    foreign_types: self.foreign_types,
    foreign_libraries: self.foreign_libraries,
    foreign_functions: self.foreign_functions,
    type_syntax: self.type_syntax,
    type_syntax_files: self.type_syntax_files,
    type_arguments: self.type_arguments,
    lambda_parameters: self.lambda_parameters,
    lambda_parameter_files: self.lambda_parameter_files,
    lambdas: self.lambdas,
    bodies: self.bodies,
    body_by_declaration: self.body_by_declaration,
    expressions: self.expressions,
    expression_files: self.expression_files,
    expression_children: self.expression_children,
    explicit_call_type_argument_spans: self.explicit_call_type_argument_spans,
    explicit_call_type_arguments: self.explicit_call_type_arguments,
    blocks: self.blocks,
    block_files: self.block_files,
    block_items: self.block_items,
    block_item_files: self.block_item_files,
    object_fields: self.object_fields,
    object_field_files: self.object_field_files,
    patterns: self.patterns,
    pattern_files: self.pattern_files,
    pattern_children: self.pattern_children,
    pattern_fields: self.pattern_fields,
    pattern_field_files: self.pattern_field_files,
    pattern_arms: self.pattern_arms,
    pattern_arm_files: self.pattern_arm_files,
    arm_children: self.arm_children,
    diagnostics: self.diagnostics,
    name_lookup: self.name_lookup,
    type_bindings: self.type_bindings,
    trait_bindings: self.trait_bindings,
    value_bindings: self.value_bindings,
    value_binding_candidates: self.value_binding_candidates,
    foreign_library_by_alias: self.foreign_library_by_alias,
  }
}

///|
/// Consumes a lazy parser event stream, assigns deterministic source-order
/// identities, interns names, and builds the initial module namespaces.
fn CollectionBuilder::collect_file_events(
  self : CollectionBuilder,
  file : FileId,
  path : String,
  source : Bytes,
  events : Iter[@parser.ParseEvent],
) -> Unit {
  guard file_id_module(file) == self.module_id else {
    abort("source file belongs to another module")
  }
  self.current_file = file
  self.files.push(file)
  self.file_paths.push(path)
  self.file_sources.push(source)
  while events.next() is Some(event) {
    match event {
      @parser.Declaration(declaration) => self.collect_declaration(declaration)
      @parser.Diagnostic(diagnostic) =>
        self.diagnostics.push(ParseDiagnostic(self.current_file, diagnostic))
    }
  }
}

///|
pub fn collect_module(
  module_id : ModuleId,
  events : Iter[@parser.ParseEvent],
) -> CollectedModule {
  let builder = CollectionBuilder::new(module_id)
  builder.collect_file_events(make_file_id(module_id, 0), "", b"", events)
  builder.finish()
}

///|
/// Parses and collects a pre-tokenized module without materializing the full
/// parse-event stream.
pub fn collect_tokens(
  module_id : ModuleId,
  tokens : Iter[@tokenizer.Token],
) -> CollectedModule {
  collect_module(module_id, @parser.parse(tokens))
}

///|
/// Tokenizes, parses, and collects one module without materializing the full
/// parse-event stream.
pub fn collect_bytes(module_id : ModuleId, source : Bytes) -> CollectedModule {
  let builder = CollectionBuilder::new(module_id)
  builder.collect_file_events(
    make_file_id(module_id, 0),
    "",
    source,
    @parser.parse_bytes(source),
  )
  builder.finish()
}
