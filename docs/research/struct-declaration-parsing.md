# Struct declaration parsing

Date: 2026-07-29

Updated: 2026-08-15 for mutable field syntax.

## Grammar

```text
struct-declaration = "pub"? "struct" identifier type-parameters?
                     struct-body line-end

struct-body        = "{" "}"
                   | "{" newline newline* struct-field* "}"

struct-field       = "mut"? identifier ":" type newline
```

Examples:

```dew
pub struct Point<t> {
  mut x: t
  y: t
}

struct Cache<t> {
  entries: Map<String, List<t>>
}

struct Empty {}
```

Struct fields are newline-delimited, matching inline object literals. Commas are not field separators. Every non-empty field requires a newline, including the final field before `}`. Blank lines and line comments are accepted between fields. `mut` is an optional field modifier; fields without it remain immutable.

## Visibility

A bare struct is `ModuleVisible`; `pub struct` exports the type. Fields do not have separate visibility modifiers in the initial grammar. Field accessibility follows the containing type's eventual visibility/access policy.

## AST

```text
StructDeclaration {
  visibility
  name
  name_offset
  type_parameters
  fields
  offset
}

StructField {
  mutable
  name
  type
  offset
}
```

Field order is preserved. Duplicate field names, recursive-layout legality, generic arity, unknown types, and visibility leakage are semantic checks.

## Type integration

Struct fields use the shared recursive `TypeExpr` parser, including applied types, newlines after type-argument commas, one trailing comma, and contextual splitting of `>>` into two generic closers. This permits fields such as:

```dew
entries: Map<String, List<Result<t>>>
```

## Recovery and stress coverage

Dedicated expectations identify missing struct names, body-opening newlines, field names, colons, types, and field-ending newlines. `UnclosedStruct` retains the declaration offset. Tests cover explicit mutable and default immutable fields, compact and multiline empty structs, generic parameter formatting, nested applied field types, rejected comma separators, rejected field visibility modifiers, comments, declaration separation, malformed fields, and a 1,024-field iterative stress case.

## Benchmarks

The benchmark source is `src/parser/struct_declaration_bench_test.mbt`. Named-field workloads contain 128 fields of generic type `t`. Applied-field workloads contain 64 fields of `Map<String, List<t>>`. Parse-only measurements materialize tokens outside the timed closure.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only named fields, n=128 | 11.26–12.73 us | 7.07 us | 5.94 us | 38.62 us |
| tokenize-only named fields, n=128 | 35.71–37.64 us | 49.61 us | 40.09 us | 116.43 us |
| tokenize + parse named fields, n=128 | 42.82–45.02 us | 53.91 us | 39.19 us | 141.71 us |
| parse-only applied fields, n=64 | 21.36–22.89 us | 12.05 us | 11.73 us | 72.61 us |
| tokenize-only applied fields, n=64 | 43.35–46.04 us | 61.13 us | 52.31 us | 145.23 us |
| tokenize + parse applied fields, n=64 | 60.77–64.21 us | 70.28 us | 54.03 us | 211.17 us |
| short generic struct, end-to-end | 1.49–1.59 us | 1.67 us | 1.28 us | 4.96 us |
| empty struct, end-to-end | 452.86–509.55 ns | 460.15 ns | 381.31 ns | 1.51 us |

Backend timings should only be compared within the same runner. Applied-field parsing performs the expected additional AST and type-argument work but remains iterative by field count.
