# Builtin declaration parsing

Date: 2026-07-29

## Syntax

The initial parser accepts:

```dew
pub builtin i32_add(a: I32, b: I32) -> I32 = "i32_add"
```

with this deterministic grammar:

```text
builtin-declaration = "pub"? "builtin" identifier type-parameters?
                      "(" parameters? ")" "->" type "=" quoted-string-literal
                      line-end

type-parameters     = "<" identifier ("," identifier)* ","? ">"
parameters          = parameter ("," parameter)* ","?
parameter           = identifier ":" type
type                = identifier
```

The standard double-quoted string after `=` is the compiler builtin registry name, and the lossless token payload remains `Bytes`. MoonBit-style `#|` multiline strings are rejected in this declaration position. The compiler performs an exact lookup against its registered builtin names. The registry is extensible so compiler extensions may provide custom builtin implementations.

## Visibility

`pub` is optional:

- `pub builtin` is exported from the declaring module;
- bare `builtin` remains visible throughout its module but is not exported.

The AST represents these states as `Public` and `ModuleVisible`. There is no private declaration visibility and `private` remains an ordinary identifier rather than a modifier.

## Generic information

Generic builtins retain ordered type-parameter records and typed value-parameter records:

```dew
pub builtin select<t, u>(value: t, fallback: u) -> t = "select"
```

The parser does not resolve whether a named type refers to a generic parameter or declared type. Semantic analysis performs that resolution and attaches instantiated generic arguments to call sites before builtin replacement. Calls may obtain generic arguments through inference or explicit call-site arguments; the explicit syntax remains to be specified.

Generic builtin declarations do not currently accept trait bounds or other constraints. This is a provisional simplification and may be reopened when a required builtin cannot be expressed safely without bounds.

## Implemented call inference

Body inference now reads the source-ordered builtin candidate chain retained by collection. Every candidate is checked inside a `LocalTypeSolver` rollback snapshot, so failed argument, return, or occurs constraints leave no mutations or diagnostics behind.

Each candidate receives fresh call-local variables for its generic parameters. Parameter and return signatures are substituted iteratively through canonical applied types, and both argument types and the call's expected result type participate in selection. A unique winner records its exact `DeclId` and zonked inferred generic arguments in `InferredModuleBodies`.

A viable concrete candidate is trialed before generic fallbacks. When no concrete candidate succeeds, viable generic signatures are ordered by strict structural match-set containment over complete parameter and result types. The unique undominated candidate wins; alpha-equivalent and overlapping-incomparable maxima remain ambiguous.

Nested overloaded calls use an iterative retry worklist. Candidate trials are repeated only after another call commits constraints that may distinguish the deferred overload. Details and benchmarks are in `docs/research/direct-generic-overload-call-inference.md`.

## Forward-only behavior

`Parser::parse_declaration` skips blank lines, consumes an optional `pub`, selects the production from the required declaration keyword, and parses exactly one declaration. It consumes one physical terminating newline when present; end of input is an implicit final newline. The next declaration remains untouched. No token is rewound and no alternate declaration production is attempted after consuming `builtin`.

Lexical error tokens encountered at an expected grammar position are consumed and converted to `DeclarationLexicalError`. Other mismatches remain unconsumed in lookahead and produce `ExpectedDeclarationSyntax`.

## Current limits

- Return types are required, including explicit `-> Unit` for a Unit-returning builtin.
- Builtin registry names use standard double-quoted strings; multiline string syntax is rejected.
- Signature types may be named or recursively applied generic types such as `Result<List<I32>>`.
- One trailing comma is accepted in both type-parameter and value-parameter lists.
- Dew-visible builtin names may be overloaded. Body inference selects viable candidates, diagnoses no-match and ambiguity, and retains the exact selected declaration.
- Multiple declarations may refer to the same builtin registry string and need not share one canonical signature.
- The compiler-provided builtin expansion reports or carries the type of its produced value. Compilation accepts the expansion only when that type matches the instantiated declaration return type. This acts as a type guard across the extensible builtin boundary.
- Duplicate generic names, duplicate parameter names, unknown types, unknown registry names, overload ambiguity, and builtin result compatibility are semantic errors rather than parser errors. Overload ambiguity is implemented; registry lookup and expansion-result compatibility remain lowering concerns.
- A physical newline terminates the declaration; end of input is an implicit final newline. Semicolons are not declaration terminators.
