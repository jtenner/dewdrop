# Hold the bounded GC field-prefix experiment

The experiment branches from installed Wago073b2f61880e965d3c33ba83e32f72e9391a845d in `.tmp/wago-test-field-prefix`. It keeps the first fully checked object address in RDX and handle extent in reserved RDI through at most eight same-object deconstruction pairs in128bytes. Larger handle/header checks remain at the source field read after its preceding local.set. Calls, writes, source-local changes and other objects end the prefix.

Astra supplied the lease/extent design. GPT-6 Sol with explicit Daybreak Blue reviewed the production delta; no concrete source finding, with test gaps. Checked tests now cover both extent sources and late traps, dirty pins, earlier trap/store order, older roots, nullable/packed fields, true/false register pressure, the eight-pair cap, a padded partial128-byte window, and source/profile/unwind metadata. The final checked and profile lanes pass in24.033s and24.893s. The initial structural red failed because baseline made five resolver calls where the candidate makes two; baseline semantics passed. Initial admission rejected a transient RDI global-cell cache; the final preflight excludes persistent leases and verifies RDI is free after the normal flush. Raw failures remain visible.

Public Compile of the pinned compiler admits760extra reads in272functions. Native code decreases24,516,539→24,504,875bytes. Exact root metadata remains the same. The matching8192-iteration micro median drops124078.5→81926.5ns (33.97%); wrong-type negative differs0.19%, within noise.

Full quiet normal-host runs, serial balanced pairs with fresh native/result caches and fixed CPU12,14/GOMAXPROCS2:

| Variant | Seconds | Median |
|---|---|---|
| Installed source control |36.0711,36.4554,36.5847|36.4554|
| Prefix candidate |55.6658,36.2279,36.1740|36.2279|

The median difference is0.62%, inside the overall spread. The55.67s sample also used55.95CPU seconds; it is retained and its cause is unknown. It did not recur in the other two candidate runs. This does not establish a54% persistent regression or a useful full-job gain. All six runs produced both required fixed hashes, main42 and exact native roots. Known V8 reference4s; no V8 timing was repeated.

Decision: hold locally. No PR, cherry-pick or installation for this experiment. Installed PATH remains local-gc-073b2f618. Investigate a module-shared getter specialization next, separately, on the same pinned compiler. Raw full data is `data/wago-test-field-prefix-full-2026-10-21/`; raw test/micro/review/admission records remain `.tmp/wago-next-gc-perf/test-field-prefix/` and `.tmp/wago-next-gc-perf/daybreak-test-field-prefix/`.
