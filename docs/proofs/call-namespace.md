# Namespace call and stack proof

Date: 2026-09-04

## Failure

The self-hosted emitter treated `StarshineFfi` as a run-time method receiver.
It emitted a poison expression before a static FFI call. The old output trapped
at run time. After poison emission became an error, the compiler reported:

```text
linked emitter reached a poisoned expression ...
declaration_name=self_host_emit_linked_builtin ...
source_name=StarshineFfi
parent=unresolved-field ...
parent=unresolved-call-target
```

## Static selection

Namespace lookup:

\[
\frac{\Gamma(q)=\mathsf{Namespace}
      \qquad \Delta(q,n)=d}
     {\Gamma;\Delta\vdash q.n\Downarrow d}
\;\textsc{Select-Namespace}
\]

Static call typing:

\[
\frac{
  \Gamma;\Delta\vdash q.n\Downarrow d
  \qquad
  \Sigma(d)=\tau_1\times\cdots\times\tau_m\to\tau_r
  \qquad
  \forall i\in\{1,\ldots,m\}.\;
    \Gamma;\Delta;\Sigma\vdash a_i:\tau_i
}{
  \Gamma;\Delta;\Sigma\vdash q.n(a_1,\ldots,a_m):\tau_r
}
\;\textsc{Call-Namespace}
\]

The key negative fact is:

\[
\boxed{
\Gamma(q)=\mathsf{Namespace}
\Longrightarrow
q\notin\mathsf{RuntimeValue}
\land
\neg\operatorname{EmitReceiver}(q.n(\vec a),q)
}
\]

Plain English: `q` selects the function. It is not an argument.

## Emission

Assume each argument preserves its carrier:

\[
\forall i.\;
\Phi;\mathcal C\vdash
\langle a_i,S_{i-1}\rangle
\Downarrow
\langle I_i,S_{i-1}\cdot\mathcal C(\tau_i)\rangle.
\]

Define:

\[
S_i=S_{i-1}\cdot\mathcal C(\tau_i).
\]

If the linked function agrees with the logical signature,

\[
\operatorname{params}(\Phi(d))
=
[\mathcal C(\tau_1),\ldots,\mathcal C(\tau_m)]
\]

and

\[
\operatorname{result}(\Phi(d))=\mathcal C(\tau_r),
\]

then:

\[
\frac{
  \forall i.\;a_i\Downarrow I_i
  \qquad
  \operatorname{params}(\Phi(d))=\mathcal C(\vec\tau)
  \qquad
  \operatorname{result}(\Phi(d))=\mathcal C(\tau_r)
}{
  \langle q.n(\vec a),S\rangle
  \Downarrow
  \left\langle
    I_1;\cdots;I_m;\mathtt{call}\;\Phi(d),
    S\cdot\mathcal C(\tau_r)
  \right\rangle
}
\;\textsc{Emit-Call-Namespace}
\]

No derivation emits \(q\).

## Current status

The compiler now shares one namespace predicate between lowering validation and
the emitter. It rejects poison and consumed expressions with a diagnostic.

The next obligation is still open:

\[
\boxed{
\operatorname{params}(\Phi(d))
=
[\mathcal C(\tau_1),\ldots,\mathcal C(\tau_m)]
}
\tag{ABI-Call-Args}
\]

The current compiler-B build reaches this check and Starshine reports a stack
type mismatch in `self_host_emit_linked_builtin`. This means static call
selection is now correct, but its linked physical signature or argument carrier
plan is not yet correct.

## Required checks

Before a call is emitted, assert:

\[
\begin{aligned}
&d\ne\bot, \\
&\Phi(d)\ne\bot, \\
&|\operatorname{params}(\Phi(d))|=m, \\
&\forall i<m.\;
  \operatorname{params}(\Phi(d))[i]=\mathcal C(\tau_i), \\
&\operatorname{result}(\Phi(d))=\mathcal C(\tau_r).
\end{aligned}
\]

Each failed condition must report the module, body, expression, declaration,
argument index, expected carrier, and actual carrier.

## Direct linked-function lookup

The direct lookup is valid only when all stored identities agree.

```text
0 ≤ i < |F|    F[i].index = i    owner(d) = m
F[i].module = m    F[i].declaration = d
──────────────────────────────────────────────
linked_function_matches(F, i, d)
```

Checking only `F[i].module = owner(d)` is not sufficient. Two declarations can
have the same module owner. In that case, a module-only check can accept the
wrong function and give its body plan to the caller.

## Exact call-site specialization precedes receiver recovery

An unresolved method call can still have an exact specialization recorded by
its caller body, caller specialization, and expression:

```text
specialized_call(b, σ, e) = i
──────────────────────────────
target_function(b, σ, e) = i
```

Receiver-and-name lookup is a fallback only:

```text
specialized_call(b, σ, e) = none
receiver_method(receiver(e), name(e)) = i
─────────────────────────────────────────────
target_function(b, σ, e) = i
```

Reversing these rules can select an arbitrary `Map.get` specialization. It can,
for example, assign an `i64` payload to `Map<U32, U32>.get`, whose payload must
be `i32`.
