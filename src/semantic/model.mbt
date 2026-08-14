///|
pub enum CollectedDeclKind {
  BuiltinDecl
  LetDecl
  TraitDecl
  FunctionDecl
  TestDecl
  ImplDecl
  StructDecl
  EnumDecl
  TypeAliasDecl
} derive(Eq, Debug)

///|
pub enum CollectedMethodKind {
  TraitMethodDecl
  ImplMethodDecl
} derive(Eq, Debug)

///|
pub enum CollectedVariantKind {
  UnitVariantDecl
  TupleVariantDecl
  StructVariantDecl
} derive(Eq, Debug)

///|
pub enum CollectedParameterKind {
  ReceiverParameterDecl
  ValueParameterDecl
} derive(Eq, Debug)

///|
pub enum SemanticVisibility {
  ModuleVisible
  Public
} derive(Eq, Debug)

///|
fn semantic_visibility(
  visibility : @parser.DeclarationVisibility,
) -> SemanticVisibility {
  match visibility {
    @parser.ModuleVisible => ModuleVisible
    @parser.Public => Public
  }
}

///|
pub struct CollectedDeclaration {
  id : DeclId
  kind : CollectedDeclKind
  name : NameId
  visibility : SemanticVisibility
  offset : UInt64
} derive(Eq, Debug)

///|
pub fn CollectedDeclaration::has_name(self : CollectedDeclaration) -> Bool {
  self.name >= 0
}

///|
pub struct CollectedMethod {
  id : DeclId
  parent : DeclId
  kind : CollectedMethodKind
  name : NameId
  visibility : SemanticVisibility
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum CollectedDeclarationReference {
  TopLevelReference(CollectedDeclaration)
  MethodReference(CollectedMethod)
} derive(Eq, Debug)

///|
pub struct CollectedField {
  id : FieldId
  declaration : DeclId
  variant : VariantId?
  name : NameId
  type_ : HirTypeId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedVariant {
  id : VariantId
  declaration : DeclId
  kind : CollectedVariantKind
  name : NameId
  payload_types : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedGenericParameter {
  id : GenericParameterId
  declaration : DeclId
  index : Int
  name : NameId
  bounds : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedParameter {
  id : ParameterId
  declaration : DeclId
  index : Int
  kind : CollectedParameterKind
  name : NameId
  type_ : HirTypeId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedCallable {
  declaration : DeclId
  return_type : HirTypeId
} derive(Eq, Debug)

///|
pub struct CollectedImport {
  path : String
  open_ : Bool
  wildcard : Bool
  import_alias : String?
  import_alias_offset : UInt64
  file : FileId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedBuiltin {
  declaration : DeclId
  builtin_name : Bytes
} derive(Eq, Debug)

///|
pub struct CollectedLet {
  declaration : DeclId
  mutable_ : Bool
} derive(Eq, Debug)

///|
pub struct CollectedAlias {
  declaration : DeclId
  target : HirTypeId
} derive(Eq, Debug)

///|
pub struct CollectedImpl {
  declaration : DeclId
  foreign_ : Bool
  trait_type : HirTypeId?
  target_type : HirTypeId
} derive(Eq, Debug)

///|
pub enum BindingSpace {
  ModuleType
  ModuleTrait
  ModuleValue
  TraitMethod
  ImplMethod
  StructField
  EnumVariant
  VariantField
  GenericParameter
  Parameter
} derive(Eq, Debug)

///|
pub struct DuplicateNameDiagnostic {
  space : BindingSpace
  name : NameId
  first : UInt64
  duplicate : UInt64
  first_file : FileId
  duplicate_file : FileId
  first_offset : UInt64
  duplicate_offset : UInt64
} derive(Eq, Debug)

///|
pub struct DuplicateTestIdentityDiagnostic {
  file : FileId
  display_name : Bytes
  first_offset : UInt64
  duplicate_offset : UInt64
} derive(Eq, Debug)

///|
pub enum CollectionDiagnostic {
  ParseDiagnostic(FileId, @parser.ParseDiagnostic)
  DuplicateName(DuplicateNameDiagnostic)
  DuplicateTestIdentity(DuplicateTestIdentityDiagnostic)
  InvalidExpectedTestTrap(FileId, Bytes, UInt64)
  InvalidUtf8StringLiteral(FileId, UInt64)
  TestDeclarationOutsideTestFile(FileId, UInt64)
  UnknownDerivedTrait(String, FileId, UInt64)
  DuplicateDerivedTrait(String, FileId, UInt64, UInt64)
} derive(Eq, Debug)

///|
pub struct ValueBindingCandidate {
  declaration : DeclId
  mut next : Int
} derive(Eq, Debug)

///|
pub struct ValueBinding {
  head : Int
  mut tail : Int
  kind : CollectedDeclKind
  offset : UInt64
} derive(Eq, Debug)

///|
/// Frozen-by-convention output of declaration collection. Maps are built once
/// by the collector and are only read by subsequent semantic phases.
pub struct CollectedTest {
  declaration : DeclId
  display_name : Bytes
  expected_trap : Bytes?
  file : FileId
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct CollectedModule {
  module_id : ModuleId
  preamble_declaration_count : Int
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
  type_syntax : Array[HirTypeSyntax]
  type_syntax_files : Array[FileId]
  type_arguments : Array[HirTypeId]
  lambda_parameters : Array[HirLambdaParameter]
  lambda_parameter_files : Array[FileId]
  lambdas : Array[HirLambda]
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
  diagnostics : Array[CollectionDiagnostic]
  name_lookup : Map[String, NameId]
  type_bindings : Map[NameId, DeclId]
  trait_bindings : Map[NameId, DeclId]
  value_bindings : Map[NameId, ValueBinding]
  value_binding_candidates : Array[ValueBindingCandidate]
}

///|
pub fn CollectedModule::source_file(
  self : CollectedModule,
  file : FileId,
) -> ProgramFile? {
  for index, candidate in self.files {
    if candidate == file {
      return Some(
        ProgramFile::named(
          candidate,
          self.file_paths[index],
          self.file_sources[index],
        ),
      )
    }
  }
  None
}

///|
pub fn CollectedModule::file_is_test(
  self : CollectedModule,
  file : FileId,
) -> Bool {
  for test_file in self.test_files {
    if test_file == file {
      return true
    }
  }
  false
}

///|
pub fn CollectedModule::declaration_is_test_only(
  self : CollectedModule,
  declaration : DeclId,
) -> Bool {
  if semantic_id_module(declaration) != self.module_id {
    return false
  }
  let declaration_index = semantic_id_local(declaration)
  declaration_index >= 0 &&
  declaration_index < self.declaration_files.length() &&
  self.file_is_test(self.declaration_files[declaration_index])
}

///|
pub fn CollectedModule::declaration_location(
  self : CollectedModule,
  declaration : DeclId,
) -> SourceLocation? {
  match self.declaration(declaration) {
    Some(TopLevelReference(value)) =>
      Some({
        file: self.declaration_files[semantic_id_local(declaration)],
        offset: value.offset,
      })
    Some(MethodReference(value)) =>
      Some({
        file: self.declaration_files[semantic_id_local(declaration)],
        offset: value.offset,
      })
    None => None
  }
}

///|
pub fn CollectedModule::callable_return_location(
  self : CollectedModule,
  declaration : DeclId,
) -> SourceLocation? {
  for callable in self.callables {
    if callable.declaration == declaration {
      return self.type_syntax_location(callable.return_type)
    }
  }
  None
}

///|
pub fn CollectedModule::type_syntax_location(
  self : CollectedModule,
  syntax : HirTypeId,
) -> SourceLocation? {
  if syntax < 0 || syntax >= self.type_syntax.length() {
    return None
  }
  Some({
    file: self.type_syntax_files[syntax],
    offset: self.type_syntax[syntax].offset(),
  })
}

///|
pub fn CollectedModule::expression_location(
  self : CollectedModule,
  expression : ExprId,
) -> SourceLocation? {
  if expression < 0 || expression >= self.expressions.length() {
    return None
  }
  Some({
    file: self.expression_files[expression],
    offset: self.expressions[expression].offset(),
  })
}

///|
pub fn CollectedModule::pattern_location(
  self : CollectedModule,
  pattern : PatternId,
) -> SourceLocation? {
  if pattern < 0 || pattern >= self.patterns.length() {
    return None
  }
  Some({
    file: self.pattern_files[pattern],
    offset: self.patterns[pattern].offset(),
  })
}

///|
pub fn CollectedModule::block_location(
  self : CollectedModule,
  block : BlockId,
) -> SourceLocation? {
  if block < 0 || block >= self.blocks.length() {
    return None
  }
  Some({ file: self.block_files[block], offset: self.blocks[block].offset })
}

///|
pub fn CollectedModule::pattern_arm_location(
  self : CollectedModule,
  arm : PatternArmId,
) -> SourceLocation? {
  if arm < 0 || arm >= self.pattern_arms.length() {
    return None
  }
  Some({
    file: self.pattern_arm_files[arm],
    offset: self.pattern_arms[arm].offset,
  })
}

///|
pub fn CollectedModule::body_location(
  self : CollectedModule,
  body : BodyId,
) -> SourceLocation? {
  if semantic_id_module(body) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(body)
  if local_index < 0 || local_index >= self.bodies.length() {
    return None
  }
  Some({
    file: self.body_files[local_index],
    offset: self.bodies[local_index].offset,
  })
}

///|
pub fn CollectedModule::declaration(
  self : CollectedModule,
  id : DeclId,
) -> CollectedDeclarationReference? {
  if semantic_id_module(id) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(id)
  if local_index < 0 || local_index >= self.declaration_locations.length() {
    return None
  }
  let location = self.declaration_locations[local_index]
  if location >= 0 {
    Some(TopLevelReference(self.declarations[location]))
  } else {
    Some(MethodReference(self.methods[-location - 1]))
  }
}

///|
pub fn CollectedModule::generic_parameters_of(
  self : CollectedModule,
  declaration : DeclId,
) -> HirSpan {
  guard semantic_id_module(declaration) == self.module_id else {
    abort("generic-parameter owner belongs to another module")
  }
  self.generic_parameter_spans[semantic_id_local(declaration)]
}

///|
pub fn CollectedModule::parameters_of(
  self : CollectedModule,
  declaration : DeclId,
) -> HirSpan {
  guard semantic_id_module(declaration) == self.module_id else {
    abort("parameter owner belongs to another module")
  }
  self.parameter_spans[semantic_id_local(declaration)]
}

///|
pub fn CollectedModule::find_name(
  self : CollectedModule,
  name : String,
) -> NameId? {
  self.name_lookup.get(name)
}

///|
pub fn CollectedModule::name(self : CollectedModule, id : NameId) -> String {
  self.names[id]
}

///|
pub fn CollectedModule::lookup_type(
  self : CollectedModule,
  name : String,
) -> DeclId? {
  match self.find_name(name) {
    Some(id) => self.type_bindings.get(id)
    None => None
  }
}

///|
pub fn CollectedModule::lookup_trait(
  self : CollectedModule,
  name : String,
) -> DeclId? {
  match self.find_name(name) {
    Some(id) => self.trait_bindings.get(id)
    None => None
  }
}

///|
pub fn CollectedModule::lookup_value(
  self : CollectedModule,
  name : String,
) -> DeclId? {
  match self.find_name(name) {
    Some(id) =>
      match self.value_bindings.get(id) {
        Some(binding) =>
          Some(self.value_binding_candidates[binding.head].declaration)
        None => None
      }
    None => None
  }
}

///|
/// Iterates all declarations in one value binding in source order. Initial
/// Dew permits overload sets for builtin declarations.
pub fn CollectedModule::value_declarations(
  self : CollectedModule,
  name : String,
) -> Iter[DeclId] {
  let mut cursor = match self.find_name(name) {
    Some(id) =>
      match self.value_bindings.get(id) {
        Some(binding) => binding.head
        None => -1
      }
    None => -1
  }
  Iter::new(fn() {
    if cursor < 0 {
      return None
    }
    let candidate = self.value_binding_candidates[cursor]
    cursor = candidate.next
    Some(candidate.declaration)
  })
}
