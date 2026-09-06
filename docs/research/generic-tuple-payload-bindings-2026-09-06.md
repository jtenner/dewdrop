# Generic tuple payload bindings

The native fast match path selected its implementation from unspecialized
pattern shapes. A generic payload later specialized to a tuple still used one
local.set for a boxed reference, although the destination had scalar locals.

Both match-path selection and scratch planning now use specialized shapes.
Tuple payloads use the existing general matcher, checked product unboxing, and
ordered scalar local stores. Dense enum dispatch uses the same decision.
There is no Map-specific rule or new boxing format.

The minimal native regression validates emitted bytes, not only the module IR.
It failed before the fix (9.003 seconds) and passed afterward (9.176 seconds).
Shared execution now checks a generic user enum with an I32/I64 tuple payload.
Native library checks passed (12.304 seconds); self-host hardening and shared
checks passed (53.829 seconds). The latter remains a performance bug over the
30-second limit.

The Map prototype now passes this boundary. It exposed a separate reference
field-write issue: a raw-array read supplies eqref to a nominal field without
the field's declared heap-type adapter. That is a separate compiler fix.
