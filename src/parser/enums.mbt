///|
pub enum EnumVariant {
  UnitVariant(String, UInt64)
  TupleVariant(String, Array[TypeExpr], UInt64)
  StructVariant(String, Array[StructField], UInt64)
} derive(Eq, Debug)

///|
pub fn EnumVariant::name(self : EnumVariant) -> String {
  match self {
    UnitVariant(name, _)
    | TupleVariant(name, _, _)
    | StructVariant(name, _, _) => name
  }
}

///|
pub fn EnumVariant::offset(self : EnumVariant) -> UInt64 {
  match self {
    UnitVariant(_, offset)
    | TupleVariant(_, _, offset)
    | StructVariant(_, _, offset) => offset
  }
}

///|
pub struct EnumDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  variants : Array[EnumVariant]
  derives : Array[DeriveRequest]
  offset : UInt64
} derive(Eq, Debug)

///|
fn Parser::finish_enum_variant_line(
  self : Parser,
  enum_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(declaration_failure(UnclosedEnum(enum_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          Ok(())
        }
        _ => Err(self.declaration_error(LineEnd))
      }
  }
}

///|
fn Parser::parse_tuple_variant_types(
  self : Parser,
  variant_offset : UInt64,
) -> Result[Array[TypeExpr], RecoveryFailure] {
  let types : Array[TypeExpr] = []
  self.skip_newlines()
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightParen) =>
          return Err(declaration_failure(EmptyTupleVariant(variant_offset)))
        _ => ()
      }
    None =>
      return Err(declaration_failure(UnclosedTupleVariant(variant_offset)))
  }
  while true {
    let type_ = match self.parse_type() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    types.push(type_)
    self.skip_newlines()
    match self.peek_token() {
      None =>
        return Err(declaration_failure(UnclosedTupleVariant(variant_offset)))
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.RightParen) => {
            self.consume_lookahead()
            return Ok(types)
          }
          @tokenizer.Symbol(@tokenizer.Comma) => {
            self.consume_lookahead()
            self.skip_newlines()
            match self.peek_token() {
              None =>
                return Err(
                  declaration_failure(UnclosedTupleVariant(variant_offset)),
                )
              Some(next) =>
                match next.kind() {
                  @tokenizer.Symbol(@tokenizer.RightParen) => {
                    self.consume_lookahead()
                    return Ok(types)
                  }
                  _ => ()
                }
            }
          }
          @tokenizer.Symbol(@tokenizer.RightBrace) =>
            return Err(
              declaration_failure(UnclosedTupleVariant(variant_offset)),
            )
          _ => return Err(self.declaration_error(VariantTypeSeparatorOrClose))
        }
    }
  } nobreak {
    abort("unreachable tuple variant parser termination")
  }
}

///|
fn Parser::finish_enum_variant_field_line(
  self : Parser,
  variant_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(declaration_failure(UnclosedStructVariant(variant_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          Ok(())
        }
        _ => Err(self.declaration_error(LineEnd))
      }
  }
}

///|
fn Parser::parse_enum_variant_field(
  self : Parser,
  variant_offset : UInt64,
) -> Result[StructField, RecoveryFailure] {
  let (name, offset) = match self.parse_identifier(EnumVariantFieldName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Colon))
      }
    None =>
      return Err(declaration_failure(UnclosedStructVariant(variant_offset)))
  }
  let type_ = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.finish_enum_variant_field_line(variant_offset) {
    Ok(_) => Ok({ name, type_, offset })
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_struct_variant_fields(
  self : Parser,
  variant_offset : UInt64,
) -> Result[Array[StructField], RecoveryFailure] {
  let fields : Array[StructField] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(fields)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(EnumVariantBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(fields)
    }
    if self.peek_token() is None {
      return Err(declaration_failure(UnclosedStructVariant(variant_offset)))
    }
    let field = match self.parse_enum_variant_field(variant_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    fields.push(field)
    self.skip_newlines()
  } nobreak {
    abort("unreachable struct variant parser termination")
  }
}

///|
fn Parser::parse_enum_variant(
  self : Parser,
  enum_offset : UInt64,
) -> Result[EnumVariant, RecoveryFailure] {
  let (name, variant_offset) = match self.parse_identifier(EnumVariantName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    None => Err(declaration_failure(UnclosedEnum(enum_offset)))
    Some(token) =>
      match token.kind() {
        @tokenizer.Newline => {
          self.consume_lookahead()
          Ok(UnitVariant(name, variant_offset))
        }
        @tokenizer.Symbol(@tokenizer.LeftParen) => {
          self.consume_lookahead()
          let types = match self.parse_tuple_variant_types(variant_offset) {
            Ok(value) => value
            Err(error) => return Err(error.inside_parenthesis())
          }
          match self.finish_enum_variant_line(enum_offset) {
            Ok(_) => Ok(TupleVariant(name, types, variant_offset))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          let fields = match self.parse_struct_variant_fields(variant_offset) {
            Ok(value) => value
            Err(error) => return Err(error.inside_brace())
          }
          match self.finish_enum_variant_line(enum_offset) {
            Ok(_) => Ok(StructVariant(name, fields, variant_offset))
            Err(error) => Err(error)
          }
        }
        _ => Err(self.declaration_error(EnumVariantPayloadOrLineEnd))
      }
  }
}

///|
fn Parser::parse_enum_body(
  self : Parser,
  enum_offset : UInt64,
) -> Result[Array[EnumVariant], RecoveryFailure] {
  let variants : Array[EnumVariant] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(variants)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(EnumBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(variants)
    }
    if self.peek_token() is None {
      return Err(declaration_failure(UnclosedEnum(enum_offset)))
    }
    let variant = match self.parse_enum_variant(enum_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    variants.push(variant)
    self.skip_newlines()
  } nobreak {
    abort("unreachable enum body parser termination")
  }
}

///|
fn Parser::parse_enum_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[EnumDeclaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(EnumName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let type_parameters = match self.parse_optional_type_parameters() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  guard self.consume_left_brace_for_declaration() else {
    return Err(self.declaration_error(LeftBrace))
  }
  let variants = match self.parse_enum_body(declaration_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  let derives = match self.parse_optional_derive_requests() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.finish_declaration_line() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  Ok({
    visibility,
    name,
    name_offset,
    type_parameters,
    variants,
    derives,
    offset: declaration_offset,
  })
}
