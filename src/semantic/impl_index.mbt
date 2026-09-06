///|
pub enum ImplTargetHead {
  ErrorImplTargetHead
  PrimitiveImplTargetHead(PrimitiveType)
  NominalImplTargetHead(DeclId)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum IndexedImplKind {
  InherentIndexedImpl
  TraitIndexedImpl(DeclId)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum ImplBucketKind {
  InherentImplBucket
  TraitImplBucket(DeclId)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct IndexedImplMethod {
  declaration : DeclId
  requirement : DeclId?
  instance : Bool
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct IndexedImpl {
  declaration : DeclId
  kind : IndexedImplKind
  target_head : ImplTargetHead
  trait_type : ResolvedTypeId
  target_type : ResolvedTypeId
  methods : HirSpan
  bucket : Int
  valid : Bool
  coherent : Bool
  specificity : Int
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct ImplBucket {
  kind : ImplBucketKind
  target_head : ImplTargetHead
  implementations : HirSpan
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct IndexedMethodDispatch {
  target_head : ImplTargetHead
  name : NameId
  inherent : Bool
  instance : Bool
  implementation : Int
  method_index : Int
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct IndexedTraitMethodDispatch {
  trait_declaration : DeclId
  name : NameId
  instance : Bool
  implementation : Int
  method_index : Int
} derive(Eq, Debug, ToJson, FromJson)

///|
pub enum ImplIndexDiagnostic {
  InvalidImplTraitHead(DeclId, UInt64)
  InvalidImplTargetHead(DeclId, UInt64)
  OrphanTraitImpl(DeclId, DeclId, ImplTargetHead, UInt64)
  OverlappingTraitImpl(DeclId, DeclId, DeclId, ImplTargetHead, UInt64)
  UnknownTraitImplMethod(DeclId, DeclId, UInt64)
  MissingTraitMethod(DeclId, DeclId, UInt64)
  DuplicateTraitImplMethod(DeclId, DeclId, DeclId, UInt64)
  TraitMethodReceiverMismatch(DeclId, DeclId, UInt64)
  TraitMethodParameterCountMismatch(DeclId, DeclId, Int, Int, UInt64)
  TraitMethodGenericParameterCountMismatch(DeclId, DeclId, Int, Int, UInt64)
  TraitMethodParameterTypeMismatch(DeclId, DeclId, Int, UInt64)
  TraitMethodReturnTypeMismatch(DeclId, DeclId, UInt64)
  DuplicateInherentMethod(NameId, DeclId, DeclId, UInt64)
} derive(Eq, Debug, ToJson, FromJson)

///|
pub fn ImplIndexDiagnostic::offset(self : ImplIndexDiagnostic) -> UInt64 {
  match self {
    InvalidImplTraitHead(_, offset)
    | InvalidImplTargetHead(_, offset)
    | OrphanTraitImpl(_, _, _, offset)
    | OverlappingTraitImpl(_, _, _, _, offset)
    | UnknownTraitImplMethod(_, _, offset)
    | MissingTraitMethod(_, _, offset)
    | DuplicateTraitImplMethod(_, _, _, offset)
    | TraitMethodReceiverMismatch(_, _, offset)
    | TraitMethodParameterCountMismatch(_, _, _, _, offset)
    | TraitMethodGenericParameterCountMismatch(_, _, _, _, offset)
    | TraitMethodParameterTypeMismatch(_, _, _, offset)
    | TraitMethodReturnTypeMismatch(_, _, offset)
    | DuplicateInherentMethod(_, _, _, offset) => offset
  }
}

///|
pub struct ModuleImplIndex {
  module_id : ModuleId
  implementations : Array[IndexedImpl]
  methods : Array[IndexedImplMethod]
  buckets : Array[ImplBucket]
  bucket_implementations : Array[Int]
  method_dispatch : Array[IndexedMethodDispatch]
  trait_method_dispatch : Array[IndexedTraitMethodDispatch]
  diagnostics : Array[ImplIndexDiagnostic]
} derive(Eq, Debug, ToJson, FromJson)

///|
pub fn ModuleImplIndex::implementation(
  self : ModuleImplIndex,
  declaration : DeclId,
) -> IndexedImpl? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  for implementation in self.implementations {
    if implementation.declaration == declaration {
      return Some(implementation)
    }
  }
  None
}

///|
pub fn ModuleImplIndex::bucket_implementations_of(
  self : ModuleImplIndex,
  bucket : ImplBucket,
) -> ArrayView[Int] {
  self.bucket_implementations[bucket.implementations.start:bucket.implementations.start +
  bucket.implementations.length]
}

///|
fn impl_primitive_key(primitive : PrimitiveType) -> UInt64 {
  match primitive {
    UnitType => 0UL
    BoolType => 1UL
    I32Type => 2UL
    U32Type => 3UL
    I64Type => 4UL
    U64Type => 5UL
    F32Type => 6UL
    F64Type => 7UL
    StringType => 8UL
    NeverType => 9UL
    I8Type => 10UL
    I16Type => 11UL
    U8Type => 12UL
    U16Type => 13UL
    BytesType => 14UL
    V128Type => 15UL
    Swar32Type => 16UL
    Swar64Type => 17UL
    I8x4Type => 18UL
    U8x4Type => 19UL
    I16x2Type => 20UL
    U16x2Type => 21UL
    I8x8Type => 22UL
    U8x8Type => 23UL
    I16x4Type => 24UL
    U16x4Type => 25UL
    I32x2Type => 26UL
    U32x2Type => 27UL
    I8x16Type => 28UL
    U8x16Type => 29UL
    I16x8Type => 30UL
    U16x8Type => 31UL
    I32x4Type => 32UL
    U32x4Type => 33UL
    I64x2Type => 34UL
    U64x2Type => 35UL
    F32x4Type => 36UL
    F64x2Type => 37UL
    StringViewType => 38UL
    StringBuilderType => 39UL
    BytesBuilderType => 40UL
    CompileTimeTypeType => 41UL
  }
}

///|
fn impl_head_key(head : ImplTargetHead) -> (Int, UInt64) {
  match head {
    ErrorImplTargetHead => (-1, 0UL)
    PrimitiveImplTargetHead(primitive) => (0, impl_primitive_key(primitive))
    NominalImplTargetHead(declaration) => (1, declaration)
  }
}

///|
fn trait_impl_is_package_owned(
  owner : ModuleId,
  trait_declaration : DeclId,
  target_head : ImplTargetHead,
) -> Bool {
  if semantic_modules_share_package(
      owner,
      semantic_id_module(trait_declaration),
    ) {
    return true
  }
  match target_head {
    NominalImplTargetHead(declaration) =>
      semantic_modules_share_package(owner, semantic_id_module(declaration))
    PrimitiveImplTargetHead(_) => semantic_module_is_standard_package(owner)
    ErrorImplTargetHead => true
  }
}

///|
fn method_dispatch_key_compare(
  entry : IndexedMethodDispatch,
  target_head : ImplTargetHead,
  name : NameId,
  inherent : Bool,
  instance : Bool,
) -> Int {
  let (entry_kind, entry_value) = impl_head_key(entry.target_head)
  let (target_kind, target_value) = impl_head_key(target_head)
  let kind_order = entry_kind - target_kind
  if kind_order != 0 {
    return kind_order
  }
  let value_order = entry_value.compare(target_value)
  if value_order != 0 {
    return value_order
  }
  let name_order = entry.name.compare(name)
  if name_order != 0 {
    return name_order
  }
  let entry_tier = if entry.inherent { 0 } else { 1 }
  let target_tier = if inherent { 0 } else { 1 }
  let tier_order = entry_tier - target_tier
  if tier_order != 0 {
    return tier_order
  }
  let entry_receiver = if entry.instance { 1 } else { 0 }
  let target_receiver = if instance { 1 } else { 0 }
  entry_receiver - target_receiver
}

///|
pub fn ModuleImplIndex::method_dispatch_span(
  self : ModuleImplIndex,
  target_head : ImplTargetHead,
  name : NameId,
  inherent : Bool,
  instance : Bool,
) -> HirSpan {
  let mut lower = 0
  let mut upper = self.method_dispatch.length()
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if method_dispatch_key_compare(
        self.method_dispatch[middle],
        target_head,
        name,
        inherent,
        instance,
      ) <
      0 {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  let start = lower
  upper = self.method_dispatch.length()
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if method_dispatch_key_compare(
        self.method_dispatch[middle],
        target_head,
        name,
        inherent,
        instance,
      ) <=
      0 {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  { start, length: lower - start, }
}

///|
fn trait_method_dispatch_key_compare(
  entry : IndexedTraitMethodDispatch,
  trait_declaration : DeclId,
  name : NameId,
  instance : Bool,
) -> Int {
  let trait_order = entry.trait_declaration.compare(trait_declaration)
  if trait_order != 0 {
    return trait_order
  }
  let name_order = entry.name.compare(name)
  if name_order != 0 {
    return name_order
  }
  let entry_receiver = if entry.instance { 1 } else { 0 }
  let target_receiver = if instance { 1 } else { 0 }
  entry_receiver - target_receiver
}

///|
pub fn ModuleImplIndex::trait_method_dispatch_span(
  self : ModuleImplIndex,
  trait_declaration : DeclId,
  name : NameId,
  instance : Bool,
) -> HirSpan {
  let mut lower = 0
  let mut upper = self.trait_method_dispatch.length()
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if trait_method_dispatch_key_compare(
        self.trait_method_dispatch[middle],
        trait_declaration,
        name,
        instance,
      ) <
      0 {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  let start = lower
  upper = self.trait_method_dispatch.length()
  while lower < upper {
    let middle = lower + (upper - lower) / 2
    if trait_method_dispatch_key_compare(
        self.trait_method_dispatch[middle],
        trait_declaration,
        name,
        instance,
      ) <=
      0 {
      lower = middle + 1
    } else {
      upper = middle
    }
  }
  { start, length: lower - start, }
}

///|
fn resolved_impl_target_head(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> (ImplTargetHead, Bool) {
  let mut type_ = root
  while true {
    match resolved.types[type_] {
      ErrorType => return (ErrorImplTargetHead, true)
      PrimitiveType(primitive) =>
        return (PrimitiveImplTargetHead(primitive), false)
      NominalType(declaration) =>
        return (NominalImplTargetHead(declaration), false)
      AppliedType(base, _) => type_ = base
      GenericParameterType(_)
      | TraitType(_)
      | SelfType(_)
      | ProductType(_)
      | MemberTypeProjection(_, _, _)
      | FunctionType(_, _) => return (ErrorImplTargetHead, false)
    }
  }
  (ErrorImplTargetHead, false)
}

///|
fn resolved_impl_trait_head(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> (DeclId?, Bool) {
  let mut type_ = root
  while true {
    match resolved.types[type_] {
      ErrorType => return (None, true)
      TraitType(declaration) => return (Some(declaration), false)
      AppliedType(base, _) => type_ = base
      PrimitiveType(_)
      | GenericParameterType(_)
      | NominalType(_)
      | SelfType(_)
      | ProductType(_)
      | MemberTypeProjection(_, _, _)
      | FunctionType(_, _) => return (None, false)
    }
  }
  (None, false)
}

///|
fn impl_method_spans(collected : CollectedModule) -> Array[HirSpan] {
  if collected.methods.length() == 0 {
    return []
  }
  let spans = Array::make(collected.declaration_locations.length(), {
    start: 0,
    length: 0,
  })
  for index, method_info in collected.methods {
    let owner = semantic_id_local(method_info.parent)
    if spans[owner].length == 0 {
      spans[owner] = { start: index, length: 1, }
    } else {
      spans[owner] = {
        start: spans[owner].start,
        length: spans[owner].length + 1,
      }
    }
  }
  spans
}

///|
fn method_span_of(spans : Array[HirSpan], declaration : DeclId) -> HirSpan {
  let index = semantic_id_local(declaration)
  if index < 0 || index >= spans.length() {
    { start: 0, length: 0, }
  } else {
    spans[index]
  }
}

///|
fn impl_declaration_offset(
  collected : CollectedModule,
  declaration : DeclId,
) -> UInt64 {
  match collected.declaration(declaration) {
    Some(TopLevelReference(value)) => value.offset
    Some(MethodReference(value)) => value.offset
    None => 0UL
  }
}

///|
fn method_has_receiver(
  collected : CollectedModule,
  method_info : DeclId,
) -> Bool {
  let parameters = collected.parameters_of(method_info)
  parameters.length > 0 &&
  collected.parameters[parameters.start].kind == ReceiverParameterDecl
}

///|
fn value_parameter_count(
  collected : CollectedModule,
  method_info : DeclId,
) -> Int {
  let parameters = collected.parameters_of(method_info)
  if parameters.length > 0 &&
    collected.parameters[parameters.start].kind == ReceiverParameterDecl {
    parameters.length - 1
  } else {
    parameters.length
  }
}

///|
fn impl_diagnostic_rank(diagnostic : ImplIndexDiagnostic) -> Int {
  match diagnostic {
    InvalidImplTraitHead(_, _) => 0
    InvalidImplTargetHead(_, _) => 1
    OrphanTraitImpl(_, _, _, _) => 2
    OverlappingTraitImpl(_, _, _, _, _) => 3
    UnknownTraitImplMethod(_, _, _) => 4
    MissingTraitMethod(_, _, _) => 5
    DuplicateTraitImplMethod(_, _, _, _) => 6
    TraitMethodReceiverMismatch(_, _, _) => 7
    TraitMethodParameterCountMismatch(_, _, _, _, _) => 8
    TraitMethodGenericParameterCountMismatch(_, _, _, _, _) => 9
    TraitMethodParameterTypeMismatch(_, _, _, _) => 10
    TraitMethodReturnTypeMismatch(_, _, _) => 11
    DuplicateInherentMethod(_, _, _, _) => 12
  }
}

///|
fn find_trait_requirement(
  collected : CollectedModule,
  method_spans : Array[HirSpan],
  trait_declaration : DeclId,
  name : NameId,
) -> Int {
  let span = method_span_of(method_spans, trait_declaration)
  for index in span.start..<(span.start + span.length) {
    if collected.methods[index].name == name {
      return index
    }
  }
  -1
}

///|
priv struct ImplTypeContext {
  generic_parameters : HirSpan
  generic_arguments : HirSpan
  method_parameters : HirSpan
  method_arguments : HirSpan
  self_owner : DeclId
  self_type : ResolvedTypeId
}

///|
fn impl_substitute_type(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  context : ImplTypeContext,
) -> ResolvedTypeId {
  let mut current = root
  while true {
    let next = match resolved.types[current] {
      GenericParameterType(parameter) => {
        let parameter_index = semantic_id_local(parameter)
        if parameter_index >= context.generic_parameters.start &&
          parameter_index <
          context.generic_parameters.start + context.generic_parameters.length {
          let relative = parameter_index - context.generic_parameters.start
          if relative < context.generic_arguments.length {
            resolved.type_arguments[context.generic_arguments.start + relative]
          } else {
            current
          }
        } else if parameter_index >= context.method_parameters.start &&
          parameter_index <
          context.method_parameters.start + context.method_parameters.length {
          let relative = parameter_index - context.method_parameters.start
          if relative < context.method_arguments.length {
            resolved.generic_parameter_types[context.method_arguments.start +
            relative]
          } else {
            current
          }
        } else {
          current
        }
      }
      SelfType(owner) if owner == context.self_owner => context.self_type
      _ => current
    }
    if next == current {
      return current
    }
    current = next
  }
  root
}

///|
fn impl_signature_types_equal(
  resolved : ResolvedModuleTypes,
  left_root : ResolvedTypeId,
  left_context : ImplTypeContext,
  right_root : ResolvedTypeId,
  right_context : ImplTypeContext,
) -> Bool {
  let left_stack : Array[ResolvedTypeId] = [left_root]
  let right_stack : Array[ResolvedTypeId] = [right_root]
  while left_stack.length() > 0 {
    let left = impl_substitute_type(
      resolved,
      left_stack.pop().unwrap(),
      left_context,
    )
    let right = impl_substitute_type(
      resolved,
      right_stack.pop().unwrap(),
      right_context,
    )
    if left == right {
      continue
    }
    match (resolved.types[left], resolved.types[right]) {
      (ErrorType, _) | (_, ErrorType) => return true
      (
        AppliedType(left_base, left_arguments),
        AppliedType(right_base, right_arguments),
      ) => {
        if left_arguments.length != right_arguments.length {
          return false
        }
        left_stack.push(left_base)
        right_stack.push(right_base)
        let mut index = left_arguments.length
        while index > 0 {
          index -= 1
          left_stack.push(resolved.type_arguments[left_arguments.start + index])
          right_stack.push(
            resolved.type_arguments[right_arguments.start + index],
          )
        }
      }
      (
        FunctionType(left_parameters, left_result),
        FunctionType(right_parameters, right_result),
      ) => {
        if left_parameters.length != right_parameters.length {
          return false
        }
        left_stack.push(left_result)
        right_stack.push(right_result)
        let mut index = left_parameters.length
        while index > 0 {
          index -= 1
          left_stack.push(
            resolved.type_arguments[left_parameters.start + index],
          )
          right_stack.push(
            resolved.type_arguments[right_parameters.start + index],
          )
        }
      }
      _ => return false
    }
  }
  right_stack.length() == 0
}

///|
fn impl_callable_indices(collected : CollectedModule) -> Array[Int] {
  let indices = Array::make(collected.declaration_locations.length(), -1)
  for index, callable in collected.callables {
    indices[semantic_id_local(callable.declaration)] = index
  }
  indices
}

///|
fn impl_trait_context(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  trait_declaration : DeclId,
  trait_type : ResolvedTypeId,
  target_type : ResolvedTypeId,
) -> ImplTypeContext {
  let arguments = match resolved.types[trait_type] {
    AppliedType(_, arguments) => arguments
    _ => { start: 0, length: 0, }
  }
  {
    generic_parameters: collected.generic_parameters_of(trait_declaration),
    generic_arguments: arguments,
    method_parameters: { start: 0, length: 0, },
    method_arguments: { start: 0, length: 0, },
    self_owner: trait_declaration,
    self_type: target_type,
  }
}

///|
fn validate_trait_impl_methods(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  callable_indices : Array[Int],
  method_spans : Array[HirSpan],
  implementation : CollectedImpl,
  trait_declaration : DeclId,
  trait_type : ResolvedTypeId,
  target_type : ResolvedTypeId,
  methods : Array[IndexedImplMethod],
  diagnostics : Array[ImplIndexDiagnostic],
) -> HirSpan {
  let start = methods.length()
  let base_trait_context = impl_trait_context(
    collected, resolved, trait_declaration, trait_type, target_type,
  )
  let implementation_context : ImplTypeContext = {
    generic_parameters: { start: 0, length: 0, },
    generic_arguments: { start: 0, length: 0, },
    method_parameters: { start: 0, length: 0, },
    method_arguments: { start: 0, length: 0, },
    self_owner: implementation.declaration,
    self_type: target_type,
  }
  let impl_methods = method_span_of(method_spans, implementation.declaration)
  let requirements = method_span_of(method_spans, trait_declaration)
  let matched = Array::make(requirements.length, false)
  for index in impl_methods.start..<(impl_methods.start + impl_methods.length) {
    let method_info = collected.methods[index]
    let requirement_index = find_trait_requirement(
      collected,
      method_spans,
      trait_declaration,
      method_info.name,
    )
    if requirement_index < 0 {
      diagnostics.push(
        UnknownTraitImplMethod(
          method_info.id,
          implementation.declaration,
          method_info.offset,
        ),
      )
      methods.push({
        declaration: method_info.id,
        requirement: None,
        instance: method_has_receiver(collected, method_info.id),
      })
      continue
    }
    let requirement_slot = requirement_index - requirements.start
    let requirement = collected.methods[requirement_index]
    if matched[requirement_slot] {
      let mut first = method_info.id
      for previous in impl_methods.start..<index {
        if collected.methods[previous].name == method_info.name {
          first = collected.methods[previous].id
          break
        }
      }
      diagnostics.push(
        DuplicateTraitImplMethod(
          requirement.id,
          first,
          method_info.id,
          method_info.offset,
        ),
      )
    } else {
      matched[requirement_slot] = true
    }
    let requirement_receiver = method_has_receiver(collected, requirement.id)
    let implementation_receiver = method_has_receiver(collected, method_info.id)
    if requirement_receiver != implementation_receiver {
      diagnostics.push(
        TraitMethodReceiverMismatch(
          requirement.id,
          method_info.id,
          method_info.offset,
        ),
      )
    }
    let expected_parameters = value_parameter_count(collected, requirement.id)
    let actual_parameters = value_parameter_count(collected, method_info.id)
    let requirement_generics = collected.generic_parameters_of(requirement.id)
    let implementation_generics = collected.generic_parameters_of(
      method_info.id,
    )
    let generic_counts_match = requirement_generics.length ==
      implementation_generics.length
    if !generic_counts_match {
      diagnostics.push(
        TraitMethodGenericParameterCountMismatch(
          requirement.id,
          method_info.id,
          requirement_generics.length,
          implementation_generics.length,
          method_info.offset,
        ),
      )
    }
    if expected_parameters != actual_parameters {
      diagnostics.push(
        TraitMethodParameterCountMismatch(
          requirement.id,
          method_info.id,
          expected_parameters,
          actual_parameters,
          method_info.offset,
        ),
      )
    } else if requirement_receiver == implementation_receiver &&
      generic_counts_match {
      let trait_context : ImplTypeContext = {
        generic_parameters: base_trait_context.generic_parameters,
        generic_arguments: base_trait_context.generic_arguments,
        method_parameters: requirement_generics,
        method_arguments: implementation_generics,
        self_owner: base_trait_context.self_owner,
        self_type: base_trait_context.self_type,
      }
      let requirement_parameters = collected.parameters_of(requirement.id)
      let implementation_parameters = collected.parameters_of(method_info.id)
      for parameter_index in 0..<requirement_parameters.length {
        if !impl_signature_types_equal(
            resolved,
            resolved.parameter_types[requirement_parameters.start +
            parameter_index],
            trait_context,
            resolved.parameter_types[implementation_parameters.start +
            parameter_index],
            implementation_context,
          ) {
          diagnostics.push(
            TraitMethodParameterTypeMismatch(
              requirement.id,
              method_info.id,
              parameter_index,
              method_info.offset,
            ),
          )
        }
      }
      let requirement_callable = callable_indices[semantic_id_local(
          requirement.id,
        )]
      let implementation_callable = callable_indices[semantic_id_local(
          method_info.id,
        )]
      if requirement_callable >= 0 &&
        implementation_callable >= 0 &&
        !impl_signature_types_equal(
          resolved,
          resolved.callable_return_types[requirement_callable],
          trait_context,
          resolved.callable_return_types[implementation_callable],
          implementation_context,
        ) {
        diagnostics.push(
          TraitMethodReturnTypeMismatch(
            requirement.id,
            method_info.id,
            method_info.offset,
          ),
        )
      }
    }
    methods.push({
      declaration: method_info.id,
      requirement: Some(requirement.id),
      instance: implementation_receiver,
    })
  }
  for slot in 0..<requirements.length {
    if !matched[slot] {
      let requirement = collected.methods[requirements.start + slot]
      diagnostics.push(
        MissingTraitMethod(
          requirement.id,
          implementation.declaration,
          impl_declaration_offset(collected, implementation.declaration),
        ),
      )
    }
  }
  { start, length: methods.length() - start, }
}

///|
fn collect_inherent_methods(
  collected : CollectedModule,
  method_spans : Array[HirSpan],
  implementation : CollectedImpl,
  methods : Array[IndexedImplMethod],
) -> HirSpan {
  let start = methods.length()
  let span = method_span_of(method_spans, implementation.declaration)
  for index in span.start..<(span.start + span.length) {
    let method_info = collected.methods[index]
    methods.push({
      declaration: method_info.id,
      requirement: None,
      instance: method_has_receiver(collected, method_info.id),
    })
  }
  { start, length: methods.length() - start, }
}

///|
fn collect_imported_trait_methods(
  collected : CollectedModule,
  method_spans : Array[HirSpan],
  implementation : CollectedImpl,
  trait_declaration : DeclId,
  imports : ResolvedModuleImports,
  methods : Array[IndexedImplMethod],
) -> HirSpan {
  let start = methods.length()
  let span = method_span_of(method_spans, implementation.declaration)
  for index in span.start..<(span.start + span.length) {
    let method_info = collected.methods[index]
    let method_name = collected.name(method_info.name)
    let mut requirement : DeclId? = None
    for interface_index in imports.scope.imported_interfaces {
      let interface_ = imports.scope.interfaces[interface_index].unwrap()
      for callable in interface_.callables {
        match callable.kind {
          FrozenTraitCallable(owner) =>
            if owner == trait_declaration && callable.name == method_name {
              requirement = Some(callable.declaration)
              break
            }
          _ => ()
        }
      }
      if requirement is Some(_) {
        break
      }
    }
    methods.push({
      declaration: method_info.id,
      requirement,
      instance: method_has_receiver(collected, method_info.id),
    })
  }
  { start, length: methods.length() - start, }
}

///|
priv struct ImplPatternScratch {
  solver : LocalTypeSolver
  task_types : Array[ResolvedTypeId]
  task_states : Array[Int]
  task_result_starts : Array[Int]
  results : Array[BodyTypeId]
  arguments : Array[BodyTypeId]
  marks : Array[Int]
  values : Array[BodyTypeId]
  mut generation : Int
  mut generic_parameters : HirSpan
  mut any_generic_parameter : Bool
}

///|
fn ImplPatternScratch::new(
  resolved : ResolvedModuleTypes,
) -> ImplPatternScratch {
  {
    solver: LocalTypeSolver::new(resolved),
    task_types: [],
    task_states: [],
    task_result_starts: [],
    results: [],
    arguments: [],
    marks: Array::make(resolved.types.length(), 0),
    values: Array::make(resolved.types.length(), 0),
    generation: 0,
    generic_parameters: { start: 0, length: 0, },
    any_generic_parameter: false,
  }
}

///|
fn ImplPatternScratch::next_generation(self : ImplPatternScratch) -> Unit {
  self.generation += 1
  if self.generation == 0x7fffffff {
    self.generation = 1
    for index in 0..<self.marks.length() {
      self.marks[index] = 0
    }
  }
}

///|
fn ImplPatternScratch::push_task(
  self : ImplPatternScratch,
  type_ : ResolvedTypeId,
  state : Int,
  result_start : Int,
) -> Unit {
  self.task_types.push(type_)
  self.task_states.push(state)
  self.task_result_starts.push(result_start)
}

///|
fn ImplPatternScratch::import_pattern(
  self : ImplPatternScratch,
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  generic_parameters : HirSpan,
  any_generic_parameter : Bool,
  begin_group : Bool,
) -> BodyTypeId {
  if begin_group {
    self.next_generation()
    self.generic_parameters = generic_parameters
    self.any_generic_parameter = any_generic_parameter
  } else if self.generic_parameters != generic_parameters ||
    self.any_generic_parameter != any_generic_parameter {
    abort("impl pattern import group changed generic ownership")
  }
  self.task_types.clear()
  self.task_states.clear()
  self.task_result_starts.clear()
  self.results.clear()
  self.push_task(root, 0, 0)
  while self.task_types.length() > 0 {
    let source = self.task_types.pop().unwrap()
    let state = self.task_states.pop().unwrap()
    let result_start = self.task_result_starts.pop().unwrap()
    if state == 0 {
      if self.marks[source] == self.generation {
        self.results.push(self.values[source])
        continue
      }
      match resolved.types[source] {
        GenericParameterType(parameter) => {
          let parameter_index = semantic_id_local(parameter)
          let result = if self.any_generic_parameter ||
            (
              parameter_index >= self.generic_parameters.start &&
              parameter_index <
              self.generic_parameters.start + self.generic_parameters.length
            ) {
            self.solver.fresh_variable()
          } else {
            self.solver.resolved_type(source)
          }
          self.marks[source] = self.generation
          self.values[source] = result
          self.results.push(result)
        }
        ProductType(fields) => {
          self.push_task(source, 2, self.results.length())
          let mut index = fields.length
          while index > 0 {
            index -= 1
            self.push_task(resolved.type_arguments[fields.start + index], 0, 0)
          }
        }
        AppliedType(base, arguments) => {
          self.push_task(source, 1, self.results.length())
          let mut index = arguments.length
          while index > 0 {
            index -= 1
            self.push_task(
              resolved.type_arguments[arguments.start + index],
              0,
              0,
            )
          }
          self.push_task(base, 0, 0)
        }
        ErrorType
        | PrimitiveType(_)
        | NominalType(_)
        | TraitType(_)
        | SelfType(_)
        | MemberTypeProjection(_, _, _)
        | FunctionType(_, _) => {
          let result = self.solver.resolved_type(source)
          self.marks[source] = self.generation
          self.values[source] = result
          self.results.push(result)
        }
      }
    } else if state == 1 {
      let arguments = match resolved.types[source] {
        AppliedType(_, arguments) => arguments
        _ => abort("impl pattern import expected an applied type")
      }
      self.arguments.clear()
      for index in 0..<arguments.length {
        self.arguments.push(self.results[result_start + index + 1])
      }
      let result = self.solver.applied_type(
        self.results[result_start],
        self.arguments,
      )
      self.marks[source] = self.generation
      self.values[source] = result
      while self.results.length() > result_start {
        self.results.pop() |> ignore
      }
      self.results.push(result)
    } else {
      let fields = match resolved.types[source] {
        ProductType(fields) => fields
        _ => abort("impl pattern import expected a product type")
      }
      self.arguments.clear()
      for index in 0..<fields.length {
        self.arguments.push(self.results[result_start + index])
      }
      let result = self.solver.product_type(self.arguments)
      self.marks[source] = self.generation
      self.values[source] = result
      self.results.truncate(result_start)
      self.results.push(result)
    }
  }
  guard self.results.length() == 1 else {
    abort("impl pattern import produced an invalid result stack")
  }
  self.results[0]
}

///|
fn impl_type_contains_generic(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> Bool {
  let work : Array[ResolvedTypeId] = [root]
  let visited = Array::make(resolved.types.length(), false)
  while work.length() > 0 {
    let type_ = work.pop().unwrap()
    if type_ < 0 || type_ >= resolved.types.length() || visited[type_] {
      continue
    }
    visited[type_] = true
    match resolved.types[type_] {
      GenericParameterType(_) => return true
      MemberTypeProjection(owner, _, _) => work.push(owner)
      ProductType(fields) =>
        for index in 0..<fields.length {
          work.push(resolved.type_arguments[fields.start + index])
        }
      AppliedType(base, arguments) => {
        work.push(base)
        for index in 0..<arguments.length {
          work.push(resolved.type_arguments[arguments.start + index])
        }
      }
      FunctionType(parameters, result) => {
        work.push(result)
        for index in 0..<parameters.length {
          work.push(resolved.type_arguments[parameters.start + index])
        }
      }
      ErrorType
      | PrimitiveType(_)
      | NominalType(_)
      | TraitType(_)
      | SelfType(_) => ()
    }
  }
  false
}

///|
fn compiler_indexed_trait_kind(
  collected : CollectedModule,
  declaration : DeclId,
) -> Int {
  let owner = semantic_id_module(declaration)
  if owner == collected.module_id {
    if semantic_id_local(declaration) >= collected.preamble_declaration_count {
      return 0
    }
  } else if !semantic_module_is_standard_package(owner) {
    return 0
  }
  standard_indexed_trait_kind(declaration)
}

///|
fn impl_target_patterns_overlap(
  scratch : ImplPatternScratch,
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  left : IndexedImpl,
  right : IndexedImpl,
) -> Bool {
  scratch.solver.reset()
  let left_external = semantic_id_module(left.declaration) !=
    collected.module_id
  let right_external = semantic_id_module(right.declaration) !=
    collected.module_id
  let left_generics = if left_external {
    { start: 0, length: 0, }
  } else {
    collected.generic_parameters_of(left.declaration)
  }
  let right_generics = if right_external {
    { start: 0, length: 0, }
  } else {
    collected.generic_parameters_of(right.declaration)
  }
  let left_target = scratch.import_pattern(
    resolved,
    left.target_type,
    left_generics,
    left_external,
    true,
  )
  let right_target = scratch.import_pattern(
    resolved,
    right.target_type,
    right_generics,
    right_external,
    true,
  )
  scratch.solver.unify(
    left_target,
    right_target,
    synthetic_type_origin(-1, 0UL),
  )
}

///|
fn impl_patterns_overlap(
  scratch : ImplPatternScratch,
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  left : IndexedImpl,
  right : IndexedImpl,
) -> Bool {
  scratch.solver.reset()
  let left_external = semantic_id_module(left.declaration) !=
    collected.module_id
  let right_external = semantic_id_module(right.declaration) !=
    collected.module_id
  let left_generics = if left_external {
    { start: 0, length: 0, }
  } else {
    collected.generic_parameters_of(left.declaration)
  }
  let right_generics = if right_external {
    { start: 0, length: 0, }
  } else {
    collected.generic_parameters_of(right.declaration)
  }
  let left_trait = scratch.import_pattern(
    resolved,
    left.trait_type,
    left_generics,
    left_external,
    true,
  )
  let left_target = scratch.import_pattern(
    resolved,
    left.target_type,
    left_generics,
    left_external,
    false,
  )
  let right_trait = scratch.import_pattern(
    resolved,
    right.trait_type,
    right_generics,
    right_external,
    true,
  )
  let right_target = scratch.import_pattern(
    resolved,
    right.target_type,
    right_generics,
    right_external,
    false,
  )
  scratch.solver.unify(left_trait, right_trait, synthetic_type_origin(-1, 0UL)) &&
  scratch.solver.unify(
    left_target,
    right_target,
    synthetic_type_origin(-1, 0UL),
  )
}

///|
fn impl_pattern_matches(
  scratch : ImplPatternScratch,
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  general : IndexedImpl,
  specific : IndexedImpl,
) -> Bool {
  scratch.solver.reset()
  let general_external = semantic_id_module(general.declaration) !=
    collected.module_id
  let general_generics = if general_external {
    { start: 0, length: 0, }
  } else {
    collected.generic_parameters_of(general.declaration)
  }
  let general_trait = scratch.import_pattern(
    resolved,
    general.trait_type,
    general_generics,
    general_external,
    true,
  )
  let general_target = scratch.import_pattern(
    resolved,
    general.target_type,
    general_generics,
    general_external,
    false,
  )
  scratch.solver.unify(
    general_trait,
    scratch.solver.resolved_type(specific.trait_type),
    synthetic_type_origin(-1, 0UL),
  ) &&
  scratch.solver.unify(
    general_target,
    scratch.solver.resolved_type(specific.target_type),
    synthetic_type_origin(-1, 0UL),
  )
}

///|
fn build_module_impl_index_internal(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports?,
) -> ModuleImplIndex {
  if collected.module_id != resolved.module_id {
    abort("impl index inputs belong to different modules")
  }
  let method_spans = impl_method_spans(collected)
  let callable_indices = impl_callable_indices(collected)
  let implementations : Array[IndexedImpl] = []
  let methods : Array[IndexedImplMethod] = []
  let diagnostics : Array[ImplIndexDiagnostic] = []
  for index, implementation in collected.impls {
    let offset = impl_declaration_offset(collected, implementation.declaration)
    let (target_head, target_poison) = resolved_impl_target_head(
      resolved,
      resolved.impl_target_types[index],
    )
    let mut valid = target_head != ErrorImplTargetHead
    if !valid && !target_poison {
      diagnostics.push(
        InvalidImplTargetHead(implementation.declaration, offset),
      )
    }
    let (kind, method_span) = match implementation.trait_type {
      None =>
        (
          InherentIndexedImpl,
          collect_inherent_methods(
            collected, method_spans, implementation, methods,
          ),
        )
      Some(_) => {
        let (trait_head, trait_poison) = resolved_impl_trait_head(
          resolved,
          resolved.impl_trait_types[index],
        )
        match trait_head {
          Some(trait_declaration) => {
            let method_span = if semantic_id_module(trait_declaration) ==
              collected.module_id {
              validate_trait_impl_methods(
                collected,
                resolved,
                callable_indices,
                method_spans,
                implementation,
                trait_declaration,
                resolved.impl_trait_types[index],
                resolved.impl_target_types[index],
                methods,
                diagnostics,
              )
            } else {
              match imports {
                Some(imported) =>
                  collect_imported_trait_methods(
                    collected, method_spans, implementation, trait_declaration, imported,
                    methods,
                  )
                None =>
                  collect_inherent_methods(
                    collected, method_spans, implementation, methods,
                  )
              }
            }
            (TraitIndexedImpl(trait_declaration), method_span)
          }
          None => {
            valid = false
            if !trait_poison {
              diagnostics.push(
                InvalidImplTraitHead(implementation.declaration, offset),
              )
            }
            (
              TraitIndexedImpl(0UL),
              collect_inherent_methods(
                collected, method_spans, implementation, methods,
              ),
            )
          }
        }
      }
    }
    match kind {
      TraitIndexedImpl(trait_declaration) if valid &&
        !implementation.foreign_ &&
        !trait_impl_is_package_owned(
          collected.module_id,
          trait_declaration,
          target_head,
        ) => {
        valid = false
        diagnostics.push(
          OrphanTraitImpl(
            implementation.declaration,
            trait_declaration,
            target_head,
            offset,
          ),
        )
      }
      _ => ()
    }
    implementations.push({
      declaration: implementation.declaration,
      kind,
      target_head,
      trait_type: resolved.impl_trait_types[index],
      target_type: resolved.impl_target_types[index],
      methods: method_span,
      bucket: -1,
      valid,
      coherent: valid,
      specificity: 0,
    })
  }

  let bucket_lookup : Map[(Int, UInt64, Int, UInt64), Int] = Map::default()
  let bucket_kinds : Array[ImplBucketKind] = []
  let bucket_heads : Array[ImplTargetHead] = []
  let bucket_counts : Array[Int] = []
  for index, implementation in implementations {
    if !implementation.valid {
      continue
    }
    let (head_kind, head_id) = impl_head_key(implementation.target_head)
    let (bucket_kind, trait_id) = match implementation.kind {
      InherentIndexedImpl => (0, 0UL)
      TraitIndexedImpl(trait_declaration) => (1, trait_declaration)
    }
    let key = (bucket_kind, trait_id, head_kind, head_id)
    let bucket = bucket_lookup
      .get(key)
      .unwrap_or_else(fn() {
        let created = bucket_kinds.length()
        bucket_lookup[key] = created
        bucket_kinds.push(
          match implementation.kind {
            InherentIndexedImpl => InherentImplBucket
            TraitIndexedImpl(trait_declaration) =>
              TraitImplBucket(trait_declaration)
          },
        )
        bucket_heads.push(implementation.target_head)
        bucket_counts.push(0)
        created
      })
    bucket_counts[bucket] += 1
    implementations[index] = {
      declaration: implementation.declaration,
      kind: implementation.kind,
      target_head: implementation.target_head,
      trait_type: implementation.trait_type,
      target_type: implementation.target_type,
      methods: implementation.methods,
      bucket,
      valid: implementation.valid,
      coherent: implementation.coherent,
      specificity: implementation.specificity,
    }
  }

  let buckets : Array[ImplBucket] = []
  let bucket_implementations = Array::make(implementations.length(), -1)
  let cursors : Array[Int] = []
  let mut start = 0
  for bucket in 0..<bucket_kinds.length() {
    buckets.push({
      kind: bucket_kinds[bucket],
      target_head: bucket_heads[bucket],
      implementations: { start, length: bucket_counts[bucket], },
    })
    cursors.push(start)
    start += bucket_counts[bucket]
  }
  for index, implementation in implementations {
    if implementation.bucket >= 0 {
      let cursor = cursors[implementation.bucket]
      bucket_implementations[cursor] = index
      cursors[implementation.bucket] = cursor + 1
    }
  }

  let coherence = Array::make(implementations.length(), true)
  let specificity = Array::make(implementations.length(), 0)
  let pattern_scratch = ImplPatternScratch::new(resolved)
  for bucket in buckets {
    match bucket.kind {
      TraitImplBucket(trait_declaration) if bucket.implementations.length > 1 => {
        let indexed_trait = compiler_indexed_trait_kind(
            collected, trait_declaration,
          ) !=
          0
        for right_offset in 1..<bucket.implementations.length {
          let right_index = bucket_implementations[bucket.implementations.start +
            right_offset]
          let right = implementations[right_index]
          for left_offset in 0..<right_offset {
            let left_index = bucket_implementations[bucket.implementations.start +
              left_offset]
            let left = implementations[left_index]
            if indexed_trait {
              if !impl_target_patterns_overlap(
                  pattern_scratch, collected, resolved, left, right,
                ) {
                continue
              }
              coherence[left_index] = false
              coherence[right_index] = false
              diagnostics.push(
                OverlappingTraitImpl(
                  trait_declaration,
                  left.declaration,
                  right.declaration,
                  bucket.target_head,
                  impl_declaration_offset(collected, right.declaration),
                ),
              )
              break
            }
            let identical = left.trait_type == right.trait_type &&
              left.target_type == right.target_type
            if !identical &&
              collected.generic_parameters_of(left.declaration).length == 0 &&
              collected.generic_parameters_of(right.declaration).length == 0 {
              continue
            }
            if !identical &&
              !impl_patterns_overlap(
                pattern_scratch, collected, resolved, left, right,
              ) {
              continue
            }
            let left_matches_right = identical ||
              impl_pattern_matches(
                pattern_scratch, collected, resolved, left, right,
              )
            let right_matches_left = identical ||
              impl_pattern_matches(
                pattern_scratch, collected, resolved, right, left,
              )
            if left_matches_right && !right_matches_left {
              specificity[right_index] += 1
            } else if right_matches_left && !left_matches_right {
              specificity[left_index] += 1
            } else {
              coherence[left_index] = false
              coherence[right_index] = false
              diagnostics.push(
                OverlappingTraitImpl(
                  trait_declaration,
                  left.declaration,
                  right.declaration,
                  bucket.target_head,
                  impl_declaration_offset(collected, right.declaration),
                ),
              )
              break
            }
          }
        }
      }
      InherentImplBucket => {
        let seen : Map[NameId, DeclId] = Map::default()
        for offset_index in 0..<bucket.implementations.length {
          let implementation = implementations[bucket_implementations[bucket.implementations.start +
            offset_index]]
          for
            method_index in implementation.methods.start..<(implementation.methods.start +
            implementation.methods.length) {
            let indexed_method = methods[method_index]
            let collected_method = match
              collected.declaration(indexed_method.declaration) {
              Some(MethodReference(value)) => value
              _ => abort("indexed method is not a method declaration")
            }
            match seen.get(collected_method.name) {
              Some(first) =>
                diagnostics.push(
                  DuplicateInherentMethod(
                    collected_method.name,
                    first,
                    indexed_method.declaration,
                    collected_method.offset,
                  ),
                )
              None => seen[collected_method.name] = indexed_method.declaration
            }
          }
        }
      }
      _ => ()
    }
  }

  for index, implementation in implementations {
    implementations[index] = {
      declaration: implementation.declaration,
      kind: implementation.kind,
      target_head: implementation.target_head,
      trait_type: implementation.trait_type,
      target_type: implementation.target_type,
      methods: implementation.methods,
      bucket: implementation.bucket,
      valid: implementation.valid,
      coherent: implementation.valid && coherence[index],
      specificity: specificity[index],
    }
  }

  let method_dispatch : Array[IndexedMethodDispatch] = []
  let trait_method_dispatch : Array[IndexedTraitMethodDispatch] = []
  for implementation_index, implementation in implementations {
    if !implementation.valid || !implementation.coherent {
      continue
    }
    let inherent = match implementation.kind {
      InherentIndexedImpl => true
      TraitIndexedImpl(_) => false
    }
    for
      method_index in implementation.methods.start..<(implementation.methods.start +
      implementation.methods.length) {
      match implementation.kind {
        TraitIndexedImpl(_) if methods[method_index].requirement is None =>
          continue
        _ => ()
      }
      let method_info = match
        collected.declaration(methods[method_index].declaration) {
        Some(MethodReference(value)) => value
        _ => abort("indexed method is not a method declaration")
      }
      method_dispatch.push({
        target_head: implementation.target_head,
        name: method_info.name,
        inherent,
        instance: methods[method_index].instance,
        implementation: implementation_index,
        method_index,
      })
      match implementation.kind {
        TraitIndexedImpl(trait_declaration) =>
          trait_method_dispatch.push({
            trait_declaration,
            name: method_info.name,
            instance: methods[method_index].instance,
            implementation: implementation_index,
            method_index,
          })
        InherentIndexedImpl => ()
      }
    }
  }
  method_dispatch.sort_by(fn(left, right) {
    let key_order = method_dispatch_key_compare(
      left,
      right.target_head,
      right.name,
      right.inherent,
      right.instance,
    )
    if key_order != 0 {
      key_order
    } else {
      let implementation_order = left.implementation - right.implementation
      if implementation_order != 0 {
        implementation_order
      } else {
        left.method_index - right.method_index
      }
    }
  })

  trait_method_dispatch.sort_by(fn(left, right) {
    let key_order = trait_method_dispatch_key_compare(
      left,
      right.trait_declaration,
      right.name,
      right.instance,
    )
    if key_order != 0 {
      key_order
    } else {
      let implementation_order = left.implementation - right.implementation
      if implementation_order != 0 {
        implementation_order
      } else {
        left.method_index - right.method_index
      }
    }
  })

  diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      impl_diagnostic_rank(left) - impl_diagnostic_rank(right)
    }
  })
  {
    module_id: collected.module_id,
    implementations,
    methods,
    buckets,
    bucket_implementations,
    method_dispatch,
    trait_method_dispatch,
    diagnostics,
  }
}

///|
pub fn build_module_impl_index(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
) -> ModuleImplIndex {
  build_module_impl_index_internal(collected, resolved, None)
}

///|
fn rebuild_impl_buckets(index : ModuleImplIndex) -> Unit {
  let bucket_lookup : Map[(Int, UInt64, Int, UInt64), Int] = Map::default()
  let bucket_kinds : Array[ImplBucketKind] = []
  let bucket_heads : Array[ImplTargetHead] = []
  let bucket_counts : Array[Int] = []
  for implementation_index, implementation in index.implementations {
    if !implementation.valid {
      continue
    }
    let (head_kind, head_id) = impl_head_key(implementation.target_head)
    let (bucket_kind, trait_id) = match implementation.kind {
      InherentIndexedImpl => (0, 0UL)
      TraitIndexedImpl(trait_declaration) => (1, trait_declaration)
    }
    let key = (bucket_kind, trait_id, head_kind, head_id)
    let bucket = bucket_lookup
      .get(key)
      .unwrap_or_else(fn() {
        let created = bucket_kinds.length()
        bucket_lookup[key] = created
        bucket_kinds.push(
          match implementation.kind {
            InherentIndexedImpl => InherentImplBucket
            TraitIndexedImpl(trait_declaration) =>
              TraitImplBucket(trait_declaration)
          },
        )
        bucket_heads.push(implementation.target_head)
        bucket_counts.push(0)
        created
      })
    bucket_counts[bucket] += 1
    index.implementations[implementation_index] = { ..implementation, bucket, }
  }
  index.buckets.clear()
  index.bucket_implementations.clear()
  let cursors : Array[Int] = []
  let mut start = 0
  for bucket in 0..<bucket_kinds.length() {
    index.buckets.push({
      kind: bucket_kinds[bucket],
      target_head: bucket_heads[bucket],
      implementations: { start, length: bucket_counts[bucket], },
    })
    cursors.push(start)
    for _ in 0..<bucket_counts[bucket] {
      index.bucket_implementations.push(-1)
    }
    start += bucket_counts[bucket]
  }
  for implementation_index, implementation in index.implementations {
    if implementation.bucket >= 0 {
      let cursor = cursors[implementation.bucket]
      index.bucket_implementations[cursor] = implementation_index
      cursors[implementation.bucket] = cursor + 1
    }
  }
}

///|
/// Extends the validated local implementation index with immutable evidence
/// frozen by imported modules. Imported evidence is already coherence-checked
/// by its owner; the consumer only builds deterministic dispatch entries.
pub fn build_module_impl_index_with_imports(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  imports : ResolvedModuleImports,
) -> ModuleImplIndex {
  let index = build_module_impl_index_internal(
    collected,
    resolved,
    Some(imports),
  )
  let local_implementation_count = index.implementations.length()
  let imported_impl_callables : Map[DeclId, Array[FrozenInterfaceCallable]] = Map::default()
  let requirements : Map[(DeclId, String), DeclId] = {}
  for method in collected.methods {
    if method.kind == TraitMethodDecl {
      requirements[(method.parent, collected.name(method.name))] = method.id
    }
  }
  for interface_index in imports.scope.imported_interfaces {
    let interface_ = imports.scope.interfaces[interface_index].unwrap()
    for callable in interface_.callables {
      if callable.kind is FrozenTraitCallable(owner) {
        let key = (owner, callable.name)
        guard requirements.get(key) is None ||
          requirements.get(key) == Some(callable.declaration) else {
          abort("EVD-212 duplicate imported trait requirement identity")
        }
        requirements[key] = callable.declaration
      }
      let owner = match callable.kind {
        FrozenImplCallable(owner) => owner
        _ => continue
      }
      match imported_impl_callables.get(owner) {
        Some(methods) => methods.push(callable)
        None => imported_impl_callables[owner] = [callable]
      }
    }
  }
  for imported in imports.implementations {
    let (target_head, poisoned) = resolved_impl_target_head(
      resolved,
      imported.target_type,
    )
    if target_head == ErrorImplTargetHead {
      if !poisoned {
        index.diagnostics.push(InvalidImplTargetHead(imported.declaration, 0UL))
      }
      continue
    }
    let kind = if imported.trait_type < 0 {
      InherentIndexedImpl
    } else {
      match resolved_impl_trait_head(resolved, imported.trait_type) {
        (Some(trait_declaration), _) => TraitIndexedImpl(trait_declaration)
        _ => continue
      }
    }
    let method_start = index.methods.length()
    let implementation_index = index.implementations.length()
    match imported_impl_callables.get(imported.declaration) {
      Some(callables) =>
        for callable in callables {
          let resolved_callable = match imports.callable(callable.declaration) {
            Some(value) => value
            None => continue
          }
          let instance = resolved_callable.parameters.length > 0 &&
            imports.parameter_receivers[resolved_callable.parameters.start]
          let method_index = index.methods.length()
          index.methods.push({
            declaration: callable.declaration,
            requirement: match kind {
              TraitIndexedImpl(trait_) =>
                requirements.get((trait_, callable.name))
              InherentIndexedImpl => None
            },
            instance,
          })
          let name = match collected.find_name(callable.name) {
            Some(existing) => existing
            None => {
              let created = collected.names.length()
              collected.names.push(callable.name)
              collected.name_lookup[callable.name] = created
              created
            }
          }
          let inherent = match kind {
            InherentIndexedImpl => true
            TraitIndexedImpl(_) => false
          }
          index.method_dispatch.push({
            target_head,
            name,
            inherent,
            instance,
            implementation: implementation_index,
            method_index,
          })
          match kind {
            TraitIndexedImpl(trait_declaration) =>
              index.trait_method_dispatch.push({
                trait_declaration,
                name,
                instance,
                implementation: implementation_index,
                method_index,
              })
            InherentIndexedImpl => ()
          }
        }
      None => ()
    }
    index.implementations.push({
      declaration: imported.declaration,
      kind,
      target_head,
      trait_type: imported.trait_type,
      target_type: imported.target_type,
      methods: {
        start: method_start,
        length: index.methods.length() - method_start,
      },
      bucket: -1,
      valid: true,
      coherent: true,
      specificity: 0,
    })
  }
  rebuild_impl_buckets(index)
  let coherence : Array[Bool] = []
  let specificity : Array[Int] = []
  for implementation in index.implementations {
    coherence.push(implementation.coherent)
    specificity.push(implementation.specificity)
  }
  let pattern_scratch = ImplPatternScratch::new(resolved)
  for right_index in local_implementation_count..<index.implementations.length() {
    let right = index.implementations[right_index]
    if !right.valid || !right.coherent {
      continue
    }
    let right_trait = match right.kind {
      TraitIndexedImpl(declaration) => declaration
      InherentIndexedImpl => continue
    }
    let indexed_trait = compiler_indexed_trait_kind(collected, right_trait) != 0
    let bucket = index.buckets[right.bucket]
    for candidate_offset in 0..<bucket.implementations.length {
      let left_index = index.bucket_implementations[bucket.implementations.start +
        candidate_offset]
      if left_index >= right_index {
        break
      }
      let left = index.implementations[left_index]
      if !left.valid || !left.coherent {
        continue
      }
      if indexed_trait {
        if !impl_target_patterns_overlap(
            pattern_scratch, collected, resolved, left, right,
          ) {
          continue
        }
        coherence[left_index] = false
        coherence[right_index] = false
        index.diagnostics.push(
          OverlappingTraitImpl(
            right_trait,
            left.declaration,
            right.declaration,
            right.target_head,
            0UL,
          ),
        )
        break
      }
      let identical = left.trait_type == right.trait_type &&
        left.target_type == right.target_type
      if !identical &&
        !impl_type_contains_generic(resolved, left.trait_type) &&
        !impl_type_contains_generic(resolved, left.target_type) &&
        !impl_type_contains_generic(resolved, right.trait_type) &&
        !impl_type_contains_generic(resolved, right.target_type) {
        continue
      }
      if !identical &&
        !impl_patterns_overlap(
          pattern_scratch, collected, resolved, left, right,
        ) {
        continue
      }
      let left_matches_right = identical ||
        impl_pattern_matches(pattern_scratch, collected, resolved, left, right)
      let right_matches_left = identical ||
        impl_pattern_matches(pattern_scratch, collected, resolved, right, left)
      if left_matches_right && !right_matches_left {
        specificity[right_index] += 1
      } else if right_matches_left && !left_matches_right {
        specificity[left_index] += 1
      } else {
        coherence[left_index] = false
        coherence[right_index] = false
        index.diagnostics.push(
          OverlappingTraitImpl(
            right_trait,
            left.declaration,
            right.declaration,
            right.target_head,
            0UL,
          ),
        )
        break
      }
    }
  }
  for implementation_index, implementation in index.implementations {
    index.implementations[implementation_index] = {
      ..implementation,
      coherent: implementation.valid && coherence[implementation_index],
      specificity: specificity[implementation_index],
    }
  }
  let retained_methods : Array[IndexedMethodDispatch] = []
  for dispatch in index.method_dispatch {
    if index.implementations[dispatch.implementation].coherent {
      retained_methods.push(dispatch)
    }
  }
  index.method_dispatch.clear()
  for dispatch in retained_methods {
    index.method_dispatch.push(dispatch)
  }
  let retained_trait_methods : Array[IndexedTraitMethodDispatch] = []
  for dispatch in index.trait_method_dispatch {
    if index.implementations[dispatch.implementation].coherent {
      retained_trait_methods.push(dispatch)
    }
  }
  index.trait_method_dispatch.clear()
  for dispatch in retained_trait_methods {
    index.trait_method_dispatch.push(dispatch)
  }
  index.diagnostics.sort_by(fn(left, right) {
    let offset_order = left.offset().compare(right.offset())
    if offset_order != 0 {
      offset_order
    } else {
      impl_diagnostic_rank(left) - impl_diagnostic_rank(right)
    }
  })
  index.method_dispatch.sort_by(fn(left, right) {
    let key_order = method_dispatch_key_compare(
      left,
      right.target_head,
      right.name,
      right.inherent,
      right.instance,
    )
    if key_order != 0 {
      key_order
    } else {
      let implementation_order = left.implementation - right.implementation
      if implementation_order != 0 {
        implementation_order
      } else {
        left.method_index - right.method_index
      }
    }
  })
  index.trait_method_dispatch.sort_by(fn(left, right) {
    let key_order = trait_method_dispatch_key_compare(
      left,
      right.trait_declaration,
      right.name,
      right.instance,
    )
    if key_order != 0 {
      key_order
    } else {
      let implementation_order = left.implementation - right.implementation
      if implementation_order != 0 {
        implementation_order
      } else {
        left.method_index - right.method_index
      }
    }
  })
  index
}
