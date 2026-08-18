# Product types and array literals

Date: 2026-08-18

## Purpose

The self-hosted parser needs small ordered values and lists. Manual struct wrappers and repeated `Array::push` calls made the Dew port harder to read and easier to get wrong. Dew now has first-class product values and array literals.

## Source forms

Products use parentheses and commas:

```dew
fn split(value: U64) -> (U32, U32) {
  (value.into(), value.into())
}
```

A product has 2 through 32 source fields. One value in parentheses remains grouping. Products can nest and accept newlines and one trailing comma.

A `let` item can destructure a product:

```dew
let (first, (second, _)) = next()
```

The initializer runs once. Parsing lowers the binding to one hidden local and ordered product-field projections. The projections bind at the same source point, so a later binding cannot change an earlier projection.

Array literals use brackets:

```dew
let values = [1, 2, 3]
let empty: Array<I32> = []
```

Elements run from left to right. Newlines and one trailing comma are accepted. All elements unify with one element type. An empty literal needs an expected `Array<t>` type.

## Semantic representation

Products are structural types. `(I32, I64)` is distinct from `(I64, I32)`. Nested structure is retained in resolved and body-local type arenas, aliases, substitutions, unification, occurs checks, zonking, imported interfaces, specialization keys, and cache codecs.

HIR and lowering use flat spans:

- `HirProductExpr` and `PlannedProductExpression` retain ordered children.
- `HirProductField` and `PlannedProductField` retain logical field index and arity.
- `HirArrayExpr` and `PlannedArrayLiteral` retain ordered elements and the selected element shape.

`ProductPlannedValueShape` recursively records the physical leaf shapes. It does not introduce one general heap product carrier.

## WasmGC representation

Direct products are Wasm multivalue bundles:

- function parameters and results flatten recursively;
- locals use contiguous Wasm locals;
- product construction leaves ordered scalar values on the operand stack;
- local stores spill leaves in reverse stack order;
- local reads restore source order;
- `if`, `match`, functional `while`, `break`, and `continue` use shape-aware scratch locals when a direct multivalue block is not suitable.

This path does not allocate a runtime product object.

A product is boxed only when one reference carrier is required. Current boundaries include:

- `Array<(...)>` elements;
- immutable and mutable closure captures;
- struct fields;
- tuple-like and struct-like enum payloads;
- eager module values.

The box is one fixed WasmGC array of nullable `eqref` leaves. Scalar leaves use the existing canonical erased scalar boxes; reference leaves are stored directly. Reads unbox back to the original ordered multivalue bundle. Program linking marks only the scalar box kinds used by an actual boxed product.

## Array literal lowering

A nonempty array literal selects the normal `Array<t>` carrier family from the inferred element shape. Lowering:

1. allocates backing storage at the exact literal length;
2. allocates the `Array<t>` wrapper once;
3. evaluates and stores elements in source order;
4. publishes the final logical length after initialization.

Scalar elements stay unboxed in their selected carriers. Product elements are boxed only at the array slot and are unboxed on indexed reads. Empty literals use the expected element type and allocate zero-capacity storage.

## Determinism and caches

Product and array nodes are included in parser-event, body-inference, frozen-interface, lowering-plan, specialization, and physical-link data. Ordered fields and elements remain ordered in every codec and fingerprint. No hash-map traversal determines product layout, ABI order, array element order, or box field order.

## Tests

Coverage includes:

- grouping versus product parsing;
- nesting, newlines, trailing commas, malformed delimiters, and the 32-field source limit;
- 10,000-element iterative array parsing;
- 2,048-element array inference;
- empty-array expected typing and unconstrained-empty diagnostics;
- mixed-element failures;
- nested destructuring with `_` and one initializer evaluation;
- direct and generic-specialized product parameters, results, forwarding, locals, `if`, `match`, and functional `while`;
- lambda parameters and immutable/mutable captures;
- scalar and generic-specialized product arrays, struct fields, enum payloads, patterns, and module-value storage boundaries;
- WasmGC validation for every backend fixture.

The focused native results on 2026-08-18 were:

```text
parser:   278 passed
semantic: 349 passed
backend:   44 passed
```
