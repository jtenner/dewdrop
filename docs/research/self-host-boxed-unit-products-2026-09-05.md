# Unit values in the existing boxed product representation

The self-host currently represents products as nested GC pairs. A logical Unit
field has a nullable-reference marker in that layout; this is different from
the native compiler's flattened product ABI. Construction now explicitly emits
the null marker after the Unit expression executes. Projection consumes the
marker and leaves no physical value. The emission carrier check models that
unboxing step as Unit, not eqref.

This is a representation operation, not a conversion of unknown/error evidence
to a reference. Unit call arguments and locals remain physically erased. Changing
the legacy pair layout is separate from correcting its stack contract.

The shared self-host callback test now uses a typed `main` wrapper for each
oracle entry: the standalone self-host driver exports its entrypoint, not every
public source function. All original 66 shared cases execute; none are skipped.

Validation: the entire hardening lane passes in 15.884 seconds: 123 hardening
tests, 24 numeric records, 78 reference/capture/Unit checks, all 66 shared callback
checks, and the existing arithmetic/conversion/memory/math matrices. New cases
read a Unit product field and check source-order effects on both ends of an I64
product. A clean bootstrap is next.
