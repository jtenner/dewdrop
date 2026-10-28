# Phase 1 JavaScript package contract

Scope: only `tools/dew-package-contract.mjs`,
`tools/test_dew_package_contract.mjs`, and this note.
Branch: `t3/javascript-package-contract`.
Worktree: `/home/dev/.t3/worktrees/dewdrop/t3-e477a636`.
Baseline: `20f902acb6caa56a49712df832aeb0c46ec520b8`.
Approved plan read in full with `git show c812b052:docs/package-manager-migration-plan.md`.
The owner permits the local Phase 1 contract only. No remote work is in scope.

## Red check checkpoint

The test file loads the real baseline publisher functions with Node VM.
It converts `fail` to a thrown error, without a compiler or network call.
Manifest checks run the real capsule reader with a source fixture. Capsule
checks run its real encoding code with in-memory source I/O. Source selection
checks use actual temporary files and permissions. The current source remains
untouched. The new module does not yet exist at this checkpoint.

Command: `node tools/test_dew_package_contract.mjs --baseline`.
Runtime: Node `v24.22.1`, Linux, uid 1000. Exit status: **1**.
Result: **106 checks, 24 pass, 82 fail**. No compiler process ran.
The first adapter attempt had an invalid virtual source map. It was corrected
before the recorded run. That attempt is not defect evidence.

The manifest and source checks reach the existing publisher with real manifest
and source fixtures. The capsule checks call the real serializer with a supplied
file list and virtual reads. This widens the encoder input surface: empty lists,
non-source paths, duplicate paths, and unsorted supplied lists were not normally
produced by the old source selector. Those cases prove checks in the extracted
encoder, not a claim that the old CLI could select every such input.
The allocation guard stops an oversized output allocation in the old encoder.
It does not measure peak memory.

Raw output also exists outside production source at
`/tmp/dew-phase1-javascript-e477a636/red.{stdout,stderr,exit}`.
Exact streams follow. The named checks are the check inventory.

### Red stdout

```text
ok manifest: valid plain result
ok manifest: reject null dependencies
ok manifest: reject array dependencies
ok manifest: reject malformed JSON
ok manifest: reject trailing JSON
ok manifest: reject nested dependency
ok name: punctuation and 255 byte boundary
ok version: accept 0.0.0
ok version: accept 4294967295.4294967295.4294967295
ok version: accept 1.2.3-4294967295
ok version: accept 1.2.3-alpha.1-x+00.99999999999999999999
ok version: accept 1.2.3+bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ok requirement: accept *
ok requirement: accept 1.2.3
ok requirement: accept ^0.2.3
ok requirement: accept ~1.2.3-alpha+build
ok requirement: accept git+x#r
ok requirement: accept git+https://example.test/repo#tag
ok requirement: accept git+xxxxxxxxxxxxxxxxxxxxxxxxxx (2048 bytes)
ok sources: root fallback is regular files only
ok sources: empty src does not fall back
ok capsule path: 4096 byte boundary
ok capsule: invalid provenance
ok capsule: inherited manifest fields cannot supply values
checks=106 passed=24 failed=82 mode=baseline
```

### Red stderr

```text
not ok manifest: absent dependencies means own empty object: dew.json does not contain a package manifest
not ok manifest: reject unknown field: Missing expected rejection.
not ok manifest: reject duplicate field: Missing expected rejection.
not ok manifest: reject escaped duplicate field: Missing expected rejection.
not ok manifest: reject duplicate dependency: Missing expected rejection.
not ok manifest: reject escaped duplicate dependency: Missing expected rejection.
not ok manifest: reject proto field: Missing expected rejection.
not ok manifest: reject proto dependency: Missing expected rejection.
not ok name: reject "scope/name": Missing expected rejection.
not ok name: reject "@/name": Missing expected rejection.
not ok name: reject "@scope/": Missing expected rejection.
not ok name: reject "@a/b/c": Missing expected rejection.
not ok name: reject "@A/b": Missing expected rejection.
not ok name: reject "@a/b!": Missing expected rejection.
not ok name: reject "@a/é": Missing expected rejection.
not ok name: reject "@a/b\n": Missing expected rejection.
not ok name: reject "@a/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb": Missing expected rejection.
not ok version: reject "1.2": Missing expected rejection.
not ok version: reject "v1.2.3": Missing expected rejection.
not ok version: reject "1.02.3": Missing expected rejection.
not ok version: reject "1.2.3.4": Missing expected rejection.
not ok version: reject "4294967296.0.0": Missing expected rejection.
not ok version: reject "1.2.3-4294967296": Missing expected rejection.
not ok version: reject "1.2.3-01": Missing expected rejection.
not ok version: reject "1.2.3-": Missing expected rejection.
not ok version: reject "1.2.3+": Missing expected rejection.
not ok version: reject "1.2.3-a..b": Missing expected rejection.
not ok version: reject "1.2.3+a+b": Missing expected rejection.
not ok version: reject "1.2.3_foo": Missing expected rejection.
not ok version: reject "1.2.3\n": Missing expected rejection.
not ok version: reject "1.2.3+bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb": Missing expected rejection.
not ok requirement: reject "": Missing expected rejection.
not ok requirement: reject "latest": Missing expected rejection.
not ok requirement: reject "1.x": Missing expected rejection.
not ok requirement: reject ">=1.2.3": Missing expected rejection.
not ok requirement: reject "^1.2": Missing expected rejection.
not ok requirement: reject "~1.02.3": Missing expected rejection.
not ok requirement: reject "1.2.3-4294967296": Missing expected rejection.
not ok requirement: reject "git+#r": Missing expected rejection.
not ok requirement: reject "git+x#": Missing expected rejection.
not ok requirement: reject "git+x": Missing expected rejection.
not ok requirement: reject "git+x#r\u0000": Missing expected rejection.
not ok requirement: reject "git+xxxxxxxxxxxxxxxxxxxxxxxxxx (2049 bytes)": Missing expected rejection.
not ok dependencies: reject invalid name: Missing expected rejection.
not ok dependencies: 256 accepted, 257 rejected: Missing expected rejection.
not ok manifest: 1 MiB text boundary: Missing expected rejection.
not ok manifest: disk reader uses the same strict parser: Missing expected rejection.
not ok manifest: disk reader rejects oversized file: Missing expected rejection.
not ok manifest: disk reader rejects symlink: Missing expected rejection.
not ok manifest: missing file keeps read error: The input did not match the regular expression /ENOENT|no such file/i. Input:

'Error: dew.json is invalid JSON'

not ok sources: recursive src, tests included, global byte order: Expected values to be strictly deep-equal:
+ actual - expected

  [
+   'src/a/z.dew',
    'src/a.dew',
-   'src/a/z.dew',
    'src/unit_test.dew',
    'src/é.dew',
    'src/.dew',
    'src/😀.dew'
  ]

not ok sources: regular src file uses root fallback: package has no conventional .dew sources
not ok sources: reject symlink src: Missing expected rejection.
not ok sources: reject symlink nested directory: Missing expected rejection.
not ok sources: reject symlink nested source: Missing expected rejection.
not ok sources: reject symlink root source: Missing expected rejection.
not ok sources: reject symlink package root: Missing expected rejection.
not ok sources: unreadable src error stays visible: Missing expected rejection.
not ok sources: 16 MiB bound before content read: Missing expected rejection.
not ok capsule: v1 bytes and canonical order from supplied buffers: Expected values to be strictly deep-equal:
+ actual - expected

  [
    {
-     contents: Buffer(1) [Uint8Array] [
-       97
-     ],
-     path: 'a.dew'
-   },
-   {
      contents: Buffer(2) [Uint8Array] [
        0,
        255
      ],
      path: 'z_test.dew'
    },
+   {
+     contents: Buffer(1) [Uint8Array] [
+       97
+     ],
+     path: 'a.dew'
+   }
  ]

not ok capsule: omitted dependencies: dew.json does not contain a package manifest
not ok capsule path: reject "/x.dew": Missing expected rejection.
not ok capsule path: reject "C:/x.dew": Missing expected rejection.
not ok capsule path: reject "a\\b.dew": Missing expected rejection.
not ok capsule path: reject "a\u0000.dew": Missing expected rejection.
not ok capsule path: reject "a//b.dew": Missing expected rejection.
not ok capsule path: reject "./x.dew": Missing expected rejection.
not ok capsule path: reject "a/../b.dew": Missing expected rejection.
not ok capsule path: reject "a/./b.dew": Missing expected rejection.
not ok capsule path: reject "x.dew/": Missing expected rejection.
not ok capsule path: reject "README": Missing expected rejection.
not ok capsule path: reject "dew.json/x.dew": Missing expected rejection.
not ok capsule path: reject "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (4097 bytes)": Missing expected rejection.
not ok capsule path: reject duplicate: Missing expected rejection.
not ok capsule path: reject prefix conflict: Missing expected rejection.
not ok capsule: reject empty files: Missing expected rejection.
not ok capsule: reject 65537 files before encoding: Missing expected rejection.
not ok capsule: 16 MiB per source limit: Missing expected rejection.
not ok capsule: preflight 64 MiB before output allocation: The input did not match the regular expression /capsule.*64 MiB/i. Input:

'Error: TEST: oversized allocation before capsule limit check'

not ok capsule: reject source length 0: Missing expected rejection.
not ok capsule: reject source length 2049: Missing expected rejection.
not ok capsule: unknown object key: Missing expected rejection.
```

## Coverage and cost

The checks cover missing dependencies, strict JSON keys including escaped
duplicates, prototype keys, name grammar, bounded Dew SemVer and requirements,
manifest bytes, source selection, test sources, root fallback, symlinks,
permissions, source size, v1 bytes, ordering, paths, duplicate and conflicting
paths, provenance, source count, and capsule allocation preflight.

The snapshot caller owns bounded source reads. It must open without following
symlinks, check the open file with `fstat`, cap reads at 16 MiB, check size and
identity again after the read, and reject changed source directories. Collection
alone does not freeze files. Encoding will use supplied buffers only.

Shared callers after integration: pack, publish, source snapshot, integrity,
compiler manifest preparation, and local artifact restore. The module will
validate bytes in O(input bytes), walk source directories, sort paths by UTF-8
bytes, and copy each source buffer once into one checked output buffer. The
source input buffers remain owned by the caller. No cost claim is measured.

Hold: all native lanes, compiler builds, cross-platform builds, stress tests,
and all benchmark/timing work. No compiler check is needed for this module.
Shared vectors are not yet present in this worktree.

After a quiet-host lease, compare the pinned baseline with the frozen final
head. Use tiny manifests and sources, 256 dependencies, deep/wide source trees,
65,536 empty files, 16 MiB sources, near-64 MiB capsules, and rejected excess
inputs. Record raw time, RSS, allocations, I/O, runtime version, and exact source
and executable IDs. Include pack and publish snapshot callers after integration.
