///|
/// Parser-event payload schema version.
let parse_event_payload_version = 1U

///|
/// Conservative recursive syntax depth accepted from persistent artifacts.
let parse_event_maximum_depth = 2048

///|
/// Conservative array and text limits for one parser-event artifact.
let parse_event_maximum_items = 0x00100000

///|
let parse_event_maximum_text = 0x01000000

///|
let parse_event_maximum_bytes = 0x10000000

///|
fn parse_write_offset(writer : @cache_binary.Writer, value : UInt64) -> Unit {
  writer.write_var_u64(value)
}

///|
fn parse_read_offset(reader : @cache_binary.Reader, field : String) -> UInt64 {
  reader.read_var_u64(field)
}

///|
fn parse_write_option_tag(
  writer : @cache_binary.Writer,
  present : Bool,
) -> Unit {
  writer.write_option_tag(present)
}

///|
fn parse_write_keyword(
  writer : @cache_binary.Writer,
  value : @tokenizer.Keyword,
) -> Unit {
  writer.write_byte(
    match value {
      @tokenizer.Fn => 0
      @tokenizer.Test => 1
      @tokenizer.Pub => 2
      @tokenizer.Builtin => 3
      @tokenizer.Foreign => 4
      @tokenizer.Impl => 5
      @tokenizer.Trait => 6
      @tokenizer.For => 7
      @tokenizer.Enum => 8
      @tokenizer.Struct => 9
      @tokenizer.Type => 10
      @tokenizer.Let => 11
      @tokenizer.Using => 12
      @tokenizer.Mut => 13
      @tokenizer.If => 14
      @tokenizer.Else => 15
      @tokenizer.Match => 16
      @tokenizer.Is => 17
      @tokenizer.While => 18
      @tokenizer.Loop => 19
      @tokenizer.Return => 20
      @tokenizer.Defer => 21
      @tokenizer.Break => 22
      @tokenizer.Continue => 23
      @tokenizer.True => 24
      @tokenizer.False => 25
      @tokenizer.As => 26
      @tokenizer.In => 27
      @tokenizer.Where => 28
      @tokenizer.Open => 29
      @tokenizer.Import => 30
      @tokenizer.Export => 31
      @tokenizer.Package => 32
    },
  )
}

///|
fn parse_read_keyword(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.Keyword {
  match reader.read_byte(field) {
    0 => @tokenizer.Fn
    1 => @tokenizer.Test
    2 => @tokenizer.Pub
    3 => @tokenizer.Builtin
    4 => @tokenizer.Foreign
    5 => @tokenizer.Impl
    6 => @tokenizer.Trait
    7 => @tokenizer.For
    8 => @tokenizer.Enum
    9 => @tokenizer.Struct
    10 => @tokenizer.Type
    11 => @tokenizer.Let
    12 => @tokenizer.Using
    13 => @tokenizer.Mut
    14 => @tokenizer.If
    15 => @tokenizer.Else
    16 => @tokenizer.Match
    17 => @tokenizer.Is
    18 => @tokenizer.While
    19 => @tokenizer.Loop
    20 => @tokenizer.Return
    21 => @tokenizer.Defer
    22 => @tokenizer.Break
    23 => @tokenizer.Continue
    24 => @tokenizer.True
    25 => @tokenizer.False
    26 => @tokenizer.As
    27 => @tokenizer.In
    28 => @tokenizer.Where
    29 => @tokenizer.Open
    30 => @tokenizer.Import
    31 => @tokenizer.Export
    32 => @tokenizer.Package
    _ => {
      reader.fail(field, "unknown keyword discriminant")
      @tokenizer.Fn
    }
  }
}

///|
fn parse_write_symbol(
  writer : @cache_binary.Writer,
  value : @tokenizer.Symbol,
) -> Unit {
  writer.write_byte(
    match value {
      @tokenizer.LeftParen => 0
      @tokenizer.RightParen => 1
      @tokenizer.LeftBrace => 2
      @tokenizer.RightBrace => 3
      @tokenizer.LeftBracket => 4
      @tokenizer.RightBracket => 5
      @tokenizer.Caret => 6
      @tokenizer.Plus => 7
      @tokenizer.Minus => 8
      @tokenizer.Star => 9
      @tokenizer.Slash => 10
      @tokenizer.Exponent => 11
      @tokenizer.Percent => 12
      @tokenizer.Colon => 13
      @tokenizer.DoubleColon => 14
      @tokenizer.Equal => 15
      @tokenizer.EqualEqual => 16
      @tokenizer.FatArrow => 17
      @tokenizer.BangEqual => 18
      @tokenizer.LessEqual => 19
      @tokenizer.GreaterEqual => 20
      @tokenizer.ShiftLeft => 21
      @tokenizer.ShiftRight => 22
      @tokenizer.LogicalAnd => 23
      @tokenizer.LogicalOr => 24
      @tokenizer.Comma => 25
      @tokenizer.Semicolon => 26
      @tokenizer.Dot => 27
      @tokenizer.Ellipsis => 28
      @tokenizer.Less => 29
      @tokenizer.Greater => 30
      @tokenizer.Arrow => 31
      @tokenizer.Bang => 32
      @tokenizer.Ampersand => 33
      @tokenizer.Pipe => 34
    },
  )
}

///|
fn parse_read_symbol(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.Symbol {
  match reader.read_byte(field) {
    0 => @tokenizer.LeftParen
    1 => @tokenizer.RightParen
    2 => @tokenizer.LeftBrace
    3 => @tokenizer.RightBrace
    4 => @tokenizer.LeftBracket
    5 => @tokenizer.RightBracket
    6 => @tokenizer.Caret
    7 => @tokenizer.Plus
    8 => @tokenizer.Minus
    9 => @tokenizer.Star
    10 => @tokenizer.Slash
    11 => @tokenizer.Exponent
    12 => @tokenizer.Percent
    13 => @tokenizer.Colon
    14 => @tokenizer.DoubleColon
    15 => @tokenizer.Equal
    16 => @tokenizer.EqualEqual
    17 => @tokenizer.FatArrow
    18 => @tokenizer.BangEqual
    19 => @tokenizer.LessEqual
    20 => @tokenizer.GreaterEqual
    21 => @tokenizer.ShiftLeft
    22 => @tokenizer.ShiftRight
    23 => @tokenizer.LogicalAnd
    24 => @tokenizer.LogicalOr
    25 => @tokenizer.Comma
    26 => @tokenizer.Semicolon
    27 => @tokenizer.Dot
    28 => @tokenizer.Ellipsis
    29 => @tokenizer.Less
    30 => @tokenizer.Greater
    31 => @tokenizer.Arrow
    32 => @tokenizer.Bang
    33 => @tokenizer.Ampersand
    34 => @tokenizer.Pipe
    _ => {
      reader.fail(field, "unknown symbol discriminant")
      @tokenizer.LeftParen
    }
  }
}

///|
fn parse_write_lex_error(
  writer : @cache_binary.Writer,
  value : @tokenizer.LexError,
) -> Unit {
  match value {
    @tokenizer.UnexpectedUnit(unit) => {
      writer.write_byte(0)
      writer.write_u32_le(unit)
    }
    @tokenizer.InvalidAtIdentifier => writer.write_byte(1)
    @tokenizer.InvalidInteger(text) => {
      writer.write_byte(2)
      writer.write_string(text)
    }
    @tokenizer.InvalidFloat(text) => {
      writer.write_byte(3)
      writer.write_string(text)
    }
    @tokenizer.InvalidEscape(unit) => {
      writer.write_byte(4)
      writer.write_u32_le(unit)
    }
    @tokenizer.UnterminatedString => writer.write_byte(5)
    @tokenizer.SourceIo(code) => {
      writer.write_byte(6)
      writer.write_zigzag_int(code)
    }
  }
}

///|
fn parse_read_lex_error(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.LexError {
  match reader.read_byte(field) {
    0 => @tokenizer.UnexpectedUnit(reader.read_u32_le(field + ".unit"))
    1 => @tokenizer.InvalidAtIdentifier
    2 =>
      @tokenizer.InvalidInteger(
        reader.read_string(parse_event_maximum_text, field + ".integer"),
      )
    3 =>
      @tokenizer.InvalidFloat(
        reader.read_string(parse_event_maximum_text, field + ".float"),
      )
    4 => @tokenizer.InvalidEscape(reader.read_u32_le(field + ".unit"))
    5 => @tokenizer.UnterminatedString
    6 => @tokenizer.SourceIo(reader.read_zigzag_int(field + ".code"))
    _ => {
      reader.fail(field, "unknown lexical-error discriminant")
      @tokenizer.UnterminatedString
    }
  }
}

///|
fn parse_write_token_kind(
  writer : @cache_binary.Writer,
  value : @tokenizer.TokenKind,
) -> Unit {
  match value {
    @tokenizer.Newline => writer.write_byte(0)
    @tokenizer.Symbol(value) => {
      writer.write_byte(1)
      parse_write_symbol(writer, value)
    }
    @tokenizer.Keyword(value) => {
      writer.write_byte(2)
      parse_write_keyword(writer, value)
    }
    @tokenizer.Identifier(value) => {
      writer.write_byte(3)
      writer.write_string(value)
    }
    @tokenizer.AtIdentifier(value) => {
      writer.write_byte(4)
      writer.write_string(value)
    }
    @tokenizer.I8(value) => {
      writer.write_byte(5)
      writer.write_var_u64(value)
    }
    @tokenizer.I16(value) => {
      writer.write_byte(6)
      writer.write_var_u64(value)
    }
    @tokenizer.I32(value) => {
      writer.write_byte(7)
      writer.write_var_u64(value)
    }
    @tokenizer.I64(value) => {
      writer.write_byte(8)
      writer.write_var_u64(value)
    }
    @tokenizer.U8(value) => {
      writer.write_byte(9)
      writer.write_var_u64(value)
    }
    @tokenizer.U16(value) => {
      writer.write_byte(10)
      writer.write_var_u64(value)
    }
    @tokenizer.U32(value) => {
      writer.write_byte(11)
      writer.write_var_u64(value)
    }
    @tokenizer.U64(value) => {
      writer.write_byte(12)
      writer.write_var_u64(value)
    }
    @tokenizer.F32(value) => {
      writer.write_byte(13)
      writer.write_f32(value)
    }
    @tokenizer.F64(value) => {
      writer.write_byte(14)
      writer.write_f64(value)
    }
    @tokenizer.StringLiteral(value) => {
      writer.write_byte(15)
      writer.write_bytes(value)
    }
    @tokenizer.BytesLiteral(value) => {
      writer.write_byte(16)
      writer.write_bytes(value)
    }
    @tokenizer.MultilineString(value) => {
      writer.write_byte(17)
      writer.write_bytes(value)
    }
    @tokenizer.Error(value) => {
      writer.write_byte(18)
      parse_write_lex_error(writer, value)
    }
  }
}

///|
fn parse_read_token_kind(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.TokenKind {
  match reader.read_byte(field) {
    0 => @tokenizer.Newline
    1 => @tokenizer.Symbol(parse_read_symbol(reader, field + ".symbol"))
    2 => @tokenizer.Keyword(parse_read_keyword(reader, field + ".keyword"))
    3 =>
      @tokenizer.Identifier(
        reader.read_string(parse_event_maximum_text, field + ".identifier"),
      )
    4 =>
      @tokenizer.AtIdentifier(
        reader.read_string(parse_event_maximum_text, field + ".at_identifier"),
      )
    5 => @tokenizer.I8(reader.read_var_u64(field + ".i8"))
    6 => @tokenizer.I16(reader.read_var_u64(field + ".i16"))
    7 => @tokenizer.I32(reader.read_var_u64(field + ".i32"))
    8 => @tokenizer.I64(reader.read_var_u64(field + ".i64"))
    9 => @tokenizer.U8(reader.read_var_u64(field + ".u8"))
    10 => @tokenizer.U16(reader.read_var_u64(field + ".u16"))
    11 => @tokenizer.U32(reader.read_var_u64(field + ".u32"))
    12 => @tokenizer.U64(reader.read_var_u64(field + ".u64"))
    13 => @tokenizer.F32(reader.read_f32(field + ".f32"))
    14 => @tokenizer.F64(reader.read_f64(field + ".f64"))
    15 =>
      @tokenizer.StringLiteral(
        reader.read_bytes(parse_event_maximum_bytes, field + ".string"),
      )
    16 =>
      @tokenizer.BytesLiteral(
        reader.read_bytes(parse_event_maximum_bytes, field + ".bytes"),
      )
    17 =>
      @tokenizer.MultilineString(
        reader.read_bytes(parse_event_maximum_bytes, field + ".multiline"),
      )
    18 => @tokenizer.Error(parse_read_lex_error(reader, field + ".error"))
    _ => {
      reader.fail(field, "unknown token-kind discriminant")
      @tokenizer.Newline
    }
  }
}

///|
fn parse_write_token(
  writer : @cache_binary.Writer,
  token : @tokenizer.Token,
) -> Unit {
  parse_write_token_kind(writer, token.kind())
  parse_write_offset(writer, token.offset())
  writer.write_zigzag_int(token.index())
}

///|
fn parse_read_token(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.Token {
  @tokenizer.Token::new(
    parse_read_token_kind(reader, field + ".kind"),
    parse_read_offset(reader, field + ".offset"),
    reader.read_zigzag_int(field + ".index"),
  )
}

///|
fn parse_write_optional_token(
  writer : @cache_binary.Writer,
  token : @tokenizer.Token?,
) -> Unit {
  match token {
    Some(value) => {
      parse_write_option_tag(writer, true)
      parse_write_token(writer, value)
    }
    None => parse_write_option_tag(writer, false)
  }
}

///|
fn parse_read_optional_token(
  reader : @cache_binary.Reader,
  field : String,
) -> @tokenizer.Token? {
  if reader.read_option_tag(field + ".tag") {
    Some(parse_read_token(reader, field + ".value"))
  } else {
    None
  }
}

///|
fn parse_write_visibility(
  writer : @cache_binary.Writer,
  value : DeclarationVisibility,
) -> Unit {
  writer.write_byte(
    match value {
      ModuleVisible => 0
      Public => 1
    },
  )
}

///|
fn parse_read_visibility(
  reader : @cache_binary.Reader,
  field : String,
) -> DeclarationVisibility {
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
fn parse_write_type(writer : @cache_binary.Writer, value : TypeExpr) -> Unit {
  match value {
    ComputedType(target, selector, offset) => {
      writer.write_byte(5)
      parse_write_type(writer, target)
      writer.write_bytes(selector)
      parse_write_offset(writer, offset)
    }
    NamedType(name, offset) => {
      writer.write_byte(0)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    QualifiedType(module_alias, name, offset, name_offset) => {
      writer.write_byte(3)
      writer.write_string(module_alias)
      writer.write_string(name)
      parse_write_offset(writer, offset)
      parse_write_offset(writer, name_offset)
    }
    ProductType(fields, offset) => {
      writer.write_byte(4)
      writer.write_var_u64(fields.length().to_uint64())
      for field in fields {
        parse_write_type(writer, field)
      }
      parse_write_offset(writer, offset)
    }
    AppliedType(base, arguments, offset) => {
      writer.write_byte(1)
      parse_write_type(writer, base)
      writer.write_var_u64(arguments.length().to_uint64())
      for argument in arguments {
        parse_write_type(writer, argument)
      }
      parse_write_offset(writer, offset)
    }
    FunctionType(parameters, result, offset) => {
      writer.write_byte(2)
      writer.write_var_u64(parameters.length().to_uint64())
      for parameter in parameters {
        parse_write_type(writer, parameter)
      }
      parse_write_type(writer, result)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_type(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> TypeExpr {
  if depth > parse_event_maximum_depth {
    reader.fail(field, "syntax nesting exceeds limit")
    return NamedType("", 0UL)
  }
  match reader.read_byte(field + ".tag") {
    5 =>
      ComputedType(
        parse_read_type(reader, field + ".target", depth + 1),
        reader.read_bytes(parse_event_maximum_bytes, field + ".selector"),
        parse_read_offset(reader, field + ".offset"),
      )
    0 =>
      NamedType(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    1 => {
      let base = parse_read_type(reader, field + ".base", depth + 1)
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".argument_count",
      )
      let arguments : Array[TypeExpr] = []
      for index in 0..<count {
        arguments.push(
          parse_read_type(reader, field + ".argument[\{index}]", depth + 1),
        )
      }
      AppliedType(base, arguments, parse_read_offset(reader, field + ".offset"))
    }
    2 => {
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".parameter_count",
      )
      let parameters : Array[TypeExpr] = []
      for index in 0..<count {
        parameters.push(
          parse_read_type(reader, field + ".parameter[\{index}]", depth + 1),
        )
      }
      FunctionType(
        parameters,
        parse_read_type(reader, field + ".result", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    }
    3 =>
      QualifiedType(
        reader.read_string(parse_event_maximum_text, field + ".alias"),
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
        parse_read_offset(reader, field + ".name_offset"),
      )
    4 => {
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".field_count",
      )
      let fields : Array[TypeExpr] = []
      for index in 0..<count {
        fields.push(
          parse_read_type(reader, field + ".field[\{index}]", depth + 1),
        )
      }
      ProductType(fields, parse_read_offset(reader, field + ".offset"))
    }
    _ => {
      reader.fail(field, "unknown type discriminant")
      NamedType("", 0UL)
    }
  }
}

///|
fn parse_write_type_parameter(
  writer : @cache_binary.Writer,
  value : TypeParameter,
) -> Unit {
  writer.write_string(value.name)
  writer.write_var_u64(value.bounds.length().to_uint64())
  for bound in value.bounds {
    parse_write_type(writer, bound)
  }
  parse_write_offset(writer, value.offset)
}

///|
fn parse_read_type_parameter(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> TypeParameter {
  let name = reader.read_string(parse_event_maximum_text, field + ".name")
  let count = reader.read_count(
    parse_event_maximum_items,
    field + ".bound_count",
  )
  let bounds : Array[TypeExpr] = []
  for index in 0..<count {
    bounds.push(parse_read_type(reader, field + ".bound[\{index}]", depth + 1))
  }
  { name, bounds, offset: parse_read_offset(reader, field + ".offset"), }
}

///|
fn parse_write_type_parameters(
  writer : @cache_binary.Writer,
  values : Array[TypeParameter],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    parse_write_type_parameter(writer, value)
  }
}

///|
fn parse_read_type_parameters(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[TypeParameter] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[TypeParameter] = []
  for index in 0..<count {
    values.push(parse_read_type_parameter(reader, field + "[\{index}]", depth))
  }
  values
}

///|
fn parse_write_fn_parameter(
  writer : @cache_binary.Writer,
  value : FnParameter,
) -> Unit {
  writer.write_string(value.name)
  parse_write_type(writer, value.type_)
  parse_write_offset(writer, value.offset)
}

///|
fn parse_read_fn_parameter(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> FnParameter {
  {
    name: reader.read_string(parse_event_maximum_text, field + ".name"),
    type_: parse_read_type(reader, field + ".type", depth + 1),
    offset: parse_read_offset(reader, field + ".offset"),
  }
}

///|
fn parse_write_fn_parameters(
  writer : @cache_binary.Writer,
  values : Array[FnParameter],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    parse_write_fn_parameter(writer, value)
  }
}

///|
fn parse_read_fn_parameters(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[FnParameter] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[FnParameter] = []
  for index in 0..<count {
    values.push(parse_read_fn_parameter(reader, field + "[\{index}]", depth))
  }
  values
}

///|
fn parse_write_receiver(
  writer : @cache_binary.Writer,
  value : ReceiverParameter?,
) -> Unit {
  match value {
    Some(receiver) => {
      parse_write_option_tag(writer, true)
      match receiver.explicit_type {
        Some(type_) => {
          parse_write_option_tag(writer, true)
          parse_write_type(writer, type_)
        }
        None => parse_write_option_tag(writer, false)
      }
      parse_write_offset(writer, receiver.offset)
    }
    None => parse_write_option_tag(writer, false)
  }
}

///|
fn parse_read_receiver(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> ReceiverParameter? {
  if !reader.read_option_tag(field + ".tag") {
    return None
  }
  let explicit_type = if reader.read_option_tag(field + ".type_tag") {
    Some(parse_read_type(reader, field + ".type", depth + 1))
  } else {
    None
  }
  Some({ explicit_type, offset: parse_read_offset(reader, field + ".offset"), })
}

///|
fn parse_write_prefix(
  writer : @cache_binary.Writer,
  value : PrefixOperator,
) -> Unit {
  writer.write_byte(
    match value {
      Positive => 0
      Negative => 1
      LogicalNot => 2
    },
  )
}

///|
fn parse_read_prefix(
  reader : @cache_binary.Reader,
  field : String,
) -> PrefixOperator {
  match reader.read_byte(field) {
    0 => Positive
    1 => Negative
    2 => LogicalNot
    _ => {
      reader.fail(field, "unknown prefix-operator discriminant")
      Positive
    }
  }
}

///|
fn parse_write_binary(
  writer : @cache_binary.Writer,
  value : BinaryOperator,
) -> Unit {
  writer.write_byte(
    match value {
      LogicalOr => 0
      LogicalAnd => 1
      BitOr => 2
      BitXor => 3
      BitAnd => 4
      Equal => 5
      NotEqual => 6
      Less => 7
      LessEqual => 8
      Greater => 9
      GreaterEqual => 10
      ShiftLeft => 11
      ShiftRight => 12
      Add => 13
      Subtract => 14
      Multiply => 15
      Divide => 16
      Remainder => 17
      Exponentiate => 18
    },
  )
}

///|
fn parse_read_binary(
  reader : @cache_binary.Reader,
  field : String,
) -> BinaryOperator {
  match reader.read_byte(field) {
    0 => LogicalOr
    1 => LogicalAnd
    2 => BitOr
    3 => BitXor
    4 => BitAnd
    5 => Equal
    6 => NotEqual
    7 => Less
    8 => LessEqual
    9 => Greater
    10 => GreaterEqual
    11 => ShiftLeft
    12 => ShiftRight
    13 => Add
    14 => Subtract
    15 => Multiply
    16 => Divide
    17 => Remainder
    18 => Exponentiate
    _ => {
      reader.fail(field, "unknown binary-operator discriminant")
      Add
    }
  }
}

///|
fn parse_write_object_fields(
  writer : @cache_binary.Writer,
  values : Array[ObjectField],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    writer.write_string(value.name)
    parse_write_expr(writer, value.value)
    parse_write_offset(writer, value.offset)
  }
}

///|
fn parse_read_object_fields(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[ObjectField] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[ObjectField] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    values.push({
      name: reader.read_string(parse_event_maximum_text, item + ".name"),
      value: parse_read_expr(reader, item + ".value", depth + 1),
      offset: parse_read_offset(reader, item + ".offset"),
    })
  }
  values
}

///|
fn parse_write_exprs(
  writer : @cache_binary.Writer,
  values : Array[Expr],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    parse_write_expr(writer, value)
  }
}

///|
fn parse_read_exprs(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[Expr] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[Expr] = []
  for index in 0..<count {
    values.push(parse_read_expr(reader, field + "[\{index}]", depth + 1))
  }
  values
}

///|
fn parse_write_block(writer : @cache_binary.Writer, value : Block) -> Unit {
  writer.write_var_u64(value.items.length().to_uint64())
  for item in value.items {
    parse_write_block_item(writer, item)
  }
  parse_write_offset(writer, value.offset)
}

///|
fn parse_read_block(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Block {
  let count = reader.read_count(
    parse_event_maximum_items,
    field + ".item_count",
  )
  let items : Array[BlockItem] = []
  for index in 0..<count {
    items.push(
      parse_read_block_item(reader, field + ".item[\{index}]", depth + 1),
    )
  }
  { items, offset: parse_read_offset(reader, field + ".offset"), }
}

///|
fn parse_write_optional_expr(
  writer : @cache_binary.Writer,
  value : Expr?,
) -> Unit {
  match value {
    Some(expr) => {
      parse_write_option_tag(writer, true)
      parse_write_expr(writer, expr)
    }
    None => parse_write_option_tag(writer, false)
  }
}

///|
fn parse_read_optional_expr(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Expr? {
  if reader.read_option_tag(field + ".tag") {
    Some(parse_read_expr(reader, field + ".value", depth + 1))
  } else {
    None
  }
}

///|
fn parse_write_expr(writer : @cache_binary.Writer, value : Expr) -> Unit {
  match value {
    I8Expr(value, offset) => {
      writer.write_byte(0)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    I16Expr(value, offset) => {
      writer.write_byte(1)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    I32Expr(value, offset) => {
      writer.write_byte(2)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    I64Expr(value, offset) => {
      writer.write_byte(3)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    U8Expr(value, offset) => {
      writer.write_byte(4)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    U16Expr(value, offset) => {
      writer.write_byte(5)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    U32Expr(value, offset) => {
      writer.write_byte(6)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    U64Expr(value, offset) => {
      writer.write_byte(7)
      writer.write_var_u64(value)
      parse_write_offset(writer, offset)
    }
    F32Expr(value, offset) => {
      writer.write_byte(8)
      writer.write_f32(value)
      parse_write_offset(writer, offset)
    }
    F64Expr(value, offset) => {
      writer.write_byte(9)
      writer.write_f64(value)
      parse_write_offset(writer, offset)
    }
    BoolExpr(value, offset) => {
      writer.write_byte(10)
      writer.write_bool(value)
      parse_write_offset(writer, offset)
    }
    StringExpr(value, offset) => {
      writer.write_byte(11)
      writer.write_bytes(value)
      parse_write_offset(writer, offset)
    }
    BytesExpr(value, offset) => {
      writer.write_byte(12)
      writer.write_bytes(value)
      parse_write_offset(writer, offset)
    }
    NameExpr(value, offset) => {
      writer.write_byte(13)
      writer.write_string(value)
      parse_write_offset(writer, offset)
    }
    ImportAliasExpr(value, offset) => {
      writer.write_byte(14)
      writer.write_string(value)
      parse_write_offset(writer, offset)
    }
    ProductExpr(elements, offset) => {
      writer.write_byte(32)
      parse_write_exprs(writer, elements)
      parse_write_offset(writer, offset)
    }
    ArrayExpr(elements, offset) => {
      writer.write_byte(33)
      parse_write_exprs(writer, elements)
      parse_write_offset(writer, offset)
    }
    LambdaExpr(parameters, result, body, offset) => {
      writer.write_byte(15)
      parse_write_fn_parameters(writer, parameters)
      parse_write_type(writer, result)
      parse_write_block(writer, body)
      parse_write_offset(writer, offset)
    }
    ObjectExpr(fields, offset) => {
      writer.write_byte(16)
      parse_write_object_fields(writer, fields)
      parse_write_offset(writer, offset)
    }
    ConstructExpr(target, fields, offset) => {
      writer.write_byte(17)
      parse_write_expr(writer, target)
      parse_write_object_fields(writer, fields)
      parse_write_offset(writer, offset)
    }
    BlockExpr(block) => {
      writer.write_byte(18)
      parse_write_block(writer, block)
    }
    IfExpr(condition, then_, else_, offset) => {
      writer.write_byte(19)
      parse_write_expr(writer, condition)
      parse_write_block(writer, then_)
      parse_write_optional_expr(writer, else_)
      parse_write_offset(writer, offset)
    }
    MatchExpr(scrutinee, arms, offset) => {
      writer.write_byte(20)
      parse_write_expr(writer, scrutinee)
      parse_write_pattern_arms(writer, arms)
      parse_write_offset(writer, offset)
    }
    IsExpr(scrutinee, pattern, offset) => {
      writer.write_byte(21)
      parse_write_expr(writer, scrutinee)
      parse_write_pattern(writer, pattern)
      parse_write_offset(writer, offset)
    }
    WhileExpr(initial, arms, offset) => {
      writer.write_byte(22)
      parse_write_expr(writer, initial)
      parse_write_pattern_arms(writer, arms)
      parse_write_offset(writer, offset)
    }
    ReturnExpr(value, offset) => {
      writer.write_byte(35)
      parse_write_optional_expr(writer, value)
      parse_write_offset(writer, offset)
    }
    BreakExpr(value, offset) => {
      writer.write_byte(23)
      parse_write_expr(writer, value)
      parse_write_offset(writer, offset)
    }
    ContinueExpr(value, offset) => {
      writer.write_byte(24)
      parse_write_expr(writer, value)
      parse_write_offset(writer, offset)
    }
    PrefixExpr(operator, operand, offset) => {
      writer.write_byte(25)
      parse_write_prefix(writer, operator)
      parse_write_expr(writer, operand)
      parse_write_offset(writer, offset)
    }
    BinaryExpr(operator, left, right, offset) => {
      writer.write_byte(26)
      parse_write_binary(writer, operator)
      parse_write_expr(writer, left)
      parse_write_expr(writer, right)
      parse_write_offset(writer, offset)
    }
    CallExpr(target, arguments, offset) => {
      writer.write_byte(27)
      parse_write_expr(writer, target)
      parse_write_exprs(writer, arguments)
      parse_write_offset(writer, offset)
    }
    ExplicitTypeCallExpr(target, types, arguments, offset) => {
      writer.write_byte(28)
      parse_write_expr(writer, target)
      writer.write_var_u64(types.length().to_uint64())
      for type_ in types {
        parse_write_type(writer, type_)
      }
      parse_write_exprs(writer, arguments)
      parse_write_offset(writer, offset)
    }
    FieldExpr(target, name, offset) => {
      writer.write_byte(29)
      parse_write_expr(writer, target)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    QualifiedExpr(target, name, offset) => {
      writer.write_byte(30)
      parse_write_expr(writer, target)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    IndexExpr(target, index, offset) => {
      writer.write_byte(31)
      parse_write_expr(writer, target)
      parse_write_expr(writer, index)
      parse_write_offset(writer, offset)
    }
    ProductFieldExpr(target, index, arity, offset) => {
      writer.write_byte(34)
      parse_write_expr(writer, target)
      writer.write_var_u64(index.to_uint64())
      writer.write_var_u64(arity.to_uint64())
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_expr(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Expr {
  if depth > parse_event_maximum_depth {
    reader.fail(field, "syntax nesting exceeds limit")
    return BoolExpr(false, 0UL)
  }
  match reader.read_byte(field + ".tag") {
    0 =>
      I8Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    1 =>
      I16Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    2 =>
      I32Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    3 =>
      I64Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    4 =>
      U8Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    5 =>
      U16Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    6 =>
      U32Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    7 =>
      U64Expr(
        reader.read_var_u64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    8 =>
      F32Expr(
        reader.read_f32(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    9 =>
      F64Expr(
        reader.read_f64(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    10 =>
      BoolExpr(
        reader.read_bool(field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    11 =>
      StringExpr(
        reader.read_bytes(parse_event_maximum_bytes, field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    12 =>
      BytesExpr(
        reader.read_bytes(parse_event_maximum_bytes, field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    13 =>
      NameExpr(
        reader.read_string(parse_event_maximum_text, field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    14 =>
      ImportAliasExpr(
        reader.read_string(parse_event_maximum_text, field + ".value"),
        parse_read_offset(reader, field + ".offset"),
      )
    15 =>
      LambdaExpr(
        parse_read_fn_parameters(reader, field + ".parameters", depth + 1),
        parse_read_type(reader, field + ".result", depth + 1),
        parse_read_block(reader, field + ".body", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    16 =>
      ObjectExpr(
        parse_read_object_fields(reader, field + ".fields", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    17 =>
      ConstructExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        parse_read_object_fields(reader, field + ".fields", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    18 => BlockExpr(parse_read_block(reader, field + ".block", depth + 1))
    19 =>
      IfExpr(
        parse_read_expr(reader, field + ".condition", depth + 1),
        parse_read_block(reader, field + ".then", depth + 1),
        parse_read_optional_expr(reader, field + ".else", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    20 =>
      MatchExpr(
        parse_read_expr(reader, field + ".scrutinee", depth + 1),
        parse_read_pattern_arms(reader, field + ".arms", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    21 =>
      IsExpr(
        parse_read_expr(reader, field + ".scrutinee", depth + 1),
        parse_read_pattern(reader, field + ".pattern", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    22 =>
      WhileExpr(
        parse_read_expr(reader, field + ".initial", depth + 1),
        parse_read_pattern_arms(reader, field + ".arms", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    23 =>
      BreakExpr(
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    24 =>
      ContinueExpr(
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    25 =>
      PrefixExpr(
        parse_read_prefix(reader, field + ".operator"),
        parse_read_expr(reader, field + ".operand", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    26 =>
      BinaryExpr(
        parse_read_binary(reader, field + ".operator"),
        parse_read_expr(reader, field + ".left", depth + 1),
        parse_read_expr(reader, field + ".right", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    27 =>
      CallExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        parse_read_exprs(reader, field + ".arguments", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    28 => {
      let target = parse_read_expr(reader, field + ".target", depth + 1)
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".type_count",
      )
      let types : Array[TypeExpr] = []
      for index in 0..<count {
        types.push(
          parse_read_type(reader, field + ".type[\{index}]", depth + 1),
        )
      }
      ExplicitTypeCallExpr(
        target,
        types,
        parse_read_exprs(reader, field + ".arguments", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    }
    29 =>
      FieldExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    30 =>
      QualifiedExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    31 =>
      IndexExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        parse_read_expr(reader, field + ".index", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    32 =>
      ProductExpr(
        parse_read_exprs(reader, field + ".elements", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    33 =>
      ArrayExpr(
        parse_read_exprs(reader, field + ".elements", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    34 =>
      ProductFieldExpr(
        parse_read_expr(reader, field + ".target", depth + 1),
        reader.read_count(32, field + ".index"),
        reader.read_count(32, field + ".arity"),
        parse_read_offset(reader, field + ".offset"),
      )
    35 =>
      ReturnExpr(
        parse_read_optional_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    _ => {
      reader.fail(field, "unknown expression discriminant")
      BoolExpr(false, 0UL)
    }
  }
}

///|
fn parse_write_block_item(
  writer : @cache_binary.Writer,
  value : BlockItem,
) -> Unit {
  match value {
    TypeBindingItem(name, type_, offset) => {
      writer.write_byte(5)
      writer.write_string(name)
      parse_write_type(writer, type_)
      parse_write_offset(writer, offset)
    }
    LetItem(mutable_, name, name_offset, expression, offset) => {
      writer.write_byte(0)
      writer.write_bool(mutable_)
      writer.write_string(name)
      parse_write_offset(writer, name_offset)
      parse_write_expr(writer, expression)
      parse_write_offset(writer, offset)
    }
    AssignmentItem(target, value, offset) => {
      writer.write_byte(2)
      parse_write_expr(writer, target)
      parse_write_expr(writer, value)
      parse_write_offset(writer, offset)
    }
    IndexSetItem(target, value, offset) => {
      writer.write_byte(3)
      parse_write_expr(writer, target)
      parse_write_expr(writer, value)
      parse_write_offset(writer, offset)
    }
    ExpressionItem(expression, offset) => {
      writer.write_byte(4)
      parse_write_expr(writer, expression)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_block_item(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> BlockItem {
  match reader.read_byte(field + ".tag") {
    5 =>
      TypeBindingItem(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_type(reader, field + ".type", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    0 =>
      LetItem(
        reader.read_bool(field + ".mutable"),
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".name_offset"),
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    1 => {
      let value = parse_read_optional_expr(reader, field + ".value", depth + 1)
      let offset = parse_read_offset(reader, field + ".offset")
      ExpressionItem(ReturnExpr(value, offset), offset)
    }
    2 =>
      AssignmentItem(
        parse_read_expr(reader, field + ".target", depth + 1),
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    3 =>
      IndexSetItem(
        parse_read_expr(reader, field + ".target", depth + 1),
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    4 =>
      ExpressionItem(
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    _ => {
      reader.fail(field, "unknown block-item discriminant")
      ExpressionItem(BoolExpr(false, 0UL), 0UL)
    }
  }
}

///|
fn parse_write_pattern_fields(
  writer : @cache_binary.Writer,
  values : Array[PatternField],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    writer.write_string(value.name)
    parse_write_pattern(writer, value.pattern)
    parse_write_offset(writer, value.offset)
  }
}

///|
fn parse_read_pattern_fields(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[PatternField] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[PatternField] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    values.push({
      name: reader.read_string(parse_event_maximum_text, item + ".name"),
      pattern: parse_read_pattern(reader, item + ".pattern", depth + 1),
      offset: parse_read_offset(reader, item + ".offset"),
    })
  }
  values
}

///|
fn parse_write_patterns(
  writer : @cache_binary.Writer,
  values : Array[Pattern],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    parse_write_pattern(writer, value)
  }
}

///|
fn parse_read_patterns(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[Pattern] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[Pattern] = []
  for index in 0..<count {
    values.push(parse_read_pattern(reader, field + "[\{index}]", depth + 1))
  }
  values
}

///|
fn parse_write_pattern(writer : @cache_binary.Writer, value : Pattern) -> Unit {
  match value {
    WildcardPattern(offset) => {
      writer.write_byte(0)
      parse_write_offset(writer, offset)
    }
    BindingPattern(name, offset) => {
      writer.write_byte(1)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    ImportAliasPattern(name, offset) => {
      writer.write_byte(8)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    RestPattern(offset) => {
      writer.write_byte(2)
      parse_write_offset(writer, offset)
    }
    LiteralPattern(expression, offset) => {
      writer.write_byte(3)
      parse_write_expr(writer, expression)
      parse_write_offset(writer, offset)
    }
    QualifiedPattern(target, name, offset) => {
      writer.write_byte(4)
      parse_write_pattern(writer, target)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    TuplePattern(target, arguments, offset) => {
      writer.write_byte(5)
      parse_write_pattern(writer, target)
      parse_write_patterns(writer, arguments)
      parse_write_offset(writer, offset)
    }
    StructPattern(target, fields, rest, offset) => {
      writer.write_byte(6)
      parse_write_pattern(writer, target)
      parse_write_pattern_fields(writer, fields)
      match rest {
        Some(value) => {
          parse_write_option_tag(writer, true)
          parse_write_offset(writer, value)
        }
        None => parse_write_option_tag(writer, false)
      }
      parse_write_offset(writer, offset)
    }
    AlternativePattern(first, remaining, offset) => {
      writer.write_byte(7)
      parse_write_pattern(writer, first)
      parse_write_patterns(writer, remaining)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_pattern(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Pattern {
  if depth > parse_event_maximum_depth {
    reader.fail(field, "syntax nesting exceeds limit")
    return WildcardPattern(0UL)
  }
  match reader.read_byte(field + ".tag") {
    0 => WildcardPattern(parse_read_offset(reader, field + ".offset"))
    1 =>
      BindingPattern(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    2 => RestPattern(parse_read_offset(reader, field + ".offset"))
    8 =>
      ImportAliasPattern(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    3 =>
      LiteralPattern(
        parse_read_expr(reader, field + ".value", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    4 =>
      QualifiedPattern(
        parse_read_pattern(reader, field + ".target", depth + 1),
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    5 =>
      TuplePattern(
        parse_read_pattern(reader, field + ".target", depth + 1),
        parse_read_patterns(reader, field + ".arguments", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    6 => {
      let target = parse_read_pattern(reader, field + ".target", depth + 1)
      let fields = parse_read_pattern_fields(
        reader,
        field + ".fields",
        depth + 1,
      )
      let rest = if reader.read_option_tag(field + ".rest_tag") {
        Some(parse_read_offset(reader, field + ".rest"))
      } else {
        None
      }
      StructPattern(
        target,
        fields,
        rest,
        parse_read_offset(reader, field + ".offset"),
      )
    }
    7 =>
      AlternativePattern(
        parse_read_pattern(reader, field + ".first", depth + 1),
        parse_read_patterns(reader, field + ".remaining", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    _ => {
      reader.fail(field, "unknown pattern discriminant")
      WildcardPattern(0UL)
    }
  }
}

///|
fn parse_write_pattern_arms(
  writer : @cache_binary.Writer,
  values : Array[PatternArm],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    parse_write_pattern(writer, value.pattern)
    parse_write_optional_expr(writer, value.guard_condition)
    parse_write_expr(writer, value.body)
    parse_write_offset(writer, value.offset)
  }
}

///|
fn parse_read_pattern_arms(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[PatternArm] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[PatternArm] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    values.push({
      pattern: parse_read_pattern(reader, item + ".pattern", depth + 1),
      guard_condition: parse_read_optional_expr(
        reader,
        item + ".guard",
        depth + 1,
      ),
      body: parse_read_expr(reader, item + ".body", depth + 1),
      offset: parse_read_offset(reader, item + ".offset"),
    })
  }
  values
}

///|
fn parse_write_derive_requests(
  writer : @cache_binary.Writer,
  values : Array[DeriveRequest],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    writer.write_string(value.name)
    parse_write_offset(writer, value.offset)
  }
}

///|
fn parse_read_derive_requests(
  reader : @cache_binary.Reader,
  field : String,
) -> Array[DeriveRequest] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[DeriveRequest] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    values.push({
      name: reader.read_string(parse_event_maximum_text, item + ".name"),
      offset: parse_read_offset(reader, item + ".offset"),
    })
  }
  values
}

///|
fn parse_write_struct_fields(
  writer : @cache_binary.Writer,
  values : Array[StructField],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    writer.write_bool(value.mutable_)
    writer.write_string(value.name)
    parse_write_type(writer, value.type_)
    parse_write_offset(writer, value.offset)
  }
}

///|
fn parse_read_struct_fields(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[StructField] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[StructField] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    values.push({
      mutable_: reader.read_bool(item + ".mutable"),
      name: reader.read_string(parse_event_maximum_text, item + ".name"),
      type_: parse_read_type(reader, item + ".type", depth + 1),
      offset: parse_read_offset(reader, item + ".offset"),
    })
  }
  values
}

///|
fn parse_write_enum_variants(
  writer : @cache_binary.Writer,
  values : Array[EnumVariant],
) -> Unit {
  writer.write_var_u64(values.length().to_uint64())
  for value in values {
    match value {
      UnitVariant(name, offset) => {
        writer.write_byte(0)
        writer.write_string(name)
        parse_write_offset(writer, offset)
      }
      TupleVariant(name, types, offset) => {
        writer.write_byte(1)
        writer.write_string(name)
        writer.write_var_u64(types.length().to_uint64())
        for type_ in types {
          parse_write_type(writer, type_)
        }
        parse_write_offset(writer, offset)
      }
      StructVariant(name, fields, offset) => {
        writer.write_byte(2)
        writer.write_string(name)
        parse_write_struct_fields(writer, fields)
        parse_write_offset(writer, offset)
      }
    }
  }
}

///|
fn parse_read_enum_variants(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Array[EnumVariant] {
  let count = reader.read_count(parse_event_maximum_items, field + ".count")
  let values : Array[EnumVariant] = []
  for index in 0..<count {
    let item = field + "[\{index}]"
    match reader.read_byte(item + ".tag") {
      0 =>
        values.push(
          UnitVariant(
            reader.read_string(parse_event_maximum_text, item + ".name"),
            parse_read_offset(reader, item + ".offset"),
          ),
        )
      1 => {
        let name = reader.read_string(parse_event_maximum_text, item + ".name")
        let type_count = reader.read_count(
          parse_event_maximum_items,
          item + ".type_count",
        )
        let types : Array[TypeExpr] = []
        for type_index in 0..<type_count {
          types.push(
            parse_read_type(reader, item + ".type[\{type_index}]", depth + 1),
          )
        }
        values.push(
          TupleVariant(name, types, parse_read_offset(reader, item + ".offset")),
        )
      }
      2 =>
        values.push(
          StructVariant(
            reader.read_string(parse_event_maximum_text, item + ".name"),
            parse_read_struct_fields(reader, item + ".fields", depth + 1),
            parse_read_offset(reader, item + ".offset"),
          ),
        )
      _ => {
        reader.fail(item, "unknown enum-variant discriminant")
        values.push(UnitVariant("", 0UL))
      }
    }
  }
  values
}

///|
fn parse_write_function(
  writer : @cache_binary.Writer,
  value : FunctionDeclaration,
) -> Unit {
  parse_write_visibility(writer, value.visibility)
  writer.write_string(value.name)
  parse_write_offset(writer, value.name_offset)
  parse_write_type_parameters(writer, value.type_parameters)
  parse_write_receiver(writer, value.receiver)
  parse_write_fn_parameters(writer, value.parameters)
  parse_write_type(writer, value.return_type)
  parse_write_block(writer, value.body)
  parse_write_offset(writer, value.offset)
}

///|
fn parse_read_function(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> FunctionDeclaration {
  {
    visibility: parse_read_visibility(reader, field + ".visibility"),
    name: reader.read_string(parse_event_maximum_text, field + ".name"),
    name_offset: parse_read_offset(reader, field + ".name_offset"),
    type_parameters: parse_read_type_parameters(
      reader,
      field + ".type_parameters",
      depth + 1,
    ),
    receiver: parse_read_receiver(reader, field + ".receiver", depth + 1),
    parameters: parse_read_fn_parameters(
      reader,
      field + ".parameters",
      depth + 1,
    ),
    return_type: parse_read_type(reader, field + ".return_type", depth + 1),
    body: parse_read_block(reader, field + ".body", depth + 1),
    offset: parse_read_offset(reader, field + ".offset"),
  }
}

///|
fn parse_write_foreign_library_member(
  writer : @cache_binary.Writer,
  value : ForeignLibraryMember,
) -> Unit {
  parse_write_visibility(writer, value.visibility)
  writer.write_string(value.name)
  parse_write_offset(writer, value.name_offset)
  parse_write_fn_parameters(writer, value.parameters)
  parse_write_type(writer, value.return_type)
  writer.write_bytes(value.export_name)
  parse_write_offset(writer, value.export_name_offset)
  parse_write_offset(writer, value.offset)
}

///|
fn parse_read_foreign_library_member(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> ForeignLibraryMember {
  {
    visibility: parse_read_visibility(reader, field + ".visibility"),
    name: reader.read_string(parse_event_maximum_text, field + ".name"),
    name_offset: parse_read_offset(reader, field + ".name_offset"),
    parameters: parse_read_fn_parameters(
      reader,
      field + ".parameters",
      depth + 1,
    ),
    return_type: parse_read_type(reader, field + ".return_type", depth + 1),
    export_name: reader.read_bytes(
      parse_event_maximum_bytes,
      field + ".export_name",
    ),
    export_name_offset: parse_read_offset(reader, field + ".export_name_offset"),
    offset: parse_read_offset(reader, field + ".offset"),
  }
}

///|
fn parse_write_declaration(
  writer : @cache_binary.Writer,
  value : Declaration,
) -> Unit {
  match value {
    Import(value) => {
      writer.write_byte(0)
      writer.write_bool(value.open_)
      writer.write_var_u64(value.path.length().to_uint64())
      for segment in value.path {
        writer.write_string(segment)
      }
      writer.write_bool(value.wildcard)
      match value.import_alias {
        Some(alias_name) => {
          parse_write_option_tag(writer, true)
          writer.write_string(alias_name)
        }
        None => parse_write_option_tag(writer, false)
      }
      parse_write_offset(writer, value.import_alias_offset)
      parse_write_offset(writer, value.offset)
    }
    Builtin(value) => {
      writer.write_byte(1)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_type_parameters(writer, value.type_parameters)
      parse_write_fn_parameters(writer, value.parameters)
      parse_write_type(writer, value.return_type)
      writer.write_bytes(value.builtin_name)
      parse_write_offset(writer, value.offset)
    }
    Let(value) => {
      writer.write_byte(2)
      parse_write_visibility(writer, value.visibility)
      writer.write_bool(value.mutable_)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_expr(writer, value.value)
      parse_write_offset(writer, value.offset)
    }
    Trait(value) => {
      writer.write_byte(3)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_type_parameters(writer, value.type_parameters)
      writer.write_var_u64(value.methods.length().to_uint64())
      for trait_method in value.methods {
        writer.write_string(trait_method.name)
        parse_write_offset(writer, trait_method.name_offset)
        parse_write_type_parameters(writer, trait_method.type_parameters)
        parse_write_receiver(writer, trait_method.receiver)
        parse_write_fn_parameters(writer, trait_method.parameters)
        parse_write_type(writer, trait_method.return_type)
        parse_write_offset(writer, trait_method.offset)
      }
      parse_write_offset(writer, value.offset)
    }
    Function(value) => {
      writer.write_byte(4)
      parse_write_function(writer, value)
    }
    Test(value) => {
      writer.write_byte(5)
      writer.write_bytes(value.name)
      parse_write_offset(writer, value.name_offset)
      match value.expected_trap {
        Some(trap) => {
          parse_write_option_tag(writer, true)
          writer.write_bytes(trap)
        }
        None => parse_write_option_tag(writer, false)
      }
      parse_write_type(writer, value.return_type)
      parse_write_block(writer, value.body)
      parse_write_offset(writer, value.offset)
    }
    Impl(value) => {
      writer.write_byte(6)
      writer.write_bool(value.foreign_)
      parse_write_type_parameters(writer, value.type_parameters)
      match value.trait_type {
        Some(type_) => {
          parse_write_option_tag(writer, true)
          parse_write_type(writer, type_)
        }
        None => parse_write_option_tag(writer, false)
      }
      parse_write_type(writer, value.target_type)
      writer.write_var_u64(value.methods.length().to_uint64())
      for impl_method in value.methods {
        parse_write_function(writer, impl_method)
      }
      parse_write_offset(writer, value.offset)
    }
    Struct(value) => {
      writer.write_byte(7)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_type_parameters(writer, value.type_parameters)
      parse_write_struct_fields(writer, value.fields)
      parse_write_derive_requests(writer, value.derives)
      parse_write_offset(writer, value.offset)
    }
    Enum(value) => {
      writer.write_byte(8)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_type_parameters(writer, value.type_parameters)
      parse_write_enum_variants(writer, value.variants)
      parse_write_derive_requests(writer, value.derives)
      parse_write_offset(writer, value.offset)
    }
    TypeAlias(value) => {
      writer.write_byte(9)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_type_parameters(writer, value.type_parameters)
      parse_write_type(writer, value.target)
      parse_write_offset(writer, value.offset)
    }
    ForeignType(value) => {
      writer.write_byte(10)
      parse_write_visibility(writer, value.visibility)
      writer.write_string(value.name)
      parse_write_offset(writer, value.name_offset)
      parse_write_offset(writer, value.offset)
    }
    ForeignLibrary(value) => {
      writer.write_byte(11)
      writer.write_bool(value.host_import)
      writer.write_bytes(value.logical_name)
      parse_write_offset(writer, value.logical_name_offset)
      writer.write_string(value.namespace_alias)
      parse_write_offset(writer, value.alias_offset)
      writer.write_var_u64(value.members.length().to_uint64())
      for foreign_member in value.members {
        parse_write_foreign_library_member(writer, foreign_member)
      }
      parse_write_offset(writer, value.offset)
    }
  }
}

///|
fn parse_read_declaration(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> Declaration {
  match reader.read_byte(field + ".tag") {
    0 => {
      let open_ = reader.read_bool(field + ".open")
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".path_count",
      )
      let path : Array[String] = []
      for index in 0..<count {
        path.push(
          reader.read_string(
            parse_event_maximum_text,
            field + ".path[\{index}]",
          ),
        )
      }
      let wildcard = reader.read_bool(field + ".wildcard")
      let import_alias = if reader.read_option_tag(field + ".alias_tag") {
        Some(reader.read_string(parse_event_maximum_text, field + ".alias"))
      } else {
        None
      }
      Import({
        open_,
        path,
        wildcard,
        import_alias,
        import_alias_offset: parse_read_offset(reader, field + ".alias_offset"),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    }
    1 =>
      Builtin({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        type_parameters: parse_read_type_parameters(
          reader,
          field + ".type_parameters",
          depth + 1,
        ),
        parameters: parse_read_fn_parameters(
          reader,
          field + ".parameters",
          depth + 1,
        ),
        return_type: parse_read_type(reader, field + ".return_type", depth + 1),
        builtin_name: reader.read_bytes(
          parse_event_maximum_bytes,
          field + ".builtin_name",
        ),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    2 =>
      Let({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        mutable_: reader.read_bool(field + ".mutable"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        value: parse_read_expr(reader, field + ".value", depth + 1),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    3 => {
      let visibility = parse_read_visibility(reader, field + ".visibility")
      let name = reader.read_string(parse_event_maximum_text, field + ".name")
      let name_offset = parse_read_offset(reader, field + ".name_offset")
      let type_parameters = parse_read_type_parameters(
        reader,
        field + ".type_parameters",
        depth + 1,
      )
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".method_count",
      )
      let methods : Array[TraitMethod] = []
      for index in 0..<count {
        let item = field + ".method[\{index}]"
        methods.push({
          name: reader.read_string(parse_event_maximum_text, item + ".name"),
          name_offset: parse_read_offset(reader, item + ".name_offset"),
          type_parameters: parse_read_type_parameters(
            reader,
            item + ".type_parameters",
            depth + 1,
          ),
          receiver: parse_read_receiver(reader, item + ".receiver", depth + 1),
          parameters: parse_read_fn_parameters(
            reader,
            item + ".parameters",
            depth + 1,
          ),
          return_type: parse_read_type(reader, item + ".return_type", depth + 1),
          offset: parse_read_offset(reader, item + ".offset"),
        })
      }
      Trait({
        visibility,
        name,
        name_offset,
        type_parameters,
        methods,
        offset: parse_read_offset(reader, field + ".offset"),
      })
    }
    4 => Function(parse_read_function(reader, field + ".function", depth + 1))
    5 => {
      let name = reader.read_bytes(parse_event_maximum_bytes, field + ".name")
      let name_offset = parse_read_offset(reader, field + ".name_offset")
      let expected_trap = if reader.read_option_tag(field + ".trap_tag") {
        Some(reader.read_bytes(parse_event_maximum_bytes, field + ".trap"))
      } else {
        None
      }
      Test({
        name,
        name_offset,
        expected_trap,
        return_type: parse_read_type(reader, field + ".return_type", depth + 1),
        body: parse_read_block(reader, field + ".body", depth + 1),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    }
    6 => {
      let foreign_ = reader.read_bool(field + ".foreign")
      let type_parameters = parse_read_type_parameters(
        reader,
        field + ".type_parameters",
        depth + 1,
      )
      let trait_type = if reader.read_option_tag(field + ".trait_tag") {
        Some(parse_read_type(reader, field + ".trait", depth + 1))
      } else {
        None
      }
      let target_type = parse_read_type(reader, field + ".target", depth + 1)
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".method_count",
      )
      let methods : Array[FunctionDeclaration] = []
      for index in 0..<count {
        methods.push(
          parse_read_function(reader, field + ".method[\{index}]", depth + 1),
        )
      }
      Impl({
        foreign_,
        type_parameters,
        trait_type,
        target_type,
        methods,
        offset: parse_read_offset(reader, field + ".offset"),
      })
    }
    7 =>
      Struct({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        type_parameters: parse_read_type_parameters(
          reader,
          field + ".type_parameters",
          depth + 1,
        ),
        fields: parse_read_struct_fields(reader, field + ".fields", depth + 1),
        derives: parse_read_derive_requests(reader, field + ".derives"),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    8 =>
      Enum({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        type_parameters: parse_read_type_parameters(
          reader,
          field + ".type_parameters",
          depth + 1,
        ),
        variants: parse_read_enum_variants(
          reader,
          field + ".variants",
          depth + 1,
        ),
        derives: parse_read_derive_requests(reader, field + ".derives"),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    9 =>
      TypeAlias({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        type_parameters: parse_read_type_parameters(
          reader,
          field + ".type_parameters",
          depth + 1,
        ),
        target: parse_read_type(reader, field + ".target", depth + 1),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    10 =>
      ForeignType({
        visibility: parse_read_visibility(reader, field + ".visibility"),
        name: reader.read_string(parse_event_maximum_text, field + ".name"),
        name_offset: parse_read_offset(reader, field + ".name_offset"),
        offset: parse_read_offset(reader, field + ".offset"),
      })
    11 => {
      let host_import = reader.read_bool(field + ".host_import")
      let logical_name = reader.read_bytes(
        parse_event_maximum_bytes,
        field + ".logical_name",
      )
      let logical_name_offset = parse_read_offset(
        reader,
        field + ".logical_name_offset",
      )
      let namespace_alias = reader.read_string(
        parse_event_maximum_text,
        field + ".namespace_alias",
      )
      let alias_offset = parse_read_offset(reader, field + ".alias_offset")
      let count = reader.read_count(
        parse_event_maximum_items,
        field + ".member_count",
      )
      let members : Array[ForeignLibraryMember] = []
      for index in 0..<count {
        members.push(
          parse_read_foreign_library_member(
            reader,
            field + ".member[\{index}]",
            depth + 1,
          ),
        )
      }
      ForeignLibrary({
        host_import,
        logical_name,
        logical_name_offset,
        namespace_alias,
        alias_offset,
        members,
        offset: parse_read_offset(reader, field + ".offset"),
      })
    }
    _ => {
      reader.fail(field, "unknown declaration discriminant")
      Import({
        open_: false,
        path: [],
        wildcard: false,
        import_alias: None,
        import_alias_offset: 0UL,
        offset: 0UL,
      })
    }
  }
}

///|
fn parse_write_expectation(
  writer : @cache_binary.Writer,
  value : DeclarationExpectation,
) -> Unit {
  writer.write_byte(
    match value {
      DeclarationKeyword => 0
      ImportPathSegment => 1
      ImportAlias => 2
      ImportWildcard => 3
      BuiltinName => 4
      BindingName => 5
      TraitName => 6
      StructName => 7
      StructFieldName => 8
      StructBodyNewline => 9
      EnumName => 10
      TypeAliasName => 11
      EnumBodyNewline => 12
      EnumVariantName => 13
      EnumVariantPayloadOrLineEnd => 14
      EnumVariantBodyNewline => 15
      EnumVariantFieldName => 16
      VariantTypeSeparatorOrClose => 17
      FunctionName => 18
      TestName => 19
      TestExpectedTrap => 20
      FunctionBodyNewline => 21
      ImplMemberKeyword => 22
      ForOrLeftBrace => 23
      TraitMethodKeyword => 24
      TraitMethodName => 25
      TraitBodyNewline => 26
      TypeParameter => 27
      TypeParameterSeparatorOrClose => 28
      TypeBound => 29
      DeriveName => 30
      DeriveSeparatorOrClose => 31
      TypeArgumentSeparatorOrClose => 32
      LeftParen => 33
      LeftBrace => 34
      ParameterName => 35
      Colon => 36
      ParameterSeparatorOrClose => 37
      Type => 38
      Arrow => 39
      Equal => 40
      BuiltinString => 41
      LineEnd => 42
      ForeignTypeName => 43
      ForeignLibraryName => 44
      ForeignLibraryAlias => 45
      ForeignLibraryMemberKeyword => 46
      ForeignLibraryExportName => 47
    },
  )
}

///|
fn parse_read_expectation(
  reader : @cache_binary.Reader,
  field : String,
) -> DeclarationExpectation {
  match reader.read_byte(field) {
    0 => DeclarationKeyword
    1 => ImportPathSegment
    2 => ImportAlias
    3 => ImportWildcard
    4 => BuiltinName
    5 => BindingName
    6 => TraitName
    7 => StructName
    8 => StructFieldName
    9 => StructBodyNewline
    10 => EnumName
    11 => TypeAliasName
    12 => EnumBodyNewline
    13 => EnumVariantName
    14 => EnumVariantPayloadOrLineEnd
    15 => EnumVariantBodyNewline
    16 => EnumVariantFieldName
    17 => VariantTypeSeparatorOrClose
    18 => FunctionName
    19 => TestName
    20 => TestExpectedTrap
    21 => FunctionBodyNewline
    22 => ImplMemberKeyword
    23 => ForOrLeftBrace
    24 => TraitMethodKeyword
    25 => TraitMethodName
    26 => TraitBodyNewline
    27 => TypeParameter
    28 => TypeParameterSeparatorOrClose
    29 => TypeBound
    30 => DeriveName
    31 => DeriveSeparatorOrClose
    32 => TypeArgumentSeparatorOrClose
    33 => LeftParen
    34 => LeftBrace
    35 => ParameterName
    36 => Colon
    37 => ParameterSeparatorOrClose
    38 => Type
    39 => Arrow
    40 => Equal
    41 => BuiltinString
    42 => LineEnd
    43 => ForeignTypeName
    44 => ForeignLibraryName
    45 => ForeignLibraryAlias
    46 => ForeignLibraryMemberKeyword
    47 => ForeignLibraryExportName
    _ => {
      reader.fail(field, "unknown declaration-expectation discriminant")
      DeclarationKeyword
    }
  }
}

///|
fn parse_write_pattern_error(
  writer : @cache_binary.Writer,
  value : PatternError,
) -> Unit {
  match value {
    ExpectedPattern(token) => {
      writer.write_byte(0)
      parse_write_optional_token(writer, token)
    }
    ExpectedPatternProperty(token) => {
      writer.write_byte(1)
      parse_write_optional_token(writer, token)
    }
    ExpectedPatternDelimiter(token, offset) => {
      writer.write_byte(2)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedPatternBodyNewline(token, offset) => {
      writer.write_byte(3)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedPatternField(token, offset) => {
      writer.write_byte(4)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedPatternFieldNewline(token, offset) => {
      writer.write_byte(5)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    RestPatternNotAllowed(offset) => {
      writer.write_byte(6)
      parse_write_offset(writer, offset)
    }
    DuplicateRestPattern(offset) => {
      writer.write_byte(7)
      parse_write_offset(writer, offset)
    }
    UnclosedTuplePattern(offset) => {
      writer.write_byte(8)
      parse_write_offset(writer, offset)
    }
    UnclosedStructPattern(offset) => {
      writer.write_byte(9)
      parse_write_offset(writer, offset)
    }
    EmptyTuplePattern(offset) => {
      writer.write_byte(10)
      parse_write_offset(writer, offset)
    }
    PatternLexicalError(error, offset) => {
      writer.write_byte(11)
      parse_write_lex_error(writer, error)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_pattern_error(
  reader : @cache_binary.Reader,
  field : String,
) -> PatternError {
  match reader.read_byte(field + ".tag") {
    0 => ExpectedPattern(parse_read_optional_token(reader, field + ".token"))
    1 =>
      ExpectedPatternProperty(
        parse_read_optional_token(reader, field + ".token"),
      )
    2 =>
      ExpectedPatternDelimiter(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    3 =>
      ExpectedPatternBodyNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    4 =>
      ExpectedPatternField(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    5 =>
      ExpectedPatternFieldNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    6 => RestPatternNotAllowed(parse_read_offset(reader, field + ".offset"))
    7 => DuplicateRestPattern(parse_read_offset(reader, field + ".offset"))
    8 => UnclosedTuplePattern(parse_read_offset(reader, field + ".offset"))
    9 => UnclosedStructPattern(parse_read_offset(reader, field + ".offset"))
    10 => EmptyTuplePattern(parse_read_offset(reader, field + ".offset"))
    11 =>
      PatternLexicalError(
        parse_read_lex_error(reader, field + ".error"),
        parse_read_offset(reader, field + ".offset"),
      )
    _ => {
      reader.fail(field, "unknown pattern-error discriminant")
      ExpectedPattern(None)
    }
  }
}

///|
fn parse_write_expression_error(
  writer : @cache_binary.Writer,
  value : ExpressionError,
) -> Unit {
  match value {
    TypeArgumentError(expectation, token, offset) => {
      writer.write_byte(47)
      parse_write_expectation(writer, expectation)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedValue(token) => {
      writer.write_byte(0)
      parse_write_optional_token(writer, token)
    }
    ExpectedCallDelimiter(token) => {
      writer.write_byte(1)
      parse_write_optional_token(writer, token)
    }
    ExpectedFieldName(token) => {
      writer.write_byte(2)
      parse_write_optional_token(writer, token)
    }
    ExpectedQualifiedName(token) => {
      writer.write_byte(3)
      parse_write_optional_token(writer, token)
    }
    ExpectedRightBracket(token, offset) => {
      writer.write_byte(4)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedArrayDelimiter(token, offset) => {
      writer.write_byte(42)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedObjectField(token, offset) => {
      writer.write_byte(5)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedObjectColon(token, offset) => {
      writer.write_byte(6)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedObjectFieldNewline(token, offset) => {
      writer.write_byte(7)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedBlockNewline(token, offset) => {
      writer.write_byte(8)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedBlockItemNewline(token, offset) => {
      writer.write_byte(9)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedAssignmentTarget(token, offset) => {
      writer.write_byte(10)
      parse_write_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedBlockBindingName(token) => {
      writer.write_byte(11)
      parse_write_optional_token(writer, token)
    }
    ExpectedBlockEqual(token) => {
      writer.write_byte(12)
      parse_write_optional_token(writer, token)
    }
    ExpectedIfBody(token, offset) => {
      writer.write_byte(13)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedElseBranch(token, offset) => {
      writer.write_byte(14)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedMatchBody(token, offset) => {
      writer.write_byte(15)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedMatchBodyNewline(token, offset) => {
      writer.write_byte(16)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedMatchArmArrow(token, offset) => {
      writer.write_byte(17)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedMatchArmNewline(token, offset) => {
      writer.write_byte(18)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedWhileBody(token, offset) => {
      writer.write_byte(19)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedWhileBodyNewline(token, offset) => {
      writer.write_byte(20)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedWhileArmArrow(token, offset) => {
      writer.write_byte(21)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedWhileArmNewline(token, offset) => {
      writer.write_byte(22)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedBreakValue(token, offset) => {
      writer.write_byte(23)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedContinueValue(token, offset) => {
      writer.write_byte(24)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedLambdaSyntax(expectation, token, offset) => {
      writer.write_byte(25)
      parse_write_expectation(writer, expectation)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    UnexpectedLambdaTypeCloser(left, right) => {
      writer.write_byte(26)
      parse_write_offset(writer, left)
      parse_write_offset(writer, right)
    }
    InvalidLambdaSyntax(offset) => {
      writer.write_byte(27)
      parse_write_offset(writer, offset)
    }
    MatchPatternError(error) => {
      writer.write_byte(28)
      parse_write_pattern_error(writer, error)
    }
    UnclosedObject(offset) => {
      writer.write_byte(29)
      parse_write_offset(writer, offset)
    }
    UnclosedBlock(offset) => {
      writer.write_byte(30)
      parse_write_offset(writer, offset)
    }
    UnclosedMatch(offset) => {
      writer.write_byte(31)
      parse_write_offset(writer, offset)
    }
    UnclosedWhile(offset) => {
      writer.write_byte(32)
      parse_write_offset(writer, offset)
    }
    ChainedComparison(offset) => {
      writer.write_byte(33)
      parse_write_offset(writer, offset)
    }
    UnclosedGroup(offset) => {
      writer.write_byte(34)
      parse_write_offset(writer, offset)
    }
    InvalidProductArity(arity, offset) => {
      writer.write_byte(43)
      writer.write_var_u64(arity.to_uint64())
      parse_write_offset(writer, offset)
    }
    UnclosedArray(offset) => {
      writer.write_byte(44)
      parse_write_offset(writer, offset)
    }
    UnclosedCall(offset) => {
      writer.write_byte(35)
      parse_write_offset(writer, offset)
    }
    UnclosedIndex(offset) => {
      writer.write_byte(36)
      parse_write_offset(writer, offset)
    }
    MissingOperand(offset) => {
      writer.write_byte(37)
      parse_write_offset(writer, offset)
    }
    LexicalError(error, offset) => {
      writer.write_byte(38)
      parse_write_lex_error(writer, error)
      parse_write_offset(writer, offset)
    }
    InvalidOperatorState(offset) => {
      writer.write_byte(39)
      parse_write_offset(writer, offset)
    }
    UsingDoubleDispose(name, offset) => {
      writer.write_byte(40)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    UsingValueEscape(name, offset) => {
      writer.write_byte(41)
      writer.write_string(name)
      parse_write_offset(writer, offset)
    }
    ExpectedForIn(token, offset) => {
      writer.write_byte(45)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
    ExpectedForBody(token, offset) => {
      writer.write_byte(46)
      parse_write_optional_token(writer, token)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_expression_error(
  reader : @cache_binary.Reader,
  field : String,
) -> ExpressionError {
  let tag = reader.read_byte(field + ".tag")
  if tag <= 3 {
    let token = parse_read_optional_token(reader, field + ".token")
    return match tag {
      0 => ExpectedValue(token)
      1 => ExpectedCallDelimiter(token)
      2 => ExpectedFieldName(token)
      _ => ExpectedQualifiedName(token)
    }
  }
  if tag >= 4 && tag <= 9 {
    let token = parse_read_optional_token(reader, field + ".token")
    let offset = parse_read_offset(reader, field + ".offset")
    return match tag {
      4 => ExpectedRightBracket(token, offset)
      5 => ExpectedObjectField(token, offset)
      6 => ExpectedObjectColon(token, offset)
      7 => ExpectedObjectFieldNewline(token, offset)
      8 => ExpectedBlockNewline(token, offset)
      _ => ExpectedBlockItemNewline(token, offset)
    }
  }
  match tag {
    10 =>
      ExpectedAssignmentTarget(
        parse_read_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    11 =>
      ExpectedBlockBindingName(
        parse_read_optional_token(reader, field + ".token"),
      )
    12 =>
      ExpectedBlockEqual(parse_read_optional_token(reader, field + ".token"))
    13 =>
      ExpectedIfBody(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    14 =>
      ExpectedElseBranch(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    15 =>
      ExpectedMatchBody(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    16 =>
      ExpectedMatchBodyNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    17 =>
      ExpectedMatchArmArrow(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    18 =>
      ExpectedMatchArmNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    19 =>
      ExpectedWhileBody(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    20 =>
      ExpectedWhileBodyNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    21 =>
      ExpectedWhileArmArrow(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    22 =>
      ExpectedWhileArmNewline(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    23 =>
      ExpectedBreakValue(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    24 =>
      ExpectedContinueValue(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    25 =>
      ExpectedLambdaSyntax(
        parse_read_expectation(reader, field + ".expectation"),
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    26 =>
      UnexpectedLambdaTypeCloser(
        parse_read_offset(reader, field + ".left"),
        parse_read_offset(reader, field + ".right"),
      )
    27 => InvalidLambdaSyntax(parse_read_offset(reader, field + ".offset"))
    28 =>
      MatchPatternError(parse_read_pattern_error(reader, field + ".pattern"))
    29 => UnclosedObject(parse_read_offset(reader, field + ".offset"))
    30 => UnclosedBlock(parse_read_offset(reader, field + ".offset"))
    31 => UnclosedMatch(parse_read_offset(reader, field + ".offset"))
    32 => UnclosedWhile(parse_read_offset(reader, field + ".offset"))
    33 => ChainedComparison(parse_read_offset(reader, field + ".offset"))
    34 => UnclosedGroup(parse_read_offset(reader, field + ".offset"))
    35 => UnclosedCall(parse_read_offset(reader, field + ".offset"))
    36 => UnclosedIndex(parse_read_offset(reader, field + ".offset"))
    37 => MissingOperand(parse_read_offset(reader, field + ".offset"))
    38 =>
      LexicalError(
        parse_read_lex_error(reader, field + ".error"),
        parse_read_offset(reader, field + ".offset"),
      )
    39 => InvalidOperatorState(parse_read_offset(reader, field + ".offset"))
    40 =>
      UsingDoubleDispose(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    41 =>
      UsingValueEscape(
        reader.read_string(parse_event_maximum_text, field + ".name"),
        parse_read_offset(reader, field + ".offset"),
      )
    42 =>
      ExpectedArrayDelimiter(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    43 =>
      InvalidProductArity(
        reader.read_count(32, field + ".arity"),
        parse_read_offset(reader, field + ".offset"),
      )
    44 => UnclosedArray(parse_read_offset(reader, field + ".offset"))
    47 =>
      TypeArgumentError(
        parse_read_expectation(reader, field + ".expectation"),
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    45 =>
      ExpectedForIn(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    46 =>
      ExpectedForBody(
        parse_read_optional_token(reader, field + ".token"),
        parse_read_offset(reader, field + ".offset"),
      )
    _ => {
      reader.fail(field, "unknown expression-error discriminant")
      MissingOperand(0UL)
    }
  }
}

///|
fn parse_write_declaration_error(
  writer : @cache_binary.Writer,
  value : DeclarationError,
) -> Unit {
  match value {
    ExpectedDeclarationSyntax(expectation, token) => {
      writer.write_byte(0)
      parse_write_expectation(writer, expectation)
      parse_write_optional_token(writer, token)
    }
    DeclarationLexicalError(error, offset) => {
      writer.write_byte(1)
      parse_write_lex_error(writer, error)
      parse_write_offset(writer, offset)
    }
    DeclarationExpressionError(error) => {
      writer.write_byte(2)
      parse_write_expression_error(writer, error)
    }
    ImportAfterDeclaration(offset) => {
      writer.write_byte(3)
      parse_write_offset(writer, offset)
    }
    ReceiverMustBeFirst(offset) => {
      writer.write_byte(4)
      parse_write_offset(writer, offset)
    }
    InvalidReceiverType(type_, offset) => {
      writer.write_byte(5)
      parse_write_type(writer, type_)
      parse_write_offset(writer, offset)
    }
    UnexpectedTypeCloser(offset) => {
      writer.write_byte(6)
      parse_write_offset(writer, offset)
    }
    UnclosedTrait(offset) => {
      writer.write_byte(7)
      parse_write_offset(writer, offset)
    }
    UnclosedFunction(offset) => {
      writer.write_byte(8)
      parse_write_offset(writer, offset)
    }
    UnclosedImpl(offset) => {
      writer.write_byte(9)
      parse_write_offset(writer, offset)
    }
    UnclosedStruct(offset) => {
      writer.write_byte(10)
      parse_write_offset(writer, offset)
    }
    UnclosedEnum(offset) => {
      writer.write_byte(11)
      parse_write_offset(writer, offset)
    }
    UnclosedTupleVariant(offset) => {
      writer.write_byte(12)
      parse_write_offset(writer, offset)
    }
    UnclosedStructVariant(offset) => {
      writer.write_byte(13)
      parse_write_offset(writer, offset)
    }
    EmptyTupleVariant(offset) => {
      writer.write_byte(14)
      parse_write_offset(writer, offset)
    }
    InvalidProductTypeArity(arity, offset) => {
      writer.write_byte(22)
      writer.write_var_u64(arity.to_uint64())
      parse_write_offset(writer, offset)
    }
    UnclosedProductType(offset) => {
      writer.write_byte(23)
      parse_write_offset(writer, offset)
    }
    PublicImplNotAllowed(offset) => {
      writer.write_byte(15)
      parse_write_offset(writer, offset)
    }
    ForeignImplRequiresTrait(offset) => {
      writer.write_byte(16)
      parse_write_offset(writer, offset)
    }
    PublicForeignLibraryNotAllowed(offset) => {
      writer.write_byte(17)
      parse_write_offset(writer, offset)
    }
    PublicForeignLibraryMemberNotAllowed(offset) => {
      writer.write_byte(18)
      parse_write_offset(writer, offset)
    }
    GenericForeignLibraryMemberNotAllowed(offset) => {
      writer.write_byte(19)
      parse_write_offset(writer, offset)
    }
    ReceiverForeignLibraryMemberNotAllowed(offset) => {
      writer.write_byte(20)
      parse_write_offset(writer, offset)
    }
    ForeignLibraryMemberBodyNotAllowed(offset) => {
      writer.write_byte(21)
      parse_write_offset(writer, offset)
    }
  }
}

///|
fn parse_read_declaration_error(
  reader : @cache_binary.Reader,
  field : String,
  depth : Int,
) -> DeclarationError {
  match reader.read_byte(field + ".tag") {
    0 =>
      ExpectedDeclarationSyntax(
        parse_read_expectation(reader, field + ".expectation"),
        parse_read_optional_token(reader, field + ".token"),
      )
    1 =>
      DeclarationLexicalError(
        parse_read_lex_error(reader, field + ".error"),
        parse_read_offset(reader, field + ".offset"),
      )
    2 =>
      DeclarationExpressionError(
        parse_read_expression_error(reader, field + ".expression"),
      )
    3 => ImportAfterDeclaration(parse_read_offset(reader, field + ".offset"))
    4 => ReceiverMustBeFirst(parse_read_offset(reader, field + ".offset"))
    5 =>
      InvalidReceiverType(
        parse_read_type(reader, field + ".type", depth + 1),
        parse_read_offset(reader, field + ".offset"),
      )
    6 => UnexpectedTypeCloser(parse_read_offset(reader, field + ".offset"))
    7 => UnclosedTrait(parse_read_offset(reader, field + ".offset"))
    8 => UnclosedFunction(parse_read_offset(reader, field + ".offset"))
    9 => UnclosedImpl(parse_read_offset(reader, field + ".offset"))
    10 => UnclosedStruct(parse_read_offset(reader, field + ".offset"))
    11 => UnclosedEnum(parse_read_offset(reader, field + ".offset"))
    12 => UnclosedTupleVariant(parse_read_offset(reader, field + ".offset"))
    13 => UnclosedStructVariant(parse_read_offset(reader, field + ".offset"))
    14 => EmptyTupleVariant(parse_read_offset(reader, field + ".offset"))
    15 => PublicImplNotAllowed(parse_read_offset(reader, field + ".offset"))
    16 => ForeignImplRequiresTrait(parse_read_offset(reader, field + ".offset"))
    17 =>
      PublicForeignLibraryNotAllowed(
        parse_read_offset(reader, field + ".offset"),
      )
    18 =>
      PublicForeignLibraryMemberNotAllowed(
        parse_read_offset(reader, field + ".offset"),
      )
    19 =>
      GenericForeignLibraryMemberNotAllowed(
        parse_read_offset(reader, field + ".offset"),
      )
    20 =>
      ReceiverForeignLibraryMemberNotAllowed(
        parse_read_offset(reader, field + ".offset"),
      )
    21 =>
      ForeignLibraryMemberBodyNotAllowed(
        parse_read_offset(reader, field + ".offset"),
      )
    22 =>
      InvalidProductTypeArity(
        reader.read_count(32, field + ".arity"),
        parse_read_offset(reader, field + ".offset"),
      )
    23 => UnclosedProductType(parse_read_offset(reader, field + ".offset"))
    _ => {
      reader.fail(field, "unknown declaration-error discriminant")
      ImportAfterDeclaration(0UL)
    }
  }
}

///|
fn parse_write_event(writer : @cache_binary.Writer, event : ParseEvent) -> Unit {
  match event {
    Declaration(value) => {
      writer.write_byte(0)
      parse_write_declaration(writer, value)
    }
    Diagnostic(value) => {
      writer.write_byte(1)
      writer.write_byte(
        match value.severity {
          Error => 0
          Warning => 1
          Info => 2
          Hint => 3
        },
      )
      parse_write_declaration_error(writer, value.error)
    }
  }
}

///|
fn parse_read_event(
  reader : @cache_binary.Reader,
  field : String,
) -> ParseEvent {
  match reader.read_byte(field + ".tag") {
    0 => Declaration(parse_read_declaration(reader, field + ".declaration", 0))
    1 => {
      let severity = match reader.read_byte(field + ".severity") {
        0 => Error
        1 => Warning
        2 => Info
        3 => Hint
        _ => {
          reader.fail(field + ".severity", "unknown severity discriminant")
          Error
        }
      }
      Diagnostic({
        severity,
        error: parse_read_declaration_error(reader, field + ".error", 0),
      })
    }
    _ => {
      reader.fail(field, "unknown parse-event discriminant")
      Diagnostic({ severity: Error, error: ImportAfterDeclaration(0UL), })
    }
  }
}

///|
/// Encodes the complete parser syntax graph directly, without a JSON tree.
pub fn serialize_parse_events(
  events : Array[ParseEvent],
) -> Result[Bytes, String] {
  let writer = @cache_binary.Writer::new(size_hint=events.length() * 24 + 8)
  writer.write_u32_le(parse_event_payload_version)
  writer.write_var_u64(events.length().to_uint64())
  for event in events {
    parse_write_event(writer, event)
  }
  Ok(writer.to_bytes())
}

///|
/// Decodes the direct canonical V1 parser-event payload.
pub fn deserialize_parse_events(
  payload : Bytes,
) -> Result[Array[ParseEvent], String] {
  let reader = @cache_binary.Reader::new(payload, context="parse_event_payload")
  if reader.read_u32_le("version") != parse_event_payload_version {
    return Err(
      "parse_event_payload.version: unsupported parser-event payload version",
    )
  }
  let count = reader.read_count(parse_event_maximum_items, "event_count")
  let events : Array[ParseEvent] = []
  for index in 0..<count {
    events.push(parse_read_event(reader, "event[\{index}]"))
  }
  match reader.finish() {
    Ok(_) => Ok(events)
    Err(error) => Err(error)
  }
}
