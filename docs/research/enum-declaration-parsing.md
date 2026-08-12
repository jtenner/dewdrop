# Enum declaration parsing

Date: 2026-07-29

## Grammar

```text
enum-declaration = "pub"? "enum" identifier type-parameters?
                   enum-body line-end

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

Enums support unit, tuple-like, and struct-like variants:

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

Variants are newline-delimited. Commas are not variant separators. Tuple payloads use comma-delimited type lists and accept exactly one trailing comma. An empty tuple payload is rejected in favor of the canonical unit spelling. Compact empty struct-like payloads remain distinct and are accepted.

## AST layout

```text
EnumDeclaration {
  visibility
  name
  name_offset
  type_parameters
  variants
  offset
}

EnumVariant =
  UnitVariant(name, offset)
  TupleVariant(name, payload_types, offset)
  StructVariant(name, fields, offset)
```

Using one tagged enum node per variant avoids allocating a separate payload wrapper. Struct-like variants reuse `StructField`; tuple variants store `Array[TypeExpr]`. `EnumVariant::name` and `EnumVariant::offset` provide shape-independent access.

## Visibility

A bare enum is `ModuleVisible`; `pub enum` exports the type. Variants and struct-like variant fields do not have separate visibility modifiers in the initial grammar. Constructor accessibility for an exported enum remains a semantic policy question.

## Streaming parser behavior

After consuming a variant name, one token selects its deterministic form:

- `Newline` produces a unit variant.
- `(` begins a tuple-like payload.
- `{` begins a struct-like payload.
- Any other token produces `EnumVariantPayloadOrLineEnd` without backtracking.

Tuple payloads and field types use the shared recursive `TypeExpr` parser, including applied types and contextual `>>` closing. Variant and field loops are iterative by member count.

## Diagnostics and stress coverage

Dedicated diagnostics cover missing enum names, body newlines, variant names, payload forms, tuple separators, struct-like body newlines, and struct-like field names. Structural failures retain offsets through `UnclosedEnum`, `UnclosedTupleVariant`, `UnclosedStructVariant`, and `EmptyTupleVariant`.

Tests cover all three variant shapes, generic and recursively applied payloads, multiline tuple payloads with trailing commas, compact and multiline empty enums, empty struct-like variants, comments, blank lines, malformed fields, rejected comma-separated variants, rejected member visibility, declaration separation, and a 1,024-unit-variant stress case.

## Benchmarks

The benchmark source is `src/parser/enum_declaration_bench_test.mbt`. Unit workloads contain 256 variants. Tuple workloads contain 64 variants carrying `Map<String, List<t>>`. Struct workloads contain 64 variants with two fields. Parse-only measurements materialize tokens outside the timed closure.

| Workload | Native | WasmGC | JavaScript | Wasm |
|---|---:|---:|---:|---:|
| parse-only unit variants, n=256 | 12.17–21.83 us | 9.28 us | 14.73 us | 68.78 us |
| tokenize-only unit variants, n=256 | 47.88–92.62 us | 88.62 us | 144.24 us | 257.06 us |
| tokenize + parse unit variants, n=256 | 53.87–103.61 us | 102.52 us | 147.41 us | 308.52 us |
| parse-only tuple variants, n=64 | 25.78–48.48 us | 24.14 us | 27.14 us | 157.99 us |
| tokenize-only tuple variants, n=64 | 45.91–88.52 us | 111.68 us | 129.38 us | 210.04 us |
| tokenize + parse tuple variants, n=64 | 67.19–127.68 us | 138.26 us | 144.33 us | 298.81 us |
| parse-only struct variants, n=64 | 28.69–54.44 us | 30.11 us | 34.74 us | 143.40 us |
| tokenize-only struct variants, n=64 | 74.56–136.89 us | 170.57 us | 168.64 us | 297.70 us |
| tokenize + parse struct variants, n=64 | 93.73–170.71 us | 215.52 us | 208.32 us | 393.57 us |
| short mixed generic enum, end-to-end | 2.16–3.96 us | 4.45 us | 4.11 us | 8.64 us |
| empty enum, end-to-end | 435.25–818.71 ns | 745.56 ns | 812.46 ns | 1.83 us |

The JavaScript and Wasm runners showed wider variance in several tokenization-heavy cases. A later native full-suite run also slowed legacy tokenizer-only and expression workloads globally, so the widened native ranges are retained rather than attributed to enum parsing. Backend timings should only be compared within the same runner; optimization decisions require repeated controlled runs.

## Deferred semantics

This parser phase does not assign runtime tags or layouts. Duplicate names, generic arity, recursive representation legality, constructor expressions, qualified variant syntax, pattern matching, exhaustiveness, and WasmGC lowering are implemented by later semantic/backend phases; constructor visibility remains a language-policy question.
