# Native program module-index contracts

`ProgramIndex::module_index` previously returned any stored integer. A corrupt
map could authorize a negative index, an index past the module arena, or the
wrong module. All owner methods delegate to this lookup.

The index now retains the same module array used to build it, not a second
copy of all module data. A selected index is checked against that live array
(ARN-101), and the selected module's stored identity must equal the requested
identity (ARN-106). Only an absent map key means no owner. A stored -1 is not
an absence sentinel. The public wrapper prints the complete numeric record
before aborting; the checked helper exposes the same record to tests.

Specialization also has direct map readers. Its entry now checks the complete
index against the pass's actual module array: parallel lengths, map cardinality,
every required owner, and exact table position. This catches replacement arrays
as well as mutations of the shared arena. Counts and per-module checks prove a
total one-to-one mapping before those direct readers run. Module-level failures
use zero declaration/body and the missing expression sentinel; they do not
invent a caller context.

Measured checks:

- The thin checked API reproduces the existing negative-index behavior:
  one positive test passes and the negative test returns `Ok(Some(-2))`
  instead of the numeric error, in 9.182 seconds.
- Bounds and stored-identity implementation: four tests pass in 10.924 seconds.
- Full table preflight: seven tests pass in 11.875 seconds. Cases include all
  negative selected indices, the upper signed bound, another stored module,
  a removed arena entry, extra map entries, replacement module IDs, and
  mismatched arena lengths.
- Scoped semantic/backend interface regeneration passes in 3.264 seconds.

The full routine native lane passes all 1,322 tests in 281.288 seconds:
36 tokenizer, 297 parser, 821 semantic, 147 backend, 19 loader, and two driver
tests. The standard source-only package has no tests and is not counted as
coverage. All 270 integration tests pass in 90.764 seconds. Generated-source,
policy, metadata, and associated CLI checks pass in 19.017 seconds. Provider
bindings are unchanged. A new clean bootstrap has not yet been run for this
index change. Runs over 30 seconds remain
timing defects; speed work is deferred.

This is not a claim to have replaced
every old diagnostic or checked every other compiler index. In particular,
the existing duplicate-module construction abort remains separate cleanup.
The self-host selected-owner boundary is recorded in the
[owner log](program-callable-owner-2026-09-09.md).
