///|
pub struct ForeignTypeDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct ForeignLibraryMember {
  name : String
  name_offset : UInt64
  parameters : Array[FnParameter]
  return_type : TypeExpr
  export_name : Bytes
  export_name_offset : UInt64
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct ForeignLibraryDeclaration {
  logical_name : Bytes
  logical_name_offset : UInt64
  namespace_alias : String
  alias_offset : UInt64
  members : Array[ForeignLibraryMember]
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
fn Parser::parse_foreign_type_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(ForeignTypeName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.finish_declaration_line() {
    Ok(_) =>
      Ok(
        ForeignType({
          visibility,
          name,
          name_offset,
          offset: declaration_offset,
        }),
      )
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_foreign_library_parameters(
  self : Parser,
) -> Result[Array[FnParameter], RecoveryFailure] {
  let parameters : Array[FnParameter] = []
  self.skip_newlines()
  if self.consume_right_paren_for_declaration() {
    return Ok(parameters)
  }
  while true {
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Identifier("self") =>
            return Err(
              declaration_failure(
                ReceiverForeignLibraryMemberNotAllowed(token.offset()),
              ),
            )
          _ => ()
        }
      None => ()
    }
    let parameter = match self.parse_parameter() {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    parameters.push(parameter)
    if self.consume_right_paren_for_declaration() {
      return Ok(parameters)
    }
    guard self.consume_comma() else {
      return Err(self.declaration_error(ParameterSeparatorOrClose))
    }
    self.skip_newlines()
    if self.consume_right_paren_for_declaration() {
      return Ok(parameters)
    }
  } nobreak {
    abort("unreachable foreign parameter parser termination")
  }
}

///|
fn Parser::parse_foreign_library_member(
  self : Parser,
  member_offset : UInt64,
) -> Result[ForeignLibraryMember, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(FunctionName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) if token.kind() is @tokenizer.Symbol(@tokenizer.Less) =>
      return Err(
        declaration_failure(
          GenericForeignLibraryMemberNotAllowed(token.offset()),
        ),
      )
    _ => ()
  }
  guard self.consume_left_paren() else {
    return Err(self.declaration_error(LeftParen))
  }
  let parameters = match self.parse_foreign_library_parameters() {
    Ok(value) => value
    Err(error) => return Err(error.inside_parenthesis())
  }
  match self.peek_token() {
    Some(token) if token.kind() is @tokenizer.Symbol(@tokenizer.Arrow) =>
      self.consume_lookahead()
    _ => return Err(self.declaration_error(Arrow))
  }
  let return_type = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => self.consume_lookahead()
        @tokenizer.Symbol(@tokenizer.LeftBrace) =>
          return Err(
            declaration_failure(
              ForeignLibraryMemberBodyNotAllowed(token.offset()),
            ),
          )
        _ => return Err(self.declaration_error(Equal))
      }
    None => return Err(self.declaration_error(Equal))
  }
  let (export_name, export_name_offset) = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.StringLiteral(value) => {
          self.consume_lookahead()
          (value, token.offset())
        }
        _ => return Err(self.declaration_error(ForeignLibraryExportName))
      }
    None => return Err(self.declaration_error(ForeignLibraryExportName))
  }
  match self.finish_declaration_line() {
    Ok(_) =>
      Ok({
        name,
        name_offset,
        parameters,
        return_type,
        export_name,
        export_name_offset,
        offset: member_offset,
      })
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_foreign_library_body(
  self : Parser,
  declaration_offset : UInt64,
) -> Result[Array[ForeignLibraryMember], RecoveryFailure] {
  let members : Array[ForeignLibraryMember] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(members)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(FunctionBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(members)
    }
    let member_offset = match self.peek_token() {
      Some(token) => {
        let offset = token.offset()
        match token.kind() {
          @tokenizer.Keyword(@tokenizer.Pub) =>
            return Err(
              declaration_failure(PublicForeignLibraryMemberNotAllowed(offset)),
            )
          @tokenizer.Keyword(@tokenizer.Fn) => self.consume_lookahead()
          _ => return Err(self.declaration_error(ForeignLibraryMemberKeyword))
        }
        offset
      }
      None => return Err(declaration_failure(UnclosedImpl(declaration_offset)))
    }
    let foreign_member = match
      self.parse_foreign_library_member(member_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    members.push(foreign_member)
    self.skip_newlines()
  } nobreak {
    abort("unreachable foreign library body parser termination")
  }
}

///|
fn Parser::parse_foreign_library_after_impl(
  self : Parser,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
  let (logical_name, logical_name_offset) = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.StringLiteral(value) => {
          self.consume_lookahead()
          (value, token.offset())
        }
        _ => return Err(self.declaration_error(ForeignLibraryName))
      }
    None => return Err(self.declaration_error(ForeignLibraryName))
  }
  match self.peek_token() {
    Some(token) if token.kind() is @tokenizer.Keyword(@tokenizer.As) =>
      self.consume_lookahead()
    _ => return Err(self.declaration_error(ForeignLibraryAlias))
  }
  let (namespace_alias, alias_offset) = match
    self.parse_identifier(ForeignLibraryAlias) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  guard self.consume_left_brace_for_declaration() else {
    return Err(self.declaration_error(LeftBrace))
  }
  let members = match self.parse_foreign_library_body(declaration_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  match self.finish_declaration_line() {
    Ok(_) =>
      Ok(
        ForeignLibrary({
          logical_name,
          logical_name_offset,
          namespace_alias,
          alias_offset,
          members,
          offset: declaration_offset,
        }),
      )
    Err(error) => Err(error)
  }
}
