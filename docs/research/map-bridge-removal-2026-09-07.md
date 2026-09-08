# Remove the old Map provider fallback

## Source finding

The Dew library already owns Map storage and algorithms, and both compilers
pass the shared Map corpus. The pinned provider still has an unused second
implementation in `starshine-mb/src/ffi_bridge/map_runtime_bridge.mbt`.
`funcs_push_runtime` can dispatch seven old Map names to that implementation.
This must be removed, not retained as a fallback.

The old Array and Map builders share layout and append helpers. Array's public
push helper even dispatches Map insertion for encoded carrier pairs. Remove the
Array operations first, keeping only the helpers still required by Map, then
remove Map. After both removals, carrier and Option-type arguments are unused
and must leave the public signature, provider metadata, and Dew consumer
together.

## Implementation and tests

Removed the complete old Map implementation and its six shared Array layout
helpers. The provider has no collection-runtime fallback. Its constructor now
takes three arguments: text type base, UTF-8 validator index, and write index.
Removed the four collection carrier/Option layout fields and arguments from
the provider, public interface, generated wrapper, and Dew emission call.
The Dew caller no longer computes or forwards those unused facts.

The new policy test fails before removal (five subtest failures, 0.037 seconds).
The bridge regression fails before removal (13 pass, one failure,
6.752 seconds). Public interface refresh takes 0.961 seconds; generated wrapper
refresh takes 4.041 seconds. The Array boundary test retains all 18 names;
carrier permutations are no longer expressible through the constructor.

All 14 focused bridge tests pass in 6.847 seconds. Three Map policy tests pass
in 0.041 seconds, and all 16 Array policy tests pass in 0.074 seconds.
The provider change is committed as `6eb2734a8`. Provider rebuild takes
10.767 seconds; consumer regeneration takes 4.053 seconds. All 469 selected
FFI signatures are regenerated against the new constructor.
The full self-host hardening lane passes in 69.986 seconds: 325 tests, 75 exact
failure records, and all shared corpora. Real Array passes 29 checks
(0.981 seconds), Map passes 12 (1.477 seconds), and Set passes eight
(1.542 seconds). The new FFI constructor is used by the emission probes.
The generated-source lane passes in 3.824 seconds. Fresh native Map compilation
takes 0.587 seconds and all 12 checks pass in 0.023 seconds. Fresh native Set
compilation takes 0.595 seconds and all eight checks pass in 0.024 seconds.
Broad final lanes remain due after the next
batches. This is correctness and API cleanup, not speed work.
