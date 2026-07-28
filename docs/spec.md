# Dew Language Specification

> Status: early design draft. Syntax and semantics marked **Proposed** are not yet settled.

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
  -> later semantic and lowering stages
  -> Starshine
  -> WasmGC
```

### 3.1 Source stream

The compiler reads as directly as possible from a raw file descriptor to minimize abstraction overhead and memory use. A custom WTF-8 decoder exposes a forward-only iterator of decoded code points and tagged malformed-input sentinels.

- Input is read one host operating-system page at a time. This buffer-size choice is provisional pending measurement.
- The complete source text does not remain resident in memory.
- Consumed input pages may be released once no active lexer state depends on them.
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

Source metadata uses the following provisional model:

```dew
Source {
  line_breaks: Array[Offset]
  tokens: Array[Token]
}

Token(TokenKind, Offset, Index)
```

A `Source` records line-break positions and a transient array of tokens.

- `Offset` is the token's absolute UTF-8 byte offset in the source.
- `Index` is the token's index in the active `Source.tokens` array.
- A token index is valid only while that token remains in the active array. AST nodes must not retain an index after the corresponding token is evicted.

Tokens may be evicted after their declaration has been converted into AST nodes, provided those AST nodes retain enough information to regenerate diagnostic source text. `Source.tokens` is therefore an active token window rather than a required full-file token archive.

Because source pages are discarded, diagnostic source text is reconstructed from retained tokens, AST nodes, and synthetic recovery nodes. Exact preservation of original whitespace and spelling is not currently required.

### 3.3 Parser

The parser consumes the token iterator and returns one interleaved event iterator:

```dew
enum ParseEvent {
  Declaration(Declaration)
  Diagnostic(Diagnostic)
}

fn parse(tokens: Iter[Token]) -> Iter[ParseEvent]
```

A single event stream is the default low-memory API. Returning separate lazy declaration and diagnostic iterators would require buffering whichever stream the caller consumes more slowly. The parser instead emits each declaration or diagnostic as soon as it becomes available, and the consumer decides what to retain.

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
- Recovery tracks nested contexts so that a delimiter inside a nested construct does not incorrectly synchronize an enclosing construct.
- Events preserve parser discovery order.
- The core parser does not accumulate all diagnostics or declarations merely to support separate output channels.
- Convenience adapters may route events into callbacks or collections, but those adapters own any resulting buffering.

### 3.4 Expression parsing

Expressions are parsed using the shunting-yard algorithm. Operator precedence and associativity must be explicit so expression parsing remains deterministic without backtracking or competing representations.

The initial operator table, and the treatment of prefix, postfix, call, indexing, field-access, and assignment forms, remain to be specified.

## 4. Names

- Generic type variables use `snake_case`, for example `t` and `type_var`.
- Named types use `PascalCase`, for example `I32`, `I64`, and `SumExample`.
- Identifiers may contain Unicode characters. The exact Unicode identifier-start, identifier-continue, normalization, and confusable-character rules remain open.

## 5. Traits

Dew supports traits parameterized by types.

```dew
trait Add<t> {
  fn add(left: t, right: t) -> t
}
```

A method does not repeat the trait's generic parameter list merely to use those parameters. Method-level generics may be specified separately in the future, but their syntax and shadowing rules are not yet decided.

Dew supports static and instance trait methods. Static trait methods are callable using qualified syntax:

```dew
Trait::static_method(...)
```

All of the following instance-call forms are intended to be legal:

```dew
value.method(args)
Trait::method(value, args)
Type::method(value, args)
```

### 5.1 Dispatch

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

A runtime `Trait` value is an erased trait object. Its receiver slot uses a non-null Wasm `(ref any)`-compatible representation. GC-reference values can enter that slot directly. Numeric and vector scalars cannot, so coercing an unboxed scalar to an erased `Trait` value allocates a WasmGC box containing the scalar.

Boxing occurs only at an actual erased-trait-object boundary. A statically resolved trait call, including a qualified call on a concrete scalar, must remain unboxed and compile directly. Generic dictionary calls may use ABI-shape-specialized entries so scalar arguments remain unboxed. The optimizer should eliminate a temporary trait-object allocation when the object does not escape and the implementation can be directized.

A centralized `br_table` dispatcher is not the default. It may be introduced as a benchmark-driven optimization for small sealed implementation sets, but it does not define language semantics. A table-based `call_indirect` is likewise unnecessary when a typed function reference is already stored in the WasmGC dictionary.

Method-name ambiguity at the source level still requires an explicit qualification rule, specified by Q-039.

## 6. Implementations

Dew supports generic trait implementations, including implementations of a parameterized trait for a concrete type.

```dew
impl Into<I32> for I64 {
  fn into(self) -> I32 {
    @wasm.i64_trunc_i32(self)
  }
}
```

Dew is garbage-collected because it targets WasmGC. User-defined aggregate and recursive types compile to WasmGC recursive types. Primitive scalar values such as `I64` remain unboxed.

`self` denotes the receiver semantically, but its lowered representation follows the receiver type: a primitive receiver is passed as an unboxed Wasm scalar, while a GC-managed receiver is passed as a Wasm reference.

Generic lowering should avoid broad monomorphization so generated Wasm remains compact and deliverable. Generic trait operations use hidden immutable dictionaries containing typed function references. ABI-shape specialization may still be used to preserve unboxed primitive values.

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

A module may explicitly define an implementation when it owns neither the trait nor the implementing type by using `foreign impl`:

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

Dew supports static and instance methods associated directly with types. An instance method is identified by `self` as its first parameter. `self` is shorthand for `self: Self` and is not legal in any later parameter position. A method without a first `self` parameter is static. Visibility rules remain open.

Instance type methods may be called as either:

```dew
value.method(args)
Type::method(value, args)
```

Trait-qualified calls may be used when explicit trait selection is needed, subject to the final lookup rules.

## 8. Sum types

Dew supports generic sum types with tuple-like and struct-like variants.

```dew
pub enum SumExample<type_var> {
  Add(A, B, C)
  StructKind {
    field: Type
    field_2: type_var
  }
}
```

A struct-like variant can be constructed using qualified syntax:

```dew
let a = SumExample<type_var>::StructKind {
  field: value
  field_2: other_value
}
```

Variant separators, generic argument inference, pattern syntax, representation, and exhaustiveness rules remain open.

## 9. Decision log

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

## 10. Question history

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
| Q-024 | Partially answered | Exact concrete implementations outrank generic implementations containing type variables. Generic/generic overlap and orphan rules remain Q-036 and Q-037. |
| Q-025 | Answered | `self` must be first and abbreviates `self: Self`; its presence distinguishes instance methods from static methods. |
| Q-026 | Answered | `Offset` is a UTF-8 byte offset. `Index` indexes the active token array and is invalid after eviction. |
| Q-027 | Answered | Tokens may be evicted once source text needed for diagnostics can be regenerated from AST nodes. |
| Q-036 | Answered | Use structural specificity: exact types first, then strict match-set containment; reject equally specific or incomparable overlaps at declaration. |
| Q-037 | Answered | Permit module-local orphan implementations with the explicit `foreign impl` syntax. |
| Q-038 | Answered | Scalars are boxed when explicitly treated as erased runtime `Trait` objects; direct/static and ABI-specialized generic calls keep them unboxed. |
| Q-040 | Answered | A foreign impl is considered only in its exact declaring module and cannot be imported or re-exported. |
| Q-041 | Answered | Foreign impls in different modules do not conflict globally because they cannot be imported into a shared scope. |
| Q-042 | Answered | Foreign impl evidence is private: a public body may use it internally, but a public signature cannot expose or require it. |
| Q-047 | Answered | Use WTF-8 plus lossless tagged sentinels above U+10FFFF rather than replacing malformed bytes with U+FFFD. Sentinels are allowed in string literals. |
| Q-048 | Answered | The tokenizer owns one reusable page-sized buffer that is rewritten from the file descriptor throughout the cursor's lifetime. |

## 11. Open questions

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
- **Q-049 — Runtime string representation:** Must Dew strings preserve arbitrary WTF-8 bytes exactly, including malformed-byte sentinels, or do source string literals decode into another runtime representation?
- **Q-050 — String indexing:** Are string length and indexing measured in raw bytes, WTF-8 decoded units, Unicode scalar values, or grapheme clusters?
- **Q-051 — Invalid bytes outside strings:** Should malformed-byte sentinels always produce lexical errors in identifiers, keywords, numbers, operators, and comments, or may comments also retain/ignore arbitrary bytes?


