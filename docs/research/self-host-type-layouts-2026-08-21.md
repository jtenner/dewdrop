# Self-host type layouts

Date: 2026-08-21

The Dew lowering port now plans local nominal type layouts.

Implemented behavior:

- struct, enum, and foreign-type layouts;
- declaration-indexed layout lookup slots;
- source-ordered fields with independent struct and variant field indexes;
- canonical resolved field types and backend value shapes;
- stable enum tags;
- unit, tuple, and struct variant payload layouts;
- tuple payload type and shape arenas;
- visibility, generic span, test-only, and source-offset metadata.

Function planning remains blocked on a Starshine validation defect triggered by compiler-shaped callable aggregate construction. The malformed experiment was removed; the repository retains only validated layout code.
