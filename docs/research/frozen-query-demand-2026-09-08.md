# Query demand stays fixed during specialization

The self-host compiler classified some generic callees as query-dependent while
resolving an already selected caller. This changed the meaning of requests
which had already been created. A valid carrier-only request could suddenly
require logical arguments that it had never needed or retained.

There were two late writes: one for ordinary generic calls and one for generic
trait implementations. Both are removed. Initial source scanning already marks
query/projection bodies and bound trait calls, then closes that demand over the
caller graph. Selected implementations participate in that source scan too.
A generic declaration without those requirements does not become a query
instance merely because a query-dependent caller uses it.

No logical arguments are fabricated, no missing type becomes Ref, and the
SPC-301 concrete-Self check is retained. Trait witness selection and argument
recording remain unchanged. The native compiler already computes this demand
before requests; it needs no matching production change.

## Reproduction

Two small valid programs reproduce the error: a query-dependent caller followed
by an independent plain call to the same generic method, and a bound trait call
followed by an independent call to the same generic implementation. Both used
to fail SPC-301 when the earlier carrier-only request was revisited under the
new classification. Source order affected whether the error appeared.

The shared four-result corpus checks both selected callers and their independent
plain callers. Two self-host tests also require unchanged demand and valid
linked/body plans. The native corpus already passed before the production fix
(0.399 seconds). The combined self-host source failed before the fix (0.064
seconds), as did both individual source probes (0.065 and 0.068 seconds).
The full red hardening run failed both new compiler tests and the shared corpus
(63.654 seconds). After the change, all 523 compiler tests and 184 exact records
passed; the first runtime checker incorrectly expected extra exports from the
single-entry self-host harness (68.368 seconds). The checker now uses four
`main` cases in both compilers. That harness error was not counted as a pass.

An isolated compiler-source fixture also reproduces the original freeze-helper
failure: replace the twelve array-container `.copy()` calls with a generic
`for item in source { result.push(item) }` helper. Before the fix, the compiler
reports SPC-301 for an Array method (11.210 seconds). Production freeze code
continues to use the ordinary library `.copy()` method.

Final hardening passes all 523 tests, 184 exact records, and shared execution
probes (64.540 seconds). The library lane passes 326 tests and shared probes
(31.177 seconds); generated checks pass (5.092 seconds). Clean bootstrap passes
(203.051 seconds), with identical B/C raw and linked SHA-256:
`ade600c03225d48c93c93ddc605cb12f889c329427553e17619c588f2aa7a317`.

The fresh C compiler also compiles the isolated generic-copy source successfully
(73.445 seconds). Its output validates, with core SHA-256
`e1a47de3dda852b925a07d0b84a844490606791266f706a5ad4221016eb72186`.
This directly checks the original source case, not only the smaller regression.
The newly linked compiler then compiles that same source (72.006 seconds),
producing exactly the same validated core bytes. This exercises the generic
copy helper during compilation, not just its planning and emission.
Speed work remains out of scope; runs over 30 seconds remain recorded defects.
