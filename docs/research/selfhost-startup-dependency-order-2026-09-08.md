# Self-host startup dependency order

Two source modules import each other. One declares a marker type and computes
`answer = read_seed() + 2`; the other declares `seed = 40` and the called reader.
The self-host compiler emits valid Wasm but returns **2 instead of 42**. The
caller ran before the other module initialized its global. The first temporary
probe needed the existing prelude's `fd_write` import accounted for (1.525
seconds); it remains a throwing stub. The corrected execution probe exposes
the wrong value in 1.506 seconds.

The retained regression uses a function to create the seed, so a native
constant global initializer cannot hide the ordering fault. It tests both
directions of the module dependency and executes the resulting Wasm. The red
hardening run passes 632 tests and fails the new ordering test and value probe
(60.750 seconds).

Startup now follows global reads through selected call bodies and logical query
instances. Owned module/declaration/body records replace any guessed target.
The worklist has an exact body/instance visited set; global edges are unique.
Lookup absence, malformed arenas, missing bodies, and key contradictions stay
diagnostic. Ordinary builtins/foreign and bodyless trait declarations explicitly
have no local body. This is not general effect analysis for dynamic callbacks.

The stable scheduler uses original module order only to break ties. It emits a
semantic diagnostic for a real value cycle. Physical global slots and startup
order are assigned after scheduling; Unit still runs without a storage slot.
A separate edge postcondition proves total membership and dependency-first
order without repeating the scheduling algorithm. The link verifier compares
the emitted table with source-derived selected records.

The first build rejected nested Option patterns as non-exhaustive (15.213
seconds); matching the outer callable first makes the exhaustive cases clear.
The next hardening run passes 633 tests and both value probes, but an older
negative record now reports its earlier stored-body-ID failure (60.158 seconds).
The test corpus distinguishes a shifted stored ID from a genuinely absent body;
duplicate source keys are likewise checked before a missing-link count.
The expanded lane passes 639 tests, 273 exact records, and all execution probes
(61.407 seconds). The wider mutation corpus then exposes a test setup error
(60.604 seconds): plain calls do not require specialization records. The test
now seeds a valid identical exact replay, checks its unchanged dependency edge,
and only then changes one record field. The exact-record checker kept the setup
failure visible instead of accepting any trap as success. The final hardening
run passes 652 tests, 286 exact records, both startup value probes, and all
shared corpora (60.746 seconds). Library execution passes 326 tests and all
shared corpora (27.904 seconds); generated checks pass (4.210 seconds). Clean
Node bootstrap passes (188.663 seconds). Compiler B and C are byte-identical:
`40226c46b244aaaae21fee9acb1bdd520aecebdcea54392f55c681fdc474daaa`.

Follow-up found during this batch: a direct type-query expression in a global initializer reaches
the old module-level cyclic-step guard although its false self-read branch
should be removed (temporary source probe, 0.056 seconds, code 501/phase 5).
The self-host query folding entry currently skips module-let bodies because
they have no callable record. The native folder visits them, but its source
initialization schedule is also built before branch pruning. Execution
schedules must use selected lowered dependencies without mutating inference
dependency records.
This follow-up is fixed in the
[direct-global-query change](direct-global-query-initialization-2026-09-08.md),
with shared execution checks and retained real-cycle tests.
This is separate from the fixed interprocedural scheduler. Full dynamic-call
effects and full link freeze remain open. Runs over 30 seconds are speed bugs;
no speed work is included.
