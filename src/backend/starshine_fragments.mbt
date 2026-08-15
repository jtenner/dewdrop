///|
fn starshine_type_index(
  reference : @semantic.PlannedWasmTypeReference,
) -> @lib.TypeIdx {
  match reference {
    @semantic.WasmModuleTypeReference(index) =>
      @lib.TypeIdx::new(index.reinterpret_as_uint())
    @semantic.WasmRecursiveTypeReference(index) =>
      @lib.TypeIdx::rec(index.reinterpret_as_uint())
  }
}

///|
fn starshine_nominal_ref(type_index : @lib.TypeIdx) -> @lib.ValType {
  @lib.ValType::ref_type(
    @lib.RefType::new(false, @lib.HeapType::new(type_index)),
  )
}

///|
fn starshine_function_ref(type_index : @lib.TypeIdx) -> @lib.ValType {
  @lib.ValType::ref_type(
    @lib.RefType::new(true, @lib.HeapType::new(type_index)),
  )
}

///|
fn starshine_storage_type(
  storage : @semantic.PlannedWasmStorageType,
) -> @lib.StorageType {
  match storage {
    @semantic.WasmI8SignedStorage | @semantic.WasmI8UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i8())
    @semantic.WasmI16SignedStorage | @semantic.WasmI16UnsignedStorage =>
      @lib.StorageType::pack_type(@lib.PackType::i16())
    @semantic.WasmI32Storage => @lib.StorageType::val_type(@lib.ValType::i32())
    @semantic.WasmI64Storage => @lib.StorageType::val_type(@lib.ValType::i64())
    @semantic.WasmF32Storage => @lib.StorageType::val_type(@lib.ValType::f32())
    @semantic.WasmF64Storage => @lib.StorageType::val_type(@lib.ValType::f64())
    @semantic.WasmV128Storage =>
      @lib.StorageType::val_type(@lib.ValType::v128())
    @semantic.WasmStringRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::eqref_null())
    @semantic.WasmNullableEqRefStorage
    | @semantic.WasmExternalNominalRefStorage(_)
    | @semantic.WasmFixedArrayRefStorage(_) =>
      @lib.StorageType::val_type(@lib.ValType::eqref_null())
    @semantic.WasmNullableFunctionRefStorage =>
      @lib.StorageType::val_type(@lib.ValType::funcref())
    @semantic.WasmFunctionRefStorage(index) =>
      @lib.StorageType::val_type(
        starshine_function_ref(@lib.TypeIdx::new(index.reinterpret_as_uint())),
      )
    @semantic.WasmNominalRefStorage(reference) =>
      @lib.StorageType::val_type(
        starshine_nominal_ref(starshine_type_index(reference)),
      )
  }
}

///|
fn starshine_value_type(value : @semantic.PlannedWasmValueType) -> @lib.ValType {
  match value {
    @semantic.WasmI32Value => @lib.ValType::i32()
    @semantic.WasmI64Value => @lib.ValType::i64()
    @semantic.WasmF32Value => @lib.ValType::f32()
    @semantic.WasmF64Value => @lib.ValType::f64()
    @semantic.WasmV128Value => @lib.ValType::v128()
    @semantic.WasmStringRefValue => @lib.ValType::eqref_null()
    @semantic.WasmNullableEqRefValue
    | @semantic.WasmExternalNominalRefValue(_)
    | @semantic.WasmFixedArrayRefValue(_) => @lib.ValType::eqref_null()
    @semantic.WasmFunctionRefValue(index) =>
      starshine_function_ref(@lib.TypeIdx::new(index.reinterpret_as_uint()))
    @semantic.WasmNominalRefValue(index) =>
      starshine_nominal_ref(@lib.TypeIdx::new(index.reinterpret_as_uint()))
  }
}

///|
fn starshine_physical_subtype(
  planned : @semantic.PlannedModuleWasmGCFragments,
  type_ : @semantic.PlannedWasmPhysicalType,
) -> (@lib.SubType, Bool) {
  let fields : Array[@lib.FieldType] = []
  let mut has_recursive_reference = false
  for index in 0..<type_.fields.length {
    let field = planned.fields[type_.fields.start + index]
    match field.storage {
      @semantic.WasmNominalRefStorage(@semantic.WasmRecursiveTypeReference(_)) =>
        has_recursive_reference = true
      _ => ()
    }
    fields.push(
      @lib.FieldType::new(
        starshine_storage_type(field.storage),
        if field.mutable_ {
          @lib.Mut::var_()
        } else {
          @lib.Mut::const_()
        },
      ),
    )
  }
  let composite = @lib.CompType::struct_(fields)
  let subtype = match type_.kind {
    @semantic.PlannedWasmEnumBaseType(_) | @semantic.PlannedWasmClosureType =>
      @lib.SubType::new(false, [], composite)
    @semantic.PlannedWasmEnumSubtypeType(declaration, _, _) =>
      @lib.SubType::new(
        true,
        [
          @lib.TypeIdx::new(
            planned.type_index_of(declaration).unwrap().reinterpret_as_uint(),
          ),
        ],
        composite,
      )
    @semantic.PlannedWasmCaptureCellType(_) =>
      @lib.SubType::new(true, [], composite)
    @semantic.PlannedWasmLambdaClosureType(_) =>
      @lib.SubType::new(
        true,
        [@lib.TypeIdx::new(planned.closure_type_index.reinterpret_as_uint())],
        composite,
      )
    @semantic.PlannedWasmTraitMethodSignatureType(requirement) =>
      starshine_function_subtype(
        planned,
        planned.function_of(requirement).unwrap(),
      )
    @semantic.PlannedWasmStructType(_)
    | @semantic.PlannedWasmForeignMarkerType(_)
    | @semantic.PlannedWasmTraitVTableType(_)
    | @semantic.PlannedWasmTraitObjectType(_) =>
      @lib.SubType::comp_type(composite)
  }
  (subtype, has_recursive_reference)
}

///|
fn starshine_function_subtype(
  planned : @semantic.PlannedModuleWasmGCFragments,
  function_ : @semantic.PlannedWasmFunctionFragment,
) -> @lib.SubType {
  let parameters : Array[@lib.ValType] = []
  for index in 0..<function_.parameters.length {
    parameters.push(
      starshine_value_type(
        planned.function_value_types[function_.parameters.start + index],
      ),
    )
  }
  let results : Array[@lib.ValType] = []
  for index in 0..<function_.results.length {
    results.push(
      starshine_value_type(
        planned.function_value_types[function_.results.start + index],
      ),
    )
  }
  @lib.SubType::comp_type(@lib.CompType::func(parameters, results))
}

///|
fn starshine_function_type_subtype(
  planned : @semantic.PlannedModuleWasmGCFragments,
  function_type : @semantic.PlannedWasmFunctionTypeFragment,
) -> @lib.SubType {
  let parameters : Array[@lib.ValType] = []
  for index in 0..<function_type.parameters.length {
    parameters.push(
      starshine_value_type(
        planned.function_value_types[function_type.parameters.start + index],
      ),
    )
  }
  let results : Array[@lib.ValType] = []
  for index in 0..<function_type.results.length {
    results.push(
      starshine_value_type(
        planned.function_value_types[function_type.results.start + index],
      ),
    )
  }
  @lib.SubType::comp_type(@lib.CompType::func(parameters, results))
}

///|
fn starshine_plan_uses_text(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Bool {
  planned.uses_text_runtime
}

///|
fn starshine_text_runtime_base(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Int {
  planned.physical_types.length() + planned.signature_type_count
}

///|
fn starshine_text_runtime_types(base : Int) -> Array[@lib.RecType] {
  let array_index = @lib.TypeIdx::new(base.reinterpret_as_uint())
  let chunks = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::v128()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let chunk_reference = @lib.ValType::ref_type(
    @lib.RefType::new(false, @lib.HeapType::new(array_index)),
  )
  let text_fields = [
    @lib.FieldType::new(
      @lib.StorageType::val_type(chunk_reference),
      @lib.Mut::const_(),
    ),
    @lib.FieldType::new(
      @lib.StorageType::val_type(@lib.ValType::i32()),
      @lib.Mut::const_(),
    ),
    @lib.FieldType::new(
      @lib.StorageType::val_type(@lib.ValType::i32()),
      @lib.Mut::const_(),
    ),
  ]
  let builder_fields = [
    @lib.FieldType::new(
      @lib.StorageType::val_type(chunk_reference),
      @lib.Mut::var_(),
    ),
    @lib.FieldType::new(
      @lib.StorageType::val_type(@lib.ValType::i32()),
      @lib.Mut::var_(),
    ),
    @lib.FieldType::new(
      @lib.StorageType::val_type(@lib.ValType::i32()),
      @lib.Mut::var_(),
    ),
  ]
  [
    chunks,
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::struct_(text_fields)),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::struct_(text_fields)),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::struct_(text_fields)),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::struct_(builder_fields)),
    ),
    @lib.RecType::new(
      @lib.SubType::comp_type(@lib.CompType::struct_(builder_fields)),
    ),
  ]
}

///|
fn starshine_fixed_array_runtime_types() -> Array[@lib.RecType] {
  let storages = [
    @lib.StorageType::val_type(@lib.ValType::i32()),
    @lib.StorageType::val_type(@lib.ValType::i64()),
    @lib.StorageType::val_type(@lib.ValType::f32()),
    @lib.StorageType::val_type(@lib.ValType::f64()),
    @lib.StorageType::val_type(@lib.ValType::v128()),
    @lib.StorageType::val_type(@lib.ValType::eqref_null()),
    @lib.StorageType::pack_type(@lib.PackType::i8()),
    @lib.StorageType::pack_type(@lib.PackType::i16()),
  ]
  let types : Array[@lib.RecType] = []
  for storage in storages {
    types.push(
      @lib.RecType::new(
        @lib.SubType::comp_type(
          @lib.CompType::array(@lib.FieldType::new(storage, @lib.Mut::var_())),
        ),
      ),
    )
  }
  types
}

///|
fn starshine_fixed_array_runtime_base(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Int {
  starshine_text_runtime_base(planned) +
  (if planned.uses_text_runtime { 6 } else { 0 })
}

///|
fn starshine_map_runtime_types() -> Array[@lib.RecType] {
  let bucket_type = @lib.RecType::new(
    @lib.SubType::comp_type(
      @lib.CompType::array(
        @lib.FieldType::new(
          @lib.StorageType::val_type(@lib.ValType::eqref_null()),
          @lib.Mut::var_(),
        ),
      ),
    ),
  )
  let fields : Array[@lib.FieldType] = []
  let storages = [
    @lib.StorageType::val_type(@lib.ValType::eqref_null()),
    @lib.StorageType::val_type(@lib.ValType::i64()),
    @lib.StorageType::val_type(@lib.ValType::i32()),
    @lib.StorageType::val_type(@lib.ValType::i64()),
    @lib.StorageType::val_type(@lib.ValType::f32()),
    @lib.StorageType::val_type(@lib.ValType::f64()),
    @lib.StorageType::val_type(@lib.ValType::v128()),
    @lib.StorageType::val_type(@lib.ValType::eqref_null()),
    @lib.StorageType::val_type(@lib.ValType::i32()),
    @lib.StorageType::val_type(@lib.ValType::i64()),
    @lib.StorageType::val_type(@lib.ValType::f32()),
    @lib.StorageType::val_type(@lib.ValType::f64()),
    @lib.StorageType::val_type(@lib.ValType::v128()),
    @lib.StorageType::val_type(@lib.ValType::eqref_null()),
  ]
  for storage in storages {
    fields.push(@lib.FieldType::new(storage, @lib.Mut::var_()))
  }
  [
    bucket_type,
    @lib.RecType::new(@lib.SubType::comp_type(@lib.CompType::struct_(fields))),
  ]
}

///|
fn starshine_map_runtime_base(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Int {
  starshine_fixed_array_runtime_base(planned) +
  (if planned.uses_fixed_array_runtime { 8 } else { 0 })
}

///| Produces the exact Starshine type section described by the frozen Dew

///| WasmGC fragment plan. This function performs no dependency analysis and

///|
/// allocates no new semantic identities.
pub fn emit_starshine_type_section(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> @lib.TypeSec {
  let rec_types : Array[@lib.RecType] = []
  for group in planned.type_groups {
    let subtypes : Array[@lib.SubType] = []
    let mut has_recursive_reference = false
    for index in 0..<group.types.length {
      let (subtype, recursive) = starshine_physical_subtype(
        planned,
        planned.physical_types[group.types.start + index],
      )
      subtypes.push(subtype)
      has_recursive_reference = has_recursive_reference || recursive
    }
    if subtypes.length() == 1 && !has_recursive_reference {
      rec_types.push(@lib.RecType::new(subtypes[0]))
    } else {
      rec_types.push(@lib.RecType::group(subtypes))
    }
  }
  for function_type in planned.function_types {
    rec_types.push(
      @lib.RecType::new(starshine_function_type_subtype(planned, function_type)),
    )
  }
  for function_ in planned.functions {
    let mut canonical = false
    for function_type in planned.function_types {
      if function_type.signature_type_index == function_.signature_type_index {
        canonical = true
        break
      }
    }
    if function_.signature_type_index >= 0 && !canonical {
      rec_types.push(
        @lib.RecType::new(starshine_function_subtype(planned, function_)),
      )
    }
  }
  if starshine_plan_uses_text(planned) {
    for
      runtime_type in starshine_text_runtime_types(
        starshine_text_runtime_base(planned),
      ) {
      rec_types.push(runtime_type)
    }
  }
  if planned.uses_fixed_array_runtime {
    for runtime_type in starshine_fixed_array_runtime_types() {
      rec_types.push(runtime_type)
    }
  }
  if planned.uses_map_runtime {
    for runtime_type in starshine_map_runtime_types() {
      rec_types.push(runtime_type)
    }
  }
  @lib.TypeSec::new(rec_types)
}

///|
/// Validates the emitted type fragments with Starshine before function-body
/// emission begins.
pub fn validate_starshine_type_fragments(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> Result[Unit, @validate.ValidationError] {
  @validate.validate_module(
    @lib.Module::new().with_type_sec(emit_starshine_type_section(planned)),
  )
}

///|
/// Emits builtin declarations as imports from Dew's reserved runtime module.
/// Their order matches the imported function-index prefix frozen by semantic
/// planning.
pub fn emit_starshine_import_section(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> @lib.ImportSec {
  let imports : Array[@lib.Import] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmImportedFunction(identity) =>
        if !function_.elided {
          imports.push(
            @lib.Import::new(
              @lib.Name::from_string(@utf8.decode_lossy(identity.module_name)),
              @lib.Name::from_string(@utf8.decode_lossy(identity.field)),
              @lib.ExternType::func(
                @lib.TypeIdx::new(
                  function_.signature_type_index.reinterpret_as_uint(),
                ),
              ),
            ),
          )
        }
      @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  @lib.ImportSec::new(imports)
}

///|
/// Produces Starshine's function section for defined Dew functions. Imported
/// builtin functions and signature-only trait requirements do not occupy
/// entries in this section.
pub fn emit_starshine_function_section(
  planned : @semantic.PlannedModuleWasmGCFragments,
) -> @lib.FuncSec {
  let signatures : Array[@lib.TypeIdx] = []
  for function_ in planned.functions {
    match function_.kind {
      @semantic.PlannedWasmDefinedFunction(_)
      | @semantic.PlannedWasmDefinedLambdaFunction(_)
      | @semantic.PlannedWasmRuntimeFunction(_)
      | @semantic.PlannedWasmTraitAdapterFunction(_, _) =>
        if !function_.elided {
          signatures.push(
            @lib.TypeIdx::new(
              function_.signature_type_index.reinterpret_as_uint(),
            ),
          )
        }
      @semantic.PlannedWasmImportedFunction(_)
      | @semantic.PlannedWasmInlineBuiltinFunction(_)
      | @semantic.PlannedWasmSignatureOnlyFunction => ()
    }
  }
  @lib.FuncSec::new(signatures)
}
