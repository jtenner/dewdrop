# Dew Language Specification

> Status: early design draft. Syntax and semantics marked **Proposed** are not yet settled. Implementation priorities and deferred work are tracked in `docs/roadmap.md`.

## 1. Purpose

Dew is a statically typed programming language implemented in MoonBit. It intentionally resembles MoonBit while introducing a distinct trait, implementation, method, and sum-type model. Dew uses Starshine as its backend and targets WebAssembly GC directly.

## 2. Design priorities

1. Runtime performance.
2. Low memory usage.
3. Predictable compilation with bounded compiler work where practical.
4. Modular compiler stages.
5. Familiar MoonBit-like syntax without requiring MoonBit source compatibility.

## 3. Compiler pipeline

```text
raw file descriptor
  -> page-at-a-time byte reader
  -> streaming WTF-8 unit iterator
  -> streaming lexer
  -> Iter[Token]
  -> streaming parser
  -> Iter[ParseEvent]
  -> module-local declaration collection and type HIR
  -> body HIR, name resolution, and type checking
  -> Starshine
  -> WasmGC
```

### 3.1 Source stream

The compiler reads as directly as possible from a raw file descriptor to minimize abstraction overhead and memory use. A custom WTF-8 decoder exposes a forward-only iterator of decoded code points and tagged malformed-input sentinels.

- Input is read one host operating-system page at a time. This buffer-size choice is provisional pending measurement.
- The streaming tokenizer does not require complete source text to remain resident; consumed descriptor pages may be released once no active lexer state depends on them.
- The installed manifest compiler currently retains one immutable path/byte record per collected file for exact diagnostics after token eviction. Removing that retained copy requires a future reopen/source-provider contract rather than reconstructing source spelling from tokens.
- The WTF-8 iterator must handle multi-byte sequences split across page boundaries.
- File-descriptor input is the primary implementation path; portability abstractions are not an initial design priority.

#### 3.1.1 Implemented refillable WTF-8 decoder

The MoonBit package `jtenner/dewdrop/tokenizer` implements the allocation-conscious source decoder:

```moonbit
pub type UtfCodepoint = UInt
pub type ByteOffset = UInt64

pub fn Utf8Cursor::from_fd(
  Int,
  buffer_size? : Int,
) -> Utf8Cursor

pub fn Utf8Cursor::next(
  Utf8Cursor,
) -> (UtfCodepoint, ByteOffset)?
```

- `from_fd` allocates one mutable `Bytes` buffer and repeatedly refills that same buffer from the borrowed descriptor.
- The default buffer capacity is the host operating-system page size; tests may supply a smaller capacity of at least four bytes.
- Before refill, an incomplete sequence's remaining bytes are moved to the front of the same buffer. The next descriptor read writes directly into the free suffix.
- The cursor never closes the borrowed descriptor.
- `next` yields `(UtfCodepoint, ByteOffset)` with an absolute UTF-8 byte offset.
- `each` is the preferred hot path and invokes a two-argument callback directly, avoiding source-level tuple/option construction per unit.
- WTF-8 permits surrogate code points U+D800 through U+DFFF.
- Overlong sequences, values above U+10FFFF, malformed continuation structure, invalid leading bytes, and truncated sequences are preserved one byte at a time using tagged sentinel values.
- `0x110000..0x1100FF` preserve malformed bytes in their low eight bits. This keeps them distinct from literal U+FFFD without allocating error objects.
- `0x120000..0x12FFFF` report one terminal descriptor error, preserving the platform error code in the low sixteen bits.
- Malformed-byte sentinels are acceptable inside string literals. Other lexical contexts may convert them to `Error` tokens.

### 3.2 Lexer

The lexer is hand-written around a fast, forward-only cursor.

- It performs no backtracking.
- It streams tokens rather than materializing the complete token sequence.
- It consumes the custom WTF-8 unit iterator.
- It exposes tokens through MoonBit's `Iter` abstraction, subject to implementation validation.
- Identifier and literal token payloads contain decoded values rather than source slices.
- Decoded identifiers are stored as MoonBit `String` values.
- Identifiers may use Unicode.
- Malformed-byte sentinels produce `Error` tokens in contexts that require valid identifiers or syntax. String literal bodies may retain them as data. Lexing continues so errors can be accumulated after the complete parse.
- Tokens do not require the original source-text buffer to remain alive.

#### 3.2.1 Implemented token kinds

`Tokenizer` uses two WTF-8 unit lookahead slots and never rewinds the source cursor. Physical LF, CRLF, and CR line endings produce `Newline` tokens; CRLF produces one token at the CR byte offset. It exposes:

```moonbit
pub fn Tokenizer::next(Tokenizer) -> Token?
pub fn Tokenizer::iter(Tokenizer) -> Iter[Token]
```

Every token has the shape:

```dew
Token(TokenKind, ByteOffset, Index)
```

The initial fixed symbol set is:

```text
( ) { } [ ] ^ + - * / ** % : :: = == != , ; . ...
< <= > >= << >> -> ! & && | ||
```

`**` is exponentiation. `@identifier` and dotted intrinsic paths such as `@wasm.i64_trunc_i32` produce one `AtIdentifier(String)` token.

The keyword set is:

```text
fn test pub builtin foreign impl trait for enum struct type let mut
if else match while loop return break continue
true false as in where open import export package
```

Identifiers produce decoded MoonBit `String` values. The initial Unicode classifier is intentionally broad: ASCII names follow letter/underscore start rules, while non-ASCII Unicode scalars are accepted unless classified as whitespace. This is provisional until Q-029 defines Unicode XID and normalization behavior.

Numeric literals use fixed-width token variants and unsigned magnitude payloads because unary `-` is a separate token:

```text
1       -> I32
1i8     -> I8       1i16 -> I16       1i32 -> I32       1i64 -> I64
1u8     -> U8       1u16 -> U16       1u32 -> U32       1u64 -> U64
1U      -> U32      1L   -> I64       1UL  -> U64
1.0     -> F64
1.0F    -> F32      1.0f32 -> F32     1.0f64 -> F64
```

A floating-point spelling must contain `.`. Therefore `1e3` and `1F` are lexical errors, while `1.0e3` and `1.0F` are valid. A leading-dot form such as `.5` is valid. Decimal integer and fractional components may contain non-leading, non-trailing, non-consecutive `_` separators.

String tokens use `Bytes` payloads so WTF-8 surrogates and malformed raw bytes remain lossless:

- Double-quoted strings support `\\`, `\"`, `\n`, `\r`, `\t`, `\0`, `\b`, `\f`, and `\xHH` escapes.
- MoonBit-style multiline strings begin with `#|`. Consecutive marked lines may be indented; markers and indentation are removed and the lines are joined with `\n`.
- Malformed-byte sentinels are accepted inside both string forms.

Horizontal and other non-line whitespace is trivia. `//` consumes comment text but preserves its terminating line ending as a `Newline` token. Blank lines therefore remain visible to the parser. Block-comment syntax remains open.

The `#|` scanner may consume a line ending while determining whether another marked line continues the string. If the following line is not a continuation, the tokenizer queues that consumed line ending and emits it immediately after the multiline-string token, preserving source order without rewinding.

Source metadata uses stable file-local byte offsets and transient parser tokens. The semantic collector separately retains each file's logical path and immutable source bytes for diagnostics; it does not retain the token stream.

- `Offset` is the token's absolute UTF-8 byte offset within one source file.
- `FileId` is a stable packed module/file-local identity assigned from manifest order; it is stored separately and is never packed into `Offset`.
- `SourceLocation` pairs one `FileId` with one physical byte offset.
- `Index` is the token's index in the active `Source.tokens` array.
- A token index is valid only while that token remains in the active array. AST nodes must not retain an index after the corresponding token is evicted.

Tokens may be evicted after their declaration has been converted into AST/HIR nodes. HIR type syntax, lambda parameters, expressions, blocks, block items, object/pattern fields, patterns, and arms retain aligned `FileId` provenance, while source-local byte offsets remain in their compact nodes. Diagnostics recover exact source lines from the retained immutable file record, not from parser tokens. Byte offsets map deterministically to one-based line and byte-column values; final diagnostics sort by module order, manifest file order, byte offset, and deterministic rank.

### 3.3 Parser

The parser consumes the token iterator and returns one interleaved event iterator:

```dew
enum ParseEvent {
  Declaration(Declaration)
  Diagnostic(ParseDiagnostic)
}

fn parse(tokens: Iter[Token]) -> Iter[ParseEvent]
fn parse_bytes(bytes: Bytes) -> Iter[ParseEvent]
fn Parser::parse_events(self) -> Iter[ParseEvent]
```

These entry points are implemented. A single event stream is the default low-memory API. Returning separate lazy declaration and diagnostic iterators would require buffering whichever stream the caller consumes more slowly. The parser instead emits each declaration or diagnostic as soon as it becomes available, and the consumer decides what to retain.

The iterator emits declarations, not nested executable statements. Function bodies and other declaration internals contain their own statement structures.

Diagnostics have exactly four initial severity levels:

```dew
Error
Warning
Info
Hint
```

- The parser targets exactly one token of lookahead.
- The grammar must not admit multiple valid representations of the same token sequence.
- Every declaration begins with a reserved declaration keyword so its production can be selected deterministically.
- The parser does not retain competing parse trees or deferred alternatives.
- Syntax recovery is required. Recovery may discard tokens to reach a synchronization point.
- Where the intended syntax is obvious, recovery may synthesize missing tokens and explicit error AST nodes.
- Synthetic nodes permit partial compilation and useful language-server output from incomplete or invalid programs.
- Construct parsers track their own nested delimiters. The initial module-event recovery discards the failed physical line and subsequent non-declaration lines, then stops before a line beginning with a declaration keyword.
- This keyword-led recovery guarantees forward progress without enlarging hot expression parser state. Declaration-local recovery metadata will later refine cases where a nested member begins with a declaration keyword.
- Events preserve parser discovery order.
- The core parser does not accumulate all diagnostics or declarations merely to support separate output channels.
- Convenience adapters may route events into callbacks or collections, but those adapters own any resulting buffering.

#### 3.3.1 Module preambles and imports

Each file begins in preamble mode. The initial import grammar is:

```text
qualified-import-declaration = "import" module-path ("as" at-identifier)? line-end
open-import-declaration      = "open" import-target line-end
import-target                = module-path ("." "*")?
module-path                  = identifier ("." identifier)*
at-identifier                = "@" identifier
```

For example:

```dew
open dew.std.preamble
open dew.std.*
open app.features.*
```

The first ordinary declaration permanently closes preamble mode for that file. Any later `import` or `open` is consumed and diagnosed as `ImportAfterDeclaration`; parsing then continues. `global` is not a keyword. A qualified import names exactly one module and derives its final path segment as the default `@alias`; `as @identifier` replaces that alias. Qualified imports reject wildcards. An open import contributes an exact module or terminal wildcard family to the current module's unqualified lookup and rejects aliases.

An open wildcard considers every already-known module whose canonical dotted path is below the prefix. Expansion follows deterministic collected-program module order and never enumerates a directory. `open dew.std.*` selects all public compiler-owned standard modules; the private `dew.std.text_runtime` implementation module is excluded from direct user lookup and enters only through public text-module dependencies. A prefix with no matching module receives `MissingImportedModule(prefix.*, ...)`.

Imports and opens declared by any source file contribute to the owning Dew module's semantic import scope; they never affect another module. `import my.lib as @lib` permits qualified access such as `@lib.my_func()`, while `open my.lib` adds public names to unqualified lookup. Neither form re-exports declarations or changes their owning module/identity. Parser events retain both forms as import declarations for streaming purposes, but semantic collection stores them in a separate import arena and does not assign `DeclId`s. Collected imports retain the canonical path, open/qualified mode, wildcard flag, optional alias, `FileId`, and source offsets.

#### 3.3.2 Builtin declarations

Builtin declarations have the initial grammar:

```text
builtin-declaration = "pub"? "builtin" identifier type-parameters?
                      "(" parameters? ")" "->" type "=" quoted-string-literal
                      line-end

type-parameters     = "<" type-parameter ("," type-parameter)* ","? ">"
type-parameter      = identifier (":" type ("+" type)*)?
parameters          = parameter ("," parameter)* ","?
parameter           = identifier ":" type
type                = identifier
```

For example:

```dew
pub builtin i32_add(a: I32, b: I32) -> I32 = "i32_add"

pub builtin select<t, u>(value: t, fallback: u) -> t = "select"
```

The final standard double-quoted string is the compiler builtin registry name, and its lossless payload is retained as `Bytes`. `#|` multiline string syntax is not accepted in this declaration position. The compiler resolves the exact string against an extensible builtin registry; compiler extensions may register custom builtin implementations.

`pub` exports the declaration from its module. Without `pub`, the declaration remains visible throughout the declaring module but is not exported. Files do not create visibility boundaries: all files assigned to one module contribute to one shared type, trait, value, implementation, and callable namespace, so a default-visible function declared in one file is callable from every other file in that module. Dew has no private declaration visibility; this default is represented as `ModuleVisible`, analogous to protected module scope rather than private scope.

The AST retains ordered type parameters, typed value parameters, the declared return type, and the builtin name. Generic names and named types use the same syntactic type form and are resolved during semantic analysis. Instantiated generic information is attached to calls before the compiler replaces the builtin call with custom inline Wasm. Generic call arguments may be inferred or supplied explicitly; explicit call syntax remains open.

Return types are required, including explicit `-> Unit`. One trailing comma is accepted in type-parameter and value-parameter lists. A generic parameter may carry ordered trait bounds such as `t: Eq + Debug`. Bounds lower into flat HIR type syntax, resolve in the trait namespace, and survive private frozen-interface cache V11 serialization. Local and imported calls enforce those bounds, and generic implementation candidates recursively enforce their own prerequisites. Generic-body evidence selection and executable evidence propagation remain incomplete. Signature types may be named or recursively applied generic types such as `Result<List<I32>>`.

Dew-visible builtin names may be overloaded. Multiple declarations may also refer to the same builtin registry string without sharing one canonical signature. Overload resolution and ambiguity are semantic concerns.

A compiler-provided builtin expansion must report or carry the type of the value it produces. That result type must match the fully instantiated return type declared by the selected builtin overload. The compiler enforces this check as a type guard at the extensible builtin boundary.

The implemented entry point is:

```moonbit
pub fn Parser::parse_declaration(
  Parser,
) -> Result[Declaration, DeclarationError]
```

It parses exactly one declaration, consumes one physical terminating newline when present, and leaves the next declaration untouched. End of input acts as an implicit final newline.

#### 3.3.3 Let declarations

Let declarations have the grammar:

```text
let-declaration = "pub"? "let" "mut"? identifier "=" expression line-end
line-end        = newline | end-of-input
```

For example:

```dew
let value = expression
let mut value = expression
pub let exported = expression
```

A bare binding is immutable. `mut` marks the binding mutable. Visibility follows the declaration-wide rule: bare `let` is module-visible and `pub let` is exported. The AST retains visibility, mutability, binding name and offset, initializer expression, and declaration offset.

Semicolons are not declaration terminators. A physical newline is required between adjacent declarations, while end of input acts as an implicit final newline. Blank lines are accepted and skipped before the next declaration.

Release-mode declaration benchmarks live in `src/parser/declaration_bench_test.mbt`; current measurements are recorded in `docs/research/newline-let-object-parsing.md`.

#### 3.3.4 Types and function declarations

Declaration types have the recursive grammar:

```text
type          = identifier type-arguments?
type-arguments = "<" type ("," newline* type)* ","? newline* ">"
```

This supports nested applications such as `Result<List<I32>>`. The lexer retains `>>` as the shift operator token; while parsing types, one `ShiftRight` token contextually supplies two adjacent generic closers. Extra unmatched closers are errors. This closer state is local to type parsing and does not enlarge the hot expression parser state.

Ordinary function declarations have the grammar:

```text
function-declaration = "pub"? "fn" identifier type-parameters?
                       "(" function-parameters? ")"
                       "->" type block line-end
function-parameter   = "self"
                     | "self" ":" type
                     | identifier ":" type
block                = "{" "}"
                     | "{" newline newline* block-item* "}"
block-item           = "let" "mut"? identifier "=" expression newline
                     | identifier "=" expression newline
                     | "return" expression? newline
                     | expression newline
```

Return types are mandatory. Function bodies and control-flow branches share the `Block` and `BlockItem` AST representation. A compact empty block is valid; a non-empty block requires a newline after `{`, and every let, assignment, return, or expression item requires its own newline. Function-local lets cannot be `pub`. `Block::tail_expression` exposes a final expression item without synthesizing an AST node for implicit Unit.

A local assignment is legal only when its simple-name target resolves to the exact `let mut` binding visible at that source position, including a lambda capture sourced from such a binding. The right-hand side is evaluated once and constrained to the binding type; assignment yields `Unit`. Immutable lets, parameters, pattern bindings, module values, fields, and arbitrary expressions are not assignment targets.

A first `self` parameter turns an ordinary function into a method. `self: Type` retains an explicit receiver type; shorthand `self` relies on a containing `Self` context such as an impl and is diagnosed during semantic analysis if no such context exists. `self` is illegal in any later parameter position. A function without a first receiver is static/free depending on its declaration context.

Function and impl parser benchmarks live in `src/parser/function_impl_bench_test.mbt`; detailed measurements are recorded in `docs/research/function-impl-declaration-parsing.md`.

#### 3.3.5 Struct declarations

Struct declarations use the grammar:

```text
struct-declaration = "pub"? "struct" identifier type-parameters?
                     struct-body derive-clause? line-end
struct-body        = "{" "}"
                   | "{" newline newline* struct-field* "}"
struct-field       = identifier ":" type newline
derive-clause      = "derive" "(" identifier ("," identifier)* ","? ")"
```

```dew
pub struct Point<t> {
  x: t
  y: t
}

struct Cache<t> {
  entries: Map<String, List<t>>
}
```

A bare struct is module-visible; `pub struct` exports it. Fields do not have separate visibility modifiers. Fields are newline-delimited rather than comma-delimited, and every non-empty field requires a newline, including the final field before `}`. Blank lines and comments are accepted between fields, and compact `{}` is an empty struct.

The AST retains ordered fields, recursively parsed types, and ordered postfix derive requests. `derive(Eq)` synthesizes coherent Eq and Ne implementations whose source-ordered field comparisons short-circuit; `derive(Debug)` recursively streams source-ordered field names and concrete values; and `derive(Hash)` emits deterministic source-ordered U64 mixing plus structural `hash_eq`. Generic owner parameters referenced by field types receive the corresponding conditional trait prerequisite, source bounds are preserved, duplicate generated bounds are avoided, and phantom parameters remain unconstrained. Concrete field types are validated by ordinary generated-body method selection. Unknown and duplicate derive requests are diagnosed at the request location. Duplicate fields, unknown types, generic arity, recursive-layout legality, and visibility leakage are semantic errors. Inline object expressions use the same field-name/newline shape, allowing later contextual typing against struct declarations.

Struct benchmarks live in `src/parser/struct_declaration_bench_test.mbt`; measurements and parser details are recorded in `docs/research/struct-declaration-parsing.md`.

#### 3.3.6 Enum declarations

Enum declarations use the grammar:

```text
enum-declaration = "pub"? "enum" identifier type-parameters?
                   enum-body derive-clause? line-end
enum-body        = "{" "}"
                 | "{" newline newline* enum-variant* "}"
enum-variant     = identifier newline
                 | identifier "(" variant-types ")" newline
                 | identifier struct-variant-body newline
variant-types    = type ("," type)* ","?
struct-variant-body = "{" "}"
                    | "{" newline newline* variant-field* "}"
variant-field    = identifier ":" type newline
```

```dew
pub enum Message<t> {
  Quit
  Changed(I32, I32)
  Data {
    value: t
    headers: Map<String, String>
  }
}
```

Enums support unit, tuple-like, and struct-like variants. Variants are newline-delimited; commas are reserved for tuple payload type lists. Empty tuple payloads are rejected in favor of the unit spelling, while compact empty struct-like payloads remain a distinct accepted form. Tuple payload lists allow newlines and exactly one trailing comma.

The AST uses one tagged `EnumVariant` node per variant rather than allocating a separate payload wrapper. Struct-like variants reuse `StructField`, all payload types use the recursive applied-type parser, and ordered postfix derive requests are retained. `derive(Eq)` requires matching variants and source-ordered payload equality; `derive(Debug)` writes the selected enum/variant name and recursively formatted payloads; and `derive(Hash)` mixes the source variant ordinal followed by source-ordered payload hashes while using structural `hash_eq` for collision safety. Generic payload-referenced owner parameters receive the corresponding conditional trait prerequisites. Variants and fields do not have separate visibility modifiers.

Enum benchmarks live in `src/parser/enum_declaration_bench_test.mbt`; measurements and parser details are recorded in `docs/research/enum-declaration-parsing.md`.

#### 3.3.7 Type alias declarations

Type aliases use the grammar:

```text
type-alias = "pub"? "type" identifier type-parameters?
             "=" type line-end
```

```dew
type UserId = U64
pub type Rows<t> = Result<List<t>>
```

A bare alias is module-visible; `pub type` exports it. The target uses the shared recursive type parser. Because the declaration is incomplete after `=`, physical newlines are soft before the target type, and newlines remain supported inside type-argument lists.

The parser retains the alias name, visibility, generic parameters, target type, and offsets. Alias transparency, recursive cycles, expansion limits, unknown types, and generic arity are semantic checks.

Type-alias and module-stream benchmarks live in `src/parser/type_alias_module_bench_test.mbt`; details are recorded in `docs/research/type-alias-module-streaming.md`.

### 3.4 Expression parsing

Expressions are parsed using a forward-only shunting-yard state machine. It alternates between:

1. **seeking a unary value**, where literals, names, prefix operators, and grouping openers are valid;
2. **seeking a binary operator**, where infix operators, postfix calls/accesses, right-unary qualification, and grouping closers are valid.

The parser consumes a token only after the current mode determines its role. A token that does not continue the current expression remains in the parser's single lookahead slot. No expression branch backtracks.

Newlines are soft while the parser is seeking a unary value, because the expression is syntactically incomplete. This includes continuation after prefix and binary operators. A newline after a complete top-level value terminates the expression and remains for the enclosing declaration parser. Newlines are also soft inside an open grouping parenthesis and around call/index delimiters. Newlines may follow commas, including a single trailing comma.

The scan maintains one array of partially built expression values and two parallel scalar arrays containing pending operator codes and offsets. Reducing an operator immediately constructs its AST node; no separate postfix token stream is materialized. Every operator is pushed and popped at most once, so expression parsing is linear in the number of tokens. The scalar operator representation avoids allocating temporary pending-operator objects.

The initial precedence table is:

| Precedence | Operators | Associativity |
|---:|---|---|
| postfix/right-unary | function call, field `.`, qualification `::`, construction `{}`, index `[]` | chained |
| prefix | unary `+`, unary `-`, `!` | prefix; binds above `**` |
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

Parentheses in value-seeking mode group expressions. In operator-seeking mode, `(` begins a function call, `.` requires a following field identifier, `::` acts as a right-unary qualification operator that consumes one following property identifier, and `[` parses one index expression through a required `]`. After consuming the qualified property, the parser remains in operator-seeking mode, so qualification chains directly with calls and other accesses:

```dew
Type::method(value).field[index]
Namespace::Type::constructor(...)
```

`::` wraps the current top value as `QualifiedExpr(target, property, separator_offset)` without entering the shunting-yard operator stack or reducing pending infix operators. It therefore has postfix precedence while retaining the requested right-hand property operand. A newline after `::` is soft because the qualification is incomplete. Call arguments recursively invoke the same expression parser, but precedence handling itself is iterative. Calls accept zero arguments and one trailing comma; a second trailing comma is an error.

In binary-seeking mode, `{` attaches a construction body to the current value:

```dew
Point {
  x: 10
  y: 20
}

Message::Data {
  value: payload
}
```

The result is `ConstructExpr(target, fields, opening_offset)` and remains in binary-seeking mode. Construction shares its field-body parser with untyped object expressions. A physical newline after a complete target terminates before `{`; construction therefore begins on the target's current expression line. Semantic analysis verifies that the target denotes an appropriate struct or struct-like enum constructor.

`{` in value-seeking mode begins an inline object expression:

```text
object       = "{" newline* (object-field newline+)* "}"
object-field = identifier ":" expression
```

```dew
let obj = {
  a: "b"
  c: 39
  d: {}
}
```

Every non-empty object field requires a terminating newline, including the final field before `}`. Commas are not field separators. Blank lines may occur between fields, and `{}` is an empty object. Object fields retain source order; duplicate-name validation and object type inference occur during semantic analysis.

Control-flow conditions use an internal expression context that stops before an ungrouped `{` in binary-seeking mode, leaving the brace in lookahead for the block parser. The stop flag is call-local and does not enlarge `Parser`. Parenthesized conditions retain ordinary construction behavior because the stop rule applies only at grouping depth zero.

Reusable blocks and if expressions use:

```text
block         = "{" "}"
              | "{" newline newline* block-item* "}"
block-item    = "let" "mut"? identifier "=" expression newline
              | identifier "=" expression newline
              | "return" expression? newline
              | expression newline
if-expression = "if" expression-before-block block
                ("else" (block | if-expression))?
```

```dew
if ready {
  run()
}

if ready {
  first
} else if fallback_ready {
  fallback
} else {
  final_value
}
```

`IfExpr` retains the condition, then block, optional else expression, and offset. A block else is wrapped as `BlockExpr`; `else if` is a nested `IfExpr`. The complete if remains in binary-seeking mode and may be followed by calls, fields, indexes, qualification, construction, or infix operators.

Because `else` is optional and the parser has one token of lookahead, `else` must occur on the same physical line as the preceding `}`. A newline after `}` terminates the no-else if and remains available to the enclosing block or declaration parser. Bare `{ ... }` in unary-value-seeking mode remains an object expression; `BlockExpr` is used only in syntactically known block positions, avoiding object/block ambiguity.

Typing applies these rules after parsing:

- An if used as a value must have an else branch.
- Value-producing branch result types must unify.
- An if without else has type `Unit`.
- If a no-else branch does not explicitly end in a Unit-producing expression, Unit is implied after it and any prior value is discarded.
- An if-with-else used only for effect may likewise discard branch values and produce Unit.
- A value-producing else-if chain must end with a final else.

Implicit Unit is a semantic/lowering rule and does not require an allocated `UnitExpr` node.

Pattern-test expressions use:

```text
is-expression = expression "is" pattern
```

```dew
let present = get_it(42) is Option::Some(_)

if get_it(42) is Option::Some(value) {
  use(value)
}

if get_it(42) is Option::Some(value) && value > 0 {
  use(value)
}
```

An `is` expression evaluates its left operand exactly once, tests it against the pattern, and produces `Bool`. It has comparison-level precedence: arithmetic and postfix operations bind inside its scrutinee, while logical conjunction and disjunction bind outside it. As with other comparison operators, an ungrouped comparison may not be chained into the scrutinee.

An `is` expression used directly as an if condition is lowered as a two-arm match. Bindings from the pattern are immutable and available only in the successful then block. When the direct condition is followed by `&&`, those bindings are also in scope in the conjunction's right-hand guard. They do not escape the successful branch and are not introduced by a standalone Boolean use such as `let present = value is Option::Some(_)`. A failed pattern selects the else branch, or implicit Unit when no else is present.

The parser retains `IsExpr` long enough to establish this conditional binding scope. Standalone uses are deterministically desugared to an ordered match returning `true` or `false`, so executable lowering shares match semantics and introduces no second scrutinee evaluation. As with constructor-valued if conditions, a struct pattern in an if condition must be parenthesized so its `{ ... }` cannot be mistaken for the if body: `if (value is Point { x ... }) { ... }`.

Match expressions use a separate pattern parser:

```text
match-expression = "match" expression-before-block match-body
match-body       = "{" "}"
                 | "{" newline newline* match-arm* "}"
match-arm        = arm-patterns match-guard? "=>"
                   (expression | block) newline
arm-patterns     = pattern ("," newline* pattern)*
match-guard      = "if" expression

pattern          = "_"
                 | identifier
                 | literal
                 | pattern "::" identifier
                 | pattern "(" tuple-pattern-list ")"
                 | pattern struct-pattern-body

tuple-pattern-list = tuple-pattern-item
                     ("," newline* tuple-pattern-item)* ","?
tuple-pattern-item = pattern | "..."
struct-pattern-body = "{}"
                    | "{" newline struct-pattern-member* "}"
struct-pattern-member = identifier (":" pattern)? newline
                      | "..." newline
```

```dew
match option {
  Option::None, Result::Err(_) => fallback
  Option::Some(value) if value > 0 => value
  List::Cons(head, ...), Vector::Items(head, ...) if ready => head
  Message::Data {
    item
    ...
  } => {
    process(item)
  }
}
```

`=>` is a dedicated `FatArrow` token. Patterns are not parsed as expressions: `Parser::parse_pattern` accepts wildcard, binding, literal, qualified, tuple-like, and struct-like forms through a separate forward-only grammar. Tuple pattern lists permit newlines and one trailing comma; struct pattern fields are newline-delimited and support shorthand bindings or `field: subpattern` renaming. Empty tuple patterns are rejected in favor of unit patterns.

A match arm may list multiple alternative patterns separated by commas. A comma makes the arm incomplete, so newlines are soft before the next pattern; a trailing arm-alternative comma is rejected. The AST uses `AlternativePattern(first, remaining, offset)` only when a comma occurs, leaving the common single-pattern arm allocation-free. Semantic analysis must require every alternative in one arm to bind the same names and must unify the corresponding binding types before the shared guard and body are checked.

An optional `if` guard follows the complete alternative list and precedes `=>`. The guard is evaluated with the selected pattern's bindings in scope, must have type `Bool`, and a false guard continues matching at the next arm. These constraints are semantic; parsing retains the optional guard expression as `PatternArm.guard_condition`.

Bare `...` is a rest pattern only inside tuple-like or struct-like payloads. A tuple payload permits at most one rest item; patterns before it match from the front and patterns after it match from the back. A struct payload permits at most one newline-delimited `...` member, allowing unlisted fields to be ignored. Without struct rest, semantic validation requires the complete field set. Standalone rest patterns, named-field values such as `field: ...`, and duplicate rest items are rejected syntactically.

Pattern bindings are always immutable. `mut` is not part of pattern grammar and is rejected wherever a pattern is expected. Any identifier used in a pattern-binding position whose spelling begins with `_` is a discard and produces `WildcardPattern(offset)` rather than a named binding. This includes `_`, `_value`, and names such as `__temporary`; the spelling is not retained in the binding environment. An arm may explicitly create a mutable shadow binding in its body:

```dew
match option {
  Option::Some(value) => {
    let mut value = value
    update(value)
  }
}
```

The initializer resolves to the immutable pattern binding before the new mutable binding enters scope. This keeps mutation explicit and avoids carrying binding mutability through alternative-pattern compatibility checks.

`MatchExpr` retains the scrutinee and ordered `PatternArm` values. Arm bodies may be ordinary expressions or reusable blocks. Because an arm is incomplete after `=>`, newlines are soft before its body. A direct `{` after `=>` is a block; a directly returned object is parenthesized as `=> ({ ... })`. Match bodies and arms are newline-delimited, blank lines and comments are accepted, and the completed match remains in binary-seeking mode.

Match scrutinees use the same call-local left-brace stop set as if conditions. The former boolean stop parameter is now a compact integer bit set, leaving persistent `Parser` size unchanged and permitting future contextual terminators. Parentheses permit constructor scrutinees such as `match (Point {}) { ... }`.

Dew's initial `while` is a functional pattern loop rather than a conventional mutable-condition loop:

```text
while-expression = "while" expression-before-block pattern-arm-body
pattern-arm-body = "{" "}"
                 | "{" newline newline* pattern-arm* "}"
pattern-arm      = arm-patterns match-guard? "=>"
                   (expression | block) newline
control-transfer = "continue" expression
                 | "break" expression
```

```dew
let value = while initial {
  State::Next(next) if next.is_valid() => {
    continue next
  }
  State::Done(result) => break result
  _ => break 0
}
```

The initial state expression is evaluated once. Each iteration matches the current state against ordered `PatternArm` values using the same alternatives, guards, rest patterns, and discard bindings as `match`. `continue expression` computes the next state and restarts the nearest enclosing functional while; `break expression` exits that loop and becomes the value of `WhileExpr`. Both control keywords require an operand beginning on the same physical line, though that operand may continue across later soft newlines while syntactically incomplete.

Semantic analysis must unify the initial-state type, every continue-value type, and each arm pattern's expected type. It separately unifies all break-value types as the loop result. Every reachable arm-body path must transfer with `continue`, `break`, `return`, or another diverging expression; ordinary fallthrough is invalid. Pattern coverage must be exhaustive, with guarded arms contributing only conditional coverage. The parser retains empty bodies and out-of-loop control expressions for later diagnostics rather than storing loop depth in `Parser`.

Executable lowering assigns each `ControlId` carrier-typed state and result locals when its shapes consume Wasm values. The initial state is evaluated once, ordered pattern arms test the current state inside a structured Wasm `loop`, `continue` stores the next state and branches to the loop header, and `break` stores the result and exits the surrounding block. Unit and `Never` shapes consume no locals. Nested blocks, matches, loops, guards, returns, and divergence preserve the nearest resolved control target through deterministic branch relocation during final instruction assembly.

An ungrouped `{` terminates the initial state expression. A constructor initial state therefore requires grouping, as in `while (State {}) { ... }`. A completed `WhileExpr` returns to binary-seeking mode and may participate in postfix or infix continuation. The separate `loop` keyword remains reserved but is not part of this initial functional-loop form.

Else-if parsing is iterative for actual chains: the common no-else and direct-else cases avoid temporary chain arrays, while `else if` chains collect arms and fold backward into nested `IfExpr` nodes. A 1,024-arm stress test verifies bounded host stack use.

Relational and equality operators are non-associative, so chains such as `a < b < c` and `a == b != c` are rejected. Explicit grouping may separate comparisons.

`=` is not an expression operator. Binding uses `let`/`let mut`; mutation uses the dedicated newline-delimited block item `identifier = expression`. The assignment target must resolve to the exact mutable let binding or a capture sourced from it, and the block item yields `Unit`.

The prefix operators bind more tightly than exponentiation, so `-2 ** 2` means `(-2) ** 2`.

Expression AST nodes use one recursive enum allocation per node. The operator table is closed: modules and traits cannot introduce operator spellings or precedence.

Release-mode microbenchmarks live in `src/parser/expression_bench_test.mbt`, `src/parser/constructor_if_bench_test.mbt`, `src/parser/match_pattern_bench_test.mbt`, and `src/parser/functional_while_bench_test.mbt`; measurement notes are recorded in `docs/research/expression-parser-performance.md`, `docs/research/constructor-block-if-parsing.md`, `docs/research/match-pattern-parsing.md`, and `docs/research/functional-pattern-loops.md`.

### 3.4 Semantic declaration collection

The `jtenner/dewdrop/semantic` package consumes `Iter[ParseEvent]` directly. Collection assigns stable packed semantic identities with a deterministic 32-bit module component and a 32-bit module-local source-order component. Top-level declarations and nested trait/impl methods share one declaration sequence; fields, variants, generic parameters, and value parameters use independent kind-specific sequences.

Every module owns its own name interner and separate type, trait, and value namespaces. Module collection performs no global allocation and is designed as one independent future worker job. Builtin declarations with one Dew-visible name form a source-ordered overload chain; other repeated module bindings currently produce duplicate diagnostics while retaining identities for continued analysis.

Declaration-level `TypeExpr` trees lower immediately into child-first flat HIR nodes and shared argument spans. Lowering is iterative and uses reusable builder-local scratch arrays. Callable signatures, field types, tuple variant payloads, alias targets, and impl trait/target types retain HIR IDs rather than recursive parser type trees.

Module-level let initializers, top-level function blocks, and impl method blocks lower during the same collection pass into module-wide expression, block, pattern, object-field, and pattern-arm arenas. Parallel provenance arrays retain the exact `FileId` for every diagnostic-relevant HIR record without widening hot expression/pattern enum payloads. Every executable body receives a stable packed `BodyId`, records exact node spans for future body-local side tables, and is reachable from its owning declaration in constant time. Builtins and trait method signatures have no executable body.

Body lowering is child-first and iterative. A reusable primitive task machine schedules expression, block, pattern, and arm visit/finish operations without recursive MoonBit calls or one retained child array per syntax node. Calls, tuple patterns, alternatives, and match/while arm lists use shared child arenas; blocks, objects, and struct patterns use contiguous record spans. Missing optional HIR values use `-1` sentinels in hot records.

The collected module artifact is frozen by convention after construction. Recursive parser declarations and executable AST bodies become unreachable immediately after their HIR is emitted. Design details and cross-backend benchmarks are recorded in `docs/research/semantic-declaration-collection.md` and `docs/research/executable-body-hir.md`.

### 3.5 Declaration type resolution

`resolve_module_types` converts declaration-level type HIR into a canonical module-local `ResolvedType` arena. The resolved primitive set covers `Unit`, `Bool`, the complete fixed-width scalar set (`I8`, `I16`, `I32`, `I64`, `U8`, `U16`, `U32`, `U64`, `F32`, `F64`), `String`, `Bytes`, `StringView`, `StringBuilder`, `BytesBuilder`, `V128`, `Swar32`, `Swar64`, and the packed lane types; these names and `Self` are reserved from user type declarations.

Ordinary type lookup checks immediate generic parameters, containing trait/impl generics for methods, contextual `Self`, primitives, the module type namespace, and finally the trait namespace. Type declarations outrank traits with the same spelling in an ordinary type position. Impl trait positions search the trait namespace exclusively and distinguish a known non-trait from an unknown trait.

Resolved types distinguish primitives, stable generic-parameter identities, nominal constructors, trait constructors, contextual `Self`, applications, and one shared error sentinel. Structural hash-consing assigns equal types one `ResolvedTypeId`; applied arguments use flat spans. Generic arity is checked before an application is interned, and invalid signature types become `ErrorType` so later phases can continue without cascaded diagnostics.

Signature output arrays align with collected parameters, callables, fields, variants, aliases, and impls. Alias targets additionally produce a deduplicated dependency graph. Iterative Kosaraju analysis reports multi-alias and self cycles without recursive host calls; a 1,024-alias cycle is covered by tests.

After cycle analysis, zero-argument and generic aliases normalize transparently in callable, field, tuple-variant, and impl signatures. Substitution uses stable `GenericParameterId` identities, normalized alias applications are memoized by canonical type ID, and cyclic or transitively cyclic applications become `ErrorType`. A deterministic expansion budget defaults to `max(4096, initial resolved type count * 64)` and emits at most one `AliasExpansionLimit` diagnostic per affected alias declaration.

Alias declaration constructors, source `syntax_types`, and `alias_target_types` retain alias identity: alias targets are the unexpanded generic recipes required for future instantiation. Normalization starts from non-alias semantic signature roots rather than eagerly expanding every open generic alias target, avoiding quadratic work. A 1,024-alias acyclic chain normalizes iteratively. Full details and benchmarks are recorded in `docs/research/declaration-type-resolution.md` and `docs/research/transparent-alias-normalization.md`.

### 3.6 Body-local name and control resolution

`resolve_module_names` resolves every executable body independently and merges job results in stable `BodyId` order. `LocalId` and `ControlId` are body-local integers; parameters are allocated first, sequential lets enter scope only after their initializer resolves, and each pattern arm owns an isolated lexical scope. Same-scope lets may explicitly shadow an earlier parameter, pattern binding, or let, producing a new local identity.

Expression references distinguish locals, module value names, module type and trait roots, deferred enum-variant names, intrinsics, and error references. Module values retain `NameId` so later overload resolution can inspect the complete source-ordered builtin candidate chain. Qualified members, methods, fields, and final enum variants remain deferred until expected-type and member selection.

Pattern constructor context distinguishes a binding from the base of tuple, struct, or qualified patterns. Known bare unit variants are also retained as constructor candidates. The first pattern alternative defines the arm's binding-name contract; corresponding occurrences in later alternatives receive the same `LocalId`. Duplicate, missing, and extra names are diagnosed, while corresponding binding-type compatibility remains a type-inference check.

Each functional `while` receives one `ControlId`. Its initial state resolves outside that control; arm guards and bodies resolve with it active. `break` and `continue` select the nearest active control, while out-of-loop transfers remain represented with diagnostics. Traversal uses iterative task arrays, and 1,024 sequential locals, wide alternatives, nested controls, and reversed body-job order are covered by tests. Full details and benchmarks are recorded in `docs/research/body-name-resolution.md`.

### 3.7 Body-local type terms and unification

`LocalTypeSolver` provides the body-local inference foundation. Rigid module types remain in frozen `ResolvedModuleTypes`, while temporary `TypeVariableId` values and local applied terms belong to exactly one body or module-let SCC job. `BodyTypeId` compactly distinguishes the shared local error term, encoded rigid resolved references, variable terms, and applied terms with flat argument spans.

Inference variables use union by size and path compression outside speculation. Structural unification is iterative and handles variable, rigid resolved, local applied, and mixed resolved/local application pairs. Nominal constructors remain rigid. Before binding a variable to a structured term, an iterative generation-marked occurs check rejects infinite types such as `alpha = List<alpha>`.

A concrete mismatch emits one origin-bearing `LocalTypeMismatch` and poisons the affected variable class with the shared body error type. Later equalities involving that poison succeed without repeating the root diagnostic. Constraint origins distinguish expression, pattern, local, return, call, operator, and synthetic requirements.

Rollback snapshots log parent, size, and binding mutations and retain allocation and diagnostic lengths. Candidate trials may commit or restore nested snapshots in LIFO order without copying the complete solver. Final iterative zonking follows representatives, substitutes bound variables through applications, propagates poison, and permits unresolved-variable detection. Full details and benchmarks are recorded in `docs/research/body-local-unification.md`.

### 3.8 Basic HIR-driven type inference

`infer_module_bodies` consumes collected HIR, normalized declaration signatures, and resolved body names. It publishes HIR-aligned expression, local, block, and reserved pattern type tables plus compact body-local type terms and deterministic diagnostics. Body jobs remain independent and merge in stable `BodyId` order.

Parameters and receivers use their normalized declared types. Literals have fixed lexical primitive types. A local-name expression reuses the exact `BodyTypeId` of its resolved `LocalId`, and a let local unifies with its initializer after name resolution has enforced initializer-before-binding visibility. Local lets are monomorphic.

The final expression item is a block's value; earlier expression values may be discarded. Empty blocks and blocks ending in let have type `Unit`, while blocks ending in return have type `Never`. Valued returns are checked against the declared callable return type, and bare return checks `Unit`. An actual `Never` expression is assignable to any expected value type without ordinary equality.

`if` conditions check against `Bool`. With `else`, every non-diverging branch constrains one shared result type; without `else`, the expression has type `Unit` and the then-block value is discarded. Logical operators constrain `Bool`. Other binary operators map to homogeneous standard traits such as `Add`, `Sub`, `Lt`, and `Lte`; inference unifies both operand types, selects the exact implementation method through the impl index, and freezes that evidence for lowering. Unary `+` and `-` constrain the result to the operand type and lower without trait selection (`+` emits nothing, `-` emits the native `*_neg` instruction), and prefix `!` constrains both the operand and the result to `Bool`.

Basic inference initially defers members, qualification, constructors, objects, indexing, matches, and functional loops. Subsequent immutable inference phases now resolve every listed form, including indexing and indexed setting through the ambient `IndexedGet<key, value>` and `IndexedSet<key, value>` traits; failed boundaries poison their outer expression and coalesce dependent diagnostics. Final zonking detects unresolved supported expressions and locals. Reachability compaction discards solver-only variables and applications before body fragments merge. A worker-local solver is reset and reused across sequential jobs, preserving capacity without sharing mutable state between workers. Full details, optimization history, and benchmarks are recorded in `docs/research/basic-body-type-inference.md`.

### 3.9 Direct, generic, and overloaded calls

A call whose target is a module value name reads the frozen source-ordered value binding. One callable declaration selects directly. Function types are structurally resolved. Unambiguous non-generic local/imported functions may be selected as values. Non-generic overload sets are deferred until argument, return, assignment, or other constraints provide a fully determined structural function type; exact signature matching must leave one candidate. Calls through function-typed locals/module values are checked against their structural parameter and result types. Direct named calls retain the direct Wasm signature. First-class function values use the closure ABI below, with structurally coalesced direct and environment-first entry signatures across program links. Field and qualified call targets defer to the later implementation/member phase described in Section 3.14.

A lambda uses `fn(parameter: Type, ...) -> Result { ... }`. Parameters and result types are initially mandatory, and the body uses the ordinary newline-delimited block grammar. In expression value-seeking mode, `fn` commits directly to lambda parsing; the parser does not rewind or speculate, and the completed block enters ordinary postfix/binary continuation mode. Collection lowers lambda headers immediately and nested blocks into isolated source-ordered HIR fragments with parent/root-body identities.

Lexical resolution freezes the active binding stack at each lambda expression. Lambda parameters, locals, controls, captures, and diagnostics occupy separate deterministic spans. Direct captures follow first-use order and retain exact source-local identity and mutability. A free variable referenced only by a nested lambda is also routed through each intermediate lambda, after that lambda's direct captures, so descendant closure construction has a deterministic environment path. Lambda parameter/results resolve in the root declaration's generic/type scope and intern as canonical structural function types.

Isolated lambda bodies are inferred after root bodies and earlier parent lambdas. Capture types are imported from the exact source body/lambda job into a fresh solver, including canonical applied generic shapes. Lambda expressions have their structural function type; calls through lambda-valued locals use ordinary function-value call selection. Expression, local, capture, block, pattern, control, call-target, and diagnostic tables remain HIR-aligned when merged. Lambda bodies then receive the ordinary structured-flow and exhaustiveness analysis in isolated jobs; expression/block/arm outcomes merge globally while diagnostics retain lambda ownership.

Lowering records lambda construction as `PlannedLambdaClosure`, captured reads as `PlannedCaptureGet`, and mutation as explicit `PlannedLocalSet`/`PlannedCaptureSet` operations. Each planned lambda freezes its root type/shape, flow, local/capture spans, and isolated body ranges. Planned capture records retain exact lexical source identity, mutability, inferred type, and storage shape.

WasmGC planning emits one open closure base for modules that produce, accept, return, or call first-class function values. The base contains one immutable nullable abstract function reference. Every lambda receives a deterministic final subtype containing the inherited entry prefix followed by capture fields. Scalar/SIMD captures use compact storage, references use GC-safe `eqref` with exact casts restored at use sites, and Unit/Never consume no field. Modules without first-class function use add no closure types.

Lambda construction allocates one flattened closure subtype, and generated environment-first entry functions receive `(closure, source parameters...)`. Named non-capturing references instantiate the one-field base with their original `ref.func`. Invocation evaluates the target once, tests whether the entry has the direct source signature, then uses typed `call_ref` with either source arguments or the closure object plus source arguments. Declarative element segments authorize named and lambda entries. Returned, nested, immediate, passed, module-level, and imported closures execute in Node.

A bounded generic named reference retains its frozen obligation evidence. If it occurs inside a generic specialization, link planning resolves the exact target specialization and records the caller specialization plus any source-ordered caller-local runtime dictionary parameters. The runtime value is a final subtype of the same closure base. Its inherited field contains a private environment-first trampoline and its remaining immutable `eqref` fields contain captured dictionaries. The trampoline loads visible callback arguments first, then the captured evidence, and directly calls the exact local or imported target specialization. Closed generic callers use a zero-capture trampoline to preserve evidence identity even when another specialization has the same Wasm carrier. Public erased callback factories therefore return ordinary structural closure values whose dictionaries remain valid after the factory returns.

Uncaptured mutable lets remain ordinary carrier-typed Wasm locals. If any lambda captures a mutable let, WasmGC planning emits one shared final cell at the binding execution, using a mutable `i32`, `i64`, `f32`, `f64`, `v128`, or `eqref` field. Closure fields and directized lifted parameters carry the cell reference rather than a copied value. Reads and writes in the declaring body and every direct/transitive capture dereference that same cell, preserving sibling and returned-closure aliasing without reintroducing a split closure environment.

Each selected declaration generic receives one fresh body-local variable at each call site. Signature substitution is iterative through canonical applied types, caches repeated subgraphs within one candidate, and never inserts local variables into `ResolvedModuleTypes`. Arguments constrain instantiated parameters, while the call expression constrains the instantiated return type. Selected calls retain their exact `DeclId` and zonked generic arguments in HIR-aligned `call_targets` plus flat `call_type_arguments`.

Builtin overload trials use `LocalTypeSolver` snapshots. Candidate arity, arguments, and expected return are checked speculatively, then every mutation, allocation, and diagnostic is rolled back. A unique winner is instantiated again and committed. Losing candidates cannot leak constraints or mismatch diagnostics.

Candidates are provisionally ordered by ascending declared generic-parameter count. A viable concrete tier therefore outranks generic fallbacks, and a less-specific tier is considered only if every more-specific tier has no viable candidate. Equally ranked viable candidates are ambiguous. Full structural match-set containment between generic candidates remains required by the broader coherence design but is not yet implemented.

Nested overloaded calls use an iterative retry worklist. Direct parent calls first propagate parameter expectations inward; overloaded calls commit unique candidates, and deferred parents retry whenever another call made progress. No-match, ambiguity, invalid target, direct arity mismatch, and unresolved generic arguments have dedicated diagnostics. Poisoned child arguments suppress dependent overload cascades. Full details and benchmarks are recorded in `docs/research/direct-generic-overload-call-inference.md`.

### 3.10 Module-value dependency SCC inference

`analyze_module_value_dependencies` scans resolved module-let body references, maps module value names back to stable let declarations, deduplicates edges with generation marks, and publishes flat dependency spans. Iterative Kosaraju traversal builds SCCs without recursive graph traversal. Components are scheduled dependency-first, and members within one SCC remain in source order.

`infer_module_values` allocates one shared inference slot per member and one solver per active SCC. Forward references consume already frozen dependency types. Members of one recursive SCC constrain the same slot graph, so cycles are legal when another constraint determines every type. An unconstrained recursive class emits `UnresolvedModuleValue` for every affected declaration before the shared class is poisoned.

The frozen `InferredModuleValues` artifact retains source-aligned declaration types, compact local applied terms, dependency and SCC metadata, and deterministic diagnostics. Module lets may use direct calls, fresh generic instantiation, and builtin overload selection. They remain monomorphic.

Function and impl-method jobs begin only after the module-value barrier. Primitive and other rigid values import directly; positive local applications are rebuilt iteratively in each independent body solver with generation-cached source terms. Module-let body job outputs produced during SCC inference are retained and merged rather than inferred again. `InferredModuleBodies` embeds the complete frozen module-value artifact, and forward or reverse function-job schedules remain identical. Full details and benchmarks are recorded in `docs/research/module-value-scc-inference.md`.

### 3.11 Pattern, match, and functional-loop inference

Every match arm pattern receives the scrutinee type as an expected type, and every functional-loop arm pattern receives the loop state type. Iterative pattern tasks propagate expectations through wildcard, binding, literal, qualified, tuple, struct, rest, and alternative patterns. Corresponding alternative occurrences already share one `LocalId`, so payload constraints enforce compatible binding types directly.

Bare variants select from the expected enum when it is known; otherwise one globally unique module variant may determine the enum. Ambiguous or missing candidates are diagnostic. Qualified variants select only from their explicit enum. Unit, tuple, and struct payload kinds are checked, tuple rest maps prefix and suffix patterns, and struct rest permits omitted fields. Generic enum and struct payload types are instantiated from expected nominal arguments or fresh variables. Selected `VariantId` or struct `DeclId` values and zonked generic arguments are retained in frozen pattern-constructor side tables.

Match guards check against `Bool`. Non-diverging arm bodies constrain one shared match result; all-diverging matches produce `Never`. Selected constructors, wildcard status, guard expressions, and expected nominal types become frozen inputs for the subsequent flow and coverage phase.

Every functional loop owns separate state and result types. Its initial expression and every `continue` value constrain the state type; each arm pattern receives that state; every `break` value constrains the result type; and the while expression reuses the result type. A control with no break receives result type `Never`. Full details and benchmarks are recorded in `docs/research/pattern-match-functional-loop-inference.md`.

### 3.12 Structured flow and constructor coverage

`analyze_module_flows` reads frozen HIR, resolved types, and inferred bodies. Every expression, block, pattern arm, and body receives a compact summary of possible ordinary fallthrough, return, break, continue, and divergence outcomes. Sequential composition preserves early exits; branch alternatives union outcomes; logical `&&` and `||` retain both evaluated-right and skipped-right paths; and ordinary expressions inferred as `Never` contribute divergence.

Blocks diagnose every item after flow can no longer fall through. Functional loops consume their own break and continue outcomes, propagate returns and divergence, and diagnose arm summaries that retain ordinary fallthrough. Loop fallthrough diagnostics belong to flow analysis rather than type inference.

Coverage domains are finite `Bool`, finite source-ordered enum variants, open domains requiring a catch-all, or error domains that suppress dependent diagnostics. Guarded arms contribute no unconditional coverage. Wildcards and bindings are irrefutable; enum constructors cover one variant only when their complete payload pattern is irrefutable. Whole-pattern and constructor-payload irrefutability remain separate so nested enum patterns do not overclaim coverage.

Non-exhaustive matches and functional loops retain stable missing Boolean or `VariantId` witnesses. Arms that add no case beyond prior unconditional coverage are redundant. Redundancy remains conservative for refutable nested payloads until a full pattern-matrix usefulness phase. Body jobs use immutable inputs and merge in stable `BodyId` order; forward and reverse schedules compare equal. Full details and benchmarks are recorded in `docs/research/structured-flow-exhaustiveness.md`.

### 3.13 Objects, constructors, enum values, and fields

Explicit `Struct { ... }` construction selects a nominal struct declaration. `Enum::Variant { ... }` selects a struct-like enum variant, while qualified or bare calls select tuple variants and qualified or bare names select unit variants. Bare enum constructors prefer the expected enum and otherwise require one globally unique module variant spelling. The result of every enum constructor is the enclosing enum instance.

An untyped `{ ... }` object expression requires an expected nominal struct type. Expected types may flow from returns, selected call parameters, enclosing fields, module-value slots, branches, or ordinary equality constraints. Nested expected objects and chained fields are solved by an iterative member worklist: fields enter child-first, objects enter reverse child-first, and deferred dependencies retry only when earlier work made progress.

Constructor generics reuse expected nominal arguments when present and otherwise receive fresh variables. Field and tuple-payload signatures are instantiated iteratively under those arguments. Every selected struct, variant, unit value, and field retains its exact stable semantic ID; constructor generic arguments and object-field `FieldId` targets are frozen in HIR-aligned side tables.

Construction validates payload kind, tuple arity, unknown fields, duplicate fields, missing fields, and field value types. Field access requires a nominal struct base and substitutes its generic arguments into the selected field type. Per-declaration field spans prevent whole-module field scans. Object arguments participate in overload speculation through a no-diagnostic nominal-shape check, allowing nominal candidates to outrank incompatible primitive candidates without dependent call cascades.

Bodies without member syntax use shared empty member arrays, and selection storage is allocated lazily during the existing expression initialization pass. Member inference remains body-job-local and forward/reverse body schedules compare equal. Method and static qualification are specified below. Full object/field details and benchmarks are recorded in `docs/research/object-constructor-field-inference.md`.

#### 3.13.1 Indexing and indexed setting

`container[key]` selects the ambient `IndexedGet<key, value>` trait and produces `value`. `container[key] = value` selects `IndexedSet<key, value>` but is a block item rather than an expression: it cannot be nested, returned, passed as an argument, or used as a tail value. The parser first completes the left expression, observes `=` with its sole token lookahead, requires the outer node to be an index, and then parses the value without adding `=` to the expression precedence table. Receiver, key, and value execute once in that order.

`dew.std.fixed_array` defines compiler-known generic `FixedArray<t>` over six unboxed WasmGC carrier arrays (`i32`, `i64`, `f32`, `f64`, `v128`, and nullable `eqref`). `get(U32)` returns `Option<t>` without trapping. Index get/set, `set`, `get_unchecked`, and `set_unchecked` trap on out-of-bounds indices. The unchecked spelling omits Dew's optional-result branch; the WasmGC array instruction still traps rather than granting arbitrary memory access.

`dew.std.array` defines mutable reference-identity `Array<t>` over the same six carrier families. `new` starts with zero capacity; `with_capacity` reserves exactly the requested capacity. Full pushes grow deterministically from zero to four and then double, preserve all live elements, and trap on unsigned capacity overflow. `length`, `capacity`, `is_empty`, safe `get`, trapping index/unchecked get, Boolean safe `set`, trapping index/unchecked set, `push`, optional `pop`, `clear`, and `iter` are compiler-known operations. Pop and clear release removed reference carriers by writing null into dead slots while preserving capacity. Aliases observe every mutation.

`dew.std.collections.stack` defines `Stack<t>` as a carrier-preserving standard abstraction over `Array<t>`. `stack_new`, `stack_with_capacity`, `stack_push`, optional `stack_pop`, optional non-mutating `stack_peek`, `stack_length`, `stack_is_empty`, `stack_clear`, and explicit iterator functions preserve mutable reference identity. Pop order is LIFO; empty pop and peek return `Option::None`. Stack iteration follows stable insertion order from the bottom element to the current top.

`dew.std.collections.circular_buffer` defines bounded and growable mutable ring buffers over the six Array carrier families. Bounded push returns false when full. Growable push expands zero capacity to four and otherwise doubles while preserving logical FIFO order. Head and tail positions wrap modulo backing capacity; pop and peek return `Option::None` when empty; pop and clear release removed reference carriers; iteration is stable logical front-to-back.

`using name = expression` evaluates acquisition once, creates an immutable binding, and registers one direct `Disposable.dispose` cleanup through the defer plan. It has the same LIFO exit and trap-exclusion behavior; acquisition traps register nothing. Disposable evidence must be visible through `dew.std.disposable`. Current aliasable references are not invalidated by cleanup. Direct manual disposal and direct return of a using binding are rejected with source-located diagnostics; alias-mediated escape remains outside the current non-affine analysis.

`defer expression` registers a lexical cleanup closure at that statement. Deferred expressions execute exactly once in reverse registration order when their scope exits by fallthrough, return, break, or continue. Exit values evaluate before cleanup. A nested loop's own break/continue does not exit an enclosing deferred scope. Mutable captures observe their latest value, later declarations are out of scope, cleanup traps stop older cleanups, and ordinary traps do not unwind defer.

`dew.std.disposable` defines non-ambient `Disposable` evidence with `dispose(self) -> Unit` and a generic explicit dispatch helper. Disposal has no implicit error result or trap unwinding. Because current references are aliasable rather than linear, direct calls do not statically consume aliases and callers own manual double-disposal/idempotence policy.

`dew.std.show` defines non-ambient `Show` evidence with `append_show(self, formatter: ShowFormatter) -> Unit`. `show(value)` constructs one builder-backed formatter and returns its finished String; composition helpers append nested shown values, text/views, or ASCII without intermediate strings. Nested dispatch is capped at 64 levels and output at 1,048,576 bytes; crossing either boundary traps. Show is side-effect free and distinct from ambient WASI-backed Debug. Initial stable formats cover Bool, signed/unsigned fixed-width integers, String, and StringView. Postfix `derive(Show)` emits ordinary coherent generic implementations with `Type { field: value }`, `Type::Variant(value)`, and `Type::Variant { field: value }` forms and freezes across imports. Floating-point, Unit, byte, SWAR, and SIMD formats remain intentionally undefined.

`dew.std.collections.ordered_set` defines comparator-ordered sets with idempotent insertion, membership, removal, extrema, bounds, predecessor/successor, key iteration, and inclusive/exclusive ranges over the shared red-black tree core.

`dew.std.collections.ordered_map` defines deterministic comparator-ordered maps with replacement, optional lookup, removal, extrema, bounds, predecessor/successor, entry iteration, and inclusive/exclusive ranges over the shared red-black tree core.

`dew.std.collections.red_black_tree` defines a mutable comparator-driven ordered tree with replacement, lookup, removal, extrema, predecessor/successor, lower/upper bounds, invariant checking, deterministic in-order traversal, and inclusive/exclusive range iterators.

`dew.std.collections.priority_queue` defines `PriorityQueue<value, priority, comparator>` as a thin BinaryHeap wrapper. It retains comparator and min/max policy, keeps values paired with priorities, returns `Option::None` at empty boundaries, and leaves equal-priority order unspecified.

`dew.std.collections.binary_heap` defines mutable `BinaryHeap<t, c>` with comparator evidence and minimum/maximum policy retained at construction. Push and pop are O(log n), peek is O(1), and copied Floyd construction is O(n). Empty peek/pop return `Option::None`; equal elements are unstable; iteration exposes heap layout rather than sorted order.

`dew.std.ordering` defines `Ordering::{Less, Equal, Greater}` and explicit `Comparator<t>` evidence for heaps, trees, sorting, and binary search. `NaturalComparator` supports values with `Lt` and `Eq`; comparator implementations used by ordered collections must define a deterministic total order. Natural floating-point comparison is not a total NaN ordering.

`dew.std.collections.deque` defines a growable double-ended queue over circular-buffer storage. Pushes at either end are O(1) amortized; pops and peeks are O(1); empty boundaries return `Option::None`; iteration remains logical front-to-back.

`dew.std.queue` defines mutable FIFO `Queue<t>` with construction, exact reservation, enqueue, optional dequeue, optional non-mutating front peek, length, emptiness, clear, and explicit iterator functions. Empty dequeue and peek return `Option::None`; aliases observe mutation; iteration is stable front-to-back. Its implementation lowers onto growable circular-buffer storage, giving O(1) amortized enqueue/dequeue with deterministic wraparound.

The ambient `Iter<t>` protocol has `has_next(self) -> Bool` and state-advancing `next(self) -> t`. Implementations are mutable reference-identity cursors. Calling `next` after exhaustion traps; callers that need a non-trapping boundary must check `has_next` first. Array and Stack iteration use stable index order over the live logical prefix. Hash collection iteration order is intentionally unspecified.

All current mutable collections use alias-visible reference semantics rather than persistence or snapshot isolation. A mutation that changes membership, length, or traversal topology invalidates outstanding iterators; successful insertion/removal, push/pop, enqueue/dequeue, and clearing a nonempty collection are structural. Failed/no-op mutations and capacity-only reservation are nonstructural. Indexed replacement and replacement of an existing map/tree value preserve iterator validity; values not yet yielded are read when reached. Using an invalidated iterator has unspecified traversal results but remains WasmGC memory- and type-safe. Persistent collections, if added, use distinct nominal APIs.

`IndexedSet` is distinct from a reference-returning `IndexMut` because Dew has no mutable-reference or borrow abstraction. Until associated types exist, the compiler must treat `(Self, key) -> value` as a functional dependency; complete cross-module enforcement remains pending. Implementation and validation details are recorded in `docs/research/fixed-array-indexing.md` and `docs/research/growable-array-iterators.md`.

#### 3.13.2 Hash keys, maps, and sets

String, StringView, and Bytes implement allocation-free 64-bit FNV-1a Hash over their logical bytes. The offset basis is 14695981039346656037 and the prime is 1099511628211; equal byte sequences share hashes across the three types, while `hash_eq` remains same-type.

The ambient `Hash` trait requires `hash(self) -> U64` and `hash_eq(self, right: Self) -> Bool`. A complete Hash implementation is sufficient for map-key eligibility. Collision equality is part of Hash because a U64 hash alone cannot define arbitrary key identity and Dew does not yet support supertrait bounds. Implementations must guarantee that hash-equal keys produce the same U64 value.

`dew.std.map` defines mutable reference-identity `Map<key, value>` with expected-context empty construction, inferred singleton construction, length, membership, safe `Option<value>` lookup, trapping unchecked/index lookup, insertion/replacement, indexed setting, Boolean removal, and clear. Insert and replacement return `Unit`; replacing an existing key preserves length. `remove` returns true only when it unlinks a present key. Clear replaces the bucket table and resets logical length, so aliases observe the mutation immediately.

`dew.std.set` defines mutable reference-identity `Set<key>` with expected-context empty construction, inferred singleton construction, `length`, `is_empty`, `contains`, insert, remove, and clear. `insert` returns true only when it adds a new key. `remove` returns true only when it unlinks a present key. Clear replaces the bucket table and resets logical length, so aliases observe the mutation immediately.

The deterministic WasmGC representation starts with sixteen buckets and grows geometrically through power-of-two capacities when a distinct insertion would make logical length exceed bucket count. Map entries store their U64 hash plus the canonical six erased carrier slots for both key and value; Set reuses the same private bucket/entry machinery while leaving the value carriers unused. Hash executes once per operation; `hash_eq` executes only after stored-hash equality. Growth traverses buckets and chains iteratively, relinks existing entries by their stored hashes without invoking user code, preserves wrapper identity and logical length, and uses the measured maximum load factor 1.0. Selection freezes both exact implementation method identities before lowering, linking marks them reachable, and emission performs no trait lookup. Traversal is iterative, including Map and Set head/middle/tail unlinking. `Map::keys`, `Map::values`, and `Map::entries` expose explicit mutable iterators; `MapEntry::key` and `MapEntry::value` read the paired entry; `Set::iter` exposes key iteration. Hash iteration order is explicitly unspecified. Iterators scan buckets and linked chains without allocating per element, `has_next` may prefetch iterator state, and exhausted `next` traps. Compact specialized entry layouts remain future work. Full details and threshold measurements are recorded in `docs/research/hash-map.md`.

### 3.14 Implementation indexing and method selection

`build_module_impl_index` freezes source-ordered implementations, validated method evidence, inherent and trait buckets, coherence and specificity metadata, source-sorted diagnostics, and a deterministic static/instance dispatch table. Impl heads must be primitive or nominal after transparent alias normalization. Trait impl validation checks required, unknown, and duplicate methods; receiver shape; value and method-generic arity; and parameter/return types after iterative substitution of trait arguments and contextual `Self`. Duplicate inherent names are diagnosed across impl blocks.

Implementations in one `(trait declaration, target head)` bucket are compared structurally. Impl-owned generics become fresh pattern variables, while trait application and target type are imported together so repeated generic occurrences remain correlated. Disjoint patterns coexist. A unique directional match establishes strict specialization; equivalent or overlapping-incomparable patterns are incoherent and receive `OverlappingTraitImpl`. Thus `Convert<I32> for Item` and `Convert<Bool> for Item` are disjoint, `Read for Box<I32>` outranks `Read for Box<t>`, and `Read for Pair<a, I32>` conflicts with `Read for Pair<Bool, b>`.

Supported statically selected forms are `receiver.method(args)`, `Type::method(receiver, args)`, `Type::static_function(args)`, `Trait::method(receiver, args)`, and `Trait::static_function(args)`. Receiver syntax defers its field target from ordinary member inference. Type qualification accepts both primitive and nominal type roots and restricts lookup to inherent members of that head; trait qualification restricts lookup to coherent evidence for the named trait. Inherent receiver methods have strict priority over unqualified trait methods, and the highest viable trait specificity wins.

Candidate signatures are instantiated and trialed under solver rollback; receiver, arguments, and expected result all participate. Impl generics, impl-method generics, and impl-owned `Self` are substituted, with selected type arguments stored in impl-then-method order. Expected results can select a static implementation when `Self` or an impl generic appears in the return type.

A unique candidate publishes its exact implementation method `DeclId` through `SelectedInferredCallTarget`, so later lowering can emit a direct call. No viable candidate emits `NoMatchingMethod`; multiple equally specific viable candidates emit `AmbiguousMethod`; absent qualified names emit `UnknownQualifiedMember`. Poisoned receivers suppress dependent cascades. Impl method bodies substitute their containing target for `Self`, while declaration generics remain rigid in their own body. Member retries skip already selected or failed nodes, preventing duplicate diagnostics while allowing method parameters to type nested object arguments.

Target dispatch entries sort by target head, name, inherent/trait tier, static/instance shape, implementation, and method source order; a secondary trait-qualified table sorts by trait declaration and the same stable member keys. Body jobs read the same immutable index and merge deterministically; forward and reverse schedules compare equal. Stress coverage includes 512 implementation buckets, 512 methods plus calls, and 512 applied specialization levels. Imported impl evidence is merged into consumer dispatch indexes (see the decision-log entries D-337 and D-477); generic obligations and runtime trait objects remain later work. Full details and benchmarks are recorded in `docs/research/impl-index-instance-method-inference.md`.

### 3.15 Deterministic lowering plans

`plan_module_lowering` consumes collected HIR, resolved types, frozen nominal layout recipes, the eager module-initialization schedule, stable callable ABI plans, resolved names, frozen inference selections, and structured flow summaries. It publishes one backend-neutral `PlannedModuleLowering` without mutating a shared Starshine builder. Module, body, declaration, local, control, field, variant, and selected-call identities remain stable numeric IDs.

HIR-aligned plan arrays cover bodies, expressions, blocks/items, object fields, patterns, and pattern arms. Every expression combines its frozen `BodyTypeId`, a backend-facing value shape, flow summary, exact selected operation, and source offset. Initial shapes are error, unit, `i32`, `i64`, `f32`, `f64`, reference, generic, and never. Strings, nominal values, and trait values use reference shape; unresolved rigid generic ABI choices remain explicit as generic shape.

The module plan embeds deterministic nominal layout recipes. Struct layouts retain source-ordered fields with exact `FieldId`, normalized type, shape, and field index. Enum variants receive stable zero-based source-order tags and preserve unit, tuple-type, or struct-field payload recipes. Generic payloads remain rigid recipes. A subsequent WasmGC fragment phase selects recursive groups and the sole optimized subtype-family enum representation without changing these semantic recipes. Full details and benchmarks are recorded in `docs/research/runtime-type-layout-plans.md`.

Module lets are eager. Dependency-first acyclic SCCs become exact `(DeclId, BodyId, BodyTypeId)` initialization steps. Multi-member SCCs and self-edge singleton SCCs become explicit cyclic steps and emit source-sorted `EagerModuleInitializationCycle` diagnostics, even when type inference successfully solved their recursive equations. Full details and benchmarks are recorded in `docs/research/module-initialization-plans.md`.

Callable ABI plans cover builtins, top-level functions, trait requirements, and impl methods. They retain exact declaration/body identity, containing and local generics, parameter types/shapes, receiver presence, contextual impl target, result type/shape, and source offset. Impl-owned `Self` uses the target's scalar/reference shape, while trait requirement `Self` remains generic for future dictionary ABI selection. Full details and benchmarks are recorded in `docs/research/function-abi-plans.md`.

Plan operations freeze constants, local/module-value reads, intrinsics, exact struct and enum construction, blocks, `if`, matches, functional loops and transfers, prefix/binary operations, selected direct/function/method calls, and exact field reads. Calls retain their selected `DeclId`, receiver when receiver syntax supplied one, ordinary argument span, and inferred type-argument span. Constructor and pattern plans retain exact `DeclId`, `VariantId`, and `FieldId` evidence.

Call and qualification roots consumed by a parent become `PlannedConsumedExpression`, preventing accidental standalone function/type/trait emission. Upstream poison remains `PlannedPoisonExpression` without duplicate diagnostics. Index reads and indexed-setting block items retain exact selected trait-method evidence; compiler-known FixedArray selections lower directly to carrier-specific array operations while user implementations remain ordinary direct calls.

Each body first produces a job-local plan. Results merge only in stable `BodyId` order into exclusive HIR-aligned slots; forward and reverse schedules compare equal. Traversal remains iterative through 1,024 prefixes and 512 selected method calls. Full details and benchmarks are recorded in `docs/research/deterministic-lowering-plans.md`.

### 3.16 Deterministic WasmGC and Starshine fragments

`plan_module_wasmgc_fragments` consumes resolved types plus frozen module lowering and publishes one immutable `PlannedModuleWasmGCFragments`. Every struct becomes one physical type source. Every enum becomes one non-final tag-only base plus subtype sources for distinct exact payload shapes; physically empty unit variants map directly to the base. Type jobs collect only stable nominal dependencies. Iterative SCC analysis orders groups dependency first, preserves source order within a recursive group, and assigns module-local type indices only during the stable merge. Forward and reverse simulated job schedules produce equal plans.

References to types in earlier groups use module `TypeIdx`; references inside the current recursive group use group-local `RecIdx`. Multi-member SCCs and self-referential singleton types therefore emit as Starshine `RecType::group`, while non-recursive singleton types use `RecType::new`.

The sole WasmGC enum ABI is an optimized subtype family: one non-final tag-only base, one final subtype per distinct exact payload shape within that enum family, and direct payload fields following the inherited tag prefix. Physically empty unit variants allocate the base directly. Source-order tags and exact `VariantId` evidence retain source identity when variants share a physical subtype. Tagged envelopes and automatic representation selection were removed after Node and Wago measurements showed consistently slower execution, more allocation work, and no compiler-performance advantage.

Callable signature types follow all physical GC types in stable callable order. Builtin imports receive the first function indices, executable top-level and impl functions follow, and trait requirements retain signature types without occupying function indices. Generic and trait ABI slots currently use nullable `eqref`; concrete nominal slots use non-null typed references; `Unit` and `Never` occupy no Wasm value slot.

The backend package mechanically emits Starshine `TypeSec`, `ImportSec`, `FuncSec`, `GlobalSec`, `ExportSec`, and `CodeSec` values from the frozen plan, appends the versioned `dew.abi` and `dew.metrics` custom sections, and assembles complete modules. Unrecognized builtins import from the reserved runtime module `dew`; recognized scalar builtins such as `i32_add`, `i32_sub`, and `i32_lte` emit native Wasm instructions and consume no function index. Frozen directization evidence replaces calls to trivial primitive impl wrappers with those instructions, and module-visible wrappers that become unreachable are elided deterministically. `emit_starshine_binary` validates the complete module through Starshine before encoding it through Starshine. The compiler does not invoke an external Wasm validator. The recursive trait-based Fibonacci module passes Starshine validation and executes in Node. Non-generic local and imported enum construction, field extraction, guarded matching, and dense dispatch emit the optimized subtype-family ABI through Starshine. Generic scalar boxes, erased ABI adapters, and explicit host-driven initialization (`__dew_init`) are implemented; the Wasm `Start` section remains subsequent work. Full details and measurements are recorded in `docs/research/deterministic-starshine-fragments.md`, `docs/research/enum-layout-dispatch-optimization.md`, and `docs/research/executable-trait-fibonacci.md`.

## 4. Names

- Generic type variables use `snake_case`, for example `t` and `type_var`.
- Named types use `PascalCase`, for example `I32`, `I64`, and `SumExample`.
- Identifiers may contain Unicode characters. The exact Unicode identifier-start, identifier-continue, normalization, and confusable-character rules remain open.

## 5. Traits

Dew supports traits parameterized by types.

```dew
trait Into<t> {
  fn into(self) -> t
}
```

Standard binary-operator traits are deliberately homogeneous and are not parameterized by a right-hand-side type:

```dew
trait Add {
  fn add(self, right: Self) -> Self
}

trait Lte {
  fn lte(self, right: Self) -> Bool
}
```

An operator obligation unifies the left and right operand types before implementation selection. Thus `impl Add for I32` fixes both operands and the result to `I32`; forms such as `Add<I64> for I32` are not part of Dew's operator model. Generic traits remain available for non-operator abstractions.

The compiler-owned `dew.std.preamble` module provides the homogeneous operator traits `Add`, `Sub`, `Mul`, `Div`, `Rem`, `Eq`, `Ne`, `Lt`, `Lte`, `Gt`, `Gte`, `BitAnd`, `BitOr`, `BitXor`, `Shl`, and `Shr`; the generic `Into<t>`, `Iter<t>`, `IndexedGet<key, value>`, `IndexedSet<key, value>`, and `Hash` traits; and the scalar builtin declarations such as `i32_add`, `i32_sub`, and `i32_lte` that back them. `collect_program_bytes` includes this preamble automatically. The raw `collect_bytes` phase helper intentionally omits it for isolated semantic tests and benchmarks. Preamble and user source are parsed as separate event streams, so user byte offsets remain unchanged; `CollectedModule.preamble_declaration_count` records the fixed semantic-ID prefix. In the production driver, `dew.std.preamble`, `dew.std.option`, and `dew.std.result` are ambient canonical imports; the remaining standard modules (text, bytes, builders, WASI, map, set, fixed arrays, lanes, and intrinsics) are selected by a deterministic leading-import prepass and resolved only through frozen interfaces, as described in `std/README.md`.

A method does not repeat the trait's generic parameter list merely to use those parameters. Method-level generics are not accepted by the initial parser and may be specified separately in the future, but their syntax and shadowing rules are not yet decided.

The implemented declaration grammar is:

```text
trait-declaration = "pub"? "trait" identifier type-parameters? trait-body line-end
trait-body        = "{" "}"
                  | "{" newline newline* trait-method* "}"
trait-method      = "fn" identifier "(" trait-parameters? ")"
                    "->" type newline
trait-parameter   = "self"
                  | "self" ":" "Self"
                  | identifier ":" type
```

One trailing comma is accepted in trait type-parameter and method-parameter lists, and newlines may follow commas. Non-empty trait bodies require a newline after `{`, and every method signature requires a newline after its return type. Compact empty traits such as `trait Marker {}` are valid. Trait bodies initially contain method signatures only: default bodies, associated types, associated constants, supertraits, and generic bounds are not yet parsed.

A bare trait is module-visible; `pub trait` exports it. Trait methods inherit membership in the trait contract and do not have separate visibility modifiers.

Dew supports static and instance trait methods. Static trait methods are callable using qualified syntax:

```dew
Trait::static_method(...)
```

`self` must be the first parameter. Both `self` and explicit `self: Self` are accepted and normalized to one receiver AST form. An explicit receiver type other than `Self` is rejected. A method without a first receiver, including a zero-argument method, is static.

All of the following instance-call forms are intended to be legal:

```dew
value.method(args)
Trait::method(value, args)
Type::method(value, args)
```

### 5.1 Dispatch

> **Status:** Static dispatch and runtime trait values for object-safe traits over nominal reference, scalar, packed, and SIMD receivers are implemented across linked modules. Concrete-to-trait boundaries retain exact coherent evidence, reconstruct local or imported requirement signatures, construct WasmGC trait objects using one shared typed dictionary per exact evidence tree, and invoke source-ordered methods with `call_ref`. Closed generic specializations recursively substitute symbolic bound evidence. Transparent tail or explicit-return parameter selectors devirtualize completely, while genuinely dynamic generic branches materialize exact prerequisite-aware dictionaries and implementation-method specializations, including imported providers. Public root generics whose symbolic evidence is used for erased coercions or direct bound methods/operators export a V1 runtime-evidence fallback with trailing source-ordered `eqref` vtable parameters. Static calls dispatch through the supplied typed method reference without constructing an object. Direct evidence forwards through private, recursive, and imported generic calls using contiguous callee-hidden slots and caller-local forwarding records. Statically selected concrete generic implementations recursively preserve ordered prerequisite trees and forward caller-local leaf runtime dictionaries through each exact implementation-method specialization. Erased dictionaries that would need to capture those prerequisites remain tracked in `docs/roadmap.md`.

When semantic analysis knows the selected method and implementation, Dew emits a direct call. This applies to inherent methods, statically selected trait methods, and qualified trait calls whose receiver type is concrete.

Dynamic dispatch is used only when the receiver is a runtime trait object. The default representation uses an immutable per-implementation dictionary/vtable represented by a WasmGC struct:

```text
TraitVTable = struct {
  method_0: ref Method0Signature
  method_1: ref Method1Signature
}

TraitObject = {
  receiver
  vtable: ref TraitVTable
}
```

A dynamic trait call loads a typed function reference from the dictionary and invokes it with Wasm `call_ref`. A trampoline is generated only when receiver casting or ABI adaptation is necessary; otherwise the dictionary stores the implementation function directly.

A runtime `Trait` value is an erased trait object. Its receiver slot uses a non-null Wasm `(ref any)`-compatible representation. GC-reference values enter that slot directly. Numeric, packed, and vector scalars allocate one immutable WasmGC snapshot box using the canonical `i32`, `i64`, `f32`, `f64`, or `v128` carrier. The erased-receiver adapter casts that box and loads field zero before directly calling the concrete implementation method.

Boxing occurs only at an actual erased-trait-object boundary. A statically resolved trait call, including a qualified call on a concrete scalar, remains unboxed and compiles directly. A scalar box belongs exclusively to the resulting trait value and is not an alias to the source local, parameter, field, or module value. If mutable receiver syntax is added, mutation changes only the trait-owned box and never writes back through the conversion source; current receiver parameters are immutable, so current carrier boxes are immutable. Closed generic implementation dictionaries select ABI-shape/evidence-specialized method entries, so equal receiver carriers with different prerequisite implementations remain distinct.

Exact non-generic receiver-free self calls in structural tail position lower to WebAssembly Core 3 `return_call` when the callable result and all locals use scalar carriers. Tail positions propagate through block tails, explicit returns, if branches, and match arms; non-tail, reference-carrier, generic, receiver, mutual, and callback recursion remain ordinary calls. The scalar restriction preserves Node/Wago parity for the current Core 3 runtimes.

Repeated scalar field extraction from the same immutable direct local is reused when an earlier immutable lexical `let` already stores the value. Later direct extractions read that local; duplicate uncaptured immutable aliases are elided and their uses are retargeted. Adjacent operands do not gain scratch locals. Mutable bases, captured aliases, reference/generic/Unit results, arbitrary calls, and uncertain cross-block control flow are excluded.

A supported scalar field read directly from fresh struct construction becomes a source-ordered parameter selection over every field initializer, removing the struct allocation and field load without skipping or reordering unselected initializers. The same applies to an immutable uncaptured local whose sole use is a later direct field read in the same block; its declaration and local read are elided when every non-adjacent constructor initializer and intervening expression is total/discardable. Narrow, reference, generic, trait-coerced, variant, mutable/captured, multiple-use, cross-block, effectful-gap, and escaping aggregates remain unchanged.

Whole-program optimization derives immutable summaries for non-generic scalar parameter selectors and zero-argument scalar constants. Selector calls evaluate every original argument exactly once in source order through `PlannedParameterSelect`; constant calls drop only zero-argument call overhead. Summary rewriting is deterministic and transitive, while reference, trait, callback, receiver, generic, and effectful cases remain uninlined.

Whole-program optimization copies lowering arenas before mutation and deterministically folds exact Bool and I32/U32/I64/U64 constant operations to a fixed point. Wrapping add/subtract/multiply, bitwise operations, equality, comparisons, and valid unary operations fold; potentially trapping division/remainder, shifts, exponentiation, packed values, and floats remain unfused.

Program lowering propagates exact runtime-trait evidence through non-captured locals, blocks, same-evidence `if`/`match` joins, transparent parameter returns, and effect-free private forwarding chains. A flow remains exact only when its trait, recursive implementation/prerequisite evidence, carrier shape, and nominal head agree on every incoming path. Exact dynamic calls are rewritten to the selected implementation method using ordinary generic specialization arguments and ordered prerequisite roots. Generic parameter selectors are solved to a fixed point; a tail expression or sole explicit `return` of a parameter transfers the callee's bound slot to the caller, preserves all argument evaluation, and adopts the selected concrete type/shape. Locals are converted back to their concrete representation only when every read and assignment participates in the selected non-escaping flow. Private wrappers with no remaining external reference are removed before fragment planning, eliminating their envelopes, scalar/SIMD boxes, dictionaries, adapters, globals, `ref.func`, and `call_ref`. Differing evidence, captures, unknown assignments, public wrappers, and wrappers whose elimination could remove effectful evaluation retain dynamic dispatch. A dynamic generic specialization resolves its bound slot through the caller evidence forest and materializes the exact recursive dictionary. These transformations do not change trait-value semantics.

Trait-object reference identity is not observable language semantics. Copying a trait value may preserve its runtime envelope reference, while repeating a conversion may allocate another envelope or scalar box; programs cannot distinguish these cases through ambient identity. There is no universal equality operation for erased trait values. Equality requires an explicitly object-safe semantic operation, and the current `Eq` method shape is not object-safe because it uses `Self` outside the receiver. Shared dictionary identity never implies receiver or value equality.

A centralized `br_table` dispatcher is not the default. It may be introduced as a benchmark-driven optimization for small sealed implementation sets, but it does not define language semantics. A table-based `call_indirect` is likewise unnecessary when a typed function reference is already stored in the WasmGC dictionary.

Method-name ambiguity at the source level still requires an explicit qualification rule, specified by Q-039.

## 6. Implementations

Dew supports inherent, trait, generic, and module-local foreign implementations:

```text
impl-declaration = "impl" type-parameters? type impl-body line-end
                 | "impl" type-parameters? type "for" type impl-body line-end
                 | "foreign" "impl" type-parameters? type "for" type
                   impl-body line-end
impl-body        = "{" "}"
                 | "{" newline newline* function-declaration* "}"
```

```dew
impl Counter {
  fn increment(self: Counter) -> Counter {
    self
  }
}

impl Into<I32> for I64 {
  fn into(self) -> I32 {
    @wasm.i64_trunc_i32(self)
  }
}

impl<a> Convert<List<a>> for Wrapper<List<a>> {
  fn convert(self) -> List<a> {
    self
  }
}
```

An impl without `for` is inherent. An impl with `Trait for Type` supplies trait evidence. Impl bodies contain ordinary function declarations without separate `pub` modifiers. A receiver method has first parameter `self`; a method without it is static. Signature matching, receiver compatibility, missing or duplicate trait methods, overload selection, package ownership, and coherence are semantic checks.

An ordinary trait implementation is legal only when its declaring package owns the trait declaration or the normalized nominal head of the target type. Generic arguments do not transfer ownership. Primitive targets are owned by `dew.std`, so another package may implement its own trait for a primitive but may not ordinarily implement a foreign trait for that primitive. Package manifests currently contribute one ordinary module; every module in a package-less explicit module graph is a separate ownership domain, while all compiler-owned `dew.std` modules share the standard package identity.

Neither ordinary nor foreign impl declarations accept `pub`.

Dew is garbage-collected because it targets WasmGC. User-defined aggregate and recursive types compile to WasmGC recursive types. Primitive scalar values such as `I64` remain unboxed.

`self` denotes the receiver semantically, but its lowered representation follows the receiver type: a primitive receiver is passed as an unboxed Wasm scalar, while a GC-managed receiver is passed as a Wasm reference.

Executable generic code uses deterministic physical-carrier specialization: source shapes with the same Wasm carrier are coalesced only when their evidence identities also agree, and supported exported boundaries receive nullable-`eqref` erased fallback adapters with recursive conversion of nested aggregates and structural function values. Unboxed scalar carriers remain unboxed at concrete boundaries. Hidden immutable dictionaries are emitted only at actual erased runtime trait-value boundaries (Section 5.1), never for directized closed generic calls. A public generic body whose symbolic bounds are consumed by erased trait coercions or direct bound methods/operators receives an all-reference export with one trailing `eqref` evidence parameter per declared bound. Trait coercions cast those opaque parameters to exact typed vtables. Bound calls evaluate visible operands first, load the matching source-ordered method reference, and execute typed `call_ref` without an intermediate trait object. Nested generic calls forward direct bound evidence through contiguous trailing callee parameters after all visible arguments. Statically selected concrete evidence trees may contain recursively nested runtime-prerequisite paths; every concrete layer receives its exact implementation-method specialization and the leaf runtime dictionaries are forwarded in source order. A fallback is still suppressed when an erased conversion would require an immutable dictionary to capture caller-local evidence.

When multiple implementations match, Dew selects the unique most-specific implementation:

1. An exact concrete implementation outranks an implementation containing type variables.
2. Among generic implementations, implementation `A` is more specific than `B` when every type matched by `A` is also matched by `B`, but not every type matched by `B` is matched by `A`.
3. Equally specific or incomparable overlapping implementations are rejected when declared rather than deferred until a call site.

This makes the following first implementation more specific for `List<I32>`:

```dew
impl<a> Trait for List<a> { ... }
impl<b> Trait for b { ... }
```

### 6.1 Foreign implementations

A module may explicitly define an implementation when its package owns neither the trait nor the implementing type by using `foreign impl`:

```dew
foreign impl Trait for ForeignType {
  // ...
}
```

A foreign implementation is private implementation evidence considered only while compiling its declaring module.

- `pub foreign impl` is illegal.
- A foreign implementation cannot be imported or re-exported from another module.
- Two modules may independently declare different foreign implementations for the same trait/type pair without a global coherence conflict.
- A public function body may use its module's foreign implementation internally, but a public signature cannot expose, export, or require that implementation as evidence for callers.

## 7. Type methods

Dew supports static and instance methods associated directly with types. Any ordinary function whose first parameter is `self` is syntactically a method. `self: Type` explicitly identifies its receiver type; shorthand `self` resolves through a containing `Self` context such as an impl. `self` is illegal in any later parameter position. A function without a first `self` parameter is static or free depending on context. Top-level visibility uses the normal `pub`/module-visible declaration rule, while impl methods do not carry separate visibility modifiers.

Instance type methods may be called as either:

```dew
value.method(args)
Type::method(value, args)
```

Trait-qualified calls may be used when explicit trait selection is needed, subject to the final lookup rules.

## 8. Struct types

Dew supports named generic struct types with ordered named fields.

```dew
pub struct Point<t> {
  x: t
  y: t
}
```

Struct declarations provide nominal targets for explicit construction and expected types for compatible inline object expressions:

```dew
let explicit = Point {
  x: 10
  y: 20
}

let inferred = {
  x: 10
  y: 20
}
```

The parser preserves field order but does not assign layout. Semantic analysis resolves field types, checks duplicate names and generic arity, determines whether an inline object satisfies an expected struct type, and diagnoses public structs whose field types leak inaccessible declarations. WasmGC layout and recursive-group formation occur during lowering.

Field defaults, tuple structs, field-level visibility, object-to-struct inference without an expected type, and structural versus nominal compatibility remain open.

## 9. Sum types

Dew supports generic sum types with unit, tuple-like, and struct-like variants.

```dew
pub enum SumExample<type_var> {
  Empty
  Add(A, B, C)
  StructKind {
    field: Type
    field_2: type_var
  }
}
```

Variants and struct-like fields are newline-delimited. Tuple payload types are comma-delimited and permit one trailing comma. An empty tuple payload such as `Empty()` is rejected in favor of the canonical unit spelling `Empty`; an empty struct payload such as `Marker {}` remains distinct and legal.

The declaration AST preserves variant order and uses one direct tagged node for each variant shape. Duplicate variant names, duplicate struct-like fields, unknown payload types, generic arity, and recursive representation legality are semantic checks.

Variant construction syntax now parses through qualified access, calls, and postfix construction:

```dew
let empty = SumExample::Empty
let tuple = SumExample::Add(a, b, c)
let record = SumExample::StructKind {
  field: value
  field_2: other_value
}
```

Semantic analysis distinguishes unit and tuple constructors from qualified constants or static calls and validates struct-like construction targets. Generic argument inference, pattern syntax, the subtype-family runtime representation, source-order tag assignment, and exhaustiveness rules are implemented (Sections 3.11, 3.12, and 3.16); explicit generic qualification syntax at call sites remains open.

## 10. Decision log

| ID | Status | Decision |
|---|---|---|
| D-001 | Answered | Dew is implemented in MoonBit. |
| D-002 | Answered | Starshine is the backend. |
| D-003 | Answered | The target is WasmGC directly. |
| D-004 | Answered | Dew should look and work broadly like MoonBit, but with intentionally different features. |
| D-005 | Answered | Traits can take generic type parameters. |
| D-006 | Answered | Generic trait implementations are supported. |
| D-007 | Answered | Traits have static and instance methods. |
| D-008 | Answered | Types have static and instance methods. |
| D-009 | Answered | Sum types support generic parameters plus tuple-like and struct-like variants. |
| D-010 | Answered | The lexer is hand-written, forward-only, streaming, and performs no backtracking. |
| D-011 | Answered | The lexer returns a MoonBit `Iter` of tokens. |
| D-012 | Superseded | The initial separate declaration and diagnostic iterator design was replaced by D-036. |
| D-013 | Answered | Source is read from a raw file descriptor one page at a time. |
| D-014 | Answered | A custom streaming UTF-8 iterator decodes source into code points. |
| D-015 | Answered | The complete source file is not retained after its pages are consumed. |
| D-016 | Answered | Diagnostic text is reconstructed from stringified tokens rather than retained source text. |
| D-017 | Answered | Tokens carry decoded values rather than source slices. |
| D-018 | Answered | Lexical failures produce `Error` tokens and do not immediately stop lexing or parsing. |
| D-019 | Answered | The parser targets exactly one token of lookahead. |
| D-020 | Superseded | Deferred ambiguous representations were rejected in favor of the deterministic grammar defined by D-038. |
| D-021 | Superseded | The initial dual-iterator output was replaced by the single parse-event iterator in D-036. |
| D-022 | Answered | Diagnostics have severity levels. |
| D-023 | Refined | Error recovery may discard tokens or synthesize obvious syntax while tracking nested parse contexts. |
| D-024 | Answered | Generic type-variable names use `snake_case`. |
| D-025 | Answered | Named types use `PascalCase`. |
| D-026 | Answered | The `Add` trait method uses the trait-level `t`; the repeated method-level `<t>` was accidental. |
| D-027 | Refined | `self` denotes the receiver, but its lowered representation follows the type as specified by D-041. |
| D-028 | Answered | `value.method(...)`, `Trait::method(value, ...)`, and `Type::method(value, ...)` are all legal call forms. |
| D-029 | Answered | The outer parser iterator emits declarations rather than nested statements. |
| D-030 | Answered | Dew permits Unicode identifiers. |
| D-031 | Answered | The primary source-input path uses raw file descriptors directly. |
| D-032 | Provisional | Input is buffered one host operating-system page at a time, pending performance measurement. |
| D-033 | Answered | Decoded identifiers are stored as MoonBit strings. |
| D-034 | Refined | `Source` stores line-break positions and a transient active token window; tokens may later be evicted under D-043. |
| D-035 | Answered | A token has the shape `Token(TokenKind, Offset, Index)`. |
| D-036 | Answered | The parser returns one lazy `Iter[ParseEvent]` that interleaves declarations and diagnostics, avoiding cross-stream buffering. |
| D-037 | Answered | Diagnostic severities are `Error`, `Warning`, `Info`, and `Hint`. |
| D-038 | Answered | Dew's grammar must be deterministic and unambiguous; every declaration starts with a reserved declaration keyword. |
| D-039 | Answered | Expressions are parsed using the shunting-yard algorithm. |
| D-040 | Answered | Recovery may synthesize obvious missing syntax and error AST nodes to support partial compilation and language-server features. |
| D-041 | Answered | Aggregate and recursive types lower to WasmGC recursive types; primitive scalars remain unboxed, including as method receivers. |
| D-042 | Answered | Generic lowering should avoid broad monomorphization to keep generated Wasm compact. |
| D-043 | Answered | Tokens may be evicted after AST nodes contain enough information to regenerate diagnostic text. |
| D-044 | Answered | Statically selected methods compile to direct Wasm calls. |
| D-045 | Answered by design choice | Dynamic trait objects use immutable WasmGC dictionaries/vtables with typed function-reference fields invoked by `call_ref`; trampolines are used only for ABI adaptation. |
| D-046 | Answered | Exact concrete implementations take priority over matching generic implementations containing type variables. |
| D-047 | Answered | `self` must be the first parameter and is shorthand for `self: Self`; methods without it are static. |
| D-048 | Answered | Token offsets count UTF-8 bytes and token indices address the active `Source.tokens` array. |
| D-049 | Answered by design choice | Token indices are ephemeral and must not survive eviction from the active token array. |
| D-050 | Answered | Overlapping implementations use a structural specificity order; a unique narrower match wins, while equal or incomparable overlaps are rejected at declaration. |
| D-051 | Answered | A module may declare a module-local orphan implementation using `foreign impl Trait for ForeignType`. |
| D-052 | Answered | Foreign implementations are private to their declaring module: they cannot be `pub`, imported, or re-exported, and cannot appear as exported implementation evidence. |
| D-053 | Answered | Converting an unboxed scalar to an erased runtime `Trait` object boxes it into a WasmGC object because the trait-object receiver is a reference type. |
| D-054 | Answered | Static and ABI-specialized generic trait calls keep scalars unboxed; non-escaping erased boxes should be removed by directization and escape/scalar-replacement optimization. |
| D-055 | Implemented | The `tokenizer` MoonBit package provides a forward-only WTF-8 cursor over one reusable page-sized `Bytes` buffer refilled from a borrowed raw file descriptor. |
| D-056 | Implemented | `UtfCodepoint` is `UInt`, `ByteOffset` is `UInt64`, and the iterator yields code point/tagged unit first and absolute byte offset second. |
| D-057 | Implemented | The callback traversal uses a scalar-only internal decoder to avoid source-level tuple/option construction on its hot path. |
| D-058 | Superseded | U+FFFD replacement was replaced by lossless tagged malformed-byte sentinels under D-059. |
| D-059 | Answered and implemented | WTF-8 surrogate code points are accepted; malformed bytes use `0x110000..0x1100FF` sentinels and remain acceptable inside string literals. |
| D-060 | Answered and implemented | Descriptor reads reuse one buffer; incomplete sequences are compacted within that buffer before refill. |
| D-061 | Implemented | A terminal descriptor failure yields one `0x120000..0x12FFFF` I/O-error sentinel and then exhausts the iterator. |
| D-062 | Implemented | `Tokenizer` consumes the WTF-8 cursor with two units of bounded lookahead and returns `Iter[Token]` without source backtracking. |
| D-063 | Implemented | Fixed symbols include delimiters, arithmetic operators, `**`, `%`, `:`, `::`, `=`, `.`, `...`, `->`, and basic logical symbols. |
| D-064 | Implemented | `@identifier` and dotted forms such as `@wasm.i64_trunc_i32` are single `AtIdentifier(String)` tokens. |
| D-065 | Answered and implemented | A numeric literal without `.` defaults to `I32`; a floating-point literal must contain `.` in its spelling. |
| D-066 | Implemented | Quoted and MoonBit-style `#|` multiline string token payloads are lossless `Bytes`. |
| D-067 | Provisional and implemented | The initial keyword enum contains declaration, implementation, control-flow, module, and boolean words listed in section 3.2.1. |
| D-068 | Answered and implemented | Integer suffixes are `U`, `L`, and `UL`; dotted literals default to `F64`, and a trailing `F` selects `F32`. Exponent-only float spellings without `.` are rejected. |
| D-069 | Answered and implemented | Expression parsing alternates between unary-value-seeking and binary-operator-seeking modes and never rewinds the token stream. |
| D-070 | Implemented | The shunting-yard engine reduces directly into AST nodes using value and operator stacks rather than allocating a separate RPN output sequence. |
| D-071 | Implemented | Exponentiation is right-associative; ordinary arithmetic, bitwise, and logical operators are left-associative. Prefix operators bind above exponentiation. |
| D-072 | Answered and implemented | Relational and equality operators are non-associative; ungrouped chains such as `a < b < c` and `a == b != c` are rejected. |
| D-073 | Answered and implemented | `=` is not an expression operator. Binding is represented by keyword-led immutable `let` or mutable `let mut` declarations; mutation is a separate simple-name block item restricted to an existing `let mut` binding or its capture. |
| D-074 | Answered and implemented | Function calls accept one trailing comma, while a second trailing comma is an error. |
| D-075 | Answered and implemented | In binary-operator-seeking mode, `.` parses field access and `[` parses array/index access; call, field, and index postfix forms may chain. |
| D-076 | Answered | Dew's operator spelling and precedence table is closed; user code cannot declare custom operators. |
| D-077 | Implemented | Parser benchmarks cover left- and right-associative expressions, postfix chains, short expressions, tokenizer-only workloads, and end-to-end tokenization plus parsing. |
| D-078 | Implemented | Pending operators use parallel scalar code/offset arrays; successful operand pops use nullable references; internal lookahead consumption does not repeat `peek`. |
| D-079 | Implemented | Tokenizer hot paths use reusable identifier/number scratch storage and scalar lookahead advancement instead of allocating tuple values for every peek, take, and cursor refill. |
| D-080 | Answered and implemented | Builtin declarations use `[pub] builtin name<type_params>? (parameters) -> return_type = "builtin_name"`. |
| D-081 | Answered and implemented | Declaration visibility is either `Public` or default `ModuleVisible`; Dew has no private declaration visibility. |
| D-082 | Implemented | Builtin AST nodes retain ordered generic parameters, typed value parameters, return type, builtin-name bytes, visibility, and source offsets. |
| D-083 | Answered and implemented | Builtin return types are required, including explicit `-> Unit`; one trailing comma is accepted in generic and value parameter lists. |
| D-084 | Revised and implemented | Builtin names use standard double-quoted string literals only; `#|` multiline strings are rejected. The compiler performs exact lookup in an extensible registry that permits custom compiler-provided builtins. |
| D-085 | Provisional and implemented | Generic builtin declarations do not accept trait bounds initially. This may be reopened if a required builtin needs them. |
| D-086 | Answered | Dew-visible builtin declaration names may be overloaded; semantic analysis resolves candidates and diagnoses ambiguity. |
| D-087 | Answered | Generic call arguments may be inferred or explicitly supplied. The explicit call-site syntax remains open. |
| D-088 | Answered | Builtin registry strings do not imply one canonical signature. Each expansion's produced value type must match the selected declaration's instantiated return type. |
| D-089 | Answered and implemented | LF, CRLF, and CR produce significant `Newline` tokens; CRLF is one token, and line comments preserve their terminating newline. |
| D-090 | Answered and implemented | Declarations require a newline terminator, with end of input acting as an implicit final newline. |
| D-091 | Answered and implemented | Expression newlines are skipped in unary-value-seeking mode, after commas, within open groups, and around incomplete call/index syntax; a newline after a complete top-level value terminates the expression. |
| D-092 | Answered and implemented | Let declarations use `[pub] let [mut] name = expression`, with no semicolon. Their AST retains visibility, mutability, name, initializer, and offsets. |
| D-093 | Answered and implemented | Inline objects use `{ field: expression newline ... }`; every non-empty field requires a newline, commas are not separators, and `{}` is empty. |
| D-094 | Implemented | When `#|` lookahead consumes a non-continuation line ending, the tokenizer queues a pending `Newline` token rather than rewinding. |
| D-095 | Answered and implemented | Trait declarations use `[pub] trait Name<type_parameters>? { newline method-signatures }`, with compact `{}` allowed for an empty trait. |
| D-096 | Answered and implemented | Trait methods require `fn name(parameters) -> Type` followed by a newline; return types are mandatory and bodies are not accepted initially. |
| D-097 | Refined and implemented | A receiver must be first. Both `self` and `self: Self` normalize to one receiver AST entry; any other explicit receiver type is rejected. |
| D-098 | Implemented | Trait and ordinary function AST nodes store an optional receiver separately from a compact `Array[FnParameter]`; methods without a receiver are static. |
| D-099 | Provisional and implemented | Trait bodies initially contain method signatures only, with no method generics, default bodies, associated items, bounds, or supertraits. |
| D-100 | Implemented | Trait parser benchmarks separately measure tokenization, parse-only operation, and end-to-end parsing for static and receiver-heavy method sets across all four backends. |
| D-101 | Answered and implemented | A first `self` parameter on an ordinary function turns it into a method; `self` is illegal in later parameter positions. |
| D-102 | Implemented | Function declarations support optional `pub`, generics, typed parameters, mandatory return types, compact or newline-delimited bodies, local lets, returns, and expression items. |
| D-103 | Implemented | Declaration types support recursive generic application. In type context, `ShiftRight` supplies two adjacent `>` closers without changing expression tokenization. |
| D-104 | Implemented | Impl declarations support inherent `impl Type`, trait `impl Trait for Type`, generic impl parameters, and `foreign impl Trait for Type`. |
| D-105 | Answered and implemented | Impl members are ordinary function declarations; first-`self` methods are instance methods and receiverless functions are static. |
| D-106 | Answered and implemented | `pub impl`, `pub foreign impl`, and separate `pub` modifiers on impl methods are rejected. |
| D-107 | Implemented | Function and impl benchmarks measure tokenization, parse-only operation, and end-to-end parsing across native, WasmGC, JavaScript, and Wasm. |
| D-108 | Answered and implemented | Struct declarations use `[pub] struct Name<type_parameters>?` with compact or newline-delimited named-field bodies. |
| D-109 | Answered and implemented | Struct fields use `name: Type` followed by a required newline; commas are not field separators. |
| D-110 | Provisional and implemented | Struct fields do not have separate visibility modifiers; accessibility follows the containing struct's eventual access policy. |
| D-111 | Implemented | Struct AST nodes retain ordered fields and recursive applied types; parsing is iterative by field count and benchmarked across all four backends. |
| D-112 | Answered and implemented | Enum declarations support unit, tuple-like, and struct-like variants in one newline-delimited body. |
| D-113 | Answered and implemented | Enum variants are newline-delimited rather than comma-delimited; tuple payload type lists use commas and permit exactly one trailing comma. |
| D-114 | Answered and implemented | Empty tuple payloads are rejected in favor of the canonical unit spelling; compact empty struct-like payloads remain distinct and legal. |
| D-115 | Provisional and implemented | Enum variants and struct-like variant fields do not have separate visibility modifiers. |
| D-116 | Implemented | `EnumVariant` directly encodes each variant shape, avoiding a separate payload-wrapper allocation; member loops are iterative and benchmarked across all four backends. |
| D-117 | Answered and implemented | Generic type aliases use `[pub] type Name<parameters>? = Type` and reuse the recursive applied-type parser. |
| D-118 | Implemented | `Parser::parse_events`, `parse`, and `parse_bytes` expose one lazy interleaved `Iter[ParseEvent]` without collecting a module AST. |
| D-119 | Refined and implemented | Module recovery uses private failure-only structural delimiter metadata, preserving line recovery for flat errors while skipping complete malformed nested declarations before resuming at a declaration keyword. |
| D-120 | Answered and implemented | In binary-seeking mode, `::` is a right-unary qualification operator: it consumes one following property identifier, wraps the current value, and remains in binary-seeking mode. |
| D-121 | Answered and implemented | `::` has postfix precedence, supports a soft newline before its property, chains left-to-right, and never enters the infix operator stack. |
| D-122 | Implemented | Alias, module-stream, recovery, and qualified-chain workloads are benchmarked separately across native, WasmGC, JavaScript, and Wasm. |
| D-123 | Answered and implemented | In binary-seeking mode, `{` is a postfix construction body attached to the current expression; object and construction fields share one parser. |
| D-124 | Answered and implemented | Control-flow condition parsing uses a call-local stop-before-ungrouped-`{` flag, preserving the brace in lookahead without enlarging `Parser`; parentheses restore normal construction behavior. |
| D-125 | Implemented | Function bodies and control-flow branches share `Block` and `BlockItem`; `Block::tail_expression` exposes an explicit final expression without synthesizing Unit. |
| D-126 | Answered and implemented | `if` is an expression with an optional same-line `else`; block else branches use `BlockExpr`, and `else if` is a nested `IfExpr`. |
| D-127 | Answered | An if used as a value requires an else, and value-producing branch types must unify. |
| D-128 | Answered | An if without else has type Unit; if its branch lacks a final Unit-producing expression, Unit is implied and any prior value is discarded. |
| D-129 | Implemented | Constructor, brace-context, block, and if workloads have adversarial tests and cross-backend parse-only/end-to-end benchmarks. |
| D-130 | Answered and implemented | Match arms use a dedicated longest-match `=>` / `FatArrow` token. |
| D-131 | Answered and implemented | Patterns use a separate forward-only parser and AST rather than reusing expression parsing. |
| D-132 | Answered and implemented | Patterns include wildcard, binding, literal, qualified, tuple-like, and newline-delimited struct-like forms; range patterns and typed patterns remain deferred. |
| D-133 | Answered and implemented | Match arms are newline-delimited and accept expression or reusable block bodies; direct braces after `=>` are blocks, while direct object results require parentheses. |
| D-134 | Implemented | Expression contextual termination uses a compact call-local integer stop set instead of independent booleans, without enlarging persistent parser state. |
| D-135 | Implemented | Actual else-if chains parse iteratively and fold backward into nested `IfExpr`; common no-else and direct-else forms do not allocate chain arrays. |
| D-136 | Implemented | Pattern and match parsing have dedicated diagnostics, 512-arm/segment stress tests, and cross-backend benchmarks. |
| D-137 | Answered and implemented | Match guards use `if expression` between the arm pattern list and `=>`; the optional guard expression is retained on `PatternArm`. |
| D-138 | Answered and implemented | Comma-separated arm patterns are alternatives sharing one guard and body; newlines are soft after commas, but trailing alternative commas are rejected. |
| D-139 | Answered | Every alternative in one arm must bind the same variable names, and corresponding binding types must unify; name resolution and type checking enforce this rather than the parser. |
| D-140 | Answered and implemented | Bare `...` is a rest pattern restricted to tuple and struct payloads, with at most one rest item in each immediate payload. |
| D-141 | Answered | Tuple rest separates front- and back-matched positional patterns; struct rest permits omitted named fields, while a no-rest struct pattern must be semantically complete. |
| D-142 | Implemented | Alternative lists and rest payloads parse iteratively, include a 512-alternative stress test, and have dedicated cross-backend benchmarks. |
| D-143 | Answered and implemented | Pattern bindings are always immutable. `mut` is rejected in patterns; an arm that needs mutation creates an explicit `let mut` rebinding in its body. |
| D-144 | Answered and implemented | Every pattern-binding identifier beginning with `_` is discarded and normalized to `WildcardPattern`; it introduces no binding and does not participate in alternative binding compatibility. |
| D-145 | Answered and implemented | Initial `while` syntax is a functional pattern loop over one state expression, not a conventional Boolean-condition loop. |
| D-146 | Answered and implemented | Functional while bodies reuse ordered `PatternArm` values, including alternatives, `if` guards, rest patterns, and underscore discards. |
| D-147 | Answered and implemented | `continue expression` supplies the next state, while `break expression` exits the nearest functional while with its result value; both operands are mandatory and begin on the same physical line. |
| D-148 | Answered | Initial state and continue values must unify; break values separately unify as the loop result. Every reachable arm path must explicitly transfer, return, or diverge. |
| D-149 | Implemented | `WhileExpr`, `BreakExpr`, and `ContinueExpr` parse as expressions and retain no loop-depth state; context legality and exhaustiveness are semantic checks. |
| D-150 | Implemented | Functional loop arm parsing is iterative, has a 512-arm stress test, and is benchmarked parse-only, tokenize-only, and end-to-end across all four backends. |
| D-151 | Answered and implemented | Recovery metadata is represented by private failure-only brace, parenthesis, bracket, and angle frames; no recovery fields are added to persistent `Parser`. |
| D-152 | Implemented | Public expression, pattern, and declaration APIs strip recovery frames and preserve their existing error result types; module streaming alone consumes structural metadata. |
| D-153 | Answered and implemented | A delimiter owner adds its frame only when a child fails before the matching closer is consumed, preventing already-closed declarations from retaining stale recovery depth. |
| D-154 | Answered and implemented | Structural recovery ignores declaration keywords until all recorded delimiters close, then consumes the declaration-ending line and resumes keyword-led synchronization. |
| D-155 | Answered | If an enclosing delimiter never closes, compiler recovery proceeds to EOF rather than speculatively treating a keyword inside the open scope as top-level. |
| D-156 | Implemented | Nested recovery has trait, impl, function, enum, functional-while, generic, group, call, index, EOF, 1,024-delimiter and 256-declaration stress, and cross-backend benchmark coverage. |
| D-157 | Implemented | Semantic entities use deterministic packed module/local numeric IDs; module collection requires no global allocator and can become one independent worker job. |
| D-158 | Implemented | Declaration collection consumes the lazy parse-event iterator directly, interns names per module, preserves parser diagnostics, and builds separate type, trait, and value namespaces. |
| D-159 | Implemented | Dew-visible builtin declarations form source-ordered overload chains; ordinary duplicate module bindings and duplicate immediate members produce collection diagnostics while retaining stable identities. |
| D-160 | Implemented | Declaration-level type syntax lowers into child-first flat HIR with shared argument spans, iterative traversal, and reusable module-builder scratch arrays. |
| D-161 | Provisional and implemented | Semantic phase artifacts are frozen by convention after construction; future parallel jobs read immutable prior-phase artifacts and write only job-local outputs. |
| D-162 | Implemented | Module lets, top-level functions, and impl methods receive stable source-order `BodyId` values and constant-time declaration-to-body lookup; builtins and trait signatures have no body. |
| D-163 | Implemented | Executable HIR uses module-wide expression, block, pattern, object-field, and arm arenas with per-body spans rather than one arena set per function. |
| D-164 | Implemented | Body lowering is an iterative visit/finish task machine backed by reusable primitive stacks and typed parser-source pools; no recursive host calls are required. |
| D-165 | Implemented | Expressions and patterns emit child-first; variable-length direct children use shared child arenas, and absent hot-path values use `-1` sentinels. |
| D-166 | Implemented | Recursive parser body ASTs are released after collection; body HIR has 1,024-depth, 512-field, 513-arm, 512-else-if, all-target test, and four-backend benchmark coverage. |
| D-167 | Implemented | Initial compiler primitives are `Unit`, `Bool`, `I32`, `U32`, `I64`, `U64`, `F32`, `F64`, `String`, and `Never`; these names and `Self` are reserved from module type declarations. |
| D-168 | Implemented | Declaration signatures resolve into a canonical module-local arena containing primitive, generic-parameter, nominal, trait, contextual `Self`, applied, and error types. |
| D-169 | Provisional and implemented | Ordinary type lookup prefers immediate generics, containing generics, `Self`, primitives, module types, then traits; impl trait positions use the trait namespace exclusively. |
| D-170 | Implemented | Generic constructor arity and applicability are checked before interning an application; invalid types use one poison `ErrorType` to suppress cascades. |
| D-171 | Provisional and implemented | Shorthand `self` and named `Self` require a containing trait or impl context; a top-level receiver must currently provide an explicit concrete type. |
| D-172 | Implemented | Alias targets produce deduplicated dependency edges and iterative Kosaraju SCC diagnostics for multi-alias and self cycles. |
| D-173 | Implemented | Resolved parameter, callable, field, variant, alias, and impl signature tables are immutable-by-convention and indexed for future parallel body jobs. |
| D-174 | Implemented | Resolved type interning uses structural collision checks and 32-bit hash buckets to avoid BigInt-heavy hashing on JavaScript and classic Wasm. |
| D-175 | Implemented | Type aliases are transparent in callable, field, tuple-variant, and impl signatures; generic alias substitution is keyed by stable `GenericParameterId`. |
| D-176 | Implemented | Alias normalization and substitution use reusable iterative task machines and canonical type-ID memoization rather than recursive host calls. |
| D-177 | Implemented | Cyclic and transitively cyclic alias applications become the shared poison `ErrorType`; one existing SCC diagnostic remains the root error. |
| D-178 | Implemented | Alias expansion has a deterministic work budget of `max(4096, initial resolved type count * 64)` by default and reports at most one limit diagnostic per affected alias declaration. |
| D-179 | Implemented | Alias constructors, source syntax types, and alias target recipes preserve alias identity; normalization starts only from semantic signature roots to avoid quadratic open-generic expansion. |
| D-180 | Implemented | Parameters, sequential lets, and pattern bindings receive deterministic body-local `LocalId` values; each body job owns its scopes, scratch state, and diagnostics. |
| D-181 | Implemented | A local let initializer resolves before the new binding enters scope; explicit same-scope rebinding creates a new local and restores the previous binding when the scope exits. |
| D-182 | Implemented | Body references distinguish locals, module value candidate names, type and trait roots, deferred variant candidates, intrinsics, and errors in module-wide HIR-aligned side tables. |
| D-183 | Provisional and implemented | Pattern context distinguishes binding names from constructor roots; a known bare type, trait, or enum-variant spelling is treated as a constructor candidate. |
| D-184 | Implemented | The first arm alternative defines the binding-name contract; corresponding later occurrences share one `LocalId`, while duplicate, missing, and extra bindings receive deterministic diagnostics. |
| D-185 | Implemented | Every functional `while` receives a body-local `ControlId`; break and continue resolve to the nearest active loop, excluding the loop's initial-state expression. |
| D-186 | Implemented | Body name jobs may execute in any order and are merged in stable `BodyId` order; forward and reverse scheduling produce identical complete results. |
| D-187 | Implemented | Body name, scope, pattern, arm, and control traversal is iterative; pattern binding sets wider than eight names use reusable hash lookups. |
| D-188 | Implemented | Inference variables and local applied type terms are owned by one body or module-let SCC solver and never enter the frozen module resolved-type interner. |
| D-189 | Implemented | Body-local variables use union by size, path compression outside speculation, and iterative structural unification across rigid resolved and local applied types. |
| D-190 | Implemented | Variable binding performs an iterative generation-marked occurs check and diagnoses infinite local types before creating a recursive inference term. |
| D-191 | Implemented | A failed local equality records one origin-bearing mismatch and poisons the affected variable class with a shared body error type to suppress cascades. |
| D-192 | Implemented | Inference snapshots use primitive undo logs and allocation/diagnostic lengths so nested overload or trait candidate trials can commit or roll back without copying the solver. |
| D-193 | Implemented | Final body type substitution is an iterative zonking pass that follows representatives, rebuilds changed applications, propagates poison, and detects unresolved variables. |
| D-194 | Implemented | Rigid resolved types use compact encoded `BodyTypeId` references rather than allocating one body wrapper for every imported signature type. |
| D-195 | Implemented | `infer_module_bodies` publishes compact HIR-aligned expression, local, block, and reserved pattern type tables from independent body inference jobs. |
| D-196 | Answered and implemented | The final expression item is a block's value; earlier expression values may be discarded, and an empty block has type `Unit`. |
| D-197 | Answered and implemented | A valued return checks its value against the declared callable return type; bare return checks `Unit`, and a final return gives the containing block root type `Never`. |
| D-198 | Implemented | An actual `Never` expression is assignable to any expected value type without ordinary equality; two diverging if branches produce `Never`. |
| D-199 | Implemented | Literal token kinds seed fixed primitive expression types, and local-name expressions reuse the exact type slot of their resolved `LocalId`. |
| D-200 | Provisional and implemented | Logical operators enforce `Bool`; comparisons equate operands and produce `Bool`; other current operators propagate operand/result equality while domain and trait selection remain deferred. |
| D-201 | Implemented | Unsupported inference forms poison one outer expression and coalesce consumed name or qualification roots to avoid diagnostic cascades. |
| D-202 | Implemented | Final body outputs retain only reachable local type terms; worker-local solver scratch is reset and reused across sequential jobs while preserving parallel ownership. |
| D-203 | Implemented | Forward and reverse body inference scheduling produce identical complete `InferredModuleBodies` artifacts. |
| D-204 | Implemented | A call rooted at a module value name reads the frozen value-binding chain; one callable declaration selects directly, while local values and module lets are not callable until first-class function types exist. |
| D-205 | Implemented | Every direct generic call receives fresh body-local variables, and iterative signature substitution replaces only generic parameters owned by the selected declaration. |
| D-206 | Implemented | Argument types constrain instantiated parameter types and the call result constrains the instantiated return type; surrounding expected types are installed before call selection. |
| D-207 | Implemented | Builtin overload candidates are checked inside rollback snapshots so losing trials leave no allocations, variable mutations, or diagnostics. |
| D-208 | Provisional and implemented | Overload candidates are tried in ascending declared-generic-count tiers; viable concrete candidates outrank generic fallbacks, while complete generic/generic structural specificity remains future work. |
| D-209 | Implemented | Nested overloaded calls use an iterative progress worklist and retry deferred parents after another call commits distinguishing constraints. |
| D-210 | Implemented | Successful calls retain the exact selected `DeclId` and zonked inferred generic arguments in module call side tables. |
| D-211 | Implemented | Failed calls force their original result variable class to poison even after expected-type binding; poisoned child arguments suppress dependent no-match or ambiguity cascades. |
| D-212 | Implemented | Generic signature instantiation is iterative, generation-cached per candidate, and stress-tested through 1,024 applied type levels. |
| D-213 | Implemented | Call-inference scratch is worker-owned and reused across body jobs; per-body call results remain sparse until stable module merge. |
| D-214 | Implemented | Module-let dependency extraction scans resolved module references, deduplicates edges with generation marks, and stores source-ordered flat dependency spans. |
| D-215 | Implemented | Iterative Kosaraju analysis publishes dependency-first module-value SCCs whose members remain in module source order. |
| D-216 | Implemented | Every module-value SCC owns one solver and one fresh type slot per member; all member bodies constrain the shared slot graph before freezing. |
| D-217 | Refined by D-286 through D-290 | Recursive module values may have a valid inferred type when constrained, while the separate eager initialization planner rejects their runtime cycle. |
| D-218 | Implemented | Every declaration in an unconstrained recursive value class receives `UnresolvedModuleValue` before the shared class is poisoned. |
| D-219 | Implemented | `InferredModuleValues` is an immutable barrier containing source-aligned let types, compact local applications, dependency/SCC metadata, and diagnostics. |
| D-220 | Implemented | Frozen positive module-value applications are imported iteratively and generation-cached inside each independent function solver. |
| D-221 | Implemented | Module-let body jobs created during SCC inference are retained for final `BodyId`-ordered merge rather than inferred twice. |
| D-222 | Implemented | One-member SCCs and modules with no lets use dedicated fast paths; solver, call, and import scratch remain worker-owned and reusable. |
| D-223 | Implemented | Match patterns receive the scrutinee type and functional-loop patterns receive the loop state type through iterative expected-type tasks. |
| D-224 | Implemented | Bare variants prefer the expected enum and otherwise require one globally unique module candidate; qualified variants select only from their explicit enum. |
| D-225 | Implemented | Selected unit, tuple, struct-variant, and nominal-struct patterns retain their exact stable constructor identity and zonked generic arguments. |
| D-226 | Implemented | Tuple and struct payload kinds, arity, fields, missing fields, and rest behavior are checked after generic signature substitution. |
| D-227 | Implemented | Corresponding alternative-pattern occurrences share one local type variable, so incompatible payload types produce one ordinary pattern-origin mismatch. |
| D-228 | Implemented | Match guards require `Bool`; non-diverging arms constrain one shared result, while matches whose arms all diverge produce `Never`. |
| D-229 | Implemented | Every functional-loop control owns separate state and result types; initial and continue values constrain state, while break values constrain result. |
| D-230 | Implemented | A functional loop with no break targeting its control has result type `Never`. |
| D-231 | Superseded by D-237 | The provisional inferred-`Never` loop-arm fallthrough check moved from body inference into structural flow analysis. |
| D-232 | Implemented | Pattern propagation, payload substitution, match arms, and functional-loop arms use reusable iterative worker scratch and retain deterministic body-job merging. |
| D-233 | Implemented | Structured flow is a separate immutable phase reading collected HIR, resolved types, and frozen inferred bodies. |
| D-234 | Implemented | Expression, block, arm, and body flow summaries retain possible fallthrough, return, break, continue, and divergence outcomes as compact masks. |
| D-235 | Implemented | Flow uses child-first expression order, iterative block sequencing, branch union, explicit short-circuit paths, and inferred `Never` divergence. |
| D-236 | Implemented | Exhaustiveness distinguishes finite Boolean, finite enum, open catch-all, and error-suppressed coverage domains. |
| D-237 | Implemented | Functional-loop arm fallthrough is diagnosed from structural arm summaries rather than inferred root type alone. |
| D-238 | Implemented | Guarded arms contribute no unconditional coverage; non-exhaustive matches and loops retain stable missing Boolean or variant witnesses. |
| D-239 | Implemented | Whole-pattern irrefutability is separate from selected-constructor payload irrefutability, preventing nested enum payloads from overclaiming outer coverage. |
| D-240 | Implemented | Constructor-level redundant arms are diagnosed only when prior unconditional coverage makes every alternative useless; refutable nested payload usefulness remains conservative. |
| D-241 | Implemented | Pattern shape and constructor errors suppress dependent coverage diagnostics and cannot claim successful coverage. |
| D-242 | Implemented | Flow body jobs may run in any order and merge by stable `BodyId`; forward and reverse schedules produce identical outputs. |
| D-243 | Implemented | Flow and coverage traversals are iterative and cover 1,024 variants, 1,024 redundant arms, and 1,024 unreachable items. |
| D-244 | Implemented | Inferred expressions retain exact struct, variant, unit-value, or field selections plus zonked constructor generic arguments. |
| D-245 | Implemented | Untyped object literals require an expected nominal struct supplied by surrounding constraints. |
| D-246 | Implemented | Member inference uses an iterative worklist with child-first fields, reverse child-first objects, and progress-based retries. |
| D-247 | Implemented | Explicit struct and struct-variant construction validates payload ownership and records every selected object-field `FieldId`. |
| D-248 | Implemented | Tuple variants use qualified or bare call syntax; unit variants use qualified or bare value syntax; bare names prefer the expected enum and otherwise require global uniqueness. |
| D-249 | Implemented | Constructor and field signatures reuse the iterative generation-cached generic substitution engine shared by calls and patterns. |
| D-250 | Implemented | Construction diagnoses payload kind/arity, duplicate, unknown, and missing fields while preserving ordinary origin-bearing value mismatches. |
| D-251 | Implemented | Flat source-ordered fields receive per-declaration spans so construction and field access avoid whole-module scans. |
| D-252 | Implemented | Object arguments participate in overload speculation through nominal field-shape checks; incompatible primitive candidates are rejected without diagnostic leakage. |
| D-253 | Implemented | Constructor namespace roots and method/static-call targets are marked consumed before ordinary field inference, suppressing dependent unresolved or unknown-field diagnostics. |
| D-254 | Implemented | Bodies without member syntax retain shared empty arrays; member selection storage is allocated lazily in the existing expression initialization pass. |
| D-255 | Implemented | Object/field body jobs merge in stable order and pass 512-field, 512-nested-object, and 512-field-chain stress tests. |
| D-256 | Implemented | `build_module_impl_index` freezes stable implementation/method identities, target heads, inherent/trait buckets, coherence flags, and source-sorted diagnostics. |
| D-257 | Implemented | Trait impl validation checks method presence, duplicates, receiver and generic/value arity, and substituted parameter/return signatures. |
| D-258 | Implemented | Coherence imports trait applications and target types as correlated generic patterns, permits disjoint impls, ranks strict specializations, and rejects equivalent or incomparable overlaps. |
| D-259 | Implemented | Instance lookup binary-searches a deterministic dispatch table and gives inherent methods strict priority over trait methods. |
| D-260 | Implemented | Method trials use solver rollback and constrain receiver, arguments, and expected result before publishing one selected impl-method `DeclId`. |
| D-261 | Implemented | Impl generics, impl-method generics, and impl-owned `Self` use iterative call-site substitution; selected arguments are stored in impl-then-method order. |
| D-262 | Implemented | Impl-method body signatures replace containing `Self` with the impl target while preserving declaration generics as rigid body types. |
| D-263 | Implemented | Resumable member passes skip frozen selections and errors, preventing duplicate diagnostics while allowing method signatures to type nested object arguments. |
| D-264 | Implemented | Method jobs are schedule deterministic and pass 512-bucket and 512-method/call iterative stress tests. |
| D-265 | Implemented | Concrete unequal impl pairs bypass speculative unification; canonical duplicates use a direct equality path and produce one source-stable conflict per later declaration. |
| D-266 | Implemented | Trait method selection chooses the unique viable implementation with the highest strict-specificity rank. |
| D-267 | Implemented | Type-qualified calls select inherent static or receiver methods and treat an explicit receiver as the first ordinary call argument. |
| D-268 | Implemented | Trait-qualified calls restrict selection to coherent implementations of the named trait; expected results may select static `Self`-returning evidence. |
| D-269 | Implemented | Static and receiver methods share rollback-based impl/method generic substitution and publish the same frozen selected-call representation. |
| D-270 | Implemented | Coherence and selection remain iterative through at least 512 nested applied specialization levels. |
| D-271 | Implemented | Trait-qualified lookup uses a secondary deterministic dispatch table keyed by trait, name, and static/instance shape rather than scanning all implementations. |
| D-272 | Implemented | `plan_module_lowering` is a separate immutable phase over collected HIR, resolved types, frozen nominal layouts, resolved names, frozen inference, and structured flow. |
| D-273 | Implemented | Backend-neutral plans retain stable semantic IDs and HIR-aligned body, expression, block/item, field, pattern, and arm arrays. |
| D-274 | Implemented | Every planned expression combines its inferred type, runtime value shape, flow summary, exact selected operation, and source offset. |
| D-275 | Implemented | Initial runtime shapes distinguish unit, Wasm scalar widths, references, rigid generic ABI values, never, and error. |
| D-276 | Implemented | Planned direct calls retain exact selected declaration, receiver syntax operand, ordinary arguments, and inferred type arguments. |
| D-277 | Implemented | Planned construction, field, and pattern operations retain exact declaration, variant, field, and constructor evidence. |
| D-278 | Implemented | Consumed call/qualification roots cannot become standalone runtime values; upstream poison remains explicit without duplicate diagnostics. |
| D-279 | Implemented | Lowering bodies are independent jobs merged in stable `BodyId` order; forward and reverse schedules produce equal plans. |
| D-280 | Implemented | Plan construction is iterative through 1,024 prefixes and 512 selected method calls; indexing remains an explicit unsupported lowering boundary. |
| D-281 | Implemented | Module lowering embeds deterministic nominal struct and enum layout recipes keyed by stable declaration identity. |
| D-282 | Implemented | Struct and struct-variant fields retain exact source-order index, normalized type, backend value shape, and stable `FieldId`. |
| D-283 | Implemented | Enum variants receive stable zero-based source-order tags and distinct unit, tuple, or struct payload recipes. |
| D-284 | Implemented | Generic layout members remain rigid generic recipes until ABI-shape specialization or erasure is selected. |
| D-285 | Refined by D-298 through D-305 and superseded by D-375 | Semantic layout recipes defer physical representation without losing identity; the initial Starshine backend consumed deterministic recursive groups and tagged envelopes. |
| D-286 | Implemented | Eager module-value initialization is planned separately from SCC type inference using the frozen dependency-first SCC schedule. |
| D-287 | Implemented | Acyclic module lets retain exact declaration, initializer body, and frozen value type in their initialization step. |
| D-288 | Implemented | Multi-member SCCs and self-edge singleton SCCs are runtime-illegal eager initialization cycles even when their type equations are constrained. |
| D-289 | Implemented | Cycle members remain source ordered, map to one shared cyclic step, and emit one earliest-offset source-sorted diagnostic per SCC. |
| D-290 | Implemented | Module initialization planning reuses frozen SCCs without repeating graph traversal and remains iterative for 1,024 dependencies. |
| D-291 | Implemented | `PlannedModuleLowering` embeds the frozen initialization schedule so Starshine emission receives one coherent startup artifact. |
| D-292 | Implemented | Callable ABI planning covers builtins, top-level functions, trait requirements, and impl methods in stable source order. |
| D-293 | Implemented | Callable and parameter plans retain exact semantic identity, normalized type recipes, runtime shapes, generics, receiver status, and source offsets. |
| D-294 | Implemented | Impl method `Self` uses the containing target's runtime shape, preserving unboxed primitive receivers and reference aggregate receivers. |
| D-295 | Implemented | Trait requirement `Self` remains a generic ABI boundary until dictionary or erased representation selection. |
| D-296 | Implemented | Callable lookup uses a declaration-index side table without assigning final Starshine function indices. |
| D-297 | Implemented | `PlannedModuleLowering` embeds callable ABI plans alongside layouts, initialization, flow, and exact body operations. |
| D-298 | Implemented | WasmGC fragment planning is a separate immutable phase consuming resolved types and frozen module lowering. |
| D-299 | Implemented | Every nominal root is one physical type source and every payload-bearing enum variant contributes one typed payload-struct source. |
| D-300 | Implemented | Iterative SCC analysis orders physical type groups dependency first and preserves source order inside each recursive group. |
| D-301 | Implemented | Type and function indices are assigned only during stable fragment merge; simulated forward and reverse job schedules produce equal plans. |
| D-302 | Implemented | Same-group field references retain group-local recursive indices while earlier-group references retain module type indices. |
| D-303 | Superseded by D-375 | The initial enum baseline was an immutable tagged envelope with an `i32` semantic tag and nullable erased payload reference. |
| D-304 | Superseded by D-375 | The initial envelope baseline used immutable typed payload structs and null payloads for unit variants. |
| D-305 | Implemented | Scalar struct/payload fields remain unboxed, nominal fields use typed references, and `Unit`/`Never` occupy no physical field slot. |
| D-306 | Superseded by D-479 | Callable function types originally followed physical GC types in stable callable order without signature deduplication. |
| D-307 | Implemented | Builtin imports own the function-index prefix, definitions follow in source order, and trait requirements remain signature-only dictionary candidates. |
| D-308 | Implemented | Generic and trait ABI boundaries provisionally use nullable `eqref`; concrete nominal ABI values use non-null typed references. |
| D-309 | Implemented | Starshine emission mechanically constructs type, import, and function sections without repeating dependency or candidate analysis. |
| D-310 | Implemented | Multi-member and self-recursive singleton SCCs emit `RecType::group`; non-recursive singleton types emit `RecType::new`. |
| D-311 | Implemented | Dew builtins import from the reserved Starshine/Wasm module name `dew` using their declared registry key as field name. |
| D-312 | Implemented | Starshine validation covers mutual recursion, self recursion, tagged enums, and callable signatures; planning remains iterative through 1,024 nominal dependencies. |
| D-313 | Implemented | Binary operator traits are homogeneous: standard traits such as `Add`, `Sub`, and `Lte` use `Self` for both operands, have no right-hand-side type parameter, and operator inference unifies both operand types before implementation selection. |
| D-314 | Implemented | Recognized standard scalar builtins consume no import/function index and mechanically expand to native Wasm instructions during body emission. |
| D-315 | Implemented | Exact trivial-wrapper evidence is frozen during WasmGC fragment planning; calls directize without repeating trait or method selection. |
| D-316 | Implemented | Module-visible directizable wrappers are elided from function and code sections, while public wrappers remain materialized to preserve export ABI. |
| D-317 | Implemented | Complete Starshine modules include deterministic code and public function export sections and can be validated and encoded through `emit_starshine_binary`. |
| D-318 | Implemented | The recursive homogeneous-trait Fibonacci module validates and encodes through Starshine, executes in Node, and returns `fib(10) = 55`. |
| D-319 | Implemented | `collect_program_bytes` includes the compiler-owned `dew.std.preamble` module, while raw `collect_bytes` remains a no-preamble phase-testing API. |
| D-320 | Implemented | Preamble and user bytes are parsed as separate forward-only event streams; user offsets are preserved and a fixed semantic declaration-ID prefix records preamble provenance. |
| D-321 | Implemented | The initial ambient `dew.std.preamble` module provides homogeneous `Add`, `Sub`, and `Lte` traits, their `I32` implementations, and inline builtin declarations, allowing Fibonacci source to contain only the function. |
| D-322 | Specified | Every file assigned to one module contributes to one shared module namespace; default `ModuleVisible` declarations are usable across those files, while `pub` controls visibility outside the module. |
| D-323 | Superseded | `global` is no longer reserved. The former `global import` spelling was replaced before stabilization because it incorrectly suggested program/package scope. |
| D-324 | Implemented | `open module.path` contributes the imported module's public names and coherent implementation evidence to unqualified lookup in the current Dew module only. It does not re-export, clone, or change ownership of imported declarations. |
| D-325 | Specified | Standard modules use the `dew.std` root. `dew.std.preamble` is implicitly globally imported; modules such as `dew.std.map` and `dew.std.queue` are ordinary explicit imports unless the preamble re-exports selected declarations. |
| D-326 | Implemented | `FileId` is a stable packed module/file-local identity assigned in manifest order; `SourceLocation` stores `FileId` and byte offset separately. |
| D-327 | Implemented | `collect_program_files` parses manifest-ordered files independently into one shared module namespace and freezes declaration/body file provenance plus file-aware parse and duplicate diagnostics. |
| D-328 | Implemented | The bootstrap `dew.std.preamble` source is split into deterministic logical files mirrored under `std/preamble/*.dew`; user file IDs begin after a reserved compiler-owned range. |
| D-329 | Implemented | Qualified `import` and unqualified `open` declarations are parsed lazily only in each file's contiguous preamble; all files contribute to their owning module's import scope, and late imports/opens are diagnosed without stopping later declarations. |
| D-330 | Implemented | The initial in-memory manifest assigns module IDs from explicit manifest order and file IDs from per-module manifest order, with deterministic duplicate-path diagnostics. |
| D-331 | Implemented | `FrozenModuleInterface` retains public user declarations, callable signatures, resolved type recipes, and initial non-foreign impl evidence without parser ASTs or executable HIR bodies. |
| D-332 | Implemented | Collected imports form a deterministic module dependency graph with missing/duplicate diagnostics and iterative dependency-first SCC scheduling. |
| D-333 | Implemented | Import scopes expose dependency public names without retaining dependency AST/HIR; lexical and same-module declarations take precedence, while conflicting imported names are diagnosed deterministically. |
| D-334 | Implemented | Imported nominal types, traits, and transparent aliases are translated lazily into the consumer's resolved-type interner; generic alias substitution is iterative and preserves source `DeclId`/`GenericParameterId` identity. |
| D-335 | Implemented | Module SCC interface resolution uses a bounded two-pass schedule so cyclic nominal signatures can observe every member's public declaration skeleton without recursive host traversal. |
| D-336 | Implemented | Imported top-level function signatures are translated into consumer-local type recipes, and direct/generic call inference freezes exact external declaration and type-argument evidence. |
| D-337 | Implemented provisionally | Frozen interfaces include public aggregate fields and variants plus non-foreign implementation evidence whose trait and target heads are externally visible. Imported implementation methods retain exact external identities and enter consumer method/operator dispatch indexes. Owner coherence is trusted; structural overlap across independently imported or local/imported evidence remains pending. |
| D-338 | Implemented | Per-interface type-import memo tables are allocated lazily; module/interface jobs do not allocate memo storage for unrelated manifest modules. |
| D-339 | Implemented | The initial executable multi-module backend statically combines Dew modules into one Wasm module rather than defining a cross-instance WasmGC ABI. |
| D-340 | Implemented | Program callable ordering is dependency-SCC order, manifest order within an SCC, and source callable order within a module; all runtime imports precede definitions in the final Wasm function index space. |
| D-341 | Implemented | Module-local WasmGC fragment jobs remain isolated from final program indices; a separate stable merge freezes `DeclId` to final function-index evidence. |
| D-342 | Implemented | Only public functions from the selected root Dew module become Wasm exports; public dependency functions remain linked internal definitions. |
| D-343 | Implemented | The initial static linker supports scalar direct calls and module-SCC recursion, while physical aggregate types and unspecialized generic calls produce explicit link diagnostics. |
| D-344 | Implemented | Program Starshine emission consumes frozen program plans mechanically and does not repeat module graph traversal, inference, dispatch selection, or final index allocation. |
| D-345 | Implemented | Module fragments preserve imported nominal storage/value references as exact `DeclId`s instead of degrading them to `eqref`; the stable program merge resolves them to final dependency type indices. |
| D-346 | Superseded by D-476 | Program physical types were initially rebased by dependency-SCC/module order while cross-module forward references were diagnosed. Program-wide physical SCC merging now replaces that boundary. |
| D-347 | Implemented | Imported struct fields are translated into consumer type arenas and retain exact external `FieldId`, owner, variant, name, and resolved type evidence. |
| D-348 | Implemented | Non-generic local and imported struct construction emits physical-order operands followed by `struct.new`; typed field reads emit `struct.get` using final program type and field indices. |
| D-349 | Implemented | Generic aggregate types are rejected at program linking until specialization or boxing evidence is frozen. |
| D-350 | Implemented | Wide construction uses a thresholded field-order strategy: allocation-free scans for at most eight fields and one temporary `FieldId` lookup for larger structs. |
| D-351 | Implemented | Type/field ownership is derived from packed semantic IDs through one `ModuleId` lookup rather than per-entity owner maps. |
| D-352 | Implemented | Starshine is the sole compiler-side Wasm validator: complete modules must pass `@validate.validate_module` before Starshine binary encoding, and the compiler does not invoke external validation tools. |
| D-353 | Implemented | Imported variants retain exact external `VariantId`, owner declaration, payload kind, name, and consumer-local translated payload types in flat declaration-grouped arenas. |
| D-354 | Implemented | Imported unit, tuple, and struct-style enum construction reuses existing expression-selection evidence rather than introducing backend-specific foreign constructors. |
| D-355 | Implemented | Module WasmGC fragments freeze variant declarations and source-order tags in compact arrays indexed by packed variant-local ID; the program linker does not build a global variant-owner map. |
| D-356 | Superseded by D-375 | The initial executable enum backend constructed tagged nullable-`eqref` envelopes and separate typed payload objects. |
| D-357 | Implemented | Imported variant translation uses one source-ordered cursor per frozen interface, avoiding a declaration-by-variant quadratic scan. |
| D-358 | Superseded by D-375 | WasmGC enum representation was temporarily a frozen planning option with tagged-envelope and subtype-family modes; frontend and backend-neutral phases remain representation-independent. |
| D-359 | Implemented | The initial subtype-family mode emits one non-final tag-only enum base and one distinct final physical subtype per source variant; physical shape flattening is explicitly deferred. |
| D-360 | Superseded by D-375 | The initial envelope comparison retained one distinct typed payload object per non-empty source variant. |
| D-361 | Implemented | Executable match lowering evaluates the scrutinee once into a scratch local using its physical scalar carrier or nullable `eqref`. Scalar literal patterns cover every fixed-width signed, unsigned, and floating type; direct and unary-sign forms emit shared carrier-specific constant/prefix instructions followed by equality. Enum patterns dispatch by frozen source tag, cast to the exact payload/subtype type, extract bindings, and evaluate guards and arm bodies in source order. |
| D-362 | Implemented | Imported unit, tuple, and struct variant patterns preserve exact external constructors and consumer-local payload recipes; imported exhaustiveness remains conservative until flow analysis consumes frozen interfaces. |
| D-363 | Implemented | Guarded match fallback duplication and linear nested-if dispatch are accepted initial IR; control-flow factoring, dense dispatch, cast elimination, and type flattening are later optimization passes. |
| D-364 | Implemented | Both enum representations must pass Starshine validation and encoding; provisional runtime comparison keeps both available rather than selecting a default prematurely. |
| D-365 | Implemented | Exact enum shape sharing separates source-variant field evidence from representative physical types, allowing multiple variants to reuse one type without losing source tuple indices or `FieldId`s. |
| D-366 | Superseded by D-375 | The retired envelope optimizer shared equal payload types across declarations; active subtype sharing remains scoped to one declared enum base. |
| D-367 | Implemented | Optimized subtype families map physically empty unit variants directly to the non-final enum base while retaining source identity through the frozen tag. |
| D-368 | Implemented | Equal recursive payload recipes may reuse one representative physical type; broader recursive structural partition refinement remains deferred. |
| D-369 | Superseded by D-375 | Automatic enum representation selection briefly used whole-program construction and destructuring evidence before the envelope representation and selection pass were removed. |
| D-370 | Implemented | Match results use a shared result local and outer exit block so guarded arms fall through without duplicating the remaining arm tree. |
| D-371 | Implemented | Complete, unique, unguarded dense tag domains emit `br_table`; guarded, duplicate-tag, partial, and catch-all matches retain factored source-order dispatch. |
| D-372 | Implemented | Baseline and optimized layout/dispatch policies remain independently selectable so compile-time, encoded-size, and runtime effects remain measurable. |
| D-373 | Implemented | The Wago Wasm 3 benchmark harness configures Core 3 features and an explicit bounded throughput heap, reporting compile, instantiate, execution, allocation, size, and checksum evidence. |
| D-374 | Superseded by D-375 | Program-wide WasmGC planning briefly defaulted to the optimized automatic enum policy while both physical representations remained available. |
| D-375 | Implemented | Tagged-envelope enums are removed from the compiler after subtype families prove faster in Node and approximately 2.8-3.0x faster in Wago while also reducing allocation work and encoded size. |
| D-376 | Implemented | The sole enum ABI is one non-final tag-only base plus final direct-payload subtypes; physically empty unit variants allocate the base directly. |
| D-377 | Implemented | Exact subtype shape sharing remains scoped to one enum base because a Wasm subtype declares one nominal supertype; unrelated enum families retain distinct physical subtype definitions. |
| D-378 | Implemented | `WasmGCPlanningOptions` retains only baseline-versus-optimized subtype controls for measurements; production module and program planning always default to exact sharing, unit-base reuse, and dense dispatch. |
| D-379 | Implemented | Dew's scalar primitive set is `I8`, `I16`, `I32`, `I64`, `U8`, `U16`, `U32`, `U64`, `F32`, and `F64`; small integers use canonical `i32` values while `I64`/`U64` use `i64`. |
| D-380 | Implemented | Aggregate `I8`/`U8` and `I16`/`U16` fields use packed WasmGC storage with signed or unsigned getter instructions selected from frozen field storage evidence. |
| D-381 | Implemented | Canonical numeric suffixes are lowercase width names (`i8`, `u64`, `f32`, and so on); legacy `U`, `L`, `UL`, and `F` remain accepted, and signed `max + 1` is legal only beneath unary negation. |
| D-382 | Implemented | Homogeneous scalar arithmetic, comparison, bitwise, and shift operators resolve through compiler-owned trait implementations and emit signedness-specific Wasm instructions with narrow-result normalization. |
| D-383 | Implemented | `Into<t>` exists for every ordered scalar numeric pair: integer narrowing wraps, integer widening follows source signedness, float conversion uses IEEE operations, and float-to-integer truncation traps outside the exact target range. |
| D-384 | Implemented | Typed linear-memory intrinsics use `U32` memory-zero addresses, offset zero, natural alignment hints, little-endian Wasm behavior, and bounds traps; memory is emitted only when reachable code uses an intrinsic. |
| D-385 | Implemented | `V128` is a native Wasm `v128` primitive with direct bitwise, splat, lane-arithmetic, comparison, shift, saturation, min/max, reduction, memory, parameter, result, local, and aggregate-field support. |
| D-386 | Implemented in part | `Swar32` and `Swar64` are allocation-free semantic primitives over `i32` and `i64`; core packed-lane construction, extraction, replacement, add/subtract, shifts, masks, reductions, and population-count formulas are ported from `JairusSW/as-simd`. |
| D-387 | Superseded by D-403 through D-407 | The provisional shared `stringref` carrier was replaced by distinct GC-managed String/Bytes wrappers over `array<v128>`. |
| D-388 | Implemented | Fragment planning performs iterative exact-call reachability for compiler-owned definitions so unused expanded-preamble helper bodies receive no function index, while every user definition remains a root. |
| D-389 | Implemented | `b"..."` produces a `Bytes` literal, preserves exact escaped octets, and accepts non-ASCII source text through the tokenizer's existing WTF-8 encoder. |
| D-390 | Accepted | Dew will add concrete zero-wrapper packed-lane primitives over the raw carriers: 128-bit views such as `I32x4`/`F32x4` use `v128`, 64-bit views such as `I32x2` use `i64`, and useful 32-bit views use `i32`. |
| D-391 | Accepted | Same-width lane-view changes are explicit zero-instruction reinterpretations rather than ordinary numeric `Into<t>` conversions; numeric lane conversion and lane rearrangement remain separately named operations. |
| D-392 | Implemented in part | SWAR correctness is tested by compiling Dew exports to Wasm and comparing them in Node against deterministic independent BigInt lane oracles; each new SWAR operation must extend this parity harness. |
| D-393 | Implemented | Dew defines 20 concrete zero-wrapper lane primitives: four `i32`-carried views, six `i64`-carried integer views, and ten native `v128` views, each retaining a distinct semantic identity. `F32x2` is intentionally unsupported. |
| D-394 | Implemented | Every ordered reinterpretation among lane views with the same physical carrier is explicit and emits no instruction; numeric vector conversion remains a separately named operation. |
| D-395 | Implemented | Native lane extraction and replacement use generated fixed-index functions and methods so every Wasm lane immediate is frozen before mechanical emission. |
| D-396 | Implemented | Native lane views expose canonical Wasm SIMD arithmetic, comparisons, saturation, min/max, reductions, widening, narrowing, extension-multiply, dot, swizzle, rounding, and numeric conversion operations where Starshine provides an instruction. |
| D-397 | Implemented | `open dew.std.<lane-type>` selects and opens a compiler-owned standard module without requiring a manifest entry. A deterministic leading-import prepass collects only selected lane modules under reserved identities, freezes each interface once per program, and contributes its methods/impl evidence without adding lane declarations to user arenas. |
| D-398 | Implemented | Every typed scalar-packed integer family adds wrapping multiply, comparison masks, min/max, saturation, average, signed abs/neg, bitmask, and reductions, with 61,000 Node/Wasm differential checks. |
| D-399 | Implemented | Native vectors provide scalar splat loads, fixed-index lane loads/stores, widening partial loads, and zero-extending 32/64-bit loads with natural alignment hints and ordinary Wasm bounds traps. |
| D-400 | Implemented | String-oriented byte rearrangement uses deterministic named shuffles (`reverse`, zip/unzip, and `concat_shift_1..15`) plus dynamic swizzle instead of a new arbitrary-immediate source syntax. |
| D-401 | Accepted | Dew does not expose relaxed SIMD in its deterministic standard surface because implementation-dependent results conflict with reproducible execution. |
| D-402 | Accepted | Dew does not define `F32x2`; non-native floating SWAR semantics do not justify the language, test, and optimization surface. |
| D-403 | Implemented | `String`, `StringView`, and `Bytes` use distinct WasmGC struct identities carrying shared mutable-physical `array<v128>` backing, byte start, and exact byte length; publication is semantically immutable. |
| D-404 | Implemented | Source `String` literals must be strict RFC 3629 UTF-8; malformed and WTF-8 byte sequences remain representable only as `Bytes`. |
| D-405 | Implemented | `dew.std.string` exposes byte length, zero-copy String-to-Bytes backing sharing, strict Bytes UTF-8 validation, and UTF-16 unit pre-counting. |
| D-406 | Implemented in part | UTF-8 validation and UTF-16 length algorithms derive from `JairusSW/utf-as` under MIT attribution and operate directly over GC-resident V128 chunks. |
| D-407 | Implemented | WASI-facing APIs consume `Bytes`; lowering copies bounded chunks into reusable linear-memory scratch and never makes linear memory the owner of a Dew string. |
| D-408 | Implemented | UTF-16 unit counting is a `String` operation, not a raw `Bytes` operation, so the algorithm always receives valid UTF-8. |
| D-409 | Implemented | String, StringView, and Bytes equality first compares exact byte length, scans to mutual physical alignment, compares full V128 chunks when legal, and compares logical tails exactly. |
| D-410 | Implemented | `String.byte_at(U32)`, `StringView.byte_at(U32)`, and `Bytes.byte_at(U32)` expose exact logical byte indexing and trap on an out-of-range unsigned index. |
| D-411 | Implemented | `Bytes.to_string()` performs strict RFC 3629 validation, traps on malformed input, and publishes a nominal String wrapper sharing the existing GC chunk array and exact length without copying content. |
| D-412 | Implemented | Compiler-owned runtime functions freeze private callable dependencies before final function-index assignment; checked Bytes-to-String conversion retains and directly calls its UTF-8 validator even when validation is not otherwise referenced. |
| D-413 | Implemented | `test "display name" { ... }` declares a zero-parameter, implicit-Unit test body with frozen display-name/file/offset metadata and a deterministic compiler-owned manifest-order `__dew_test_<ordinal>` test-mode entry point; source byte offsets are not part of the export identity. |
| D-414 | Implemented | Standard `assert(Bool, String) -> Unit` evaluates both arguments and traps with Wasm `unreachable` when the condition is false; message transport across the trap is deferred without changing the source API. |
| D-415 | Implemented | Standard `unreachable() -> Never` emits the Wasm `unreachable` instruction directly. |
| D-416 | Implemented provisionally | `std/tests/*_test.dew` files are assembled deterministically and executed through Node by `tools/dew-test/run.sh`; a future test manifest/custom section will replace offset-derived export discovery. |
| D-417 | Implemented | Tests are first-class semantic callables but are not package interface values; normal planning analyzes and elides them, while `WasmGCPlanningOptions::test_mode()` makes them reachability roots and exports. |
| D-418 | Implemented | Any manifest source path ending exactly in `_test.dew` is a test-only file. All callables declared there, including helpers, are excluded from production interfaces/reachability/emission and become roots in test mode; `test` declarations outside `_test.dew` are diagnosed. |
| D-419 | Implemented | `String.view(start, length)` and `StringView.view(start, length)` create O(1) normalized shared ranges after overflow-safe bounds and strict UTF-8 boundary checks; view conversion to String or Bytes shares chunks, start, and length. |
| D-420 | Implemented | `StringBuilder` privately mutates geometrically grown V128 storage, appends String and StringView values, publishes a start-zero String with `finish()`, and traps on every use after consumption. |
| D-421 | Implemented | Logical text operations honor nonzero starts. Dynamic two-chunk swizzle assembles unaligned logical V128 blocks for UTF validation/counting and equality, while byte access adds start and exact tails remain scalar. |
| D-422 | Implemented | `BytesBuilder` privately mutates geometrically grown V128 storage, appends arbitrary Bytes ranges and individual U8 values, publishes a start-zero Bytes with `finish()`, and traps on every use after consumption. |
| D-423 | Implemented | StringBuilder and BytesBuilder share one deterministic SIMD builder engine for growth, used-chunk copying, unaligned logical V128 reads/writes, exact scalar tails, and consume-on-finish enforcement while retaining distinct nominal runtime types. |
| D-424 | Implemented | `view(start, length)` is the strict checked length-based shared-range operation; String/StringView results are StringView, while Bytes returns another shared Bytes wrapper. |
| D-425 | Implemented | `subarray(start, end)` is the strict checked end-exclusive shared-range operation, while `slice(start, end)` exact-copies the end-exclusive range into start-zero storage; all indices are U32 and invalid, reversed, or out-of-bounds ranges trap rather than clamp. |
| D-426 | Implemented | `compact()` exact-copies the complete logical String, StringView, or Bytes range into exactly sized start-zero V128 storage to release disproportionately retained backing. |
| D-427 | Implemented | `StringBuilder.append_ascii(U8)` appends exactly one byte only for values through 0x7F, while `append_scalar(U32)` directly emits the canonical one-to-four-byte strict UTF-8 encoding and traps on surrogates or values above U+10FFFF. |
| D-428 | Implemented | `StringBuilder.append_checked(Bytes)` validates strict UTF-8 once through the existing checked Bytes-to-String path, then appends the exact logical range without weakening the builder invariant. |
| D-429 | Implemented | `String.concat(String)`, `String.concat_view(StringView)`, and `Bytes.concat(Bytes)` perform overflow-checked flat concatenation into exactly sized start-zero V128 storage; they preserve arbitrary Bytes, strict text invariants, unaligned shared inputs, zero padding, and never create ropes or retain source backing. |
| D-430 | Implemented | `Bytes.find_byte(U8)` returns `Option<U32>` as `Option::Some(index)` or `Option::None`, while `contains_byte(U8)` shares an allocation-free SIMD scan; any U32 sentinel remains a private runtime detail. |
| D-431 | Implemented | `Bytes.starts_with(Bytes)` and `Bytes.ends_with(Bytes)` compare exact logical ranges allocation-free, match empty patterns, reject overlong patterns, preserve arbitrary bytes, and support independently unaligned shared backing. |
| D-432 | Implemented | Function bodies may join nominal GC values through the common eqref control-flow carrier, but module and linked-program emission casts the final value back to the frozen exact nominal result reference before satisfying the callable ABI. |
| D-433 | Implemented | `Bytes.find(Bytes)` and `Bytes.contains(Bytes)` are allocation-free exact substring operations: empty needles match at zero, one-byte needles reuse SIMD byte search, needles through sixteen bytes use SIMD first/last candidate masks, and longer needles use a rolling U64 fingerprint with exact collision verification. |
| D-434 | Implemented | Text-runtime hardening is deterministic and test-only: exhaustive byte/alignment and boundary-length matrices, an algebraically constructed rolling-hash collision, all builder consumption aliases, invalid UTF-8 interior edges, exact nominal result ABI regressions, and 64 KiB search stress execute without adding public APIs or machine-dependent fail-closed timing thresholds. |
| D-435 | Implemented | String and StringView expose allocation-free find, contains, starts-with, and ends-with operations for all String/StringView operand combinations; results are UTF-8 byte offsets, empty needles match at zero, matching is exact without normalization, and valid UTF-8 self-synchronization preserves scalar boundaries. |
| D-436 | Implemented | WASI Preview 1 Bytes I/O uses the 65,520 data bytes remaining in one reusable 64 KiB linear-memory page: `wasi_fd_write` handles complete and partial writes, `wasi_fd_read` builds immutable GC Bytes through full-window reads until the limit, EOF, or a short read, and errno, zero-progress writes, or host over-reporting trap. Unreachable WASI imports and memory are elided. |
| D-437 | Implemented | WASI marshalling selects aligned four-V128 copy batches before generic unaligned/tail handling, retains each staged write window across host partial writes, and provides benchmark-only phase probes that separate GC-to-scratch, scratch-to-GC, and host-callback costs. |
| D-438 | Implemented | Convention-based compiler fixtures snapshot ordered compiler errors, ordered compiler warnings, deterministic WASI stdout lines, normalized expected Wasm traps, repeated byte-identical Wasm, and canonical WAT. Failed compilation uses `output: null` and has no WAT; every compiled fixture executes test exports and zero-argument `main` in both Node and Wago Core 3, requires identical normalized stdout/traps, ignores `main`'s return value, and uses either a stdout array or `{ trap, stdout }` output. The harness supplies equivalent bounded Preview 1 `fd_write`/`fd_read` callbacks to both runtimes. |
| D-439 | Implemented | Compiler snapshot diagnostics use explicit `DEW_ERROR` or `DEW_WARNING` framing terminated by `DEW_END`, preserving each possibly multiline deterministic `Debug` representation as one ordered JSON string. Fixture totals are discovered from the checked-in tree rather than duplicated here. Unreachable block items are the first ordinary source-located warning producer and do not prevent compilation or execution. |
| D-440 | Implemented | Snapshot host behavior uses one optional `host` object for hexadecimal stdin, bounded partial reads/writes, errno, zero progress, and over-reporting. Optional `<test>.files/`, `<test>.modules/<dotted.module>/`, and `<test>.tests/` sibling directories add same-module files, statically linked imported modules, and test-only files without a fixture manifest or JSON module graph. |
| D-441 | Implemented | Primitive names are legal type-qualified call roots and select inherent static or receiver-taking impl members through the same frozen dispatch index as nominal types. Builder construction uses `StringBuilder::new()`, `StringBuilder::with_capacity(...)`, `BytesBuilder::new()`, and `BytesBuilder::with_capacity(...)`. |
| D-442 | Implemented | Standard text ownership is split into `dew.std.string`, `dew.std.string_builder`, `dew.std.bytes`, and `dew.std.bytes_builder`; `BytesBuilder` remains a consuming publication builder and does not preempt a future reusable mutable `Buffer`. The bootstrap compiler preserves deterministic declaration order through a private shared text-runtime source. |
| D-443 | Implemented | Test exports use deterministic manifest ordinals. The standard runner compiles `_test.dew` files individually and reads one compiler-emitted `dew.tests` Wasm custom section containing versioned `DEW_TESTS_V3` records for export, logical module, logical file, strict-UTF-8 display name, and optional expected trap. Stable module/file/display-name identities are duplicate-checked, metadata drives exact filtering and listing, repeated test builds are byte-identical, and production binaries contain no test section. |
| D-444 | Superseded by D-453 | The selective embedded-source-mirror bootstrap established deterministic import masks and stable standard slots, but user modules no longer collect those optional mirrors into their own declaration arenas. |
| D-445 | Implemented | Tests may declare `expect_trap "category"` between the display name and body. Collection validates the same five stable trap categories used by snapshots, V3 metadata transports the expectation, and the runner treats a matching normalized Wasm trap as a pass while continuing to later tests. |
| D-446 | Implemented in part | Ordinary-file type and body resolution cannot use values, nominal types, traits, or impl evidence declared only in `_test.dew` files. Production WasmGC planning omits test-only nominal layouts and will not traverse call edges into test callables; module values, initialization artifacts, and imported evidence remain under audit. |
| D-447 | Implemented provisionally | `tools/dew check`, `build`, `test`, and `run` accept explicitly ordered files or strict manifests, select a static link root, execute the immutable program pipeline, preserve framed deterministic diagnostics, and return nonzero status on failure. Build provides deterministic HIR, lowering, pinned-printer WAT, and Starshine-validated Wasm emit modes. Run invokes an exported zero-argument `main` with bounded Preview 1 stdin/stdout hosting. Installed binaries and file-aware diagnostic rendering remain pending. |
| D-448 | Superseded by D-527 | The initial explicit root/module/file graph remains supported as `dew.modules.json` for bootstrap compiler inputs. It is no longer the package-definition format. |
| D-449 | Implemented | Self-describing test binaries append a deterministic `dew.tests` custom section only after Starshine has validated and encoded the semantic Wasm module. The section payload exactly preserves the V3 record schema, custom-section structure has direct backend tests including multi-byte unsigned LEB128 lengths, Node requires exactly one section, malformed/version/UTF-8/duplicate metadata has dedicated tests, and ordinary production emission remains section-free. |
| D-450 | Implemented | CLI/standard test compilation injects a private `dew_test_assert` runtime. A failed assertion converts the current runtime `String` to sharing `Bytes`, writes the exact dynamic bytes to WASI Preview 1 descriptor 1 through the bounded reusable staging page, and then traps. The runner captures per-test stdout and strict-UTF-8 decodes the message. Static `dew.assertions` metadata and assertion-ID globals are forbidden; production assertions remain direct zero-I/O inline traps. |
| D-451 | Implemented for current artifacts | Test-only impl declarations are excluded when freezing module interfaces, so their evidence cannot enter imported scopes. Module initialization steps carry explicit `test_only` ownership, nominal layouts remain production-filtered, and backend tests prove production and ordinary test-mode planning remain assertion-global-free. Future module-global/startup emission must skip marked initialization steps; those runtime artifacts are not implemented yet. |
| D-452 | Implemented | Program-wide test linking distinguishes test-only helper callables from explicit test entries. Only explicit entries are exported, and globally unique `__dew_test_<ordinal>` names follow manifest module/file/declaration order rather than dependency-SCC emission order. Manifest-driven `dew test` embeds complete cross-module identities and supports package-wide exact/substring filters and metadata-only listing. |
| D-453 | Implemented | Selected `dew.std.*` sources are collected as deterministic compiler-owned modules with reserved identities, frozen independently, and imported into user modules only through immutable interfaces. `dew.std.preamble`, `dew.std.option`, and `dew.std.result` are ambient; text, builder, bytes, WASI, and lane modules remain import-selected. Cross-module methods, primitive/static impl evidence, runtime dependencies, and direct typed calls retain their owner identities through linking. |
| D-454 | Implemented in part | The standard library defines generic `Option<t>` and `Result<t, e>`, and text/byte search returns `Option<U32>`. Generic enum payload positions use one deterministic erased aggregate layout containing `i32`, `i64`, `f32`, `f64`, `v128`, and nullable-`eqref` carrier fields; constructors initialize only the inferred carrier and patterns read only that carrier. Generic functions and generic structs remain unsupported pending the general callable ABI. |
| D-455 | Implemented | Program planning computes cross-module callable, runtime, and nominal reachability before final indices. Elided signatures consume no type slots or external type references; unused imported generic and ordinary nominal layouts are omitted; private runtime dependencies such as UTF-8 validation, test assertion transport, and WASI imports are rooted across their real standard-module boundaries. |
| D-456 | Implemented | Open targets may end in one terminal wildcard. Wildcard expansion considers only deterministic collected module paths, opens all descendants of the dotted prefix, diagnoses an empty match, and excludes the private `dew.std.text_runtime` module from direct user scope. Qualified imports reject wildcards. `open dew.std.*` selects every public standard module, including all lane families and `dew.std.wasm.intrinsics`. |
| D-457 | Implemented provisionally | The bootstrap driver resolves the canonical `dew.std` package from explicitly ordered `--package-root` values, ordered `DEW_PACKAGE_ROOTS`, or the compiler checkout fallback. It reads only compiler-registered source paths selected by leading imports, never enumerates directories, and feeds caller-owned source bytes into stable reserved module identities. `--bootstrap-std` preserves generated-source fallback and `--no-default-preamble` disables implicit preamble/Option/Result imports for user modules. On-disk, generated, cache-miss, and cache-hit paths must emit byte-identical Wasm. |
| D-458 | Implemented | Diagnostics-free compiler-owned standard `FrozenModuleInterface` bundles use a private deterministic versioned binary serialization containing complete resolved-type arenas, declarations, fields, variants, callables, parameters, implementation evidence, shapes, identities, and source locations. Decoding bounds every collection by remaining bytes and rejects invalid tags, Booleans, UTF-8, truncation, and trailing data. |
| D-459 | Implemented | Standard interface cache keys are SHA-256 over a private ABI marker plus the exact ordered selected logical paths and source bytes. Artifacts live under `.dew-cache/interfaces`, carry a second versioned envelope and SHA-256 payload checksum, and are identity/count checked before mixed cached/fresh SCC freezing. `--cache-report`, `--no-interface-cache`, `DEW_CACHE_DIR`, and `DEW_INTERFACE_CACHE=0` control the cache. Corruption is a visible input/cache failure, never a silent miss. Generated bootstrap providers are intentionally non-cacheable. |
| D-460 | Implemented provisionally | `@identifier` is reserved for imported module aliases rather than direct compiler intrinsics. Qualified imports derive the final module-path segment as a default alias, `import path as @alias` records an explicit alias, wildcards are rejected, and `@alias.member(...)` selects callables from the exact frozen imported interface without adding that interface's names to unqualified lookup. Import and open declarations from every file contribute to the owning module scope; qualification of types/traits/variants/patterns remains pending. |
| D-461 | Implemented provisionally | Direct source-addressable WebAssembly intrinsics belong to the independently frozen `dew.std.wasm.intrinsics` module. The former direct `@wasm.*` expression path is removed; the initial migrated conversion is executable through an import alias. Complete generated WebAssembly Core 3 intrinsic coverage remains required. |
| D-462 | Planned | Ordinary packages use strict TOML metadata and conventionally derive modules from deterministic sorted `src/**/*.dew` paths under the root package or `.dew/packages/<package-name>/`; JSON, TOML, and YAML parsers/serializers must eventually be implemented in Dew itself for installed/self-hosted tooling and public standard APIs. |
| D-463 | Implemented | Indexed reads select ambient `IndexedGet<key, value>` evidence. Indexed setting uses `IndexedSet<key, value>` and is a block item rather than an assignment expression; receiver, key, and value evaluate once in that order. |
| D-464 | Implemented provisionally | `dew.std.fixed_array` uses one nominal wrapper over carrier-specialized mutable WasmGC arrays. `get` returns `Option<t>`; index get/set, `set`, `get_unchecked`, and `set_unchecked` trap out of bounds. Complete functional-dependency coherence remains pending; growable Array is implemented over the same six carriers. |
| D-465 | Implemented | Expected test traps distinguish GC `array-out-of-bounds` from linear-memory `memory-out-of-bounds`; Node and Wago normalize their current runtime messages to the stable category. |
| D-466 | Implemented provisionally | Ambient `Hash` returns U64 and includes `hash_eq` for collision identity, so every complete Hash implementation can be a Map or Set key without a separate unsupported supertrait bound. |
| D-467 | Implemented provisionally | `dew.std.map` is a mutable deterministic WasmGC separate-chaining map with sixteen initial buckets, measured load-1 geometric growth, erased unboxed key/value carrier slots, safe optional lookup, trapping index lookup, insertion/replacement, Boolean removal, alias-visible clear, membership, length, and indexed setting. Rehashing relinks entries from stored hashes without user calls; removal unlinks chain heads, middles, and tails. Iteration remains pending. |
| D-468 | Implemented provisionally | `dew.std.set` reuses the collision-safe Hash table representation, geometric growth, and exact frozen Hash evidence. It provides empty/singleton construction, length, emptiness, membership, Boolean insert/remove, and O(1) logical clear; insertion is idempotent and removal unlinks collision-chain heads, middles, and tails deterministically. Iteration remains pending. |
| D-469 | Implemented | Logical `&&` and `||` lower structurally to typed Wasm `if` expressions. The left operand executes once, the right operand executes only on the required path, and `Never`, return-containing branches, and functional-loop transfers preserve their control effects. |
| D-470 | Implemented | Match and functional-loop emission handles nested enum tuple/struct payloads, nominal struct destructuring, literals, rest/catch-all nodes, and comma-separated alternatives through an iterative pattern-emission task stack. Alternative branches share canonical binding locals and perform extraction only on the selected path. |
| D-471 | Implemented | Flow exhaustiveness consumes complete frozen imported enum domains, including imported variant payload irrefutability and field counts, so closed imported enums receive the same missing/redundant-arm behavior as local enums. |
| D-472 | Implemented | Structured-control-flow integration snapshots execute short-circuit side-effect suppression, logical return/break/continue paths, nested nominal/enum patterns, wide alternatives, deep constructor paths, and imported enum matches identically in Node and Wago Core 3. |
| D-473 | Implemented provisionally | Non-test module-level values receive deterministic Wasm globals. Direct scalar literals use immutable legal constant initializers; other values use dependency-ordered zero-argument initializer functions. Program links expose one `__dew_init` function that Dew hosts invoke exactly once before `main` or test entry points. Reference globals use nullable `eqref` storage and recover nominal types through frozen casts at use sites. |
| D-474 | Implemented provisionally | Public module-level `let` types are frozen after module-value inference, including applied generic types. Opened imports and `@alias.value` expressions resolve non-callable public values to program globals. Program initialization computes value dependencies through direct reads and the reachable callable graph, schedules dependencies first across module SCCs, and rejects remaining cycles with `EagerProgramInitializationCycle`. Host-provided initialization and richer source-labelled cycle paths remain pending. |
| D-475 | Implemented provisionally | Frozen non-foreign implementation evidence is exported only when its trait and target heads are public, imported, primitive, generic, or canonical preamble identities. Test-only, `foreign impl`, and private-head evidence is excluded together with its methods. Consumer inference merges exported methods into exact direct method/operator dispatch, and program linking preserves the source implementation-method `DeclId`. Cross-scope structural overlap diagnostics are defined by D-477. |
| D-478 | Implemented provisionally | Declaration type positions parse `fn(T, ...) -> R`, including zero parameters and nested function results. Collection lowers them iteratively into `FunctionTypeSyntax`; semantic resolution structurally interns ordered parameter and result types, traverses them through alias normalization and imported interfaces, and serializes canonical callable function types in frozen-interface cache V6. Unambiguous non-generic local/imported functions resolve as values, and calls through function-typed locals are checked structurally. Semantic lowering retains a provisional reference shape; D-479 defines executable concrete Wasm references. Lambdas, captures, and generic or overloaded function-value disambiguation remain unsupported. |
| D-479 | Implemented provisionally | Reachable concrete function types receive nullable typed Wasm references. Named non-capturing values emit `ref.func`, function-valued calls emit typed `call_ref`, function-typed locals retain the exact reference type, and declarative element segments authorize referenced functions. Program linking structurally coalesces equivalent signatures across modules while comparing nominal members by exact declaration identity. Local and imported runtime snapshots execute identically in Node and Wago Core 3. Captured closures and persistent package ABI fingerprints remain pending. |
| D-480 | Implemented syntactically | Lambda expressions use `fn(parameter: Type, ...) -> Result { ... }` with mandatory explicit types and the ordinary block grammar. `fn` commits in expression value-seeking mode, preserving one-token lookahead and forward-only cursor movement; pipe syntax is omitted because `|` is already infix. Collection assigns source-ordered lambda identities and isolates nested bodies from enclosing HIR spans while recording parent and root-body identities. Semantic capture resolution and executable closure emission remain pending. |
| D-481 | Implemented semantically | Lambda lexical resolution snapshots only bindings visible at the expression's source position. Direct captures use deterministic first-use order and retain exact body-local or parent-lambda-local identities plus mutability. Nested free variables are routed through intermediate lambdas in stable nested-lambda order. Lambda-local parameter/local/control/diagnostic spans remain isolated from root executable bodies. Signature/body inference and closure-object emission remain pending. |
| D-482 | Implemented semantically | Lambda parameter and result syntax resolves in the enclosing root declaration's generic/type scope. Alias-normalized parameter/results are structurally interned as one canonical function type per lambda. Resolved lambda signature tables are serialized through frozen-interface cache V6; V5 and older persistent artifacts are rejected and standard-interface filenames use a `v6-` prefix. Isolated lambda-body inference and closure emission remain pending. |
| D-483 | Implemented semantically | Isolated lambda bodies use fresh ordinary inference jobs after root bodies and source-ordered parent lambdas. Exact capture-source local types are imported iteratively into each fresh solver; lambda parameters/results constrain canonical signature types, nested lambda expressions have structural function types, and function-valued lambda calls select typed call targets. All inferred expression/local/capture/block/pattern/control/call and diagnostic data merges into deterministic HIR-aligned module tables. Closure construction remains an explicit backend boundary. |
| D-484 | Implemented semantically | Every lambda body receives an isolated structured-flow job over its own expression/block/pattern/arm spans. Exhaustiveness, redundant arms, functional-loop fallthrough, unreachable items, and root outcomes use the ordinary body algorithm; results merge into global HIR-aligned flow tables and deterministic lambda-owned diagnostic spans. |
| D-485 | Implemented semantically | Lambda lowering emits explicit `PlannedLambdaClosure` and `PlannedCaptureGet` operations. `PlannedLambdaLowering` preserves root type/shape, flow, local/capture ownership, and isolated expression/block/pattern/arm spans; each planned capture freezes exact lexical source identity, mutability, inferred type, and storage shape. Starshine rejects these operations until physical closure/environment planning lands. |
| D-486 | Implemented provisionally | Modules with lambdas plan one closure struct containing immutable nullable abstract-function and `eqref` environment fields. Each lambda plans a stable environment struct and capture-field relocation; compact scalar/SIMD storage is retained, references use `eqref`, and zero-width Unit/Never captures are omitted. Modules without lambdas emit no extra physical types. Environment-first entry signatures and executable closure instructions remain pending. |
| D-487 | Implemented | First-class function modules use a closure object containing an abstract function reference and nullable environment. Lambda entries use canonical environment-first signatures; construction allocates deterministic environment/closure structs, capture reads restore exact nominal casts, and calls evaluate the target once before selecting typed direct or environment-first `call_ref`. Named references use a null environment without adapter functions. Declarative elements include named and lambda entries. Node snapshots execute non-capturing, scalar/reference/function-capturing, nested, immediate, returned, passed, module-level, and imported closures. Generic/overloaded function-reference disambiguation, mutable scalar capture cells, and escape/directization optimizations remain pending. |
| D-488 | Implemented | Closure environments are flattened into the closure allocation. An open one-field base stores the abstract entry reference; each lambda uses a final subtype whose inherited prefix is the entry and whose remaining fields are deterministic captures. Lambda construction emits one `struct.new`, and the hidden `eqref` parameter points to the closure itself. Calls discriminate direct named entries from environment-first lambda entries with a concrete function-type test, preserving original named functions without adapters. Cross-module physical linking retains the closure-base supertype dependency. |
| D-489 | Implemented | A deterministic post-lowering use pass directizes immediate lambdas and immutable local function values when every local read is a call target and the binding is not captured. Named references become direct calls. Directized lambdas receive private signatures with physical captures before source parameters; call sites load exact capture sources and emit direct `call`, while construction and let initialization are elided. Returned, passed, captured, module-level, imported, or otherwise unknown uses retain the closure ABI conservatively. |
| D-490 | Implemented | Unused immutable local lambda and named-reference initializers are elided because construction has no source-visible effect. Elided lambdas retain semantic diagnostics but receive no runtime closure subtype, entry signature, function index, body emission, or declarative element. Directized lambdas likewise omit their unused physical closure subtype. |
| D-491 | Implemented | Two or more remaining references to the same named function within one body share one activation-local closure cache. The immutable base closure is constructed in the body prelude and repeated expressions emit `local.get`; one-off references remain inline, call-only references are directized, and module values retain once-per-module initialization. Cache locals follow deterministic first-reference order. |
| D-492 | Implemented | Every remaining named-function value in a linked module uses one module-representation singleton global, ordered by module and first surviving reference. `__dew_init` constructs each singleton before source module initializers, and all bodies load it with `global.get`. Separate consumer modules retain separate singleton objects until closure-base physical identities are unified program-wide. Standalone fragment emission retains activation-local caching. |
| D-493 | Implemented | Mutable lexical state is introduced only by `let mut name = value`. Simple-name assignment is a newline-delimited block item spelled `name = expression`, evaluates its right-hand side once, yields `Unit`, and may target only the exact mutable let binding or a capture sourced from it. Parameters, pattern bindings, immutable lets, module values, declarations, field targets, and other expression forms are not assignable. Compound and destructuring assignment remain omitted. |
| D-494 | Implemented | Uncaptured mutable lets remain carrier-typed Wasm locals. A mutable let captured by any lambda is promoted at binding execution to one shared final WasmGC cell with a mutable `i32`, `i64`, `f32`, `f64`, `v128`, or `eqref` field. Declaring bodies and all direct, sibling, nested, transitive, returned, and directized closures route and dereference the same cell reference. Immutable captures remain copied closure fields; directization may remove a closure but never copy or remove observably shared mutable state. |
| D-495 | Implemented | A non-generic local or imported callable overload set may become a function value only when constraints provide a fully determined structural function type. Candidates are visited in frozen binding order and filtered by exact signature unification. One viable candidate records its exact `DeclId`; zero and multiple matches produce dedicated diagnostics, and an unresolved expectation produces an expected-type-required diagnostic without unresolved-type cascades. Callable collisions across opened modules merge into one overload set, while callable/module-value collisions remain ambiguous. |
| D-496 | Implemented | When more than one linked module requires the first-class function ABI, all module-local closure-base physical plans map to the first dependency-ordered program closure base. Lambda subtypes from every module inherit that shared final type index. Surviving named references are deduplicated by exact declaration across the entire program and initialized once before source module state; standalone fragment emission retains its local base and activation cache. |
| D-497 | Implemented provisionally | Program lowering recognizes a conservative transparent callback summary: a callable whose entire result is `callback(parameter_1, ...)`, where callback is parameter zero and every remaining parameter is forwarded once in source order. The call may be the expression body, a block tail, an explicit return, or an immutable let initializer returned immediately by the next and final item. A direct call passing a known lambda or named function is rewritten to the callback target, eliminating wrapper dispatch and closure construction. Any other work, reordering, unused argument, control flow, mutable/intervening local storage, return/storage escape, or unknown callback value disables this rewrite. |
| D-498 | Implemented provisionally | Expected structural function types may instantiate generic local or imported function references, recording the inferred type arguments with the exact declaration. Program lowering executes exact parameter selectors and transparent callback wrappers directly at their call sites while retaining source argument evaluation order. |
| D-499 | Implemented provisionally | Program fragment planning closes remaining reachable generic calls and references into deterministic specializations keyed by exact declaration plus inferred physical-shape vector. Each specialization receives its own concrete Wasm signature and emitted copy of the source body; generic locals and structured result carriers are rewritten to the selected shape. Imported definitions specialize in their owner module. Escaping named references use one linked singleton per specialized function index, so distinct carrier specializations cannot alias. Persistent interface fingerprints, erased fallback adapters, generic structs, and trait-bound dictionary execution remain pending. |
| D-500 | Implemented provisionally | Generic specialization demand is closed transitively through specialized bodies. Call-site type arguments referring to an enclosing generic parameter are substituted through that specialization before selecting or creating the nested callee. Specialization identity canonicalizes source shapes to Wasm carriers (`i32`, `i64`, `f32`, `f64`, `v128`, `eqref`, or no value), so packed and scalar source types sharing one carrier reuse one function. Every materialized function records deterministic `<DeclId>:<carrier,...>` program ABI identity. Unspecialized recipes are always elided and cannot accidentally become raw Wasm exports before an erased boundary ABI exists. |
| D-501 | Implemented provisionally | Every field whose declared struct type is a generic parameter reserves deterministic `i32`, `i64`, `f32`, `f64`, `v128`, and nullable-`eqref` physical slots, matching the generic-enum payload ABI. Construction evaluates the source field once into the slot selected by its inferred carrier and initializes all other slots with deterministic zero/null defaults. Field access selects the same slot from the inferred instantiated result type. Generic struct references retain one nominal physical identity per declaration; scalar payloads remain unboxed and reference results are cast only at exact nominal consumers. |
| D-502 | Implemented provisionally | Each public generic callable owned by the linked root module materializes one all-reference specialization, keyed with `eqref` carriers, under the callable's source export name; its unspecialized recipe remains elided. If an escaping generic reference expects an exact nominal structural signature that differs from the erased specialization, the linker emits one private static-to-erased adapter for that target/signature pair. Exact GC arguments enter `eqref` parameters without allocation, erased results are cast back to the frozen nominal type, singleton closures and declarative elements reference the adapter, and physically identical scalar specializations receive no redundant closure adapter. |
| D-503 | Implemented provisionally | A demanded scalar specialization of a public root generic whose supported generic occurrences require boundary conversion receives one deterministic `<source>$dew$<carrier,...>` export adapter. Five lazily emitted immutable WasmGC boxes carry `i32`, `i64`, `f32`, `f64`, and `v128`; direct scalar adapters box arguments before invoking the all-`eqref` fallback and cast/unbox results afterward. Ordinary Dew calls and function references retain allocation-free concrete specializations. |
| D-504 | Implemented provisionally | Signature instantiation recursively substitutes generic parameters inside structural function parameter/result types. Body-local structural function terms participate in rollback-safe unification, occurs checks, zonking, compaction, module-value freezing, and function-reference selection. Generic callback bodies select carrier-correct direct and environment-first `call_ref` signatures and specialized result block types. |
| D-505 | Implemented provisionally | A direct generic field inside a struct may cross a static/erased export boundary through a boundary-only aggregate clone. Static-to-erased conversion reads the specialization-selected carrier field and boxes scalar leaves into the field's `eqref` slot; erased-to-static conversion casts/unboxes that slot into the selected carrier field and initializes every unused carrier field deterministically. |
| D-506 | Implemented provisionally | Aggregate boundary conversion descends through acyclic nested generic struct fields. Each nested object is evaluated once into a deterministic `eqref` scratch local, recursively reconstructed from converted leaves, and inserted into its parent clone. The initial nominal-cycle exclusion and pending enum/callback cases are superseded by D-510 through D-512. |
| D-507 | Implemented provisionally | Every exported frozen-interface callable carries a 256-bit lowercase hexadecimal ABI fingerprint. The V2 preimage domain-separates callable, erased-box, and flattened-closure schema versions and encodes module path, source export name, generic arity, normalized parameter/result type trees, and physical value shapes. Generic parameters use declaration-relative ordinals. Local and imported nominal/trait identities visible through the frozen import scope use stable dependency module path, declaration name, and generic arity, so independently assigned module IDs do not perturb fingerprints; unresolved identities retain an explicit raw-ID fallback. Frozen interfaces and standard-interface cache envelopes advance to V6, and V5 filenames/artifacts are never decoded as V6. Full content-sensitive nominal fingerprints and compatibility negotiation remain pending. |
| D-508 | Implemented provisionally | `tools/dew-abi.mjs` discovers deterministic `<source>$dew$<carrier,...>` function exports and invokes scalar adapters after one `__dew_init` call. Callers supply the source name, specialization carrier vector, physical parameter carriers, result carrier, and JSON arguments. `i64` uses decimal strings, floating arguments must be finite, and results are normalized as typed JSON. JavaScript-hosted `v128` and `eqref` calls reject explicitly; those boundaries require an in-Wasm package consumer. |
| D-509 | Implemented provisionally | `tools/wasm-metrics.mjs` deterministically measures encoded Wasm/printed WAT bytes, type/function/global/import/export counts, `$dew$` adapter exports, direct and reference calls, aggregate allocation sites, casts/tests, and local accesses. Optional JSON budgets accept exact/minimum/maximum non-negative integer constraints and reject unknown or malformed metrics. Full checks gate transparent closure directization at zero indirect-call/cast/test sites and bound the scalar erased generic adapter's export, box, call, cast, type/function, and size costs. Static sites are regression budgets rather than runtime timing claims. |
| D-510 | Implemented provisionally | Generic enum specialization applies the selected carrier to pattern payload loads, pattern-binding locals, tuple/struct variant construction, and function-value result casts. Static-to-erased and erased-to-static aggregate adapters dispatch through the shared enum tag, reconstruct the exact unit/tuple/struct payload subtype, box or unbox generic scalar leaves, initialize unused carrier slots deterministically, and recurse through nested struct/enum payload graphs. Adapter inputs are already evaluated into deterministic locals. |
| D-511 | Implemented provisionally | Cyclic nominal adapter graphs use private backend conversion helpers rather than finite compiler cloning. Helper discovery follows adapter, callable signature, nominal layout, variant, and field order and keys repeated instantiated declarations by adapter, exact resolved argument vector, and conversion direction. Each helper has an exact `(ref Nominal) -> (ref Nominal)` signature, reconstructs one runtime node, and calls itself or another helper only at a repeated type-graph edge. Helper types/functions append after planned/runtime types and ordinary initialization indices, preserving existing linked identities and allowing finite recursive values to terminate naturally. Runtime object cycles and sharing are not currently constructible through immutable Dew aggregate fields. |
| D-512 | Implemented provisionally | A static/erased generic boundary containing a structural callback materializes deterministic direction-specific wrapper entries and a final wrapper subtype of the linked flattened closure base. The wrapper stores the source closure once, recursively wraps callback-typed parameters/results, boxes or unboxes scalar generic leaves, tests the stored entry against the source direct signature, and dispatches with the matching direct or environment-first typed `call_ref`. Wrapper physical types, functions, and declarative-element entries append after planned functions and cyclic adapter helpers without perturbing existing declaration identities. |
| D-513 | Implemented provisionally | Recursive static/erased nominal conversion recognizes structural function types in generic struct fields and enum tuple/struct payloads. It evaluates each source field once into a deterministic `eqref` scratch local, constructs the direction-correct flattened callback wrapper, and inserts that wrapper while reconstructing the exact containing struct or variant subtype. Wrapper discovery substitutes the enclosing aggregate's actual type arguments, and missing concrete/erased callback signatures are synthesized and deduplicated deterministically in the type section. |
| D-514 | Implemented provisionally | An unresolved function-value call is not diagnosed until member inference and function-reference selection have had an opportunity to determine its target. Calls sourced from instantiated generic aggregate fields and enum pattern bindings therefore retain their concrete structural body type. Lowering structurally matches a frozen `BodyFunctionType`, including nested function/applied parameters, against the resolved type arena and records the exact resolved function type required by typed `call_ref` emission. |
| D-515 | Implemented provisionally | An in-Wasm ABI consumer imports provider exports under the `dew` namespace after the host invokes provider `__dew_init` exactly once. The focused callback-aggregate consumer declares structurally equivalent generic-box and flattened-closure types, constructs a direct `i32` callback, invokes `identity_box$dew$i32`, and dispatches the returned wrapper inside Wasm. The JavaScript harness accepts only a declared scalar result carrier and never transports `eqref` or closure objects across the host boundary. |
| D-516 | Implemented provisionally | The in-Wasm enum callback consumer declares a structurally equivalent open enum base and final tuple subtype, constructs the tuple tag and direct callback, invokes `identity_choice$dew$i32`, casts the returned base reference to the exact tuple subtype, and dispatches its reconstructed callback wrapper. Enum values, subtype casts, and closure references remain entirely within Wasm; the host observes only the final `i32` result. |
| D-517 | Implemented provisionally | The standalone reference consumer constructs an exact nominal WasmGC struct, passes it to a public all-reference generic fallback with `(eqref) -> eqref`, casts the returned value to its exact structural type, and reads its scalar field. Provider initialization still occurs exactly once before consumer instantiation, and the JavaScript host never creates, receives, or interprets the reference value. |
| D-518 | Implemented provisionally | The in-Wasm vector consumer constructs a `v128`, invokes the deterministic `identity$dew$v128` adapter, and extracts a scalar lane from the returned vector. The adapter's immutable vector box, all-reference fallback call, cast, and unbox execute entirely inside Wasm because the JavaScript WebAssembly API cannot supply or receive `v128` values directly. |
| D-519 | Implemented provisionally | A multi-module provider may expose a root-owned `$dew$<carrier,...>` adapter whose nominal aggregate type is declared in an imported module. A structurally equivalent Wasm consumer imports that adapter exactly as it imports the single-module form, proving that final linked type canonicalization and exported callable identity do not depend on source-module ownership. Persistent external package compatibility still requires dependency-interface fingerprints and integrity metadata. |
| D-520 | Implemented provisionally | The deterministic imported-package budget requires exactly one root-owned adapter export over the imported callback aggregate and bounds linked type/function count, direct calls, aggregate/string allocation sites, casts, and binary/text size. The same full-check tranche links the structurally equivalent Wasm consumer and requires a scalar result of `42`, so static compactness and executable package-boundary compatibility regress visibly together. |
| D-521 | Implemented provisionally | Dedicated enum and cyclic-adapter budgets gate recursive representation costs independently. The enum budget covers tuple, struct, nested-struct, and nested-enum subtype reconstruction. The cyclic budget requires the expected direct helper-call count, zero `call_ref`/`ref.test`, and bounded helper signatures, reconstruction sites, casts, and output size. |
| D-522 | Implemented provisionally | Dedicated nested-aggregate and mutable-cell budgets separate two remaining static-cost classes. The nested adapter budget requires one export and zero indirect dispatch while bounding clone/cast sites. The mutable fixture budget preserves its expected closure/cell dispatch profile—ten `call_ref` and five `ref.test` sites—while bounding allocations, casts, locals, functions/types, and output size. |
| D-523 | Implemented provisionally | Every CLI-built production Wasm module contains exactly one `dew.metrics` custom section. The V1 payload is `DWM1` followed by a little-endian unsigned 32-bit materialized-specialization count. The count includes executable concrete and erased-fallback generic bodies while excluding boundary/reference adapters, elided recipes, and functions without executable indices. Static budgets consume this metadata directly and reject absent, duplicate, malformed, or unsupported sections. |
| D-524 | Implemented provisionally | Exported callables use V3 SHA-256 ABI fingerprints, public nominal declarations use V2 fingerprints, and module content uses the V2 domain. Every fingerprint includes stable symbolic identities plus each generic parameter's ordered trait bounds; exported implementation records additionally encode owner-relative generic bounds before trait and target types. Every frozen module receives a cycle-safe transitive interface fingerprint over the deterministic reachable module-path/content graph. Direct dependency content records and all fingerprints persist in frozen-interface/cache V11; independently assigned module and declaration IDs do not affect them. |
| D-525 | Implemented provisionally | Every CLI-built production module contains exactly one `dew.abi` section with `DWA1`, language/closure/generic-carrier/box/callback-wrapper schema versions, root module path, transitive interface fingerprint, and direct dependency content records. Dew ABI tools reject missing, duplicate, malformed, unsupported, wrong-path, or mismatched-fingerprint providers before instantiation. The imported-package consumer snapshots the expected provider record and includes a fail-visible incompatible-fingerprint regression. |
| D-526 | Superseded in package syntax by D-527 | Versioned external packages, integrity/interface validation, deterministic dependency ordering, and V11 dependency-interface cache behavior remain implemented. Resolution records moved out of the package definition into `dew.lock`. |
| D-527 | Implemented provisionally | `dew.json` contains only `@scope/name`, an exact package semantic version, and an optional dependency-request object. Requests accept exact, `^`, `~`, or `*` semantic versions and Git URLs. The root `dew.lock` contains the complete transitive exact resolution as version, source, materialized relative path, package-integrity V2 digest, and expected interface fingerprint records. One Dew module is derived from each package name by `@` removal, `/` to `.`, and `-` to `_`; source ownership is sorted recursive `src/**/*.dew`, or sorted immediate sibling `*.dew` when `src/` is absent. Production excludes `_test.dew`; package tests include it. `tools/dew` discovers `dew.json` from the invocation directory, while explicit multi-module compiler graphs use `dew.modules.json`. |
| D-528 | Implemented provisionally | Ambient `Debug` streams deterministic output to stdout through ordinary coherent trait methods. Generic and non-generic derived structs/enums recurse in source field/payload order through prerequisite-aware static evidence specialization; Bool and all fixed-width integers have built-in evidence, with integer formatting using one bounded linear-memory scratch range and exact decimal handling for signed minima and unsigned maxima. |
| D-529 | Implemented provisionally | Primitive Debug also covers Unit, F32, F64, String, and Bytes. Floating-point output is an exact lowercase IEEE bit form that preserves signed zero and NaN payloads. String writes quoted valid UTF-8 with deterministic ASCII escaping; Bytes writes a quoted byte literal with printable ASCII preserved and every other byte rendered as lowercase `\\xNN`. Both stream through bounded scratch and partial-write-safe WASI calls without allocation. |
| D-530 | Implemented | `Debug.debug` and ambient `debug(value)` return Unit. Runtime formatters may internally return byte counts for bounded-write loops, but ordinary generated and primitive implementations consume those counts through one inline drop builtin rather than exposing the final segment's count as unstable user semantics. |
| D-531 | Implemented provisionally | Packed ambient primitives have deterministic Debug forms: Swar32 and Swar64 expose exact unsigned carrier bits in decimal wrappers, while V128 emits one high-lane-first 128-bit lowercase hexadecimal wrapper. Typed lane values still require type-specific formatting in their owning standard modules. |
| D-532 | Implemented provisionally | A local or imported generic implementation may satisfy method, operator, indexing, collection, or generic-call evidence only when every ordered bound on its inferred owner type arguments is recursively satisfied by visible coherent evidence. Imported implementation owner spans and prerequisites survive private cache V11, imported implementations are rebuilt into consumer trait-obligation buckets, and prerequisite traversal has a fixed depth bound of 64. |
| D-533 | Implemented provisionally | A generic body assigns each source-ordered declared bound a symbolic evidence slot. Operators and instance methods on rigid generic parameters select the matching local or imported trait requirement, instantiate `Self` and applied trait arguments, and retain a dedicated symbolic inferred/lowered call target. Generic calls and generic implementation prerequisites may consume matching body bounds transitively. Trait requirements remain signature-only and are never emitted as ordinary direct calls. |
| D-534 | Implemented provisionally | Every generic call freezes its ordered obligations as a recursive evidence forest. A node is either a concrete coherent implementation with ordered prerequisite children and owner specialization arguments, or a reference to one of the caller's source-ordered bound slots. Concrete owner arguments retain either an exact physical carrier or the enclosing generic-parameter ordinal, avoiding invalid snapshot-local inference IDs while preserving the information needed for transitive specialization. Generic implementation method/operator selection freezes its prerequisite forest on the expression, and lowering carries the same deterministic arenas unchanged. |
| D-535 | Implemented provisionally | Closed generic specialization resolves caller-bound evidence recursively and includes the resulting concrete implementation identity, owner carriers, and prerequisite tree in the specialization ABI key. Equal physical carriers with different selected evidence do not coalesce. Every specialized call expression records its exact target specialization. A symbolic bound method/operator call maps its signature-only requirement to the selected implementation's ordinary method, specializes that method with the evidence node's owner carriers, and forwards the node's prerequisite children as method evidence; signature-only requirements are never emitted directly. Dynamic/open trait boundaries remain dictionary work. |
| D-536 | Implemented provisionally | Generic `derive(Eq)` synthesizes ordinary conditional Eq and Ne implementations over the applied nominal type. Every generated owner parameter referenced by a field or variant payload type preserves its source bounds and gains one Eq prerequisite unless already present; phantom parameters remain unconstrained. Concrete stored types are checked by ordinary generated-body method selection. Field and payload comparisons use symbolic owner-bound evidence inside the generated body; closed concrete uses execute through D-535, nested generic derived values forward prerequisites transitively, and concrete arguments without Eq evidence fail ordinary method selection. |
| D-537 | Implemented provisionally | `derive(Debug)` and `derive(Hash)` use the same field/payload prerequisite rule as D-536. Generic Debug recursively emits the concrete source-ordered values rather than shape placeholders, and ambient debug dispatch may select caller-bound symbolic evidence before concrete candidates. Derived Hash starts from the U64 FNV offset basis, mixes the zero-based enum variant ordinal and every payload hash in source order with the FNV prime, and implements collision-safe structural `hash_eq` through each stored value's Hash evidence. Generated methods remain ordinary coherent implementations and missing concrete evidence is diagnosed at the exact derive request. |
| D-538 | Implemented provisionally | Derived Eq/Ne, Debug, and Hash implementations have exactly the coherence and evidence-visibility status of handwritten implementations. Overlaps mark both sides incoherent and retain derive-site plus handwritten source labels in either declaration order. Public generated methods and ordered prerequisites survive frozen-interface/cache round trips; private nominal heads export none. Imported generic derived methods execute as provider-owned specializations, with a targeted cross-module nominal `ref.cast` only when a consumer local, capture, module value, field, or control-flow join uses the common `eqref` carrier for an exact provider parameter. Generic bounds participate in callable, nominal, implementation, and transitive interface fingerprints. |
| D-539 | Implemented provisionally | A bare trait in a value position denotes an erased runtime trait type. Assignability at an expected trait boundary preserves the concrete source type and freezes exact visible coherent evidence; unresolved sources defer selection until ordinary constraints settle. Calls on trait receivers freeze exact trait, requirement, source-order slot, and type arguments. Each demanded object-safe trait receives method-signature types followed by an immutable typed-funcref vtable and `{ receiver: eqref, vtable }` object. Each exact implementation/evidence combination receives source-ordered erased-receiver adapters and one private dictionary global initialized once by startup with declarative `ref.func` entries. Consumer planning reconstructs imported trait requirements from frozen callable metadata and preserves provider implementation-method and receiver identities; linking maps their casts and calls to final provider type/function indices. Trait-object construction loads that dictionary, and dynamic calls evaluate the object once before typed-field `call_ref`; concrete calls retain the allocation-free direct path. Methods with method generics or `Self` outside the receiver are not dynamically callable. |
| D-540 | Implemented provisionally | Scalar, packed, and SIMD receivers cross erased trait boundaries through one immutable snapshot box selected by canonical Wasm carrier (`i32`, `i64`, `f32`, `f64`, or `v128`). Adapters cast and load the box before direct implementation calls. Static scalar calls remain unboxed. A box is owned by the trait value and never aliases or writes back to its conversion source; future mutable receiver syntax may mutate only that box. Trait-object identity is not ambiently observable, repeated conversions need not preserve envelope identity, shared dictionary identity does not imply value identity, and universal erased equality is absent unless an explicitly object-safe operation defines it. |
| D-541 | Implemented provisionally | A closed concrete trait boundary selecting a generic implementation materializes one dictionary per recursive evidence key. The key includes owner carriers and ordered prerequisite implementation trees; its adapter calls the exact evidence-aware implementation-method specialization, including provider-owned specializations for imported implementations. Equal physical receiver carriers with different prerequisites do not coalesce. Transparent forwarding wrappers preserve argument evaluation and are directized when exact evidence proves the call. |
| D-542 | Implemented | An ordinary trait implementation is accepted only when the declaring package owns either the trait or the normalized nominal target head; `dew.std` owns primitive targets and its reserved modules form one ownership domain. Package-less explicit graph modules are separate ownership domains. Third-party combinations require `foreign impl`, whose evidence remains exact-module-private and is never frozen or imported. `OrphanTraitImpl` labels the implementation plus available foreign trait/type declarations, invalid evidence is removed before coherence and dispatch, interface freezing rechecks ownership, and private cache V11 rejects serialized orphan evidence. Local implementation methods over imported nominal targets restore the exact provider reference before direct calls. |
| D-543 | Implemented provisionally | Runtime-trait flow analysis classifies values as pending, unknown/escaping, exact evidence, or forwarded parameters. Exact evidence propagates through safe locals, blocks, same-evidence branches, transparent returns, and effect-free forwarding chains. Closed recursive prerequisites are transferred to ordinary implementation-method specialization. Non-captured locals whose complete use/assignment set remains exact are rewritten to their concrete carrier; dead private wrappers and all unneeded runtime dispatch artifacts are omitted. Differing evidence, captures, public ABI entry points, and potentially effectful wrapper evaluation remain dynamic. |
| D-544 | Implemented provisionally | Symbolic trait coercions in a generic body are resolved through each caller specialization's ordered evidence forest. A transparent tail or sole explicit-return parameter selector becomes a parameter selection and can eliminate all runtime artifacts. A genuinely dynamic branch materializes the exact dictionary, recursive prerequisites, generic implementation-method specialization, adapter, startup global, and typed `call_ref`. Imported public generic providers use the same linked specialization path. Method-signature, vtable, and object physical types demanded in multiple modules are canonicalized by requirement/trait declaration identity. |
| D-545 | Implemented provisionally | A public root generic whose symbolic bounds are used by erased trait coercions or direct bound methods/operators exports an all-reference fallback with one trailing `eqref` evidence parameter per flattened source bound. Specialization evidence records the trait plus absolute hidden-parameter index. Trait coercions cast that parameter to the exact vtable and construct the object without selecting provider-local evidence; bound calls load the matching typed method reference and use `call_ref` without an intermediate object. Direct evidence forwards through private, recursive, and imported generic call chains: each callee compacts runtime evidence into contiguous trailing slots, while each call record retains caller-local source indices and appends them after visible argument evaluation. Context-sensitive evidence classification also permits recursively nested statically selected concrete generic implementations and forwards the complete ordered prerequisite tree through exact implementation-method specializations. Direct-child spans are recorded only after recursively copied descendants, preserving every evidence-tree level. Generic function references retain their target obligation evidence; concrete and caller-runtime-evidence bounded references execute through exact evidence-aware specializations and the common closure ABI. Concrete erased coercions may retain caller-local prerequisite evidence through immutable receiver captures. A structurally typed external Wasm consumer supplies its own receiver and `ref.func` implementation and exercises direct static, prerequisite-bearing static, and erased paths through a multi-module provider. Callable fingerprints use V4 with the runtime-evidence V1 marker, and `dew.abi` language compatibility is version 2. |
| D-546 | Implemented provisionally | A bounded generic function reference inside a caller specialization records its frozen expression evidence, exact target specialization identity, caller body/specialization identity, and ordered caller-local runtime dictionary indices. The backend emits a final subtype of the linked closure base containing an environment-first trampoline plus immutable `eqref` evidence fields. Construction preserves source-bound order; the trampoline loads visible callback arguments before captured evidence and directly calls the exact local or imported target specialization. Closed generic callers use zero-capture evidence trampolines so carrier-equivalent but evidence-distinct targets never merge. The structural callback ABI is unchanged. Same-module/imported Node and Wago snapshots and a core-Wasm external consumer execute returned closures carrying consumer-owned vtables. |
| D-547 | Implemented provisionally | An erased concrete implementation whose recursive prerequisite tree contains caller-runtime evidence retains the V1 method-only vtable ABI. Link planning normalizes the runtime leaves into source-ordered caller parameter indices, materializes the exact implementation-method specialization, and marks unresolved generic dictionaries as non-runtime templates. Coercion allocates one immutable capture struct containing the already boxed/reference receiver followed by the demanded dictionaries, then stores that capture in the ordinary trait object's receiver field. The dictionary adapter restores the exact receiver, evaluates ordinary dynamic-call arguments, loads captured evidence fields, and directly calls the exact local or imported specialization. One- and two-dictionary external Wasm paths, recursively nested prerequisites, reversed module planning, malformed spans, and Node/Wago snapshots are covered. |
| D-548 | Implemented provisionally | Before callback and runtime-trait directization, program lowering computes a deterministic fixed point of total/discardable callable summaries across local and imported declarations. Only constants, local/capture reads, total control-flow joins, parameter selection, and calls whose callee and complete argument trees are already summarized qualify; recursion, traps, mutation, dynamic dispatch, callback invocation, and unknown operations do not. Callback escape summaries follow immutable aliases and transitive forwarding wrappers. Exact internal calls through public APIs may discard summarized preludes and directize, while the public fallback body and ABI remain emitted. Returned, captured, conditionally or multiply invoked callbacks, differing trait evidence, and unsummarized effects retain dynamic representations. A depth-256 reverse-chain benchmark, trapping counterexamples, imported Node/Wago execution, and WAT allocation/dispatch contracts are covered. |
| D-549 | Implemented | `dew clean` idempotently removes the complete configured interface/package cache, while `--dry-run` reports the exact target without mutation. Dangerous filesystem, home, project, and working-directory roots are rejected. A cache symlink is unlinked without following its target; a regular file at the cache path is removable corrupt cache state. |
| D-550 | Implemented provisionally | Effect-safe common-subexpression elimination initially targets repeated scalar field extraction from one immutable direct local after an immutable lexical `let` has stored the value. Later direct extractions read that local; duplicate uncaptured immutable aliases are elided and uses are retargeted. Adjacent operands gain no scratch local because the measured `local.tee` form regressed the Node hot path. Mutable bases, captured aliases, references, generic carriers, Unit/Never, calls, allocation, collection reads, and uncertain cross-block flow remain excluded. |
| D-551 | Implemented provisionally | A supported scalar field projection from fresh struct construction is rewritten to `PlannedParameterSelect` over every source-ordered field initializer. The same rewrite applies to an immutable uncaptured local with one later direct field read in the same block. Adjacent use always qualifies; a lexical gap qualifies only when all constructor initializers and intervening expressions are total/discardable. The declaration and local read are elided from copied lowering arenas. Narrow storage, reference/generic fields, trait-coerced bases, variants, mutable/captured locals, multiple/cross-block uses, effectful gaps, and escaping values remain unchanged. |
| D-552 | Implemented | Unit implements non-ambient `Show` with the exact text `()`. Generic specializations whose visible Unit parameters have no Wasm carrier compute all subsequent local indices from specialized shapes; Unit local reads and writes emit no physical access while preserving their value-expression evaluation. |
| D-553 | Implemented provisionally | Successful `dew build` Wasm, HIR, and lowering outputs publish one atomic V1 `.dba` envelope keyed by normalized output-independent arguments, explicit source contents, custom standard roots, compiler/standard source contents, dependency-interface state, emit mode, and relevant package environment. Compiler/workspace dependency content hashes may be reused only while exact path/size/mtime/ctime manifests match. Hits verify key, kind, size, and SHA-256 before atomically restoring the requested destination. Corrupt entries fail visibly, failed builds are not cached, `--no-build-cache` bypasses reuse, `--cache-report` reports deterministic keys, and `dew clean` removes all build artifacts. WAT conversion, per-file syntax/HIR caching, transitive workspace invalidation, and parallel scheduling remain separate. |
| D-554 | Implemented | `string_comparator()`, `string_view_comparator()`, and `bytes_comparator()` return explicit non-ambient comparator evidence. Comparison is allocation-free unsigned lexicographic order over logical bytes: first mismatch wins, a shorter prefix is less, and equal length/content is equal. StringView honors offsets without copying; valid UTF-8 byte order preserves scalar order, while Bytes orders arbitrary payloads without interpretation. |
| D-555 | Implemented | `dew.std.text` provides String and StringView code-point iterators implementing ambient `Iter<U32>`. Construction retains the logical source range and a shared scalar cursor without copying text; successful `next()` decodes one shortest-form Unicode scalar and allocates nothing. Exhaustion, stray continuations, overlong sequences, surrogates, values above U+10FFFF, and truncated StringView ranges trap deterministically. Iterator aliases share advancement. |
| D-556 | Implemented | An immutable uncaptured local initialized by a fresh struct is scalar-replaced when every use is a direct read of the same supported scalar field. The existing local changes to that scalar carrier; every constructor initializer remains evaluated once at the original declaration in source order, repeated field reads become local reads, and the aggregate allocation/loads disappear. Mixed fields, mutable/captured locals, trait coercions, narrow/reference/generic fields, and non-field uses remain allocated. |
| D-557 | Implemented | A fresh immutable struct local followed immediately by one immutable direct field alias per constructor field is scalar-replaced when aliases occur in constructor order and every field has a supported scalar carrier. The aggregate declaration is elided, each existing alias local receives the corresponding initializer at the same source-order boundary, and aggregate construction/access disappears. Reordered, missing, repeated, captured aggregate, narrow/reference/generic, or non-field uses remain allocated. |
| D-558 | Implemented | An immutable uncaptured sole-use struct local initialized by an `if` is scalar-replaced when every reachable branch recursively ends in a fresh struct providing the same supported scalar field. Each branch constructor becomes a source-ordered scalar selector, block/if result carriers and the existing local become scalar, and the final field read becomes a local read. Branch selection and all selected-branch initializer effects remain unchanged; any non-fresh branch rejects the rewrite. |
| D-559 | Implemented | Immediate or adjacent sole-use projection from a fresh single-field struct may eliminate the wrapper for reference and erased-generic carriers. The exact initializer value is forwarded once without changing child identity; the wrapper cannot escape or expose identity. Multi-field references, captures, coercions, calls, repeated reference uses, narrow fields, and other escaping forms remain allocated. |
| D-560 | Implemented | A match whose scrutinee is a fresh tuple variant is payload-replaced when the first unguarded arm matches that exact constructor and its body directly returns one top-level binding. The variant constructor and match dispatch are replaced by a source-ordered parameter selector, so every payload argument evaluates once while the selected scalar/reference/generic payload is forwarded without enum allocation. Other arm orders, guards, nested patterns, struct variants, and escaping scrutinees remain unchanged. |
| D-561 | Implemented | Exact nonescaping trait-object flow through immutable locals and transparent forwarding rewrites erased values to their concrete carrier and dynamic calls to exact implementation methods. When the complete demanded flow remains exact, no trait envelope, scalar/SIMD box, dictionary, adapter, global, `ref.func`, or `call_ref` is emitted. Captures, conflicting evidence joins, unknown assignments/calls, and externally demanded dynamic fallback bodies retain ordinary trait-object representation. |
| D-477 | Implemented | Consumer coherence compares every newly imported trait implementation against local and earlier imported evidence in the shared resolved-type arena. Exact, generic, strictly specialized, and incomparable patterns use the same unification rules as local coherence; incoherent entries are removed from method and qualified-trait dispatch. `check`, test generation, snapshot generation, and benchmark generation report implementation-index diagnostics directly. |
| D-476 | Implemented | Reachable nominal roots close transitively through local and imported struct/enum payload types before fragment planning. When an external physical reference would otherwise point forward, the linker computes deterministic program-wide physical SCCs, assigns a final index to every module-local physical type, emits each SCC as one Wasm recursive group, and places callable signatures afterward. References inside shared groups use their final type-section indices because Starshine's relative recursive-index form is intentionally not binary-encodable. Acyclic links retain the existing module-local type order and snapshots. |
| D-478 | Implemented provisionally | Every source-verified locked dependency publishes one content-addressed V1 installed package capsule keyed by exact package identity, version, source, package-integrity V2 digest, expected transitive interface fingerprint, and derived module path. The capsule commits to sorted dependency requests and ordered conventional `.dew` payloads through a canonical envelope checksum plus per-file SHA-256 digests. If the locked package tree is absent, the CLI rejects corrupt, mismatched, unordered, duplicate, or unsafe payloads, recomputes package integrity, stages the complete package beside its destination, and atomically restores it at the original locked path. Existing frozen-interface injection and ordinary body/link planning then produce byte-identical Wasm; nonempty partial destinations are never overwritten. |

## 11. Question history

| Question | Status | Resolution |
|---|---|---|
| Q-001 | Answered | Read a raw file descriptor page-by-page through a custom streaming UTF-8 code point iterator. Identifier character rules remain Q-013. |
| Q-002 | Answered | Do not retain the source file; reconstruct diagnostic text from stringified tokens. |
| Q-003 | Answered | Tokens contain decoded values. |
| Q-004 | Answered | Emit recoverable `Error` tokens and accumulate errors through the rest of parsing. |
| Q-005 | Refined | Target exactly one lookahead token, but do not preserve ambiguous alternatives; the grammar must select one deterministic production. |
| Q-006 | Superseded | The dual-iterator answer was replaced by the single `Iter[ParseEvent]` decision in Q-018. |
| Q-007 | Answered | Recover by discarding tokens, with nested contexts tracked during synchronization. |
| Q-008 | Answered | The outer parser iterator emits `Declaration` values, not nested executable statements. |
| Q-009 | Answered | Type variables use `snake_case`. Named types additionally use `PascalCase`. |
| Q-010 | Answered | The repeated method-level `<t>` was a mistake and is removed. |
| Q-011 | Refined | The corrected `fn into(self) -> I32` form is retained. `self` denotes the receiver; its physical representation follows the receiver type under Q-022. |
| Q-012 | Partially answered | All three call forms are legal. Runtime dispatch is settled by Q-023; source-level lookup precedence remains Q-039. |
| Q-013 | Answered | Unicode identifiers are permitted. Detailed Unicode classification remains Q-029. |
| Q-014 | Answered | Use raw file descriptors as directly as possible to reduce overhead and memory usage. |
| Q-015 | Provisional | Use the host operating-system page size, pending measurement. |
| Q-016 | Answered | Store each decoded identifier as a MoonBit `String`. |
| Q-017 | Answered | `Source` stores line-break positions and an active token array. `Offset` is a UTF-8 byte offset and `Index` indexes that array. |
| Q-018 | Answered by design choice | Use one `Iter[ParseEvent]`. Interleaving declarations and diagnostics avoids buffering caused by independently consumed lazy iterators. |
| Q-019 | Answered | Diagnostic levels are `Error`, `Warning`, `Info`, and `Hint`. Lexical severity conversion remains Q-030. |
| Q-020 | Answered | Do not admit ambiguous syntax. Declarations start with keywords and expressions use shunting-yard parsing. |
| Q-021 | Answered | Recovery may fill in obvious missing syntax and produce error AST nodes for partial compilation and language-server information. |
| Q-022 | Answered | Avoid boxing: primitives remain Wasm scalars while aggregate and recursive types use WasmGC recursive types. Avoid broad monomorphization. |
| Q-023 | Answered by design choice | Emit direct calls when the implementation is statically known. Dynamic trait objects use typed function references in WasmGC dictionaries and `call_ref`; `br_table` is reserved for measured optimization. |
| Q-024 | Partially implemented | Impl coherence and method selection now use structural disjointness and strict specificity. Ordinary function-overload selection still uses provisional declared-generic-count tiers rather than complete generic match-set containment. |
| Q-025 | Refined and implemented | `self` must be first; both `self` and `self: Self` are accepted and normalize to one receiver form. Its presence distinguishes instance methods from static methods. |
| Q-026 | Answered | `Offset` is a UTF-8 byte offset. `Index` indexes the active token array and is invalid after eviction. |
| Q-027 | Answered | Tokens may be evicted once source text needed for diagnostics can be regenerated from AST nodes. |
| Q-036 | Answered and implemented | Impl coherence uses structural overlap plus directional pattern matching: strict containment is ranked, disjoint patterns coexist, and equivalent or incomparable overlaps are rejected. |
| Q-037 | Answered | Permit module-local orphan implementations with the explicit `foreign impl` syntax. |
| Q-038 | Answered | Scalars are boxed when explicitly treated as erased runtime `Trait` objects; direct/static and ABI-specialized generic calls keep them unboxed. |
| Q-040 | Answered | A foreign impl is considered only in its exact declaring module and cannot be imported or re-exported. |
| Q-041 | Answered | Foreign impls in different modules do not conflict globally because they cannot be imported into a shared scope. |
| Q-042 | Answered | Foreign impl evidence is private: a public body may use it internally, but a public signature cannot expose or require it. |
| Q-047 | Answered | Use WTF-8 plus lossless tagged sentinels above U+10FFFF rather than replacing malformed bytes with U+FFFD. Sentinels are allowed in string literals. |
| Q-048 | Answered | The tokenizer owns one reusable page-sized buffer that is rewritten from the file descriptor throughout the cursor's lifetime. |
| Q-065 | Revised | A builtin registry key must use a standard double-quoted string literal. Exact matching is performed by an extensible compiler registry that supports custom builtins. |
| Q-066 | Answered | Every builtin requires an explicit return type, including `-> Unit`. |
| Q-067 | Answered | One trailing comma is accepted in generic and value parameter lists. |
| Q-068 | Answered and implemented | Applied types use `Type<arguments>` recursively. In type context, a `>>` token closes two nested applications. |
| Q-069 | Provisionally answered | Generic builtin bounds are not supported initially, but the decision may be reopened if needed. |
| Q-070 | Answered and implemented | Dew-visible builtin names may be overloaded; rollback-based body inference selects one candidate or diagnoses no-match and ambiguity. |
| Q-071 | Partially answered | Generic arguments may be inferred or explicit. Explicit call-site syntax remains open. |
| Q-072 | Answered | Registry names do not define one canonical signature; the compiler instead guards each expansion's result against the instantiated declared return type. |
| Q-073 | Answered | End of input acts as an implicit final newline for declaration termination. |
| Q-074 | Answered | Newlines are ignored while an expression is syntactically incomplete, including unary-value-seeking mode. |
| Q-075 | Answered | Newlines are accepted after commas. |
| Q-076 | Answered | Inline object fields are newline-delimited and each non-empty field requires its own terminating newline. |
| Q-081 | Answered and implemented | `self` may be the first parameter of an ordinary function, turning that function into a method. |
| Q-082 | Answered and implemented | The final expression item is the block value and provides callable fallthrough; earlier expression values may be evaluated and discarded. |
| Q-083 | Answered and implemented | Bare `return` supplies `Unit` and is valid only when `Unit` is assignable to the declared callable return type. |
| Q-084 | Provisionally answered and implemented | Shorthand `self` requires a containing trait or impl `Self` context. A top-level receiver currently must write an explicit concrete receiver type. |
| Q-085 | Answered and implemented | Struct fields are newline-delimited, require a final newline before `}`, and do not use comma separators. |
| Q-090 | Answered and implemented | Enum variants are newline-delimited and have unit, tuple-like, or struct-like forms selected by the token following the variant name. |
| Q-091 | Answered and implemented | A zero-payload variant uses the unit spelling `Name`; `Name()` is rejected, while `Name {}` remains a legal empty struct-like variant. |
| Q-096 | Answered and implemented | `::` is parsed in binary-seeking mode as a right-unary property qualification and leaves the parser in binary-seeking mode for calls and further accesses. |
| Q-097 | Answered and implemented | Module parsing uses one lazy event iterator that interleaves successful declarations and error-severity parser diagnostics. |
| Q-099 | Answered and implemented | An ungrouped left brace terminates a control-flow condition; parenthesized constructor expressions remain valid conditions. |
| Q-100 | Answered | `else` is mandatory when an if is used as a value. An if without else has type Unit. |
| Q-101 | Answered | A no-else if branch receives an implicit Unit result when it does not explicitly produce Unit; preceding values are discarded. |
| Q-102 | Answered and implemented | Optional else remains compatible with one-token lookahead by requiring `else` on the same physical line as the preceding closing brace. |
| Q-103 | Answered and implemented | Match arms use `pattern => body`, are newline-delimited, and may contain an expression or reusable block body. |
| Q-104 | Answered and implemented | Patterns are parsed separately from expressions and initially support wildcard, binding, literal, qualification, tuple payloads, and struct payloads. |
| Q-105 | Answered and implemented | A direct brace after a match arrow is a block; an object result is parenthesized to keep one-token parsing deterministic. |
| Q-106 | Answered and implemented | Match guards use `if`; the guard is parsed after all comma-separated alternatives and before `=>`. |
| Q-107 | Answered and implemented | A match arm may contain comma-separated alternative patterns sharing one guard and body. |
| Q-108 | Answered and implemented | Alternative patterns bind identical variable-name sets, corresponding occurrences share one `LocalId`, and payload inference unifies their types. |
| Q-109 | Answered and implemented | Bare `...` denotes one rest item inside tuple-like and struct-like pattern payloads. |
| Q-110 | Answered and implemented | Pattern bindings cannot be mutable. Mutation requires an explicit `let mut` rebinding after the pattern has matched. |
| Q-111 | Answered and implemented | `_` and every underscore-prefixed identifier in a pattern-binding position discard the matched value rather than introducing a binding. |
| Q-112 | Answered and implemented | `while initial { pattern arms }` is a functional state loop whose arms share match-pattern syntax. |
| Q-113 | Answered and implemented | `continue next` updates the functional-loop state, and `break result` determines the loop expression's value. |
| Q-114 | Answered and implemented | Functional-loop state/result constraints, guard-aware constructor coverage, and structural arm transfer summaries are implemented; refutable nested pattern-matrix usefulness remains a later refinement. |
| Q-115 | Answered and implemented | Failed declarations report private failure-only delimiter frames so module synchronization can skip nested members without enlarging `Parser`. |
| Q-116 | Answered and implemented | Recovery preserves existing public diagnostics, emits one diagnostic per failed declaration, and conservatively reaches EOF when an enclosing delimiter remains open. |

## 12. Open questions

### Batch 5: coherence, trait objects, operators, and partial compilation

- **Q-028 — Descriptor read strategy:** Should pages be loaded with repeated `read` calls, memory mapping, or another direct mechanism? Should release builds benchmark one page against multi-page buffers before fixing this policy?
- **Q-029 — Unicode identifier rules:** Should Dew follow Unicode `XID_Start`/`XID_Continue`-style classes? Should identifiers be normalized, such as NFC, and should visually confusable names be diagnosed?
- **Q-030 — Lexical diagnostic severity:** Is a lexer-produced `Error` token always an `Error`, or may parser context reinterpret it as a `Warning`, `Info`, or `Hint`?
- **Q-031 — Operator model:** Which operators exist initially, what are their precedence and associativity levels, and may users declare custom operators?
- **Q-032 — Synthetic syntax:** Must every synthetic token and error AST node be explicitly marked as synthetic? May later lowering proceed through these nodes, or must code generation stop at any declaration containing one?
- **Q-033 — Generic ABI shapes:** Which primitive ABI shapes receive shared specializations: one each for `i32`, `i64`, `f32`, `f64`, `v128`, and GC references, or a smaller initial set? May hot code request additional specialization?
- **Q-034 — Wasm recursive groups:** Should each Dew type form its own Wasm recursive group where possible, or should mutually dependent module/package types be emitted in shared recursive groups?
- **Q-035 — Diagnostic regeneration:** What minimum information must AST nodes retain to regenerate useful source text after token eviction? How are diagnostics for malformed input represented when no complete AST node can be built?
- **Q-039 — Source-level method ambiguity:** If an inherent method and one or more trait methods share a name, does `value.method(...)` always select the inherent method? If two traits match, must the programmer use `Trait::method(value, ...)`?
- **Q-043 — Mutable boxed scalar receivers:** If a mutable trait method changes a boxed scalar receiver, does it mutate only the boxed trait-object value, or must changes be written back to an originating scalar variable when one exists?
- **Q-044 — Trait-object identity:** Is reference identity observable for trait objects? Should two separately boxed copies of the same scalar ever compare equal by identity, or must equality always be provided by a trait/value operation?
- **Q-045 — Erasure syntax:** Is conversion from a concrete value to runtime `Trait` implicit when required by context, or must the programmer write an explicit cast/construction so scalar allocation is visible in source?
- **Q-046 — Directization guarantee:** Is eliminating a non-escaping scalar trait-object box merely an optimization, or should the language define constructs where boxing is forbidden and compilation fails if the call cannot remain direct?
- **Q-049 — Answered by D-403 and D-404:** Runtime `String` stores strict UTF-8 in GC-owned V128 chunks. Arbitrary and malformed byte sequences are represented only by `Bytes`.
- **Q-050 — Answered for the initial API by D-405, D-408, and D-410:** `byte_length` and `byte_at` are explicitly byte-oriented; `utf16_length` is explicitly a UTF-16 code-unit count. Future scalar-value and grapheme operations require separately named APIs and do not change byte indexing.
- **Q-051 — Invalid bytes outside strings:** Should malformed-byte sentinels always produce lexical errors in identifiers, keywords, numbers, operators, and comments, or may comments also retain/ignore arbitrary bytes?
- **Q-052 — Future optional arguments:** Optional function arguments are not currently supported. A future design must define declaration syntax, call-site omission rules, default-expression evaluation order, overload interaction, interface serialization, and whether omitted arguments affect ABI identity.
- **Q-053 — Keyword inventory:** Which additional words must be reserved initially? Candidates include `const`, `static`, `async`, `await`, `try`, `catch`, `throw`, `defer`, `unsafe`, `self`, and `Self`.
- **Q-055 — Comments:** Should Dew support nested `/* ... */` block comments in addition to `//` line comments?
- **Q-056 — String escapes:** Are the implemented escapes sufficient? Should Dew also support `\u{...}`, interpolation, raw strings, byte strings, or another escape model?
- **Q-057 — String token payload:** Confirm that `Bytes` is the correct token payload for both quoted and multiline strings so malformed bytes and WTF-8 surrogates remain exact.
- **Q-071 — Explicit generic call syntax:** What syntax supplies explicit generic arguments at a call site without conflicting with comparison operators?
- **Q-077 — Default trait methods:** Should trait declarations permit method bodies, and if so, do implementations inherit, override, or explicitly select defaults?
- **Q-078 — Trait bounds and supertraits:** What syntax expresses bounds on trait type parameters and inheritance or requirements between traits?
- **Q-079 — Associated trait items:** Should traits support associated types, constants, or builtin declarations in addition to methods?
- **Q-080 — Trait method overloading:** May one trait declare multiple methods with the same name when their parameter signatures differ, and how are qualified references resolved?
- **Q-086 — Struct field accessibility:** Does exporting a struct automatically expose all of its fields, or may the language later add read-only, package-level, or constructor-only field access?
- **Q-087 — Struct field defaults:** Should struct declarations permit default field expressions, and how would defaults interact with generic inference and object construction?
- **Q-088 — Tuple structs:** Does Dew need a distinct tuple-struct declaration form, or should named structs plus tuple-like enum variants cover the use cases?
- **Q-089 — Object-to-struct inference:** May an unannotated inline object infer a nominal struct type from its field set, or is an expected type always required?
- **Q-092 — Enum constructor accessibility:** Does exporting an enum automatically export all variant constructors, or can modules expose the type while restricting construction?
- **Q-093 — Enum runtime representation:** How are tags, payload references, singleton unit variants, and recursive generic enums represented in WasmGC?
- **Q-094 — Explicit generic qualification:** Qualified unit, tuple, and struct-like variant expressions now parse through `::`, calls, and construction. What syntax supplies explicit generic arguments without conflicting with comparison operators?


