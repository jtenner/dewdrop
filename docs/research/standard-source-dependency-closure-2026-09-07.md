# Standard source dependency closure

Moving String access into Dew exposed an import-loading defect. A program that
opened only ordering and red-black-tree modules did not select the String module
now imported by ordering. Inference reported two missing String methods.

Dependency selection now follows each selected source's leading imports with a
work queue. A path enters the queue once. The initial order stays fixed; newly
found paths are appended in source order. Cycles terminate without duplicate
modules. Supplied source providers determine their own dependency edges.

The filesystem loader follows the bytes it actually reads, not the embedded
copy of that source. Its fingerprint covers every dependency path and content.
A missing transitive file remains a loader error. Parse-event cache selection
uses the loaded source provider and includes the full dependency closure.

The existing registry still maps package names to source files. This change does
not claim to remove all legacy standard-module selection or publication rules.
It removes the need to add another fixed dependency mask for String access.

## Validation

- The cycle fixture initially failed because String was absent (9.065 seconds).
- Two dependency-selection tests now pass (8.722 seconds for the owning native
  semantic lane; 27.713 seconds for the filtered package sweep).
- The original red-black-tree integration test now passes (0.582 seconds).
- All 19 loader tests pass (3.713 seconds). New tests cover duplicate roots,
  cyclic imports, dependency fingerprint changes, and an exact missing-file error.
- All 268 integration tests pass (49.227 seconds). This is above the 30-second
  limit and remains a performance bug.
- Clean bootstrap passes with the String access change (168.137 seconds).
  Compiler B/C raw and linked bytes match, SHA-256
  `88b4360a7e6982f0e5cc799467ef04e178bd1e35b2eb981632c1e1d7fa28d33b`.
- All 942 routine native tests pass across the serialized runs. One stale
  String reachability test used a declaration ordinal; the corrected test
  passes (9.045 seconds). Backend 93, loader 19, and driver 2 tests pass in
  29.868, 1.532, and 8.437 seconds. Generated checks pass (10.508 seconds).
