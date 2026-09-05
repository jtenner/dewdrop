# Collection expression arena correctness

The packed `Into` runtime regression exposed an out-of-bounds write in native
collection, before inference. Block assignment and index-set expressions appended
to the expression and file arenas, but not the explicit call type-argument arena.
A subsequent generic call indexed the shorter arena with its expression ID.

All three arrays now append through `CollectionBuilder::append_expr`. The separate
`emit_expr` helper also records the expression on the lowering work stack; block
mutation expressions do not. `ARN-103` checks parallel lengths before each append.
The self-host collector already uses its common expression append helper for both
mutation forms.

The regression covers both assignment forms followed by an explicit generic call
in another body. It checks parallel lengths and that only the call owns the type
arguments. Before the fix the test aborted at the invalid array write (10.072 s).
After the fix all 13 body HIR tests pass (see measured test output).
