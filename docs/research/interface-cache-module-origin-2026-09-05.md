# Interface cache membership needs source provenance

## Reproduction

While running the new memory execution matrix, compiling `dew.std.conversions`
followed by `dew.std.memory` failed with:

```
frozen-interface cache contains unavailable module dew.std.conversions
```

The bundle policy treated every module whose name began with `dew.std.` as a
standard dependency, including the current root and user-supplied workspace
modules. The bundle key covered the loaded library sources, not those workspace
sources. Two different programs could therefore select the same key and cache a
root from the previous program. This is a correctness defect, not a cache miss.

## Fix

Collection now records the manifest-module prefix length. Bundle membership uses
that recorded provenance: loader-supplied modules follow the manifest prefix;
manifest dependencies require the explicit dependency policy; the root never
belongs to the dependency bundle. No module-name prefix or declaration ordinal
is used. Bounds assertions protect the origin boundary and module index.

The version-1 key domain now includes the module-origin policy. This prevents
reuse of old bundles built with the incorrect policy without deleting user cache
files or silently treating malformed cache records as valid. An empty source
fingerprint still disables caching. Dependency fingerprints remain part of the
key.

## Validation

The regression failed before the fix because a user module with a standard-like
name was cacheable. After the fix, seven cache tests pass (3.298 seconds). They
cover both a standard-like root and a standard-like non-root workspace module,
explicit dependency selection, and a one-field loaded-module name mutation.
The complete standard-loader lane passes all 17 tests (3.703 seconds).

The previously failing library execution sequence now passes: 296 library tests,
750 scalar conversions, and 201 memory checks (18.542 seconds). The memory work
that exposed this bug remains a separate implementation commit.
Repeating the same library sequence with warm caches also passes (3.025 seconds).
