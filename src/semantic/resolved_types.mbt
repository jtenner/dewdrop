///|
pub type ResolvedTypeId = Int

///|
pub enum PrimitiveType {
  UnitType
  BoolType
  I32Type
  U32Type
  I64Type
  U64Type
  F32Type
  F64Type
  StringType
  NeverType
  I8Type
  I16Type
  U8Type
  U16Type
  BytesType
  V128Type
  Swar32Type
  Swar64Type
  I8x4Type
  U8x4Type
  I16x2Type
  U16x2Type
  I8x8Type
  U8x8Type
  I16x4Type
  U16x4Type
  I32x2Type
  U32x2Type
  I8x16Type
  U8x16Type
  I16x8Type
  U16x8Type
  I32x4Type
  U32x4Type
  I64x2Type
  U64x2Type
  F32x4Type
  F64x2Type
  StringViewType
  StringBuilderType
  BytesBuilderType
} derive(Eq, Debug, ToJson, FromJson)

///|
fn PrimitiveType::rank(self : PrimitiveType) -> Int {
  match self {
    UnitType => 0
    BoolType => 1
    I32Type => 2
    U32Type => 3
    I64Type => 4
    U64Type => 5
    F32Type => 6
    F64Type => 7
    StringType => 8
    NeverType => 9
    I8Type => 10
    I16Type => 11
    U8Type => 12
    U16Type => 13
    BytesType => 14
    V128Type => 15
    Swar32Type => 16
    Swar64Type => 17
    I8x4Type => 18
    U8x4Type => 19
    I16x2Type => 20
    U16x2Type => 21
    I8x8Type => 22
    U8x8Type => 23
    I16x4Type => 24
    U16x4Type => 25
    I32x2Type => 26
    U32x2Type => 27
    I8x16Type => 28
    U8x16Type => 29
    I16x8Type => 30
    U16x8Type => 31
    I32x4Type => 32
    U32x4Type => 33
    I64x2Type => 34
    U64x2Type => 35
    F32x4Type => 36
    F64x2Type => 37
    StringViewType => 38
    StringBuilderType => 39
    BytesBuilderType => 40
  }
}

///|
fn primitive_type_from_name(name : String) -> PrimitiveType? {
  match name {
    "Unit" => Some(UnitType)
    "Bool" => Some(BoolType)
    "I32" => Some(I32Type)
    "U32" => Some(U32Type)
    "I64" => Some(I64Type)
    "U64" => Some(U64Type)
    "F32" => Some(F32Type)
    "F64" => Some(F64Type)
    "String" => Some(StringType)
    "Never" => Some(NeverType)
    "I8" => Some(I8Type)
    "I16" => Some(I16Type)
    "U8" => Some(U8Type)
    "U16" => Some(U16Type)
    "Bytes" => Some(BytesType)
    "StringView" => Some(StringViewType)
    "StringBuilder" => Some(StringBuilderType)
    "BytesBuilder" => Some(BytesBuilderType)
    "V128" => Some(V128Type)
    "Swar32" => Some(Swar32Type)
    "Swar64" => Some(Swar64Type)
    "I8x4" => Some(I8x4Type)
    "U8x4" => Some(U8x4Type)
    "I16x2" => Some(I16x2Type)
    "U16x2" => Some(U16x2Type)
    "I8x8" => Some(I8x8Type)
    "U8x8" => Some(U8x8Type)
    "I16x4" => Some(I16x4Type)
    "U16x4" => Some(U16x4Type)
    "I32x2" => Some(I32x2Type)
    "U32x2" => Some(U32x2Type)
    "I8x16" => Some(I8x16Type)
    "U8x16" => Some(U8x16Type)
    "I16x8" => Some(I16x8Type)
    "U16x8" => Some(U16x8Type)
    "I32x4" => Some(I32x4Type)
    "U32x4" => Some(U32x4Type)
    "I64x2" => Some(I64x2Type)
    "U64x2" => Some(U64x2Type)
    "F32x4" => Some(F32x4Type)
    "F64x2" => Some(F64x2Type)
    _ => None
  }
}

///|
pub enum ResolvedType {
  ErrorType
  PrimitiveType(PrimitiveType)
  GenericParameterType(GenericParameterId)
  NominalType(DeclId)
  TraitType(DeclId)
  SelfType(DeclId)
  ProductType(HirSpan)
  AppliedType(ResolvedTypeId, HirSpan)
  FunctionType(HirSpan, ResolvedTypeId)
} derive(Eq, Debug)

///|
pub enum TypeDiagnostic {
  ReservedTypeName(DeclId, NameId, UInt64)
  UnknownType(NameId, DeclId, UInt64)
  UnknownTrait(NameId, DeclId, UInt64)
  AmbiguousImportedType(NameId, DeclId, UInt64)
  AmbiguousImportedTrait(NameId, DeclId, UInt64)
  ExpectedTraitType(NameId, DeclId, UInt64)
  TypeArityMismatch(ResolvedTypeId, Int, Int, DeclId, UInt64)
  TypeNotApplicable(ResolvedTypeId, DeclId, UInt64)
  NullableRefRequiresForeignType(ResolvedTypeId, DeclId, UInt64)
  SelfOutsideContext(DeclId, UInt64)
  AliasCycle(HirSpan, UInt64)
  AliasExpansionLimit(DeclId, Int, UInt64)
} derive(Eq, Debug)

///|
pub fn TypeDiagnostic::offset(self : TypeDiagnostic) -> UInt64 {
  match self {
    ReservedTypeName(_, _, offset)
    | UnknownType(_, _, offset)
    | UnknownTrait(_, _, offset)
    | AmbiguousImportedType(_, _, offset)
    | AmbiguousImportedTrait(_, _, offset)
    | ExpectedTraitType(_, _, offset)
    | TypeArityMismatch(_, _, _, _, offset)
    | TypeNotApplicable(_, _, offset)
    | NullableRefRequiresForeignType(_, _, offset)
    | SelfOutsideContext(_, offset)
    | AliasCycle(_, offset)
    | AliasExpansionLimit(_, _, offset) => offset
  }
}

///|
pub struct ResolvedModuleTypes {
  module_id : ModuleId
  types : Array[ResolvedType]
  type_arguments : Array[ResolvedTypeId]
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
  alias_expansion_work : Int
  alias_expansion_limit : Int
  diagnostics : Array[TypeDiagnostic]
  error_type : ResolvedTypeId
  primitive_types : Array[ResolvedTypeId]
} derive(Eq, Debug)

///|
pub fn ResolvedModuleTypes::primitive(
  self : ResolvedModuleTypes,
  primitive : PrimitiveType,
) -> ResolvedTypeId {
  self.primitive_types[primitive.rank()]
}

///|
pub fn ResolvedModuleTypes::declaration_type(
  self : ResolvedModuleTypes,
  declaration : DeclId,
) -> ResolvedTypeId {
  guard semantic_id_module(declaration) == self.module_id else {
    return self.error_type
  }
  let local_index = semantic_id_local(declaration)
  if local_index < 0 || local_index >= self.declaration_types.length() {
    self.error_type
  } else {
    self.declaration_types[local_index]
  }
}

///|
pub fn ResolvedModuleTypes::syntax_type(
  self : ResolvedModuleTypes,
  syntax : HirTypeId,
) -> ResolvedTypeId {
  self.syntax_types[syntax]
}

///|
pub fn ResolvedModuleTypes::arguments(
  self : ResolvedModuleTypes,
  type_ : ResolvedTypeId,
) -> ArrayView[ResolvedTypeId] {
  match self.types[type_] {
    ProductType(span) | AppliedType(_, span) | FunctionType(span, _) =>
      self.type_arguments[span.start:span.start + span.length]
    _ => self.type_arguments[0:0]
  }
}

///|
priv struct ResolvedTypeInterner {
  types : Array[ResolvedType]
  arguments : Array[ResolvedTypeId]
  buckets : Map[Int, Int]
  next : Array[Int]
  hashes : Array[Int]
  primitive_types : Array[ResolvedTypeId]
  mut error_type : ResolvedTypeId
}

///|
fn type_hash_mix(hash : Int, value : Int) -> Int {
  (hash ^ value) * 16777619
}

///|
fn PrimitiveType::hash_value(self : PrimitiveType) -> Int {
  type_hash_mix(0x210001, self.rank())
}

///|
fn ResolvedTypeInterner::new() -> ResolvedTypeInterner {
  let interner = {
    types: [],
    arguments: [],
    buckets: Map::default(),
    next: [],
    hashes: [],
    primitive_types: [],
    error_type: -1,
  }
  interner.error_type = interner.intern_simple(ErrorType, 0x110001)
  let primitives = [
    UnitType,
    BoolType,
    I32Type,
    U32Type,
    I64Type,
    U64Type,
    F32Type,
    F64Type,
    StringType,
    NeverType,
    I8Type,
    I16Type,
    U8Type,
    U16Type,
    BytesType,
    V128Type,
    Swar32Type,
    Swar64Type,
    I8x4Type,
    U8x4Type,
    I16x2Type,
    U16x2Type,
    I8x8Type,
    U8x8Type,
    I16x4Type,
    U16x4Type,
    I32x2Type,
    U32x2Type,
    I8x16Type,
    U8x16Type,
    I16x8Type,
    U16x8Type,
    I32x4Type,
    U32x4Type,
    I64x2Type,
    U64x2Type,
    F32x4Type,
    F64x2Type,
    StringViewType,
    StringBuilderType,
    BytesBuilderType,
  ]
  for primitive in primitives {
    interner.primitive_types.push(
      interner.intern_simple(PrimitiveType(primitive), primitive.hash_value()),
    )
  }
  interner
}

///|
fn ResolvedTypeInterner::insert(
  self : ResolvedTypeInterner,
  type_ : ResolvedType,
  hash : Int,
) -> ResolvedTypeId {
  let id = self.types.length()
  let previous = self.buckets.get(hash).unwrap_or(-1)
  self.types.push(type_)
  self.hashes.push(hash)
  self.next.push(previous)
  self.buckets[hash] = id
  id
}

///|
fn ResolvedTypeInterner::intern_simple(
  self : ResolvedTypeInterner,
  type_ : ResolvedType,
  hash : Int,
) -> ResolvedTypeId {
  let mut candidate = self.buckets.get(hash).unwrap_or(-1)
  while candidate >= 0 {
    if self.types[candidate] == type_ {
      return candidate
    }
    candidate = self.next[candidate]
  }
  self.insert(type_, hash)
}

///|
fn ResolvedTypeInterner::intern_primitive(
  self : ResolvedTypeInterner,
  primitive : PrimitiveType,
) -> ResolvedTypeId {
  self.primitive_types[primitive.rank()]
}

///|
fn ResolvedTypeInterner::intern_generic(
  self : ResolvedTypeInterner,
  parameter : GenericParameterId,
) -> ResolvedTypeId {
  self.intern_simple(
    GenericParameterType(parameter),
    type_hash_mix(0x310001, parameter.hash()),
  )
}

///|
fn ResolvedTypeInterner::intern_nominal(
  self : ResolvedTypeInterner,
  declaration : DeclId,
) -> ResolvedTypeId {
  self.intern_simple(
    NominalType(declaration),
    type_hash_mix(0x410001, declaration.hash()),
  )
}

///|
fn ResolvedTypeInterner::intern_trait(
  self : ResolvedTypeInterner,
  declaration : DeclId,
) -> ResolvedTypeId {
  self.intern_simple(
    TraitType(declaration),
    type_hash_mix(0x510001, declaration.hash()),
  )
}

///|
fn ResolvedTypeInterner::intern_self(
  self : ResolvedTypeInterner,
  declaration : DeclId,
) -> ResolvedTypeId {
  self.intern_simple(
    SelfType(declaration),
    type_hash_mix(0x610001, declaration.hash()),
  )
}

///|
fn ResolvedTypeInterner::product_matches(
  self : ResolvedTypeInterner,
  candidate : ResolvedTypeId,
  fields : Array[ResolvedTypeId],
) -> Bool {
  match self.types[candidate] {
    ProductType(span) => {
      if span.length != fields.length() {
        return false
      }
      for index in 0..<fields.length() {
        if self.arguments[span.start + index] != fields[index] {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn ResolvedTypeInterner::intern_product(
  self : ResolvedTypeInterner,
  fields : Array[ResolvedTypeId],
) -> ResolvedTypeId {
  let mut hash = 0x730001
  for field in fields {
    hash = type_hash_mix(hash, self.hashes[field])
  }
  hash = type_hash_mix(hash, fields.length())
  let mut candidate = self.buckets.get(hash).unwrap_or(-1)
  while candidate >= 0 {
    if self.product_matches(candidate, fields) {
      return candidate
    }
    candidate = self.next[candidate]
  }
  let start = self.arguments.length()
  for field in fields {
    self.arguments.push(field)
  }
  self.insert(ProductType({ start, length: fields.length(), }), hash)
}

///|
fn ResolvedTypeInterner::applied_matches(
  self : ResolvedTypeInterner,
  candidate : ResolvedTypeId,
  base : ResolvedTypeId,
  arguments : Array[ResolvedTypeId],
) -> Bool {
  match self.types[candidate] {
    AppliedType(candidate_base, span) => {
      if candidate_base != base || span.length != arguments.length() {
        return false
      }
      for index in 0..<arguments.length() {
        if self.arguments[span.start + index] != arguments[index] {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn ResolvedTypeInterner::function_matches(
  self : ResolvedTypeInterner,
  candidate : ResolvedTypeId,
  parameters : Array[ResolvedTypeId],
  result : ResolvedTypeId,
) -> Bool {
  match self.types[candidate] {
    FunctionType(span, candidate_result) => {
      if candidate_result != result || span.length != parameters.length() {
        return false
      }
      for index in 0..<parameters.length() {
        if self.arguments[span.start + index] != parameters[index] {
          return false
        }
      }
      true
    }
    _ => false
  }
}

///|
fn ResolvedTypeInterner::intern_function(
  self : ResolvedTypeInterner,
  parameters : Array[ResolvedTypeId],
  result : ResolvedTypeId,
) -> ResolvedTypeId {
  let mut hash = type_hash_mix(0x720001, self.hashes[result])
  for parameter in parameters {
    hash = type_hash_mix(hash, self.hashes[parameter])
  }
  hash = type_hash_mix(hash, parameters.length())
  let mut candidate = self.buckets.get(hash).unwrap_or(-1)
  while candidate >= 0 {
    if self.function_matches(candidate, parameters, result) {
      return candidate
    }
    candidate = self.next[candidate]
  }
  let start = self.arguments.length()
  for parameter in parameters {
    self.arguments.push(parameter)
  }
  self.insert(
    FunctionType({ start, length: parameters.length(), }, result),
    hash,
  )
}

///|
fn ResolvedTypeInterner::intern_applied(
  self : ResolvedTypeInterner,
  base : ResolvedTypeId,
  arguments : Array[ResolvedTypeId],
) -> ResolvedTypeId {
  let mut hash = type_hash_mix(0x710001, self.hashes[base])
  for argument in arguments {
    hash = type_hash_mix(hash, self.hashes[argument])
  }
  hash = type_hash_mix(hash, arguments.length())
  let mut candidate = self.buckets.get(hash).unwrap_or(-1)
  while candidate >= 0 {
    if self.applied_matches(candidate, base, arguments) {
      return candidate
    }
    candidate = self.next[candidate]
  }
  let start = self.arguments.length()
  for argument in arguments {
    self.arguments.push(argument)
  }
  self.insert(AppliedType(base, { start, length: arguments.length(), }), hash)
}
