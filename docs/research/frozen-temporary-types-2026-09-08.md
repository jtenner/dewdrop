# Frozen expression-temporary allocation

## Missing physical storage evidence

A source-derived test matches Unit and uses Unit as a functional loop state.
The old planner retained Unit as the temporary carrier and left the emitter
to invent an I32 slot. The regression failed at that carrier assertion:
571 tests passed and one failed (70.593 seconds).

The planner now retains explicit I32 storage for unused control/projection
slots whose logical value is Unit or proved Never. The logical type remains
in the value record. Unknown and Conflict cannot become markers (BOD-610),
and Never requires source flow that cannot fall through (BOD-611).

The emitter allocates expression temporaries directly in frozen record order.
It checks source ownership, record uniqueness, mirrored carriers, and ordinal
bounds. Constructor and raw-array records retain their extra source-agreement
checks. Other expression kinds must have a valid physical carrier; they cannot
fall back to inferred shapes, I32, or Ref. Two unused scratch-shape recovery
helpers are removed along with the old allocation scan.

## Unit loop stores

The first corrected test reached Wasm validation and exposed an existing
empty-stack store for the Unit loop initializer (73.699 seconds). The emitter
also stored Unit continue values unconditionally. Both stores are now omitted
when the frozen source carrier is Unit. Source evaluation still occurs before
the loop or continue branch. No fabricated runtime operand is needed.

The shared Unit branch corpus now checks a side-effecting Unit match subject
and a Unit loop with two side-effecting continues. Both must return 42. The
same source and checks run through native and self-host compilation. Four
numeric negative tests cover Unknown, Conflict, false Never flow, and an
invalid temporary ordinal; each changes one field of valid source-derived
state. The expanded hardening lane passes 576 compiler tests, 220 exact
numeric records, 22 Unit branch checks, and all other shared probes
(72.673 seconds). The native library lane passes 326 tests and all shared
probes, including both new Unit cases (30.183 seconds). Generated-file checks
pass (4.944 seconds). The clean bootstrap passes (238.320 seconds). Compiler B
and C have identical raw and linked SHA-256 hashes:
`c108e1b89c292b9c3d0d2d936c02cd15f498fb573833dd57a5f4a3c017f7750c`.

## Scope

All currently planned expression-temporary slots and broad carrier types now
drive allocation. Capture-cell records, full reference heap types/nullability,
source-local recovery, and complete control-stack verification remain open.
Unused I32 marker slots can be removed later as speed work, not by weakening
the distinction between logical Unit/Never and physical storage. Runs above
30 seconds remain speed bugs.
