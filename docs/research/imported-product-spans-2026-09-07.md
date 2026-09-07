# Imported product spans

The native interface importer treated `ProductType` as a simple type. It copied
the field span from the source interface into the receiving type arena. That
span could be in range but identify unrelated fields in the receiving module.
An imported `(I32, I64)` payload was read as unrelated local signature types.

Product imports now walk every field in source order and intern the translated
field list in the receiving arena. Nested products use the same work stack as
applied and function types. Repeated equal products share structural identity.
The simple-type path rejects a product instead of copying a foreign span.
Source and destination product spans are checked before field reads.

Tests do not depend on the new match-pattern syntax. They use existing product
`let` bindings and inspect the imported type graph directly. Both focused tests
passed in 9.310 seconds. The new imported match-pattern test also passes after
this change: four product-pattern inference tests, 9.366 seconds.

This is an atomic import fix found during the larger tuple-pattern batch.
Full compiler lanes and the bootstrap will run at that batch's close. No speed
work or format-version change is included.
