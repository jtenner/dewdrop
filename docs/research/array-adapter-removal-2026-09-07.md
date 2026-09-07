# Remove old Array specialization and storage adapters

Array algorithms already have Dew bodies. This change removes three obsolete
compiler paths that could hide a missing selected call or assume an old layout:

- Specialization no longer searches for `dew_array_iter` to identify an Array
  module, then picks a callable from its name and argument count.
- Unit specialization no longer creates a second reference-shaped request for
  an old Array builtin. Emission no longer constructs its hidden reference
  marker wrapper. Unit storage uses the checked raw-array contract in library
  bodies instead.
- Native inline builtin emission no longer looks up the standard Array wrapper
  or reads guessed fields for old backing-length targets. Its interface no
  longer takes an Array type or storage base.

The two new source-policy checks failed before removal. A native regression
checks the exact `UnsupportedBuiltin` target for both removed backing-length
aliases. The shared Unit, Array, raw-storage, stack, and iterator probes remain
enabled.

This does not yet remove Array literal construction or every old self-host
emitter branch. Those still need their own checked construction/call recipes.

## Measured checks

- Array policy: 12 passed, 0.064 seconds.
- Focused native Array tests: 3 passed, 17.453 seconds for the filtered lane.
- Self-host hardening: 238 tests, 29 exact failure records, all shared probes
  passed, 65.358 seconds.
- Native integration: 268 passed, 49.462 seconds.
- Generated sources and CLI fixtures: passed, 9.421 seconds.
- Clean bootstrap: passed, 165.336 seconds. Compiler A build took 42.312 seconds;
  A and B compiler execution took 43.562 and 55.072 seconds.

Compiler B/C core and linked output agree. Linked SHA-256:
`a761cba0e29450c19ffb915099255745c2405e042656d7a7fff74cf0b82b6701`.
All durations above 30 seconds remain performance bugs.
