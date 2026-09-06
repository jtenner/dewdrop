///|
let any_type_name = 0

///|
let trait_type_name = 1

///|
priv struct TypeResolver {
  collected : CollectedModule
  imports : ModuleImportScope?
  interner : ResolvedTypeInterner
  syntax_types : Array[ResolvedTypeId]
  declaration_types : Array[ResolvedTypeId]
  generic_parameter_types : Array[ResolvedTypeId]
  generic_bound_types : Array[ResolvedTypeId]
  parameter_types : Array[ResolvedTypeId]
  callable_return_types : Array[ResolvedTypeId]
  callable_function_types : Array[ResolvedTypeId]
  lambda_parameter_types : Array[ResolvedTypeId]
  lambda_return_types : Array[ResolvedTypeId]
  lambda_function_types : Array[ResolvedTypeId]
  explicit_call_type_arguments : Array[ResolvedTypeId]
  field_types : Array[ResolvedTypeId]
  variant_payloads : Array[HirSpan]
  signature_type_lists : Array[ResolvedTypeId]
  alias_target_types : Array[ResolvedTypeId]
  impl_trait_types : Array[ResolvedTypeId]
  impl_target_types : Array[ResolvedTypeId]
  alias_dependencies : Array[HirSpan]
  alias_dependency_declarations : Array[DeclId]
  alias_is_cyclic : Array[Bool]
  alias_cycles : Array[HirSpan]
  alias_cycle_declarations : Array[DeclId]
  normalizations : Array[ResolvedTypeId]
  diagnostics : Array[TypeDiagnostic]
  alias_indices : Map[DeclId, Int]
  task_syntax : Array[HirTypeId]
  task_states : Array[Int]
  task_expectations : Array[Int]
  task_constructor_positions : Array[Bool]
  application_scratch : Array[ResolvedTypeId]
  computed_active : Array[Bool]
  computed_depth : Int
  import_type_memos : Array[Array[ResolvedTypeId]]
  import_task_interfaces : Array[Int]
  import_task_types : Array[ResolvedTypeId]
  import_task_states : Array[Int]
  import_result_starts : Array[Int]
  import_results : Array[ResolvedTypeId]
  import_application_scratch : Array[ResolvedTypeId]
  type_visit_stack : Array[ResolvedTypeId]
  mut type_visit_marks : Array[Int]
  alias_visit_marks : Array[Int]
  alias_dependency_scratch : Array[Int]
  normalization_task_types : Array[ResolvedTypeId]
  normalization_task_states : Array[Int]
  normalization_result_starts : Array[Int]
  normalization_results : Array[ResolvedTypeId]
  normalization_application_scratch : Array[ResolvedTypeId]
  substitution_task_types : Array[ResolvedTypeId]
  substitution_task_states : Array[Int]
  substitution_result_starts : Array[Int]
  substitution_results : Array[ResolvedTypeId]
  substitution_application_scratch : Array[ResolvedTypeId]
  substitution_marks : Array[Int]
  substitution_values : Array[ResolvedTypeId]
  alias_expansion_limited : Array[Bool]
  mut visit_generation : Int
  mut substitution_generation : Int
  mut alias_expansion_work : Int
  mut alias_expansion_limit : Int
}

///|
fn TypeResolver::new(
  collected : CollectedModule,
  imports : ModuleImportScope?,
) -> TypeResolver {
  let interner = ResolvedTypeInterner::new()
  ignore(interner.intern_nominal(standard_array_type_declaration()))
  let generic_parameter_types : Array[ResolvedTypeId] = []
  for parameter in collected.generic_parameters {
    generic_parameter_types.push(interner.intern_generic(parameter.id))
  }
  let alias_indices : Map[DeclId, Int] = Map::default()
  for index, alias_entry in collected.aliases {
    alias_indices[alias_entry.declaration] = index
  }
  let import_type_memos : Array[Array[ResolvedTypeId]] = []
  match imports {
    Some(scope) =>
      for _ in scope.interfaces {
        import_type_memos.push([])
      }
    None => ()
  }
  let declaration_types = Array::make(
    collected.declaration_locations.length(),
    interner.error_type,
  )
  for declaration in collected.declarations {
    declaration_types[semantic_id_local(declaration.id)] = match
      declaration.kind {
      StructDecl | EnumDecl | TypeAliasDecl | ForeignTypeDecl =>
        interner.intern_nominal(declaration.id)
      TraitDecl => interner.intern_trait(declaration.id)
      _ => interner.error_type
    }
  }
  {
    collected,
    imports,
    interner,
    syntax_types: Array::make(collected.type_syntax.length(), -1),
    declaration_types,
    generic_parameter_types,
    generic_bound_types: Array::make(collected.generic_bounds.length(), -1),
    parameter_types: Array::make(collected.parameters.length(), -1),
    callable_return_types: Array::make(collected.callables.length(), -1),
    callable_function_types: Array::make(collected.callables.length(), -1),
    lambda_parameter_types: Array::make(
      collected.lambda_parameters.length(),
      -1,
    ),
    lambda_return_types: Array::make(collected.lambdas.length(), -1),
    lambda_function_types: Array::make(collected.lambdas.length(), -1),
    explicit_call_type_arguments: Array::make(
      collected.explicit_call_type_arguments.length(),
      -1,
    ),
    field_types: Array::make(collected.fields.length(), -1),
    variant_payloads: Array::make(
      collected.variants.length(),
      empty_hir_span(0),
    ),
    signature_type_lists: [],
    alias_target_types: Array::make(collected.aliases.length(), -1),
    impl_trait_types: Array::make(collected.impls.length(), -1),
    impl_target_types: Array::make(collected.impls.length(), -1),
    alias_dependencies: Array::make(
      collected.aliases.length(),
      empty_hir_span(0),
    ),
    alias_dependency_declarations: [],
    alias_is_cyclic: Array::make(collected.aliases.length(), false),
    alias_cycles: [],
    alias_cycle_declarations: [],
    normalizations: [],
    diagnostics: [],
    alias_indices,
    task_syntax: [],
    task_states: [],
    task_expectations: [],
    task_constructor_positions: [],
    application_scratch: [],
    computed_active: Array::make(collected.type_syntax.length(), false),
    computed_depth: 0,
    import_type_memos,
    import_task_interfaces: [],
    import_task_types: [],
    import_task_states: [],
    import_result_starts: [],
    import_results: [],
    import_application_scratch: [],
    type_visit_stack: [],
    type_visit_marks: [],
    alias_visit_marks: Array::make(collected.aliases.length(), 0),
    alias_dependency_scratch: [],
    normalization_task_types: [],
    normalization_task_states: [],
    normalization_result_starts: [],
    normalization_results: [],
    normalization_application_scratch: [],
    substitution_task_types: [],
    substitution_task_states: [],
    substitution_result_starts: [],
    substitution_results: [],
    substitution_application_scratch: [],
    substitution_marks: [],
    substitution_values: [],
    alias_expansion_limited: Array::make(collected.aliases.length(), false),
    visit_generation: 0,
    substitution_generation: 0,
    alias_expansion_work: 0,
    alias_expansion_limit: -1,
  }
}

///|
fn TypeResolver::diagnose(
  self : TypeResolver,
  diagnostic : TypeDiagnostic,
) -> Unit {
  self.diagnostics.push(diagnostic)
}

///|
fn TypeResolver::push_import_type_task(
  self : TypeResolver,
  interface_index : Int,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.import_task_interfaces.push(interface_index)
  self.import_task_types.push(type_)
  self.import_task_states.push(state)
  self.import_result_starts.push(result_start)
}

///|
fn TypeResolver::import_interface_type(
  self : TypeResolver,
  interface_index : Int,
  root : ResolvedTypeId,
) -> ResolvedTypeId {
  if self.import_type_memos[interface_index].length() == 0 {
    let source = self.imports.unwrap().interfaces[interface_index].unwrap().resolved_types
    self.import_type_memos[interface_index] = Array::make(
      source.types.length(),
      -1,
    )
  }
  let cached = self.import_type_memos[interface_index][root]
  if cached >= 0 {
    return cached
  }
  self.import_task_interfaces.clear()
  self.import_task_types.clear()
  self.import_task_states.clear()
  self.import_result_starts.clear()
  self.import_results.clear()
  self.push_import_type_task(interface_index, root, 0, 0)
  while self.import_task_types.length() > 0 {
    let source_interface = self.import_task_interfaces.pop().unwrap()
    let source_type = self.import_task_types.pop().unwrap()
    let state = self.import_task_states.pop().unwrap()
    let result_start = self.import_result_starts.pop().unwrap()
    let memo = self.import_type_memos[source_interface][source_type]
    if state == 0 && memo >= 0 {
      self.import_results.push(memo)
      continue
    }
    let source = self.imports.unwrap().interfaces[source_interface].unwrap().resolved_types
    if state == 0 {
      match source.types[source_type] {
        MemberTypeProjection(owner, _, _) => {
          self.push_import_type_task(
            source_interface,
            source_type,
            4,
            self.import_results.length(),
          )
          self.push_import_type_task(source_interface, owner, 0, 0)
        }
        ErrorType => {
          self.import_type_memos[source_interface][source_type] = self.interner.error_type
          self.import_results.push(self.interner.error_type)
        }
        PrimitiveType(primitive) => {
          let imported = self.interner.intern_primitive(primitive)
          self.import_type_memos[source_interface][source_type] = imported
          self.import_results.push(imported)
        }
        GenericParameterType(parameter) => {
          let imported = self.interner.intern_generic(parameter)
          self.import_type_memos[source_interface][source_type] = imported
          self.import_results.push(imported)
        }
        NominalType(declaration) => {
          let imported = self.interner.intern_nominal(declaration)
          self.import_type_memos[source_interface][source_type] = imported
          self.import_results.push(imported)
        }
        TraitType(declaration) => {
          let imported = self.interner.intern_trait(declaration)
          self.import_type_memos[source_interface][source_type] = imported
          self.import_results.push(imported)
        }
        SelfType(declaration) => {
          let imported = self.interner.intern_self(declaration)
          self.import_type_memos[source_interface][source_type] = imported
          self.import_results.push(imported)
        }
        ProductType(fields) => {
          self.push_import_type_task(
            source_interface,
            source_type,
            3,
            self.import_results.length(),
          )
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_import_type_task(
              source_interface,
              source.type_arguments[fields.start + index],
              0,
              0,
            )
          }
        }
        AppliedType(base, arguments) => {
          self.push_import_type_task(
            source_interface,
            source_type,
            1,
            self.import_results.length(),
          )
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_import_type_task(
              source_interface,
              source.type_arguments[arguments.start + index],
              0,
              0,
            )
          }
          self.push_import_type_task(source_interface, base, 0, 0)
        }
        FunctionType(parameters, result) => {
          self.push_import_type_task(
            source_interface,
            source_type,
            2,
            self.import_results.length(),
          )
          self.push_import_type_task(source_interface, result, 0, 0)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_import_type_task(
              source_interface,
              source.type_arguments[parameters.start + index],
              0,
              0,
            )
          }
        }
      }
    } else if state == 4 {
      let (operation, selector) = match source.types[source_type] {
        MemberTypeProjection(_, operation, selector) => (operation, selector)
        _ => abort("INV-001 imported projection task has the wrong type")
      }
      let imported = self.interner.intern_member_projection(
        self.import_results[result_start],
        operation,
        selector,
      )
      self.import_type_memos[source_interface][source_type] = imported
      self.import_results.truncate(result_start)
      self.import_results.push(imported)
    } else if state == 1 {
      let arguments = match source.types[source_type] {
        AppliedType(_, arguments) => arguments
        _ => abort("imported type finish task is not applied")
      }
      let imported_base = self.import_results[result_start]
      self.import_application_scratch.clear()
      for index in 0..<arguments.length {
        self.import_application_scratch.push(
          self.import_results[result_start + index + 1],
        )
      }
      let imported = self.interner.intern_applied(
        imported_base,
        self.import_application_scratch,
      )
      self.import_type_memos[source_interface][source_type] = imported
      self.import_results.truncate(result_start)
      self.import_results.push(imported)
    } else if state == 2 {
      let parameters = match source.types[source_type] {
        FunctionType(parameters, _) => parameters
        _ => abort("imported type finish task is not a function")
      }
      self.import_application_scratch.clear()
      for index in 0..<parameters.length {
        self.import_application_scratch.push(
          self.import_results[result_start + index],
        )
      }
      let imported = self.interner.intern_function(
        self.import_application_scratch,
        self.import_results[result_start + parameters.length],
      )
      self.import_type_memos[source_interface][source_type] = imported
      self.import_results.truncate(result_start)
      self.import_results.push(imported)
    } else {
      let fields = match source.types[source_type] {
        ProductType(fields) => fields
        _ => abort("imported type finish task is not a product")
      }
      self.import_application_scratch.clear()
      for index in 0..<fields.length {
        self.import_application_scratch.push(
          self.import_results[result_start + index],
        )
      }
      let imported = self.interner.intern_product(
        self.import_application_scratch,
      )
      self.import_type_memos[source_interface][source_type] = imported
      self.import_results.truncate(result_start)
      self.import_results.push(imported)
    }
  }
  guard self.import_results.length() == 1 else {
    abort("imported type traversal produced an invalid result stack")
  }
  self.import_results[0]
}

///|
fn TypeResolver::generic_in_span(
  self : TypeResolver,
  span : HirSpan,
  name : NameId,
) -> GenericParameterId? {
  for index in span.start..<(span.start + span.length) {
    let parameter = self.collected.generic_parameters[index]
    if parameter.name == name {
      return Some(parameter.id)
    }
  }
  None
}

///|
fn TypeResolver::generic_parameter(
  self : TypeResolver,
  owner : DeclId,
  name : NameId,
) -> GenericParameterId? {
  let own = self.collected.generic_parameters_of(owner)
  match self.generic_in_span(own, name) {
    Some(parameter) => return Some(parameter)
    None => ()
  }
  match self.collected.declaration(owner) {
    Some(MethodReference(declaration)) => {
      let parent = self.collected.generic_parameters_of(declaration.parent)
      self.generic_in_span(parent, name)
    }
    _ => None
  }
}

///|
fn TypeResolver::declaration_visible(
  self : TypeResolver,
  owner : DeclId,
  declaration : DeclId,
) -> Bool {
  self.collected.declaration_is_test_only(owner) ||
  !self.collected.declaration_is_test_only(declaration)
}

///|
fn TypeResolver::self_context(self : TypeResolver, owner : DeclId) -> DeclId? {
  match self.collected.declaration(owner) {
    Some(MethodReference(declaration)) => Some(declaration.parent)
    _ => None
  }
}

///|
fn TypeResolver::declaration_arity(
  self : TypeResolver,
  declaration : DeclId,
) -> Int {
  if semantic_id_module(declaration) == self.collected.module_id {
    self.collected.generic_parameters_of(declaration).length
  } else {
    match self.imports {
      Some(imports) => {
        for imported in imports.declarations {
          if imported.declaration == declaration {
            return imported.generic_parameter_count
          }
        }
        0
      }
      None => 0
    }
  }
}

///|
fn TypeResolver::constructor_arity(
  self : TypeResolver,
  type_ : ResolvedTypeId,
) -> Int? {
  match self.interner.types[type_] {
    ErrorType => None
    PrimitiveType(_) => Some(0)
    NominalType(declaration) | TraitType(declaration) =>
      Some(self.declaration_arity(declaration))
    GenericParameterType(_)
    | SelfType(_)
    | ProductType(_)
    | AppliedType(_, _)
    | MemberTypeProjection(_, _, _)
    | FunctionType(_, _) => None
  }
}

///|
fn TypeResolver::resolve_any_named_type(
  self : TypeResolver,
  owner : DeclId,
  self_owner : DeclId?,
  name : NameId,
  offset : UInt64,
) -> ResolvedTypeId {
  match self.generic_parameter(owner, name) {
    Some(parameter) => return self.interner.intern_generic(parameter)
    None => ()
  }
  let spelling = self.collected.name(name)
  if spelling == "Self" {
    return match self_owner {
      Some(declaration) => self.interner.intern_self(declaration)
      None => {
        self.diagnose(SelfOutsideContext(owner, offset))
        self.interner.error_type
      }
    }
  }
  match primitive_type_from_name(spelling) {
    Some(primitive) => return self.interner.intern_primitive(primitive)
    None => ()
  }
  match self.collected.type_bindings.get(name) {
    Some(declaration) if self.declaration_visible(owner, declaration) =>
      return self.interner.intern_nominal(declaration)
    _ => ()
  }
  match self.collected.trait_bindings.get(name) {
    Some(declaration) if self.declaration_visible(owner, declaration) =>
      return self.interner.intern_trait(declaration)
    _ => ()
  }
  match self.imports {
    Some(imports) => {
      match imports.lookup_type(spelling) {
        Some(binding) =>
          return self.import_interface_type(
            binding.interface_index,
            binding.semantic_type,
          )
        None => ()
      }
      match imports.lookup_trait(spelling) {
        Some(binding) =>
          return self.import_interface_type(
            binding.interface_index,
            binding.semantic_type,
          )
        None => ()
      }
      if imports.type_is_ambiguous(spelling) ||
        imports.trait_is_ambiguous(spelling) {
        self.diagnose(AmbiguousImportedType(name, owner, offset))
        return self.interner.error_type
      }
    }
    None => ()
  }
  self.diagnose(UnknownType(name, owner, offset))
  self.interner.error_type
}

///|
fn TypeResolver::resolve_trait_named_type(
  self : TypeResolver,
  owner : DeclId,
  name : NameId,
  offset : UInt64,
) -> ResolvedTypeId {
  match self.collected.trait_bindings.get(name) {
    Some(declaration) => return self.interner.intern_trait(declaration)
    None => ()
  }
  let spelling = self.collected.name(name)
  match self.imports {
    Some(imports) => {
      match imports.lookup_trait(spelling) {
        Some(binding) =>
          return self.import_interface_type(
            binding.interface_index,
            binding.semantic_type,
          )
        None => ()
      }
      if imports.trait_is_ambiguous(spelling) {
        self.diagnose(AmbiguousImportedTrait(name, owner, offset))
        return self.interner.error_type
      }
    }
    None => ()
  }
  let imported_type = match self.imports {
    Some(imports) => imports.lookup_type(spelling) is Some(_)
    None => false
  }
  if self.collected.type_bindings.contains(name) ||
    imported_type ||
    primitive_type_from_name(spelling) is Some(_) ||
    self.generic_parameter(owner, name) is Some(_) ||
    spelling == "Self" {
    self.diagnose(ExpectedTraitType(name, owner, offset))
  } else {
    self.diagnose(UnknownTrait(name, owner, offset))
  }
  self.interner.error_type
}

///|
fn TypeResolver::qualified_import_binding(
  self : TypeResolver,
  module_alias : NameId,
  name : NameId,
  expectation : Int,
) -> ImportedDeclarationBinding? {
  let imports = match self.imports {
    Some(value) => value
    None => return None
  }
  let interface_index = match
    imports.lookup_alias(self.collected.name(module_alias)) {
    Some(value) => value
    None => return None
  }
  if expectation == trait_type_name {
    imports.lookup_module_trait(interface_index, self.collected.name(name))
  } else {
    match
      imports.lookup_module_type(interface_index, self.collected.name(name)) {
      Some(binding) => Some(binding)
      None =>
        imports.lookup_module_trait(interface_index, self.collected.name(name))
    }
  }
}

///|
fn TypeResolver::resolve_qualified_type(
  self : TypeResolver,
  owner : DeclId,
  module_alias : NameId,
  name : NameId,
  offset : UInt64,
  name_offset : UInt64,
  expectation : Int,
  constructor_position : Bool,
) -> ResolvedTypeId {
  let binding = match
    self.qualified_import_binding(module_alias, name, expectation) {
    Some(value) => value
    None => {
      if expectation == trait_type_name {
        self.diagnose(UnknownTrait(name, owner, name_offset))
      } else {
        self.diagnose(UnknownType(name, owner, name_offset))
      }
      return self.interner.error_type
    }
  }
  let type_ = self.import_interface_type(
    binding.interface_index,
    binding.semantic_type,
  )
  if !constructor_position &&
    expectation != trait_type_name &&
    binding.source_kind == TypeAliasDecl &&
    binding.generic_parameter_count > 0 {
    self.diagnose(
      TypeArityMismatch(
        type_,
        binding.generic_parameter_count,
        0,
        owner,
        offset,
      ),
    )
    return self.interner.error_type
  }
  if constructor_position || type_ == self.interner.error_type {
    return type_
  }
  match self.constructor_arity(type_) {
    Some(0) | None => type_
    Some(expected) => {
      self.diagnose(TypeArityMismatch(type_, expected, 0, owner, offset))
      self.interner.error_type
    }
  }
}

///|
fn TypeResolver::resolve_named_type(
  self : TypeResolver,
  owner : DeclId,
  self_owner : DeclId?,
  name : NameId,
  offset : UInt64,
  expectation : Int,
  constructor_position : Bool,
) -> ResolvedTypeId {
  let type_ = if expectation == trait_type_name {
    self.resolve_trait_named_type(owner, name, offset)
  } else {
    self.resolve_any_named_type(owner, self_owner, name, offset)
  }
  if !constructor_position && expectation != trait_type_name {
    match self.imports {
      Some(imports) =>
        match imports.lookup_type(self.collected.name(name)) {
          Some(binding) if binding.source_kind == TypeAliasDecl &&
            binding.generic_parameter_count > 0 => {
            self.diagnose(
              TypeArityMismatch(
                type_,
                binding.generic_parameter_count,
                0,
                owner,
                offset,
              ),
            )
            return self.interner.error_type
          }
          _ => ()
        }
      None => ()
    }
  }
  if constructor_position || type_ == self.interner.error_type {
    return type_
  }
  match self.constructor_arity(type_) {
    Some(0) | None => type_
    Some(expected) => {
      self.diagnose(TypeArityMismatch(type_, expected, 0, owner, offset))
      self.interner.error_type
    }
  }
}

///|
fn TypeResolver::push_type_task(
  self : TypeResolver,
  syntax : HirTypeId,
  state : Int,
  expectation : Int,
  constructor_position : Bool,
) -> Unit {
  self.task_syntax.push(syntax)
  self.task_states.push(state)
  self.task_expectations.push(expectation)
  self.task_constructor_positions.push(constructor_position)
}

///|
fn TypeResolver::imported_alias_binding(
  self : TypeResolver,
  syntax : HirTypeId,
) -> ImportedDeclarationBinding? {
  let binding = match self.collected.type_syntax[syntax] {
    NamedTypeSyntax(name, _) =>
      match self.imports {
        Some(imports) => imports.lookup_type(self.collected.name(name))
        None => None
      }
    QualifiedTypeSyntax(module_alias, name, _, _) =>
      self.qualified_import_binding(module_alias, name, any_type_name)
    _ => None
  }
  match binding {
    Some(value) if value.source_kind == TypeAliasDecl => Some(value)
    _ => None
  }
}

///|
fn TypeResolver::declaration_is_foreign_type(
  self : TypeResolver,
  declaration : DeclId,
) -> Bool {
  match self.collected.declaration(declaration) {
    Some(TopLevelReference(value)) => return value.kind == ForeignTypeDecl
    Some(MethodReference(_)) => return false
    None => ()
  }
  match self.imports {
    Some(scope) =>
      match scope.declaration_bindings.get(declaration) {
        Some(index) if index >= 0 && index < scope.declarations.length() =>
          scope.declarations[index].source_kind == ForeignTypeDecl
        _ => false
      }
    None => false
  }
}

///|
fn TypeResolver::nullable_ref_intrinsic_owner(
  _self : TypeResolver,
  owner : DeclId,
) -> Bool {
  match standard_wasm_intrinsics_operation(owner) {
    WasmRefNull | WasmRefIsNull | WasmRefAsNonNull => true
    _ => false
  }
}

///|
fn TypeResolver::valid_nullable_ref_argument(
  self : TypeResolver,
  owner : DeclId,
  argument : ResolvedTypeId,
) -> Bool {
  if argument == self.interner.error_type {
    return true
  }
  match self.interner.types[argument] {
    NominalType(declaration) => self.declaration_is_foreign_type(declaration)
    GenericParameterType(_) => self.nullable_ref_intrinsic_owner(owner)
    _ => false
  }
}

///|
fn TypeResolver::finish_applied_type(
  self : TypeResolver,
  owner : DeclId,
  syntax : HirTypeId,
  base_syntax : HirTypeId,
  arguments : HirSpan,
  offset : UInt64,
) -> Unit {
  let base = self.syntax_types[base_syntax]
  if base == self.interner.error_type {
    self.syntax_types[syntax] = base
    return
  }
  match self.imported_alias_binding(base_syntax) {
    Some(binding) => {
      if binding.generic_parameter_count != arguments.length {
        self.diagnose(
          TypeArityMismatch(
            base,
            binding.generic_parameter_count,
            arguments.length,
            owner,
            offset,
          ),
        )
        self.syntax_types[syntax] = self.interner.error_type
        return
      }
      self.application_scratch.clear()
      for index in arguments.start..<(arguments.start + arguments.length) {
        self.application_scratch.push(
          self.syntax_types[self.collected.type_arguments[index]],
        )
      }
      let target = self.import_interface_type(
        binding.interface_index,
        binding.semantic_type,
      )
      self.syntax_types[syntax] = self.substitute_imported_alias_target(
        binding,
        target,
        self.application_scratch,
      )
      return
    }
    None => ()
  }
  let expected = match self.constructor_arity(base) {
    Some(value) => value
    None => {
      self.diagnose(TypeNotApplicable(base, owner, offset))
      self.syntax_types[syntax] = self.interner.error_type
      return
    }
  }
  if expected != arguments.length {
    self.diagnose(
      TypeArityMismatch(base, expected, arguments.length, owner, offset),
    )
    self.syntax_types[syntax] = self.interner.error_type
    return
  }
  self.application_scratch.clear()
  for index in arguments.start..<(arguments.start + arguments.length) {
    self.application_scratch.push(
      self.syntax_types[self.collected.type_arguments[index]],
    )
  }
  match self.interner.types[base] {
    NominalType(declaration) if declaration ==
      standard_nullable_ref_type_declaration() => {
      let argument = self.application_scratch[0]
      if !self.valid_nullable_ref_argument(owner, argument) {
        self.diagnose(NullableRefRequiresForeignType(argument, owner, offset))
        self.syntax_types[syntax] = self.interner.error_type
        return
      }
    }
    _ => ()
  }
  self.syntax_types[syntax] = self.interner.intern_applied(
    base,
    self.application_scratch,
  )
}

///|
fn TypeResolver::resolve_syntax(
  self : TypeResolver,
  owner : DeclId,
  syntax : HirTypeId,
  expectation : Int,
) -> ResolvedTypeId {
  if self.computed_active[syntax] || self.computed_depth >= 256 {
    self.diagnose(
      ComputedTypeFailure(
        owner,
        if self.computed_active[syntax] {
          "CT-033 cyclic computed type"
        } else {
          "CT-034 computed type nesting limit exceeded"
        },
        self.collected.type_syntax[syntax].offset(),
      ),
    )
    return self.interner.error_type
  }
  self.computed_active[syntax] = true
  let self_owner = self.self_context(owner)
  self.task_syntax.clear()
  self.task_states.clear()
  self.task_expectations.clear()
  self.task_constructor_positions.clear()
  self.push_type_task(syntax, 0, expectation, false)
  while self.task_syntax.length() > 0 {
    let current = self.task_syntax.pop().unwrap()
    let state = self.task_states.pop().unwrap()
    let current_expectation = self.task_expectations.pop().unwrap()
    let constructor_position = self.task_constructor_positions.pop().unwrap()
    match self.collected.type_syntax[current] {
      ComputedTypeSyntax(target, selector, offset) =>
        self.syntax_types[current] = self.resolve_computed_type(
          owner, target, selector, offset,
        )
      NamedTypeSyntax(name, offset) =>
        self.syntax_types[current] = self.resolve_named_type(
          owner, self_owner, name, offset, current_expectation, constructor_position,
        )
      QualifiedTypeSyntax(module_alias, name, offset, name_offset) =>
        self.syntax_types[current] = self.resolve_qualified_type(
          owner, module_alias, name, offset, name_offset, current_expectation, constructor_position,
        )
      ProductTypeSyntax(fields, _) =>
        if state == 0 {
          self.push_type_task(
            current, 1, current_expectation, constructor_position,
          )
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_type_task(
              self.collected.type_arguments[fields.start + index],
              0,
              any_type_name,
              false,
            )
          }
        } else {
          self.application_scratch.clear()
          for index in 0..<fields.length {
            self.application_scratch.push(
              self.syntax_types[self.collected.type_arguments[fields.start +
              index]],
            )
          }
          self.syntax_types[current] = self.interner.intern_product(
            self.application_scratch,
          )
        }
      AppliedTypeSyntax(base, arguments, offset) =>
        if state == 0 {
          self.push_type_task(
            current, 1, current_expectation, constructor_position,
          )
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_type_task(
              self.collected.type_arguments[arguments.start + index],
              0,
              any_type_name,
              false,
            )
          }
          self.push_type_task(base, 0, current_expectation, true)
        } else {
          self.finish_applied_type(owner, current, base, arguments, offset)
        }
      FunctionTypeSyntax(parameters, result, _) =>
        if state == 0 {
          self.push_type_task(
            current, 1, current_expectation, constructor_position,
          )
          self.push_type_task(result, 0, any_type_name, false)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.push_type_task(
              self.collected.type_arguments[parameters.start + index],
              0,
              any_type_name,
              false,
            )
          }
        } else {
          self.application_scratch.clear()
          for index in 0..<parameters.length {
            self.application_scratch.push(
              self.syntax_types[self.collected.type_arguments[parameters.start +
              index]],
            )
          }
          self.syntax_types[current] = self.interner.intern_function(
            self.application_scratch,
            self.syntax_types[result],
          )
        }
    }
  }
  self.computed_active[syntax] = false
  self.syntax_types[syntax]
}

///|
fn TypeResolver::resolve_reserved_names(self : TypeResolver) -> Unit {
  for declaration in self.collected.declarations {
    match declaration.kind {
      StructDecl | EnumDecl | TypeAliasDecl | ForeignTypeDecl => {
        let spelling = self.collected.name(declaration.name)
        if primitive_type_from_name(spelling) is Some(_) || spelling == "Self" {
          self.diagnose(
            ReservedTypeName(
              declaration.id,
              declaration.name,
              declaration.offset,
            ),
          )
        }
      }
      _ => ()
    }
  }
}

///|
fn TypeResolver::resolve_parameters(self : TypeResolver) -> Unit {
  for index, parameter in self.collected.parameters {
    if parameter.type_ >= 0 {
      self.parameter_types[index] = self.resolve_syntax(
        parameter.declaration,
        parameter.type_,
        any_type_name,
      )
    } else {
      match parameter.kind {
        ReceiverParameterDecl =>
          match self.self_context(parameter.declaration) {
            Some(declaration) =>
              self.parameter_types[index] = self.interner.intern_self(
                declaration,
              )
            None => {
              self.diagnose(
                SelfOutsideContext(parameter.declaration, parameter.offset),
              )
              self.parameter_types[index] = self.interner.error_type
            }
          }
        ValueParameterDecl => {
          self.diagnose(
            UnknownType(parameter.name, parameter.declaration, parameter.offset),
          )
          self.parameter_types[index] = self.interner.error_type
        }
      }
    }
  }
}

///|
fn TypeResolver::resolve_signatures(self : TypeResolver) -> Unit {
  self.resolve_reserved_names()
  for parameter in self.collected.generic_parameters {
    for
      index in parameter.bounds.start..<(parameter.bounds.start +
      parameter.bounds.length) {
      self.generic_bound_types[index] = self.resolve_syntax(
        parameter.declaration,
        self.collected.generic_bounds[index],
        trait_type_name,
      )
    }
  }
  self.resolve_parameters()
  for index, callable in self.collected.callables {
    self.callable_return_types[index] = self.resolve_syntax(
      callable.declaration,
      callable.return_type,
      any_type_name,
    )
  }
  for index, lambda in self.collected.lambdas {
    let root_body = self.collected.bodies[semantic_id_local(lambda.root_body)]
    for
      parameter_index in lambda.parameters.start..<(lambda.parameters.start +
      lambda.parameters.length) {
      self.lambda_parameter_types[parameter_index] = self.resolve_syntax(
        root_body.declaration,
        self.collected.lambda_parameters[parameter_index].type_,
        any_type_name,
      )
    }
    self.lambda_return_types[index] = self.resolve_syntax(
      root_body.declaration,
      lambda.return_type,
      any_type_name,
    )
  }
  for body in self.collected.bodies {
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      if self.collected.expressions[expression] is HirTypeBindingExpr(syntax, _) {
        ignore(self.resolve_syntax(body.declaration, syntax, any_type_name))
      }
      if expression >= self.collected.explicit_call_type_argument_spans.length() {
        continue
      }
      let explicit = self.collected.explicit_call_type_argument_spans[expression]
      for argument in explicit.start..<(explicit.start + explicit.length) {
        self.explicit_call_type_arguments[argument] = self.resolve_syntax(
          body.declaration,
          self.collected.explicit_call_type_arguments[argument],
          any_type_name,
        )
      }
    }
  }
  for lambda in self.collected.lambdas {
    let owner = self.collected.bodies[semantic_id_local(lambda.root_body)].declaration
    for
      expression in lambda.body.expressions.start..<(lambda.body.expressions.start +
      lambda.body.expressions.length) {
      if self.collected.expressions[expression] is HirTypeBindingExpr(syntax, _) {
        ignore(self.resolve_syntax(owner, syntax, any_type_name))
      }
      if expression >= self.collected.explicit_call_type_argument_spans.length() {
        continue
      }
      let explicit = self.collected.explicit_call_type_argument_spans[expression]
      for argument in explicit.start..<(explicit.start + explicit.length) {
        self.explicit_call_type_arguments[argument] = self.resolve_syntax(
          owner,
          self.collected.explicit_call_type_arguments[argument],
          any_type_name,
        )
      }
    }
  }
  for index, field in self.collected.fields {
    self.field_types[index] = self.resolve_syntax(
      field.declaration,
      field.type_,
      any_type_name,
    )
  }
  for index, variant in self.collected.variants {
    let start = self.signature_type_lists.length()
    let source = variant.payload_types
    for payload_index in source.start..<(source.start + source.length) {
      self.signature_type_lists.push(
        self.resolve_syntax(
          variant.declaration,
          self.collected.type_arguments[payload_index],
          any_type_name,
        ),
      )
    }
    self.variant_payloads[index] = {
      start,
      length: self.signature_type_lists.length() - start,
    }
  }
  for index, alias_entry in self.collected.aliases {
    self.alias_target_types[index] = self.resolve_syntax(
      alias_entry.declaration,
      alias_entry.target,
      any_type_name,
    )
  }
  for index, implementation in self.collected.impls {
    self.impl_trait_types[index] = match implementation.trait_type {
      Some(type_) =>
        self.resolve_syntax(implementation.declaration, type_, trait_type_name)
      None => -1
    }
    self.impl_target_types[index] = self.resolve_syntax(
      implementation.declaration,
      implementation.target_type,
      any_type_name,
    )
  }
}

///|
fn TypeResolver::collect_alias_dependencies(self : TypeResolver) -> Unit {
  self.type_visit_marks = Array::make(self.interner.types.length(), 0)
  for alias_index, target in self.alias_target_types {
    self.visit_generation += 1
    if self.visit_generation == 0 {
      self.type_visit_marks.fill(0)
      self.alias_visit_marks.fill(0)
      self.visit_generation = 1
    }
    self.type_visit_stack.clear()
    self.type_visit_stack.push(target)
    let dependency_indices = self.alias_dependency_scratch
    dependency_indices.clear()
    while self.type_visit_stack.length() > 0 {
      let type_ = self.type_visit_stack.pop().unwrap()
      if self.type_visit_marks[type_] == self.visit_generation {
        continue
      }
      self.type_visit_marks[type_] = self.visit_generation
      match self.interner.types[type_] {
        MemberTypeProjection(owner, _, _) => self.type_visit_stack.push(owner)
        ProductType(fields) =>
          for offset in 0..<fields.length {
            self.type_visit_stack.push(
              self.interner.arguments[fields.start + offset],
            )
          }
        NominalType(declaration) =>
          match self.alias_indices.get(declaration) {
            Some(dependency) =>
              if self.alias_visit_marks[dependency] != self.visit_generation {
                self.alias_visit_marks[dependency] = self.visit_generation
                dependency_indices.push(dependency)
              }
            None => ()
          }
        AppliedType(base, arguments) => {
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.type_visit_stack.push(
              self.interner.arguments[arguments.start + index],
            )
          }
          self.type_visit_stack.push(base)
        }
        FunctionType(parameters, result) => {
          self.type_visit_stack.push(result)
          let mut index = parameters.length
          while index > 0 {
            index -= 1
            self.type_visit_stack.push(
              self.interner.arguments[parameters.start + index],
            )
          }
        }
        _ => ()
      }
    }
    dependency_indices.sort()
    let start = self.alias_dependency_declarations.length()
    for dependency in dependency_indices {
      self.alias_dependency_declarations.push(
        self.collected.aliases[dependency].declaration,
      )
    }
    self.alias_dependencies[alias_index] = {
      start,
      length: self.alias_dependency_declarations.length() - start,
    }
  }
}

///|
fn TypeDiagnostic::rank(self : TypeDiagnostic) -> Int {
  match self {
    ReservedTypeName(_, _, _) => 0
    UnknownType(_, _, _) => 1
    UnknownTrait(_, _, _) => 2
    AmbiguousImportedType(_, _, _) => 3
    AmbiguousImportedTrait(_, _, _) => 4
    ExpectedTraitType(_, _, _) => 5
    TypeArityMismatch(_, _, _, _, _) => 6
    TypeNotApplicable(_, _, _) => 7
    NullableRefRequiresForeignType(_, _, _) => 8
    SelfOutsideContext(_, _) => 9
    AliasCycle(_, _) => 10
    AliasExpansionLimit(_, _, _) => 11
    ComputedTypeFailure(_, _, _) => 12
  }
}

///|
fn TypeResolver::sort_diagnostics(self : TypeResolver) -> Unit {
  self.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      left.rank() - right.rank()
    }
  })
}

///|
fn TypeResolver::finish(self : TypeResolver) -> ResolvedModuleTypes {
  self.sort_diagnostics()
  {
    module_id: self.collected.module_id,
    types: self.interner.types,
    type_arguments: self.interner.arguments,
    syntax_types: self.syntax_types,
    declaration_types: self.declaration_types,
    generic_parameter_types: self.generic_parameter_types,
    generic_bound_types: self.generic_bound_types,
    parameter_types: self.parameter_types,
    callable_return_types: self.callable_return_types,
    callable_function_types: self.callable_function_types,
    lambda_parameter_types: self.lambda_parameter_types,
    lambda_return_types: self.lambda_return_types,
    lambda_function_types: self.lambda_function_types,
    explicit_call_type_arguments: self.explicit_call_type_arguments,
    field_types: self.field_types,
    variant_payloads: self.variant_payloads,
    signature_type_lists: self.signature_type_lists,
    alias_target_types: self.alias_target_types,
    impl_trait_types: self.impl_trait_types,
    impl_target_types: self.impl_target_types,
    alias_dependencies: self.alias_dependencies,
    alias_dependency_declarations: self.alias_dependency_declarations,
    alias_is_cyclic: self.alias_is_cyclic,
    alias_cycles: self.alias_cycles,
    alias_cycle_declarations: self.alias_cycle_declarations,
    alias_expansion_work: self.alias_expansion_work,
    alias_expansion_limit: self.alias_expansion_limit,
    diagnostics: self.diagnostics,
    error_type: self.interner.error_type,
    primitive_types: self.interner.primitive_types,
  }
}

///|
/// Resolves all declaration-level type syntax in one collected module. The
/// result is immutable-by-convention and safe to share between future body
/// analysis jobs.
fn resolve_module_types_with_imports_and_alias_expansion_limit(
  collected : CollectedModule,
  imports : ModuleImportScope?,
  alias_expansion_limit : Int,
) -> ResolvedModuleTypes {
  let resolver = TypeResolver::new(collected, imports)
  resolver.resolve_signatures()
  resolver.collect_alias_dependencies()
  resolver.find_alias_cycles()
  resolver.normalize_aliases(alias_expansion_limit)
  resolver.validate_compile_time_storage()
  resolver.finish()
}

///|
fn resolve_module_types_with_alias_expansion_limit(
  collected : CollectedModule,
  alias_expansion_limit : Int,
) -> ResolvedModuleTypes {
  resolve_module_types_with_imports_and_alias_expansion_limit(
    collected,
    None,
    alias_expansion_limit,
  )
}

///|
pub fn resolve_module_types_with_imports(
  collected : CollectedModule,
  imports : ModuleImportScope,
) -> ResolvedModuleTypes {
  guard collected.module_id == imports.module_id else {
    abort("type import scope belongs to another module")
  }
  resolve_module_types_with_imports_and_alias_expansion_limit(
    collected,
    Some(imports),
    -1,
  )
}

///|
/// Resolves and transparently normalizes all declaration-level type syntax in
/// one collected module. The result is immutable-by-convention and safe to
/// share between future body analysis jobs.
pub fn resolve_module_types(collected : CollectedModule) -> ResolvedModuleTypes {
  resolve_module_types_with_alias_expansion_limit(collected, -1)
}
