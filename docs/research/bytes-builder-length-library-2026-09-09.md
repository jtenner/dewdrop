# BytesBuilder length and lifetime checks in Dew

`bytes_builder_byte_length` is now an ordinary Dew function. It checks the
consumed flag through `struct.get 2`, traps if it is nonzero, and reads the
logical length through `struct.get 1`. Both raw reads retain the primitive
BytesBuilder owner. This does not confuse capacity with length or make a
finished builder reusable.

Both runtime dispatchers and the native fragment registry remove the old
length operation. The shared length builder remains for StringBuilder until
that separate data-type migration. The shared Bytes corpus adds live alias
reads, direct and aliased use-after-finish traps, and a returned length
function. It must pass in both compilers.

The policy has four intended failures (0.032 seconds). The provider test has
one intended failure out of 21 (5.956 seconds). All 21 provider tests pass
after removal (6.036 seconds). Provider commit `c5d3d0a51` builds in 9.438
seconds; all 476 selected signatures survive consumer refresh (3.931 seconds).
Provider SHA-256:
`72a70a4f25bd874b05f365930c71023226b97ddadd6b7ae9669fa1ac07eb1f22`.

The library lane passes in 43.354 seconds, including all 26 shared Bytes
checks. Self-host hardening passes all 801 tests, 401 exact records, and shared
corpora in 86.173 seconds, using the script's existing debug native profile.
The profile changes the host compiler build, not the emitted program checks.
Generated checks pass in 17.833 seconds. Runs above 30 seconds remain timing
bugs. The later StringBuilder length batch passes clean bootstrap in 175.134
seconds with identical B/C bytes; see its
[validation log](string-builder-length-library-2026-09-09.md).
