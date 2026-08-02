///|
pub struct ResolvedImportedImplementation {
  declaration : DeclId
  trait_type : ResolvedTypeId
  target_type : ResolvedTypeId
} derive(Eq, Debug)

///|
pub struct ResolvedImportedField {
  field : FieldId
  declaration : DeclId
  variant : VariantId?
  name : String
  type_ : ResolvedTypeId
} derive(Eq, Debug)

///|
pub struct ResolvedImportedVariant {
  variant : VariantId
  declaration : DeclId
  kind : CollectedVariantKind
  name : String
  payload_types : HirSpan
} derive(Eq, Debug)

///|
pub struct ResolvedImportedCallable {
  declaration : DeclId
  generic_parameters : HirSpan
  parameters : HirSpan
  result_type : ResolvedTypeId
} derive(Eq, Debug)

///|
pub struct ResolvedModuleImports {
  module_id : ModuleId
  scope : ModuleImportScope
  callables : Array[ResolvedImportedCallable]
  parameter_types : Array[ResolvedTypeId]
  parameter_receivers : Array[Bool]
  implementations : Array[ResolvedImportedImplementation]
  fields : Array[ResolvedImportedField]
  field_spans : Map[DeclId, HirSpan]
  variants : Array[ResolvedImportedVariant]
  variant_payload_types : Array[ResolvedTypeId]
  variant_spans : Map[DeclId, HirSpan]
  callable_by_declaration : Map[DeclId, Int]
}

///|
pub fn ResolvedModuleImports::callable(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> ResolvedImportedCallable? {
  match self.callable_by_declaration.get(declaration) {
    Some(index) => Some(self.callables[index])
    None => None
  }
}

///|
pub fn ResolvedModuleImports::fields_of(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> ArrayView[ResolvedImportedField] {
  match self.field_spans.get(declaration) {
    Some(span) => self.fields[span.start:span.start + span.length]
    None => self.fields[0:0]
  }
}

///|
pub fn ResolvedModuleImports::variants_of(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> ArrayView[ResolvedImportedVariant] {
  match self.variant_spans.get(declaration) {
    Some(span) => self.variants[span.start:span.start + span.length]
    None => self.variants[0:0]
  }
}

///|
pub fn ResolvedModuleImports::variant_named(
  self : ResolvedModuleImports,
  declaration : DeclId,
  name : String,
) -> ResolvedImportedVariant? {
  for variant in self.variants_of(declaration) {
    if variant.name == name {
      return Some(variant)
    }
  }
  None
}

///|
pub fn ResolvedModuleImports::variant(
  self : ResolvedModuleImports,
  variant : VariantId,
) -> ResolvedImportedVariant? {
  for imported in self.variants {
    if imported.variant == variant {
      return Some(imported)
    }
  }
  None
}

///|
pub fn ResolvedModuleImports::variant_payload(
  self : ResolvedModuleImports,
  variant : ResolvedImportedVariant,
) -> ArrayView[ResolvedTypeId] {
  self.variant_payload_types[variant.payload_types.start:variant.payload_types.start +
  variant.payload_types.length]
}

///|
pub fn ResolvedModuleImports::is_struct(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> Bool {
  for imported in self.scope.declarations {
    if imported.declaration == declaration {
      return imported.source_kind == StructDecl
    }
  }
  false
}

///|
pub fn ResolvedModuleImports::is_enum(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> Bool {
  for imported in self.scope.declarations {
    if imported.declaration == declaration {
      return imported.source_kind == EnumDecl
    }
  }
  false
}

///|
pub fn ResolvedModuleImports::generic_parameters_of(
  self : ResolvedModuleImports,
  declaration : DeclId,
) -> HirSpan {
  for imported in self.scope.declarations {
    if imported.declaration == declaration {
      return imported.generic_parameters
    }
  }
  { start: 0, length: 0 }
}

///|
pub fn ResolvedModuleImports::value_binding(
  self : ResolvedModuleImports,
  name : String,
) -> ImportedValueBinding? {
  match self.scope.value_bindings.get(name) {
    Some(binding) if !binding.ambiguous => Some(binding)
    _ => None
  }
}

///|
priv struct InterfaceTypeImporter {
  resolved : ResolvedModuleTypes
  interfaces : Array[FrozenModuleInterface?]
  memos : Array[Array[ResolvedTypeId]]
  task_interfaces : Array[Int]
  task_types : Array[ResolvedTypeId]
  task_states : Array[Int]
  task_result_starts : Array[Int]
  results : Array[ResolvedTypeId]
  application_scratch : Array[ResolvedTypeId]
}

///|
fn InterfaceTypeImporter::new(
  resolved : ResolvedModuleTypes,
  interfaces : Array[FrozenModuleInterface?],
) -> InterfaceTypeImporter {
  let memos : Array[Array[ResolvedTypeId]] = []
  for _ in interfaces {
    memos.push([])
  }
  {
    resolved,
    interfaces,
    memos,
    task_interfaces: [],
    task_types: [],
    task_states: [],
    task_result_starts: [],
    results: [],
    application_scratch: [],
  }
}

///|
fn InterfaceTypeImporter::intern_simple(
  self : InterfaceTypeImporter,
  interface_index : Int,
  type_ : ResolvedType,
) -> ResolvedTypeId {
  let type_ = match type_ {
    TraitType(declaration) =>
      if semantic_id_local(declaration) <
        self.interfaces[interface_index].unwrap().preamble_declaration_count {
        TraitType(
          make_semantic_id(
            self.resolved.module_id,
            semantic_id_local(declaration),
          ),
        )
      } else {
        type_
      }
    other => other
  }
  match type_ {
    ErrorType => return self.resolved.error_type
    PrimitiveType(primitive) => return self.resolved.primitive(primitive)
    AppliedType(_, _) => abort("simple imported type is applied")
    _ => ()
  }
  for index, existing in self.resolved.types {
    if existing == type_ {
      return index
    }
  }
  let index = self.resolved.types.length()
  self.resolved.types.push(type_)
  index
}

///|
fn InterfaceTypeImporter::intern_applied(
  self : InterfaceTypeImporter,
  base : ResolvedTypeId,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId {
  for index, existing in self.resolved.types {
    match existing {
      AppliedType(existing_base, span) if existing_base == base &&
        span.length == arguments.length() => {
        let mut same = true
        for argument_index in 0..<span.length {
          if self.resolved.type_arguments[span.start + argument_index] !=
            arguments[argument_index] {
            same = false
            break
          }
        }
        if same {
          return index
        }
      }
      _ => ()
    }
  }
  let start = self.resolved.type_arguments.length()
  for argument in arguments {
    self.resolved.type_arguments.push(argument)
  }
  let index = self.resolved.types.length()
  self.resolved.types.push(
    AppliedType(base, { start, length: arguments.length() }),
  )
  index
}

///|
fn InterfaceTypeImporter::push(
  self : InterfaceTypeImporter,
  interface_index : Int,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.task_interfaces.push(interface_index)
  self.task_types.push(type_)
  self.task_states.push(state)
  self.task_result_starts.push(result_start)
}

///|
fn InterfaceTypeImporter::import_type(
  self : InterfaceTypeImporter,
  interface_index : Int,
  root : ResolvedTypeId,
) -> ResolvedTypeId {
  if self.memos[interface_index].length() == 0 {
    let source = self.interfaces[interface_index].unwrap().resolved_types
    self.memos[interface_index] = Array::make(source.types.length(), -1)
  }
  let cached = self.memos[interface_index][root]
  if cached >= 0 {
    return cached
  }
  self.task_interfaces.clear()
  self.task_types.clear()
  self.task_states.clear()
  self.task_result_starts.clear()
  self.results.clear()
  self.push(interface_index, root, 0, 0)
  while self.task_types.length() > 0 {
    let source_interface = self.task_interfaces.pop().unwrap()
    let source_type = self.task_types.pop().unwrap()
    let state = self.task_states.pop().unwrap()
    let result_start = self.task_result_starts.pop().unwrap()
    let memo = self.memos[source_interface][source_type]
    if state == 0 && memo >= 0 {
      self.results.push(memo)
      continue
    }
    let source = self.interfaces[source_interface].unwrap().resolved_types
    if state == 0 {
      match source.types[source_type] {
        AppliedType(base, arguments) => {
          self.push(source_interface, source_type, 1, self.results.length())
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push(
              source_interface,
              source.type_arguments[arguments.start + index],
              0,
              0,
            )
          }
          self.push(source_interface, base, 0, 0)
        }
        simple => {
          let imported = self.intern_simple(source_interface, simple)
          self.memos[source_interface][source_type] = imported
          self.results.push(imported)
        }
      }
    } else {
      let (_, arguments) = match source.types[source_type] {
        AppliedType(base, arguments) => (base, arguments)
        _ => abort("imported type finish task is not applied")
      }
      let imported_base = self.results[result_start]
      self.application_scratch.clear()
      for index in 0..<arguments.length {
        self.application_scratch.push(self.results[result_start + index + 1])
      }
      let imported = self.intern_applied(
        imported_base,
        self.application_scratch,
      )
      self.memos[source_interface][source_type] = imported
      self.results.truncate(result_start)
      self.results.push(imported)
    }
  }
  guard self.results.length() == 1 else {
    abort("imported type traversal produced an invalid result stack")
  }
  self.results[0]
}

///|
/// Imports callable signature recipes into the consumer's resolved-type arena.
/// Source interface IDs remain unchanged; only module-local type-arena indices
/// are translated.
pub fn resolve_module_imports(
  resolved : ResolvedModuleTypes,
  scope : ModuleImportScope,
) -> ResolvedModuleImports {
  guard resolved.module_id == scope.module_id else {
    abort("resolved import scope belongs to another module")
  }
  let importer = InterfaceTypeImporter::new(resolved, scope.interfaces)
  let callables : Array[ResolvedImportedCallable] = []
  let parameter_types : Array[ResolvedTypeId] = []
  let parameter_receivers : Array[Bool] = []
  let implementations : Array[ResolvedImportedImplementation] = []
  let fields : Array[ResolvedImportedField] = []
  let field_spans : Map[DeclId, HirSpan] = Map::default()
  let variants : Array[ResolvedImportedVariant] = []
  let variant_payload_types : Array[ResolvedTypeId] = []
  let variant_spans : Map[DeclId, HirSpan] = Map::default()
  let callable_by_declaration : Map[DeclId, Int] = Map::default()
  for reference in scope.callable_references {
    let interface_ = scope.interfaces[reference.interface_index].unwrap()
    let callable = interface_.callables[reference.callable_index]
    let parameter_start = parameter_types.length()
    for index in 0..<callable.parameters.length {
      let parameter = interface_.parameters[callable.parameters.start + index]
      parameter_types.push(
        importer.import_type(reference.interface_index, parameter.type_),
      )
      parameter_receivers.push(parameter.receiver)
    }
    let imported_index = callables.length()
    callables.push({
      declaration: callable.declaration,
      generic_parameters: callable.generic_parameters,
      parameters: {
        start: parameter_start,
        length: parameter_types.length() - parameter_start,
      },
      result_type: importer.import_type(
        reference.interface_index,
        callable.result_type,
      ),
    })
    callable_by_declaration[callable.declaration] = imported_index
  }
  for interface_index in scope.imported_interfaces {
    let interface_ = scope.interfaces[interface_index].unwrap()
    for callable in interface_.callables {
      if callable_by_declaration.contains(callable.declaration) {
        continue
      }
      let parameter_start = parameter_types.length()
      for index in 0..<callable.parameters.length {
        let parameter = interface_.parameters[callable.parameters.start + index]
        parameter_types.push(
          importer.import_type(interface_index, parameter.type_),
        )
        parameter_receivers.push(parameter.receiver)
      }
      let imported_index = callables.length()
      callables.push({
        declaration: callable.declaration,
        generic_parameters: callable.generic_parameters,
        parameters: {
          start: parameter_start,
          length: parameter_types.length() - parameter_start,
        },
        result_type: importer.import_type(interface_index, callable.result_type),
      })
      callable_by_declaration[callable.declaration] = imported_index
    }
  }
  for interface_index in scope.imported_interfaces {
    let interface_ = scope.interfaces[interface_index].unwrap()
    let mut variant_cursor = 0
    for declaration in interface_.declarations {
      if declaration.source_kind != StructDecl &&
        declaration.source_kind != EnumDecl {
        continue
      }
      let start = fields.length()
      for field in interface_.fields {
        if field.declaration == declaration.declaration {
          fields.push({
            field: field.field,
            declaration: field.declaration,
            variant: field.variant,
            name: field.name,
            type_: importer.import_type(interface_index, field.type_),
          })
        }
      }
      field_spans[declaration.declaration] = {
        start,
        length: fields.length() - start,
      }
      if declaration.source_kind == EnumDecl {
        let variant_start = variants.length()
        while variant_cursor < interface_.variants.length() &&
              interface_.variants[variant_cursor].declaration ==
              declaration.declaration {
          let variant = interface_.variants[variant_cursor]
          let payload_start = variant_payload_types.length()
          for payload_index in 0..<variant.payload_types.length {
            variant_payload_types.push(
              importer.import_type(
                interface_index,
                interface_.variant_payload_types[variant.payload_types.start +
                payload_index],
              ),
            )
          }
          variants.push({
            variant: variant.variant,
            declaration: variant.declaration,
            kind: variant.kind,
            name: variant.name,
            payload_types: {
              start: payload_start,
              length: variant_payload_types.length() - payload_start,
            },
          })
          variant_cursor += 1
        }
        variant_spans[declaration.declaration] = {
          start: variant_start,
          length: variants.length() - variant_start,
        }
      }
    }
    for implementation in interface_.implementations {
      implementations.push({
        declaration: implementation.declaration,
        trait_type: if implementation.trait_type >= 0 {
          importer.import_type(interface_index, implementation.trait_type)
        } else {
          -1
        },
        target_type: importer.import_type(
          interface_index,
          implementation.target_type,
        ),
      })
    }
  }
  {
    module_id: resolved.module_id,
    scope,
    callables,
    parameter_types,
    parameter_receivers,
    implementations,
    fields,
    field_spans,
    variants,
    variant_payload_types,
    variant_spans,
    callable_by_declaration,
  }
}

///|
pub struct AnalyzedProgramModule {
  module_id : ModuleId
  imports : ResolvedModuleImports
  names : ResolvedModuleNames
  inferred : InferredModuleBodies
}

///|
pub struct AnalyzedProgramSemantics {
  frozen : FrozenProgramInterfaces
  modules : Array[AnalyzedProgramModule]
}

///|
/// Runs imported signature resolution, body name resolution, and body inference
/// from one already-frozen interface graph.
pub fn analyze_program_semantics_with_frozen(
  program : CollectedProgram,
  frozen : FrozenProgramInterfaces,
) -> AnalyzedProgramSemantics {
  guard frozen.interfaces.length() == program.modules.length() &&
    frozen.import_scopes.length() == program.modules.length() else {
    abort("frozen program interfaces do not match the collected program")
  }
  let slots : Array[AnalyzedProgramModule?] = Array::make(
    program.modules.length(),
    None,
  )
  for scc in frozen.graph.sccs {
    for index in 0..<scc.length {
      let module_index = frozen.graph.scc_modules[scc.start + index]
      let collected = program.modules[module_index]
      let resolved = frozen.interfaces[module_index].resolved_types
      let scope = frozen.import_scopes[module_index]
      let imports = resolve_module_imports(resolved, scope)
      let names = resolve_module_names_with_imports(collected, scope)
      let inferred = infer_module_bodies_with_imports(
        collected, resolved, imports, names,
      )
      slots[module_index] = Some({
        module_id: collected.module_id,
        imports,
        names,
        inferred,
      })
    }
  }
  let modules : Array[AnalyzedProgramModule] = []
  for slot in slots {
    modules.push(slot.unwrap())
  }
  { frozen, modules }
}

///|
/// Runs imported signature resolution, body name resolution, and body inference
/// in dependency-SCC order while retaining manifest-indexed outputs.
pub fn analyze_program_semantics(
  program : CollectedProgram,
) -> AnalyzedProgramSemantics {
  analyze_program_semantics_with_frozen(
    program,
    freeze_program_interfaces(program),
  )
}

///|
pub fn analyze_program_semantics_with_cached_interfaces(
  program : CollectedProgram,
  cached : Array[FrozenModuleInterface?],
) -> AnalyzedProgramSemantics {
  analyze_program_semantics_with_frozen(
    program,
    freeze_program_interfaces_with_cached(program, cached),
  )
}
