///|
priv enum RecoveryFailure {
  DeclarationFailure(DeclarationError)
  ExpressionFailure(ExpressionError)
  PatternFailure(PatternError)
  InsideBrace(RecoveryFailure)
  InsideParenthesis(RecoveryFailure)
  InsideBracket(RecoveryFailure)
  InsideAngle(RecoveryFailure)
}

///|
priv struct RecoveryFence {
  mut braces : Int
  mut parentheses : Int
  mut brackets : Int
  mut angles : Int
}

///|
fn declaration_failure(error : DeclarationError) -> RecoveryFailure {
  DeclarationFailure(error)
}

///|
fn expression_failure(error : ExpressionError) -> RecoveryFailure {
  ExpressionFailure(error)
}

///|
fn pattern_failure(error : PatternError) -> RecoveryFailure {
  PatternFailure(error)
}

///|
fn RecoveryFailure::inside_brace(self : RecoveryFailure) -> RecoveryFailure {
  InsideBrace(self)
}

///|
fn RecoveryFailure::inside_parenthesis(
  self : RecoveryFailure,
) -> RecoveryFailure {
  InsideParenthesis(self)
}

///|
fn RecoveryFailure::inside_parentheses_count(
  self : RecoveryFailure,
  count : Int,
) -> RecoveryFailure {
  let mut failure = self
  let mut remaining = count
  while remaining > 0 {
    failure = InsideParenthesis(failure)
    remaining -= 1
  }
  failure
}

///|
fn RecoveryFailure::inside_bracket(self : RecoveryFailure) -> RecoveryFailure {
  InsideBracket(self)
}

///|
fn RecoveryFailure::inside_angle(self : RecoveryFailure) -> RecoveryFailure {
  InsideAngle(self)
}

///|
fn RecoveryFailure::fence(self : RecoveryFailure) -> RecoveryFence {
  let fence : RecoveryFence = {
    braces: 0,
    parentheses: 0,
    brackets: 0,
    angles: 0,
  }
  let mut current = self
  while true {
    match current {
      InsideBrace(inner) => {
        fence.braces += 1
        current = inner
      }
      InsideParenthesis(inner) => {
        fence.parentheses += 1
        current = inner
      }
      InsideBracket(inner) => {
        fence.brackets += 1
        current = inner
      }
      InsideAngle(inner) => {
        fence.angles += 1
        current = inner
      }
      _ => return fence
    }
  } nobreak {
    abort("unreachable recovery fence traversal")
  }
}

///|
fn declaration_failure_with_fence(
  error : DeclarationError,
  fence : RecoveryFence,
) -> RecoveryFailure {
  let mut failure = declaration_failure(error)
  let mut braces = fence.braces
  while braces > 0 {
    failure = InsideBrace(failure)
    braces -= 1
  }
  let mut parentheses = fence.parentheses
  while parentheses > 0 {
    failure = InsideParenthesis(failure)
    parentheses -= 1
  }
  let mut brackets = fence.brackets
  while brackets > 0 {
    failure = InsideBracket(failure)
    brackets -= 1
  }
  let mut angles = fence.angles
  while angles > 0 {
    failure = InsideAngle(failure)
    angles -= 1
  }
  failure
}

///|
fn RecoveryFailure::expression_error(self : RecoveryFailure) -> ExpressionError {
  let mut current = self
  while true {
    match current {
      InsideBrace(inner)
      | InsideParenthesis(inner)
      | InsideBracket(inner)
      | InsideAngle(inner) => current = inner
      ExpressionFailure(error) => return error
      PatternFailure(error) => return MatchPatternError(error)
      DeclarationFailure(_) =>
        abort("declaration failure escaped through expression parser")
    }
  } nobreak {
    abort("unreachable expression failure traversal")
  }
}

///|
fn RecoveryFailure::pattern_error(self : RecoveryFailure) -> PatternError {
  let mut current = self
  while true {
    match current {
      InsideBrace(inner)
      | InsideParenthesis(inner)
      | InsideBracket(inner)
      | InsideAngle(inner) => current = inner
      PatternFailure(error) => return error
      ExpressionFailure(_) =>
        abort("expression failure escaped through pattern parser")
      DeclarationFailure(_) =>
        abort("declaration failure escaped through pattern parser")
    }
  } nobreak {
    abort("unreachable pattern failure traversal")
  }
}

///|
fn RecoveryFailure::declaration_error(
  self : RecoveryFailure,
) -> DeclarationError {
  let mut current = self
  while true {
    match current {
      InsideBrace(inner)
      | InsideParenthesis(inner)
      | InsideBracket(inner)
      | InsideAngle(inner) => current = inner
      DeclarationFailure(error) => return error
      ExpressionFailure(error) => return DeclarationExpressionError(error)
      PatternFailure(error) =>
        return DeclarationExpressionError(MatchPatternError(error))
    }
  } nobreak {
    abort("unreachable declaration failure traversal")
  }
}
