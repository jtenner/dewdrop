///|
fn derived_eq_expression(
  left_names : Array[String],
  right_names : Array[String],
  offset : UInt64,
) -> Expr {
  let mut result : Expr = BoolExpr(true, offset)
  for index, left in left_names {
    let equal = BinaryExpr(
      Equal,
      NameExpr(left, offset),
      NameExpr(right_names[index], offset),
      offset,
    )
    result = BinaryExpr(LogicalAnd, result, equal, offset)
  }
  result
}

///|
fn derived_struct_eq_expression(
  fields : Array[StructField],
  offset : UInt64,
) -> Expr {
  let mut result : Expr = BoolExpr(true, offset)
  for field in fields {
    let equal = BinaryExpr(
      Equal,
      FieldExpr(NameExpr("self", offset), field.name, offset),
      FieldExpr(NameExpr("right", offset), field.name, offset),
      offset,
    )
    result = BinaryExpr(LogicalAnd, result, equal, offset)
  }
  result
}

///|
fn derived_variant_pattern(
  enum_name : String,
  variant : EnumVariant,
  prefix : String,
  offset : UInt64,
) -> (Pattern, Array[String]) {
  let base = QualifiedPattern(
    BindingPattern(enum_name, offset),
    variant.name(),
    offset,
  )
  let names : Array[String] = []
  match variant {
    UnitVariant(_, _) => (base, names)
    TupleVariant(_, types, _) => {
      let patterns : Array[Pattern] = []
      for index in 0..<types.length() {
        let name = prefix + index.to_string()
        names.push(name)
        patterns.push(BindingPattern(name, offset))
      }
      (TuplePattern(base, patterns, offset), names)
    }
    StructVariant(_, fields, _) => {
      let patterns : Array[PatternField] = []
      for index, field in fields {
        let name = prefix + index.to_string()
        names.push(name)
        patterns.push({
          name: field.name,
          pattern: BindingPattern(name, offset),
          offset,
        })
      }
      (StructPattern(base, patterns, None, offset), names)
    }
  }
}

///|
fn derived_enum_eq_expression(
  enum_name : String,
  variants : Array[EnumVariant],
  offset : UInt64,
) -> Expr {
  let outer_arms : Array[PatternArm] = []
  for index, variant in variants {
    let (left_pattern, left_names) = derived_variant_pattern(
      enum_name,
      variant,
      "derive_left_" + index.to_string() + "_",
      offset,
    )
    let (right_pattern, right_names) = derived_variant_pattern(
      enum_name,
      variant,
      "derive_right_" + index.to_string() + "_",
      offset,
    )
    let inner_arms : Array[PatternArm] = [
      {
        pattern: right_pattern,
        guard_condition: None,
        body: derived_eq_expression(left_names, right_names, offset),
        offset,
      },
      {
        pattern: WildcardPattern(offset),
        guard_condition: None,
        body: BoolExpr(false, offset),
        offset,
      },
    ]
    outer_arms.push({
      pattern: left_pattern,
      guard_condition: None,
      body: MatchExpr(NameExpr("right", offset), inner_arms, offset),
      offset,
    })
  }
  MatchExpr(NameExpr("self", offset), outer_arms, offset)
}

///|
fn derived_type_mentions_parameter(
  type_ : TypeExpr,
  parameter : String,
) -> Bool {
  match type_ {
    NamedType(name, _) => name == parameter
    AppliedType(base, arguments, _) => {
      if derived_type_mentions_parameter(base, parameter) {
        return true
      }
      for argument in arguments {
        if derived_type_mentions_parameter(argument, parameter) {
          return true
        }
      }
      false
    }
    FunctionType(parameters, result, _) => {
      for type_ in parameters {
        if derived_type_mentions_parameter(type_, parameter) {
          return true
        }
      }
      derived_type_mentions_parameter(result, parameter)
    }
  }
}

///|
fn derived_trait_type_parameters(
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  trait_name : String,
  offset : UInt64,
) -> Array[TypeParameter] {
  let result : Array[TypeParameter] = []
  for parameter in parameters {
    let mut required = false
    for type_ in field_types {
      if derived_type_mentions_parameter(type_, parameter.name) {
        required = true
        break
      }
    }
    let bounds = parameter.bounds.copy()
    if required {
      let mut has_trait = false
      for bound in bounds {
        match bound {
          NamedType(name, _) if name == trait_name => has_trait = true
          _ => ()
        }
      }
      if !has_trait {
        bounds.push(NamedType(trait_name, offset))
      }
    }
    result.push({ ..parameter, bounds, })
  }
  result
}

///|
fn derived_comparison_impl(
  name : String,
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  trait_name : String,
  method_name : String,
  expression : Expr,
  offset : UInt64,
) -> ImplDeclaration {
  let target = derived_nominal_type(name, parameters, offset)
  {
    foreign_: false,
    type_parameters: derived_trait_type_parameters(
      parameters, field_types, "Eq", offset,
    ),
    trait_type: Some(NamedType(trait_name, offset)),
    target_type: target,
    methods: [
      {
        visibility: ModuleVisible,
        name: method_name,
        name_offset: offset,
        type_parameters: [],
        receiver: Some({ explicit_type: None, offset }),
        parameters: [{ name: "right", type_: target, offset }],
        return_type: NamedType("Bool", offset),
        body: { items: [ExpressionItem(expression, offset)], offset },
        offset,
      },
    ],
    offset,
  }
}

///|
fn derived_eq_impls(
  name : String,
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  expression : Expr,
  offset : UInt64,
) -> Array[ImplDeclaration] {
  [
    derived_comparison_impl(
      name, parameters, field_types, "Eq", "eq", expression, offset,
    ),
    derived_comparison_impl(
      name,
      parameters,
      field_types,
      "Ne",
      "ne",
      PrefixExpr(
        LogicalNot,
        BinaryExpr(
          Equal,
          NameExpr("self", offset),
          NameExpr("right", offset),
          offset,
        ),
        offset,
      ),
      offset,
    ),
  ]
}

///|
fn derived_hash_call(value : Expr, offset : UInt64) -> Expr {
  CallExpr(FieldExpr(value, "hash", offset), [], offset)
}

///|
fn derived_hash_eq_call(left : Expr, right : Expr, offset : UInt64) -> Expr {
  CallExpr(FieldExpr(left, "hash_eq", offset), [right], offset)
}

///|
fn derived_hash_mix(state : Expr, value : Expr, offset : UInt64) -> Expr {
  BinaryExpr(
    Multiply,
    BinaryExpr(BitXor, state, value, offset),
    U64Expr(1099511628211UL, offset),
    offset,
  )
}

///|
fn derived_struct_hash_expression(
  fields : Array[StructField],
  offset : UInt64,
) -> Expr {
  let mut result : Expr = U64Expr(14695981039346656037UL, offset)
  for field in fields {
    result = derived_hash_mix(
      result,
      derived_hash_call(
        FieldExpr(NameExpr("self", offset), field.name, offset),
        offset,
      ),
      offset,
    )
  }
  result
}

///|
fn derived_struct_hash_eq_expression(
  fields : Array[StructField],
  offset : UInt64,
) -> Expr {
  let mut result : Expr = BoolExpr(true, offset)
  for field in fields {
    let equal = derived_hash_eq_call(
      FieldExpr(NameExpr("self", offset), field.name, offset),
      FieldExpr(NameExpr("right", offset), field.name, offset),
      offset,
    )
    result = BinaryExpr(LogicalAnd, result, equal, offset)
  }
  result
}

///|
fn derived_hash_eq_expression(
  left_names : Array[String],
  right_names : Array[String],
  offset : UInt64,
) -> Expr {
  let mut result : Expr = BoolExpr(true, offset)
  for index, left in left_names {
    result = BinaryExpr(
      LogicalAnd,
      result,
      derived_hash_eq_call(
        NameExpr(left, offset),
        NameExpr(right_names[index], offset),
        offset,
      ),
      offset,
    )
  }
  result
}

///|
fn derived_enum_hash_expression(
  enum_name : String,
  variants : Array[EnumVariant],
  offset : UInt64,
) -> Expr {
  let arms : Array[PatternArm] = []
  for index, variant in variants {
    let (pattern, names) = derived_variant_pattern(
      enum_name,
      variant,
      "derive_hash_" + index.to_string() + "_",
      offset,
    )
    let mut result : Expr = derived_hash_mix(
      U64Expr(14695981039346656037UL, offset),
      U64Expr(index.reinterpret_as_uint().to_uint64(), offset),
      offset,
    )
    for name in names {
      result = derived_hash_mix(
        result,
        derived_hash_call(NameExpr(name, offset), offset),
        offset,
      )
    }
    arms.push({ pattern, guard_condition: None, body: result, offset })
  }
  MatchExpr(NameExpr("self", offset), arms, offset)
}

///|
fn derived_enum_hash_eq_expression(
  enum_name : String,
  variants : Array[EnumVariant],
  offset : UInt64,
) -> Expr {
  let outer_arms : Array[PatternArm] = []
  for index, variant in variants {
    let (left_pattern, left_names) = derived_variant_pattern(
      enum_name,
      variant,
      "derive_hash_eq_left_" + index.to_string() + "_",
      offset,
    )
    let (right_pattern, right_names) = derived_variant_pattern(
      enum_name,
      variant,
      "derive_hash_eq_right_" + index.to_string() + "_",
      offset,
    )
    let inner_arms : Array[PatternArm] = [
      {
        pattern: right_pattern,
        guard_condition: None,
        body: derived_hash_eq_expression(left_names, right_names, offset),
        offset,
      },
      {
        pattern: WildcardPattern(offset),
        guard_condition: None,
        body: BoolExpr(false, offset),
        offset,
      },
    ]
    outer_arms.push({
      pattern: left_pattern,
      guard_condition: None,
      body: MatchExpr(NameExpr("right", offset), inner_arms, offset),
      offset,
    })
  }
  MatchExpr(NameExpr("self", offset), outer_arms, offset)
}

///|
fn derived_hash_impl(
  name : String,
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  hash_expression : Expr,
  hash_eq_expression : Expr,
  offset : UInt64,
) -> ImplDeclaration {
  let target = derived_nominal_type(name, parameters, offset)
  {
    foreign_: false,
    type_parameters: derived_trait_type_parameters(
      parameters, field_types, "Hash", offset,
    ),
    trait_type: Some(NamedType("Hash", offset)),
    target_type: target,
    methods: [
      {
        visibility: ModuleVisible,
        name: "hash",
        name_offset: offset,
        type_parameters: [],
        receiver: Some({ explicit_type: None, offset }),
        parameters: [],
        return_type: NamedType("U64", offset),
        body: { items: [ExpressionItem(hash_expression, offset)], offset },
        offset,
      },
      {
        visibility: ModuleVisible,
        name: "hash_eq",
        name_offset: offset,
        type_parameters: [],
        receiver: Some({ explicit_type: None, offset }),
        parameters: [{ name: "right", type_: target, offset }],
        return_type: NamedType("Bool", offset),
        body: { items: [ExpressionItem(hash_eq_expression, offset)], offset },
        offset,
      },
    ],
    offset,
  }
}

///|
fn derived_nominal_type(
  name : String,
  parameters : Array[TypeParameter],
  offset : UInt64,
) -> TypeExpr {
  let base = NamedType(name, offset)
  if parameters.length() == 0 {
    return base
  }
  let arguments : Array[TypeExpr] = []
  for parameter in parameters {
    arguments.push(NamedType(parameter.name, parameter.offset))
  }
  AppliedType(base, arguments, offset)
}

///|
fn derived_debug_impl(
  name : String,
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  body : Block,
  offset : UInt64,
) -> ImplDeclaration {
  let target = derived_nominal_type(name, parameters, offset)
  let unit_body = {
    items: [
      ExpressionItem(
        CallExpr(
          NameExpr("__dew_debug_ignore", offset),
          [BlockExpr(body)],
          offset,
        ),
        offset,
      ),
    ],
    offset,
  }
  {
    foreign_: false,
    type_parameters: derived_trait_type_parameters(
      parameters, field_types, "Debug", offset,
    ),
    trait_type: Some(NamedType("Debug", offset)),
    target_type: target,
    methods: [
      {
        visibility: ModuleVisible,
        name: "debug",
        name_offset: offset,
        type_parameters: [],
        receiver: Some({ explicit_type: None, offset }),
        parameters: [],
        return_type: NamedType("Unit", offset),
        body: unit_body,
        offset,
      },
    ],
    offset,
  }
}

///|
fn derived_debug_utf8(value : String) -> Bytes {
  let output = Buffer()
  output.write_string_utf8(value)
  output.to_bytes()
}

///|
fn derived_debug_write(value : Bytes, offset : UInt64) -> Expr {
  CallExpr(
    NameExpr("__dew_debug_write", offset),
    [U32Expr(1UL, offset), BytesExpr(value, offset)],
    offset,
  )
}

///|
fn derived_debug_value(value : Expr, offset : UInt64) -> Expr {
  CallExpr(NameExpr("debug", offset), [value], offset)
}

///|
fn derived_debug_block(expressions : Array[Expr], offset : UInt64) -> Block {
  let items : Array[BlockItem] = []
  for expression in expressions {
    items.push(ExpressionItem(expression, offset))
  }
  { items, offset }
}

///|
fn derived_struct_debug_body(
  value : StructDeclaration,
  offset : UInt64,
) -> Block {
  if value.fields.length() == 0 {
    return derived_debug_block(
      [derived_debug_write(derived_debug_utf8(value.name + " {}"), offset)],
      offset,
    )
  }
  let expressions : Array[Expr] = [
    derived_debug_write(derived_debug_utf8(value.name + " { "), offset),
  ]
  for index, field in value.fields {
    let label = if index == 0 {
      field.name + ": "
    } else {
      ", " + field.name + ": "
    }
    expressions.push(derived_debug_write(derived_debug_utf8(label), offset))
    expressions.push(
      derived_debug_value(
        FieldExpr(NameExpr("self", offset), field.name, offset),
        offset,
      ),
    )
  }
  expressions.push(derived_debug_write(b" }", offset))
  derived_debug_block(expressions, offset)
}

///|
fn derived_debug_variant_pattern(
  enum_name : String,
  variant : EnumVariant,
  variant_index : Int,
  offset : UInt64,
) -> (Pattern, Array[String]) {
  let base = QualifiedPattern(
    BindingPattern(enum_name, offset),
    variant.name(),
    offset,
  )
  let names : Array[String] = []
  match variant {
    UnitVariant(_, _) => (base, names)
    TupleVariant(_, types, _) => {
      let patterns : Array[Pattern] = []
      for index in 0..<types.length() {
        let name = "derive_debug_" +
          variant_index.to_string() +
          "_" +
          index.to_string()
        names.push(name)
        patterns.push(BindingPattern(name, offset))
      }
      (TuplePattern(base, patterns, offset), names)
    }
    StructVariant(_, fields, _) => {
      let patterns : Array[PatternField] = []
      for index, field in fields {
        let name = "derive_debug_" +
          variant_index.to_string() +
          "_" +
          index.to_string()
        names.push(name)
        patterns.push({
          name: field.name,
          pattern: BindingPattern(name, offset),
          offset,
        })
      }
      (StructPattern(base, patterns, None, offset), names)
    }
  }
}

///|
fn derived_debug_variant_body(
  enum_name : String,
  variant : EnumVariant,
  names : Array[String],
  offset : UInt64,
) -> Block {
  let prefix = enum_name + "::" + variant.name()
  let expressions : Array[Expr] = []
  match variant {
    UnitVariant(_, _) =>
      expressions.push(derived_debug_write(derived_debug_utf8(prefix), offset))
    TupleVariant(_, types, _) => {
      expressions.push(
        derived_debug_write(derived_debug_utf8(prefix + "("), offset),
      )
      for index in 0..<types.length() {
        if index > 0 {
          expressions.push(derived_debug_write(b", ", offset))
        }
        expressions.push(
          derived_debug_value(NameExpr(names[index], offset), offset),
        )
      }
      expressions.push(derived_debug_write(b")", offset))
    }
    StructVariant(_, fields, _) =>
      if fields.length() == 0 {
        expressions.push(
          derived_debug_write(derived_debug_utf8(prefix + " {}"), offset),
        )
      } else {
        expressions.push(
          derived_debug_write(derived_debug_utf8(prefix + " { "), offset),
        )
        for index, field in fields {
          let label = if index == 0 {
            field.name + ": "
          } else {
            ", " + field.name + ": "
          }
          expressions.push(
            derived_debug_write(derived_debug_utf8(label), offset),
          )
          expressions.push(
            derived_debug_value(NameExpr(names[index], offset), offset),
          )
        }
        expressions.push(derived_debug_write(b" }", offset))
      }
  }
  derived_debug_block(expressions, offset)
}

///|
fn derived_show_append_text(value : String, offset : UInt64) -> Expr {
  let bytes = Buffer()
  bytes.write_string_utf8(value)
  CallExpr(
    NameExpr("show_append_text", offset),
    [NameExpr("builder", offset), StringExpr(bytes.to_bytes(), offset)],
    offset,
  )
}

///|
fn derived_show_append_value(value : Expr, offset : UInt64) -> Expr {
  CallExpr(
    NameExpr("show_append", offset),
    [NameExpr("builder", offset), value],
    offset,
  )
}

///|
fn derived_show_block(expressions : Array[Expr], offset : UInt64) -> Block {
  let items : Array[BlockItem] = []
  for expression in expressions {
    items.push(ExpressionItem(expression, offset))
  }
  { items, offset }
}

///|
fn derived_struct_show_body(
  value : StructDeclaration,
  offset : UInt64,
) -> Block {
  if value.fields.length() == 0 {
    return derived_show_block(
      [derived_show_append_text(value.name + " {}", offset)],
      offset,
    )
  }
  let expressions : Array[Expr] = [
    derived_show_append_text(value.name + " { ", offset),
  ]
  for index, field in value.fields {
    let label = if index == 0 {
      field.name + ": "
    } else {
      ", " + field.name + ": "
    }
    expressions.push(derived_show_append_text(label, offset))
    expressions.push(
      derived_show_append_value(
        FieldExpr(NameExpr("self", offset), field.name, offset),
        offset,
      ),
    )
  }
  expressions.push(derived_show_append_text(" }", offset))
  derived_show_block(expressions, offset)
}

///|
fn derived_show_variant_body(
  enum_name : String,
  variant : EnumVariant,
  names : Array[String],
  offset : UInt64,
) -> Block {
  let prefix = enum_name + "::" + variant.name()
  let expressions : Array[Expr] = []
  match variant {
    UnitVariant(_, _) =>
      expressions.push(derived_show_append_text(prefix, offset))
    TupleVariant(_, types, _) => {
      expressions.push(derived_show_append_text(prefix + "(", offset))
      for index in 0..<types.length() {
        if index > 0 {
          expressions.push(derived_show_append_text(", ", offset))
        }
        expressions.push(
          derived_show_append_value(NameExpr(names[index], offset), offset),
        )
      }
      expressions.push(derived_show_append_text(")", offset))
    }
    StructVariant(_, fields, _) =>
      if fields.length() == 0 {
        expressions.push(derived_show_append_text(prefix + " {}", offset))
      } else {
        expressions.push(derived_show_append_text(prefix + " { ", offset))
        for index, field in fields {
          let label = if index == 0 {
            field.name + ": "
          } else {
            ", " + field.name + ": "
          }
          expressions.push(derived_show_append_text(label, offset))
          expressions.push(
            derived_show_append_value(NameExpr(names[index], offset), offset),
          )
        }
        expressions.push(derived_show_append_text(" }", offset))
      }
  }
  derived_show_block(expressions, offset)
}

///|
fn derived_show_impl(
  name : String,
  parameters : Array[TypeParameter],
  field_types : Array[TypeExpr],
  body : Block,
  offset : UInt64,
) -> ImplDeclaration {
  let target = derived_nominal_type(name, parameters, offset)
  {
    foreign_: false,
    type_parameters: derived_trait_type_parameters(
      parameters, field_types, "Show", offset,
    ),
    trait_type: Some(NamedType("Show", offset)),
    target_type: target,
    methods: [
      {
        visibility: ModuleVisible,
        name: "append_show",
        name_offset: offset,
        type_parameters: [],
        receiver: Some({ explicit_type: None, offset }),
        parameters: [
          { name: "builder", type_: NamedType("StringBuilder", offset), offset },
        ],
        return_type: NamedType("Unit", offset),
        body,
        offset,
      },
    ],
    offset,
  }
}

///|
fn derived_struct_field_types(value : StructDeclaration) -> Array[TypeExpr] {
  let field_types : Array[TypeExpr] = []
  for field in value.fields {
    field_types.push(field.type_)
  }
  field_types
}

///|
fn derived_enum_field_types(value : EnumDeclaration) -> Array[TypeExpr] {
  let field_types : Array[TypeExpr] = []
  for variant in value.variants {
    match variant {
      UnitVariant(_, _) => ()
      TupleVariant(_, types, _) =>
        for type_ in types {
          field_types.push(type_)
        }
      StructVariant(_, fields, _) =>
        for field in fields {
          field_types.push(field.type_)
        }
    }
  }
  field_types
}

///|
pub fn derived_struct_debug_impl(
  value : StructDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  derived_debug_impl(
    value.name,
    value.type_parameters,
    derived_struct_field_types(value),
    derived_struct_debug_body(value, offset),
    offset,
  )
}

///|
pub fn derived_enum_debug_impl(
  value : EnumDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  let arms : Array[PatternArm] = []
  for index, variant in value.variants {
    let (pattern, names) = derived_debug_variant_pattern(
      value.name,
      variant,
      index,
      offset,
    )
    let body = BlockExpr(
      derived_debug_variant_body(value.name, variant, names, offset),
    )
    arms.push({ pattern, guard_condition: None, body, offset })
  }
  derived_debug_impl(
    value.name,
    value.type_parameters,
    derived_enum_field_types(value),
    derived_debug_block(
      [MatchExpr(NameExpr("self", offset), arms, offset)],
      offset,
    ),
    offset,
  )
}

///|
pub fn derived_struct_show_impl(
  value : StructDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  derived_show_impl(
    value.name,
    value.type_parameters,
    derived_struct_field_types(value),
    derived_struct_show_body(value, offset),
    offset,
  )
}

///|
pub fn derived_enum_show_impl(
  value : EnumDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  let arms : Array[PatternArm] = []
  for index, variant in value.variants {
    let (pattern, names) = derived_debug_variant_pattern(
      value.name,
      variant,
      index,
      offset,
    )
    arms.push({
      pattern,
      guard_condition: None,
      body: BlockExpr(
        derived_show_variant_body(value.name, variant, names, offset),
      ),
      offset,
    })
  }
  derived_show_impl(
    value.name,
    value.type_parameters,
    derived_enum_field_types(value),
    derived_show_block(
      [MatchExpr(NameExpr("self", offset), arms, offset)],
      offset,
    ),
    offset,
  )
}

///|
pub fn derived_struct_eq_impls(
  value : StructDeclaration,
  offset : UInt64,
) -> Array[ImplDeclaration] {
  derived_eq_impls(
    value.name,
    value.type_parameters,
    derived_struct_field_types(value),
    derived_struct_eq_expression(value.fields, offset),
    offset,
  )
}

///|
pub fn derived_enum_eq_impls(
  value : EnumDeclaration,
  offset : UInt64,
) -> Array[ImplDeclaration] {
  derived_eq_impls(
    value.name,
    value.type_parameters,
    derived_enum_field_types(value),
    derived_enum_eq_expression(value.name, value.variants, offset),
    offset,
  )
}

///|
pub fn derived_struct_hash_impl(
  value : StructDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  derived_hash_impl(
    value.name,
    value.type_parameters,
    derived_struct_field_types(value),
    derived_struct_hash_expression(value.fields, offset),
    derived_struct_hash_eq_expression(value.fields, offset),
    offset,
  )
}

///|
pub fn derived_enum_hash_impl(
  value : EnumDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  derived_hash_impl(
    value.name,
    value.type_parameters,
    derived_enum_field_types(value),
    derived_enum_hash_expression(value.name, value.variants, offset),
    derived_enum_hash_eq_expression(value.name, value.variants, offset),
    offset,
  )
}
