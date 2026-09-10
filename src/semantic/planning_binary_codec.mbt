///|
/// Canonical binary payload schemas for module type layouts and WasmGC fragments.
let planned_type_layout_payload_version = 1U

///|
let planned_wasmgc_fragment_payload_version = 1U

///|
let planning_binary_maximum_items = 0x01000000

///|
let planning_binary_maximum_text = 0x01000000

///|
fn pb_write_visibility(
  writer : @cache_binary.Writer,
  value : SemanticVisibility,
) -> Unit {
  writer.write_byte(
    match value {
      ModuleVisible => 0
      Public => 1
    },
  )
}

///|
fn pb_read_visibility(
  reader : @cache_binary.Reader,
  field : String,
) -> SemanticVisibility {
  match reader.read_byte(field) {
    0 => ModuleVisible
    1 => Public
    _ => {
      reader.fail(field, "unknown visibility discriminant")
      ModuleVisible
    }
  }
}

///|
fn pb_write_int_array(
  writer : @cache_binary.Writer,
  values : Array[Int],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_int(writer, value)
  }
}

///|
fn pb_read_int_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[Int] {
  let count = reader.read_count(planning_binary_maximum_items, field)
  let values : Array[Int] = []
  for _ in 0..<count {
    values.push(ib_read_int(reader, field))
  }
  values
}

///|
fn pb_write_string_array(
  writer : @cache_binary.Writer,
  values : Array[String],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    writer.write_string(value)
  }
}

///|
fn pb_read_string_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[String] {
  let count = reader.read_count(planning_binary_maximum_items, field)
  let values : Array[String] = []
  for _ in 0..<count {
    values.push(reader.read_string(planning_binary_maximum_text, field))
  }
  values
}

///|
fn pb_write_shape_array(
  writer : @cache_binary.Writer,
  values : Array[PlannedValueShape],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_shape(writer, value)
  }
}

///|
fn pb_read_shape_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[PlannedValueShape] {
  let count = reader.read_count(planning_binary_maximum_items, field)
  let values : Array[PlannedValueShape] = []
  for _ in 0..<count {
    values.push(ib_read_shape(reader, field))
  }
  values
}

///|
fn pb_write_layout_kind(
  writer : @cache_binary.Writer,
  value : PlannedNominalLayoutKind,
) -> Unit {
  match value {
    PlannedStructLayout(fields) => {
      writer.write_byte(0)
      ib_write_span(writer, fields)
    }
    PlannedEnumLayout(variants) => {
      writer.write_byte(1)
      ib_write_span(writer, variants)
    }
    PlannedForeignTypeLayout => writer.write_byte(2)
  }
}

///|
fn pb_read_layout_kind(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedNominalLayoutKind {
  match reader.read_byte(field) {
    0 => PlannedStructLayout(ib_read_span(reader, field))
    1 => PlannedEnumLayout(ib_read_span(reader, field))
    2 => PlannedForeignTypeLayout
    _ => {
      reader.fail(field, "unknown nominal-layout discriminant")
      PlannedStructLayout({ start: 0, length: 0, })
    }
  }
}

///|
fn pb_write_variant_payload(
  writer : @cache_binary.Writer,
  value : PlannedVariantPayloadLayout,
) -> Unit {
  match value {
    PlannedUnitVariantLayout => writer.write_byte(0)
    PlannedTupleVariantLayout(types) => {
      writer.write_byte(1)
      ib_write_span(writer, types)
    }
    PlannedStructVariantLayout(fields) => {
      writer.write_byte(2)
      ib_write_span(writer, fields)
    }
  }
}

///|
fn pb_read_variant_payload(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedVariantPayloadLayout {
  match reader.read_byte(field) {
    0 => PlannedUnitVariantLayout
    1 => PlannedTupleVariantLayout(ib_read_span(reader, field))
    2 => PlannedStructVariantLayout(ib_read_span(reader, field))
    _ => {
      reader.fail(field, "unknown variant-layout discriminant")
      PlannedUnitVariantLayout
    }
  }
}

///|
fn pb_span_is_valid(span : HirSpan, length : Int) -> Bool {
  span.start >= 0 &&
  span.length >= 0 &&
  span.start + span.length >= span.start &&
  span.start + span.length <= length
}

///|
pub fn validate_planned_module_type_layouts(
  value : PlannedModuleTypeLayouts,
) -> Result[Unit, String] {
  for index in value.layout_by_declaration {
    if index < -1 || index >= value.layouts.length() {
      return Err("type-layout declaration lookup is out of range")
    }
  }
  for index, layout in value.layouts {
    if semantic_id_module(layout.declaration) != value.module_id {
      return Err("type-layout declaration belongs to another module")
    }
    let declaration = semantic_id_local(layout.declaration)
    if declaration < 0 ||
      declaration >= value.layout_by_declaration.length() ||
      value.layout_by_declaration[declaration] != index {
      return Err("type-layout declaration lookup is inconsistent")
    }
    match layout.kind {
      PlannedStructLayout(fields) =>
        if !pb_span_is_valid(fields, value.fields.length()) {
          return Err("type-layout field span is outside its arena")
        }
      PlannedEnumLayout(variants) =>
        if !pb_span_is_valid(variants, value.variants.length()) {
          return Err("type-layout variant span is outside its arena")
        }
      PlannedForeignTypeLayout => ()
    }
  }
  for index, field in value.fields {
    if semantic_id_module(field.field) != value.module_id ||
      semantic_id_local(field.field) != index ||
      semantic_id_module(field.declaration) != value.module_id ||
      field.index < 0 ||
      field.type_ < 0 {
      return Err("type-layout field record is invalid")
    }
    match field.variant {
      Some(variant) =>
        if semantic_id_module(variant) != value.module_id {
          return Err("type-layout field variant belongs to another module")
        }
      None => ()
    }
  }
  for index, variant in value.variants {
    if semantic_id_module(variant.variant) != value.module_id ||
      semantic_id_local(variant.variant) != index ||
      semantic_id_module(variant.declaration) != value.module_id ||
      variant.tag < 0 {
      return Err("type-layout variant record is invalid")
    }
    match variant.payload {
      PlannedUnitVariantLayout => ()
      PlannedTupleVariantLayout(types) =>
        if !pb_span_is_valid(types, value.payload_types.length()) ||
          !pb_span_is_valid(types, value.payload_shapes.length()) {
          return Err("type-layout tuple payload span is outside its arena")
        }
      PlannedStructVariantLayout(fields) =>
        if !pb_span_is_valid(fields, value.fields.length()) {
          return Err("type-layout struct payload span is outside its arena")
        }
    }
  }
  if value.payload_types.length() != value.payload_shapes.length() {
    return Err("type-layout payload arenas have different lengths")
  }
  Ok(())
}

///|
pub fn serialize_planned_module_type_layouts(
  value : PlannedModuleTypeLayouts,
) -> Result[Bytes, String] {
  match validate_planned_module_type_layouts(value) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let writer = @cache_binary.Writer::new()
  writer.write_u32_le(planned_type_layout_payload_version)
  ib_write_id(writer, value.module_id)
  writer.write_var_u64(value.layouts.length().to_uint64())
  for layout in value.layouts {
    ib_write_id(writer, layout.declaration)
    pb_write_visibility(writer, layout.visibility)
    ib_write_span(writer, layout.generic_parameters)
    writer.write_bool(layout.test_only)
    pb_write_layout_kind(writer, layout.kind)
    ib_write_id(writer, layout.offset)
  }
  pb_write_int_array(writer, value.layout_by_declaration)
  writer.write_var_u64(value.fields.length().to_uint64())
  for field in value.fields {
    ib_write_id(writer, field.field)
    ib_write_id(writer, field.declaration)
    match field.variant {
      Some(variant) => {
        writer.write_option_tag(true)
        ib_write_id(writer, variant)
      }
      None => writer.write_option_tag(false)
    }
    writer.write_bool(field.mutable_)
    writer.write_string(field.name)
    ib_write_int(writer, field.index)
    ib_write_int(writer, field.type_)
    ib_write_shape(writer, field.shape)
    ib_write_id(writer, field.offset)
  }
  writer.write_var_u64(value.variants.length().to_uint64())
  for variant in value.variants {
    ib_write_id(writer, variant.variant)
    ib_write_id(writer, variant.declaration)
    ib_write_int(writer, variant.tag)
    pb_write_variant_payload(writer, variant.payload)
    ib_write_id(writer, variant.offset)
  }
  pb_write_int_array(writer, value.payload_types)
  pb_write_shape_array(writer, value.payload_shapes)
  Ok(writer.to_bytes())
}

///|
pub fn deserialize_planned_module_type_layouts(
  bytes : Bytes,
) -> Result[PlannedModuleTypeLayouts, String] {
  let reader = @cache_binary.Reader::new(bytes, context="type-layout payload")
  if reader.read_u32_le("version") != planned_type_layout_payload_version {
    return Err("type-layout payload has unsupported version")
  }
  let module_id = ib_read_id(reader, "module_id")
  let layout_count = reader.read_count(planning_binary_maximum_items, "layouts")
  let layouts : Array[PlannedNominalLayout] = []
  for _ in 0..<layout_count {
    layouts.push({
      declaration: ib_read_id(reader, "layout.declaration"),
      visibility: pb_read_visibility(reader, "layout.visibility"),
      generic_parameters: ib_read_span(reader, "layout.generic_parameters"),
      test_only: reader.read_bool("layout.test_only"),
      kind: pb_read_layout_kind(reader, "layout.kind"),
      offset: ib_read_id(reader, "layout.offset"),
    })
  }
  let layout_by_declaration = pb_read_int_array(reader, "layout_by_declaration")
  let field_count = reader.read_count(planning_binary_maximum_items, "fields")
  let fields : Array[PlannedFieldLayout] = []
  for _ in 0..<field_count {
    let field = ib_read_id(reader, "field.field")
    let declaration = ib_read_id(reader, "field.declaration")
    let variant = if reader.read_option_tag("field.variant") {
      Some(ib_read_id(reader, "field.variant"))
    } else {
      None
    }
    fields.push({
      field,
      declaration,
      variant,
      mutable_: reader.read_bool("field.mutable"),
      name: reader.read_string(planning_binary_maximum_text, "field.name"),
      index: ib_read_int(reader, "field.index"),
      type_: ib_read_int(reader, "field.type"),
      shape: ib_read_shape(reader, "field.shape"),
      offset: ib_read_id(reader, "field.offset"),
    })
  }
  let variant_count = reader.read_count(
    planning_binary_maximum_items, "variants",
  )
  let variants : Array[PlannedVariantLayout] = []
  for _ in 0..<variant_count {
    variants.push({
      variant: ib_read_id(reader, "variant.variant"),
      declaration: ib_read_id(reader, "variant.declaration"),
      tag: ib_read_int(reader, "variant.tag"),
      payload: pb_read_variant_payload(reader, "variant.payload"),
      offset: ib_read_id(reader, "variant.offset"),
    })
  }
  let value : PlannedModuleTypeLayouts = {
    module_id,
    layouts,
    layout_by_declaration,
    fields,
    variants,
    payload_types: pb_read_int_array(reader, "payload_types"),
    payload_shapes: pb_read_shape_array(reader, "payload_shapes"),
  }
  match reader.finish() {
    Ok(_) => validate_planned_module_type_layouts(value).map(fn(_) { value })
    Err(error) => Err(error)
  }
}

///|
fn pb_write_type_reference(
  writer : @cache_binary.Writer,
  value : PlannedWasmTypeReference,
) -> Unit {
  match value {
    WasmModuleTypeReference(index) => {
      writer.write_byte(0)
      ib_write_int(writer, index)
    }
    WasmRecursiveTypeReference(index) => {
      writer.write_byte(1)
      ib_write_int(writer, index)
    }
  }
}

///|
fn pb_read_type_reference(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmTypeReference {
  match reader.read_byte(field) {
    0 => WasmModuleTypeReference(ib_read_int(reader, field))
    1 => WasmRecursiveTypeReference(ib_read_int(reader, field))
    _ => {
      reader.fail(field, "unknown Wasm type-reference discriminant")
      WasmModuleTypeReference(0)
    }
  }
}

///|
fn pb_write_storage_type(
  writer : @cache_binary.Writer,
  value : PlannedWasmStorageType,
) -> Unit {
  match value {
    WasmI8SignedStorage => writer.write_byte(0)
    WasmI8UnsignedStorage => writer.write_byte(1)
    WasmI16SignedStorage => writer.write_byte(2)
    WasmI16UnsignedStorage => writer.write_byte(3)
    WasmI32Storage => writer.write_byte(4)
    WasmI64Storage => writer.write_byte(5)
    WasmF32Storage => writer.write_byte(6)
    WasmF64Storage => writer.write_byte(7)
    WasmV128Storage => writer.write_byte(8)
    WasmStringRefStorage => writer.write_byte(9)
    WasmNullableEqRefStorage => writer.write_byte(10)
    WasmNullableFunctionRefStorage => writer.write_byte(11)
    WasmFunctionRefStorage(index) => {
      writer.write_byte(12)
      ib_write_int(writer, index)
    }
    WasmNominalRefStorage(reference) => {
      writer.write_byte(13)
      pb_write_type_reference(writer, reference)
    }
    WasmExternalNominalRefStorage(declaration) => {
      writer.write_byte(14)
      ib_write_id(writer, declaration)
    }
    WasmFixedArrayRefStorage(carrier) => {
      writer.write_byte(15)
      ib_write_int(writer, carrier)
    }
    WasmNullableNominalRefStorage(reference) => {
      writer.write_byte(16)
      pb_write_type_reference(writer, reference)
    }
    WasmNullableExternalNominalRefStorage(declaration) => {
      writer.write_byte(17)
      ib_write_id(writer, declaration)
    }
  }
}

///|
fn pb_read_storage_type(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmStorageType {
  match reader.read_byte(field) {
    0 => WasmI8SignedStorage
    1 => WasmI8UnsignedStorage
    2 => WasmI16SignedStorage
    3 => WasmI16UnsignedStorage
    4 => WasmI32Storage
    5 => WasmI64Storage
    6 => WasmF32Storage
    7 => WasmF64Storage
    8 => WasmV128Storage
    9 => WasmStringRefStorage
    10 => WasmNullableEqRefStorage
    11 => WasmNullableFunctionRefStorage
    12 => WasmFunctionRefStorage(ib_read_int(reader, field))
    13 => WasmNominalRefStorage(pb_read_type_reference(reader, field))
    14 => WasmExternalNominalRefStorage(ib_read_id(reader, field))
    15 => WasmFixedArrayRefStorage(ib_read_int(reader, field))
    16 => WasmNullableNominalRefStorage(pb_read_type_reference(reader, field))
    17 => WasmNullableExternalNominalRefStorage(ib_read_id(reader, field))
    _ => {
      reader.fail(field, "unknown Wasm storage discriminant")
      WasmI32Storage
    }
  }
}

///|
fn pb_write_field_role(
  writer : @cache_binary.Writer,
  value : PlannedWasmFieldRole,
) -> Unit {
  match value {
    WasmStructField(field) => {
      writer.write_byte(0)
      ib_write_id(writer, field)
    }
    WasmEnumTagField => writer.write_byte(1)
    WasmTuplePayloadField(variant, index) => {
      writer.write_byte(2)
      ib_write_id(writer, variant)
      ib_write_int(writer, index)
    }
    WasmStructPayloadField(field) => {
      writer.write_byte(3)
      ib_write_id(writer, field)
    }
    WasmClosureEntryField => writer.write_byte(4)
    WasmCaptureCellValueField(index) => {
      writer.write_byte(5)
      ib_write_int(writer, index)
    }
    WasmLambdaCaptureField(lambda, index) => {
      writer.write_byte(6)
      ib_write_int(writer, lambda)
      ib_write_int(writer, index)
    }
    WasmTraitObjectReceiverField(trait_) => {
      writer.write_byte(7)
      ib_write_id(writer, trait_)
    }
    WasmTraitObjectVTableField(trait_) => {
      writer.write_byte(8)
      ib_write_id(writer, trait_)
    }
    WasmTraitMethodField(trait_, requirement, slot) => {
      writer.write_byte(9)
      ib_write_id(writer, trait_)
      ib_write_id(writer, requirement)
      ib_write_int(writer, slot)
    }
  }
}

///|
fn pb_read_field_role(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmFieldRole {
  match reader.read_byte(field) {
    0 => WasmStructField(ib_read_id(reader, field))
    1 => WasmEnumTagField
    2 =>
      WasmTuplePayloadField(
        ib_read_id(reader, field),
        ib_read_int(reader, field),
      )
    3 => WasmStructPayloadField(ib_read_id(reader, field))
    4 => WasmClosureEntryField
    5 => WasmCaptureCellValueField(ib_read_int(reader, field))
    6 =>
      WasmLambdaCaptureField(
        ib_read_int(reader, field),
        ib_read_int(reader, field),
      )
    7 => WasmTraitObjectReceiverField(ib_read_id(reader, field))
    8 => WasmTraitObjectVTableField(ib_read_id(reader, field))
    9 =>
      WasmTraitMethodField(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
      )
    _ => {
      reader.fail(field, "unknown Wasm field-role discriminant")
      WasmEnumTagField
    }
  }
}

///|
fn pb_write_physical_kind(
  writer : @cache_binary.Writer,
  value : PlannedWasmPhysicalTypeKind,
) -> Unit {
  match value {
    PlannedWasmStructType(declaration) => {
      writer.write_byte(0)
      ib_write_id(writer, declaration)
    }
    PlannedWasmEnumBaseType(declaration) => {
      writer.write_byte(1)
      ib_write_id(writer, declaration)
    }
    PlannedWasmEnumSubtypeType(declaration, variant, index) => {
      writer.write_byte(2)
      ib_write_id(writer, declaration)
      ib_write_id(writer, variant)
      ib_write_int(writer, index)
    }
    PlannedWasmClosureType => writer.write_byte(3)
    PlannedWasmCaptureCellType(index) => {
      writer.write_byte(4)
      ib_write_int(writer, index)
    }
    PlannedWasmLambdaClosureType(lambda) => {
      writer.write_byte(5)
      ib_write_int(writer, lambda)
    }
    PlannedWasmTraitMethodSignatureType(requirement) => {
      writer.write_byte(6)
      ib_write_id(writer, requirement)
    }
    PlannedWasmTraitVTableType(trait_) => {
      writer.write_byte(7)
      ib_write_id(writer, trait_)
    }
    PlannedWasmTraitObjectType(trait_) => {
      writer.write_byte(8)
      ib_write_id(writer, trait_)
    }
    PlannedWasmForeignMarkerType(declaration) => {
      writer.write_byte(9)
      ib_write_id(writer, declaration)
    }
  }
}

///|
fn pb_read_physical_kind(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmPhysicalTypeKind {
  match reader.read_byte(field) {
    0 => PlannedWasmStructType(ib_read_id(reader, field))
    1 => PlannedWasmEnumBaseType(ib_read_id(reader, field))
    2 =>
      PlannedWasmEnumSubtypeType(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
        ib_read_int(reader, field),
      )
    3 => PlannedWasmClosureType
    4 => PlannedWasmCaptureCellType(ib_read_int(reader, field))
    5 => PlannedWasmLambdaClosureType(ib_read_int(reader, field))
    6 => PlannedWasmTraitMethodSignatureType(ib_read_id(reader, field))
    7 => PlannedWasmTraitVTableType(ib_read_id(reader, field))
    8 => PlannedWasmTraitObjectType(ib_read_id(reader, field))
    9 => PlannedWasmForeignMarkerType(ib_read_id(reader, field))
    _ => {
      reader.fail(field, "unknown Wasm physical-type discriminant")
      PlannedWasmClosureType
    }
  }
}

///|
fn pb_write_value_type(
  writer : @cache_binary.Writer,
  value : PlannedWasmValueType,
) -> Unit {
  match value {
    WasmI32Value => writer.write_byte(0)
    WasmI64Value => writer.write_byte(1)
    WasmF32Value => writer.write_byte(2)
    WasmF64Value => writer.write_byte(3)
    WasmV128Value => writer.write_byte(4)
    WasmStringRefValue => writer.write_byte(5)
    WasmNullableEqRefValue => writer.write_byte(6)
    WasmFunctionRefValue(index) => {
      writer.write_byte(7)
      ib_write_int(writer, index)
    }
    WasmNominalRefValue(index) => {
      writer.write_byte(8)
      ib_write_int(writer, index)
    }
    WasmExternalNominalRefValue(declaration) => {
      writer.write_byte(9)
      ib_write_id(writer, declaration)
    }
    WasmFixedArrayRefValue(carrier) => {
      writer.write_byte(10)
      ib_write_int(writer, carrier)
    }
    WasmNullableNominalRefValue(index) => {
      writer.write_byte(11)
      ib_write_int(writer, index)
    }
    WasmNullableExternalNominalRefValue(declaration) => {
      writer.write_byte(12)
      ib_write_id(writer, declaration)
    }
  }
}

///|
fn pb_read_value_type(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmValueType {
  match reader.read_byte(field) {
    0 => WasmI32Value
    1 => WasmI64Value
    2 => WasmF32Value
    3 => WasmF64Value
    4 => WasmV128Value
    5 => WasmStringRefValue
    6 => WasmNullableEqRefValue
    7 => WasmFunctionRefValue(ib_read_int(reader, field))
    8 => WasmNominalRefValue(ib_read_int(reader, field))
    9 => WasmExternalNominalRefValue(ib_read_id(reader, field))
    10 => WasmFixedArrayRefValue(ib_read_int(reader, field))
    11 => WasmNullableNominalRefValue(ib_read_int(reader, field))
    12 => WasmNullableExternalNominalRefValue(ib_read_id(reader, field))
    _ => {
      reader.fail(field, "unknown Wasm value-type discriminant")
      WasmI32Value
    }
  }
}

///|
fn pb_write_import_identity(
  writer : @cache_binary.Writer,
  value : WasmImportIdentity,
) -> Unit {
  writer.write_bytes(value.module_name)
  writer.write_bytes(value.field)
  writer.write_byte(
    match value.kind {
      HostWasmImport => 0
      StaticLinkWasmImport => 1
      WasiWasmImport => 2
      ForeignHostWasmImport => 3
    },
  )
}

///|
fn pb_read_import_identity(
  reader : @cache_binary.Reader,
  field : String,
) -> WasmImportIdentity {
  let module_name = reader.read_bytes(planning_binary_maximum_text, field)
  let import_field = reader.read_bytes(planning_binary_maximum_text, field)
  let kind = match reader.read_byte(field) {
    0 => HostWasmImport
    1 => StaticLinkWasmImport
    2 => WasiWasmImport
    3 => ForeignHostWasmImport
    _ => {
      reader.fail(field, "unknown Wasm import-kind discriminant")
      HostWasmImport
    }
  }
  { module_name, field: import_field, kind, }
}

///|
fn pb_write_function_kind(
  writer : @cache_binary.Writer,
  value : PlannedWasmFunctionKind,
) -> Unit {
  match value {
    PlannedWasmImportedFunction(identity) => {
      writer.write_byte(0)
      pb_write_import_identity(writer, identity)
    }
    PlannedWasmInlineBuiltinFunction(name) => {
      writer.write_byte(1)
      writer.write_bytes(name)
    }
    PlannedWasmErasedAdapterFunction => writer.write_byte(10)
    PlannedWasmDefinedFunction(body) => {
      writer.write_byte(3)
      ib_write_id(writer, body)
    }
    PlannedWasmDefinedLambdaFunction(lambda) => {
      writer.write_byte(4)
      ib_write_int(writer, lambda)
    }
    PlannedWasmTraitAdapterFunction(implementation, requirement) => {
      writer.write_byte(5)
      ib_write_id(writer, implementation)
      ib_write_id(writer, requirement)
    }
    PlannedWasmSignatureOnlyFunction => writer.write_byte(6)
    PlannedWasmOutlinedBuiltinFunction(name) => {
      writer.write_byte(7)
      writer.write_bytes(name)
    }
    PlannedWasmInlineHeapFunction(recipe) => {
      writer.write_byte(8)
      pb_write_raw_heap_instruction(writer, recipe)
    }
    PlannedWasmOutlinedHeapFunction(recipe) => {
      writer.write_byte(9)
      pb_write_raw_heap_instruction(writer, recipe)
    }
  }
}

///|
fn pb_read_function_kind(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedWasmFunctionKind {
  match reader.read_byte(field) {
    0 => PlannedWasmImportedFunction(pb_read_import_identity(reader, field))
    1 =>
      PlannedWasmInlineBuiltinFunction(
        reader.read_bytes(planning_binary_maximum_text, field),
      )
    3 => PlannedWasmDefinedFunction(ib_read_id(reader, field))
    4 => PlannedWasmDefinedLambdaFunction(ib_read_int(reader, field))
    5 =>
      PlannedWasmTraitAdapterFunction(
        ib_read_id(reader, field),
        ib_read_id(reader, field),
      )
    6 => PlannedWasmSignatureOnlyFunction
    7 =>
      PlannedWasmOutlinedBuiltinFunction(
        reader.read_bytes(planning_binary_maximum_text, field),
      )
    8 =>
      PlannedWasmInlineHeapFunction(pb_read_raw_heap_instruction(reader, field))
    9 =>
      PlannedWasmOutlinedHeapFunction(
        pb_read_raw_heap_instruction(reader, field),
      )
    10 => PlannedWasmErasedAdapterFunction
    _ => {
      reader.fail(field, "unknown Wasm function-kind discriminant")
      PlannedWasmSignatureOnlyFunction
    }
  }
}

///|
fn pb_write_specialization_evidence(
  writer : @cache_binary.Writer,
  value : PlannedSpecializationTraitEvidence,
) -> Unit {
  match value.kind {
    PlannedConcreteTraitEvidence(implementation, arguments) => {
      writer.write_byte(0)
      ib_write_id(writer, implementation)
      ib_write_span(writer, arguments)
    }
    PlannedRuntimeTraitEvidence(trait_, parameter) => {
      writer.write_byte(1)
      ib_write_id(writer, trait_)
      ib_write_int(writer, parameter)
    }
  }
  ib_write_span(writer, value.prerequisites)
}

///|
fn pb_read_specialization_evidence(
  reader : @cache_binary.Reader,
  field : String,
) -> PlannedSpecializationTraitEvidence {
  let kind = match reader.read_byte(field) {
    0 =>
      PlannedConcreteTraitEvidence(
        ib_read_id(reader, field),
        ib_read_span(reader, field),
      )
    1 =>
      PlannedRuntimeTraitEvidence(
        ib_read_id(reader, field),
        ib_read_int(reader, field),
      )
    _ => {
      reader.fail(field, "unknown specialization-evidence discriminant")
      PlannedRuntimeTraitEvidence(0UL, -1)
    }
  }
  { kind, prerequisites: ib_read_span(reader, field), }
}

///|
fn pb_write_span_array(
  writer : @cache_binary.Writer,
  values : Array[HirSpan],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    ib_write_span(writer, value)
  }
}

///|
fn pb_read_span_array(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[HirSpan] {
  let count = reader.read_count(planning_binary_maximum_items, field)
  let values : Array[HirSpan] = []
  for _ in 0..<count {
    values.push(ib_read_span(reader, field))
  }
  values
}

///|
fn pb_rebuild_imported_function_indices(
  functions : Array[PlannedWasmFunctionFragment],
) -> Map[Bytes, Int] {
  let imported : Map[Bytes, Int] = Map::default()
  for function_ in functions {
    if function_.elided || function_.function_index < 0 {
      continue
    }
    match function_.kind {
      PlannedWasmImportedFunction(identity) =>
        imported[identity.lookup_name()] = function_.function_index
      _ => ()
    }
  }
  imported
}

///|
pub fn validate_cached_module_wasmgc_fragments(
  value : PlannedModuleWasmGCFragments,
  expected_module_id : ModuleId,
  options : WasmGCPlanningOptions,
) -> Result[Unit, String] {
  if value.module_id != expected_module_id {
    return Err("cached WasmGC fragment module identity mismatch")
  }
  if value.dense_enum_dispatch != options.dense_enum_dispatch ||
    value.emit_tests != options.emit_tests {
    return Err("cached WasmGC fragment planning mode mismatch")
  }
  if value.specialization_shapes.length() != 0 ||
    value.specialized_lambda_layouts.length() != 0 ||
    value.specialization_evidence_roots.length() != 0 ||
    value.specialization_trait_evidence.length() != 0 ||
    value.specialization_evidence_children.length() != 0 ||
    value.specialization_evidence_arguments.length() != 0 {
    return Err("cached WasmGC fragment contains program specializations")
  }
  for function_ in value.functions {
    if function_.kind is PlannedWasmErasedAdapterFunction {
      return Err("cached WasmGC fragment contains a program-only erased adapter")
    }
    if function_.specialization_shapes.length != 0 ||
      function_.specialization_evidence.length != 0 ||
      function_.specialization_abi_key != "" {
      return Err("cached WasmGC function contains a program specialization")
    }
  }
  validate_module_wasmgc_arenas(value)
}

///|
pub fn serialize_planned_module_wasmgc_fragments(
  value : PlannedModuleWasmGCFragments,
) -> Result[Bytes, String] {
  match validate_module_wasmgc_arenas(value) {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  let writer = @cache_binary.Writer::new()
  writer.write_u32_le(planned_wasmgc_fragment_payload_version)
  ib_write_id(writer, value.module_id)
  writer.write_bool(value.dense_enum_dispatch)
  writer.write_bool(value.emit_tests)
  writer.write_var_u64(value.type_groups.length().to_uint64())
  for group in value.type_groups {
    ib_write_span(writer, group.types)
    ib_write_int(writer, group.first_type_index)
  }
  writer.write_var_u64(value.physical_types.length().to_uint64())
  for physical in value.physical_types {
    pb_write_physical_kind(writer, physical.kind)
    ib_write_int(writer, physical.type_index)
    ib_write_int(writer, physical.group_index)
    ib_write_span(writer, physical.fields)
    ib_write_id(writer, physical.offset)
  }
  writer.write_var_u64(value.fields.length().to_uint64())
  for field in value.fields {
    pb_write_field_role(writer, field.role)
    ib_write_int(writer, field.physical_index)
    pb_write_storage_type(writer, field.storage)
    writer.write_bool(field.mutable_)
    ib_write_id(writer, field.offset)
  }
  pb_write_int_array(writer, value.type_index_by_declaration)
  pb_write_int_array(writer, value.payload_type_index_by_variant)
  writer.write_var_u64(value.variant_declarations.length().to_uint64())
  for declaration in value.variant_declarations {
    ib_write_id(writer, declaration)
  }
  pb_write_int_array(writer, value.variant_tags)
  pb_write_span_array(writer, value.variant_field_spans)
  writer.write_var_u64(value.variant_fields.length().to_uint64())
  for field in value.variant_fields {
    pb_write_field_role(writer, field.role)
    ib_write_int(writer, field.physical_index)
    pb_write_storage_type(writer, field.storage)
  }
  pb_write_string_array(writer, value.field_names)
  ib_write_int(writer, value.closure_type_index)
  pb_write_int_array(writer, value.capture_cell_type_indices)
  pb_write_int_array(writer, value.lambda_closure_type_indices)
  pb_write_int_array(writer, value.lambda_capture_field_indices)
  writer.write_var_u64(value.function_types.length().to_uint64())
  for function_type in value.function_types {
    ib_write_int(writer, function_type.resolved_type)
    ib_write_int(writer, function_type.signature_type_index)
    ib_write_span(writer, function_type.parameters)
    ib_write_span(writer, function_type.results)
  }
  pb_write_int_array(writer, value.function_type_by_resolved)
  pb_write_int_array(writer, value.closure_entry_type_by_resolved)
  pb_write_int_array(writer, value.erased_closure_direct_type_by_resolved)
  pb_write_int_array(writer, value.erased_closure_entry_type_by_resolved)
  pb_write_int_array(writer, value.lambda_entry_signature_indices)
  pb_write_int_array(writer, value.lambda_capture_parameter_indices)
  let layout_keys = []
  for key, _ in value.specialized_lambda_layouts {
    layout_keys.push(key)
  }
  layout_keys.sort()
  writer.write_var_u64(layout_keys.length().to_uint64())
  for key in layout_keys {
    let layout = value.specialized_lambda_layouts[key]
    writer.write_string(key)
    pb_write_int_array(writer, layout.closure_types)
    pb_write_int_array(writer, layout.capture_fields)
    pb_write_int_array(writer, layout.capture_parameters)
  }
  writer.write_var_u64(value.trait_layouts.length().to_uint64())
  for layout in value.trait_layouts {
    ib_write_id(writer, layout.trait_declaration)
    ib_write_int(writer, layout.vtable_type_index)
    ib_write_int(writer, layout.object_type_index)
    ib_write_span(writer, layout.methods)
  }
  writer.write_var_u64(value.trait_layout_methods.length().to_uint64())
  for requirement in value.trait_layout_methods {
    ib_write_id(writer, requirement)
  }
  pb_write_int_array(writer, value.trait_method_signature_indices)
  writer.write_var_u64(value.trait_dictionaries.length().to_uint64())
  for dictionary in value.trait_dictionaries {
    ib_write_id(writer, dictionary.trait_declaration)
    ib_write_id(writer, dictionary.implementation)
    ib_write_int(writer, dictionary.evidence)
    writer.write_string(dictionary.evidence_key)
    ib_write_int(writer, dictionary.vtable_type_index)
    ib_write_int(writer, dictionary.object_type_index)
    ib_write_span(writer, dictionary.methods)
    ib_write_span(writer, dictionary.runtime_evidence_parameters)
    writer.write_bool(dictionary.runtime_materialized)
  }
  pb_write_int_array(writer, value.trait_dictionary_runtime_evidence_parameters)
  writer.write_var_u64(value.trait_methods.length().to_uint64())
  for trait_method in value.trait_methods {
    ib_write_id(writer, trait_method.trait_declaration)
    ib_write_id(writer, trait_method.requirement)
    ib_write_id(writer, trait_method.implementation_method)
    ib_write_shape(writer, trait_method.receiver_shape)
    ib_write_id(writer, trait_method.receiver_nominal)
    writer.write_string(trait_method.implementation_specialization_abi_key)
    ib_write_int(writer, trait_method.slot)
    ib_write_int(writer, trait_method.signature_type_index)
    ib_write_int(writer, trait_method.adapter_function)
  }
  writer.write_var_u64(value.functions.length().to_uint64())
  for function_ in value.functions {
    ib_write_id(writer, function_.declaration)
    ib_write_int(writer, function_.lambda)
    writer.write_bytes(function_.name)
    pb_write_visibility(writer, function_.visibility)
    writer.write_bool(function_.is_test)
    writer.write_bool(function_.is_test_entry)
    writer.write_bytes(function_.test_name)
    pb_write_function_kind(writer, function_.kind)
    writer.write_bytes(function_.direct_builtin)
    writer.write_bool(function_.elided)
    ib_write_int(writer, function_.signature_type_index)
    ib_write_int(writer, function_.function_index)
    ib_write_span(writer, function_.parameters)
    ib_write_span(writer, function_.results)
    ib_write_span(writer, function_.specialization_shapes)
    ib_write_span(writer, function_.specialization_evidence)
    writer.write_string(function_.specialization_abi_key)
    ib_write_id(writer, function_.offset)
  }
  pb_write_int_array(writer, value.function_by_declaration)
  pb_write_int_array(writer, value.lambda_function_indices)
  writer.write_var_u64(value.function_value_types.length().to_uint64())
  for type_ in value.function_value_types {
    pb_write_value_type(writer, type_)
  }
  pb_write_shape_array(writer, value.specialization_shapes)
  pb_write_int_array(writer, value.specialization_evidence_roots)
  writer.write_var_u64(value.specialization_trait_evidence.length().to_uint64())
  for evidence in value.specialization_trait_evidence {
    pb_write_specialization_evidence(writer, evidence)
  }
  pb_write_int_array(writer, value.specialization_evidence_children)
  pb_write_shape_array(writer, value.specialization_evidence_arguments)
  ib_write_int(writer, value.signature_type_count)
  ib_write_int(writer, value.imported_function_count)
  ib_write_int(writer, value.defined_function_count)
  writer.write_bool(value.uses_text_runtime)
  writer.write_bool(value.uses_fixed_array_runtime)
  writer.write_bool(value.uses_linear_memory)
  Ok(writer.to_bytes())
}

///|
pub fn deserialize_planned_module_wasmgc_fragments(
  bytes : Bytes,
) -> Result[PlannedModuleWasmGCFragments, String] {
  let reader = @cache_binary.Reader::new(
    bytes,
    context="WasmGC fragment payload",
  )
  if reader.read_u32_le("version") != planned_wasmgc_fragment_payload_version {
    return Err("WasmGC fragment payload has unsupported version")
  }
  let module_id = ib_read_id(reader, "module_id")
  let dense_enum_dispatch = reader.read_bool("dense_enum_dispatch")
  let emit_tests = reader.read_bool("emit_tests")
  let type_group_count = reader.read_count(
    planning_binary_maximum_items, "type_groups",
  )
  let type_groups : Array[PlannedWasmRecursiveGroup] = []
  for _ in 0..<type_group_count {
    type_groups.push({
      types: ib_read_span(reader, "type_group.types"),
      first_type_index: ib_read_int(reader, "type_group.first_type_index"),
    })
  }
  let physical_count = reader.read_count(
    planning_binary_maximum_items, "physical_types",
  )
  let physical_types : Array[PlannedWasmPhysicalType] = []
  for _ in 0..<physical_count {
    physical_types.push({
      kind: pb_read_physical_kind(reader, "physical.kind"),
      type_index: ib_read_int(reader, "physical.type_index"),
      group_index: ib_read_int(reader, "physical.group_index"),
      fields: ib_read_span(reader, "physical.fields"),
      offset: ib_read_id(reader, "physical.offset"),
    })
  }
  let field_count = reader.read_count(planning_binary_maximum_items, "fields")
  let fields : Array[PlannedWasmField] = []
  for _ in 0..<field_count {
    fields.push({
      role: pb_read_field_role(reader, "field.role"),
      physical_index: ib_read_int(reader, "field.physical_index"),
      storage: pb_read_storage_type(reader, "field.storage"),
      mutable_: reader.read_bool("field.mutable"),
      offset: ib_read_id(reader, "field.offset"),
    })
  }
  let type_index_by_declaration = pb_read_int_array(
    reader, "type_index_by_declaration",
  )
  let payload_type_index_by_variant = pb_read_int_array(
    reader, "payload_type_index_by_variant",
  )
  let variant_declaration_count = reader.read_count(
    planning_binary_maximum_items, "variant_declarations",
  )
  let variant_declarations : Array[DeclId] = []
  for _ in 0..<variant_declaration_count {
    variant_declarations.push(ib_read_id(reader, "variant_declaration"))
  }
  let variant_tags = pb_read_int_array(reader, "variant_tags")
  let variant_field_spans = pb_read_span_array(reader, "variant_field_spans")
  let variant_field_count = reader.read_count(
    planning_binary_maximum_items, "variant_fields",
  )
  let variant_fields : Array[PlannedWasmVariantField] = []
  for _ in 0..<variant_field_count {
    variant_fields.push({
      role: pb_read_field_role(reader, "variant_field.role"),
      physical_index: ib_read_int(reader, "variant_field.physical_index"),
      storage: pb_read_storage_type(reader, "variant_field.storage"),
    })
  }
  let field_names = pb_read_string_array(reader, "field_names")
  let closure_type_index = ib_read_int(reader, "closure_type_index")
  let capture_cell_type_indices = pb_read_int_array(
    reader, "capture_cell_type_indices",
  )
  let lambda_closure_type_indices = pb_read_int_array(
    reader, "lambda_closure_type_indices",
  )
  let lambda_capture_field_indices = pb_read_int_array(
    reader, "lambda_capture_field_indices",
  )
  let function_type_count = reader.read_count(
    planning_binary_maximum_items, "function_types",
  )
  let function_types : Array[PlannedWasmFunctionTypeFragment] = []
  for _ in 0..<function_type_count {
    function_types.push({
      resolved_type: ib_read_int(reader, "function_type.resolved_type"),
      signature_type_index: ib_read_int(
        reader, "function_type.signature_type_index",
      ),
      parameters: ib_read_span(reader, "function_type.parameters"),
      results: ib_read_span(reader, "function_type.results"),
    })
  }
  let function_type_by_resolved = pb_read_int_array(
    reader, "function_type_by_resolved",
  )
  let closure_entry_type_by_resolved = pb_read_int_array(
    reader, "closure_entry_type_by_resolved",
  )
  let erased_closure_direct_type_by_resolved = pb_read_int_array(
    reader, "erased_closure_direct_type_by_resolved",
  )
  let erased_closure_entry_type_by_resolved = pb_read_int_array(
    reader, "erased_closure_entry_type_by_resolved",
  )
  let lambda_entry_signature_indices = pb_read_int_array(
    reader, "lambda_entry_signature_indices",
  )
  let lambda_capture_parameter_indices = pb_read_int_array(
    reader, "lambda_capture_parameter_indices",
  )
  let layout_count = reader.read_count(
    planning_binary_maximum_items, "specialized_lambda_layouts",
  )
  let specialized_lambda_layouts : Map[String, CompileTimeLambdaLayout] = {}
  for _ in 0..<layout_count {
    let key = reader.read_string(
      planning_binary_maximum_text, "lambda_layout.key",
    )
    if specialized_lambda_layouts.contains(key) {
      reader.fail("lambda_layout.key", "duplicate logical instance")
    }
    specialized_lambda_layouts[key] = {
      closure_types: pb_read_int_array(reader, "lambda_layout.closure_types"),
      capture_fields: pb_read_int_array(reader, "lambda_layout.capture_fields"),
      capture_parameters: pb_read_int_array(
        reader, "lambda_layout.capture_parameters",
      ),
    }
  }
  let trait_layout_count = reader.read_count(
    planning_binary_maximum_items, "trait_layouts",
  )
  let trait_layouts : Array[PlannedWasmTraitLayout] = []
  for _ in 0..<trait_layout_count {
    trait_layouts.push({
      trait_declaration: ib_read_id(reader, "trait_layout.declaration"),
      vtable_type_index: ib_read_int(reader, "trait_layout.vtable_type_index"),
      object_type_index: ib_read_int(reader, "trait_layout.object_type_index"),
      methods: ib_read_span(reader, "trait_layout.methods"),
    })
  }
  let trait_layout_method_count = reader.read_count(
    planning_binary_maximum_items, "trait_layout_methods",
  )
  let trait_layout_methods : Array[DeclId] = []
  for _ in 0..<trait_layout_method_count {
    trait_layout_methods.push(ib_read_id(reader, "trait_layout_method"))
  }
  let trait_method_signature_indices = pb_read_int_array(
    reader, "trait_method_signature_indices",
  )
  let dictionary_count = reader.read_count(
    planning_binary_maximum_items, "trait_dictionaries",
  )
  let trait_dictionaries : Array[PlannedWasmTraitDictionary] = []
  for _ in 0..<dictionary_count {
    trait_dictionaries.push({
      trait_declaration: ib_read_id(reader, "dictionary.trait"),
      implementation: ib_read_id(reader, "dictionary.implementation"),
      evidence: ib_read_int(reader, "dictionary.evidence"),
      evidence_key: reader.read_string(
        planning_binary_maximum_text, "dictionary.evidence_key",
      ),
      vtable_type_index: ib_read_int(reader, "dictionary.vtable_type_index"),
      object_type_index: ib_read_int(reader, "dictionary.object_type_index"),
      methods: ib_read_span(reader, "dictionary.methods"),
      runtime_evidence_parameters: ib_read_span(
        reader, "dictionary.runtime_evidence_parameters",
      ),
      runtime_materialized: reader.read_bool("dictionary.runtime_materialized"),
    })
  }
  let trait_dictionary_runtime_evidence_parameters = pb_read_int_array(
    reader, "trait_dictionary_runtime_evidence_parameters",
  )
  let trait_method_count = reader.read_count(
    planning_binary_maximum_items, "trait_methods",
  )
  let trait_methods : Array[PlannedWasmTraitMethod] = []
  for _ in 0..<trait_method_count {
    trait_methods.push({
      trait_declaration: ib_read_id(reader, "trait_method.trait"),
      requirement: ib_read_id(reader, "trait_method.requirement"),
      implementation_method: ib_read_id(
        reader, "trait_method.implementation_method",
      ),
      receiver_shape: ib_read_shape(reader, "trait_method.receiver_shape"),
      receiver_nominal: ib_read_id(reader, "trait_method.receiver_nominal"),
      implementation_specialization_abi_key: reader.read_string(
        planning_binary_maximum_text, "trait_method.specialization_key",
      ),
      slot: ib_read_int(reader, "trait_method.slot"),
      signature_type_index: ib_read_int(
        reader, "trait_method.signature_type_index",
      ),
      adapter_function: ib_read_int(reader, "trait_method.adapter_function"),
    })
  }
  let function_count = reader.read_count(
    planning_binary_maximum_items, "functions",
  )
  let functions : Array[PlannedWasmFunctionFragment] = []
  for _ in 0..<function_count {
    functions.push({
      declaration: ib_read_id(reader, "function.declaration"),
      lambda: ib_read_int(reader, "function.lambda"),
      name: reader.read_bytes(planning_binary_maximum_text, "function.name"),
      visibility: pb_read_visibility(reader, "function.visibility"),
      is_test: reader.read_bool("function.is_test"),
      is_test_entry: reader.read_bool("function.is_test_entry"),
      test_name: reader.read_bytes(
        planning_binary_maximum_text, "function.test_name",
      ),
      kind: pb_read_function_kind(reader, "function.kind"),
      direct_builtin: reader.read_bytes(
        planning_binary_maximum_text, "function.direct_builtin",
      ),
      elided: reader.read_bool("function.elided"),
      signature_type_index: ib_read_int(reader, "function.signature_type_index"),
      function_index: ib_read_int(reader, "function.function_index"),
      parameters: ib_read_span(reader, "function.parameters"),
      results: ib_read_span(reader, "function.results"),
      specialization_shapes: ib_read_span(
        reader, "function.specialization_shapes",
      ),
      specialization_evidence: ib_read_span(
        reader, "function.specialization_evidence",
      ),
      specialization_abi_key: reader.read_string(
        planning_binary_maximum_text, "function.specialization_abi_key",
      ),
      offset: ib_read_id(reader, "function.offset"),
    })
  }
  let function_by_declaration = pb_read_int_array(
    reader, "function_by_declaration",
  )
  let lambda_function_indices = pb_read_int_array(
    reader, "lambda_function_indices",
  )
  let function_value_type_count = reader.read_count(
    planning_binary_maximum_items, "function_value_types",
  )
  let function_value_types : Array[PlannedWasmValueType] = []
  for _ in 0..<function_value_type_count {
    function_value_types.push(pb_read_value_type(reader, "function_value_type"))
  }
  let specialization_shapes = pb_read_shape_array(
    reader, "specialization_shapes",
  )
  let specialization_evidence_roots = pb_read_int_array(
    reader, "specialization_evidence_roots",
  )
  let specialization_evidence_count = reader.read_count(
    planning_binary_maximum_items, "specialization_trait_evidence",
  )
  let specialization_trait_evidence : Array[PlannedSpecializationTraitEvidence] = []
  for _ in 0..<specialization_evidence_count {
    specialization_trait_evidence.push(
      pb_read_specialization_evidence(reader, "specialization_trait_evidence"),
    )
  }
  let specialization_evidence_children = pb_read_int_array(
    reader, "specialization_evidence_children",
  )
  let specialization_evidence_arguments = pb_read_shape_array(
    reader, "specialization_evidence_arguments",
  )
  let signature_type_count = ib_read_int(reader, "signature_type_count")
  let imported_function_count = ib_read_int(reader, "imported_function_count")
  let defined_function_count = ib_read_int(reader, "defined_function_count")
  let uses_text_runtime = reader.read_bool("uses_text_runtime")
  let uses_fixed_array_runtime = reader.read_bool("uses_fixed_array_runtime")
  let uses_linear_memory = reader.read_bool("uses_linear_memory")
  match reader.finish() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let imported_function_indices = pb_rebuild_imported_function_indices(
    functions,
  )
  let value : PlannedModuleWasmGCFragments = {
    module_id,
    dense_enum_dispatch,
    emit_tests,
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
    specialized_lambda_layouts,
    trait_layouts,
    trait_layout_methods,
    trait_method_signature_indices,
    trait_dictionaries,
    trait_dictionary_runtime_evidence_parameters,
    trait_methods,
    functions,
    function_by_declaration,
    lambda_function_indices,
    function_value_types,
    specialization_shapes,
    specialization_evidence_roots,
    specialization_trait_evidence,
    specialization_evidence_children,
    specialization_evidence_arguments,
    signature_type_count,
    imported_function_count,
    defined_function_count,
    imported_function_indices,
    uses_text_runtime,
    uses_fixed_array_runtime,
    uses_linear_memory,
  }
  match validate_module_wasmgc_arenas(value) {
    Ok(_) => Ok(value)
    Err(error) => Err(error)
  }
}
