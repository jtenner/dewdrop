# Compile-time type queries

Guarded trait calls check the selected method's full logical signature against
the trait requirement before lowering. A mismatch reports `CT-040 guarded
implementation signature mismatch`; equal physical carriers are not sufficient.

Use `open dew.std.types`. These are pure compiler builtins. They use the Dew
type, not its Wasm storage type. No query call reaches runtime emission.

## Available functions

| Functions | Result and use |
| --- | --- |
| `type_equal<A, B>()` | `Bool`: exact type identity after alias resolution. |
| `is_unit<T>()`, `is_never<T>()` | `Bool`: Unit and Never are distinct. |
| `is_integer<T>()`, `is_signed_integer<T>()`, `is_float<T>()` | `Bool`: type category. |
| `bit_width<T>()` | `U32`: logical bit width for a supported numeric type. |
| `can_bitcast<A, B>()` | `Bool`: whether the explicit unsafe bitcast is valid. |
| `lane_count<T>()`, `lane_bit_width<T>()` | `U32`: packed numeric lane shape. |
| `tuple_length<T>()` | `U32`: number of tuple fields. |
| `implements<T, Trait>()` | `Bool`: whether a valid visible or associated trait implementation exists. |
| `static_assert(condition, message)` | Compile error if the constant condition is false. |
| `field_type<T>("name")` | A real type for the named field. |
| `variant_payload_types<T>("Variant")` | A tuple type, in payload source order. |
| `field_names<T>()`, `variant_names<T>()` | Names in source order. Each use makes a fresh string array. |
| `size_of<T>()`, `align_of<T>()` | `U32`: raw scalar or ordered-tuple encoding size and alignment. |
| `field_offset<T>(index)` | `U32`: raw tuple field offset; index must be a constant U32. |

Wrong type categories, invalid members, and unsupported layouts are errors.
Unknown generic types wait for specialization. An error is not a false answer.

## Select a branch before code generation

```dew
open dew.std.types

fn twice<T>(value: T) -> T {
  let integer = is_integer::<T>()
  if integer {
    value + value
  } else {
    value
  }
}
```

Each exact type instance gets its own selected body. Both compilers remove the
unused branch, including in debug builds. An immutable local or captured scalar
query value can be folded. A mutable value is not a compile-time constant.

Both branches must parse and resolve names. A type-dependent check can wait for
the exact type. A separate concrete source error must still be reported. The
selected branch then receives normal field, operator, overload, call, and bound
checks. Removed code must not request functions, locals, or physical types.

## Use a trait without a hard bound

When `QueryRead` declares `query_read() -> I32`, this form is supported:

```dew
fn read_or_zero<T>(value: T) -> I32 {
  if implements::<T, QueryRead>() {
    value.query_read()
  } else {
    0i32
  }
}
```

The true branch has proof of the trait. The proof does not escape that branch.
Imported traits and implementation prerequisites use the same check. A cycle,
ambiguous search, or search limit is a diagnostic, not `false`.

## Use returned types

```dew
open dew.std.types

struct Box<T> {
  item: T
}

type Item<T> = field_type<Box<T>>("item")

fn identity<T>(value: T) -> T {
  value
}

fn keep(value: Item<I64>) -> field_type<Box<I64>>("item") {
  type Kept = field_type<Box<I64>>("item")
  identity::<Kept>(value)
}
```

Computed types also work as generic arguments and in lambda signatures. Queries
on an unknown owner stay as type projections until that owner is known. Local
An `implements` query also checks non-foreign implementations defined with its
nominal type or trait. This lets generic library code use a caller's type. It
does not import unrelated, foreign, or test-only implementations. Required
traits use the same rule. Primitive implementations must be in the query's
normal import scope.

`type` bindings have block scope and make no runtime value. `Type` itself cannot
be stored in a runtime variable, field, parameter, or result.

## Layout limits

These layout queries define a raw linear-memory encoding. They do not expose
WasmGC object layout. Tuple fields use natural alignment; size includes tail
padding. Unit uses zero bytes and alignment one. Never has no layout. Reference
objects and nominal records have no supported byte layout through these queries.

## Next library and compiler work

- Use `is_unit` for erased Array and FixedArray storage paths. Preserve argument
  effects and order even when a value needs no storage.
- Use `implements` for optional library behavior. Keep each trait-dependent call
  inside its proved branch; keep required API guarantees as hard bounds.
- Use lane queries, `can_bitcast`, and `static_assert` to check packed `Into`
  conversions. Keep the conversion body in Dew with an explicit unsafe cast.
- Use member types and ordered names for typed field or variant helpers. They
  do not add a general compile-time loop or macro system.
- Reduce full-module instance copies and repeated source-map work after profiling.
  Preserve exact logical keys, source errors, and one fixed emitter input.

The wider stdlib builtin migration and compiler audit remain separate work in
[`agent-todo.md`](../agent-todo.md). Test and timing records are in the
[completion log](research/compile-time-query-completion-2026-09-06.md).
