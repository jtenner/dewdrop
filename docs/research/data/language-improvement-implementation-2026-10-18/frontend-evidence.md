# Historical frontend evidence

These records save small summaries from temporary logs. They are historical
records with separate test scopes. They do not establish that the final native
or compiler-C feature lanes passed.

- [Malformed string recovery](malformed-string-recovery.json) saves the native
  red and green assertions, package counts and timings, self-host red and green
  results, retained module hashes, and limits in the old logs. Its complete
  [self-host source manifest](malformed-string-self-host-source-sha256.json)
  identifies the 199 recorded source inputs.
- [Owner-cache loader tests](cache-owner-loader.json) saves the five passing
  file tests and 4.946-second lane. The surrounding native run exited with a
  failure in unrelated physical-type fixtures. It was not an all-green run.

Some old recovery logs contain no command line, process exit, or native build
hash. The JSON marks those fields unknown. Reproduction commands are labeled
separately. Timings quoted only in a research note have that origin recorded.
No missing identity was replaced with a hash of the current workspace.

The full warning logs stay at their recorded temporary paths. Each summarized
log has a SHA-256 digest. The exact source snapshots and raw measurements that
were already saved remain in their existing data directories:

- [Private fields](../module-private-fields-2026-10-18/validation.json).
- [Owner collision proof](../cache-owner-boundaries-2026-10-18/).
- [Range hashing and allocation proof](../cache-range-hashing-2026-10-18/).
- [Parse-cache admission](../parse-cache-depth-admission-2026-10-18/).
- [Fragment cache counts](../fragment-cache-generic-enum-accounting-2026-10-18/).
- [Result helper warm costs](../result-helper-warm-planning-2026-10-18/).
