# Function-value call result recovery

This note records the result-carrier rule for a call that lowering stored as a
function-value call even though its target still names a static callable.

## Evidence order

Let `P(e)` be the early planned result shape, `D(e)` the declaration selected
from the retained call target, and `Σ(D(e))` its callable signature.

The safe result order is:

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

Status: **Checked**. Constructor scheduling rejects the call if its recovered
carrier does not equal the physical struct field carrier.
