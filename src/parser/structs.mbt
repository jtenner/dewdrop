///|
pub struct StructField {
  mutable_ : Bool
  name : String
  type_ : TypeExpr
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct StructDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  fields : Array[StructField]
  derives : Array[DeriveRequest]
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
fn Parser::finish_struct_field_line(
  self : Parser,
  struct_offset : UInt64,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Err(declaration_failure(UnclosedStruct(struct_offset)))
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
fn Parser::parse_struct_field(
  self : Parser,
  struct_offset : UInt64,
) -> Result[StructField, RecoveryFailure] {
  let mutable_ = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Mut) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
  let (name, offset) = match self.parse_identifier(StructFieldName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Colon) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Colon))
      }
    None => return Err(declaration_failure(UnclosedStruct(struct_offset)))
  }
  let type_ = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.finish_struct_field_line(struct_offset) {
    Ok(_) => Ok({ mutable_, name, type_, offset })
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_struct_body(
  self : Parser,
  struct_offset : UInt64,
) -> Result[Array[StructField], RecoveryFailure] {
  let fields : Array[StructField] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(fields)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(StructBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(fields)
    }
    if self.peek_token() is None {
      return Err(declaration_failure(UnclosedStruct(struct_offset)))
    }
    let field = match self.parse_struct_field(struct_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    fields.push(field)
    self.skip_newlines()
  } nobreak {
    abort("unreachable struct body parser termination")
  }
}

///|
fn Parser::parse_struct_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[StructDeclaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(StructName) {
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
  let fields = match self.parse_struct_body(declaration_offset) {
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
    fields,
    derives,
    offset: declaration_offset,
  })
}
