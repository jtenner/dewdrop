# Imported trait signature ownership

An implementation of an imported `IndexedGet` exposed an unchecked cross-module
lookup. The checker decoded the trait's local ID and used it in the consumer's
generic-parameter table. A short consumer trapped. A larger consumer could read
an unrelated local declaration instead.

The checker now uses one resolved trait-signature view for local and imported
traits. The view keeps the owning generic-ID arena, method signatures, names,
receiver roles, and results. Trait owner parameters substitute through the
implementation's trait arguments. Method parameters substitute through the
local method's own generic parameters. Both paths use the same signature checks.
The importer now retains generic spans for trait declarations as well as types.
A missing trait view is a visible implementation diagnostic.

Local collected declaration-span lookups now check module ownership and table
bounds before indexing. A wrong owner publishes ARN-106 with the requested
declaration, expected module, actual module, and selected table before trapping.

Seven source tests cover valid owner/method generics and bad return types,
parameter types, generic counts, missing methods, and receiver roles. The trait
owner has padding declarations so that its local ID exceeds the consumer's
table length. Two negative invariant tests use a foreign ID whose low bits also
name a valid local entry; the host checks both complete numeric records.

The hardening lane now includes the existing local implementation and imported
semantics suites. All 161 tests and 27 numeric-record checks passed in
`/tmp/dewdrop-array-index-final-hardening.log`. That run still reported separate
index-emission failures from the new, uncommitted index corpus; it is not a claim
that the whole compiler migration or that emission run passed.
