# Physical body freeze

The self-host emitter previously ran a second method-target search after the
body verifier. It selected Array methods using receiver and method names, then
wrote new call targets into the checked expression table. Error collection also
wrote a second missing-target sentinel to avoid reporting the same call twice.
Those three helpers and their emission entry point are removed. Missing targets
must be diagnosed by body planning; emission cannot repair them.

The program body plan now retains a freeze witness. Its array containers are
independent copies; their elements are immutable records, enums, scalars, and
strings. This does not copy the source compiler graph or use a hash as proof.
The verifier compares all body metadata and every expression, local, control,
scratch, call, evaluation, and operand field before and after emission.

A change reports BOD-605, phase 7, using the original frozen owner and expression.
The detail packs a field role in the upper 32 bits and the table index in the
lower 32 bits. The missing index marks metadata or an array length. Roles are:

| Fields | Roles |
| --- | --- |
| Body metadata | 1–12 |
| Result value | 20–25 |
| Expressions | 40–58 |
| Local values, carriers, and slots | 70–75, 80, 81 |
| Control state values and carriers | 90–95, 100 |
| Control result values and carriers | 110–115, 120 |
| Scratch records | 130–139 |
| Calls | 150–159 |
| Evaluations | 170 |
| Operand kind and source | 180–181 |

Array-length checks use the first role of their table. Program body-count changes
use zero owner context. Exact record tests check the intended error, not just
an arbitrary trap. Equal replacement records remain valid: physical identity is
structural, not the address of a record.

This freezes the existing body plan. It does not yet prove that every temporary
local has a plan entry, freeze the entire lowered source graph, or check the
complete Wasm reference subtype relation. Fixed-point transfer audit is separate
work.

## Validation

The first build found a missing newline in the new Bool helper (16.548 seconds).
The first call-record test also used a raw function index where the plan stores
an internal handle. The numeric record checker rejected that invalid fixture;
its anonymous fixture trap was not counted as a passing invariant test
(65.886 seconds). The corrected fixture checks the exact handle before mutation.

Final hardening passes 499 tests, 169 exact numeric records, and all shared
execution corpora (63.529 seconds). This includes selected target, evaluation
order, operand kind, operand source, array bounds, and original-owner freeze
checks. Cached pattern subject IDs have a separate check: an evaluation helper
which erases those IDs is not a valid freeze certificate.

Integration passes all 268 tests (64.360 seconds). Library execution passes its
326 tests and all shared corpora (27.971 seconds).

The initial bootstrap exposed an anonymous failure while preparing a generic
Array method Self type (64.335 seconds). That assertion now records SPC-301,
phase 4, the request declaration, specialization, and resolved Self type. The
diagnostic rerun identified Array declaration 29, request 1884, and Self type 198
(61.068 seconds). The initial generic copying loop is unnecessary: the final
freeze witness uses ordinary `Array.copy()` calls. This reuses the library
implementation and does not claim to fix the separate generic iteration issue.

The final clean bootstrap passes (185.272 seconds). B and C have identical raw
and linked SHA-256 hashes:
`6cf6f902fb103fdba3a04af0848fd0b6c285093fd173793befb5def716586f74`.
The hardening and integration timings above precede the switch to library copy;
the final bootstrap checks the complete final production source.

A new, separate shared Array regression exposed missing Unit pattern storage in
a generic iteration copy (3.060 seconds). It remains visible for the next patch;
it is not counted as a passing case in this freeze batch. Runs above 30 seconds
remain timing defects; this change does not include speed work.
