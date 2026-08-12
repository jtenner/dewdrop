///|
pub struct FunctionDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  receiver : ReceiverParameter?
  parameters : Array[FnParameter]
  return_type : TypeExpr
  body : Block
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub fn FunctionDeclaration::has_receiver(self : FunctionDeclaration) -> Bool {
  self.receiver is Some(_)
}

///|
pub struct TestDeclaration {
  name : Bytes
  name_offset : UInt64
  expected_trap : Bytes?
  return_type : TypeExpr
  body : Block
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
pub struct ImplDeclaration {
  foreign_ : Bool
  type_parameters : Array[TypeParameter]
  trait_type : TypeExpr?
  target_type : TypeExpr
  methods : Array[FunctionDeclaration]
  offset : UInt64
} derive(Eq, Debug, ToJson, FromJson)

///|
fn Parser::parse_function_parameters(
  self : Parser,
) -> Result[ParsedFunctionParameters, RecoveryFailure] {
  let parameters : Array[FnParameter] = []
  let mut receiver : ReceiverParameter? = None
  self.skip_newlines()
  if self.consume_right_paren_for_declaration() {
    return Ok({ receiver, parameters })
  }
  while true {
    let (name, offset) = match self.parse_identifier(ParameterName) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    if name == "self" {
      if receiver is Some(_) || parameters.length() > 0 {
        return Err(declaration_failure(ReceiverMustBeFirst(offset)))
      }
      let explicit_type = match self.peek_token() {
        Some(token) =>
          match token.kind() {
            @tokenizer.Symbol(@tokenizer.Colon) => {
              self.consume_lookahead()
              match self.parse_type() {
                Ok(value) => Some(value)
                Err(error) => return Err(error)
              }
            }
            _ => None
          }
        None => None
      }
      receiver = Some({ explicit_type, offset })
    } else {
      match self.peek_token() {
        Some(token) =>
          match token.kind() {
            @tokenizer.Symbol(@tokenizer.Colon) => self.consume_lookahead()
            _ => return Err(self.declaration_error(Colon))
          }
        None => return Err(self.declaration_error(Colon))
      }
      let type_ = match self.parse_type() {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      parameters.push({ name, type_, offset })
    }
    if self.consume_right_paren_for_declaration() {
      return Ok({ receiver, parameters })
    }
    guard self.consume_comma() else {
      return Err(self.declaration_error(ParameterSeparatorOrClose))
    }
    self.skip_newlines()
    if self.consume_right_paren_for_declaration() {
      return Ok({ receiver, parameters })
    }
  } nobreak {
    abort("unreachable function parameter parser termination")
  }
}

///|
fn function_block_error(
  failure : RecoveryFailure,
  function_offset : UInt64,
) -> RecoveryFailure {
  let fence = failure.fence()
  let expression_error = failure.expression_error()
  let declaration_error = match expression_error {
    ExpectedBlockNewline(token, _) =>
      ExpectedDeclarationSyntax(FunctionBodyNewline, token)
    ExpectedBlockItemNewline(token, _) =>
      ExpectedDeclarationSyntax(LineEnd, token)
    UnclosedBlock(_) => UnclosedFunction(function_offset)
    _ => DeclarationExpressionError(expression_error)
  }
  declaration_failure_with_fence(declaration_error, fence)
}

///|
fn Parser::parse_function_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[FunctionDeclaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(FunctionName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let type_parameters = match self.parse_optional_type_parameters() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  guard self.consume_left_paren() else {
    return Err(self.declaration_error(LeftParen))
  }
  let parsed_parameters = match self.parse_function_parameters() {
    Ok(value) => value
    Err(error) => return Err(error.inside_parenthesis())
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Arrow) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Arrow))
      }
    None => return Err(self.declaration_error(Arrow))
  }
  let return_type = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let open_offset = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          let offset = token.offset()
          self.consume_lookahead()
          offset
        }
        _ => return Err(self.declaration_error(LeftBrace))
      }
    None => return Err(self.declaration_error(LeftBrace))
  }
  let body = match self.parse_block_after_left_brace(open_offset) {
    Ok(value) => value
    Err(error) =>
      return Err(function_block_error(error, declaration_offset).inside_brace())
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
    receiver: parsed_parameters.receiver,
    parameters: parsed_parameters.parameters,
    return_type,
    body,
    offset: declaration_offset,
  })
}

///|
fn Parser::parse_test_after_keyword(
  self : Parser,
  declaration_offset : UInt64,
) -> Result[TestDeclaration, RecoveryFailure] {
  let (name, name_offset) = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.StringLiteral(value) => {
          self.consume_lookahead()
          (value, token.offset())
        }
        _ => return Err(self.declaration_error(TestName))
      }
    None => return Err(self.declaration_error(TestName))
  }
  let expected_trap = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier("expect_trap") => {
          self.consume_lookahead()
          match self.peek_token() {
            Some(value_token) =>
              match value_token.kind() {
                @tokenizer.StringLiteral(value) => {
                  self.consume_lookahead()
                  Some(value)
                }
                _ => return Err(self.declaration_error(TestExpectedTrap))
              }
            None => return Err(self.declaration_error(TestExpectedTrap))
          }
        }
        _ => None
      }
    None => None
  }
  let open_offset = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          token.offset()
        }
        _ => return Err(self.declaration_error(LeftBrace))
      }
    None => return Err(self.declaration_error(LeftBrace))
  }
  let body = match self.parse_block_after_left_brace(open_offset) {
    Ok(value) => value
    Err(error) =>
      return Err(function_block_error(error, declaration_offset).inside_brace())
  }
  match self.finish_declaration_line() {
    Ok(_) =>
      Ok({
        name,
        name_offset,
        expected_trap,
        return_type: NamedType("Unit", declaration_offset),
        body,
        offset: declaration_offset,
      })
    Err(error) => Err(error)
  }
}

///|
fn Parser::parse_impl_body(
  self : Parser,
  impl_offset : UInt64,
) -> Result[Array[FunctionDeclaration], RecoveryFailure] {
  let methods : Array[FunctionDeclaration] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(methods)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(FunctionBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(methods)
    }
    let method_offset = match self.peek_token() {
      Some(token) => {
        let offset = token.offset()
        match token.kind() {
          @tokenizer.Error(_) =>
            return Err(self.declaration_error(ImplMemberKeyword))
          @tokenizer.Keyword(@tokenizer.Fn) => self.consume_lookahead()
          _ => return Err(self.declaration_error(ImplMemberKeyword))
        }
        offset
      }
      None => return Err(declaration_failure(UnclosedImpl(impl_offset)))
    }
    let parsed_method = match
      self.parse_function_after_keyword(ModuleVisible, method_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    methods.push(parsed_method)
    self.skip_newlines()
  } nobreak {
    abort("unreachable impl body parser termination")
  }
}

///|
fn Parser::parse_impl_after_keyword(
  self : Parser,
  foreign_ : Bool,
  declaration_offset : UInt64,
) -> Result[ImplDeclaration, RecoveryFailure] {
  let type_parameters = match self.parse_optional_type_parameters() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let first_type = match self.parse_type() {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let (trait_type, target_type) = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.For) => {
          self.consume_lookahead()
          let target = match self.parse_type() {
            Ok(value) => value
            Err(error) => return Err(error)
          }
          (Some(first_type), target)
        }
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          if foreign_ {
            return Err(
              declaration_failure(ForeignImplRequiresTrait(declaration_offset)),
            )
          }
          (None, first_type)
        }
        _ => return Err(self.declaration_error(ForOrLeftBrace))
      }
    None => return Err(self.declaration_error(ForOrLeftBrace))
  }
  guard self.consume_left_brace_for_declaration() else {
    return Err(self.declaration_error(LeftBrace))
  }
  let methods = match self.parse_impl_body(declaration_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  match self.finish_declaration_line() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  Ok({
    foreign_,
    type_parameters,
    trait_type,
    target_type,
    methods,
    offset: declaration_offset,
  })
}
