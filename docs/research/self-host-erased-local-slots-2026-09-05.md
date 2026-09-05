# Unit/Never local-slot projection

Local IDs are logical arena IDs, not physical Wasm indices. Source Unit/Never
locals now have no physical slot. Local reads, writes, local allocation, scratch
offsets, and hidden capture-cell offsets use the same source-shape projection.
Erased let initializers and assignments still execute; they do not produce a
local.set operand. Unit captures retain no physical field.

The full callback fixture previously failed at `unit_middle`'s third logical
parameter: it emitted local.get 2 although Unit erasure left only two parameters.
It now passes that boundary and reaches a separate product-construction defect:
the existing boxed tuple representation reserves fields for Unit but does not
materialize their explicit field values.

Validation: 123 hardening tests and 24 numeric records pass. The reference lane
now passes 66 execution checks, adding Unit parameters at both ends, a lambda
with Unit in the middle, and a Unit local captured beside an I64 value. The full
hardening lane took 15.909 seconds. Its full callback matrix remains enabled and
fails visibly at product construction. Generic parameters specialized to Unit
still need coverage beyond this source-shape projection.
