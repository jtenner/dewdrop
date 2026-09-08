# Intrinsic source names must not select host calls

The minimal source declares `wasi_probe_fd_write(I32, I32) -> I32` with the
instruction metadata `i32.add`, then calls it from `main`. The self-host emitter
instead selects hard-coded import 6 from the declaration spelling. Validation
fails at function 16, instruction 2, with stack underflow. The focused old
compiler probe fails in 0.156 seconds. This is a direct behavior defect, not
just an absent assertion.

The native compiler uses the instruction metadata correctly. The expanded
fixture covers all 16 old WASI suffixes, an exact `fd_write` name, and a function
reference to one alias. All 18 cases pass natively (compile 0.404 seconds,
execute 0.022 seconds). Native test generation retains its assertion writer;
an initial assumption of zero imports was incorrect. The check permits that
single writer but traps if arithmetic calls it. No other import is allowed.

Source inspection also finds sixteen unconditional WASI imports and signatures
in self-host emission, a logical-to-tagged-function offset of two, and a tagged-
to-emitted offset of fourteen. Together these conceal the fixed import prefix.
Initializers, startup, exports, and validation diagnostics add/subtract sixteen
directly. The text-runtime type base also reserves sixteen signature slots.

The corrective batch must remove the name-based call tasks, unconditional
imports/signatures, and their offsets together. Linked imports already precede
definitions in the checked link table, so ordinary source foreign declarations
must supply their actual indices. The separate two-slot internal function-handle
encoding is not an import count; its checked decoding must remain distinct.
The text-runtime base must start after the actual linked function signatures.
The emitter now does that: the WASI-specific tasks, dispatch, import/signature
builders, forced import retention, and prefix offsets are removed. Function
handles retain their two reserved internal slots, but decode to the actual link
table index. Encoding cannot reach the missing sentinel or wrap; decoding
rejects zero, one, and the missing sentinel before subtraction. Four negative
tests check complete numeric records, and boundary round trips include indices
on both sides of the former sixteen-import boundary and the maximum valid
tagged index.

The first expanded source probe exposed a separate gap: a raw builtin cannot
yet be used as a first-class function in the self-host compiler (BOD-607 at the
reference). The fixture also used `unreachable` without declaring it in the
standalone, no-preamble probe. The direct-call fixture now has a plain scalar
fallback and 17 call cases. The function-reference case is retained separately
in `tools/dew-test/intrinsic_function_reference.dew`, for the next correctness
batch. This is not reported as fixed or counted as a passing self-host case.

All 17 direct-call cases pass in the self-host compiler (0.133 seconds), with
zero imports. The initial pre-boundary-update hardening run is not final
validation. The final run passes 467 tests, 141 complete numeric records, and
all emission/semantic probes (57.379 seconds). Native library checks pass
326 tests and all shared cases, including the 17-name corpus (25.755 seconds).
The clean bootstrap passes in 167.497 seconds, with identical B/C SHA-256
`7491c1dc0a1944da8dd21f302bc999f9f093bdd5b574cbcf59c30e253a0973ae`.
Generated checks pass in 4.072 seconds. Native implementation and provider code
are unchanged from the preceding fully validated Bytes batch. No speed work
is included.
