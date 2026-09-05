# Stack is library code

`std/collections/stack.dew` now defines all eleven operations as ordinary Dew
functions. `Stack<t>` remains an alias of `Array<t>`, and its iterator remains an
alias of `ArrayIter<t>`. Empty peek returns `None`; nonempty peek reads the final
array element without mutation. Other operations delegate to the public Array
API. No Stack builtin or declaration-ordinal dispatch remains in lowering or
the builtin registry.

This removes Stack's compiler-owned behavior, but does not complete the Array
migration: Array's implementation still uses opaque operations. Stack will use
the new Array implementation through the same public API when that change lands.

The integration test checks that every Stack callable has a Dew body. It failed
before migration and passes now. The existing `collections/stack-runtime`
fixture checks empty pop/peek, aliases, LIFO removal, nonmutating peek, clear,
and iteration. Node and Wago both pass, and two compilations produce identical
Wasm. Its WAT snapshot changed to include ordinary Stack calls and bodies; the
expected diagnostics and output did not change. The cached fixture run takes
0.58 seconds. Rebuilding the native snapshot tool exceeded 30 seconds and
remains a build-time performance bug.
