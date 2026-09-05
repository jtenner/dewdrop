# Captured closure emission

Closure construction and capture reads now use explicit lambda/capture field
roles from the fragment plan. Immutable values are copied into the environment;
mutable captures share one GC cell per source local. Hidden cell locals follow
ordinary local and scratch slots. The frozen logical scalar carrier is not
replaced by the cell's reference carrier.

Captured parameters initialize their cells at function entry; let-bound cells
are allocated when their initializer executes. Local and capture writes update
the shared cell. Nested closures can forward an existing environment field.
Captured locals count as reads, so their initializers are not discarded.
Unit/Never captures do not create physical fields, and mutable fields store a
reference to the cell, not a scalar copy. Capture reads check lambda span
membership before indexing.

Validation: 123 hardening tests and 24 numeric records pass. The executable
reference/capture lane passes 48 boundary checks, including a captured I64
parameter, a let local, two closures sharing mutable state, and a nested closure
forwarding its environment. Existing scalar/memory/math matrices remain green.
Full hardening took 15.750 seconds; expanded emission checks took 3.800 seconds.

The full callback fixture remains enabled. It now reaches Wasm validation and
reports an invalid local index in `unit_middle`: physical parameters erase Unit
but local indexing still counts it. This is the next separate ABI defect.
Generic scalar captures, mutable pattern bindings, and broader closure cases
still need dedicated coverage; this is not a blanket closure-correctness claim.
