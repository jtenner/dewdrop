# Indexed arithmetic uses its frozen carrier

The real Map corpus exposed a self-host emission error in
`values[0u32] + values[1u32] == 4.0f32`. Both indexed reads and addition emitted
F32, but a later comparison recovered I32 from the receiver's first type
argument. The final Wasm validator rejected `i32.eq` with F32 operands.

Binary expression carrier reads now use the verified physical body plan, as
indexed reads already do. Emitter-side receiver-shape recovery cannot replace
the frozen arithmetic result carrier. Comparison results still use I32; the
operand instructions use their own full planned scalar carriers.

The shared member-call fixture adds indexed F32 and F64 arithmetic followed by
equality. It uses an ordinary user-defined generic IndexedGet implementation,
not Map names or standard-module identity. The Map corpus retains the original
case too. Full self-host hardening passed: 230 tests, 29 exact invariant
records, and the shared corpora in 57.584 seconds. The real Map corpus passes
all 12 checks in 1.524 seconds. The member fixture passes all 10 checks.
The full run exceeds 30 seconds and remains a performance bug. These runs
include the pending Map migration in the worktree.
