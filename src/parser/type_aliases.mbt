///|
pub struct TypeAliasDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  target : TypeExpr
  offset : UInt64
} derive(Eq, Debug)

///|
fn Parser::parse_type_alias_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[TypeAliasDeclaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(TypeAliasName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let type_parameters = match self.parse_optional_type_parameters() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Equal))
      }
    None => return Err(self.declaration_error(Equal))
  }
  self.skip_newlines()
  let target = match self.parse_type() {
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
    target,
    offset: declaration_offset,
  })
}
