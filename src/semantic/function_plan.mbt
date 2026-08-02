///|
pub enum PlannedCallableKind {
  PlannedBuiltinCallable(Bytes)
  PlannedFunctionCallable(BodyId)
  PlannedTraitMethodCallable(DeclId)
  PlannedImplMethodCallable(DeclId, BodyId?)
} derive(Eq, Debug)

///|
pub struct PlannedParameter {
  parameter : ParameterId
  declaration : DeclId
  index : Int
  receiver : Bool
  type_ : ResolvedTypeId
  shape : PlannedValueShape
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedCallable {
  declaration : DeclId
  name : Bytes
  visibility : SemanticVisibility
  compiler_owned : Bool
  is_test : Bool
  is_test_entry : Bool
  test_name : Bytes
  kind : PlannedCallableKind
  owner_generic_parameters : HirSpan
  generic_parameters : HirSpan
  parameters : HirSpan
  has_receiver : Bool
  self_type : ResolvedTypeId
  self_shape : PlannedValueShape
  result_type : ResolvedTypeId
  result_shape : PlannedValueShape
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedModuleFunctions {
  module_id : ModuleId
  callables : Array[PlannedCallable]
  callable_by_declaration : Array[Int]
  parameters : Array[PlannedParameter]
} derive(Eq, Debug)

///|
pub fn PlannedModuleFunctions::callable_of(
  self : PlannedModuleFunctions,
  declaration : DeclId,
) -> PlannedCallable? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  let declaration_index = semantic_id_local(declaration)
  if declaration_index < 0 ||
    declaration_index >= self.callable_by_declaration.length() {
    return None
  }
  let callable = self.callable_by_declaration[declaration_index]
  if callable < 0 {
    None
  } else {
    Some(self.callables[callable])
  }
}

///|
fn planned_builtin_name(
  collected : CollectedModule,
  declaration : DeclId,
) -> Bytes {
  for builtin in collected.builtins {
    if builtin.declaration == declaration {
      return builtin.builtin_name
    }
  }
  b""
}

///|
fn planned_impl_target_type(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  declaration : DeclId,
) -> ResolvedTypeId {
  for index, implementation in collected.impls {
    if implementation.declaration == declaration {
      return resolved.impl_target_types[index]
    }
  }
  -1
}

///|
fn planned_callable_type_shape(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  self_owner : DeclId,
  self_type : ResolvedTypeId,
) -> PlannedValueShape {
  let mut current = root
  while true {
    match resolved.types[current] {
      SelfType(owner) if owner == self_owner =>
        if self_type >= 0 {
          return planned_resolved_value_shape(resolved, self_type)
        } else {
          return GenericPlannedValueShape
        }
      AppliedType(base, _) => current = base
      _ => return planned_resolved_value_shape(resolved, current)
    }
  }
  ErrorPlannedValueShape
}

///|
fn planned_callable_identity(
  collected : CollectedModule,
  declaration : DeclId,
) -> (Bytes, SemanticVisibility) {
  let (name, visibility) = match collected.declaration(declaration) {
    Some(TopLevelReference(value)) => (value.name, value.visibility)
    Some(MethodReference(value)) => (value.name, value.visibility)
    None => abort("callable declaration is missing")
  }
  let output = Buffer()
  output.write_string_utf8(collected.name(name))
  (output.to_bytes(), visibility)
}

///|
fn planned_callable_metadata(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
  declaration : DeclId,
) -> (PlannedCallableKind, DeclId, HirSpan, ResolvedTypeId, UInt64) {
  match collected.declaration(declaration) {
    Some(TopLevelReference(value)) =>
      match value.kind {
        BuiltinDecl =>
          (
            PlannedBuiltinCallable(planned_builtin_name(collected, declaration)),
            declaration,
            { start: 0, length: 0 },
            -1,
            value.offset,
          )
        FunctionDecl | TestDecl =>
          (
            PlannedFunctionCallable(collected.body_of(declaration).unwrap().id),
            declaration,
            { start: 0, length: 0 },
            -1,
            value.offset,
          )
        _ => abort("non-callable top-level declaration has a signature")
      }
    Some(MethodReference(value)) =>
      match value.kind {
        TraitMethodDecl =>
          (
            PlannedTraitMethodCallable(value.parent),
            value.parent,
            collected.generic_parameters_of(value.parent),
            -1,
            value.offset,
          )
        ImplMethodDecl => {
          let body = match collected.body_of(declaration) {
            Some(body) => Some(body.id)
            None => None
          }
          (
            PlannedImplMethodCallable(value.parent, body),
            value.parent,
            collected.generic_parameters_of(value.parent),
            planned_impl_target_type(collected, resolved, value.parent),
            value.offset,
          )
        }
      }
    None => abort("callable declaration is missing")
  }
}

///|
fn planned_test_name(
  collected : CollectedModule,
  declaration : DeclId,
) -> Bytes {
  for test_ in collected.tests {
    if test_.declaration == declaration {
      return test_.display_name
    }
  }
  b""
}

///|
pub fn plan_module_functions(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
) -> PlannedModuleFunctions {
  if collected.module_id != resolved.module_id {
    abort("function plan inputs belong to different modules")
  }
  if collected.callables.length() == 0 {
    return {
      module_id: collected.module_id,
      callables: [],
      callable_by_declaration: [],
      parameters: [],
    }
  }
  let callables : Array[PlannedCallable] = []
  let callable_by_declaration = Array::make(
    collected.declaration_locations.length(),
    -1,
  )
  let parameters = Array::make(collected.parameters.length(), {
    parameter: 0UL,
    declaration: 0UL,
    index: -1,
    receiver: false,
    type_: resolved.error_type,
    shape: ErrorPlannedValueShape,
    offset: 0UL,
  })
  for callable_index, callable in collected.callables {
    let declaration = callable.declaration
    let (kind, self_owner, owner_generics, self_type, offset) = planned_callable_metadata(
      collected, resolved, declaration,
    )
    let (name, visibility) = planned_callable_identity(collected, declaration)
    let parameter_span = collected.parameters_of(declaration)
    let mut has_receiver = false
    let mut receiver_shape = ErrorPlannedValueShape
    for index in 0..<parameter_span.length {
      let parameter_index = parameter_span.start + index
      let source = collected.parameters[parameter_index]
      let type_ = resolved.parameter_types[parameter_index]
      let receiver = source.kind == ReceiverParameterDecl
      let shape = planned_callable_type_shape(
        resolved, type_, self_owner, self_type,
      )
      if receiver {
        has_receiver = true
        receiver_shape = shape
      }
      parameters[parameter_index] = {
        parameter: source.id,
        declaration,
        index: source.index,
        receiver,
        type_,
        shape,
        offset: source.offset,
      }
    }
    let result_type = resolved.callable_return_types[callable_index]
    let self_shape = if has_receiver {
      receiver_shape
    } else {
      ErrorPlannedValueShape
    }
    callable_by_declaration[semantic_id_local(declaration)] = callable_index
    let compiler_owned = semantic_id_module(declaration) >= 0xffff0000UL ||
      semantic_id_local(declaration) < collected.preamble_declaration_count
    callables.push({
      declaration,
      name,
      visibility: if compiler_owned {
        ModuleVisible
      } else {
        visibility
      },
      compiler_owned,
      is_test: collected.declaration_is_test_only(declaration) ||
      (match collected.declaration(declaration) {
        Some(TopLevelReference({ kind: TestDecl, .. })) => true
        _ => false
      }),
      is_test_entry: match collected.declaration(declaration) {
        Some(TopLevelReference({ kind: TestDecl, .. })) => true
        _ => false
      },
      test_name: planned_test_name(collected, declaration),
      kind,
      owner_generic_parameters: owner_generics,
      generic_parameters: collected.generic_parameters_of(declaration),
      parameters: parameter_span,
      has_receiver,
      self_type,
      self_shape,
      result_type,
      result_shape: planned_callable_type_shape(
        resolved, result_type, self_owner, self_type,
      ),
      offset,
    })
  }
  {
    module_id: collected.module_id,
    callables,
    callable_by_declaration,
    parameters,
  }
}
