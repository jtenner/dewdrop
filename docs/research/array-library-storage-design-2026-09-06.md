# Array library storage design

Status: raw contracts, declared fields, and all Array functions are implemented
in Dew. See the [algorithm migration](array-library-algorithms-2026-09-06.md)
for validation. Literal/runtime construction migration remains separate work.

## Raw operations and identity

The [raw contract change](raw-array-contracts-2026-09-06.md) adds declarations
for `array.new_default` and `array.copy`. Each declaration
describes one Wasm instruction. Raw allocation does not create a logical T
value: the library must initialize a slot before reading it as T.

Build raw representation metadata from the selected builtin declaration and its
resolved signature. Do not identify its array owner by the name WasmArray, a
standard module path, or a declaration number. Check arity, element type identity,
the nominal owner's empty representation declaration, and scalar operand types.
Reject contradictory representation records. Rebuild metadata from the current
signatures after cache loading, and preserve it in selected-body copies. Use the
same rules for user modules and standard modules.

## Ordinary Array fields

The library now declares its backing storage, logical length, and logical
capacity; see the [accessor change](array-library-accessors-2026-09-06.md).
The iterator also declares its owner Array and cursor. Generic field planning
uses these declarations, not an iterator layout override.

Clearing uses an existing unused default-valued slot, or one temporary default
slot when the array is full. `array.copy` then doubles the cleared interval.
This does not construct an invalid logical T or box scalar elements. The earlier
extra-sentinel proposal was not adopted: existing literal, Map, and runtime
producers may allocate exactly capacity raw slots.

As a later optimization, Unit arrays can keep length and capacity without
per-element storage. The current implementation retains marker slots. Use
`is_unit<T>()` in ordinary Dew branches. Every argument still evaluates once in
source order; the selected branch removes only its storage work. Never is not
Unit and must not be converted into a usable operand.

## Required checks

- Exact raw declarations, including renamed and reordered user declarations.
- Multiple generic parameters; the element parameter need not be the first.
- Default allocation and overlap-safe copies for each supported storage type.
- Packed I8/U8/I16/U16 storage remains distinct across generic calls.
- Scalar, reference, tuple, and Unit values retain order and bounds behavior.
- Growth and reserve arithmetic cannot wrap. Removed references are cleared.
- Array literals use the same declared construction and storage rules as calls.
- Both compilers pass the shared collection corpus and bootstrap checks.
