///|
let frozen_interface_cache_magic : Bytes = b"DEW_FROZEN_INTERFACES_V1\x00"

///|
fn cache_write_int(output : @cache_binary.Writer, value : Int) -> Unit {
  output.write_zigzag_int(value)
}

///|
fn cache_write_u64(output : @cache_binary.Writer, value : UInt64) -> Unit {
  output.write_u64_le(value)
}

///|
fn cache_write_bool(output : @cache_binary.Writer, value : Bool) -> Unit {
  output.write_bool(value)
}

///|
fn cache_write_bytes(output : @cache_binary.Writer, value : Bytes) -> Unit {
  output.write_bytes(value)
}

///|
fn cache_write_string(output : @cache_binary.Writer, value : String) -> Unit {
  output.write_string(value)
}

///|
fn cache_write_span(output : @cache_binary.Writer, value : HirSpan) -> Unit {
  cache_write_int(output, value.start)
  cache_write_int(output, value.length)
}

///|
fn cache_write_location(
  output : @cache_binary.Writer,
  value : SourceLocation,
) -> Unit {
  cache_write_u64(output, value.file)
  cache_write_u64(output, value.offset)
}

///|
fn cache_write_int_array(
  output : @cache_binary.Writer,
  values : Array[Int],
) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_int(output, value)
  }
}

///|
fn cache_write_u64_array(
  output : @cache_binary.Writer,
  values : Array[UInt64],
) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_u64(output, value)
  }
}

///|
fn cache_write_bool_array(
  output : @cache_binary.Writer,
  values : Array[Bool],
) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_bool(output, value)
  }
}

///|
fn cache_write_span_array(
  output : @cache_binary.Writer,
  values : Array[HirSpan],
) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_span(output, value)
  }
}

///|
fn cache_write_primitive(
  output : @cache_binary.Writer,
  value : PrimitiveType,
) -> Unit {
  cache_write_int(output, value.rank())
}

///|
fn cache_primitive_from_rank(rank : Int) -> PrimitiveType? {
  match rank {
    0 => Some(UnitType)
    1 => Some(BoolType)
    2 => Some(I32Type)
    3 => Some(U32Type)
    4 => Some(I64Type)
    5 => Some(U64Type)
    6 => Some(F32Type)
    7 => Some(F64Type)
    8 => Some(StringType)
    9 => Some(NeverType)
    10 => Some(I8Type)
    11 => Some(I16Type)
    12 => Some(U8Type)
    13 => Some(U16Type)
    14 => Some(BytesType)
    15 => Some(V128Type)
    16 => Some(Swar32Type)
    17 => Some(Swar64Type)
    18 => Some(I8x4Type)
    19 => Some(U8x4Type)
    20 => Some(I16x2Type)
    21 => Some(U16x2Type)
    22 => Some(I8x8Type)
    23 => Some(U8x8Type)
    24 => Some(I16x4Type)
    25 => Some(U16x4Type)
    26 => Some(I32x2Type)
    27 => Some(U32x2Type)
    28 => Some(I8x16Type)
    29 => Some(U8x16Type)
    30 => Some(I16x8Type)
    31 => Some(U16x8Type)
    32 => Some(I32x4Type)
    33 => Some(U32x4Type)
    34 => Some(I64x2Type)
    35 => Some(U64x2Type)
    36 => Some(F32x4Type)
    37 => Some(F64x2Type)
    38 => Some(StringViewType)
    39 => Some(StringBuilderType)
    40 => Some(BytesBuilderType)
    41 => Some(CompileTimeTypeType)
    _ => None
  }
}

///|
fn cache_write_resolved_type(
  output : @cache_binary.Writer,
  value : ResolvedType,
) -> Unit {
  match value {
    ErrorType => cache_write_int(output, 0)
    MemberTypeProjection(owner, operation, selector) => {
      cache_write_int(output, 9)
      cache_write_int(output, owner)
      cache_write_bytes(output, operation)
      cache_write_string(output, selector)
    }
    PrimitiveType(primitive) => {
      cache_write_int(output, 1)
      cache_write_primitive(output, primitive)
    }
    GenericParameterType(parameter) => {
      cache_write_int(output, 2)
      cache_write_u64(output, parameter)
    }
    NominalType(declaration) => {
      cache_write_int(output, 3)
      cache_write_u64(output, declaration)
    }
    TraitType(declaration) => {
      cache_write_int(output, 4)
      cache_write_u64(output, declaration)
    }
    SelfType(declaration) => {
      cache_write_int(output, 5)
      cache_write_u64(output, declaration)
    }
    ProductType(fields) => {
      cache_write_int(output, 8)
      cache_write_span(output, fields)
    }
    AppliedType(base, arguments) => {
      cache_write_int(output, 6)
      cache_write_int(output, base)
      cache_write_span(output, arguments)
    }
    FunctionType(parameters, result) => {
      cache_write_int(output, 7)
      cache_write_span(output, parameters)
      cache_write_int(output, result)
    }
  }
}

///|
fn cache_write_resolved_types(
  output : @cache_binary.Writer,
  resolved : ResolvedModuleTypes,
) -> Result[Unit, String] {
  if resolved.diagnostics.length() != 0 {
    return Err("cannot cache a frozen interface with type diagnostics")
  }
  cache_write_u64(output, resolved.module_id)
  cache_write_int(output, resolved.types.length())
  for type_ in resolved.types {
    cache_write_resolved_type(output, type_)
  }
  cache_write_int_array(output, resolved.type_arguments)
  cache_write_int_array(output, resolved.syntax_types)
  cache_write_int_array(output, resolved.declaration_types)
  cache_write_int_array(output, resolved.generic_parameter_types)
  cache_write_int_array(output, resolved.generic_bound_types)
  cache_write_int_array(output, resolved.parameter_types)
  cache_write_int_array(output, resolved.callable_return_types)
  cache_write_int_array(output, resolved.callable_function_types)
  cache_write_int_array(output, resolved.lambda_parameter_types)
  cache_write_int_array(output, resolved.lambda_return_types)
  cache_write_int_array(output, resolved.lambda_function_types)
  cache_write_int_array(output, resolved.explicit_call_type_arguments)
  cache_write_int_array(output, resolved.field_types)
  cache_write_span_array(output, resolved.variant_payloads)
  cache_write_int_array(output, resolved.signature_type_lists)
  cache_write_int_array(output, resolved.alias_target_types)
  cache_write_int_array(output, resolved.impl_trait_types)
  cache_write_int_array(output, resolved.impl_target_types)
  cache_write_span_array(output, resolved.alias_dependencies)
  cache_write_u64_array(output, resolved.alias_dependency_declarations)
  cache_write_bool_array(output, resolved.alias_is_cyclic)
  cache_write_span_array(output, resolved.alias_cycles)
  cache_write_u64_array(output, resolved.alias_cycle_declarations)
  cache_write_int(output, resolved.alias_expansion_work)
  cache_write_int(output, resolved.alias_expansion_limit)
  cache_write_int(output, resolved.error_type)
  cache_write_int_array(output, resolved.primitive_types)
  Ok(())
}

///|
fn cache_write_declaration_kind(
  output : @cache_binary.Writer,
  value : FrozenInterfaceDeclarationKind,
) -> Unit {
  cache_write_int(
    output,
    match value {
      FrozenTypeDeclaration => 0
      FrozenTraitDeclaration => 1
      FrozenValueDeclaration => 2
    },
  )
}

///|
fn cache_write_collected_kind(
  output : @cache_binary.Writer,
  value : CollectedDeclKind,
) -> Unit {
  cache_write_int(
    output,
    match value {
      BuiltinDecl => 0
      LetDecl => 1
      TraitDecl => 2
      FunctionDecl => 3
      TestDecl => 4
      ImplDecl => 5
      StructDecl => 6
      EnumDecl => 7
      TypeAliasDecl => 8
      ForeignTypeDecl => 9
      ForeignLibraryDecl => 10
    },
  )
}

///|
fn cache_write_variant_kind(
  output : @cache_binary.Writer,
  value : CollectedVariantKind,
) -> Unit {
  cache_write_int(
    output,
    match value {
      UnitVariantDecl => 0
      TupleVariantDecl => 1
      StructVariantDecl => 2
    },
  )
}

///|
fn cache_write_shape(
  output : @cache_binary.Writer,
  value : PlannedValueShape,
) -> Unit {
  cache_write_int(
    output,
    match value {
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
    },
  )
  match value {
    ProductPlannedValueShape(fields) => {
      cache_write_int(output, fields.length())
      for field in fields {
        cache_write_shape(output, field)
      }
    }
    _ => ()
  }
}

///|
fn cache_write_callable_kind(
  output : @cache_binary.Writer,
  value : FrozenInterfaceCallableKind,
) -> Unit {
  match value {
    FrozenBuiltinCallable(name) => {
      cache_write_int(output, 0)
      cache_write_bytes(output, name)
    }
    FrozenFunctionCallable => cache_write_int(output, 1)
    FrozenTraitCallable(declaration) => {
      cache_write_int(output, 2)
      cache_write_u64(output, declaration)
    }
    FrozenImplCallable(declaration) => {
      cache_write_int(output, 3)
      cache_write_u64(output, declaration)
    }
  }
}

///|
fn cache_write_interface(
  output : @cache_binary.Writer,
  interface_ : FrozenModuleInterface,
) -> Result[Unit, String] {
  cache_write_u64(output, interface_.module_id)
  cache_write_string(output, interface_.path)
  cache_write_int(output, interface_.preamble_declaration_count)
  match cache_write_resolved_types(output, interface_.resolved_types) {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  cache_write_int(output, interface_.generic_parameter_bounds.length())
  for bounds in interface_.generic_parameter_bounds {
    cache_write_span(output, bounds)
  }
  cache_write_int(output, interface_.declarations.length())
  for declaration in interface_.declarations {
    cache_write_u64(output, declaration.declaration)
    cache_write_string(output, declaration.name)
    cache_write_declaration_kind(output, declaration.kind)
    cache_write_collected_kind(output, declaration.source_kind)
    cache_write_int(output, declaration.generic_parameter_count)
    cache_write_span(output, declaration.generic_parameters)
    cache_write_int(output, declaration.semantic_type)
    cache_write_location(output, declaration.location)
  }
  cache_write_int(output, interface_.declaration_abi_fingerprints.length())
  for fingerprint in interface_.declaration_abi_fingerprints {
    cache_write_string(output, fingerprint)
  }
  cache_write_int(output, interface_.fields.length())
  for field in interface_.fields {
    cache_write_u64(output, field.field)
    cache_write_u64(output, field.declaration)
    match field.variant {
      Some(variant) => {
        cache_write_bool(output, true)
        cache_write_u64(output, variant)
      }
      None => cache_write_bool(output, false)
    }
    cache_write_bool(output, field.mutable_)
    cache_write_string(output, field.name)
    cache_write_int(output, field.type_)
    cache_write_location(output, field.location)
  }
  cache_write_int(output, interface_.variants.length())
  for variant in interface_.variants {
    cache_write_u64(output, variant.variant)
    cache_write_u64(output, variant.declaration)
    cache_write_variant_kind(output, variant.kind)
    cache_write_string(output, variant.name)
    cache_write_span(output, variant.payload_types)
    cache_write_location(output, variant.location)
  }
  cache_write_int_array(output, interface_.variant_payload_types)
  cache_write_int(output, interface_.callables.length())
  for callable in interface_.callables {
    cache_write_u64(output, callable.declaration)
    cache_write_string(output, callable.name)
    cache_write_callable_kind(output, callable.kind)
    cache_write_span(output, callable.generic_parameters)
    cache_write_span(output, callable.parameters)
    cache_write_int(output, callable.result_type)
    cache_write_shape(output, callable.result_shape)
    cache_write_string(output, callable.abi_fingerprint)
    cache_write_location(output, callable.location)
  }
  cache_write_int(output, interface_.parameters.length())
  for parameter in interface_.parameters {
    cache_write_u64(output, parameter.parameter)
    cache_write_string(output, parameter.name)
    cache_write_int(output, parameter.type_)
    cache_write_shape(output, parameter.shape)
    cache_write_bool(output, parameter.receiver)
    cache_write_location(output, parameter.location)
  }
  cache_write_int(output, interface_.implementations.length())
  for implementation in interface_.implementations {
    cache_write_u64(output, implementation.declaration)
    cache_write_span(output, implementation.generic_parameters)
    cache_write_int(output, implementation.trait_type)
    cache_write_int(output, implementation.target_type)
    cache_write_location(output, implementation.location)
  }
  cache_write_string(output, interface_.content_fingerprint)
  cache_write_string(output, interface_.interface_fingerprint)
  cache_write_int(output, interface_.dependencies.length())
  for dependency in interface_.dependencies {
    cache_write_string(output, dependency.path)
    cache_write_string(output, dependency.content_fingerprint)
  }
  Ok(())
}

///|
/// Hashes the exact imported identity/evidence structure consumed by body
/// inference while deliberately excluding source locations. Public semantic
/// fingerprints remain ID-independent; this companion fingerprint preserves the
/// concrete IDs stored in inferred call/evidence arenas without invalidating on
/// private body-only offset changes.
pub fn frozen_interface_body_evidence_fingerprint(
  interface_ : FrozenModuleInterface,
) -> Result[String, String] {
  let declarations : Array[FrozenInterfaceDeclaration] = []
  for declaration in interface_.declarations {
    declarations.push({ ..declaration, location: { file: 0UL, offset: 0UL, }, })
  }
  let fields : Array[FrozenInterfaceField] = []
  for field in interface_.fields {
    fields.push({ ..field, location: { file: 0UL, offset: 0UL, }, })
  }
  let variants : Array[FrozenInterfaceVariant] = []
  for variant in interface_.variants {
    variants.push({ ..variant, location: { file: 0UL, offset: 0UL, }, })
  }
  let callables : Array[FrozenInterfaceCallable] = []
  for callable in interface_.callables {
    callables.push({ ..callable, location: { file: 0UL, offset: 0UL, }, })
  }
  let parameters : Array[FrozenInterfaceParameter] = []
  for parameter in interface_.parameters {
    parameters.push({ ..parameter, location: { file: 0UL, offset: 0UL, }, })
  }
  let implementations : Array[FrozenInterfaceImplementation] = []
  for implementation in interface_.implementations {
    implementations.push({
      ..implementation,
      location: { file: 0UL, offset: 0UL, },
    })
  }
  let normalized : FrozenModuleInterface = {
    ..interface_,
    declarations,
    fields,
    variants,
    callables,
    parameters,
    implementations,
  }
  let output = @cache_binary.Writer::new()
  output.write_raw(b"DEW_BODY_EVIDENCE_INTERFACE_V1\x00")
  match cache_write_interface(output, normalized) {
    Err(error) => Err(error)
    Ok(_) => Ok(@crypto.bytes_to_hex_string(@crypto.sha256(output.to_bytes())))
  }
}

///|
/// Serializes diagnostics-free frozen interfaces into a deterministic,
/// versioned compiler artifact. The format is private to the matching compiler
/// ABI and is never a language-level interchange format.
pub fn serialize_frozen_interfaces(
  interfaces : Array[FrozenModuleInterface],
) -> Result[Bytes, String] {
  let output = @cache_binary.Writer::new()
  output.write_raw(frozen_interface_cache_magic)
  cache_write_int(output, interfaces.length())
  for interface_ in interfaces {
    match cache_write_interface(output, interface_) {
      Err(error) => return Err(error)
      Ok(_) => ()
    }
  }
  Ok(output.to_bytes())
}

///|
priv struct FrozenInterfaceCacheReader {
  reader : @cache_binary.Reader
}

///|
fn FrozenInterfaceCacheReader::fail(
  self : FrozenInterfaceCacheReader,
  message : String,
) -> Unit {
  self.reader.fail("interface", message)
}

///|
fn FrozenInterfaceCacheReader::read_int(
  self : FrozenInterfaceCacheReader,
) -> Int {
  self.reader.read_zigzag_int("integer")
}

///|
fn FrozenInterfaceCacheReader::read_u64(
  self : FrozenInterfaceCacheReader,
) -> UInt64 {
  self.reader.read_u64_le("u64")
}

///|
fn FrozenInterfaceCacheReader::read_bool(
  self : FrozenInterfaceCacheReader,
) -> Bool {
  self.reader.read_bool("Boolean")
}

///|
fn FrozenInterfaceCacheReader::read_bytes(
  self : FrozenInterfaceCacheReader,
) -> Bytes {
  self.reader.read_bytes(0x10000000, "bytes")
}

///|
fn FrozenInterfaceCacheReader::read_string(
  self : FrozenInterfaceCacheReader,
) -> String {
  self.reader.read_string(0x01000000, "string")
}

///|
fn FrozenInterfaceCacheReader::read_span(
  self : FrozenInterfaceCacheReader,
) -> HirSpan {
  { start: self.read_int(), length: self.read_int(), }
}

///|
fn FrozenInterfaceCacheReader::read_location(
  self : FrozenInterfaceCacheReader,
) -> SourceLocation {
  { file: self.read_u64(), offset: self.read_u64(), }
}

///|
fn FrozenInterfaceCacheReader::read_count(
  self : FrozenInterfaceCacheReader,
  item_bytes : Int,
  label : String,
) -> Int {
  if item_bytes <= 0 {
    self.fail("invalid \{label} item width")
    return 0
  }
  let by_remaining = self.reader.remaining()
  let maximum = if by_remaining < 0x01000000 {
    by_remaining
  } else {
    0x01000000
  }
  let count = self.read_int()
  if count < 0 || count > maximum {
    self.fail("invalid \{label} count")
    0
  } else {
    count
  }
}

///|
fn FrozenInterfaceCacheReader::read_int_array(
  self : FrozenInterfaceCacheReader,
) -> Array[Int] {
  let length = self.read_count(4, "integer array")
  let values : Array[Int] = []
  for _ in 0..<length {
    values.push(self.read_int())
  }
  values
}

///|
fn FrozenInterfaceCacheReader::read_u64_array(
  self : FrozenInterfaceCacheReader,
) -> Array[UInt64] {
  let length = self.read_count(8, "u64 array")
  let values : Array[UInt64] = []
  for _ in 0..<length {
    values.push(self.read_u64())
  }
  values
}

///|
fn FrozenInterfaceCacheReader::read_bool_array(
  self : FrozenInterfaceCacheReader,
) -> Array[Bool] {
  let length = self.read_count(1, "Boolean array")
  let values : Array[Bool] = []
  for _ in 0..<length {
    values.push(self.read_bool())
  }
  values
}

///|
fn FrozenInterfaceCacheReader::read_span_array(
  self : FrozenInterfaceCacheReader,
) -> Array[HirSpan] {
  let length = self.read_count(8, "span array")
  let values : Array[HirSpan] = []
  for _ in 0..<length {
    values.push(self.read_span())
  }
  values
}

///|
fn FrozenInterfaceCacheReader::read_resolved_type(
  self : FrozenInterfaceCacheReader,
) -> ResolvedType {
  match self.read_int() {
    0 => ErrorType
    1 =>
      match cache_primitive_from_rank(self.read_int()) {
        Some(primitive) => PrimitiveType(primitive)
        None => {
          self.fail("unknown primitive type in frozen-interface cache")
          ErrorType
        }
      }
    2 => GenericParameterType(self.read_u64())
    3 => NominalType(self.read_u64())
    4 => TraitType(self.read_u64())
    5 => SelfType(self.read_u64())
    6 => AppliedType(self.read_int(), self.read_span())
    7 => FunctionType(self.read_span(), self.read_int())
    8 => ProductType(self.read_span())
    9 =>
      MemberTypeProjection(
        self.read_int(),
        self.read_bytes(),
        self.read_string(),
      )
    _ => {
      self.fail("unknown resolved type in frozen-interface cache")
      ErrorType
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_resolved_types(
  self : FrozenInterfaceCacheReader,
) -> ResolvedModuleTypes {
  let module_id = self.read_u64()
  let type_count = self.read_count(4, "resolved type")
  let types : Array[ResolvedType] = []
  for _ in 0..<type_count {
    types.push(self.read_resolved_type())
  }
  for type_ in types {
    if type_ is MemberTypeProjection(owner, operation, _) {
      if owner < 0 || owner >= type_count || !computed_type_builtin(operation) {
        self.fail("invalid member projection in frozen-interface cache")
      }
    }
  }
  {
    module_id,
    types,
    type_arguments: self.read_int_array(),
    syntax_types: self.read_int_array(),
    declaration_types: self.read_int_array(),
    generic_parameter_types: self.read_int_array(),
    generic_bound_types: self.read_int_array(),
    parameter_types: self.read_int_array(),
    callable_return_types: self.read_int_array(),
    callable_function_types: self.read_int_array(),
    lambda_parameter_types: self.read_int_array(),
    lambda_return_types: self.read_int_array(),
    lambda_function_types: self.read_int_array(),
    explicit_call_type_arguments: self.read_int_array(),
    field_types: self.read_int_array(),
    variant_payloads: self.read_span_array(),
    signature_type_lists: self.read_int_array(),
    alias_target_types: self.read_int_array(),
    impl_trait_types: self.read_int_array(),
    impl_target_types: self.read_int_array(),
    alias_dependencies: self.read_span_array(),
    alias_dependency_declarations: self.read_u64_array(),
    alias_is_cyclic: self.read_bool_array(),
    alias_cycles: self.read_span_array(),
    alias_cycle_declarations: self.read_u64_array(),
    alias_expansion_work: self.read_int(),
    alias_expansion_limit: self.read_int(),
    diagnostics: [],
    error_type: self.read_int(),
    primitive_types: self.read_int_array(),
  }
}

///|
fn FrozenInterfaceCacheReader::read_declaration_kind(
  self : FrozenInterfaceCacheReader,
) -> FrozenInterfaceDeclarationKind {
  match self.read_int() {
    0 => FrozenTypeDeclaration
    1 => FrozenTraitDeclaration
    2 => FrozenValueDeclaration
    _ => {
      self.fail("unknown declaration kind in frozen-interface cache")
      FrozenValueDeclaration
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_collected_kind(
  self : FrozenInterfaceCacheReader,
) -> CollectedDeclKind {
  match self.read_int() {
    0 => BuiltinDecl
    1 => LetDecl
    2 => TraitDecl
    3 => FunctionDecl
    4 => TestDecl
    5 => ImplDecl
    6 => StructDecl
    7 => EnumDecl
    8 => TypeAliasDecl
    9 => ForeignTypeDecl
    10 => ForeignLibraryDecl
    _ => {
      self.fail("unknown collected declaration kind in frozen-interface cache")
      FunctionDecl
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_variant_kind(
  self : FrozenInterfaceCacheReader,
) -> CollectedVariantKind {
  match self.read_int() {
    0 => UnitVariantDecl
    1 => TupleVariantDecl
    2 => StructVariantDecl
    _ => {
      self.fail("unknown variant kind in frozen-interface cache")
      UnitVariantDecl
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_shape(
  self : FrozenInterfaceCacheReader,
) -> PlannedValueShape {
  match self.read_int() {
    0 => ErrorPlannedValueShape
    1 => UnitPlannedValueShape
    2 => I8PlannedValueShape
    3 => I16PlannedValueShape
    4 => I32PlannedValueShape
    5 => I64PlannedValueShape
    6 => U8PlannedValueShape
    7 => U16PlannedValueShape
    8 => U32PlannedValueShape
    9 => U64PlannedValueShape
    10 => F32PlannedValueShape
    11 => F64PlannedValueShape
    12 => Swar32PlannedValueShape
    13 => Swar64PlannedValueShape
    14 => V128PlannedValueShape
    15 => RefPlannedValueShape
    16 => GenericPlannedValueShape
    17 => NeverPlannedValueShape
    18 => {
      let count = self.read_count(64, "product shape field")
      let fields : Array[PlannedValueShape] = []
      for _ in 0..<count {
        fields.push(self.read_shape())
      }
      ProductPlannedValueShape(fields)
    }
    _ => {
      self.fail("unknown value shape in frozen-interface cache")
      ErrorPlannedValueShape
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_callable_kind(
  self : FrozenInterfaceCacheReader,
) -> FrozenInterfaceCallableKind {
  match self.read_int() {
    0 => FrozenBuiltinCallable(self.read_bytes())
    1 => FrozenFunctionCallable
    2 => FrozenTraitCallable(self.read_u64())
    3 => FrozenImplCallable(self.read_u64())
    _ => {
      self.fail("unknown callable kind in frozen-interface cache")
      FrozenFunctionCallable
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_interface(
  self : FrozenInterfaceCacheReader,
) -> FrozenModuleInterface {
  let module_id = self.read_u64()
  let path = self.read_string()
  let preamble_declaration_count = self.read_int()
  let resolved_types = self.read_resolved_types()
  let generic_bound_count = self.read_count(1, "generic parameter bound")
  let generic_parameter_bounds : Array[HirSpan] = []
  for _ in 0..<generic_bound_count {
    generic_parameter_bounds.push(self.read_span())
  }
  let declaration_count = self.read_count(1, "declaration")
  let declarations : Array[FrozenInterfaceDeclaration] = []
  for _ in 0..<declaration_count {
    declarations.push({
      declaration: self.read_u64(),
      name: self.read_string(),
      kind: self.read_declaration_kind(),
      source_kind: self.read_collected_kind(),
      generic_parameter_count: self.read_int(),
      generic_parameters: self.read_span(),
      semantic_type: self.read_int(),
      location: self.read_location(),
    })
  }
  let fingerprint_count = self.read_count(1, "declaration fingerprint")
  let declaration_abi_fingerprints : Array[String] = []
  for _ in 0..<fingerprint_count {
    declaration_abi_fingerprints.push(self.read_string())
  }
  let field_count = self.read_count(1, "field")
  let fields : Array[FrozenInterfaceField] = []
  for _ in 0..<field_count {
    let field = self.read_u64()
    let declaration = self.read_u64()
    let variant = if self.read_bool() { Some(self.read_u64()) } else { None }
    fields.push({
      field,
      declaration,
      variant,
      mutable_: self.read_bool(),
      name: self.read_string(),
      type_: self.read_int(),
      location: self.read_location(),
    })
  }
  let variant_count = self.read_count(1, "variant")
  let variants : Array[FrozenInterfaceVariant] = []
  for _ in 0..<variant_count {
    variants.push({
      variant: self.read_u64(),
      declaration: self.read_u64(),
      kind: self.read_variant_kind(),
      name: self.read_string(),
      payload_types: self.read_span(),
      location: self.read_location(),
    })
  }
  let variant_payload_types = self.read_int_array()
  let callable_count = self.read_count(1, "callable")
  let callables : Array[FrozenInterfaceCallable] = []
  for _ in 0..<callable_count {
    callables.push({
      declaration: self.read_u64(),
      name: self.read_string(),
      kind: self.read_callable_kind(),
      generic_parameters: self.read_span(),
      parameters: self.read_span(),
      result_type: self.read_int(),
      result_shape: self.read_shape(),
      abi_fingerprint: self.read_string(),
      location: self.read_location(),
    })
  }
  let parameter_count = self.read_count(1, "parameter")
  let parameters : Array[FrozenInterfaceParameter] = []
  for _ in 0..<parameter_count {
    parameters.push({
      parameter: self.read_u64(),
      name: self.read_string(),
      type_: self.read_int(),
      shape: self.read_shape(),
      receiver: self.read_bool(),
      location: self.read_location(),
    })
  }
  let implementation_count = self.read_count(1, "implementation")
  let implementations : Array[FrozenInterfaceImplementation] = []
  for _ in 0..<implementation_count {
    implementations.push({
      declaration: self.read_u64(),
      generic_parameters: self.read_span(),
      trait_type: self.read_int(),
      target_type: self.read_int(),
      location: self.read_location(),
    })
  }
  let content_fingerprint = self.read_string()
  let interface_fingerprint = self.read_string()
  let dependency_count = self.read_count(1, "interface dependency")
  let dependencies : Array[FrozenInterfaceDependency] = []
  for _ in 0..<dependency_count {
    dependencies.push({
      path: self.read_string(),
      content_fingerprint: self.read_string(),
    })
  }
  {
    module_id,
    path,
    preamble_declaration_count,
    resolved_types,
    generic_parameter_bounds,
    declarations,
    declaration_abi_fingerprints,
    fields,
    variants,
    variant_payload_types,
    callables,
    parameters,
    implementations,
    content_fingerprint,
    interface_fingerprint,
    dependencies,
  }
}

///|
/// Decodes one private compiler cache artifact. Corrupt, truncated, trailing,
/// or unsupported data is rejected visibly and must never be treated as a hit.
pub fn deserialize_frozen_interfaces(
  bytes : Bytes,
) -> Result[Array[FrozenModuleInterface], String] {
  let binary = @cache_binary.Reader::new(
    bytes,
    context="frozen_interface_payload",
  )
  let magic = binary.read_raw_bytes(
    frozen_interface_cache_magic.length(),
    frozen_interface_cache_magic.length(),
    "magic",
  )
  if magic != frozen_interface_cache_magic {
    return Err("unsupported frozen-interface cache version")
  }
  let reader : FrozenInterfaceCacheReader = { reader: binary, }
  let count = reader.read_count(1, "interface")
  let interfaces : Array[FrozenModuleInterface] = []
  for _ in 0..<count {
    let interface_ = reader.read_interface()
    if !reader.reader.failed() {
      match frozen_interface_implementation_evidence_error(interface_) {
        Some(error) => return Err(error)
        None => ()
      }
    }
    interfaces.push(interface_)
  }
  match reader.reader.finish() {
    Err(error) => Err(error)
    Ok(_) => Ok(interfaces)
  }
}
