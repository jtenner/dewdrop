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
compiler manifest preparation, and local artifact restore. Manifest validation
scans bounded input bytes. Source collection adds `lstat` and `realpath` checks
for each selected file and directory. UTF-8 path keys allocate once per file;
the comparator does not allocate. Sorting costs O(n log n) comparisons.
Prefix checks inspect ancestor segments and copy prefix strings. Deep paths can
therefore cost more than linear in path bytes, with each path capped at 4096
bytes. Encoding copies each supplied source buffer once into one checked output
buffer, then hashes that buffer in place. Input buffers stay owned by the caller.
The module also allocates bounded manifest descriptors, dependency records, path
sets, UTF-8 path keys, and a 32-byte digest. No runtime or memory gain is measured.

Hold: all native lanes, compiler builds, cross-platform builds, stress tests,
and all benchmark/timing work. No compiler check is needed for this module.
Shared vectors are not yet present in this worktree.

After a quiet-host lease, compare the pinned baseline with the frozen final
head. Use tiny manifests and sources, 256 dependencies, deep/wide source trees,
65,536 empty files, 16 MiB sources, near-64 MiB capsules, and rejected excess
inputs. Record raw time, RSS, allocations, I/O, runtime version, and exact source
and executable IDs. Include pack and publish snapshot callers after integration.


## Green implementation checkpoint

Red checkpoint: `158dd834088f598e9a629cb8f89dcb2d28c9f90a`.
Validated module Git blob: `315b772bc0fb4b5629fe41c83c1a4b440328c3fa`.
The checkpoint commit containing this section is the code checkpoint; use its
commit ID as the implementation head. A file cannot contain its own commit ID.

Frozen public API:

- `readPackageManifest(manifestPath)` is async and returns validated manifest data.
- `parsePackageManifest(text)` is sync and returns the same data.
- `collectSourceFiles(packageRoot)` is async and returns sorted
  `{path, absolutePath, size}` records. `path` uses relative slashes.
- `encodeCapsule({manifest, files, source, interfaceFingerprint, integrity})`
  is sync and returns a Buffer. Files contain `{path, contents: Buffer}`.
  It reads no disk and does not recompute source integrity or the interface.
- `MAX_MANIFEST_BYTES`, `MAX_NAME_BYTES`, `MAX_VERSION_BYTES`,
  `MAX_REQUIREMENT_BYTES`, `MAX_DEPENDENCIES`, `MAX_PATH_BYTES`,
  `MAX_SOURCE_BYTES`, `MAX_FILES`, `MAX_CAPSULE_BYTES`, and
  `MAX_LOCAL_ARTIFACT_BYTES` expose the limits. The last two are 64 MiB and
  256 MiB. The encoder enforces the 64 MiB publish policy, not the local cap.

JSON parsing is limited to the two-level manifest schema and checks decoded
keys before it stores values. Escaped duplicates cannot disappear in JSON.parse.
Encoding also validates object inputs using own data descriptors. Inherited
fields and getters cannot supply manifest data. Returned dependencies default
to an own empty plain object. Names and SemVer follow the current Dew rules.
Git requirements retain Dew's bounded `git+source#ref` check; this adds no URL
scheme, npm range, or registry resolution semantics.

Source selection uses a directory `src` recursively, or regular root `.dew`
files when `src` is absent or is a regular file. Errors under `src` stay errors.
A directory `src` with no sources cannot fall back. Test sources stay included.
Root fallback ignores unselected directories. Recursive selection rejects every
symlink it encounters. Root fallback rejects symlink `.dew` entries and a
symlink `src`, but does not inspect unrelated root directories. Selected paths
are checked again by realpath and directory inode checks. This is an inventory,
not a race-free source snapshot. Ancestors above the requested root can be
canonicalized with realpath; the requested root itself cannot be a symlink.

Path validation rejects slash-rooted paths and Windows drive-rooted paths,
backslashes, NUL, empty/dot/dotdot segments, non-`.dew` paths, `dew.json/`,
duplicates, and file/directory prefix conflicts. It retains all other existing
Dew logical-path characters. It does not add a Windows filename portability
policy for colons, reserved names, or trailing spaces. A future Windows
materializer must preserve the agreed logical-path semantics without allowing
a drive-relative path to escape. Tell the coordinator if that caller needs a
shared physical-path validation API; the four frozen exports stay unchanged.

The manifest disk reader uses no-follow/nonblocking open when the platform
supplies those flags, validates the regular open file against lstat, reads only
size plus one byte up to 1 MiB plus one, checks identity/size/timestamps again,
and rejects invalid UTF-8. It keeps filesystem errors visible. Source reads
remain the snapshot consumer's job. No source bytes are read by collection.

Commands:

- `node tools/test_dew_package_contract.mjs`: 106 pass, 0 fail, exit **0**.
- `bun tools/test_dew_package_contract.mjs`: 106 pass, 0 fail, exit **0**.
- `git diff --check`: exit **0**, stdout and stderr empty.

Both functional commands use the same 106 check names from the red checkpoint.
Bun version: `1.4.4`. Both stderr streams are empty. Full exact outputs are at
`/tmp/dew-phase1-javascript-e477a636/green.{stdout,stderr,exit}` and
`/tmp/dew-phase1-javascript-e477a636/green-bun.{stdout,stderr,exit}`.
No timing or compiler run was used. The shell wrapper saves the subprocess exit
status separately; the wrapper's own exit status is not the test result.
Node stdout is below. Bun stdout has the same named results and summary.

### Green stdout

```text
ok manifest: absent dependencies means own empty object
ok manifest: valid plain result
ok manifest: reject unknown field
ok manifest: reject duplicate field
ok manifest: reject escaped duplicate field
ok manifest: reject duplicate dependency
ok manifest: reject escaped duplicate dependency
ok manifest: reject proto field
ok manifest: reject proto dependency
ok manifest: reject null dependencies
ok manifest: reject array dependencies
ok manifest: reject malformed JSON
ok manifest: reject trailing JSON
ok manifest: reject nested dependency
ok name: reject "scope/name"
ok name: reject "@/name"
ok name: reject "@scope/"
ok name: reject "@a/b/c"
ok name: reject "@A/b"
ok name: reject "@a/b!"
ok name: reject "@a/é"
ok name: reject "@a/b\n"
ok name: reject "@a/bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
ok name: punctuation and 255 byte boundary
ok version: accept 0.0.0
ok version: accept 4294967295.4294967295.4294967295
ok version: accept 1.2.3-4294967295
ok version: accept 1.2.3-alpha.1-x+00.99999999999999999999
ok version: accept 1.2.3+bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
ok version: reject "1.2"
ok version: reject "v1.2.3"
ok version: reject "1.02.3"
ok version: reject "1.2.3.4"
ok version: reject "4294967296.0.0"
ok version: reject "1.2.3-4294967296"
ok version: reject "1.2.3-01"
ok version: reject "1.2.3-"
ok version: reject "1.2.3+"
ok version: reject "1.2.3-a..b"
ok version: reject "1.2.3+a+b"
ok version: reject "1.2.3_foo"
ok version: reject "1.2.3\n"
ok version: reject "1.2.3+bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
ok requirement: accept *
ok requirement: accept 1.2.3
ok requirement: accept ^0.2.3
ok requirement: accept ~1.2.3-alpha+build
ok requirement: accept git+x#r
ok requirement: accept git+https://example.test/repo#tag
ok requirement: accept git+xxxxxxxxxxxxxxxxxxxxxxxxxx (2048 bytes)
ok requirement: reject ""
ok requirement: reject "latest"
ok requirement: reject "1.x"
ok requirement: reject ">=1.2.3"
ok requirement: reject "^1.2"
ok requirement: reject "~1.02.3"
ok requirement: reject "1.2.3-4294967296"
ok requirement: reject "git+#r"
ok requirement: reject "git+x#"
ok requirement: reject "git+x"
ok requirement: reject "git+x#r\u0000"
ok requirement: reject "git+xxxxxxxxxxxxxxxxxxxxxxxxxx (2049 bytes)"
ok dependencies: reject invalid name
ok dependencies: 256 accepted, 257 rejected
ok manifest: 1 MiB text boundary
ok manifest: disk reader uses the same strict parser
ok manifest: disk reader rejects oversized file
ok manifest: disk reader rejects symlink
ok manifest: missing file keeps read error
ok sources: recursive src, tests included, global byte order
ok sources: root fallback is regular files only
ok sources: regular src file uses root fallback
ok sources: empty src does not fall back
ok sources: reject symlink src
ok sources: reject symlink nested directory
ok sources: reject symlink nested source
ok sources: reject symlink root source
ok sources: reject symlink package root
ok sources: unreadable src error stays visible
ok sources: 16 MiB bound before content read
ok capsule: v1 bytes and canonical order from supplied buffers
ok capsule: omitted dependencies
ok capsule path: reject "/x.dew"
ok capsule path: reject "C:/x.dew"
ok capsule path: reject "a\\b.dew"
ok capsule path: reject "a\u0000.dew"
ok capsule path: reject "a//b.dew"
ok capsule path: reject "./x.dew"
ok capsule path: reject "a/../b.dew"
ok capsule path: reject "a/./b.dew"
ok capsule path: reject "x.dew/"
ok capsule path: reject "README"
ok capsule path: reject "dew.json/x.dew"
ok capsule path: reject "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx (4097 bytes)"
ok capsule path: 4096 byte boundary
ok capsule path: reject duplicate
ok capsule path: reject prefix conflict
ok capsule: reject empty files
ok capsule: reject 65537 files before encoding
ok capsule: 16 MiB per source limit
ok capsule: preflight 64 MiB before output allocation
ok capsule: reject source length 0
ok capsule: reject source length 2049
ok capsule: invalid provenance
ok capsule: inherited manifest fields cannot supply values
ok capsule: unknown object key
checks=106 passed=106 failed=0 mode=module
```

## Deferred checks and integration limits

No compiler/native lane, platform compilation, server, publication, PR, push,
master merge, or benchmark ran. Shared vectors were absent at validation time.
The 65,537-file rejection and oversized source/capsule checks are functional
boundary checks, not stress or timing measurements. The preflight guard proves
that the over-limit output is rejected before an oversized buffer allocation.
It does not prove a measured RSS reduction. Maximum-count filesystem inventory
and an exact 64 MiB successful capsule remain deferred boundary coverage.

The assigned source files are new modules only. Existing pack/publish callers
are not changed here. The snapshot owner must import these exports, bound each
source read with lstat/open/fstat checks and `MAX_SOURCE_BYTES`, retain exactly
one frozen input set, and use collection's test files for integrity and capsule.
Compiler preparation must filter `_test.dew` only for compilation. The snapshot
owner must preflight aggregate sizes before it reads all contents, using encoded
metadata/path/length overhead, not just total source bytes. The encoder performs
its own complete encoded-size preflight again before allocating output.

The 256 MiB local artifact bound remains an exported, distinct codec policy.
No local compiler cache codec is edited in this area. Module encoding uses the
64 MiB publish cap and cannot replace a 256 MiB local codec writer as-is.

The coordinator still owns native and affected-platform validation, shared
vector integration, caller integration, and the quiet-host measurement handoff.
The workload proposal above covers each performance-sensitive shared caller.
