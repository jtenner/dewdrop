# Fixed-array get carrier

This note records the carrier rule for `get_unchecked` and `indexed_get`.
It was added after compiler B classified a `FixedArray<U32>` read as `eqref`.

## Definitions

Let:

\[
\begin{aligned}
\Gamma &\vdash a : \mathsf{FixedArray}\langle\tau\rangle, \\
\Gamma &\vdash i : \mathsf{U32}, \\
\mathcal C &: \mathsf{Type} \to \mathsf{Carrier}.
\end{aligned}
\]

The canonical heap type describes the array object. It does not describe the
value returned from one slot:

\[
\mathcal H(a) = \mathsf{arrayref}_{\mathcal C(\tau)}
\quad\not\Rightarrow\quad
\mathcal C(a[i]) = \mathtt{ref}.
\]

Receiver syntax can contain lowering wrappers. Define normalization by:

\[
\begin{aligned}
\mathcal N(\mathsf{Consumed}(e)) &= \mathcal N(e), \\
\mathcal N(\mathsf{Field}(e,n)) &= \mathcal N(e), \\
\mathcal N(e) &= e
  \quad\text{when }e\text{ is neither wrapper.}
\end{aligned}
\]

The compiler uses one bounded implementation of `𝒩` for declared-element and
canonical-heap recovery. This prevents two type checks from using different
receiver expressions.

## Typing rule

\[
\frac{
  \Gamma \vdash a : \mathsf{FixedArray}\langle\tau\rangle
  \qquad
  \Gamma \vdash i : \mathsf{U32}
}{
  \Gamma \vdash \mathsf{get\_unchecked}(a,i) : \tau
}
\;\textsc{Array-Get}
\]

## Carrier theorem

For all element types with a known physical carrier:

\[
\forall\tau.\;
\mathcal C(\tau) \neq \mathsf{unresolved}
\Longrightarrow
\operatorname{carrier}(\mathsf{get\_unchecked}(a,i)) = \mathcal C(\tau).
\]

For an unresolved generic method call with specialization `σ`, receiver
argument recovery gives the same result:

\[
\frac{
  \operatorname{ReceiverArg}(e,0)=\tau
  \qquad
  \operatorname{Specialize}(\tau,\sigma)=\tau'
  \qquad
  \mathcal C(\tau')\neq\mathsf{unresolved}
}{
  \operatorname{ExactCarrier}(e,\sigma)=\mathcal C(\tau')
}
\;\textsc{Unresolved-Array-Get}
\]

This certificate has precedence over a generic linked result carrier.

For the failing case:

\[
\begin{aligned}
\Gamma &\vdash a : \mathsf{FixedArray}\langle\mathsf{U32}\rangle, \\
\mathcal C(\mathsf{U32}) &= \mathtt{i32}, \\
\therefore\quad
\operatorname{carrier}(\mathsf{get\_unchecked}(a,i)) &= \mathtt{i32}.
\end{aligned}
\]

## Precedence lemma

Let `DeclaredElement(a)` be the element shape from the receiver's declared
type and let `Heap(a)` be its canonical run-time array type. Then:

\[
\operatorname{ExactScalar}(\operatorname{DeclaredElement}(a))
\Longrightarrow
\operatorname{ResultShape}(a[i]) = \operatorname{DeclaredElement}(a).
\]

Only when the declared element shape is absent, generic, or reference-shaped
may the compiler use `Heap(a)` as a physical fallback.

Emission can also produce a more precise result than the early canonical
plan. Let `Refine(e, τ)` mean that emission selected `τ` for `e`. Then:

\[
\frac{
  \operatorname{Refine}(e,\tau)
  \qquad
  \operatorname{ExactScalar}(\tau)
}{
  \operatorname{ResultShape}(e)=\tau
}
\;\textsc{Refined-Result}
\]

Therefore the evidence order is:

\[
\operatorname{RefinedResult}
\succ
\operatorname{DeclaredElement}
\succ
\operatorname{CanonicalHeapFallback}.
\]

## Run-time obligation

Before emission, Starshine checks:

\[
\operatorname{carrier}_{expected}(e)
=
\operatorname{carrier}_{selected}(e).
\]

A mismatch stops compilation and reports the module, declaration,
specialization, expression, expected carrier, and selected carrier.

Status: **Checked**. The compiler assertion is active. Bootstrap verification
is in progress.
