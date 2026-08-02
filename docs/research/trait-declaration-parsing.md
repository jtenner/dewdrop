# Trait declaration parsing

Date: 2026-07-29

## Grammar

The initial trait declaration grammar is deterministic and newline-delimited:

```text
trait-declaration = "pub"? "trait" identifier type-parameters? trait-body line-end

trait-body        = "{" "}"
                  | "{" newline newline* trait-method* "}"

trait-method      = "fn" identifier "(" trait-parameters? ")"
                    "->" type newline

trait-parameters  = trait-parameter ("," newline* trait-parameter)*
                    ","? newline*

trait-parameter   = "self"
                  | "self" ":" "Self"
                  | identifier ":" type
```

Type-parameter lists use the shared declaration grammar and accept one trailing comma plus newlines after commas.

Example:

```dew
pub trait Convert<t> {
  fn convert(self) -> t
  fn create(value: t) -> Self
}
```

## Visibility

A bare trait is `ModuleVisible`. `pub trait` exports it. Trait methods do not carry separate visibility modifiers in the initial grammar; they are members of the trait contract.

## Receivers

`self` is recognized contextually as a receiver only in a trait method parameter list. It must be the first parameter. Both forms are accepted:

```dew
fn compare(self, other: Self) -> I32
fn compare(self: Self, other: Self) -> I32
```

Trait methods store an optional `ReceiverParameter` separately from their ordinary `Array[FnParameter]`. The AST normalizes both trait spellings to a receiver whose `explicit_type` is absent. An explicit trait receiver type other than `Self` is rejected. A method without a receiver is static, including a zero-argument method.

## AST

`TraitDeclaration` retains:

- declaration visibility;
- name and source offset;
- ordered type parameters;
- ordered method signatures;
- declaration offset.

Each `TraitMethod` retains its name, optional receiver, compact array of ordinary typed parameters, return type, and offsets. Keeping the receiver separate avoids wrapping every ordinary parameter in a larger tagged enum and improved the 64-method native parse benchmark.

## Newline behavior

A non-empty trait body requires a newline after `{`. Every method signature requires a newline after its return type. Blank lines and line comments are accepted between methods. The closing `}` terminates the trait body and is followed by the normal declaration line end; end of input is an implicit final line end.

Compact empty traits are accepted:

```dew
trait Marker {}
```

A method body on a trait member is not part of the initial grammar. A `{` after the return type is therefore diagnosed where the method newline is required.

## Current exclusions

The parser intentionally does not yet accept:

- method-level generic parameters;
- trait parameter bounds or supertraits;
- default method bodies;
- associated types or constants;
- separate visibility modifiers on trait methods.

These can be added as explicit grammar extensions without introducing declaration backtracking.

## Diagnostics and stress coverage

Dedicated errors cover receiver position, explicit receiver type, and unclosed trait bodies. Existing declaration expectations identify missing names, braces, parameter punctuation, arrows, return types, member newlines, and the required `fn` keyword.

Tests cover public and module-visible traits, generic parameters, receiver and static methods, explicit `self: Self`, invalid receivers, compact and multiline empty bodies, multiline parameter lists, malformed member syntax, unsupported method generics, non-method members, declaration separation, and a 512-method trait body.

## Benchmarks

The benchmark source is `src/parser/trait_declaration_bench_test.mbt`. The 64-method static workload contains one typed value parameter per method; the receiver workload contains `self` plus one typed value parameter per method. Parse-only tests materialize tokens outside the timed closure.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only static methods, n=64 | 13.32–14.63 us | 9.05 us | 7.41 us | 45.89 us |
| tokenize-only static methods, n=64 | 40.67–43.08 us | 54.27 us | 42.36 us | 126.83 us |
| tokenize + parse static methods, n=64 | 49.40–51.59 us | 61.77 us | 42.73 us | 161.54 us |
| parse-only receiver methods, n=64 | 16.63–17.96 us | 10.91 us | 9.87 us | 56.53 us |
| tokenize-only receiver methods, n=64 | 48.20–52.14 us | 65.51 us | 51.67 us | 149.78 us |
| tokenize + parse receiver methods, n=64 | 59.27–62.33 us | 74.66 us | 53.31 us | 193.69 us |
| tokenize + parse short generic trait | 2.12–2.25 us | 2.48 us | 1.83 us | 6.59 us |

Backend timings should only be compared within the same runner. The receiver workload is longer and creates one additional parameter AST entry per method, so it is not a direct branch-cost comparison with the static workload.
