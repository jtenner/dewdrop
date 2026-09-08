# Exact global initializer link records

## Defect

The linker checked named function/type records but not global initializer
records. Ten source-derived mutations were accepted: wrong module, declaration,
body, shape, test flag, global slot, order, and missing/duplicate records. The
red lane passed 609 tests and failed those ten tests (69.602 seconds).

## Change

The link plan now retains its explicit test-inclusion mode. The verifier walks
selected source initialization steps in the checked dependency order and
requires exactly one matching linked record for every step. It checks complete
global counts, module/declaration/body identity, concrete and structurally equal
shapes, test flags, slots, order, encoded module ownership, and present body
owners. It does not index a module arena using the unverified linked record.

Initializer function handle arithmetic is checked in U64 before conversion.
Neither overflow nor the reserved missing handle can reach the physical body
plan. Exact numeric records retain the source module, declaration, body, and
schedule position. Additional negative cases cover missing bodies, Generic
shapes, missing/extra source steps, and function-index limits. Positive cases
cover test-only globals and Unit values.

The first fixed lane passes 619 tests and 259 exact records with all shared
probes (68.095 seconds). A wider test run first found a test-helper dependency
outside the hardening file list (18.249 seconds); the fixture now constructs
its own manifest through production entry points. The expanded lane passes
626 tests and all 265 exact records, but fails one new positive execution test
(67.171 seconds): a Unit global emits `global.set` with an empty stack. This
is a separate storage defect exposed by the new initializer coverage. The test
remains a visible failure, not an expected trap, and the next storage change
must fix it. No new bootstrap result is claimed for this batch.

Complete link freeze, synthetic startup/adaptor recipes, and full reference
types remain separate obligations. Runs above 30 seconds remain speed bugs;
no speed work is included.
