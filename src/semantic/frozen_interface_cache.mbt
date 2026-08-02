///|
let frozen_interface_cache_magic : Bytes = b"DEW_FROZEN_INTERFACES_V4\x00"

///|
fn cache_write_u32(output : Buffer, value : UInt) -> Unit {
  output.write_byte((value & 0xffU).to_byte())
  output.write_byte(((value >> 8) & 0xffU).to_byte())
  output.write_byte(((value >> 16) & 0xffU).to_byte())
  output.write_byte(((value >> 24) & 0xffU).to_byte())
}

///|
fn cache_write_int(output : Buffer, value : Int) -> Unit {
  cache_write_u32(output, value.reinterpret_as_uint())
}

///|
fn cache_write_u64(output : Buffer, value : UInt64) -> Unit {
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    output.write_byte(((value >> shift) & 0xffUL).to_byte())
  }
}

///|
fn cache_write_bool(output : Buffer, value : Bool) -> Unit {
  output.write_byte(if value { 1 } else { 0 })
}

///|
fn cache_write_bytes(output : Buffer, value : Bytes) -> Unit {
  cache_write_int(output, value.length())
  output.write_bytes(value)
}

///|
fn cache_write_string(output : Buffer, value : String) -> Unit {
  let bytes = Buffer()
  bytes.write_string_utf8(value)
  cache_write_bytes(output, bytes.to_bytes())
}

///|
fn cache_write_span(output : Buffer, value : HirSpan) -> Unit {
  cache_write_int(output, value.start)
  cache_write_int(output, value.length)
}

///|
fn cache_write_location(output : Buffer, value : SourceLocation) -> Unit {
  cache_write_u64(output, value.file)
  cache_write_u64(output, value.offset)
}

///|
fn cache_write_int_array(output : Buffer, values : Array[Int]) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_int(output, value)
  }
}

///|
fn cache_write_u64_array(output : Buffer, values : Array[UInt64]) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_u64(output, value)
  }
}

///|
fn cache_write_bool_array(output : Buffer, values : Array[Bool]) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_bool(output, value)
  }
}

///|
fn cache_write_span_array(output : Buffer, values : Array[HirSpan]) -> Unit {
  cache_write_int(output, values.length())
  for value in values {
    cache_write_span(output, value)
  }
}

///|
fn cache_write_primitive(output : Buffer, value : PrimitiveType) -> Unit {
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
    _ => None
  }
}

///|
fn cache_write_resolved_type(output : Buffer, value : ResolvedType) -> Unit {
  match value {
    ErrorType => cache_write_int(output, 0)
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
  output : Buffer,
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
  cache_write_int_array(output, resolved.parameter_types)
  cache_write_int_array(output, resolved.callable_return_types)
  cache_write_int_array(output, resolved.callable_function_types)
  cache_write_int_array(output, resolved.lambda_parameter_types)
  cache_write_int_array(output, resolved.lambda_return_types)
  cache_write_int_array(output, resolved.lambda_function_types)
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
  output : Buffer,
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
  output : Buffer,
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
    },
  )
}

///|
fn cache_write_variant_kind(
  output : Buffer,
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
fn cache_write_shape(output : Buffer, value : PlannedValueShape) -> Unit {
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
    },
  )
}

///|
fn cache_write_callable_kind(
  output : Buffer,
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
  output : Buffer,
  interface_ : FrozenModuleInterface,
) -> Result[Unit, String] {
  cache_write_u64(output, interface_.module_id)
  cache_write_string(output, interface_.path)
  cache_write_int(output, interface_.preamble_declaration_count)
  match cache_write_resolved_types(output, interface_.resolved_types) {
    Err(error) => return Err(error)
    Ok(_) => ()
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
    cache_write_int(output, implementation.trait_type)
    cache_write_int(output, implementation.target_type)
    cache_write_location(output, implementation.location)
  }
  Ok(())
}

///|
/// Serializes diagnostics-free frozen interfaces into a deterministic,
/// versioned compiler artifact. The format is private to the matching compiler
/// ABI and is never a language-level interchange format.
pub fn serialize_frozen_interfaces(
  interfaces : Array[FrozenModuleInterface],
) -> Result[Bytes, String] {
  let output = Buffer()
  output.write_bytes(frozen_interface_cache_magic)
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
  bytes : Bytes
  mut offset : Int
  mut error : String?
}

///|
fn FrozenInterfaceCacheReader::fail(
  self : FrozenInterfaceCacheReader,
  message : String,
) -> Unit {
  if self.error is None {
    self.error = Some(message)
  }
}

///|
fn FrozenInterfaceCacheReader::read_byte(
  self : FrozenInterfaceCacheReader,
) -> UInt {
  if self.offset >= self.bytes.length() {
    self.fail("truncated frozen-interface cache")
    return 0U
  }
  let value = self.bytes[self.offset].to_uint()
  self.offset += 1
  value
}

///|
fn FrozenInterfaceCacheReader::read_u32(
  self : FrozenInterfaceCacheReader,
) -> UInt {
  let b0 = self.read_byte()
  let b1 = self.read_byte()
  let b2 = self.read_byte()
  let b3 = self.read_byte()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
fn FrozenInterfaceCacheReader::read_int(
  self : FrozenInterfaceCacheReader,
) -> Int {
  self.read_u32().reinterpret_as_int()
}

///|
fn FrozenInterfaceCacheReader::read_u64(
  self : FrozenInterfaceCacheReader,
) -> UInt64 {
  let mut value = 0UL
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    value = value | (self.read_byte().to_uint64() << shift)
  }
  value
}

///|
fn FrozenInterfaceCacheReader::read_bool(
  self : FrozenInterfaceCacheReader,
) -> Bool {
  match self.read_byte() {
    0U => false
    1U => true
    _ => {
      self.fail("invalid Boolean in frozen-interface cache")
      false
    }
  }
}

///|
fn FrozenInterfaceCacheReader::read_bytes(
  self : FrozenInterfaceCacheReader,
) -> Bytes {
  let length = self.read_int()
  if length < 0 ||
    self.offset + length < self.offset ||
    self.offset + length > self.bytes.length() {
    self.fail("invalid byte range in frozen-interface cache")
    return b""
  }
  let output = Buffer()
  for index in 0..<length {
    output.write_byte(self.bytes[self.offset + index])
  }
  self.offset += length
  output.to_bytes()
}

///|
fn FrozenInterfaceCacheReader::read_string(
  self : FrozenInterfaceCacheReader,
) -> String {
  let bytes = self.read_bytes()
  if !semantic_utf8_is_valid(bytes) {
    self.fail("invalid UTF-8 string in frozen-interface cache")
    return ""
  }
  @utf8.decode_lossy(bytes)
}

///|
fn FrozenInterfaceCacheReader::read_span(
  self : FrozenInterfaceCacheReader,
) -> HirSpan {
  { start: self.read_int(), length: self.read_int() }
}

///|
fn FrozenInterfaceCacheReader::read_location(
  self : FrozenInterfaceCacheReader,
) -> SourceLocation {
  { file: self.read_u64(), offset: self.read_u64() }
}

///|
fn FrozenInterfaceCacheReader::read_count(
  self : FrozenInterfaceCacheReader,
  item_bytes : Int,
  label : String,
) -> Int {
  let length = self.read_int()
  let remaining = self.bytes.length() - self.offset
  if length < 0 || item_bytes <= 0 || length > remaining / item_bytes {
    self.fail("invalid \{label} count in frozen-interface cache")
    return 0
  }
  length
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
  {
    module_id,
    types,
    type_arguments: self.read_int_array(),
    syntax_types: self.read_int_array(),
    declaration_types: self.read_int_array(),
    generic_parameter_types: self.read_int_array(),
    parameter_types: self.read_int_array(),
    callable_return_types: self.read_int_array(),
    callable_function_types: self.read_int_array(),
    lambda_parameter_types: self.read_int_array(),
    lambda_return_types: self.read_int_array(),
    lambda_function_types: self.read_int_array(),
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
      trait_type: self.read_int(),
      target_type: self.read_int(),
      location: self.read_location(),
    })
  }
  {
    module_id,
    path,
    preamble_declaration_count,
    resolved_types,
    declarations,
    fields,
    variants,
    variant_payload_types,
    callables,
    parameters,
    implementations,
  }
}

///|
/// Decodes one private compiler cache artifact. Corrupt, truncated, trailing,
/// or unsupported data is rejected visibly and must never be treated as a hit.
pub fn deserialize_frozen_interfaces(
  bytes : Bytes,
) -> Result[Array[FrozenModuleInterface], String] {
  if bytes.length() < frozen_interface_cache_magic.length() {
    return Err("truncated frozen-interface cache header")
  }
  for index in 0..<frozen_interface_cache_magic.length() {
    if bytes[index] != frozen_interface_cache_magic[index] {
      return Err("unsupported frozen-interface cache version")
    }
  }
  let reader : FrozenInterfaceCacheReader = {
    bytes,
    offset: frozen_interface_cache_magic.length(),
    error: None,
  }
  let count = reader.read_count(1, "interface")
  let interfaces : Array[FrozenModuleInterface] = []
  for _ in 0..<count {
    interfaces.push(reader.read_interface())
  }
  match reader.error {
    Some(error) => Err(error)
    None if reader.offset != bytes.length() =>
      Err("trailing bytes in frozen-interface cache")
    None => Ok(interfaces)
  }
}
