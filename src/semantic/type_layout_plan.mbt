///|
pub enum PlannedNominalLayoutKind {
  PlannedStructLayout(HirSpan)
  PlannedEnumLayout(HirSpan)
  PlannedForeignTypeLayout
} derive(Eq, Debug)

///|
pub struct PlannedNominalLayout {
  declaration : DeclId
  visibility : SemanticVisibility
  generic_parameters : HirSpan
  test_only : Bool
  kind : PlannedNominalLayoutKind
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedFieldLayout {
  field : FieldId
  declaration : DeclId
  variant : VariantId?
  mutable_ : Bool
  name : String
  index : Int
  type_ : ResolvedTypeId
  shape : PlannedValueShape
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum PlannedVariantPayloadLayout {
  PlannedUnitVariantLayout
  PlannedTupleVariantLayout(HirSpan)
  PlannedStructVariantLayout(HirSpan)
} derive(Eq, Debug)

///|
pub struct PlannedVariantLayout {
  variant : VariantId
  declaration : DeclId
  tag : Int
  payload : PlannedVariantPayloadLayout
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct PlannedModuleTypeLayouts {
  module_id : ModuleId
  layouts : Array[PlannedNominalLayout]
  layout_by_declaration : Array[Int]
  fields : Array[PlannedFieldLayout]
  variants : Array[PlannedVariantLayout]
  payload_types : Array[ResolvedTypeId]
  payload_shapes : Array[PlannedValueShape]
} derive(Eq, Debug)

///|
pub fn PlannedModuleTypeLayouts::layout_of(
  self : PlannedModuleTypeLayouts,
  declaration : DeclId,
) -> PlannedNominalLayout? {
  if semantic_id_module(declaration) != self.module_id {
    return None
  }
  let declaration_index = semantic_id_local(declaration)
  if declaration_index < 0 ||
    declaration_index >= self.layout_by_declaration.length() {
    return None
  }
  let layout = self.layout_by_declaration[declaration_index]
  if layout < 0 {
    None
  } else {
    Some(self.layouts[layout])
  }
}

///|
fn layout_variant_field_spans(collected : CollectedModule) -> Array[HirSpan] {
  let spans = Array::make(collected.variants.length(), { start: 0, length: 0, })
  for index, field in collected.fields {
    match field.variant {
      Some(variant) => {
        let variant_index = semantic_id_local(variant)
        let current = spans[variant_index]
        if current.length == 0 {
          spans[variant_index] = { start: index, length: 1, }
        } else {
          if current.start + current.length != index {
            abort("variant fields are not contiguous")
          }
          spans[variant_index] = {
            start: current.start,
            length: current.length + 1,
          }
        }
      }
      None => ()
    }
  }
  spans
}

///|
pub fn plan_module_type_layouts(
  collected : CollectedModule,
  resolved : ResolvedModuleTypes,
) -> PlannedModuleTypeLayouts {
  if collected.module_id != resolved.module_id {
    abort("type layout inputs belong to different modules")
  }
  let mut has_nominal = false
  for declaration in collected.declarations {
    if declaration.kind == StructDecl ||
      declaration.kind == EnumDecl ||
      declaration.kind == ForeignTypeDecl {
      has_nominal = true
      break
    }
  }
  if !has_nominal {
    return {
      module_id: collected.module_id,
      layouts: [],
      layout_by_declaration: [],
      fields: [],
      variants: [],
      payload_types: [],
      payload_shapes: [],
    }
  }
  let declaration_field_spans = field_spans_by_declaration(collected)
  let declaration_variant_spans = variant_spans_by_declaration(collected)
  let variant_field_spans = layout_variant_field_spans(collected)
  let field_indices = Array::make(collected.fields.length(), 0)
  let declaration_field_counts = Array::make(
    collected.declaration_locations.length(),
    0,
  )
  let variant_field_counts = Array::make(collected.variants.length(), 0)
  for index, field in collected.fields {
    match field.variant {
      Some(variant) => {
        let variant_index = semantic_id_local(variant)
        field_indices[index] = variant_field_counts[variant_index]
        variant_field_counts[variant_index] += 1
      }
      None => {
        let declaration_index = semantic_id_local(field.declaration)
        field_indices[index] = declaration_field_counts[declaration_index]
        declaration_field_counts[declaration_index] += 1
      }
    }
  }
  let fields : Array[PlannedFieldLayout] = []
  for index, field in collected.fields {
    let type_ = resolved.field_types[index]
    fields.push({
      field: field.id,
      declaration: field.declaration,
      variant: field.variant,
      mutable_: field.mutable_,
      name: collected.name(field.name),
      index: field_indices[index],
      type_,
      shape: planned_resolved_value_shape(resolved, type_),
      offset: field.offset,
    })
  }
  let variants : Array[PlannedVariantLayout] = Array::make(
    collected.variants.length(),
    {
      variant: 0UL,
      declaration: 0UL,
      tag: -1,
      payload: PlannedUnitVariantLayout,
      offset: 0UL,
    },
  )
  let payload_types : Array[ResolvedTypeId] = []
  let payload_shapes : Array[PlannedValueShape] = []
  for declaration in collected.declarations {
    if declaration.kind != EnumDecl {
      continue
    }
    let declaration_index = semantic_id_local(declaration.id)
    let span = if declaration_index < declaration_variant_spans.length() {
      declaration_variant_spans[declaration_index]
    } else {
      { start: 0, length: 0, }
    }
    for tag in 0..<span.length {
      let variant_index = span.start + tag
      let variant = collected.variants[variant_index]
      let payload = match variant.kind {
        UnitVariantDecl => PlannedUnitVariantLayout
        TupleVariantDecl => {
          let source = resolved.variant_payloads[variant_index]
          let start = payload_types.length()
          for index in 0..<source.length {
            let type_ = resolved.signature_type_lists[source.start + index]
            payload_types.push(type_)
            payload_shapes.push(planned_resolved_value_shape(resolved, type_))
          }
          PlannedTupleVariantLayout({
            start,
            length: payload_types.length() - start,
          })
        }
        StructVariantDecl =>
          PlannedStructVariantLayout(variant_field_spans[variant_index])
      }
      variants[variant_index] = {
        variant: variant.id,
        declaration: variant.declaration,
        tag,
        payload,
        offset: variant.offset,
      }
    }
  }
  let layouts : Array[PlannedNominalLayout] = []
  let layout_by_declaration = Array::make(
    collected.declaration_locations.length(),
    -1,
  )
  for declaration in collected.declarations {
    let kind = match declaration.kind {
      StructDecl => {
        let declaration_index = semantic_id_local(declaration.id)
        let fields = if declaration_index < declaration_field_spans.length() {
          declaration_field_spans[declaration_index]
        } else {
          { start: 0, length: 0, }
        }
        Some(PlannedStructLayout(fields))
      }
      EnumDecl => {
        let declaration_index = semantic_id_local(declaration.id)
        let variants = if declaration_index < declaration_variant_spans.length() {
          declaration_variant_spans[declaration_index]
        } else {
          { start: 0, length: 0, }
        }
        Some(PlannedEnumLayout(variants))
      }
      ForeignTypeDecl => Some(PlannedForeignTypeLayout)
      _ => None
    }
    match kind {
      Some(kind) => {
        let index = layouts.length()
        layout_by_declaration[semantic_id_local(declaration.id)] = index
        layouts.push({
          declaration: declaration.id,
          visibility: declaration.visibility,
          generic_parameters: collected.generic_parameters_of(declaration.id),
          test_only: collected.declaration_is_test_only(declaration.id),
          kind,
          offset: declaration.offset,
        })
      }
      None => ()
    }
  }
  {
    module_id: collected.module_id,
    layouts,
    layout_by_declaration,
    fields,
    variants,
    payload_types,
    payload_shapes,
  }
}
