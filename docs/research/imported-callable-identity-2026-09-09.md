# Imported function values must not use export positions as source indices

Adding private raw field helpers for StringBuilder exposed a native type
error in a returned BytesBuilder length function. The exported callable list
omits private functions, while `resolved.callable_function_types` is indexed
by all source callables. Both native import paths used the exported position
to index that full source array. The resulting function type could belong to
another declaration. Ordinary direct calls could still work because their
parameter and result records were imported correctly.

The native importer now interns the function type from the selected callable's
own imported parameters and result. It never uses the exported position as a
source callable identity. The self-host interface already retains each
callable's function type alongside its declaration, so it does not use this
native positional lookup.

A small two-module fixture fails before the fix (9.331 seconds): a private
I32 function precedes an exported I64 function returned by its consumer. The
first corrected run passes (26.672 seconds). The full native run passes 799
of 800 semantic tests but exposes an unsupported qualified-function-value
form in an added test case (134.492 seconds). That case is not an export-index
test. Namespace coverage now uses a supported qualified call and inspects the
imported function type directly; open-import returned functions and generic
binders remain covered. This index fix does not add new namespace-value syntax.

The two corrected focused tests pass (26.779 seconds). The full native
integration lane passes (58.721 seconds), as does the library lane (37.191
seconds), including the original BytesBuilder function-value regression and
all 23 String checks. Runs over 30 seconds remain timing bugs; no speed work
is included in this change.
