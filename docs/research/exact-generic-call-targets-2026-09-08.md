# Exact generic call targets

Two native regressions demonstrate why a physical carrier cannot select a
logical specialization:

1. `signed<I32>` and `signed<U32>` fold a type query to different Boolean
   constants, but both specialization shapes canonicalize to I32. After
   extracting the old lookup unchanged, it returns the first function instead
   of reporting ambiguity (one failed test, 10.099 seconds).
2. Starting from a valid, Wasm-validated program with only `signed<I32>`, remove
   its exact call-map entry. The old emitter still emits `Call(FuncIdx(1))`
   instead of reporting the missing target (one failed test, 8.864 seconds).
   A unique physical match is still not proof of logical identity.

The emitter now requires an exact map entry for calls with type arguments.
It checks the map's table index before reading it and checks the selected
declaration and instance against the retained target witness. Missing exact
mappings produce SPC-304; invalid
table indices produce ARN-101; wrong declarations produce ABI-701. These are
returned `CompilerInvariantFailure` diagnostics with all nine numeric fields,
including phase 7, caller module/body/expression, and expected/actual values.
There is no carrier-based target recovery in direct call emission. Plain
non-generic lookup retains its separate checked path.

The two physical-shape lookup APIs now share a checked, unique-candidate
lookup. It rejects ambiguous matches with SPC-304 and leaves absent matches
missing. Elided functions and generated export adapters are not source
specializations. Input and stored shape spans are checked before indexing;
Generic and Error leaves produce SPC-301, including nested product leaves.
These APIs compare physical shapes only. They do not prove a logical target
and are no longer used to recover a missing generic call during emission.

Lookup records use phase 5 and the requested declaration. Body is zero and
expression is the missing sentinel because these APIs have no caller context.
Detail roles in the high 32 bits are: input span 1, input shape 2, module index
3, stored span 4, stored shape 5. Span failures pack start and length in actual;
shape failures report Generic as 1 and Error as 2. Ambiguity uses detail zero,
expected one, and actual candidate count.

Seven semantic tests pass in 12.576 seconds. The initial single backend test
passes after the fix in 9.777 seconds. An intermediate compile failed because
the backend cannot construct a read-only semantic call key; the existing
structured-key constructor is now shared publicly, without changing its
encoding. The expanded backend test passes in 8.863 seconds. It restores the
valid target after each single-field mutation and checks all numeric fields
for missing mappings, two invalid indices, and a wrong valid declaration.
Scoped semantic/backend interface generation passes in 3.828 seconds. The
first unscoped `moon info --target native` command failed in 4.520 seconds:
it tried unrelated bootstrap platform and benchmark packages. That command is
not a passing validation result.

The first full native lane failed five existing trait-callback cases in
146.225 seconds. Comparing the selected declaration with the source call's
declaration was too strict: a trait requirement is correctly replaced with
its implementation. The link now retains each selected target's declaration,
structural specialization key, physical function index, and function-table
index in a separate witness map. These are checked before emitting the call.
The check therefore permits an explicit trait implementation selection while
rejecting replacement with a different instance of the same declaration.
The five trait-callback cases pass in 10.224 seconds. Two emitter tests pass
in 9.293 seconds, including a real same-carrier instance substitution and a
missing witness. The physical linker checks declaration/key identity before
recording a witness; a different replay produces SPC-303 without changing it.
The two semantic witness tests pass in 9.825 seconds; they check exact replay,
changed instance/index, rejected publication, and preservation of the original
witness. Interface generation passes in 3.836 seconds. Full native tests pass
(1,123 tests, 159.569 seconds), integration passes (268 tests, 57.311 seconds),
and the Dew library passes (326 tests and all shared runtime cases, 32.837
seconds). The remaining serial lanes also pass:

- Self-host: 450 tests, 137 exact failure records, and all shared runtime and
  semantic probes, 146.001 seconds.
- Clean bootstrap: 168.844 seconds. B/C core and linked bytes match:
  `577075c3e5f27f53387b4e3ed1125ae019963c47c9ff487a8eba4630196d0ec8`.
- Generated source and policy checks: 12.842 seconds.
- Stress: 15 tests, 0.351 seconds.

Provider and FFI files are unchanged. Runs above 30 seconds remain speed bugs;
no speed work is included.

This does not complete all frozen-call proofs. Other lookup consumers must
also use the witness, hidden evidence operands need their own retained recipe,
and singleton references and complete heap/nullability checks remain separate
work. The link is built from cached fragments; no link codec was changed.
