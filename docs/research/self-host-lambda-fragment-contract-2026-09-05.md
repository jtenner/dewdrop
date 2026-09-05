# Lambda fragment parameter contract

Lambda fragment creation now checks the complete local span, parameter count,
parameter-local role, source order, root body, and lambda identity before reading
or appending a parameter. Failure records use FRG-401 with phase, module, owning
declaration, body, parameter position, and local index. Unit parameters are
erased in source order after these checks.

The fragment's declaration is now its source body's declaration, not its body
ID. These are different arenas: a preceding struct exposes the old confusion.
The linked lambda ID remains separate from the named function identity.

Validation: 123 hardening tests and 24 exact numeric records pass. A valid
`fn(I32, Unit, I64) -> I64` fixture checks environment placement, scalar order,
and owning declaration. Two one-field mutations check excessive parameter count
and a non-parameter local. Test generation took 2.479 seconds; linking 4.841.
The full callback execution fixture remains enabled and still reports the
separate missing captured closure emission path.
