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
