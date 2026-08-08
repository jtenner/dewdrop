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
fn derived_comparison_impl(
  name : String,
  trait_name : String,
  method_name : String,
  expression : Expr,
  offset : UInt64,
) -> ImplDeclaration {
  let target = NamedType(name, offset)
  {
    foreign_: false,
    type_parameters: [],
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
  expression : Expr,
  offset : UInt64,
) -> Array[ImplDeclaration] {
  [
    derived_comparison_impl(name, "Eq", "eq", expression, offset),
    derived_comparison_impl(
      name,
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
    type_parameters: parameters,
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
fn derived_struct_debug_text(value : StructDeclaration) -> Bytes {
  let output = Buffer()
  output.write_string_utf8(value.name)
  if value.fields.length() == 0 {
    output.write_string_utf8(" {}")
  } else {
    output.write_string_utf8(" { ")
    for index, field in value.fields {
      if index > 0 {
        output.write_string_utf8(", ")
      }
      output.write_string_utf8(field.name)
    }
    output.write_string_utf8(" }")
  }
  output.to_bytes()
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
fn derived_debug_variant_text(
  enum_name : String,
  variant : EnumVariant,
) -> Bytes {
  let output = Buffer()
  output.write_string_utf8(enum_name)
  output.write_string_utf8("::")
  output.write_string_utf8(variant.name())
  match variant {
    UnitVariant(_, _) => ()
    TupleVariant(_, types, _) => {
      output.write_byte(b'(')
      for index in 0..<types.length() {
        if index > 0 {
          output.write_string_utf8(", ")
        }
        output.write_byte(b'_')
      }
      output.write_byte(b')')
    }
    StructVariant(_, fields, _) =>
      if fields.length() == 0 {
        output.write_string_utf8(" {}")
      } else {
        output.write_string_utf8(" { ")
        for index, field in fields {
          if index > 0 {
            output.write_string_utf8(", ")
          }
          output.write_string_utf8(field.name)
        }
        output.write_string_utf8(" }")
      }
  }
  output.to_bytes()
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
pub fn derived_struct_debug_impl(
  value : StructDeclaration,
  offset : UInt64,
) -> ImplDeclaration {
  let body = if value.type_parameters.length() == 0 {
    derived_struct_debug_body(value, offset)
  } else {
    derived_debug_block(
      [derived_debug_write(derived_struct_debug_text(value), offset)],
      offset,
    )
  }
  derived_debug_impl(value.name, value.type_parameters, body, offset)
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
    let body = if value.type_parameters.length() == 0 {
      BlockExpr(derived_debug_variant_body(value.name, variant, names, offset))
    } else {
      derived_debug_write(
        derived_debug_variant_text(value.name, variant),
        offset,
      )
    }
    arms.push({ pattern, guard_condition: None, body, offset })
  }
  derived_debug_impl(
    value.name,
    value.type_parameters,
    derived_debug_block(
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
    derived_enum_eq_expression(value.name, value.variants, offset),
    offset,
  )
}
