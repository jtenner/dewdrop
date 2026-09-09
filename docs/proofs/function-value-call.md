# Function-value call identity and result

This note records the result-carrier rule for a call that lowering stored as a
function-value call even though its target still names a static callable.

## Current contract

The priority rule below is historical and is superseded. A selected target's
declaration, specialization, and physical signature must agree with the call
plan. Source expected types add constraints; they cannot overwrite a concrete
disagreement or make a missing target look present. A broad `eqref` label is
not a heap-type or nullability proof.

The emitter now reads only the frozen expression target and call recipe.
It checks the linked position, declaration, specialization, and encoded
function handle. Missing records cannot be replaced by plain-function or
name lookup. Static-looking function-value calls use their selected target;
other calls require a runtime value owned by the caller body. The instruction
emitter has no method-name, runtime-name, or `into` spelling recovery. See the
[target-read tests](../research/frozen-call-target-reads-2026-09-09.md).

Address-taken raw builtins now have explicit outlined-instruction fragments
in both compilers. They load the physical parameters and emit the declared
instruction without host imports. Compile-time queries remain signature-only.
Scalar/SIMD/memory signatures are checked; scalar unsafe bitcasts retain the
equal-carrier rule. Parameterized heap wrappers remain open.

Wasm erases Never to no result values. Indirect-call dispatch must restore
the non-returning state with `unreachable`, so a surrounding value-producing
branch cannot fall through with an empty stack. Unit still falls through.
These paths are checked and tested by the
[outlined intrinsic corpus](../research/outlined-intrinsics-2026-09-08.md).
The complete call-stack preservation theorem remains open.

## Historical evidence order (superseded)

Let `P(e)` be the early planned result shape, `D(e)` the declaration selected
from the retained call target, and `Σ(D(e))` its callable signature.

The former implementation used this result priority:

\[
\operatorname{ExactScalar}(P(e))
\succ
\operatorname{Result}(\Sigma(D(e)))
\succ
\operatorname{ExpectedType}(e)
\succ
P(e).
\]

A broad `ref` plan is not an exact scalar certificate. Therefore:

\[
P(e)=\mathtt{ref}
\not\Rightarrow
\operatorname{ResultShape}(e)=\mathtt{ref}.
\]

## Static target rule

\[
\frac{
  \Gamma\vdash q:n
  \qquad
  \Gamma;\Delta\vdash q.n\Downarrow d
  \qquad
  \Sigma(d)=\tau_1\times\cdots\times\tau_k\to\tau_r
}{
  \Gamma;\Delta;\Sigma\vdash q.n(e_1,\ldots,e_k):\tau_r
}
\;\textsc{Retained-Static-Call}
\]

Carrier preservation follows:

\[
\operatorname{ResultShape}(e)=\tau_r
\Longrightarrow
\operatorname{ExactCarrier}(e)=\mathcal C(\tau_r).
\]

For the compiler failure that caused this note:

\[
\begin{aligned}
D(e) &= \mathsf{u32\_into\_u64}, \\
\Sigma(D(e)) &= \mathsf{U32}\to\mathsf{U64}, \\
\mathcal C(\mathsf{U64}) &= \mathtt{i64}, \\
\therefore\quad\operatorname{ExactCarrier}(e) &= \mathtt{i64}.
\end{aligned}
\]

Status: concrete carrier checks are **checked and tested**. The historical
priority rule is not a current proof premise.
