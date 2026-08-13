# Forward shunting-yard expression parser

Date: 2026-07-29

## Source design

The parser follows the user-supplied PureScript `Dewdrop.Parser` and `Dewdrop.RPN` implementation. Its central property is a strict alternation between two states:

1. **Seeking a unary value**: accept literals, names, prefix operators, or a grouping opener.
2. **Seeking a binary operator**: accept infix operators, postfix calls, or a grouping closer; otherwise stop without consuming the lookahead token.

A token is consumed only after the current mode establishes its meaning. No parser branch rewinds the token stream.

## MoonBit implementation

`jtenner/dewdrop/parser` owns one token of lookahead over `Iter[Token]`. Expression parsing uses a value array containing partially built `Expr` nodes plus two parallel scalar arrays for pending operator codes and byte offsets. Prefix, binary, and group states are compact integer codes, avoiding one temporary object per pending operator.

The parser does not construct a separate postfix/RPN token sequence. Instead, reduction immediately constructs the corresponding AST node. Each operator enters and leaves the compact operator stack at most once, giving linear `O(n)` time and `O(d)` auxiliary storage, where `d` is the number of pending operators and groups.

Expression nodes are represented directly by one recursive `Expr` enum rather than a struct wrapping a second kind enum. This avoids one object layer per AST node.

## Operator insertion

When a binary operator arrives, pending operators are reduced while:

- the pending operator has greater precedence; or
- it has equal precedence and the incoming operator is left-associative.

Groups stop reduction. Prefix operators are reduced before any following binary operator, including exponentiation. Calls, field access, qualification, construction, and index access are applied directly to the current top value and therefore bind more tightly than prefix and binary operators.

Newlines are consumed in unary-value-seeking mode because the expression is incomplete. In binary/postfix-seeking mode, a top-level newline terminates the expression, while a newline inside an open grouping parenthesis is soft. Recursive call/index parsers skip newlines around their delimiters and after commas.

The supplied PureScript implementation passes `false` to every demonstrated binary operator while its equal-precedence condition makes `false` behave as right associativity. The MoonBit implementation uses explicit associativity instead:

- exponentiation is right-associative;
- relational and equality operators are non-associative and reject ungrouped chains;
- all other current binary operators are left-associative;
- `=` is not an expression operator.

## Precedence table

| Precedence | Operators | Associativity |
|---:|---|---|
| postfix | function call, field `.`, index `[]` | left/chained |
| prefix | unary `+`, unary `-`, `!` | prefix; above `**` |
| 13 | `**` | right |
| 12 | `*`, `/`, `%` | left |
| 11 | `+`, `-` | left |
| 10 | `<<`, `>>` | left |
| 9 | `<`, `<=`, `>`, `>=` | non-associative |
| 8 | `==`, `!=` | non-associative |
| 7 | `&` | left |
| 6 | `^` | left |
| 5 | `|` | left |
| 4 | `&&` | left |
| 3 | `||` | left |

## Grouping and calls

Parentheses in value-seeking mode push a group marker onto the same operator stack. A right parenthesis reduces operators through that marker. An unmatched right parenthesis in operator-seeking mode terminates the current expression and remains in lookahead for the caller.

A left parenthesis in operator-seeking mode is a function call. Call arguments invoke the same expression parser and stop at an unconsumed comma or right parenthesis. This recursion follows syntactic nesting only; operator precedence itself remains iterative.

A dot in operator-seeking mode consumes exactly one following identifier and constructs field access. `::` consumes either one property identifier as right-unary qualification or a left brace as an explicit constructor body. A bare left brace no longer attaches to a completed value. A left bracket parses one nested expression through a required right bracket. Calls, fields, qualification, explicit construction, and indexes may chain arbitrarily.

An opening brace in value-seeking mode parses an inline object. Each ordered field has an identifier, colon, and expression value. A `Newline` is mandatory after every non-empty field, including the final field before `}`; commas are not field separators. Empty `{}` is valid. If, match, and functional while are keyword-led values parsed by dedicated control-flow routines; after completion they re-enter operator-seeking mode. Value-carrying `break` and `continue` similarly parse as control-transfer expressions whose context legality is deferred to semantic analysis.

Calls accept zero arguments and one trailing comma. A second trailing comma is rejected.

## Error behavior

Lexical error tokens are consumed and converted to `ExpressionError::LexicalError`. Missing operands, unterminated groups, calls, or indexes, invalid field names, invalid delimiters, and comparison chains produce deterministic errors without trying an alternate parse.

The operator table is closed. User modules and traits cannot add spellings or precedence levels.
