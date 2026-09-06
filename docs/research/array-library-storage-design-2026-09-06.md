# Array library storage design

Status: proposed implementation for the next migration step, not a completed
feature. FixedArray regression work is recorded separately.

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

The library declares its backing storage, logical length, and logical capacity.
The iterator declares its owner Array and cursor. Generic field planning must
use these declarations, not a three-field wrapper assumption.

One possible clearing scheme reserves one default-valued backing slot beyond
capacity. It is never a logical element. `array.copy` can copy this slot to clear
removed elements without constructing an invalid T, adding an opaque compiler
operation, or boxing scalar elements. Copies can double the cleared interval
for a bulk clear. This costs one raw slot per non-Unit Array. Validate the
capacity bound before adding that slot. Check the final scheme against existing
capacity, mutation, and iteration semantics before implementing it.

Existing literal, Map, and runtime producers may allocate exactly capacity raw
slots. A sentinel scheme cannot be enabled until those producers use the same
declared construction recipe. Do not infer an extra slot from an old wrapper.

Unit arrays can keep length and capacity without per-element storage. Use
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
