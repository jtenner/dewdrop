# Rust-style iteration and `for` loops — 2026-08-20

## Decision

Dew uses one ambient iterator operation:

```dew
pub trait Iter<t> {
  fn next(self) -> Option<t>
}
```

Exhaustion returns `Option::None` repeatedly. It does not trap. The trait lives in `dew.std.option`, next to `Option<t>`, because the compiler preamble cannot resolve a type declared by a later standard module.

`for pattern in iterable { body }` is parser sugar. It does not add an AST, HIR, inference, or backend node. The parser evaluates `iterable` once, calls `.iter()` once, stores the cursor in a synthetic name containing `$`, and builds the existing functional `while` and `Option` match forms.

## Lowered shape

The source:

```dew
for value in values {
  consume(value)
}
```

is equivalent to:

```dew
{
  let $for_iter_<offset> = values.iter()
  while $for_iter_<offset>.next() {
    Option::Some(value) => {
      consume(value)
      continue $for_iter_<offset>.next()
    }
    Option::None => break {}
  }
}
```

The synthetic name cannot collide with a source identifier because `$` is not accepted in Dew identifiers.

## ABI and allocation finding

The ordinary WasmGC representation of `Option<t>` allocates a variant struct. A direct iterator loop therefore emitted `struct.new` for both `Some` and `None` before optimization. This would be one temporary allocation per yielded element.

Starshine `heap2local` already handled one non-escaping struct allocation stored in a local, but it did not handle:

- an `if` that selected different struct subtypes;
- a common base-tag field plus subtype payload fields;
- repeated Option writes to one loop-state local.

The pass now scalarizes those cases. It replaces the variant object with tag and payload locals, preserves branch-prefix effects and constructor-field evaluation order, and rewrites exact field reads. Escaping values and unsupported mixed uses remain heap objects.

Production Dew binary emission runs the focused Starshine `heap2local` pass. A backend regression compiles an Array `for` loop and verifies that the unoptimized function contains the exact `Option::Some<I32>` and `Option::None` allocations while the production binary does not. The iterator cursor allocation remains visible and occurs once per loop, not once per element.

## Backend corrections

Array, Map, and Set expose native Option-producing iterator operations. The old unchecked raw next operations remain private backend building blocks.

Two independent correctness faults were found:

1. Trait implementation declaration IDs were mapped directly to unchecked element-returning builtins. That bypassed the Option wrapper and created an ABI mismatch.
2. FixedArray lowering records an element shape but no element `BodyTypeId`. A specialized `FixedArray<I32>` function therefore had an `I32` signature while its body retained the generic reference carrier. FixedArray emission now uses the sole callable specialization shape when its implicit element shape is generic.

The second fault was link-set-sensitive because adding reachable standard functions changed which generic specializations and physical types were assembled. It looked like a linker problem, but the incorrect carrier was selected during backend specialization. Generic struct field reads also now dispatch across matching physical specializations when one source field has several exact layouts with the same Wasm storage carrier.

## Coverage

The implementation includes:

- parser desugaring and structural error tests;
- Array, Array key/entry, Map key/value/entry, Set, String, and StringView iterator updates;
- non-trapping exhaustion fixtures;
- an end-to-end Array `for` runtime fixture;
- Starshine single-write and repeated-write variant scalarization tests;
- a production backend test that rejects per-element Option allocations;
- standard-library tests, module snapshots, generated-source parity, and builtin-registry identity checks;
- the self-host parser compaction loop rewritten with `for`.

## Performance rule

Do not add a separate Dew-only iterator ABI optimization. Source and backend-neutral phases retain normal `Option<t>` semantics. Starshine owns local heap scalar replacement. A future cross-call result-ABI rewrite can extend this to non-inlined custom iterator methods without changing Dew source semantics.
