///|
pub enum PlannedWasmTypeReference {
  WasmModuleTypeReference(Int)
  WasmRecursiveTypeReference(Int)
} derive(Eq, Debug)

///|
pub enum PlannedWasmStorageType {
  WasmI8SignedStorage
  WasmI8UnsignedStorage
  WasmI16SignedStorage
  WasmI16UnsignedStorage
  WasmI32Storage
  WasmI64Storage
  WasmF32Storage
  WasmF64Storage
  WasmV128Storage
  WasmStringRefStorage
  WasmNullableEqRefStorage
  WasmNullableFunctionRefStorage
  WasmFunctionRefStorage(Int)
  WasmNominalRefStorage(PlannedWasmTypeReference)
  WasmExternalNominalRefStorage(DeclId)
  WasmFixedArrayRefStorage(Int)
  WasmNullableNominalRefStorage(PlannedWasmTypeReference)
  WasmNullableExternalNominalRefStorage(DeclId)
} derive(Eq, Debug)

///|
pub enum PlannedWasmFieldRole {
  WasmStructField(FieldId)
  WasmEnumTagField
  WasmTuplePayloadField(VariantId, Int)
  WasmStructPayloadField(FieldId)
  WasmClosureEntryField
  WasmCaptureCellValueField(Int)
  WasmLambdaCaptureField(LambdaId, Int)
  WasmTraitObjectReceiverField(DeclId)
  WasmTraitObjectVTableField(DeclId)
  WasmTraitMethodField(DeclId, DeclId, Int)
} derive(Eq, Debug)

///|
pub struct PlannedWasmField {
  role : PlannedWasmFieldRole
  physical_index : Int
  storage : PlannedWasmStorageType
  mutable_ : Bool
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum WasmEnumShapeSharing {
  DistinctEnumShapes
  ShareExactEnumShapes
} derive(Eq, Debug)

///|
pub struct WasmGCPlanningOptions {
  enum_shape_sharing : WasmEnumShapeSharing
  reuse_unit_subtype_base : Bool
  dense_enum_dispatch : Bool
  emit_tests : Bool
} derive(Eq, Debug)

///|
pub fn WasmGCPlanningOptions::subtype_families() -> WasmGCPlanningOptions {
  {
    enum_shape_sharing: DistinctEnumShapes,
    reuse_unit_subtype_base: false,
    dense_enum_dispatch: false,
    emit_tests: false,
  }
}

///|
pub fn WasmGCPlanningOptions::optimized_subtype_families() -> WasmGCPlanningOptions {
  {
    enum_shape_sharing: ShareExactEnumShapes,
    reuse_unit_subtype_base: true,
    dense_enum_dispatch: true,
    emit_tests: false,
  }
}

///|
pub fn WasmGCPlanningOptions::test_mode() -> WasmGCPlanningOptions {
  {
    enum_shape_sharing: ShareExactEnumShapes,
    reuse_unit_subtype_base: true,
    dense_enum_dispatch: true,
    emit_tests: true,
  }
}

///|
pub enum PlannedWasmPhysicalTypeKind {
  PlannedWasmStructType(DeclId)
  PlannedWasmForeignMarkerType(DeclId)
  PlannedWasmEnumBaseType(DeclId)
  PlannedWasmEnumSubtypeType(DeclId, VariantId, Int)
  PlannedWasmClosureType
  PlannedWasmCaptureCellType(Int)
  PlannedWasmLambdaClosureType(LambdaId)
  PlannedWasmTraitMethodSignatureType(DeclId)
  PlannedWasmTraitVTableType(DeclId)
  PlannedWasmTraitObjectType(DeclId)
} derive(Eq, Debug)

///|
pub struct PlannedWasmPhysicalType {
  kind : PlannedWasmPhysicalTypeKind
  type_index : Int
  group_index : Int
  fields : HirSpan
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedWasmRecursiveGroup {
  types : HirSpan
  first_type_index : Int
} derive(Eq, Debug)

///|
pub enum PlannedWasmValueType {
  WasmI32Value
  WasmI64Value
  WasmF32Value
  WasmF64Value
  WasmV128Value
  WasmStringRefValue
  WasmNullableEqRefValue
  WasmFunctionRefValue(Int)
  WasmNominalRefValue(Int)
  WasmExternalNominalRefValue(DeclId)
  WasmFixedArrayRefValue(Int)
  WasmNullableNominalRefValue(Int)
  WasmNullableExternalNominalRefValue(DeclId)
} derive(Eq, Debug)

///|
pub struct PlannedWasmFunctionTypeFragment {
  resolved_type : ResolvedTypeId
  signature_type_index : Int
  parameters : HirSpan
  results : HirSpan
} derive(Eq, Debug)

///|
pub enum WasmImportKind {
  HostWasmImport
  StaticLinkWasmImport
  WasiWasmImport
} derive(Eq, Debug)

///|
pub struct WasmImportIdentity {
  module_name : Bytes
  field : Bytes
  kind : WasmImportKind
} derive(Eq, Debug)

///|
pub fn WasmImportIdentity::host(field : Bytes) -> WasmImportIdentity {
  { module_name: b"dew", field, kind: HostWasmImport, }
}

///|
pub fn WasmImportIdentity::wasi(field : Bytes) -> WasmImportIdentity {
  { module_name: b"wasi_snapshot_preview1", field, kind: WasiWasmImport, }
}

///|
pub fn WasmImportIdentity::static_link(
  logical_name : Bytes,
  field : Bytes,
) -> WasmImportIdentity {
  let module_name = Buffer(size_hint=5 + logical_name.length())
  module_name.write_bytes(b"link:")
  module_name.write_bytes(logical_name)
  { module_name: module_name.to_bytes(), field, kind: StaticLinkWasmImport, }
}

///|
pub fn WasmImportIdentity::lookup_name(self : WasmImportIdentity) -> Bytes {
  match self.kind {
    HostWasmImport => self.field
    WasiWasmImport | StaticLinkWasmImport => {
      let output = Buffer(
        size_hint=self.module_name.length() + 1 + self.field.length(),
      )
      output.write_bytes(self.module_name)
      output.write_byte(b'.')
      output.write_bytes(self.field)
      output.to_bytes()
    }
  }
}

///|
pub enum PlannedWasmFunctionKind {
  PlannedWasmImportedFunction(WasmImportIdentity)
  PlannedWasmInlineBuiltinFunction(Bytes)
  PlannedWasmRuntimeFunction(Bytes)
  PlannedWasmDefinedFunction(BodyId)
  PlannedWasmDefinedLambdaFunction(LambdaId)
  PlannedWasmTraitAdapterFunction(DeclId, DeclId)
  PlannedWasmSignatureOnlyFunction
} derive(Eq, Debug)

///|
pub enum PlannedSpecializationTraitEvidenceKind {
  PlannedConcreteTraitEvidence(DeclId, HirSpan)
  PlannedRuntimeTraitEvidence(DeclId, Int)
} derive(Eq, Debug)

///|
pub struct PlannedSpecializationTraitEvidence {
  kind : PlannedSpecializationTraitEvidenceKind
  prerequisites : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedWasmFunctionFragment {
  declaration : DeclId
  lambda : LambdaId
  name : Bytes
  visibility : SemanticVisibility
  is_test : Bool
  is_test_entry : Bool
  test_name : Bytes
  kind : PlannedWasmFunctionKind
  direct_builtin : Bytes
  elided : Bool
  signature_type_index : Int
  function_index : Int
  parameters : HirSpan
  results : HirSpan
  specialization_shapes : HirSpan
  specialization_evidence : HirSpan
  specialization_abi_key : String
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedWasmTraitMethod {
  trait_declaration : DeclId
  requirement : DeclId
  implementation_method : DeclId
  receiver_shape : PlannedValueShape
  receiver_nominal : DeclId
  implementation_specialization_abi_key : String
  slot : Int
  signature_type_index : Int
  adapter_function : Int
} derive(Eq, Debug)

///|
pub struct PlannedWasmTraitDictionary {
  trait_declaration : DeclId
  implementation : DeclId
  evidence : Int
  evidence_key : String
  vtable_type_index : Int
  object_type_index : Int
  methods : HirSpan
  runtime_evidence_parameters : HirSpan
  runtime_materialized : Bool
} derive(Eq, Debug)

///|
pub struct PlannedWasmTraitLayout {
  trait_declaration : DeclId
  vtable_type_index : Int
  object_type_index : Int
  methods : HirSpan
} derive(Eq, Debug)

///|
pub struct PlannedWasmVariantField {
  role : PlannedWasmFieldRole
  physical_index : Int
  storage : PlannedWasmStorageType
} derive(Eq, Debug)

///|
pub struct PlannedModuleWasmGCFragments {
  module_id : ModuleId
  dense_enum_dispatch : Bool
  emit_tests : Bool
  type_groups : Array[PlannedWasmRecursiveGroup]
  physical_types : Array[PlannedWasmPhysicalType]
  fields : Array[PlannedWasmField]
  type_index_by_declaration : Array[Int]
  payload_type_index_by_variant : Array[Int]
  variant_declarations : Array[DeclId]
  variant_tags : Array[Int]
  variant_field_spans : Array[HirSpan]
  variant_fields : Array[PlannedWasmVariantField]
  field_names : Array[String]
  closure_type_index : Int
  capture_cell_type_indices : Array[Int]
  lambda_closure_type_indices : Array[Int]
  lambda_capture_field_indices : Array[Int]
  function_types : Array[PlannedWasmFunctionTypeFragment]
  function_type_by_resolved : Array[Int]
  closure_entry_type_by_resolved : Array[Int]
  erased_closure_direct_type_by_resolved : Array[Int]
  erased_closure_entry_type_by_resolved : Array[Int]
  lambda_entry_signature_indices : Array[Int]
  lambda_capture_parameter_indices : Array[Int]
  specialized_lambda_layouts : Map[String, CompileTimeLambdaLayout]
  trait_layouts : Array[PlannedWasmTraitLayout]
  trait_layout_methods : Array[DeclId]
  trait_method_signature_indices : Array[Int]
  trait_dictionaries : Array[PlannedWasmTraitDictionary]
  trait_dictionary_runtime_evidence_parameters : Array[Int]
  trait_methods : Array[PlannedWasmTraitMethod]
  functions : Array[PlannedWasmFunctionFragment]
  function_by_declaration : Array[Int]
  lambda_function_indices : Array[Int]
  function_value_types : Array[PlannedWasmValueType]
  specialization_shapes : Array[PlannedValueShape]
  specialization_evidence_roots : Array[Int]
  specialization_trait_evidence : Array[PlannedSpecializationTraitEvidence]
  specialization_evidence_children : Array[Int]
  specialization_evidence_arguments : Array[PlannedValueShape]
  signature_type_count : Int
  imported_function_count : Int
  defined_function_count : Int
  imported_function_indices : Map[Bytes, Int]
  runtime_function_indices : Map[Bytes, Int]
  uses_text_runtime : Bool
  uses_fixed_array_runtime : Bool
  uses_linear_memory : Bool
} derive(Eq, Debug)

///|
pub fn PlannedModuleWasmGCFragments::imported_function_index(
  self : PlannedModuleWasmGCFragments,
  name : Bytes,
) -> Int {
  self.imported_function_indices.get(name).unwrap_or(-1)
}

///|
pub fn PlannedModuleWasmGCFragments::runtime_function_index(
  self : PlannedModuleWasmGCFragments,
  name : Bytes,
) -> Int {
  self.runtime_function_indices.get(name).unwrap_or(-1)
}

///|
pub fn PlannedModuleWasmGCFragments::type_index_of(
  self : PlannedModuleWasmGCFragments,
  declaration : DeclId,
) -> Int? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= self.type_index_by_declaration.length() {
    return None
  }
  let index = self.type_index_by_declaration[local_index]
  if index < 0 {
    None
  } else {
    Some(index)
  }
}

///|
pub fn PlannedModuleWasmGCFragments::payload_type_index_of(
  self : PlannedModuleWasmGCFragments,
  variant : VariantId,
) -> Int? {
  if semantic_id_module(variant) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(variant)
  if local_index < 0 ||
    local_index >= self.payload_type_index_by_variant.length() {
    return None
  }
  let index = self.payload_type_index_by_variant[local_index]
  if index < 0 {
    None
  } else {
    Some(index)
  }
}

///|
pub fn PlannedModuleWasmGCFragments::variant_declaration_of(
  self : PlannedModuleWasmGCFragments,
  variant : VariantId,
) -> DeclId? {
  if semantic_id_module(variant) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(variant)
  if local_index < 0 ||
    local_index >= self.variant_declarations.length() ||
    self.variant_tags[local_index] < 0 {
    return None
  }
  Some(self.variant_declarations[local_index])
}

///|
pub fn PlannedModuleWasmGCFragments::variant_tag_of(
  self : PlannedModuleWasmGCFragments,
  variant : VariantId,
) -> Int? {
  if semantic_id_module(variant) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(variant)
  if local_index < 0 ||
    local_index >= self.variant_tags.length() ||
    self.variant_tags[local_index] < 0 {
    return None
  }
  Some(self.variant_tags[local_index])
}

///|
pub fn PlannedModuleWasmGCFragments::variant_fields_of(
  self : PlannedModuleWasmGCFragments,
  variant : VariantId,
) -> ArrayView[PlannedWasmVariantField] {
  if semantic_id_module(variant) != self.module_id {
    return self.variant_fields[0:0]
  }
  let local_index = semantic_id_local(variant)
  if local_index < 0 || local_index >= self.variant_field_spans.length() {
    return self.variant_fields[0:0]
  }
  let span = self.variant_field_spans[local_index]
  self.variant_fields[span.start:span.start + span.length]
}

///|
pub fn PlannedModuleWasmGCFragments::field_name_of(
  self : PlannedModuleWasmGCFragments,
  field : FieldId,
) -> String? {
  if semantic_id_module(field) != self.module_id {
    return None
  }
  let local_index = semantic_id_local(field)
  if local_index < 0 || local_index >= self.field_names.length() {
    return None
  }
  Some(self.field_names[local_index])
}

///|
pub fn PlannedModuleWasmGCFragments::function_of(
  self : PlannedModuleWasmGCFragments,
  declaration : DeclId,
) -> PlannedWasmFunctionFragment? {
  if semantic_id_module(declaration) == self.module_id {
    let local_index = semantic_id_local(declaration)
    if local_index >= 0 && local_index < self.function_by_declaration.length() {
      let index = self.function_by_declaration[local_index]
      if index >= 0 {
        return Some(self.functions[index])
      }
    }
  }
  for function_ in self.functions {
    if function_.declaration == declaration {
      return Some(function_)
    }
  }
  None
}

///|
priv struct WasmPhysicalTypeSource {
  kind : PlannedWasmPhysicalTypeKind
  offset : UInt64
  generic_carriers : Array[Int]
}

///|
priv struct WasmPhysicalTypeJob {
  dependencies : Array[Int]
}

///|
priv struct WasmFunctionFragmentJob {
  kind : PlannedWasmFunctionKind
  parameters : Array[PlannedWasmValueType]
  results : Array[PlannedWasmValueType]
}

///|
fn wasmgc_reachable_defined_functions(
  lowering : PlannedModuleLowering,
  functions : PlannedModuleFunctions,
  emit_tests : Bool,
  program_roots : Map[DeclId, Bool],
) -> Array[Bool] {
  let reachable = Array::make(functions.callables.length(), false)
  let work : Array[Int] = []
  for callable_index, callable in functions.callables {
    if (
        program_roots.contains(callable.declaration) ||
        callable.visibility == Public ||
        (program_roots.length() == 0 && !callable.compiler_owned)
      ) &&
      (!callable.is_test || emit_tests) {
      reachable[callable_index] = true
      work.push(callable_index)
    }
  }
  for step in lowering.initialization.steps {
    if step.test_only && !emit_tests {
      continue
    }
    let body_id = match step.kind {
      PlannedInitializeModuleValue(_, body, _) => body
      PlannedCyclicModuleValues(_) => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      let target = match lowering.expressions[expression].kind {
        PlannedDirectCall(declaration, _, _, _)
        | PlannedTailCall(declaration, _, _, _)
        | PlannedOperatorCall(declaration, _, _, _, _)
        | PlannedIndexCall(declaration, _, _, _)
        | PlannedIndexSetCall(declaration, _, _, _, _)
        | PlannedFunctionReference(declaration, _) => declaration
        _ => continue
      }
      if semantic_id_module(target) != lowering.module_id {
        continue
      }
      let local_index = semantic_id_local(target)
      if local_index < 0 ||
        local_index >= functions.callable_by_declaration.length() {
        continue
      }
      let target_callable = functions.callable_by_declaration[local_index]
      if target_callable >= 0 &&
        (!functions.callables[target_callable].is_test || emit_tests) &&
        !reachable[target_callable] {
        reachable[target_callable] = true
        work.push(target_callable)
      }
    }
  }
  while work.length() > 0 {
    let callable_index = work.pop().unwrap()
    let body_id = match functions.callables[callable_index].kind {
      PlannedFunctionCallable(body)
      | PlannedImplMethodCallable(_, Some(body)) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      let target = match lowering.expressions[expression].kind {
        PlannedDirectCall(declaration, _, _, _)
        | PlannedTailCall(declaration, _, _, _)
        | PlannedOperatorCall(declaration, _, _, _, _)
        | PlannedIndexCall(declaration, _, _, _)
        | PlannedIndexSetCall(declaration, _, _, _, _)
        | PlannedFunctionReference(declaration, _) => declaration
        _ => continue
      }
      if semantic_id_module(target) != lowering.module_id {
        continue
      }
      let local_index = semantic_id_local(target)
      if local_index < 0 ||
        local_index >= functions.callable_by_declaration.length() {
        continue
      }
      let target_callable = functions.callable_by_declaration[local_index]
      if target_callable >= 0 &&
        functions.callables[target_callable].is_test &&
        !emit_tests {
        continue
      }
      if target_callable >= 0 && !reachable[target_callable] {
        reachable[target_callable] = true
        work.push(target_callable)
      }
    }
  }
  reachable
}

///| Runtime functions remain ordinary planned callables, but some contain

///| private calls that are not represented in Dew HIR. Freeze those exact

///|
/// dependencies before function-index assignment.
fn wasmgc_add_runtime_dependencies(
  jobs : Array[WasmFunctionFragmentJob?],
  reachable : Array[Bool],
) -> Unit {
  let mut validator = -1
  let mut conversion = -1
  let mut string_as_bytes = -1
  let mut wasi_write = -1
  let mut wasi_read = -1
  let mut test_assert = -1
  let debug_runtimes : Array[Int] = []
  let mut wasi_write_import = -1
  let mut wasi_read_import = -1
  for index, job in jobs {
    match job.unwrap().kind {
      PlannedWasmRuntimeFunction(name) =>
        if name == b"dew_bytes_is_valid_utf8" {
          validator = index
        } else if name == b"dew_bytes_to_string" {
          conversion = index
        } else if name == b"dew_string_as_bytes" {
          string_as_bytes = index
        } else if name == b"dew_wasi_fd_write" {
          wasi_write = index
        } else if name == b"dew_wasi_fd_read" {
          wasi_read = index
        } else if name == b"dew_test_assert" {
          test_assert = index
        } else if wasmgc_builtin_is_debug_runtime(name) {
          debug_runtimes.push(index)
        }
      PlannedWasmImportedFunction(identity) =>
        if identity.module_name == b"wasi_snapshot_preview1" &&
          identity.field == b"fd_write" {
          wasi_write_import = index
        } else if identity.module_name == b"wasi_snapshot_preview1" &&
          identity.field == b"fd_read" {
          wasi_read_import = index
        }
      _ => ()
    }
  }
  if conversion >= 0 && reachable[conversion] && validator >= 0 {
    reachable[validator] = true
  }
  if test_assert >= 0 && reachable[test_assert] {
    if string_as_bytes >= 0 {
      reachable[string_as_bytes] = true
    }
    if wasi_write >= 0 {
      reachable[wasi_write] = true
    }
  }
  if wasi_write >= 0 && reachable[wasi_write] && wasi_write_import >= 0 {
    reachable[wasi_write_import] = true
  }
  if wasi_write_import >= 0 {
    for index in debug_runtimes {
      if reachable[index] {
        reachable[wasi_write_import] = true
        break
      }
    }
  }
  if wasi_read >= 0 && reachable[wasi_read] && wasi_read_import >= 0 {
    reachable[wasi_read_import] = true
  }
}

///|
fn wasmgc_variant_has_payload(variant : PlannedVariantLayout) -> Bool {
  match variant.payload {
    PlannedUnitVariantLayout => false
    PlannedTupleVariantLayout(payload) => payload.length > 0
    PlannedStructVariantLayout(fields) => fields.length > 0
  }
}

///|
fn wasmgc_variant_shapes_equal(
  layouts : PlannedModuleTypeLayouts,
  left : VariantId,
  right : VariantId,
) -> Bool {
  let left_variant = layouts.variants[semantic_id_local(left)]
  let right_variant = layouts.variants[semantic_id_local(right)]
  match (left_variant.payload, right_variant.payload) {
    (PlannedUnitVariantLayout, PlannedUnitVariantLayout) => true
    (
      PlannedTupleVariantLayout(left_types),
      PlannedTupleVariantLayout(right_types),
    ) => {
      if left_types.length != right_types.length {
        return false
      }
      for index in 0..<left_types.length {
        if layouts.payload_types[left_types.start + index] !=
          layouts.payload_types[right_types.start + index] {
          return false
        }
      }
      true
    }
    (
      PlannedStructVariantLayout(left_fields),
      PlannedStructVariantLayout(right_fields),
    ) => {
      if left_fields.length != right_fields.length {
        return false
      }
      for index in 0..<left_fields.length {
        let left_field = layouts.fields[left_fields.start + index]
        let right_field = layouts.fields[right_fields.start + index]
        if left_field.type_ != right_field.type_ ||
          left_field.shape != right_field.shape {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
#warnings("-unused_value")
fn wasmgc_physical_type_count_with_options(
  layouts : PlannedModuleTypeLayouts,
  options : WasmGCPlanningOptions,
) -> Int {
  let (sources, _, _) = wasmgc_build_physical_sources(
    layouts,
    options,
    Map::default(),
    false,
    Map::default(),
    Map::default(),
  )
  sources.length()
}

///|
fn wasmgc_physical_type_count_with_instantiations(
  layouts : PlannedModuleTypeLayouts,
  options : WasmGCPlanningOptions,
  generic_enum_instantiations : Map[DeclId, Array[Array[Int]]],
  raw_array_declarations : Map[DeclId, Bool],
) -> Int {
  let (sources, _, _) = wasmgc_build_physical_sources(
    layouts,
    options,
    Map::default(),
    false,
    generic_enum_instantiations,
    raw_array_declarations,
  )
  sources.length()
}

///|
fn wasmgc_variant_uses_same_generic_carriers(
  left : Array[Int],
  right : Array[Int],
) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
fn wasmgc_build_physical_sources(
  layouts : PlannedModuleTypeLayouts,
  options : WasmGCPlanningOptions,
  required_declarations : Map[DeclId, Bool],
  prune_unrequired : Bool,
  generic_enum_instantiations : Map[DeclId, Array[Array[Int]]],
  raw_array_declarations : Map[DeclId, Bool],
) -> (Array[WasmPhysicalTypeSource], Array[Int], Array[Int]) {
  let sources : Array[WasmPhysicalTypeSource] = []
  let entity_by_declaration = Array::make(
    layouts.layout_by_declaration.length(),
    -1,
  )
  let source_by_variant = Array::make(layouts.variants.length(), -1)
  for layout in layouts.layouts {
    if (layout.test_only && !options.emit_tests) ||
      (prune_unrequired && !required_declarations.contains(layout.declaration)) ||
      raw_array_declarations.contains(layout.declaration) {
      continue
    }
    let root = sources.length()
    entity_by_declaration[semantic_id_local(layout.declaration)] = root
    match layout.kind {
      PlannedStructLayout(_) =>
        sources.push({
          kind: PlannedWasmStructType(layout.declaration),
          offset: layout.offset,
          generic_carriers: [],
        })
      PlannedForeignTypeLayout =>
        sources.push({
          kind: PlannedWasmForeignMarkerType(layout.declaration),
          offset: layout.offset,
          generic_carriers: [],
        })
      PlannedEnumLayout(variants) => {
        sources.push({
          kind: PlannedWasmEnumBaseType(layout.declaration),
          offset: layout.offset,
          generic_carriers: [],
        })
        for index in 0..<variants.length {
          let variant = layouts.variants[variants.start + index]
          if options.reuse_unit_subtype_base &&
            !wasmgc_variant_has_payload(variant) {
            source_by_variant[semantic_id_local(variant.variant)] = root
            continue
          }
          let instantiations = match
            generic_enum_instantiations.get(layout.declaration) {
            Some(values) if layout.generic_parameters.length > 0 &&
              values.length() > 0 => values
            _ => [[]]
          }
          for carriers in instantiations {
            let mut duplicate = -1
            for source_index, source in sources {
              match source.kind {
                PlannedWasmEnumSubtypeType(owner, candidate, _) if owner ==
                  layout.declaration &&
                  candidate == variant.variant &&
                  wasmgc_variant_uses_same_generic_carriers(
                    source.generic_carriers,
                    carriers,
                  ) => {
                  duplicate = source_index
                  break
                }
                _ => ()
              }
            }
            if duplicate >= 0 {
              if source_by_variant[semantic_id_local(variant.variant)] < 0 {
                source_by_variant[semantic_id_local(variant.variant)] = duplicate
              }
              continue
            }
            let mut shared = -1
            if layout.generic_parameters.length == 0 &&
              options.enum_shape_sharing == ShareExactEnumShapes {
              for source_index, source in sources {
                match source.kind {
                  PlannedWasmEnumSubtypeType(owner, candidate, _) =>
                    if owner == layout.declaration &&
                      wasmgc_variant_shapes_equal(
                        layouts,
                        candidate,
                        variant.variant,
                      ) {
                      shared = source_index
                      break
                    }
                  _ => ()
                }
              }
            }
            if shared < 0 {
              shared = sources.length()
              sources.push({
                kind: PlannedWasmEnumSubtypeType(
                  layout.declaration,
                  variant.variant,
                  variant.tag,
                ),
                offset: variant.offset,
                generic_carriers: carriers.copy(),
              })
            }
            if source_by_variant[semantic_id_local(variant.variant)] < 0 {
              source_by_variant[semantic_id_local(variant.variant)] = shared
            }
          }
        }
      }
    }
  }
  (sources, entity_by_declaration, source_by_variant)
}

///|
fn wasmgc_nominal_declaration(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> DeclId? {
  let mut current = root
  while true {
    if current < 0 || current >= resolved.types.length() {
      return None
    }
    match resolved.types[current] {
      NominalType(declaration) => return Some(declaration)
      AppliedType(base, _) => current = base
      _ => return None
    }
  }
  None
}

///|
fn wasmgc_record_generic_enum_instantiation(
  output : Map[DeclId, Array[Array[Int]]],
  declaration : DeclId,
  carriers : Array[Int],
) -> Unit {
  let demands = match output.get(declaration) {
    Some(values) => values
    None => {
      let values : Array[Array[Int]] = []
      output[declaration] = values
      values
    }
  }
  for demand in demands {
    if wasmgc_variant_uses_same_generic_carriers(demand, carriers) {
      return
    }
  }
  demands.push(carriers)
}

///|
fn wasmgc_collect_inferred_enum_instantiations(
  resolved : ResolvedModuleTypes,
  inferred : InferredModuleBodies,
  generic_parameter_counts : Map[DeclId, Int],
  output : Map[DeclId, Array[Array[Int]]],
) -> Unit {
  for type_ in inferred.types {
    let (base, arguments) = match type_ {
      BodyAppliedType(base, arguments) => (base, arguments)
      _ => continue
    }
    let declaration = planned_nominal_declaration(resolved, inferred, base)
    let expected = match generic_parameter_counts.get(declaration) {
      Some(value) => value
      None => continue
    }
    guard arguments.start >= 0 &&
      arguments.length == expected &&
      arguments.start <= inferred.type_arguments.length() &&
      arguments.length <= inferred.type_arguments.length() - arguments.start else {
      abort("generic enum inference argument span is invalid")
    }
    let carriers : Array[Int] = []
    for index in 0..<arguments.length {
      let shape = planned_value_shape(
        resolved,
        inferred,
        inferred.type_arguments[arguments.start + index],
      )
      if program_specialization_shape_error(shape) is Some(_) {
        // Unspecialized templates are not concrete layout demands.
        break
      }
      carriers.push(wasmgc_fixed_array_carrier(shape))
    }
    if carriers.length() == expected {
      wasmgc_record_generic_enum_instantiation(output, declaration, carriers)
    }
  }
}

///|
pub fn wasmgc_collect_generic_enum_instantiations_into(
  resolved : ResolvedModuleTypes,
  generic_parameter_counts : Map[DeclId, Int],
  output : Map[DeclId, Array[Array[Int]]],
) -> Unit {
  for type_ in resolved.types {
    let (base, arguments) = match type_ {
      AppliedType(base, arguments) => (base, arguments)
      _ => continue
    }
    let declaration = match wasmgc_nominal_declaration(resolved, base) {
      Some(value) => value
      None => continue
    }
    let expected = match generic_parameter_counts.get(declaration) {
      Some(value) => value
      None => continue
    }
    if arguments.length != expected {
      continue
    }
    let carriers : Array[Int] = []
    for index in 0..<arguments.length {
      carriers.push(
        wasmgc_fixed_array_carrier_for_resolved_type(
          resolved.types,
          resolved.type_arguments[arguments.start + index],
        ),
      )
    }
    wasmgc_record_generic_enum_instantiation(output, declaration, carriers)
  }
}

///|
fn wasmgc_collect_generic_enum_instantiations(
  resolved : ResolvedModuleTypes,
  layouts : PlannedModuleTypeLayouts,
) -> Map[DeclId, Array[Array[Int]]] {
  let counts : Map[DeclId, Int] = Map::default()
  for layout in layouts.layouts {
    match layout.kind {
      PlannedEnumLayout(_) if layout.generic_parameters.length > 0 =>
        counts[layout.declaration] = layout.generic_parameters.length
      _ => ()
    }
  }
  let output : Map[DeclId, Array[Array[Int]]] = Map::default()
  wasmgc_collect_generic_enum_instantiations_into(resolved, counts, output)
  output
}

///|
fn wasmgc_mark_nominal_type(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  required : Map[DeclId, Bool],
) -> Bool {
  let mut changed = false
  let pending : Array[ResolvedTypeId] = [type_]
  while pending.length() > 0 {
    let current = pending.pop().unwrap()
    if current < 0 || current >= resolved.types.length() {
      continue
    }
    match resolved.types[current] {
      NominalType(declaration) =>
        if semantic_id_module(declaration) == resolved.module_id &&
          !required.contains(declaration) {
          required[declaration] = true
          changed = true
        }
      AppliedType(base, arguments) => {
        pending.push(base)
        for index in 0..<arguments.length {
          pending.push(resolved.type_arguments[arguments.start + index])
        }
      }
      _ => ()
    }
  }
  changed
}

///|
fn wasmgc_required_nominal_declarations(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
  functions : PlannedModuleFunctions,
  reachable : Array[Bool],
  program_roots : Map[DeclId, Bool],
  deferred_callables : Map[DeclId, Bool],
) -> Map[DeclId, Bool] {
  let required : Map[DeclId, Bool] = Map::default()
  if program_roots.length() == 0 {
    return required
  }
  let layouts = lowering.type_layouts
  for layout in layouts.layouts {
    if program_roots.contains(layout.declaration) {
      required[layout.declaration] = true
    }
  }
  for callable_index, callable in functions.callables {
    if !reachable[callable_index] ||
      deferred_callables.contains(callable.declaration) {
      continue
    }
    for index in 0..<callable.parameters.length {
      let parameter = functions.parameters[callable.parameters.start + index]
      if parameter.shape is RefPlannedValueShape {
        wasmgc_mark_nominal_type(resolved, parameter.type_, required) |> ignore
      }
    }
    if callable.result_shape is RefPlannedValueShape {
      wasmgc_mark_nominal_type(resolved, callable.result_type, required)
      |> ignore
    }
    if callable.has_receiver {
      wasmgc_mark_nominal_type(resolved, callable.self_type, required) |> ignore
    }
    let body_id = match callable.kind {
      PlannedFunctionCallable(body)
      | PlannedImplMethodCallable(_, Some(body)) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match lowering.expressions[expression].kind {
        PlannedStructNew(declaration, _, _) => required[declaration] = true
        PlannedUnitVariant(variant, _)
        | PlannedVariantTupleNew(variant, _, _)
        | PlannedVariantStructNew(variant, _, _) => {
          if lowering.expressions[expression].shape is I32PlannedValueShape ||
            lowering.expressions[expression].shape is I64PlannedValueShape {
            continue
          }
          for candidate in layouts.variants {
            if candidate.variant == variant {
              required[candidate.declaration] = true
              break
            }
          }
        }
        PlannedFieldGet(field, _, _) | PlannedFieldSet(field, _, _) =>
          for candidate in layouts.fields {
            if candidate.field == field {
              required[candidate.declaration] = true
              break
            }
          }
        PlannedArrayLiteral(_, _, _) =>
          required[standard_array_type_declaration()] = true
        _ => ()
      }
    }
    for
      pattern in body.patterns.start..<(body.patterns.start +
      body.patterns.length) {
      if lowering.patterns[pattern].elided {
        continue
      }
      match lowering.patterns[pattern].selected_constructor {
        StructInferredPatternConstructor(declaration, _) =>
          required[declaration] = true
        VariantInferredPatternConstructor(variant, _) => {
          if lowering.patterns[pattern].shape is I32PlannedValueShape ||
            lowering.patterns[pattern].shape is I64PlannedValueShape {
            continue
          }
          for candidate in layouts.variants {
            if candidate.variant == variant {
              required[candidate.declaration] = true
              break
            }
          }
        }
        _ => ()
      }
    }
  }
  let mut changed = true
  while changed {
    changed = false
    for layout in layouts.layouts {
      if !required.contains(layout.declaration) {
        continue
      }
      for field in layouts.fields {
        if field.declaration == layout.declaration &&
          wasmgc_mark_nominal_type(resolved, field.type_, required) {
          changed = true
        }
      }
      match layout.kind {
        PlannedEnumLayout(variants) =>
          for index in 0..<variants.length {
            let variant = layouts.variants[variants.start + index]
            match variant.payload {
              PlannedTupleVariantLayout(types) =>
                for type_index in 0..<types.length {
                  if wasmgc_mark_nominal_type(
                      resolved,
                      layouts.payload_types[types.start + type_index],
                      required,
                    ) {
                    changed = true
                  }
                }
              _ => ()
            }
          }
        PlannedStructLayout(_) | PlannedForeignTypeLayout => ()
      }
    }
  }
  required
}

///|
fn wasmgc_storage_type(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  type_index_by_declaration : Array[Int],
  current_group : Int,
  group_index_by_type : Array[Int],
  group_first_type_indices : Array[Int],
) -> PlannedWasmStorageType? {
  let mut current = root
  while true {
    match resolved.types[current] {
      ErrorType => return Some(WasmNullableEqRefStorage)
      MemberTypeProjection(_, _, _) =>
        abort("SPC-301 unresolved member projection reached physical storage")
      PrimitiveType(UnitType | NeverType | CompileTimeTypeType) => return None
      PrimitiveType(I8Type) => return Some(WasmI8SignedStorage)
      PrimitiveType(U8Type) => return Some(WasmI8UnsignedStorage)
      PrimitiveType(I16Type) => return Some(WasmI16SignedStorage)
      PrimitiveType(U16Type) => return Some(WasmI16UnsignedStorage)
      PrimitiveType(
        BoolType
        | I32Type
        | U32Type
        | Swar32Type
        | I8x4Type
        | U8x4Type
        | I16x2Type
        | U16x2Type
      ) => return Some(WasmI32Storage)
      PrimitiveType(
        I64Type
        | U64Type
        | Swar64Type
        | I8x8Type
        | U8x8Type
        | I16x4Type
        | U16x4Type
        | I32x2Type
        | U32x2Type
      ) => return Some(WasmI64Storage)
      PrimitiveType(F32Type) => return Some(WasmF32Storage)
      PrimitiveType(F64Type) => return Some(WasmF64Storage)
      PrimitiveType(
        V128Type
        | I8x16Type
        | U8x16Type
        | I16x8Type
        | U16x8Type
        | I32x4Type
        | U32x4Type
        | I64x2Type
        | U64x2Type
        | F32x4Type
        | F64x2Type
      ) => return Some(WasmV128Storage)
      PrimitiveType(
        StringType
        | BytesType
        | StringViewType
        | StringBuilderType
        | BytesBuilderType
      ) => return Some(WasmStringRefStorage)
      GenericParameterType(_)
      | TraitType(_)
      | SelfType(_)
      | ProductType(_)
      | FunctionType(_, _) => return Some(WasmNullableEqRefStorage)
      NominalType(declaration) => {
        if resolved.raw_array_declarations.contains(declaration) {
          return Some(WasmNullableEqRefStorage)
        }
        if semantic_id_module(declaration) != resolved.module_id {
          return Some(WasmExternalNominalRefStorage(declaration))
        }
        let local_index = semantic_id_local(declaration)
        if local_index >= 0 && local_index < type_index_by_declaration.length() {
          let index = type_index_by_declaration[local_index]
          if index >= 0 {
            let reference = if group_index_by_type[index] == current_group {
              WasmRecursiveTypeReference(
                index - group_first_type_indices[current_group],
              )
            } else {
              WasmModuleTypeReference(index)
            }
            return Some(WasmNominalRefStorage(reference))
          }
        }
        return Some(WasmNullableEqRefStorage)
      }
      AppliedType(base, arguments) =>
        match resolved.types[base] {
          NominalType(declaration) if declaration ==
            standard_nullable_ref_type_declaration() &&
            arguments.length == 1 => {
            let argument = resolved.type_arguments[arguments.start]
            match resolved.types[argument] {
              NominalType(foreign_declaration) => {
                if semantic_id_module(foreign_declaration) != resolved.module_id {
                  return Some(
                    WasmNullableExternalNominalRefStorage(foreign_declaration),
                  )
                }
                let local_index = semantic_id_local(foreign_declaration)
                if local_index >= 0 &&
                  local_index < type_index_by_declaration.length() {
                  let index = type_index_by_declaration[local_index]
                  if index >= 0 {
                    let reference = if group_index_by_type[index] ==
                      current_group {
                      WasmRecursiveTypeReference(
                        index - group_first_type_indices[current_group],
                      )
                    } else {
                      WasmModuleTypeReference(index)
                    }
                    return Some(WasmNullableNominalRefStorage(reference))
                  }
                }
                return Some(WasmNullableEqRefStorage)
              }
              _ => return Some(WasmNullableEqRefStorage)
            }
          }
          NominalType(declaration) if resolved.raw_array_declarations.contains(
              declaration,
            ) &&
            arguments.length == 1 => {
            let element = resolved.type_arguments[arguments.start]
            if resolved.types[element] is GenericParameterType(_) {
              // A shared generic field can hold any Wasm array heap type.
              // Its declared type parameter is an erasure contract, not
              // evidence that the backing array contains reference elements.
              return Some(WasmNullableEqRefStorage)
            }
            let carrier = wasmgc_raw_array_storage_carrier(
              planned_resolved_value_shape(resolved, element),
            )
            if carrier >= 0 {
              return Some(WasmFixedArrayRefStorage(carrier))
            }
            return Some(WasmNullableEqRefStorage)
          }
          _ => current = base
        }
    }
  }
  Some(WasmNullableEqRefStorage)
}

///|
fn wasmgc_add_type_dependency(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  entity_by_declaration : Array[Int],
  marks : Array[Int],
  generation : Int,
  dependencies : Array[Int],
) -> Unit {
  match wasmgc_nominal_declaration(resolved, type_) {
    Some(declaration) => {
      if semantic_id_module(declaration) != resolved.module_id {
        return
      }
      let local_index = semantic_id_local(declaration)
      if local_index >= 0 && local_index < entity_by_declaration.length() {
        let dependency = entity_by_declaration[local_index]
        if dependency >= 0 && marks[dependency] != generation {
          marks[dependency] = generation
          dependencies.push(dependency)
        }
      }
    }
    None => ()
  }
}

///|
fn wasmgc_plan_physical_type_job(
  resolved : ResolvedModuleTypes,
  layouts : PlannedModuleTypeLayouts,
  source : WasmPhysicalTypeSource,
  entity_by_declaration : Array[Int],
  marks : Array[Int],
  generation : Int,
) -> WasmPhysicalTypeJob {
  let dependencies : Array[Int] = []
  match source.kind {
    PlannedWasmStructType(declaration) =>
      match layouts.layout_of(declaration).unwrap().kind {
        PlannedStructLayout(fields) =>
          for index in 0..<fields.length {
            wasmgc_add_type_dependency(
              resolved,
              layouts.fields[fields.start + index].type_,
              entity_by_declaration,
              marks,
              generation,
              dependencies,
            )
          }
        _ => abort("struct physical source has a non-struct layout")
      }
    PlannedWasmForeignMarkerType(_) | PlannedWasmEnumBaseType(_) => ()
    PlannedWasmClosureType
    | PlannedWasmCaptureCellType(_)
    | PlannedWasmLambdaClosureType(_)
    | PlannedWasmTraitMethodSignatureType(_)
    | PlannedWasmTraitVTableType(_)
    | PlannedWasmTraitObjectType(_) =>
      abort("synthetic runtime type entered nominal dependency planning")
    PlannedWasmEnumSubtypeType(declaration, variant, _) => {
      let dependency = entity_by_declaration[semantic_id_local(declaration)]
      if dependency >= 0 && marks[dependency] != generation {
        marks[dependency] = generation
        dependencies.push(dependency)
      }
      let payload = layouts.variants[semantic_id_local(variant)].payload
      match payload {
        PlannedUnitVariantLayout => ()
        PlannedTupleVariantLayout(types) =>
          for index in 0..<types.length {
            wasmgc_add_type_dependency(
              resolved,
              layouts.payload_types[types.start + index],
              entity_by_declaration,
              marks,
              generation,
              dependencies,
            )
          }
        PlannedStructVariantLayout(fields) =>
          for index in 0..<fields.length {
            wasmgc_add_type_dependency(
              resolved,
              layouts.fields[fields.start + index].type_,
              entity_by_declaration,
              marks,
              generation,
              dependencies,
            )
          }
      }
    }
  }
  dependencies.sort()
  { dependencies, }
}

///|
fn wasmgc_type_sccs(
  jobs : Array[WasmPhysicalTypeJob],
) -> (Array[HirSpan], Array[Int]) {
  let count = jobs.length()
  if count == 0 {
    return ([], [])
  }
  let visited = Array::make(count, false)
  let work : Array[Int] = []
  let finish_order : Array[Int] = []
  for start in 0..<count {
    if visited[start] {
      continue
    }
    work.push(start)
    while work.length() > 0 {
      let item = work.pop().unwrap()
      if item < 0 {
        finish_order.push(-item - 1)
        continue
      }
      if visited[item] {
        continue
      }
      visited[item] = true
      work.push(-item - 1)
      let edges = jobs[item].dependencies
      let mut edge = edges.length()
      while edge > 0 {
        edge -= 1
        let dependency = edges[edge]
        if !visited[dependency] {
          work.push(dependency)
        }
      }
    }
  }
  let reverse_counts = Array::make(count, 0)
  for source in 0..<count {
    for dependency in jobs[source].dependencies {
      reverse_counts[dependency] += 1
    }
  }
  let reverse_offsets = Array::make(count + 1, 0)
  for index in 0..<count {
    reverse_offsets[index + 1] = reverse_offsets[index] + reverse_counts[index]
  }
  let reverse_cursor = Array::make(count, 0)
  for index in 0..<count {
    reverse_cursor[index] = reverse_offsets[index]
  }
  let reverse_edges = Array::make(reverse_offsets[count], 0)
  for source in 0..<count {
    for dependency in jobs[source].dependencies {
      let destination = reverse_cursor[dependency]
      reverse_edges[destination] = source
      reverse_cursor[dependency] += 1
    }
  }
  let finish_rank = Array::make(count, 0)
  for rank, entity in finish_order {
    finish_rank[entity] = rank
  }
  let assigned = Array::make(count, false)
  let component : Array[Int] = []
  let raw_spans : Array[HirSpan] = []
  let raw_members : Array[Int] = []
  let raw_ranks : Array[Int] = []
  let mut order_index = finish_order.length()
  while order_index > 0 {
    order_index -= 1
    let start = finish_order[order_index]
    if assigned[start] {
      continue
    }
    component.clear()
    work.clear()
    work.push(start)
    assigned[start] = true
    let mut rank = finish_rank[start]
    while work.length() > 0 {
      let entity = work.pop().unwrap()
      component.push(entity)
      if finish_rank[entity] < rank {
        rank = finish_rank[entity]
      }
      for edge in reverse_offsets[entity]..<reverse_offsets[entity + 1] {
        let dependent = reverse_edges[edge]
        if !assigned[dependent] {
          assigned[dependent] = true
          work.push(dependent)
        }
      }
    }
    component.sort()
    let start = raw_members.length()
    for entity in component {
      raw_members.push(entity)
    }
    raw_spans.push({ start, length: raw_members.length() - start, })
    raw_ranks.push(rank)
  }
  let order : Array[Int] = []
  for index in 0..<raw_spans.length() {
    order.push(index)
  }
  order.sort_by(fn(left, right) {
    let rank = raw_ranks[left] - raw_ranks[right]
    if rank != 0 {
      rank
    } else {
      raw_members[raw_spans[left].start] - raw_members[raw_spans[right].start]
    }
  })
  let spans : Array[HirSpan] = []
  let members : Array[Int] = []
  for component_index in order {
    let source = raw_spans[component_index]
    let start = members.length()
    for index in 0..<source.length {
      members.push(raw_members[source.start + index])
    }
    spans.push({ start, length: members.length() - start, })
  }
  (spans, members)
}

///|
fn wasmgc_append_field(
  fields : Array[PlannedWasmField],
  role : PlannedWasmFieldRole,
  storage : PlannedWasmStorageType,
  offset : UInt64,
) -> Unit {
  fields.push({
    role,
    physical_index: fields.length(),
    storage,
    mutable_: false,
    offset,
  })
}

///|
fn wasmgc_append_mutable_field(
  fields : Array[PlannedWasmField],
  role : PlannedWasmFieldRole,
  storage : PlannedWasmStorageType,
  offset : UInt64,
) -> Unit {
  fields.push({
    role,
    physical_index: fields.length(),
    storage,
    mutable_: true,
    offset,
  })
}

///|
fn wasmgc_is_erased_generic_storage(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
) -> Bool {
  match resolved.types[type_] {
    GenericParameterType(_) | SelfType(_) => true
    _ => false
  }
}

///|
fn wasmgc_append_field_with_mutability(
  fields : Array[PlannedWasmField],
  role : PlannedWasmFieldRole,
  storage : PlannedWasmStorageType,
  mutable_ : Bool,
  offset : UInt64,
) -> Unit {
  if mutable_ {
    wasmgc_append_mutable_field(fields, role, storage, offset)
  } else {
    wasmgc_append_field(fields, role, storage, offset)
  }
}

///|
fn wasmgc_append_erased_generic_fields(
  fields : Array[PlannedWasmField],
  role : PlannedWasmFieldRole,
  mutable_ : Bool,
  offset : UInt64,
) -> Unit {
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmI32Storage,
    mutable_,
    offset,
  )
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmI64Storage,
    mutable_,
    offset,
  )
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmF32Storage,
    mutable_,
    offset,
  )
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmF64Storage,
    mutable_,
    offset,
  )
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmV128Storage,
    mutable_,
    offset,
  )
  wasmgc_append_field_with_mutability(
    fields,
    role,
    WasmNullableEqRefStorage,
    mutable_,
    offset,
  )
}

///|
fn wasmgc_append_specialized_generic_field(
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  generic_parameters : HirSpan,
  carriers : Array[Int],
  fields : Array[PlannedWasmField],
  role : PlannedWasmFieldRole,
  mutable_ : Bool,
  offset : UInt64,
) -> Unit {
  if carriers.length() == 0 {
    wasmgc_append_erased_generic_fields(fields, role, mutable_, offset)
    return
  }
  let carrier = match resolved.types[type_] {
    GenericParameterType(parameter) => {
      let relative = semantic_id_local(parameter) - generic_parameters.start
      if relative < 0 || relative >= carriers.length() {
        5
      } else {
        carriers[relative]
      }
    }
    _ => 5
  }
  if carrier < 0 {
    return
  }
  wasmgc_append_field_with_mutability(
    fields,
    role,
    wasmgc_capture_cell_storage(carrier),
    mutable_,
    offset,
  )
}

///|
fn wasmgc_append_physical_type_fields(
  resolved : ResolvedModuleTypes,
  layouts : PlannedModuleTypeLayouts,
  source : WasmPhysicalTypeSource,
  type_index_by_declaration : Array[Int],
  current_group : Int,
  group_index_by_type : Array[Int],
  group_first_type_indices : Array[Int],
  target : Array[PlannedWasmField],
) -> HirSpan {
  let start = target.length()
  match source.kind {
    PlannedWasmStructType(declaration) =>
      match layouts.layout_of(declaration).unwrap().kind {
        PlannedStructLayout(fields) =>
          for index in 0..<fields.length {
            let field = layouts.fields[fields.start + index]
            if wasmgc_is_erased_generic_storage(resolved, field.type_) {
              wasmgc_append_erased_generic_fields(
                target,
                WasmStructField(field.field),
                field.mutable_,
                field.offset,
              )
            } else {
              match
                wasmgc_storage_type(
                  resolved,
                  field.type_,
                  type_index_by_declaration,
                  current_group,
                  group_index_by_type,
                  group_first_type_indices,
                ) {
                Some(storage) =>
                  wasmgc_append_field_with_mutability(
                    target,
                    WasmStructField(field.field),
                    storage,
                    field.mutable_,
                    field.offset,
                  )
                None => ()
              }
            }
          }
        _ => abort("struct physical source has a non-struct layout")
      }
    PlannedWasmForeignMarkerType(_) => ()
    PlannedWasmEnumBaseType(_) =>
      wasmgc_append_field(
        target,
        WasmEnumTagField,
        WasmI32Storage,
        source.offset,
      )
    PlannedWasmClosureType
    | PlannedWasmCaptureCellType(_)
    | PlannedWasmLambdaClosureType(_)
    | PlannedWasmTraitMethodSignatureType(_)
    | PlannedWasmTraitVTableType(_)
    | PlannedWasmTraitObjectType(_) =>
      abort("synthetic runtime type entered nominal field planning")
    PlannedWasmEnumSubtypeType(_, variant, _) => {
      wasmgc_append_field(
        target,
        WasmEnumTagField,
        WasmI32Storage,
        source.offset,
      )
      let source_variant = layouts.variants[semantic_id_local(variant)]
      let source_layout = layouts.layout_of(source_variant.declaration).unwrap()
      match source_variant.payload {
        PlannedUnitVariantLayout => ()
        PlannedTupleVariantLayout(types) =>
          for index in 0..<types.length {
            let payload_type = layouts.payload_types[types.start + index]
            let role = WasmTuplePayloadField(variant, index)
            if wasmgc_is_erased_generic_storage(resolved, payload_type) {
              wasmgc_append_specialized_generic_field(
                resolved,
                payload_type,
                source_layout.generic_parameters,
                source.generic_carriers,
                target,
                role,
                false,
                source_variant.offset,
              )
            } else {
              match
                wasmgc_storage_type(
                  resolved, payload_type, type_index_by_declaration, current_group,
                  group_index_by_type, group_first_type_indices,
                ) {
                Some(storage) =>
                  wasmgc_append_field(
                    target,
                    role,
                    storage,
                    source_variant.offset,
                  )
                None => ()
              }
            }
          }
        PlannedStructVariantLayout(fields) =>
          for index in 0..<fields.length {
            let field = layouts.fields[fields.start + index]
            let role = WasmStructPayloadField(field.field)
            if wasmgc_is_erased_generic_storage(resolved, field.type_) {
              wasmgc_append_specialized_generic_field(
                resolved,
                field.type_,
                source_layout.generic_parameters,
                source.generic_carriers,
                target,
                role,
                false,
                field.offset,
              )
            } else {
              match
                wasmgc_storage_type(
                  resolved,
                  field.type_,
                  type_index_by_declaration,
                  current_group,
                  group_index_by_type,
                  group_first_type_indices,
                ) {
                Some(storage) =>
                  wasmgc_append_field(target, role, storage, field.offset)
                None => ()
              }
            }
          }
      }
    }
  }
  let length = target.length() - start
  for index in 0..<length {
    let field = target[start + index]
    target[start + index] = { ..field, physical_index: index, }
  }
  { start, length, }
}

///|
fn wasmgc_capture_value_type(
  storage : PlannedWasmStorageType,
) -> PlannedWasmValueType {
  match storage {
    WasmI8SignedStorage
    | WasmI8UnsignedStorage
    | WasmI16SignedStorage
    | WasmI16UnsignedStorage
    | WasmI32Storage => WasmI32Value
    WasmI64Storage => WasmI64Value
    WasmF32Storage => WasmF32Value
    WasmF64Storage => WasmF64Value
    WasmV128Storage => WasmV128Value
    WasmStringRefStorage
    | WasmNullableEqRefStorage
    | WasmNullableFunctionRefStorage
    | WasmFunctionRefStorage(_)
    | WasmNominalRefStorage(_)
    | WasmExternalNominalRefStorage(_)
    | WasmNullableNominalRefStorage(_)
    | WasmNullableExternalNominalRefStorage(_) => WasmNullableEqRefValue
    WasmFixedArrayRefStorage(carrier) => WasmFixedArrayRefValue(carrier)
  }
}

///|
pub fn wasmgc_capture_cell_slot(shape : PlannedValueShape) -> Int {
  match shape {
    UnitPlannedValueShape | NeverPlannedValueShape => -1
    I8PlannedValueShape
    | U8PlannedValueShape
    | I16PlannedValueShape
    | U16PlannedValueShape
    | I32PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => 0
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape => 1
    F32PlannedValueShape => 2
    F64PlannedValueShape => 3
    V128PlannedValueShape => 4
    RefPlannedValueShape
    | GenericPlannedValueShape
    | ProductPlannedValueShape(_)
    | ErrorPlannedValueShape => 5
  }
}

///|
pub fn wasmgc_capture_cell_storage(slot : Int) -> PlannedWasmStorageType {
  match slot {
    0 => WasmI32Storage
    1 => WasmI64Storage
    2 => WasmF32Storage
    3 => WasmF64Storage
    4 => WasmV128Storage
    _ => WasmNullableEqRefStorage
  }
}

///|
fn wasmgc_capture_storage(
  shape : PlannedValueShape,
  mutable_ : Bool,
) -> PlannedWasmStorageType? {
  if mutable_ && wasmgc_capture_cell_slot(shape) >= 0 {
    return Some(WasmNullableEqRefStorage)
  }
  match shape {
    UnitPlannedValueShape | NeverPlannedValueShape => None
    I8PlannedValueShape => Some(WasmI8SignedStorage)
    U8PlannedValueShape => Some(WasmI8UnsignedStorage)
    I16PlannedValueShape => Some(WasmI16SignedStorage)
    U16PlannedValueShape => Some(WasmI16UnsignedStorage)
    I32PlannedValueShape | U32PlannedValueShape | Swar32PlannedValueShape =>
      Some(WasmI32Storage)
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      Some(WasmI64Storage)
    F32PlannedValueShape => Some(WasmF32Storage)
    F64PlannedValueShape => Some(WasmF64Storage)
    V128PlannedValueShape => Some(WasmV128Storage)
    RefPlannedValueShape
    | GenericPlannedValueShape
    | ProductPlannedValueShape(_)
    | ErrorPlannedValueShape => Some(WasmNullableEqRefStorage)
  }
}

///|

///|
pub fn wasmgc_fixed_array_carrier_for_resolved_type(
  types : Array[ResolvedType],
  root : ResolvedTypeId,
) -> Int {
  if root < 0 || root >= types.length() {
    return 5
  }
  match types[root] {
    PrimitiveType(CompileTimeTypeType) => -1
    MemberTypeProjection(_, _, _) => -1
    PrimitiveType(I8Type | U8Type) => 6
    PrimitiveType(I16Type | U16Type) => 7
    PrimitiveType(
      BoolType
      | I32Type
      | U32Type
      | Swar32Type
      | I8x4Type
      | U8x4Type
      | I16x2Type
      | U16x2Type
    ) => 0
    PrimitiveType(
      I64Type
      | U64Type
      | Swar64Type
      | I8x8Type
      | U8x8Type
      | I16x4Type
      | U16x4Type
      | I32x2Type
      | U32x2Type
    ) => 1
    PrimitiveType(F32Type) => 2
    PrimitiveType(F64Type) => 3
    PrimitiveType(
      V128Type
      | I8x16Type
      | U8x16Type
      | I16x8Type
      | U16x8Type
      | I32x4Type
      | U32x4Type
      | I64x2Type
      | U64x2Type
      | F32x4Type
      | F64x2Type
    ) => 4
    ProductType(_)
    | AppliedType(_, _)
    | NominalType(_)
    | FunctionType(_, _)
    | TraitType(_) => 5
    GenericParameterType(_) | SelfType(_) | ErrorType => 5
    PrimitiveType(UnitType | NeverType) => -1
    PrimitiveType(
      StringType
      | BytesType
      | StringViewType
      | StringBuilderType
      | BytesBuilderType
    ) => 5
  }
}

///|
pub fn wasmgc_fixed_array_carrier(shape : PlannedValueShape) -> Int {
  match shape {
    I8PlannedValueShape | U8PlannedValueShape => 6
    I16PlannedValueShape | U16PlannedValueShape => 7
    I32PlannedValueShape | U32PlannedValueShape | Swar32PlannedValueShape => 0
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape => 1
    F32PlannedValueShape => 2
    F64PlannedValueShape => 3
    V128PlannedValueShape => 4
    RefPlannedValueShape
    | GenericPlannedValueShape
    | ProductPlannedValueShape(_)
    | ErrorPlannedValueShape => 5
    UnitPlannedValueShape | NeverPlannedValueShape => -1
  }
}

///|
// Raw array storage is distinct from expression and enum payload carriers.
// Unit occupies a null marker cell; unknown evidence never selects that cell.
pub fn wasmgc_raw_array_storage_carrier(shape : PlannedValueShape) -> Int {
  if shape is ProductPlannedValueShape(_) {
    let work = [shape]
    while work.length() > 0 {
      match work.pop().unwrap() {
        GenericPlannedValueShape
        | ErrorPlannedValueShape
        | NeverPlannedValueShape => return -1
        ProductPlannedValueShape(fields) =>
          for field in fields {
            work.push(field)
          }
        _ => ()
      }
    }
  }
  match shape {
    UnitPlannedValueShape => 5
    GenericPlannedValueShape
    | ErrorPlannedValueShape
    | NeverPlannedValueShape => -1
    _ => wasmgc_fixed_array_carrier(shape)
  }
}

///|
fn wasmgc_value_type(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
  self_type : ResolvedTypeId,
  type_index_by_declaration : Array[Int],
  function_type_by_resolved : Array[Int],
  closure_abi : Bool,
) -> PlannedWasmValueType? {
  let mut current = root
  while true {
    match resolved.types[current] {
      ErrorType => return Some(WasmNullableEqRefValue)
      PrimitiveType(UnitType | NeverType | CompileTimeTypeType) => return None
      PrimitiveType(
        BoolType
        | I8Type
        | I16Type
        | I32Type
        | U8Type
        | U16Type
        | U32Type
        | Swar32Type
        | I8x4Type
        | U8x4Type
        | I16x2Type
        | U16x2Type
      ) => return Some(WasmI32Value)
      PrimitiveType(
        I64Type
        | U64Type
        | Swar64Type
        | I8x8Type
        | U8x8Type
        | I16x4Type
        | U16x4Type
        | I32x2Type
        | U32x2Type
      ) => return Some(WasmI64Value)
      PrimitiveType(F32Type) => return Some(WasmF32Value)
      PrimitiveType(F64Type) => return Some(WasmF64Value)
      PrimitiveType(
        V128Type
        | I8x16Type
        | U8x16Type
        | I16x8Type
        | U16x8Type
        | I32x4Type
        | U32x4Type
        | I64x2Type
        | U64x2Type
        | F32x4Type
        | F64x2Type
      ) => return Some(WasmV128Value)
      PrimitiveType(
        StringType
        | BytesType
        | StringViewType
        | StringBuilderType
        | BytesBuilderType
      ) => return Some(WasmStringRefValue)
      FunctionType(_, _) => {
        if closure_abi {
          return Some(WasmNullableEqRefValue)
        }
        let index = function_type_by_resolved[current]
        if index >= 0 {
          return Some(WasmFunctionRefValue(index))
        }
        return Some(WasmNullableEqRefValue)
      }
      MemberTypeProjection(_, _, _) =>
        abort(
          "SPC-301 unresolved member projection reached a physical signature",
        )
      GenericParameterType(_) | TraitType(_) | ProductType(_) =>
        return Some(WasmNullableEqRefValue)
      SelfType(_) =>
        if self_type >= 0 {
          current = self_type
        } else {
          return Some(WasmNullableEqRefValue)
        }
      NominalType(declaration) => {
        if resolved.raw_array_declarations.contains(declaration) ||
          declaration == standard_array_entry_type_declaration() {
          return Some(WasmNullableEqRefValue)
        }
        if semantic_id_module(declaration) != resolved.module_id {
          return Some(WasmExternalNominalRefValue(declaration))
        }
        let local_index = semantic_id_local(declaration)
        if local_index >= 0 && local_index < type_index_by_declaration.length() {
          let index = type_index_by_declaration[local_index]
          if index >= 0 {
            return Some(WasmNominalRefValue(index))
          }
        }
        return Some(WasmNullableEqRefValue)
      }
      AppliedType(base, arguments) =>
        match resolved.types[base] {
          NominalType(declaration) if declaration ==
            standard_nullable_ref_type_declaration() &&
            arguments.length == 1 => {
            let argument = resolved.type_arguments[arguments.start]
            match resolved.types[argument] {
              NominalType(foreign_declaration) => {
                if semantic_id_module(foreign_declaration) != resolved.module_id {
                  return Some(
                    WasmNullableExternalNominalRefValue(foreign_declaration),
                  )
                }
                let local_index = semantic_id_local(foreign_declaration)
                if local_index >= 0 &&
                  local_index < type_index_by_declaration.length() {
                  let index = type_index_by_declaration[local_index]
                  if index >= 0 {
                    return Some(WasmNullableNominalRefValue(index))
                  }
                }
                return Some(WasmNullableEqRefValue)
              }
              _ => return Some(WasmNullableEqRefValue)
            }
          }
          NominalType(declaration) if resolved.raw_array_declarations.contains(
              declaration,
            ) &&
            arguments.length == 1 => {
            let carrier = wasmgc_raw_array_storage_carrier(
              planned_resolved_value_shape(
                resolved,
                resolved.type_arguments[arguments.start],
              ),
            )
            if carrier >= 0 {
              return Some(WasmFixedArrayRefValue(carrier))
            }
            return Some(WasmNullableEqRefValue)
          }
          _ => current = base
        }
    }
  }
  Some(WasmNullableEqRefValue)
}

///|
fn wasmgc_builtin_is_debug_runtime(name : Bytes) -> Bool {
  name == b"dew_debug_i8" ||
  name == b"dew_debug_i16" ||
  name == b"dew_debug_i32" ||
  name == b"dew_debug_i64" ||
  name == b"dew_debug_u8" ||
  name == b"dew_debug_u16" ||
  name == b"dew_debug_u32" ||
  name == b"dew_debug_u64" ||
  name == b"dew_debug_f32" ||
  name == b"dew_debug_f64" ||
  name == b"dew_debug_string" ||
  name == b"dew_debug_bytes" ||
  name == b"dew_debug_v128"
}

///|
fn wasmgc_builtin_uses_linear_memory(name : Bytes) -> Bool {
  wasmgc_builtin_is_debug_runtime(name) ||
  raw_wasm_simd_uses_memory(name) ||
  name == b"dew_bytes_load_u8x16" ||
  name == b"dew_string_load_u8x16" ||
  name == b"i32.load8_s" ||
  name == b"i32.load8_u" ||
  name == b"i32.store8" ||
  name == b"i32.load16_s" ||
  name == b"i32.load16_u" ||
  name == b"i32.store16" ||
  name == b"i32.load" ||
  name == b"i32.store" ||
  name == b"i64.load" ||
  name == b"i64.store" ||
  name == b"f32.load" ||
  name == b"f32.store" ||
  name == b"f64.load" ||
  name == b"f64.store" ||
  name == b"v128.load" ||
  name == b"v128.store" ||
  name == b"dew_wasi_fd_write" ||
  name == b"dew_wasi_fd_read" ||
  name == b"dew_test_assert" ||
  name == b"dew_bench_wasi_stage_write" ||
  name == b"dew_bench_wasi_stage_read"
}

///|
fn wasmgc_builtin_is_runtime(name : Bytes) -> Bool {
  wasmgc_builtin_is_debug_runtime(name) ||
  name == b"dew_string_byte_length" ||
  name == b"dew_string_as_bytes" ||
  name == b"dew_string_utf16_length" ||
  name == b"dew_string_equals" ||
  name == b"dew_string_hash" ||
  name == b"dew_string_byte_at" ||
  name == b"dew_string_view" ||
  name == b"dew_string_concat" ||
  name == b"dew_string_concat_view" ||
  name == b"dew_string_find" ||
  name == b"dew_string_find_view" ||
  name == b"dew_string_starts_with" ||
  name == b"dew_string_starts_with_view" ||
  name == b"dew_string_ends_with" ||
  name == b"dew_string_ends_with_view" ||
  name == b"dew_string_view_byte_length" ||
  name == b"dew_string_view_byte_at" ||
  name == b"dew_string_view_to_string" ||
  name == b"dew_string_view_as_bytes" ||
  name == b"dew_string_view_utf16_length" ||
  name == b"dew_string_view_equals" ||
  name == b"dew_string_view_hash" ||
  name == b"dew_string_view_view" ||
  name == b"dew_string_view_find" ||
  name == b"dew_string_view_find_string" ||
  name == b"dew_string_view_starts_with" ||
  name == b"dew_string_view_starts_with_string" ||
  name == b"dew_string_view_ends_with" ||
  name == b"dew_string_view_ends_with_string" ||
  name == b"dew_string_builder_new" ||
  name == b"dew_string_builder_with_capacity" ||
  name == b"dew_string_builder_byte_length" ||
  name == b"dew_string_builder_append" ||
  name == b"dew_string_builder_append_view" ||
  name == b"dew_string_builder_append_ascii" ||
  name == b"dew_string_builder_append_scalar" ||
  name == b"dew_string_builder_finish" ||
  name == b"dew_bytes_builder_new" ||
  name == b"dew_bytes_builder_with_capacity" ||
  name == b"dew_bytes_builder_byte_length" ||
  name == b"dew_bytes_builder_append" ||
  name == b"dew_bytes_builder_append_byte" ||
  name == b"dew_bytes_builder_finish" ||
  name == b"dew_bytes_byte_length" ||
  name == b"dew_bytes_is_valid_utf8" ||
  name == b"dew_bytes_to_string" ||
  name == b"dew_bytes_to_string_unchecked" ||
  name == b"dew_bytes_equals" ||
  name == b"dew_bytes_hash" ||
  name == b"dew_bytes_byte_at" ||
  name == b"dew_bytes_view" ||
  name == b"dew_bytes_concat" ||
  name == b"dew_bytes_find_byte" ||
  name == b"dew_bytes_find" ||
  name == b"dew_bytes_starts_with" ||
  name == b"dew_bytes_ends_with" ||
  name == b"dew_bytes_load_u8x16" ||
  name == b"dew_string_load_u8x16" ||
  name == b"dew_wasi_fd_write" ||
  name == b"dew_wasi_fd_read" ||
  name == b"dew_test_assert" ||
  name == b"dew_bench_wasi_stage_write" ||
  name == b"dew_bench_wasi_stage_read"
}

///|
fn wasmgc_builtin_is_inline(name : Bytes) -> Bool {
  raw_wasm_builtin_is_inline(name) ||
  name == b"unsafe.bitcast" ||
  (
    name.length() >= 4 &&
    name[0] == b'd' &&
    name[1] == b'e' &&
    name[2] == b'w' &&
    name[3] == b'_'
  )
}

///|
fn wasmgc_callable_has_scalarized_signature(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
) -> Bool {
  for index in 0..<callable.parameters.length {
    let parameter = functions.parameters[callable.parameters.start + index]
    if (
        parameter.shape is I32PlannedValueShape ||
        parameter.shape is I64PlannedValueShape
      ) &&
      planned_resolved_value_shape(resolved, parameter.type_)
      is RefPlannedValueShape {
      return true
    }
  }
  (
    callable.result_shape is I32PlannedValueShape ||
    callable.result_shape is I64PlannedValueShape
  ) &&
  planned_resolved_value_shape(resolved, callable.result_type)
  is RefPlannedValueShape
}

///|
fn wasmgc_builtin_import_identity(name : Bytes) -> WasmImportIdentity {
  let wasi_prefix = b"wasi_snapshot_preview1."
  if name.length() >= wasi_prefix.length() &&
    name[0:wasi_prefix.length()] == wasi_prefix {
    WasmImportIdentity::wasi(name[wasi_prefix.length():].to_owned())
  } else {
    WasmImportIdentity::host(name)
  }
}

///|
fn wasmgc_append_shape_value_types(
  output : Array[PlannedWasmValueType],
  shape : PlannedValueShape,
) -> Unit {
  match shape {
    ProductPlannedValueShape(fields) =>
      for field in fields {
        wasmgc_append_shape_value_types(output, field)
      }
    UnitPlannedValueShape | NeverPlannedValueShape => ()
    I8PlannedValueShape
    | I16PlannedValueShape
    | I32PlannedValueShape
    | U8PlannedValueShape
    | U16PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => output.push(WasmI32Value)
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape =>
      output.push(WasmI64Value)
    F32PlannedValueShape => output.push(WasmF32Value)
    F64PlannedValueShape => output.push(WasmF64Value)
    V128PlannedValueShape => output.push(WasmV128Value)
    RefPlannedValueShape | GenericPlannedValueShape | ErrorPlannedValueShape =>
      output.push(WasmNullableEqRefValue)
  }
}

///|
fn wasmgc_append_resolved_abi_type(
  output : Array[PlannedWasmValueType],
  resolved : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
  self_type : ResolvedTypeId,
  type_index_by_declaration : Array[Int],
  function_type_by_resolved : Array[Int],
  closure_abi : Bool,
) -> Unit {
  let shape = planned_resolved_value_shape(resolved, type_)
  match shape {
    ProductPlannedValueShape(_) =>
      wasmgc_append_shape_value_types(output, shape)
    _ =>
      match
        wasmgc_value_type(
          resolved, type_, self_type, type_index_by_declaration, function_type_by_resolved,
          closure_abi,
        ) {
        Some(value) => output.push(value)
        None => ()
      }
  }
}

///|
fn wasmgc_plan_function_job(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  callable : PlannedCallable,
  type_index_by_declaration : Array[Int],
  function_type_by_resolved : Array[Int],
  closure_abi : Bool,
  deferred? : Bool = false,
) -> WasmFunctionFragmentJob {
  let parameters : Array[PlannedWasmValueType] = []
  for index in 0..<(if deferred { 0 } else { callable.parameters.length }) {
    let parameter = functions.parameters[callable.parameters.start + index]
    match parameter.shape {
      ProductPlannedValueShape(_) =>
        wasmgc_append_shape_value_types(parameters, parameter.shape)
      I32PlannedValueShape => parameters.push(WasmI32Value)
      I64PlannedValueShape => parameters.push(WasmI64Value)
      _ =>
        match
          wasmgc_value_type(
            resolved,
            parameter.type_,
            callable.self_type,
            type_index_by_declaration,
            function_type_by_resolved,
            closure_abi,
          ) {
          Some(value) => parameters.push(value)
          None => ()
        }
    }
  }
  let results : Array[PlannedWasmValueType] = []
  if !deferred {
    match callable.result_shape {
      ProductPlannedValueShape(_) =>
        wasmgc_append_shape_value_types(results, callable.result_shape)
      I32PlannedValueShape => results.push(WasmI32Value)
      I64PlannedValueShape => results.push(WasmI64Value)
      _ =>
        match
          wasmgc_value_type(
            resolved,
            callable.result_type,
            callable.self_type,
            type_index_by_declaration,
            function_type_by_resolved,
            closure_abi,
          ) {
          Some(value) => results.push(value)
          None => ()
        }
    }
  }
  let kind = match callable.kind {
    PlannedBuiltinCallable(name) =>
      if compile_time_type_query_arity(name) is Some(_) ||
        name == b"types.static_assert" ||
        computed_type_builtin(name) {
        // Queries have no runtime implementation or import. Any surviving use
        // is a planning error, never a host function with the same spelling.
        PlannedWasmSignatureOnlyFunction
      } else if wasmgc_builtin_is_runtime(name) {
        PlannedWasmRuntimeFunction(name)
      } else if wasmgc_builtin_is_inline(name) {
        PlannedWasmInlineBuiltinFunction(name)
      } else {
        PlannedWasmImportedFunction(wasmgc_builtin_import_identity(name))
      }
    PlannedForeignCallable(logical_name, export_name) =>
      PlannedWasmImportedFunction(
        WasmImportIdentity::static_link(logical_name, export_name),
      )
    PlannedFunctionCallable(body) => PlannedWasmDefinedFunction(body)
    PlannedTraitMethodCallable(_) => PlannedWasmSignatureOnlyFunction
    PlannedImplMethodCallable(_, Some(body)) => PlannedWasmDefinedFunction(body)
    PlannedImplMethodCallable(_, None) => PlannedWasmSignatureOnlyFunction
  }
  { kind, parameters, results, }
}

///|
fn wasmgc_strip_carrier_identity_casts(
  lowering : PlannedModuleLowering,
  builtin_names : Map[DeclId, Bytes],
  expressions : HirSpan,
  expression : ExprId,
) -> ExprId {
  if expressions.start < 0 ||
    expressions.start > lowering.expressions.length() ||
    expressions.length < 0 ||
    expressions.length > lowering.expressions.length() - expressions.start {
    return expression
  }
  let mut current = expression
  // This is an optional optimization. Invalid or symbolic casts are retained
  // for the normal signature verifier; they must never be optimized away.
  for _ in 0..<expressions.length {
    if current < expressions.start ||
      current - expressions.start >= expressions.length {
      return expression
    }
    let value = lowering.expressions[current]
    let (target, arguments) = match value.kind {
      PlannedDirectCall(target, receiver, arguments, _) if receiver < 0 =>
        (target, arguments)
      _ => return current
    }
    match builtin_names.get(target) {
      Some(name) if name == b"unsafe.bitcast" => ()
      _ => return current
    }
    if arguments.length != 1 ||
      arguments.start < 0 ||
      arguments.start >= lowering.expression_children.length() {
      return current
    }
    let input = lowering.expression_children[arguments.start]
    if input < 0 || input >= lowering.expressions.length() {
      return current
    }
    let carrier = raw_wasm_nonreference_carrier(value.shape)
    if carrier is None ||
      carrier !=
      raw_wasm_nonreference_carrier(lowering.expressions[input].shape) {
      return current
    }
    current = input
  }
  expression
}

///|
fn wasmgc_direct_builtin_of(
  lowering : PlannedModuleLowering,
  callable : PlannedCallable,
  builtin_names : Map[DeclId, Bytes],
) -> Bytes {
  let body_id = match callable.kind {
    PlannedFunctionCallable(body) => body
    PlannedImplMethodCallable(_, Some(body)) => body
    PlannedBuiltinCallable(_)
    | PlannedForeignCallable(_, _)
    | PlannedTraitMethodCallable(_)
    | PlannedImplMethodCallable(_, None) => return b""
  }
  let body_index = semantic_id_local(body_id)
  if body_index < 0 || body_index >= lowering.bodies.length() {
    return b""
  }
  let body = lowering.bodies[body_index]
  let block_id = match body.root {
    BlockBodyRoot(block) => block
    ExpressionBodyRoot(_) => return b""
  }
  let block = lowering.blocks[block_id]
  if block.items.length != 1 {
    return b""
  }
  let expression = match lowering.block_items[block.items.start].kind {
    PlannedExpressionItem(expression) => expression
    PlannedLetItem(_, _, _) | PlannedElidedLetItem(_) => return b""
  }
  if expression < body.expressions.start ||
    expression - body.expressions.start >= body.expressions.length {
    return b""
  }
  let unwrapped = wasmgc_strip_carrier_identity_casts(
    lowering,
    builtin_names,
    body.expressions,
    expression,
  )
  if unwrapped != expression &&
    callable.parameters.length == 1 &&
    lowering.expressions[unwrapped].kind is PlannedLocalGet(0) &&
    body.locals.length >= 1 &&
    body.locals.start >= 0 &&
    body.locals.start < lowering.locals.length() &&
    lowering.locals[body.locals.start].kind is ParameterLocal {
    return b"unsafe.bitcast"
  }
  let (target, arguments) = match lowering.expressions[unwrapped].kind {
    PlannedDirectCall(target, receiver, arguments, type_arguments)
    | PlannedTailCall(target, receiver, arguments, type_arguments) => {
      if receiver >= 0 || type_arguments.length != 0 {
        return b""
      }
      (target, arguments)
    }
    _ => return b""
  }
  if arguments.length != callable.parameters.length ||
    arguments.start < 0 ||
    arguments.start > lowering.expression_children.length() ||
    arguments.length > lowering.expression_children.length() - arguments.start {
    return b""
  }
  for index in 0..<arguments.length {
    let source = lowering.expression_children[arguments.start + index]
    if source < body.expressions.start ||
      source - body.expressions.start >= body.expressions.length {
      return b""
    }
    let argument = wasmgc_strip_carrier_identity_casts(
      lowering,
      builtin_names,
      body.expressions,
      source,
    )
    match lowering.expressions[argument].kind {
      PlannedLocalGet(local_id) => {
        if local_id != index || local_id >= body.locals.length {
          return b""
        }
        match lowering.locals[body.locals.start + local_id].kind {
          ParameterLocal => ()
          LetLocal | PatternLocal => return b""
        }
      }
      _ => return b""
    }
  }
  match builtin_names.get(target) {
    Some(name) =>
      if !wasmgc_builtin_is_runtime(name) && wasmgc_builtin_is_inline(name) {
        name
      } else {
        b""
      }
    _ => b""
  }
}

///|
fn wasmgc_forwarding_builtins(
  lowering : PlannedModuleLowering,
  builtin_names : Map[DeclId, Bytes],
) -> Array[Bytes] {
  let callables = lowering.functions.callables
  let result = Array::make(callables.length(), b"")
  let dependents : Map[DeclId, Array[Int]] = {}
  let queue : Array[Int] = []
  let pending = Array::make(callables.length(), true)
  for index, callable in callables {
    queue.push(index)
    let body_id = match callable.kind {
      PlannedFunctionCallable(body)
      | PlannedImplMethodCallable(_, Some(body)) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    let block = match body.root {
      BlockBodyRoot(block) => block
      _ => continue
    }
    if block < 0 ||
      block >= lowering.blocks.length() ||
      lowering.blocks[block].items.length != 1 {
      continue
    }
    let span = body.expressions
    if span.start < 0 ||
      span.start > lowering.expressions.length() ||
      span.length < 0 ||
      span.length > lowering.expressions.length() - span.start {
      continue
    }
    for expression in span.start..<(span.start + span.length) {
      let target = match lowering.expressions[expression].kind {
        PlannedDirectCall(target, _, _, _) | PlannedTailCall(target, _, _, _) =>
          target
        _ => continue
      }
      match dependents.get(target) {
        Some(users) => users.push(index)
        None => dependents[target] = [index]
      }
    }
  }
  // A declaration gains one proved opcode at most once. Only its users need
  // another attempt. Recursive forwarding cycles remain ordinary functions.
  while queue.length() > 0 {
    let index = queue.pop().unwrap()
    pending[index] = false
    if result[index].length() > 0 {
      continue
    }
    let callable = callables[index]
    let name = wasmgc_direct_builtin_of(lowering, callable, builtin_names)
    if name.length() == 0 {
      continue
    }
    result[index] = name
    builtin_names[callable.declaration] = name
    match dependents.get(callable.declaration) {
      Some(users) =>
        for user in users {
          if !pending[user] && result[user].length() == 0 {
            pending[user] = true
            queue.push(user)
          }
        }
      None => ()
    }
  }
  result
}

///|
fn wasmgc_validate_order(order : Array[Int], count : Int) -> Unit {
  if order.length() != count {
    abort("WasmGC fragment job order has the wrong length")
  }
  let seen = Array::make(count, false)
  for index in order {
    if index < 0 || index >= count || seen[index] {
      abort("WasmGC fragment job order is invalid")
    }
    seen[index] = true
  }
}

///|
fn wasmgc_module_uses_closure_abi(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
) -> Bool {
  for expression in lowering.expressions {
    match expression.kind {
      PlannedFunctionReference(_, _)
      | PlannedLambdaClosure(_, _)
      | PlannedFunctionValueCall(_, _, _) => return true
      _ => ()
    }
  }
  for type_ in resolved.parameter_types {
    match resolved.types[type_] {
      FunctionType(_, _) => return true
      _ => ()
    }
  }
  for type_ in resolved.callable_return_types {
    match resolved.types[type_] {
      FunctionType(_, _) => return true
      _ => ()
    }
  }
  false
}

///|
fn wasmgc_lambda_declaration(module_id : ModuleId, lambda : LambdaId) -> DeclId {
  make_semantic_id(module_id, 0x70000000 + lambda)
}

///|
fn wasmgc_trait_adapter_declaration(
  module_id : ModuleId,
  adapter : Int,
) -> DeclId {
  make_semantic_id(module_id, 0x71000000 + adapter)
}

///|
fn wasmgc_runtime_trait_declarations(
  lowering : PlannedModuleLowering,
  extra_runtime_traits : Array[DeclId],
) -> Array[DeclId] {
  let seen : Map[DeclId, Bool] = Map::default()
  let traits : Array[DeclId] = []
  for expression in lowering.expressions {
    let trait_ = match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(value, _) => value
      _ =>
        match expression.kind {
          PlannedDynamicTraitCall(value, _, _, _, _, _) => value
          _ => 0UL
        }
    }
    if trait_ != 0UL && !seen.contains(trait_) {
      seen[trait_] = true
      traits.push(trait_)
    }
  }
  for trait_ in extra_runtime_traits {
    if trait_ != 0UL && !seen.contains(trait_) {
      seen[trait_] = true
      traits.push(trait_)
    }
  }
  traits
}

///|
fn wasmgc_trait_evidence_shape_code(shape : PlannedValueShape) -> Int {
  match shape {
    ErrorPlannedValueShape => 0
    UnitPlannedValueShape => 1
    I8PlannedValueShape => 2
    I16PlannedValueShape => 3
    I32PlannedValueShape => 4
    I64PlannedValueShape => 5
    U8PlannedValueShape => 6
    U16PlannedValueShape => 7
    U32PlannedValueShape => 8
    U64PlannedValueShape => 9
    F32PlannedValueShape => 10
    F64PlannedValueShape => 11
    Swar32PlannedValueShape => 12
    Swar64PlannedValueShape => 13
    V128PlannedValueShape => 14
    RefPlannedValueShape => 15
    GenericPlannedValueShape => 16
    NeverPlannedValueShape => 17
    ProductPlannedValueShape(_) => 18
  }
}

///|
fn append_wasmgc_trait_evidence_key(
  lowering : PlannedModuleLowering,
  evidence : Int,
  depth : Int,
  output : Buffer,
) -> Unit {
  if depth >= 64 || evidence < 0 || evidence >= lowering.trait_evidence.length() {
    output.write_string_utf8("!")
    return
  }
  match lowering.trait_evidence[evidence].kind {
    GuardedInferredTraitEvidence(target, bound) =>
      output.write_string_utf8("g\{target}:\{bound}")
    BoundInferredTraitEvidence(slot) => {
      output.write_string_utf8("b")
      output.write_string_utf8(slot.to_string())
    }
    ConcreteInferredTraitEvidence(implementation, arguments) => {
      output.write_string_utf8("i")
      output.write_string_utf8(implementation.to_string())
      output.write_string_utf8("[")
      for index in 0..<arguments.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        match lowering.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(shape) => {
            output.write_string_utf8("s")
            output.write_string_utf8(
              wasmgc_trait_evidence_shape_code(shape).to_string(),
            )
          }
          GenericInferredTraitEvidenceArgument(parameter) => {
            output.write_string_utf8("g")
            output.write_string_utf8(parameter.to_string())
          }
        }
      }
      output.write_string_utf8("]{")
      let prerequisites = lowering.trait_evidence[evidence].prerequisites
      for index in 0..<prerequisites.length {
        if index > 0 {
          output.write_string_utf8(",")
        }
        append_wasmgc_trait_evidence_key(
          lowering,
          lowering.trait_evidence_children[prerequisites.start + index],
          depth + 1,
          output,
        )
      }
      output.write_string_utf8("}")
    }
  }
}

///|
pub fn wasmgc_trait_evidence_key(
  lowering : PlannedModuleLowering,
  evidence : Int,
) -> String {
  let output = Buffer()
  append_wasmgc_trait_evidence_key(lowering, evidence, 0, output)
  @utf8.decode_lossy(output.to_bytes())
}

///|
fn wasmgc_trait_evidence_runtime_materialized(
  lowering : PlannedModuleLowering,
  evidence : Int,
  depth : Int,
) -> Bool {
  if evidence < 0 ||
    evidence >= lowering.trait_evidence.length() ||
    depth > lowering.trait_evidence.length() {
    return false
  }
  let node = lowering.trait_evidence[evidence]
  match node.kind {
    BoundInferredTraitEvidence(_) | GuardedInferredTraitEvidence(_, _) =>
      return false
    ConcreteInferredTraitEvidence(_, arguments) =>
      for index in 0..<arguments.length {
        match lowering.trait_evidence_arguments[arguments.start + index] {
          ShapeInferredTraitEvidenceArgument(_) => ()
          GenericInferredTraitEvidenceArgument(_) => return false
        }
      }
  }
  if node.prerequisites.start < 0 ||
    node.prerequisites.start + node.prerequisites.length >
    lowering.trait_evidence_children.length() {
    return false
  }
  for index in 0..<node.prerequisites.length {
    if !wasmgc_trait_evidence_runtime_materialized(
        lowering,
        lowering.trait_evidence_children[node.prerequisites.start + index],
        depth + 1,
      ) {
      return false
    }
  }
  true
}

///|
fn wasmgc_trait_evidence_implementation(
  lowering : PlannedModuleLowering,
  evidence : Int,
) -> DeclId? {
  if evidence < 0 || evidence >= lowering.trait_evidence.length() {
    return None
  }
  match lowering.trait_evidence[evidence].kind {
    ConcreteInferredTraitEvidence(implementation, _) => Some(implementation)
    BoundInferredTraitEvidence(_) | GuardedInferredTraitEvidence(_, _) => None
  }
}

///|
fn wasmgc_imported_interface_callable(
  imports : ResolvedModuleImports,
  declaration : DeclId,
) -> FrozenInterfaceCallable? {
  for interface_index in imports.scope.imported_interfaces {
    let interface_ = imports.scope.interfaces[interface_index].unwrap()
    for callable in interface_.callables {
      if callable.declaration == declaration {
        return Some(callable)
      }
    }
  }
  None
}

///|
fn wasmgc_trait_requirements(
  functions : PlannedModuleFunctions,
  imports : ResolvedModuleImports?,
  trait_declaration : DeclId,
) -> Array[DeclId] {
  let requirements : Array[DeclId] = []
  if semantic_id_module(trait_declaration) == functions.module_id {
    for callable in functions.callables {
      match callable.kind {
        PlannedTraitMethodCallable(owner) if owner == trait_declaration &&
          callable.has_receiver => requirements.push(callable.declaration)
        _ => ()
      }
    }
    return requirements
  }
  match imports {
    Some(imports) =>
      for interface_index in imports.scope.imported_interfaces {
        let interface_ = imports.scope.interfaces[interface_index].unwrap()
        for callable in interface_.callables {
          match callable.kind {
            FrozenTraitCallable(owner) if owner == trait_declaration => {
              let imported = match imports.callable(callable.declaration) {
                Some(value) => value
                None => continue
              }
              if imported.parameters.length > 0 &&
                imports.parameter_receivers[imported.parameters.start] {
                requirements.push(callable.declaration)
              }
            }
            _ => ()
          }
        }
      }
    None => ()
  }
  requirements
}

///|
fn wasmgc_trait_requirement_offset(
  functions : PlannedModuleFunctions,
  imports : ResolvedModuleImports?,
  requirement : DeclId,
) -> UInt64 {
  match functions.callable_of(requirement) {
    Some(value) => value.offset
    None =>
      match imports {
        Some(imports) =>
          match wasmgc_imported_interface_callable(imports, requirement) {
            Some(value) => value.location.offset
            None => 0UL
          }
        None => 0UL
      }
  }
}

///|
fn wasmgc_trait_requirement_name(
  functions : PlannedModuleFunctions,
  imports : ResolvedModuleImports?,
  requirement : DeclId,
) -> String? {
  match functions.callable_of(requirement) {
    Some(value) => Some(@utf8.decode_lossy(value.name))
    None =>
      match imports {
        Some(imports) =>
          match wasmgc_imported_interface_callable(imports, requirement) {
            Some(value) => Some(value.name)
            None => None
          }
        None => None
      }
  }
}

///|
fn wasmgc_trait_implementation_method(
  functions : PlannedModuleFunctions,
  imports : ResolvedModuleImports?,
  implementation : DeclId,
  requirement : DeclId,
) -> DeclId? {
  let requirement_name = match
    wasmgc_trait_requirement_name(functions, imports, requirement) {
    Some(value) => value
    None => return None
  }
  if semantic_id_module(implementation) == functions.module_id {
    for callable in functions.callables {
      match callable.kind {
        PlannedImplMethodCallable(owner, _) if owner == implementation &&
          callable.has_receiver &&
          @utf8.decode_lossy(callable.name) == requirement_name =>
          return Some(callable.declaration)
        _ => ()
      }
    }
    return None
  }
  match imports {
    Some(imports) =>
      for interface_index in imports.scope.imported_interfaces {
        let interface_ = imports.scope.interfaces[interface_index].unwrap()
        for callable in interface_.callables {
          match callable.kind {
            FrozenImplCallable(owner) if owner == implementation &&
              callable.name == requirement_name =>
              return Some(callable.declaration)
            _ => ()
          }
        }
      }
    None => ()
  }
  None
}

///|
fn wasmgc_nominal_type_declaration(
  resolved : ResolvedModuleTypes,
  root : ResolvedTypeId,
) -> DeclId {
  let mut current = root
  while current >= 0 && current < resolved.types.length() {
    match resolved.types[current] {
      NominalType(declaration) => return declaration
      AppliedType(base, _) => current = base
      _ => return 0UL
    }
  }
  0UL
}

///|
fn wasmgc_trait_receiver_box_slot(shape : PlannedValueShape) -> Int {
  match shape {
    I8PlannedValueShape
    | I16PlannedValueShape
    | I32PlannedValueShape
    | U8PlannedValueShape
    | U16PlannedValueShape
    | U32PlannedValueShape
    | Swar32PlannedValueShape => 0
    I64PlannedValueShape | U64PlannedValueShape | Swar64PlannedValueShape => 1
    F32PlannedValueShape => 2
    F64PlannedValueShape => 3
    V128PlannedValueShape => 4
    _ => -1
  }
}

///|
fn wasmgc_trait_implementation_receiver(
  resolved : ResolvedModuleTypes,
  functions : PlannedModuleFunctions,
  imports : ResolvedModuleImports?,
  implementation : DeclId,
  implementation_method : DeclId,
) -> (PlannedValueShape, DeclId) {
  match functions.callable_of(implementation_method) {
    Some(callable) =>
      return (
        callable.self_shape,
        wasmgc_nominal_type_declaration(resolved, callable.self_type),
      )
    None => ()
  }
  match imports {
    Some(imports) =>
      match imports.implementation(implementation) {
        Some(value) =>
          return (
            planned_resolved_value_shape(resolved, value.target_type),
            wasmgc_nominal_type_declaration(resolved, value.target_type),
          )
        None => ()
      }
    None => ()
  }
  (ErrorPlannedValueShape, 0UL)
}

///|
fn plan_module_wasmgc_fragments_in_orders_with_instantiations(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
  imports : ResolvedModuleImports?,
  options : WasmGCPlanningOptions,
  type_order : Array[Int],
  function_order : Array[Int],
  program_roots : Map[DeclId, Bool],
  program_function_value_roots : Map[DeclId, Bool],
  extra_runtime_traits : Array[DeclId],
  generic_enum_instantiations : Map[DeclId, Array[Array[Int]]],
  deferred_callables? : Map[DeclId, Bool] = {},
) -> PlannedModuleWasmGCFragments {
  if resolved.module_id != lowering.module_id {
    abort("WasmGC fragment inputs belong to different modules")
  }
  let resolved = {
    ..resolved,
    types: lowering.resolved_types,
    type_arguments: lowering.resolved_type_arguments,
    raw_array_declarations: lowering.raw_array_declarations,
  }
  let layouts = lowering.type_layouts
  let functions = lowering.functions
  let runtime_traits = wasmgc_runtime_trait_declarations(
    lowering, extra_runtime_traits,
  )
  let runtime_requirements : Map[DeclId, Bool] = Map::default()
  for trait_declaration in runtime_traits {
    for
      requirement in wasmgc_trait_requirements(
        functions, imports, trait_declaration,
      ) {
      runtime_requirements[requirement] = true
    }
  }
  let closure_abi = wasmgc_module_uses_closure_abi(resolved, lowering)
  let reachable_functions = wasmgc_reachable_defined_functions(
    lowering,
    functions,
    options.emit_tests,
    program_roots,
  )
  let required_declarations = wasmgc_required_nominal_declarations(
    resolved, lowering, functions, reachable_functions, program_roots, deferred_callables,
  )
  let (sources, entity_by_declaration, source_by_variant) = wasmgc_build_physical_sources(
    layouts,
    options,
    required_declarations,
    program_roots.length() > 0,
    generic_enum_instantiations,
    lowering.raw_array_declarations,
  )
  let effective_type_order = if program_roots.length() > 0 {
    let order : Array[Int] = []
    for index in 0..<sources.length() {
      order.push(index)
    }
    order
  } else {
    type_order
  }
  wasmgc_validate_order(effective_type_order, sources.length())
  wasmgc_validate_order(function_order, functions.callables.length())
  let type_jobs : Array[WasmPhysicalTypeJob?] = Array::make(
    sources.length(),
    None,
  )
  let marks = Array::make(sources.length(), 0)
  for entity in effective_type_order {
    type_jobs[entity] = Some(
      wasmgc_plan_physical_type_job(
        resolved,
        layouts,
        sources[entity],
        entity_by_declaration,
        marks,
        entity + 1,
      ),
    )
  }
  let frozen_type_jobs : Array[WasmPhysicalTypeJob] = []
  for job in type_jobs {
    frozen_type_jobs.push(job.unwrap())
  }
  let (component_spans, component_members) = wasmgc_type_sccs(frozen_type_jobs)
  let entity_type_indices = Array::make(sources.length(), -1)
  let type_index_by_declaration = Array::make(
    layouts.layout_by_declaration.length(),
    -1,
  )
  let payload_type_index_by_variant = Array::make(layouts.variants.length(), -1)
  let mut next_type_index = 0
  for component in component_spans {
    for index in 0..<component.length {
      let entity = component_members[component.start + index]
      entity_type_indices[entity] = next_type_index
      match sources[entity].kind {
        PlannedWasmStructType(declaration)
        | PlannedWasmForeignMarkerType(declaration)
        | PlannedWasmEnumBaseType(declaration) =>
          type_index_by_declaration[semantic_id_local(declaration)] = next_type_index
        PlannedWasmEnumSubtypeType(_, variant, _) =>
          payload_type_index_by_variant[semantic_id_local(variant)] = next_type_index
        PlannedWasmClosureType
        | PlannedWasmCaptureCellType(_)
        | PlannedWasmLambdaClosureType(_)
        | PlannedWasmTraitMethodSignatureType(_)
        | PlannedWasmTraitVTableType(_)
        | PlannedWasmTraitObjectType(_) =>
          abort("synthetic runtime type entered nominal index planning")
      }
      next_type_index += 1
    }
  }
  for variant_index in 0..<source_by_variant.length() {
    let source = source_by_variant[variant_index]
    if source >= 0 {
      payload_type_index_by_variant[variant_index] = entity_type_indices[source]
    }
  }
  let group_index_by_type = Array::make(sources.length(), -1)
  let group_first_type_indices : Array[Int] = []
  for group_index, component in component_spans {
    let first_entity = component_members[component.start]
    group_first_type_indices.push(entity_type_indices[first_entity])
    for index in 0..<component.length {
      let entity = component_members[component.start + index]
      group_index_by_type[entity_type_indices[entity]] = group_index
    }
  }
  let type_groups : Array[PlannedWasmRecursiveGroup] = []
  let physical_types : Array[PlannedWasmPhysicalType] = []
  let fields : Array[PlannedWasmField] = []
  for group_index, component in component_spans {
    let start = physical_types.length()
    let first_type_index = group_first_type_indices[group_index]
    for index in 0..<component.length {
      let entity = component_members[component.start + index]
      let source = sources[entity]
      physical_types.push({
        kind: source.kind,
        type_index: entity_type_indices[entity],
        group_index,
        fields: wasmgc_append_physical_type_fields(
          resolved, layouts, source, type_index_by_declaration, group_index, group_index_by_type,
          group_first_type_indices, fields,
        ),
        offset: source.offset,
      })
    }
    type_groups.push({
      types: { start, length: physical_types.length() - start, },
      first_type_index,
    })
  }
  let capture_cell_type_indices = Array::make(6, -1)
  let capture_cell_offsets = Array::make(6, 0UL)
  let capture_cell_used = Array::make(6, false)
  for capture in lowering.captures {
    if capture.mutable_ && !lowering.lambdas[capture.lambda].elided {
      let slot = wasmgc_capture_cell_slot(capture.shape)
      if slot >= 0 && !capture_cell_used[slot] {
        capture_cell_used[slot] = true
        capture_cell_offsets[slot] = capture.offset
      }
    }
  }
  for slot in 0..<capture_cell_used.length() {
    if !capture_cell_used[slot] {
      continue
    }
    let type_index = next_type_index
    next_type_index += 1
    capture_cell_type_indices[slot] = type_index
    let field_start = fields.length()
    fields.push({
      role: WasmCaptureCellValueField(slot),
      physical_index: 0,
      storage: wasmgc_capture_cell_storage(slot),
      mutable_: true,
      offset: capture_cell_offsets[slot],
    })
    let physical_start = physical_types.length()
    physical_types.push({
      kind: PlannedWasmCaptureCellType(slot),
      type_index,
      group_index: type_groups.length(),
      fields: { start: field_start, length: 1, },
      offset: capture_cell_offsets[slot],
    })
    type_groups.push({
      types: { start: physical_start, length: 1, },
      first_type_index: type_index,
    })
  }
  let mut closure_type_index = -1
  let lambda_closure_type_indices = Array::make(lowering.lambdas.length(), -1)
  let lambda_capture_field_indices = Array::make(lowering.captures.length(), -1)
  if closure_abi {
    closure_type_index = next_type_index
    next_type_index += 1
    let closure_field_start = fields.length()
    fields.push({
      role: WasmClosureEntryField,
      physical_index: 0,
      storage: WasmNullableFunctionRefStorage,
      mutable_: false,
      offset: 0UL,
    })
    let closure_physical_start = physical_types.length()
    physical_types.push({
      kind: PlannedWasmClosureType,
      type_index: closure_type_index,
      group_index: type_groups.length(),
      fields: { start: closure_field_start, length: 1, },
      offset: 0UL,
    })
    type_groups.push({
      types: { start: closure_physical_start, length: 1, },
      first_type_index: closure_type_index,
    })
    for lambda_index, lambda in lowering.lambdas {
      if lambda.directized || lambda.elided {
        continue
      }
      let type_index = next_type_index
      next_type_index += 1
      lambda_closure_type_indices[lambda_index] = type_index
      let field_start = fields.length()
      fields.push({
        role: WasmClosureEntryField,
        physical_index: 0,
        storage: WasmNullableFunctionRefStorage,
        mutable_: false,
        offset: 0UL,
      })
      let mut physical_index = 1
      for capture_index in 0..<lambda.captures.length {
        let global_capture = lambda.captures.start + capture_index
        let capture = lowering.captures[global_capture]
        match wasmgc_capture_storage(capture.shape, capture.mutable_) {
          Some(storage) => {
            lambda_capture_field_indices[global_capture] = physical_index
            fields.push({
              role: WasmLambdaCaptureField(lambda_index, capture_index),
              physical_index,
              storage,
              mutable_: false,
              offset: capture.offset,
            })
            physical_index += 1
          }
          None => ()
        }
      }
      let physical_start = physical_types.length()
      physical_types.push({
        kind: PlannedWasmLambdaClosureType(lambda_index),
        type_index,
        group_index: type_groups.length(),
        fields: { start: field_start, length: fields.length() - field_start, },
        offset: match lowering.lambdas[lambda_index].root {
          BlockBodyRoot(block) => lowering.blocks[block].offset
          ExpressionBodyRoot(expression) =>
            lowering.expressions[expression].offset
        },
      })
      type_groups.push({
        types: { start: physical_start, length: 1, },
        first_type_index: type_index,
      })
    }
  }
  let trait_layouts : Array[PlannedWasmTraitLayout] = []
  let trait_layout_methods : Array[DeclId] = []
  let trait_method_signature_indices : Array[Int] = []
  let runtime_requirement_signatures : Map[DeclId, Int] = Map::default()
  for trait_declaration in runtime_traits {
    let method_start = trait_layout_methods.length()
    for
      requirement in wasmgc_trait_requirements(
        functions, imports, trait_declaration,
      ) {
      let signature_type_index = next_type_index
      next_type_index += 1
      trait_layout_methods.push(requirement)
      trait_method_signature_indices.push(signature_type_index)
      runtime_requirement_signatures[requirement] = signature_type_index
      let signature_physical = physical_types.length()
      physical_types.push({
        kind: PlannedWasmTraitMethodSignatureType(requirement),
        type_index: signature_type_index,
        group_index: type_groups.length(),
        fields: { start: 0, length: 0, },
        offset: wasmgc_trait_requirement_offset(functions, imports, requirement),
      })
      type_groups.push({
        types: { start: signature_physical, length: 1, },
        first_type_index: signature_type_index,
      })
    }
    let vtable_type_index = next_type_index
    next_type_index += 1
    let object_type_index = next_type_index
    next_type_index += 1
    let vtable_physical = physical_types.length()
    physical_types.push({
      kind: PlannedWasmTraitVTableType(trait_declaration),
      type_index: vtable_type_index,
      group_index: type_groups.length(),
      fields: { start: 0, length: 0, },
      offset: 0UL,
    })
    type_groups.push({
      types: { start: vtable_physical, length: 1, },
      first_type_index: vtable_type_index,
    })
    let object_physical = physical_types.length()
    physical_types.push({
      kind: PlannedWasmTraitObjectType(trait_declaration),
      type_index: object_type_index,
      group_index: type_groups.length(),
      fields: { start: 0, length: 0, },
      offset: 0UL,
    })
    type_groups.push({
      types: { start: object_physical, length: 1, },
      first_type_index: object_type_index,
    })
    trait_layouts.push({
      trait_declaration,
      vtable_type_index,
      object_type_index,
      methods: {
        start: method_start,
        length: trait_layout_methods.length() - method_start,
      },
    })
  }
  let function_type_by_resolved = Array::make(resolved.types.length(), -1)
  let required_function_types = Array::make(resolved.types.length(), false)
  let function_type_work : Array[ResolvedTypeId] = []
  let local_function_value_roots : Map[DeclId, Bool] = Map::default()
  for expression in lowering.expressions {
    match expression.kind {
      PlannedFunctionReference(declaration, _) => {
        local_function_value_roots[declaration] = true
        let source_type = program_body_resolved_type(lowering, expression.type_)
        if source_type >= 0 {
          function_type_work.push(source_type)
        }
      }
      PlannedFunctionValueCall(_, _, type_) if type_ >= 0 =>
        function_type_work.push(type_)
      _ => ()
    }
  }
  for callable_index, callable in functions.callables {
    if compile_time_projected_signature(lowering, callable) {
      continue
    }
    if local_function_value_roots.contains(callable.declaration) ||
      program_function_value_roots.contains(callable.declaration) {
      function_type_work.push(resolved.callable_function_types[callable_index])
    }
    for offset in 0..<callable.parameters.length {
      let type_ = functions.parameters[callable.parameters.start + offset].type_
      match resolved.types[type_] {
        FunctionType(_, _) => function_type_work.push(type_)
        _ => ()
      }
    }
    let type_ = callable.result_type
    match resolved.types[type_] {
      FunctionType(_, _) => function_type_work.push(type_)
      _ => ()
    }
  }
  for index, type_ in resolved.lambda_function_types {
    if !lowering.lambdas[index].elided {
      function_type_work.push(type_)
    }
  }
  while function_type_work.length() > 0 {
    let type_ = function_type_work.pop().unwrap()
    if required_function_types[type_] {
      continue
    }
    required_function_types[type_] = true
    match resolved.types[type_] {
      FunctionType(parameters, result) => {
        match resolved.types[result] {
          FunctionType(_, _) => function_type_work.push(result)
          _ => ()
        }
        for index in 0..<parameters.length {
          let parameter = resolved.type_arguments[parameters.start + index]
          match resolved.types[parameter] {
            FunctionType(_, _) => function_type_work.push(parameter)
            _ => ()
          }
        }
      }
      _ => ()
    }
  }
  let function_types : Array[PlannedWasmFunctionTypeFragment] = []
  let function_value_types : Array[PlannedWasmValueType] = []
  let mut next_signature_type = physical_types.length()
  for type_id in 0..<resolved.types.length() {
    if required_function_types[type_id] {
      function_type_by_resolved[type_id] = next_signature_type
      next_signature_type += 1
    }
  }
  for type_id, type_ in resolved.types {
    if !required_function_types[type_id] {
      continue
    }
    match type_ {
      FunctionType(parameters, result) => {
        let parameter_start = function_value_types.length()
        for index in 0..<parameters.length {
          wasmgc_append_resolved_abi_type(
            function_value_types,
            resolved,
            resolved.type_arguments[parameters.start + index],
            -1,
            type_index_by_declaration,
            function_type_by_resolved,
            closure_abi,
          )
        }
        let parameter_span = {
          start: parameter_start,
          length: function_value_types.length() - parameter_start,
        }
        let result_start = function_value_types.length()
        wasmgc_append_resolved_abi_type(
          function_value_types, resolved, result, -1, type_index_by_declaration,
          function_type_by_resolved, closure_abi,
        )
        function_types.push({
          resolved_type: type_id,
          signature_type_index: function_type_by_resolved[type_id],
          parameters: parameter_span,
          results: {
            start: result_start,
            length: function_value_types.length() - result_start,
          },
        })
      }
      _ => ()
    }
  }
  let closure_entry_type_by_resolved = Array::make(resolved.types.length(), -1)
  let erased_closure_direct_type_by_resolved = Array::make(
    resolved.types.length(),
    -1,
  )
  let erased_closure_entry_type_by_resolved = Array::make(
    resolved.types.length(),
    -1,
  )
  if closure_abi {
    let precise_count = function_types.length()
    for index in 0..<precise_count {
      let source = function_types[index]
      let erased = wasmgc_append_erased_callback_signature(
        function_types, function_value_types, source, next_signature_type,
      )
      erased_closure_direct_type_by_resolved[source.resolved_type] = erased
      if erased == next_signature_type {
        next_signature_type += 1
      }
    }
  }
  if closure_abi {
    for type_id, type_ in resolved.types {
      if !required_function_types[type_id] {
        continue
      }
      let (parameters, result) = match type_ {
        FunctionType(parameters, result) => (parameters, result)
        _ => continue
      }
      let signature_type_index = next_signature_type
      next_signature_type += 1
      closure_entry_type_by_resolved[type_id] = signature_type_index
      let parameter_start = function_value_types.length()
      function_value_types.push(WasmNullableEqRefValue)
      for index in 0..<parameters.length {
        wasmgc_append_resolved_abi_type(
          function_value_types,
          resolved,
          resolved.type_arguments[parameters.start + index],
          -1,
          type_index_by_declaration,
          function_type_by_resolved,
          closure_abi,
        )
      }
      let parameter_span = {
        start: parameter_start,
        length: function_value_types.length() - parameter_start,
      }
      let result_start = function_value_types.length()
      wasmgc_append_resolved_abi_type(
        function_value_types, resolved, result, -1, type_index_by_declaration, function_type_by_resolved,
        closure_abi,
      )
      function_types.push({
        resolved_type: -1,
        signature_type_index,
        parameters: parameter_span,
        results: {
          start: result_start,
          length: function_value_types.length() - result_start,
        },
      })
      let erased = wasmgc_append_erased_callback_signature(
        function_types,
        function_value_types,
        function_types[function_types.length() - 1],
        next_signature_type,
      )
      erased_closure_entry_type_by_resolved[type_id] = erased
      if erased == next_signature_type {
        next_signature_type += 1
      }
    }
  }
  let lambda_entry_signature_indices = Array::make(
    lowering.lambdas.length(),
    -1,
  )
  let lambda_capture_parameter_indices = Array::make(
    lowering.captures.length(),
    -1,
  )
  for lambda_index, lambda in lowering.lambdas {
    if lambda.elided {
      continue
    }
    if !lambda.directized {
      lambda_entry_signature_indices[lambda_index] = closure_entry_type_by_resolved[resolved.lambda_function_types[lambda_index]]
      continue
    }
    let signature_type_index = next_signature_type
    next_signature_type += 1
    lambda_entry_signature_indices[lambda_index] = signature_type_index
    let parameter_start = function_value_types.length()
    let mut capture_parameter = 0
    for capture_index in 0..<lambda.captures.length {
      let global_capture = lambda.captures.start + capture_index
      let capture = lowering.captures[global_capture]
      match wasmgc_capture_storage(capture.shape, capture.mutable_) {
        Some(storage) => {
          lambda_capture_parameter_indices[global_capture] = capture_parameter
          capture_parameter += 1
          function_value_types.push(wasmgc_capture_value_type(storage))
        }
        None => ()
      }
    }
    let lambda_type = resolved.lambda_function_types[lambda_index]
    let (parameters, result) = match resolved.types[lambda_type] {
      FunctionType(parameters, result) => (parameters, result)
      _ => abort("lambda function type is not structural")
    }
    for parameter_index in 0..<parameters.length {
      wasmgc_append_resolved_abi_type(
        function_value_types,
        resolved,
        resolved.type_arguments[parameters.start + parameter_index],
        -1,
        type_index_by_declaration,
        function_type_by_resolved,
        closure_abi,
      )
    }
    let parameter_span = {
      start: parameter_start,
      length: function_value_types.length() - parameter_start,
    }
    let result_start = function_value_types.length()
    wasmgc_append_resolved_abi_type(
      function_value_types, resolved, result, -1, type_index_by_declaration, function_type_by_resolved,
      closure_abi,
    )
    function_types.push({
      resolved_type: -1,
      signature_type_index,
      parameters: parameter_span,
      results: {
        start: result_start,
        length: function_value_types.length() - result_start,
      },
    })
  }
  let function_jobs : Array[WasmFunctionFragmentJob?] = Array::make(
    functions.callables.length(),
    None,
  )
  for callable_index in function_order {
    function_jobs[callable_index] = Some(
      wasmgc_plan_function_job(
        resolved,
        functions,
        functions.callables[callable_index],
        type_index_by_declaration,
        function_type_by_resolved,
        closure_abi,
        deferred=compile_time_projected_signature(
          lowering,
          functions.callables[callable_index],
        ),
      ),
    )
  }
  wasmgc_add_runtime_dependencies(function_jobs, reachable_functions)
  let builtin_names : Map[DeclId, Bytes] = {}
  for callable in functions.callables {
    match callable.kind {
      PlannedBuiltinCallable(name) => builtin_names[callable.declaration] = name
      _ => ()
    }
  }
  match imports {
    Some(imports) =>
      for index in imports.scope.imported_interfaces {
        let interface_ = imports.scope.interfaces[index].unwrap()
        for callable in interface_.callables {
          match callable.kind {
            FrozenBuiltinCallable(name) =>
              builtin_names[callable.declaration] = name
            _ => ()
          }
        }
      }
    None => ()
  }
  let direct_builtins = wasmgc_forwarding_builtins(lowering, builtin_names)
  let elided_functions = Array::make(functions.callables.length(), false)
  for callable_index, callable in functions.callables {
    let direct_builtin = direct_builtins[callable_index]
    elided_functions[callable_index] = compile_time_projected_signature(
        lowering, callable,
      ) ||
      (direct_builtin.length() > 0 && callable.visibility == ModuleVisible) ||
      (match function_jobs[callable_index].unwrap().kind {
        PlannedWasmImportedFunction(_)
        | PlannedWasmDefinedFunction(_)
        | PlannedWasmRuntimeFunction(_) => !reachable_functions[callable_index]
        _ => false
      })
  }
  let mut imported_function_count = 0
  let mut defined_function_count = 0
  for lambda in lowering.lambdas {
    if !lambda.elided {
      defined_function_count += 1
    }
  }
  for callable_index, job in function_jobs {
    match job.unwrap().kind {
      PlannedWasmImportedFunction(_) =>
        if !elided_functions[callable_index] {
          imported_function_count += 1
        }
      PlannedWasmDefinedFunction(_) | PlannedWasmRuntimeFunction(_) =>
        if !elided_functions[callable_index] {
          defined_function_count += 1
        }
      PlannedWasmInlineBuiltinFunction(_) | PlannedWasmSignatureOnlyFunction =>
        ()
      PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmTraitAdapterFunction(_, _) =>
        abort("synthetic function appeared in callable fragment job")
    }
  }
  let planned_functions : Array[PlannedWasmFunctionFragment] = []
  let function_by_declaration = Array::make(
    functions.callable_by_declaration.length(),
    -1,
  )
  let mut import_index = 0
  let mut defined_index = imported_function_count
  for callable_index, callable in functions.callables {
    let job = function_jobs[callable_index].unwrap()
    let parameter_start = function_value_types.length()
    for parameter in job.parameters {
      function_value_types.push(parameter)
    }
    let parameters = {
      start: parameter_start,
      length: function_value_types.length() - parameter_start,
    }
    let result_start = function_value_types.length()
    for result in job.results {
      function_value_types.push(result)
    }
    let results = {
      start: result_start,
      length: function_value_types.length() - result_start,
    }
    let function_index = match job.kind {
      PlannedWasmImportedFunction(_) =>
        if elided_functions[callable_index] {
          -1
        } else {
          let index = import_index
          import_index += 1
          index
        }
      PlannedWasmDefinedFunction(_) | PlannedWasmRuntimeFunction(_) =>
        if elided_functions[callable_index] {
          -1
        } else {
          let index = defined_index
          defined_index += 1
          index
        }
      PlannedWasmInlineBuiltinFunction(_) | PlannedWasmSignatureOnlyFunction =>
        -1
      PlannedWasmDefinedLambdaFunction(_)
      | PlannedWasmTraitAdapterFunction(_, _) =>
        abort("synthetic function appeared in callable index assignment")
    }
    let emits_signature = match job.kind {
      PlannedWasmImportedFunction(_)
      | PlannedWasmDefinedFunction(_)
      | PlannedWasmRuntimeFunction(_) => !elided_functions[callable_index]
      PlannedWasmSignatureOnlyFunction =>
        runtime_requirements.contains(callable.declaration)
      _ => false
    }
    let signature_type_index = if emits_signature {
      match runtime_requirement_signatures.get(callable.declaration) {
        Some(index) => index
        None => {
          let source_function_type = resolved.callable_function_types[callable_index]
          let canonical = function_type_by_resolved[source_function_type]
          let scalarized_signature = wasmgc_callable_has_scalarized_signature(
            resolved, functions, callable,
          )
          if canonical >= 0 && !scalarized_signature {
            canonical
          } else {
            let index = next_signature_type
            next_signature_type += 1
            index
          }
        }
      }
    } else {
      -1
    }
    function_by_declaration[semantic_id_local(callable.declaration)] = callable_index
    planned_functions.push({
      declaration: callable.declaration,
      lambda: -1,
      name: callable.name,
      visibility: callable.visibility,
      is_test: callable.is_test,
      is_test_entry: callable.is_test_entry,
      test_name: callable.test_name,
      kind: job.kind,
      direct_builtin: direct_builtins[callable_index],
      elided: elided_functions[callable_index],
      signature_type_index,
      function_index,
      parameters,
      results,
      specialization_shapes: { start: 0, length: 0, },
      specialization_evidence: { start: 0, length: 0, },
      specialization_abi_key: "",
      offset: callable.offset,
    })
  }
  let lambda_function_indices = Array::make(lowering.lambdas.length(), -1)
  for lambda_index, lambda in lowering.lambdas {
    if lambda.elided {
      continue
    }
    let signature_type_index = lambda_entry_signature_indices[lambda_index]
    let mut function_type_index = -1
    for index, fragment in function_types {
      if fragment.signature_type_index == signature_type_index {
        function_type_index = index
        break
      }
    }
    guard function_type_index >= 0 else {
      abort("lambda entry signature fragment is missing")
    }
    let function_type = function_types[function_type_index]
    let function_index = defined_index
    defined_index += 1
    lambda_function_indices[lambda_index] = planned_functions.length()
    planned_functions.push({
      declaration: wasmgc_lambda_declaration(lowering.module_id, lambda_index),
      lambda: lambda_index,
      name: b"",
      visibility: ModuleVisible,
      is_test: false,
      is_test_entry: false,
      test_name: b"",
      kind: PlannedWasmDefinedLambdaFunction(lambda_index),
      direct_builtin: b"",
      elided: false,
      signature_type_index: lambda_entry_signature_indices[lambda_index],
      function_index,
      parameters: function_type.parameters,
      results: function_type.results,
      specialization_shapes: { start: 0, length: 0, },
      specialization_evidence: { start: 0, length: 0, },
      specialization_abi_key: "",
      offset: match lambda.root {
        BlockBodyRoot(block) => lowering.blocks[block].offset
        ExpressionBodyRoot(expression) =>
          lowering.expressions[expression].offset
      },
    })
  }
  match imports {
    Some(imports) =>
      for layout in trait_layouts {
        for slot in 0..<layout.methods.length {
          let requirement = trait_layout_methods[layout.methods.start + slot]
          if functions.callable_of(requirement) is Some(_) {
            continue
          }
          let callable = match imports.callable(requirement) {
            Some(value) => value
            None => continue
          }
          let interface_callable = match
            wasmgc_imported_interface_callable(imports, requirement) {
            Some(value) => value
            None => continue
          }
          let parameter_start = function_value_types.length()
          for index in 0..<callable.parameters.length {
            match
              wasmgc_value_type(
                resolved,
                imports.parameter_types[callable.parameters.start + index],
                -1,
                type_index_by_declaration,
                function_type_by_resolved,
                closure_abi,
              ) {
              Some(value) => function_value_types.push(value)
              None => ()
            }
          }
          let parameters = {
            start: parameter_start,
            length: function_value_types.length() - parameter_start,
          }
          let result_start = function_value_types.length()
          match
            wasmgc_value_type(
              resolved,
              callable.result_type,
              -1,
              type_index_by_declaration,
              function_type_by_resolved,
              closure_abi,
            ) {
            Some(value) => function_value_types.push(value)
            None => ()
          }
          planned_functions.push({
            declaration: requirement,
            lambda: -1,
            name: b"",
            visibility: ModuleVisible,
            is_test: false,
            is_test_entry: false,
            test_name: b"",
            kind: PlannedWasmSignatureOnlyFunction,
            direct_builtin: b"",
            elided: false,
            signature_type_index: runtime_requirement_signatures[requirement],
            function_index: -1,
            parameters,
            results: {
              start: result_start,
              length: function_value_types.length() - result_start,
            },
            specialization_shapes: { start: 0, length: 0, },
            specialization_evidence: { start: 0, length: 0, },
            specialization_abi_key: "",
            offset: interface_callable.location.offset,
          })
        }
      }
    None => ()
  }
  for layout in trait_layouts {
    let vtable_field_start = fields.length()
    for slot in 0..<layout.methods.length {
      let requirement = trait_layout_methods[layout.methods.start + slot]
      fields.push({
        role: WasmTraitMethodField(layout.trait_declaration, requirement, slot),
        physical_index: slot,
        storage: WasmFunctionRefStorage(
          trait_method_signature_indices[layout.methods.start + slot],
        ),
        mutable_: false,
        offset: wasmgc_trait_requirement_offset(functions, imports, requirement),
      })
    }
    for index in 0..<physical_types.length() {
      if physical_types[index].type_index == layout.vtable_type_index {
        physical_types[index] = {
          ..physical_types[index],
          fields: {
            start: vtable_field_start,
            length: fields.length() - vtable_field_start,
          },
        }
      }
    }
    let object_field_start = fields.length()
    fields.push({
      role: WasmTraitObjectReceiverField(layout.trait_declaration),
      physical_index: 0,
      storage: WasmNullableEqRefStorage,
      mutable_: false,
      offset: 0UL,
    })
    fields.push({
      role: WasmTraitObjectVTableField(layout.trait_declaration),
      physical_index: 1,
      storage: WasmNominalRefStorage(
        WasmModuleTypeReference(layout.vtable_type_index),
      ),
      mutable_: false,
      offset: 0UL,
    })
    for index in 0..<physical_types.length() {
      if physical_types[index].type_index == layout.object_type_index {
        physical_types[index] = {
          ..physical_types[index],
          fields: { start: object_field_start, length: 2, },
        }
      }
    }
  }
  let trait_dictionaries : Array[PlannedWasmTraitDictionary] = []
  let trait_methods : Array[PlannedWasmTraitMethod] = []
  let dictionary_keys : Map[String, Bool] = Map::default()
  for expression in lowering.expressions {
    let (trait_declaration, evidence) = match expression.trait_object_coercion {
      SelectedInferredTraitObjectCoercion(trait_, node) => (trait_, node)
      _ => continue
    }
    let implementation = match
      wasmgc_trait_evidence_implementation(lowering, evidence) {
      Some(value) => value
      None => continue
    }
    let evidence_key = wasmgc_trait_evidence_key(lowering, evidence)
    let runtime_materialized = wasmgc_trait_evidence_runtime_materialized(
      lowering, evidence, 0,
    )
    let key = trait_declaration.to_string() + ":" + evidence_key
    if dictionary_keys.contains(key) {
      continue
    }
    dictionary_keys[key] = true
    let mut selected_layout = None
    for layout in trait_layouts {
      if layout.trait_declaration == trait_declaration {
        selected_layout = Some(layout)
        break
      }
    }
    let layout = match selected_layout {
      Some(value) => value
      None => continue
    }
    let method_start = trait_methods.length()
    let mut complete = true
    for slot in 0..<layout.methods.length {
      let requirement = trait_layout_methods[layout.methods.start + slot]
      let implementation_method = match
        wasmgc_trait_implementation_method(
          functions, imports, implementation, requirement,
        ) {
        Some(value) => value
        None => {
          complete = false
          break
        }
      }
      let mut requirement_index = -1
      for index, function_ in planned_functions {
        if function_.declaration == requirement {
          requirement_index = index
          break
        }
      }
      if requirement_index < 0 {
        complete = false
        break
      }
      let requirement_fragment = planned_functions[requirement_index]
      let (receiver_shape, receiver_nominal) = wasmgc_trait_implementation_receiver(
        resolved, functions, imports, implementation, implementation_method,
      )
      if (receiver_shape == RefPlannedValueShape && receiver_nominal == 0UL) ||
        (
          receiver_shape != RefPlannedValueShape &&
          wasmgc_trait_receiver_box_slot(receiver_shape) < 0
        ) {
        complete = false
        break
      }
      let adapter_fragment = if runtime_materialized {
        let index = planned_functions.length()
        planned_functions.push({
          declaration: wasmgc_trait_adapter_declaration(
            lowering.module_id,
            trait_methods.length(),
          ),
          lambda: -1,
          name: b"",
          visibility: ModuleVisible,
          is_test: false,
          is_test_entry: false,
          test_name: b"",
          kind: PlannedWasmTraitAdapterFunction(
            implementation_method, requirement,
          ),
          direct_builtin: b"",
          elided: false,
          signature_type_index: requirement_fragment.signature_type_index,
          function_index: defined_index,
          parameters: requirement_fragment.parameters,
          results: requirement_fragment.results,
          specialization_shapes: { start: 0, length: 0, },
          specialization_evidence: { start: 0, length: 0, },
          specialization_abi_key: "",
          offset: expression.offset,
        })
        defined_index += 1
        defined_function_count += 1
        index
      } else {
        -1
      }
      trait_methods.push({
        trait_declaration,
        requirement,
        implementation_method,
        receiver_shape,
        receiver_nominal,
        implementation_specialization_abi_key: "",
        slot,
        signature_type_index: requirement_fragment.signature_type_index,
        adapter_function: adapter_fragment,
      })
    }
    if complete {
      trait_dictionaries.push({
        trait_declaration,
        implementation,
        evidence,
        evidence_key,
        vtable_type_index: layout.vtable_type_index,
        object_type_index: layout.object_type_index,
        methods: {
          start: method_start,
          length: trait_methods.length() - method_start,
        },
        runtime_evidence_parameters: { start: 0, length: 0, },
        runtime_materialized,
      })
    } else {
      trait_methods.truncate(method_start)
    }
  }
  let variant_declarations = Array::make(layouts.variants.length(), 0UL)
  let variant_tags = Array::make(layouts.variants.length(), -1)
  let variant_field_spans = Array::make(layouts.variants.length(), {
    start: 0,
    length: 0,
  })
  let variant_fields : Array[PlannedWasmVariantField] = []
  for variant_index, _ in layouts.variants {
    let start = variant_fields.length()
    let payload_type = payload_type_index_by_variant[variant_index]
    if payload_type < 0 {
      continue
    }
    let physical = physical_types[payload_type]
    for physical_index in 1..<physical.fields.length {
      let field = fields[physical.fields.start + physical_index]
      variant_fields.push({
        role: field.role,
        physical_index,
        storage: field.storage,
      })
    }
    variant_field_spans[variant_index] = {
      start,
      length: variant_fields.length() - start,
    }
  }
  let field_names = Array::make(layouts.fields.length(), "")
  for index, field in layouts.fields {
    field_names[index] = field.name
  }
  for index, variant in layouts.variants {
    if variant.tag >= 0 {
      variant_declarations[index] = variant.declaration
      variant_tags[index] = variant.tag
    }
  }
  let mut uses_text_runtime = false
  for field in fields {
    match field.storage {
      WasmStringRefStorage => {
        uses_text_runtime = true
        break
      }
      _ => ()
    }
  }
  if !uses_text_runtime {
    for callable_index, reachable in reachable_functions {
      if !reachable || elided_functions[callable_index] {
        continue
      }
      let function_ = planned_functions[callable_index]
      match function_.kind {
        PlannedWasmRuntimeFunction(_) => {
          uses_text_runtime = true
          break
        }
        _ => ()
      }
      if function_.signature_type_index >= 0 {
        for index in 0..<function_.parameters.length {
          match function_value_types[function_.parameters.start + index] {
            WasmStringRefValue => {
              uses_text_runtime = true
              break
            }
            _ => ()
          }
        }
        if uses_text_runtime {
          break
        }
        for index in 0..<function_.results.length {
          match function_value_types[function_.results.start + index] {
            WasmStringRefValue => {
              uses_text_runtime = true
              break
            }
            _ => ()
          }
        }
        if uses_text_runtime {
          break
        }
      }
      let body_id = match function_.kind {
        PlannedWasmDefinedFunction(body) => body
        _ => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index < 0 || body_index >= lowering.bodies.length() {
        continue
      }
      let body = lowering.bodies[body_index]
      for
        expression_index in body.expressions.start..<(body.expressions.start +
        body.expressions.length) {
        match lowering.expressions[expression_index].kind {
          PlannedStringConst(_) | PlannedBytesConst(_) => {
            uses_text_runtime = true
            break
          }
          _ => ()
        }
      }
      if uses_text_runtime {
        break
      }
    }
  }
  let mut uses_fixed_array_runtime = false
  for callable_index, reachable in reachable_functions {
    if !reachable || elided_functions[callable_index] {
      continue
    }
    let body_id = match planned_functions[callable_index].kind {
      PlannedWasmDefinedFunction(body) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    for
      expression in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      match lowering.expressions[expression].kind {
        PlannedFixedArrayMake(_, _, _)
        | PlannedRawArrayNewDefault(_, _, _)
        | PlannedRawArrayCopy(_, _, _, _, _, _, _)
        | PlannedFixedArrayLength(_, _)
        | PlannedArrayLiteral(_, _, _)
        | PlannedFixedArrayGetUnchecked(_, _, _)
        | PlannedFixedArraySetUnchecked(_, _, _, _) => {
          uses_fixed_array_runtime = true
          break
        }
        PlannedFieldGet(_, _, _) =>
          if lowering.expressions[expression].shape
            is ProductPlannedValueShape(_) {
            uses_fixed_array_runtime = true
            break
          }
        PlannedFieldSet(_, _, value) =>
          if lowering.expressions[value].shape is ProductPlannedValueShape(_) {
            uses_fixed_array_runtime = true
            break
          }
        PlannedStructNew(_, _, fields)
        | PlannedVariantStructNew(_, _, fields) => {
          for field_index in 0..<fields.length {
            let value = lowering.object_fields[fields.start + field_index].value
            if lowering.expressions[value].shape is ProductPlannedValueShape(_) {
              uses_fixed_array_runtime = true
              break
            }
          }
          if uses_fixed_array_runtime {
            break
          }
        }
        PlannedVariantTupleNew(_, _, arguments) => {
          for argument_index in 0..<arguments.length {
            let value = lowering.expression_children[arguments.start +
              argument_index]
            if lowering.expressions[value].shape is ProductPlannedValueShape(_) {
              uses_fixed_array_runtime = true
              break
            }
          }
          if uses_fixed_array_runtime {
            break
          }
        }
        _ => ()
      }
    }
    if uses_fixed_array_runtime {
      break
    }
  }
  if !uses_fixed_array_runtime {
    for capture in lowering.captures {
      if capture.shape is ProductPlannedValueShape(_) {
        uses_fixed_array_runtime = true
        break
      }
    }
  }
  if !uses_fixed_array_runtime {
    for step in lowering.initialization.steps {
      let body_id = match step.kind {
        PlannedInitializeModuleValue(_, body, _) => body
        PlannedCyclicModuleValues(_) => continue
      }
      let body_index = semantic_id_local(body_id)
      if body_index >= 0 &&
        body_index < lowering.bodies.length() &&
        lowering.bodies[body_index].result_shape is ProductPlannedValueShape(_) {
        uses_fixed_array_runtime = true
        break
      }
    }
  }
  let mut uses_linear_memory = false
  for callable_index, reachable in reachable_functions {
    if !reachable {
      continue
    }
    match function_jobs[callable_index].unwrap().kind {
      PlannedWasmInlineBuiltinFunction(name)
      | PlannedWasmRuntimeFunction(name) =>
        if wasmgc_builtin_uses_linear_memory(name) {
          uses_linear_memory = true
          break
        }
      _ => ()
    }
    let body_id = match function_jobs[callable_index].unwrap().kind {
      PlannedWasmDefinedFunction(body) => body
      _ => continue
    }
    let body_index = semantic_id_local(body_id)
    if body_index < 0 || body_index >= lowering.bodies.length() {
      continue
    }
    let body = lowering.bodies[body_index]
    for
      expression_index in body.expressions.start..<(body.expressions.start +
      body.expressions.length) {
      let declaration = match lowering.expressions[expression_index].kind {
        PlannedDirectCall(target, _, _, _)
        | PlannedTailCall(target, _, _, _)
        | PlannedOperatorCall(target, _, _, _, _)
        | PlannedIndexCall(target, _, _, _)
        | PlannedIndexSetCall(target, _, _, _, _)
        | PlannedFunctionReference(target, _) => target
        _ => continue
      }
      if semantic_id_module(declaration) != lowering.module_id {
        continue
      }
      let local_index = semantic_id_local(declaration)
      if local_index < 0 || local_index >= function_by_declaration.length() {
        continue
      }
      let function_index = function_by_declaration[local_index]
      if function_index < 0 {
        continue
      }
      let function_ = planned_functions[function_index]
      let name = if function_.direct_builtin.length() > 0 {
        function_.direct_builtin
      } else {
        match function_.kind {
          PlannedWasmInlineBuiltinFunction(name)
          | PlannedWasmRuntimeFunction(name) => name
          _ => b""
        }
      }
      if wasmgc_builtin_uses_linear_memory(name) {
        uses_linear_memory = true
        break
      }
    }
    if uses_linear_memory {
      break
    }
  }
  let imported_function_indices : Map[Bytes, Int] = Map::default()
  let runtime_function_indices : Map[Bytes, Int] = Map::default()
  for function_ in planned_functions {
    if function_.elided || function_.function_index < 0 {
      continue
    }
    match function_.kind {
      PlannedWasmImportedFunction(identity) =>
        imported_function_indices[identity.lookup_name()] = function_.function_index
      PlannedWasmRuntimeFunction(name) =>
        runtime_function_indices[name] = function_.function_index
      _ => ()
    }
  }
  {
    module_id: lowering.module_id,
    dense_enum_dispatch: options.dense_enum_dispatch,
    emit_tests: options.emit_tests,
    type_groups,
    physical_types,
    fields,
    type_index_by_declaration,
    payload_type_index_by_variant,
    variant_declarations,
    variant_tags,
    variant_field_spans,
    variant_fields,
    field_names,
    closure_type_index,
    capture_cell_type_indices,
    lambda_closure_type_indices,
    lambda_capture_field_indices,
    function_types,
    function_type_by_resolved,
    closure_entry_type_by_resolved,
    erased_closure_direct_type_by_resolved,
    erased_closure_entry_type_by_resolved,
    lambda_entry_signature_indices,
    lambda_capture_parameter_indices,
    trait_layouts,
    trait_layout_methods,
    trait_method_signature_indices,
    trait_dictionaries,
    trait_dictionary_runtime_evidence_parameters: [],
    trait_methods,
    functions: planned_functions,
    function_by_declaration,
    lambda_function_indices,
    function_value_types,
    specialization_shapes: [],
    specialization_evidence_roots: [],
    specialization_trait_evidence: [],
    specialization_evidence_children: [],
    specialization_evidence_arguments: [],
    specialized_lambda_layouts: {},
    signature_type_count: next_signature_type - physical_types.length(),
    imported_function_count,
    defined_function_count,
    imported_function_indices,
    runtime_function_indices,
    uses_text_runtime,
    uses_fixed_array_runtime,
    uses_linear_memory,
  }
}

///|
#warnings("-unused_value")
fn plan_module_wasmgc_fragments_in_orders(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
  imports : ResolvedModuleImports?,
  options : WasmGCPlanningOptions,
  type_order : Array[Int],
  function_order : Array[Int],
  program_roots : Map[DeclId, Bool],
  program_function_value_roots : Map[DeclId, Bool],
  extra_runtime_traits : Array[DeclId],
) -> PlannedModuleWasmGCFragments {
  plan_module_wasmgc_fragments_in_orders_with_instantiations(
    resolved,
    lowering,
    imports,
    options,
    type_order,
    function_order,
    program_roots,
    program_function_value_roots,
    extra_runtime_traits,
    wasmgc_collect_generic_enum_instantiations(resolved, lowering.type_layouts),
  )
}

///|
fn plan_module_wasmgc_fragments_with_options_and_roots(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
  imports : ResolvedModuleImports?,
  options : WasmGCPlanningOptions,
  program_roots : Map[DeclId, Bool],
  program_function_value_roots : Map[DeclId, Bool],
  extra_runtime_traits : Array[DeclId],
  generic_enum_instantiations : Map[DeclId, Array[Array[Int]]],
  deferred_callables? : Map[DeclId, Bool] = {},
) -> PlannedModuleWasmGCFragments {
  let type_order : Array[Int] = []
  for
    index in 0..<wasmgc_physical_type_count_with_instantiations(
      lowering.type_layouts,
      options,
      generic_enum_instantiations,
      lowering.raw_array_declarations,
    ) {
    type_order.push(index)
  }
  let function_order : Array[Int] = []
  for index in 0..<lowering.functions.callables.length() {
    function_order.push(index)
  }
  plan_module_wasmgc_fragments_in_orders_with_instantiations(
    resolved,
    lowering,
    imports,
    options,
    type_order,
    function_order,
    program_roots,
    program_function_value_roots,
    extra_runtime_traits,
    generic_enum_instantiations,
    deferred_callables~,
  )
}

///|
fn plan_module_wasmgc_fragments_with_options(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
  options : WasmGCPlanningOptions,
) -> PlannedModuleWasmGCFragments {
  plan_module_wasmgc_fragments_with_options_and_roots(
    resolved,
    lowering,
    None,
    options,
    Map::default(),
    Map::default(),
    [],
    wasmgc_collect_generic_enum_instantiations(resolved, lowering.type_layouts),
  )
}

///|
pub fn plan_module_wasmgc_fragments(
  resolved : ResolvedModuleTypes,
  lowering : PlannedModuleLowering,
) -> PlannedModuleWasmGCFragments {
  plan_module_wasmgc_fragments_with_options(
    resolved,
    lowering,
    WasmGCPlanningOptions::optimized_subtype_families(),
  )
}
