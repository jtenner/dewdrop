# Profile the installed GC read follow-ups

This diagnostic build archives commit61881e2d0d5262e5c8362e024a95b7bec0a963e4. It includes folded checked handle-space descriptor loads and trapping-guard reuse; it precedes later cold-trap fixes and the type-test/first-field experiment. No held getter/type-fact/collector change is included. The source archive and host-builder identities are recorded in data/wago-read-followups-profile-2026-10-21/build.json.

Go CPU profile:39.07 sampled seconds in a38.84s diagnostic full job. External generated native code accounts for30.97s(79.27%). CollectMinor accounts for5.05s(12.93%) cumulatively; finishSparseMinorEvacuation is1.98s flat/2.24s cumulative: dead nursery handle reclamation, not remembered-card finish. This remains primarily generated-code work. It does not prove every generated-code cost is a GC instruction.

Software native-PC samples:1927 total,1098 in generated native code. The sampling process stopped the worker for92.3ms, with no reported errors/drops. Region counts are locality evidence, not hardware CPU time, retired instruction counts or cache-miss measurements. Leading native regions: index_module_implementations89, array_get_unchecked80, imported_requirement_identity74, intern_function53, bytes_byte_at36, array_length34, get_unchecked31, shared resolver28, resolved_import_callable27, bytes_byte_length23, simple_equal17. Full rows are retained with the raw metadata pointer.

The diagnostic build took8.414s; its full job took38.837s and produced the fixed required output hashes/main42. Peak RSS was about1.219GB. These times include diagnostic sampling and must not be compared as a normal-host speed result. No V8 compile was run. Full source images/maps remain locally under .tmp/wago-next-gc-perf/read-followups-profile; small reports and identities are retained beside this note.

This profile informed the new type-test/first-field work and the separate shared-resolver getter investigation. Claude supplies independent algorithm research; Astra supplies implementation proof; GPT-6 Sol with explicit Daybreak Blue reviews code before publication. Native interval-cache research is still a hypothesis and is not installed.

Correction from the fresh whole-GC Astra audit: an earlier draft misnamed finishSparseMinorEvacuation as remembered-card cleanup. The unchanged raw cpu-top.log identifies the function; its source reclaims dead nursery handles. These samples must not be used to rank card scanning.
