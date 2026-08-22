# Self-host I32 functional loops

Date: 2026-08-22

The linked emitter now lowers expression-valued functional `while` loops for 32-bit scalar state.

Added support:

- deterministic loop-state scratch locals;
- pattern binding and guarded loop arms;
- Wasm result blocks around void loops;
- `break value` branches to the result block;
- `continue value` writes the next state and branches to the loop header;
- label-depth tracking through nested `if`, `match`, and loop bodies;
- explicit unreachable fallthrough after the loop.

The smoke module counts down with guarded binding arms, then returns `70` through the loop result block. Starshine validates the generated `block`, `loop`, `br 2`, and `br 1` structure.

The scalar control-flow tranche now includes blocks, matches, branches, early returns, and functional loops.
