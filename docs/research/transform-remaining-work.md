# Remaining transform work

This file records intended implementation rules. It is not a completion claim.
Use `docs/transform-features.md` for tested status.

## Signature changes

Add optional signature and call-adapter fields to FnNode. Preserve them in every
body builder, including the free with_body function. A new signature contains
structured parameter and result TypeNodes. Original generic parameters and
bounds remain in the declaration header. Type rendering must validate names,
structure, nesting and total size; normal final checking remains mandatory.

Require an explicit old-ABI adapter when calls need conversion. Generate a
fresh bridge in the original module with the old signature and this adapter
body. Rewrite existing checked direct calls and function references to that
bridge using declaration/site proof identity, including imported references.
Never repair a call just because its text has the same name.

Collect transform results before rendering so repairs can affect earlier files
and functions. Retain the physical identity of the initial Source expression
node and its original body range. Only this original source fragment is eligible
for checked-site repairs when it is retained inside a generated expression.
New user Source strings are new code and must receive normal final checking.
Fresh bridge names must include module, file and original function site and be
checked against existing source. Preserve public visibility and old generic
bounds on bridges. Tests must include imports, function values, recursive calls,
stacked transforms, same-named locals, aliasing, invalid adapters, and new calls
inserted as generated syntax.

## Memory and packed integers

Implemented in commit `2203a33065`. The controls below are the verification
contract; later self-host builds must rerun the actual request checks.

The current normal opcode catalog contains 88 scalar/vector memory operations.
Use that exact catalog, including canonical lane immediates. The normal compiler
creates one zeroed 64 KiB memory page. Drafts in `.tmp/transforms-v4/memory/`
use a lazy, interpreter-owned packed byte array of the same size. They charge
its allocation before construction and check the whole range before writes.
Memory must reset between transform applications. No host memory or new Wasm
instance is exposed. Instructions absent from the normal catalog remain errors.

Swar32 and Swar64 use the U32/U64 interpreter carriers, while checked reflection
and type queries retain their actual source types. Do not add library-name
execution paths. Validate public examples, all exact memory operations, signed
loads, float bit patterns, lane preservation, first/last valid ranges, overflow,
failed-store atomicity, allocation failure, and state reset in both engines.

## Dynamic traits

Retain exact checked dictionary evidence, trait declaration, requirement slot,
receiver, and logical type arguments. No runtime search by method name. Trait
wrappers retain receiver aliasing and distinct object identity; null dispatch
must trap. Generic implementations must use the checked implementation witness.
Dew normal checking needs explicit coercion and dynamic-call metadata before its
interpreter can support the feature. Do not accept an unchecked structural
substitute. Bytecode can use whole-function AST fallback for these forms first.

## Resource accounting

Use source-language events in both engines. Remove costs for implementation
lookup scans and path-key construction; retain actual source allocations and
work. Canonical text sizes must use UTF-8 bytes in both engines. Entry cold and
warm calls must have the same event order. Compare report counters, success and
failure thresholds across Native/Dew and AST/bytecode, including text, closures,
records, generic frames, short circuit and failed later arguments. Keep the
logical allocation ledger distinct from actual heap measurement.

## Persistent result cache

Cache expanded source and logical reports, never VM values, frames, or runtime
reference IDs. Include all manifest modules/files and byte contents, checked
source-pool dependencies, engine/API fingerprints, output selection, compiler
options and limits in the key. Coarse invalidation of unused dependencies is
acceptable and must be stated. Decode with bounds and checksums. Recheck final
generated code on a hit. Native and Dew must use separate engine identities
until resource accounting is identical. Use existing cache I/O and request bytes;
Wago must not need a new host function. Test reload in a fresh process, changed
helper/API/dependency/options, corruption, truncation and limit changes.

## Independent execution

Apply stacks in source order; isolate machine state per application; merge
outputs in original source order. A single Wago instance has no threads or
worker-creation host interface. True parallel work there needs an existing host
thread facility. A serial fallback must be explicit. Do not label a serial queue
as parallel execution. Any optional Native parallel backend needs measured wall
time and peak memory before being enabled by default.
