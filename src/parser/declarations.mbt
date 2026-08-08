///|
/// Dew declarations are module-visible by default. `Public` additionally
/// exports the declaration from its module. There is no private visibility.
pub enum DeclarationVisibility {
  ModuleVisible
  Public
} derive(Eq, Debug)

///|
/// Initial type-expression representation. Generic parameters and named types
/// use the same identifier token and are resolved during semantic analysis.
pub enum TypeExpr {
  NamedType(String, UInt64)
  AppliedType(TypeExpr, Array[TypeExpr], UInt64)
  FunctionType(Array[TypeExpr], TypeExpr, UInt64)
} derive(Eq, Debug)

///|
pub fn TypeExpr::offset(self : TypeExpr) -> UInt64 {
  match self {
    NamedType(_, offset)
    | AppliedType(_, _, offset)
    | FunctionType(_, _, offset) => offset
  }
}

///|
pub struct TypeParameter {
  name : String
  offset : UInt64
} derive(Eq, Debug)

///|
/// One trait requested by a postfix `derive(...)` clause.
pub struct DeriveRequest {
  name : String
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct FnParameter {
  name : String
  type_ : TypeExpr
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct BuiltinDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  parameters : Array[FnParameter]
  return_type : TypeExpr
  builtin_name : Bytes
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct ImportDeclaration {
  open_ : Bool
  path : Array[String]
  wildcard : Bool
  import_alias : String?
  import_alias_offset : UInt64
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct LetDeclaration {
  visibility : DeclarationVisibility
  mutable_ : Bool
  name : String
  name_offset : UInt64
  value : Expr
  offset : UInt64
} derive(Eq, Debug)

///|
pub struct ReceiverParameter {
  explicit_type : TypeExpr?
  offset : UInt64
} derive(Eq, Debug)

///|
priv struct ParsedFunctionParameters {
  receiver : ReceiverParameter?
  parameters : Array[FnParameter]
}

///|
pub struct TraitMethod {
  name : String
  name_offset : UInt64
  receiver : ReceiverParameter?
  parameters : Array[FnParameter]
  return_type : TypeExpr
  offset : UInt64
} derive(Eq, Debug)

///|
pub fn TraitMethod::has_receiver(self : TraitMethod) -> Bool {
  self.receiver is Some(_)
}

///|
pub struct TraitDeclaration {
  visibility : DeclarationVisibility
  name : String
  name_offset : UInt64
  type_parameters : Array[TypeParameter]
  methods : Array[TraitMethod]
  offset : UInt64
} derive(Eq, Debug)

///|
pub enum Declaration {
  Import(ImportDeclaration)
  Builtin(BuiltinDeclaration)
  Let(LetDeclaration)
  Trait(TraitDeclaration)
  Function(FunctionDeclaration)
  Test(TestDeclaration)
  Impl(ImplDeclaration)
  Struct(StructDeclaration)
  Enum(EnumDeclaration)
  TypeAlias(TypeAliasDeclaration)
} derive(Eq, Debug)

///|
pub fn Declaration::offset(self : Declaration) -> UInt64 {
  match self {
    Import(declaration) => declaration.offset
    Builtin(declaration) => declaration.offset
    Let(declaration) => declaration.offset
    Trait(declaration) => declaration.offset
    Function(declaration) => declaration.offset
    Test(declaration) => declaration.offset
    Impl(declaration) => declaration.offset
    Struct(declaration) => declaration.offset
    Enum(declaration) => declaration.offset
    TypeAlias(declaration) => declaration.offset
  }
}

///|
/// The exact grammar element expected when declaration parsing stopped.
pub enum DeclarationExpectation {
  DeclarationKeyword
  ImportPathSegment
  ImportAlias
  ImportWildcard
  BuiltinName
  BindingName
  TraitName
  StructName
  StructFieldName
  StructBodyNewline
  EnumName
  TypeAliasName
  EnumBodyNewline
  EnumVariantName
  EnumVariantPayloadOrLineEnd
  EnumVariantBodyNewline
  EnumVariantFieldName
  VariantTypeSeparatorOrClose
  FunctionName
  TestName
  TestExpectedTrap
  FunctionBodyNewline
  ImplMemberKeyword
  ForOrLeftBrace
  TraitMethodKeyword
  TraitMethodName
  TraitBodyNewline
  TypeParameter
  TypeParameterSeparatorOrClose
  DeriveName
  DeriveSeparatorOrClose
  TypeArgumentSeparatorOrClose
  LeftParen
  LeftBrace
  ParameterName
  Colon
  ParameterSeparatorOrClose
  Type
  Arrow
  Equal
  BuiltinString
  LineEnd
} derive(Eq, Debug)

///|
pub enum DeclarationError {
  ExpectedDeclarationSyntax(DeclarationExpectation, @tokenizer.Token?)
  DeclarationLexicalError(@tokenizer.LexError, UInt64)
  DeclarationExpressionError(ExpressionError)
  ImportAfterDeclaration(UInt64)
  ReceiverMustBeFirst(UInt64)
  InvalidReceiverType(TypeExpr, UInt64)
  UnexpectedTypeCloser(UInt64)
  UnclosedTrait(UInt64)
  UnclosedFunction(UInt64)
  UnclosedImpl(UInt64)
  UnclosedStruct(UInt64)
  UnclosedEnum(UInt64)
  UnclosedTupleVariant(UInt64)
  UnclosedStructVariant(UInt64)
  EmptyTupleVariant(UInt64)
  PublicImplNotAllowed(UInt64)
  ForeignImplRequiresTrait(UInt64)
} derive(Eq, Debug)

///|
pub fn DeclarationError::offset(self : DeclarationError) -> UInt64 {
  match self {
    ExpectedDeclarationSyntax(_, token) =>
      match token {
        Some(value) => value.offset()
        None => 0UL
      }
    DeclarationLexicalError(_, offset)
    | ImportAfterDeclaration(offset)
    | ReceiverMustBeFirst(offset)
    | InvalidReceiverType(_, offset)
    | UnexpectedTypeCloser(offset)
    | UnclosedTrait(offset)
    | UnclosedFunction(offset)
    | UnclosedImpl(offset)
    | UnclosedStruct(offset)
    | UnclosedEnum(offset)
    | UnclosedTupleVariant(offset)
    | UnclosedStructVariant(offset)
    | EmptyTupleVariant(offset)
    | PublicImplNotAllowed(offset)
    | ForeignImplRequiresTrait(offset) => offset
    DeclarationExpressionError(error) => error.offset()
  }
}

///|
fn Parser::declaration_error(
  self : Parser,
  expectation : DeclarationExpectation,
) -> RecoveryFailure {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Error(error) => {
          let offset = token.offset()
          self.consume_lookahead()
          declaration_failure(DeclarationLexicalError(error, offset))
        }
        _ =>
          declaration_failure(
            ExpectedDeclarationSyntax(expectation, Some(token)),
          )
      }
    None => declaration_failure(ExpectedDeclarationSyntax(expectation, None))
  }
}

///|
fn Parser::parse_optional_derive_requests(
  self : Parser,
) -> Result[Array[DeriveRequest], RecoveryFailure] {
  let requests : Array[DeriveRequest] = []
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier("derive") => self.consume_lookahead()
        _ => return Ok(requests)
      }
    None => return Ok(requests)
  }
  guard self.consume_left_paren() else {
    return Err(self.declaration_error(LeftParen))
  }
  self.skip_newlines()
  while true {
    let (name, offset) = match self.parse_identifier(DeriveName) {
      Ok(value) => value
      Err(error) => return Err(error.inside_parenthesis())
    }
    requests.push({ name, offset })
    self.skip_newlines()
    if self.consume_right_paren_for_declaration() {
      return Ok(requests)
    }
    guard self.consume_comma() else {
      return Err(
        self.declaration_error(DeriveSeparatorOrClose).inside_parenthesis(),
      )
    }
    self.skip_newlines()
    if self.consume_right_paren_for_declaration() {
      return Ok(requests)
    }
  } nobreak {
    abort("unreachable derive request parser termination")
  }
}

///|
fn Parser::parse_identifier(
  self : Parser,
  expectation : DeclarationExpectation,
) -> Result[(String, UInt64), RecoveryFailure] {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Identifier(name) => {
          let offset = token.offset()
          self.consume_lookahead()
          Ok((name, offset))
        }
        _ => Err(self.declaration_error(expectation))
      }
    None => Err(self.declaration_error(expectation))
  }
}

///|
priv struct TypeCloserState {
  mut pending : Int
  mut offset : UInt64
}

///|
fn Parser::consume_type_greater(self : Parser, state : TypeCloserState) -> Bool {
  if state.pending > 0 {
    state.pending -= 1
    return true
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Greater) => {
          self.consume_lookahead()
          true
        }
        @tokenizer.Symbol(@tokenizer.ShiftRight) => {
          state.pending = 1
          state.offset = token.offset()
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::parse_type_arguments(
  self : Parser,
  state : TypeCloserState,
  base : TypeExpr,
  open_offset : UInt64,
) -> Result[TypeExpr, RecoveryFailure] {
  let arguments : Array[TypeExpr] = []
  self.skip_newlines()
  while true {
    let argument = match self.parse_type_inner(state) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    arguments.push(argument)
    if self.consume_type_greater(state) {
      return Ok(AppliedType(base, arguments, open_offset))
    }
    guard self.consume_comma() else {
      return Err(self.declaration_error(TypeArgumentSeparatorOrClose))
    }
    self.skip_newlines()
    if self.consume_type_greater(state) {
      return Ok(AppliedType(base, arguments, open_offset))
    }
  } nobreak {
    abort("unreachable type argument parser termination")
  }
}

///|
fn Parser::parse_function_type(
  self : Parser,
  state : TypeCloserState,
  offset : UInt64,
) -> Result[TypeExpr, RecoveryFailure] {
  guard self.consume_left_paren() else {
    return Err(self.declaration_error(LeftParen))
  }
  let parameters : Array[TypeExpr] = []
  self.skip_newlines()
  if !self.consume_right_paren_for_declaration() {
    while true {
      let parameter = match self.parse_type_inner(state) {
        Ok(value) => value
        Err(error) => return Err(error)
      }
      parameters.push(parameter)
      self.skip_newlines()
      if self.consume_right_paren_for_declaration() {
        break
      }
      guard self.consume_comma() else {
        return Err(self.declaration_error(ParameterSeparatorOrClose))
      }
      self.skip_newlines()
    }
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Arrow) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Arrow))
      }
    None => return Err(self.declaration_error(Arrow))
  }
  self.skip_newlines()
  let result = match self.parse_type_inner(state) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  Ok(FunctionType(parameters, result, offset))
}

///|
fn Parser::parse_type_inner(
  self : Parser,
  state : TypeCloserState,
) -> Result[TypeExpr, RecoveryFailure] {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Keyword(@tokenizer.Fn) => {
          let offset = token.offset()
          self.consume_lookahead()
          return self.parse_function_type(state, offset)
        }
        _ => ()
      }
    None => ()
  }
  let (name, offset) = match self.parse_identifier(Type) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  let base = NamedType(name, offset)
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Less) => {
          let open_offset = token.offset()
          self.consume_lookahead()
          match self.parse_type_arguments(state, base, open_offset) {
            Ok(value) => Ok(value)
            Err(error) => Err(error.inside_angle())
          }
        }
        _ => Ok(base)
      }
    None => Ok(base)
  }
}

///|
fn Parser::parse_type(self : Parser) -> Result[TypeExpr, RecoveryFailure] {
  let state : TypeCloserState = { pending: 0, offset: 0UL }
  let type_ = match self.parse_type_inner(state) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  if state.pending > 0 {
    Err(declaration_failure(UnexpectedTypeCloser(state.offset)))
  } else {
    Ok(type_)
  }
}

///|
fn Parser::consume_left_paren(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftParen) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::consume_right_paren_for_declaration(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightParen) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::consume_left_brace_for_declaration(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.LeftBrace) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::consume_right_brace_for_declaration(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.RightBrace) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::consume_comma(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Comma) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::consume_greater(self : Parser) -> Bool {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Greater) => {
          self.consume_lookahead()
          true
        }
        _ => false
      }
    None => false
  }
}

///|
fn Parser::parse_type_parameters(
  self : Parser,
) -> Result[Array[TypeParameter], RecoveryFailure] {
  let parameters : Array[TypeParameter] = []
  self.skip_newlines()
  while true {
    let parameter : TypeParameter = match self.parse_identifier(TypeParameter) {
      Ok((name, offset)) => { name, offset }
      Err(error) => return Err(error)
    }
    parameters.push(parameter)
    if self.consume_greater() {
      return Ok(parameters)
    }
    guard self.consume_comma() else {
      return Err(self.declaration_error(TypeParameterSeparatorOrClose))
    }
    self.skip_newlines()
    if self.consume_greater() {
      return Ok(parameters)
    }
  } nobreak {
    abort("unreachable type parameter parser termination")
  }
}

///|
fn Parser::parse_optional_type_parameters(
  self : Parser,
) -> Result[Array[TypeParameter], RecoveryFailure] {
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Less) => {
          self.consume_lookahead()
          match self.parse_type_parameters() {
            Ok(value) => Ok(value)
            Err(error) => Err(error.inside_angle())
          }
        }
        _ => Ok([])
      }
    None => Ok([])
  }
}

///|
fn Parser::parse_parameter(
  self : Parser,
) -> Result[FnParameter, RecoveryFailure] {
  let (name, offset) = match self.parse_identifier(ParameterName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
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
  Ok({ name, type_, offset })
}

///|
fn Parser::parse_parameters(
  self : Parser,
) -> Result[Array[FnParameter], RecoveryFailure] {
  let parameters : Array[FnParameter] = []
  self.skip_newlines()
  if self.consume_right_paren_for_declaration() {
    return Ok(parameters)
  }
  while true {
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
    abort("unreachable parameter parser termination")
  }
}

///|
fn Parser::finish_declaration_line(
  self : Parser,
) -> Result[Unit, RecoveryFailure] {
  match self.peek_token() {
    None => Ok(())
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
fn Parser::parse_builtin_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(BuiltinName) {
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
  let parameters = match self.parse_parameters() {
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
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Symbol(@tokenizer.Equal) => self.consume_lookahead()
        _ => return Err(self.declaration_error(Equal))
      }
    None => return Err(self.declaration_error(Equal))
  }
  let builtin_name = match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.StringLiteral(value) => {
          self.consume_lookahead()
          value
        }
        _ => return Err(self.declaration_error(BuiltinString))
      }
    None => return Err(self.declaration_error(BuiltinString))
  }
  match self.finish_declaration_line() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  Ok(
    Builtin({
      visibility,
      name,
      name_offset,
      type_parameters,
      parameters,
      return_type,
      builtin_name,
      offset: declaration_offset,
    }),
  )
}

///|
fn Parser::parse_trait_method_parameters(
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
      match self.peek_token() {
        Some(token) =>
          match token.kind() {
            @tokenizer.Symbol(@tokenizer.Colon) => {
              self.consume_lookahead()
              let receiver_type = match self.parse_type() {
                Ok(value) => value
                Err(error) => return Err(error)
              }
              match receiver_type {
                NamedType("Self", _) => ()
                _ =>
                  return Err(
                    declaration_failure(
                      InvalidReceiverType(receiver_type, offset),
                    ),
                  )
              }
            }
            _ => ()
          }
        None => ()
      }
      receiver = Some({ explicit_type: None, offset })
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
    abort("unreachable trait method parameter parser termination")
  }
}

///|
fn Parser::parse_trait_method_after_keyword(
  self : Parser,
  method_offset : UInt64,
) -> Result[TraitMethod, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(TraitMethodName) {
    Ok(value) => value
    Err(error) => return Err(error)
  }
  guard self.consume_left_paren() else {
    return Err(self.declaration_error(LeftParen))
  }
  let parsed_parameters = match self.parse_trait_method_parameters() {
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
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(LineEnd))
  }
  Ok({
    name,
    name_offset,
    receiver: parsed_parameters.receiver,
    parameters: parsed_parameters.parameters,
    return_type,
    offset: method_offset,
  })
}

///|
fn Parser::parse_trait_body_after_left_brace(
  self : Parser,
  declaration_offset : UInt64,
) -> Result[Array[TraitMethod], RecoveryFailure] {
  let methods : Array[TraitMethod] = []
  if self.consume_right_brace_for_declaration() {
    return Ok(methods)
  }
  guard self.consume_newline_token() else {
    return Err(self.declaration_error(TraitBodyNewline))
  }
  self.skip_newlines()
  while true {
    if self.consume_right_brace_for_declaration() {
      return Ok(methods)
    }
    let method_offset = match self.peek_token() {
      None => return Err(declaration_failure(UnclosedTrait(declaration_offset)))
      Some(token) => {
        let offset = token.offset()
        match token.kind() {
          @tokenizer.Error(_) =>
            return Err(self.declaration_error(TraitMethodKeyword))
          @tokenizer.Keyword(@tokenizer.Fn) => self.consume_lookahead()
          _ => return Err(self.declaration_error(TraitMethodKeyword))
        }
        offset
      }
    }
    let parsed_method = match
      self.parse_trait_method_after_keyword(method_offset) {
      Ok(value) => value
      Err(error) => return Err(error)
    }
    methods.push(parsed_method)
    self.skip_newlines()
  } nobreak {
    abort("unreachable trait body parser termination")
  }
}

///|
fn Parser::parse_trait_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
  let (name, name_offset) = match self.parse_identifier(TraitName) {
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
  let methods = match
    self.parse_trait_body_after_left_brace(declaration_offset) {
    Ok(value) => value
    Err(error) => return Err(error.inside_brace())
  }
  match self.finish_declaration_line() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  Ok(
    Trait({
      visibility,
      name,
      name_offset,
      type_parameters,
      methods,
      offset: declaration_offset,
    }),
  )
}

///|
fn Parser::parse_let_after_keyword(
  self : Parser,
  visibility : DeclarationVisibility,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
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
  let (name, name_offset) = match self.parse_identifier(BindingName) {
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
  let value = match self.parse_expression_recoverable() {
    Ok(expression) => expression
    Err(error) => return Err(error)
  }
  match self.finish_declaration_line() {
    Ok(_) => ()
    Err(error) => return Err(error)
  }
  Ok(
    Let({
      visibility,
      mutable_,
      name,
      name_offset,
      value,
      offset: declaration_offset,
    }),
  )
}

///|
fn Parser::parse_import_after_keyword(
  self : Parser,
  open_ : Bool,
  declaration_offset : UInt64,
) -> Result[Declaration, RecoveryFailure] {
  let path : Array[String] = []
  let mut wildcard = false
  while true {
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Identifier(segment) => {
            path.push(segment)
            self.consume_lookahead()
          }
          @tokenizer.Keyword(@tokenizer.Package) => {
            path.push("package")
            self.consume_lookahead()
          }
          _ => return Err(self.declaration_error(ImportPathSegment))
        }
      None => return Err(self.declaration_error(ImportPathSegment))
    }
    match self.peek_token() {
      Some(token) =>
        match token.kind() {
          @tokenizer.Symbol(@tokenizer.Dot) => {
            self.consume_lookahead()
            match self.peek_token() {
              Some(next) if next.kind() is @tokenizer.Symbol(@tokenizer.Star) => {
                self.consume_lookahead()
                wildcard = true
                break
              }
              _ => continue
            }
          }
          _ => ()
        }
      None => ()
    }
    break
  }
  let mut import_alias : String? = None
  let mut import_alias_offset = declaration_offset
  match self.peek_token() {
    Some(token) if token.kind() is @tokenizer.Keyword(@tokenizer.As) => {
      self.consume_lookahead()
      if wildcard || open_ {
        return Err(self.declaration_error(ImportAlias))
      }
      match self.peek_token() {
        Some(alias_token) =>
          match alias_token.kind() {
            @tokenizer.AtIdentifier(name) => {
              import_alias = Some(name)
              import_alias_offset = alias_token.offset()
              self.consume_lookahead()
            }
            _ => return Err(self.declaration_error(ImportAlias))
          }
        None => return Err(self.declaration_error(ImportAlias))
      }
    }
    _ => ()
  }
  if wildcard && !open_ {
    return Err(self.declaration_error(ImportWildcard))
  }
  match self.finish_declaration_line() {
    Ok(_) =>
      Ok(
        Import({
          open_,
          path,
          wildcard,
          import_alias,
          import_alias_offset,
          offset: declaration_offset,
        }),
      )
    Err(error) => Err(error)
  }
}

///|
/// Parses one newline-terminated keyword-led declaration. End of input acts as
/// an implicit final newline.
fn Parser::parse_declaration_recoverable(
  self : Parser,
) -> Result[Declaration, RecoveryFailure] {
  self.skip_newlines()
  let mut visibility = ModuleVisible
  let mut declaration_offset = match self.peek_token() {
    Some(token) => token.offset()
    None => return Err(self.declaration_error(DeclarationKeyword))
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Error(_) =>
          return Err(self.declaration_error(DeclarationKeyword))
        @tokenizer.Keyword(@tokenizer.Open) => {
          declaration_offset = token.offset()
          self.consume_lookahead()
          return self.parse_import_after_keyword(true, declaration_offset)
        }
        @tokenizer.Keyword(@tokenizer.Import) => {
          declaration_offset = token.offset()
          self.consume_lookahead()
          return self.parse_import_after_keyword(false, declaration_offset)
        }
        @tokenizer.Keyword(@tokenizer.Pub) => {
          visibility = Public
          declaration_offset = token.offset()
          self.consume_lookahead()
        }
        _ => ()
      }
    None => return Err(self.declaration_error(DeclarationKeyword))
  }
  match self.peek_token() {
    Some(token) =>
      match token.kind() {
        @tokenizer.Error(_) => Err(self.declaration_error(DeclarationKeyword))
        @tokenizer.Keyword(@tokenizer.Builtin) => {
          self.consume_lookahead()
          self.parse_builtin_after_keyword(visibility, declaration_offset)
        }
        @tokenizer.Keyword(@tokenizer.Let) => {
          self.consume_lookahead()
          self.parse_let_after_keyword(visibility, declaration_offset)
        }
        @tokenizer.Keyword(@tokenizer.Trait) => {
          self.consume_lookahead()
          self.parse_trait_after_keyword(visibility, declaration_offset)
        }
        @tokenizer.Keyword(@tokenizer.Struct) => {
          self.consume_lookahead()
          match
            self.parse_struct_after_keyword(visibility, declaration_offset) {
            Ok(value) => Ok(Struct(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Enum) => {
          self.consume_lookahead()
          match self.parse_enum_after_keyword(visibility, declaration_offset) {
            Ok(value) => Ok(Enum(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Type) => {
          self.consume_lookahead()
          match
            self.parse_type_alias_after_keyword(visibility, declaration_offset) {
            Ok(value) => Ok(TypeAlias(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Fn) => {
          self.consume_lookahead()
          match
            self.parse_function_after_keyword(visibility, declaration_offset) {
            Ok(value) => Ok(Function(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Test) => {
          if visibility == Public {
            return Err(self.declaration_error(DeclarationKeyword))
          }
          self.consume_lookahead()
          match self.parse_test_after_keyword(declaration_offset) {
            Ok(value) => Ok(Test(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Impl) => {
          if visibility == Public {
            return Err(
              declaration_failure(PublicImplNotAllowed(declaration_offset)),
            )
          }
          self.consume_lookahead()
          match self.parse_impl_after_keyword(false, declaration_offset) {
            Ok(value) => Ok(Impl(value))
            Err(error) => Err(error)
          }
        }
        @tokenizer.Keyword(@tokenizer.Foreign) => {
          if visibility == Public {
            return Err(
              declaration_failure(PublicImplNotAllowed(declaration_offset)),
            )
          }
          self.consume_lookahead()
          match self.peek_token() {
            Some(next) =>
              match next.kind() {
                @tokenizer.Keyword(@tokenizer.Impl) => self.consume_lookahead()
                _ => return Err(self.declaration_error(DeclarationKeyword))
              }
            None => return Err(self.declaration_error(DeclarationKeyword))
          }
          match self.parse_impl_after_keyword(true, declaration_offset) {
            Ok(value) => Ok(Impl(value))
            Err(error) => Err(error)
          }
        }
        _ => Err(self.declaration_error(DeclarationKeyword))
      }
    None => Err(self.declaration_error(DeclarationKeyword))
  }
}

///|
/// Parses one newline-terminated keyword-led declaration. End of input acts as
/// an implicit final newline.
pub fn Parser::parse_declaration(
  self : Parser,
) -> Result[Declaration, DeclarationError] {
  match self.parse_declaration_recoverable() {
    Ok(value) => Ok(value)
    Err(failure) => Err(failure.declaration_error())
  }
}
