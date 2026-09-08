# Bytes Debug and hidden-write removal

Bytes now calls the same ordinary Dew quoted-output function as String, with
the byte escape mode enabled. All 256 byte values, offset views, empty input,
generic calls, multi-window output, partial writes, and invalid host results
retain the shared exact-output checks. The import-free fixture also checks
the `b"..."` prefix without opening a text module.

Both old private formatter/write source files are deleted (840 lines total).
They are recoverable from Git. The native dispatcher and pinned provider have
no String or Bytes Debug entries. Native fragment planning and specialization
no longer create hidden write dependencies or search for a function by the
spelling `wasi_snapshot_preview1.fd_write` to support Debug.

`RuntimeFunctionBuilder` takes only the text type base. Its stored write index
is removed, the generated FFI constructor has one parameter, and the self-host
consumer no longer passes the magic index `6`. Provider metadata and the Dew
consumer are regenerated together. Text storage and SIMD storage access still
remain; this is not a claim that all legacy runtime builtins are gone.

The provider boundary test fails before removal (19 pass, 1 fail; 6.364 seconds)
and passes after removal (20 tests, 6.602 seconds). The policy suite fails seven
checks before removal (0.033 seconds), then passes. Existing removal policies
now require the obsolete files to be absent and still inspect the remaining
dispatchers; they do not skip checks when a file is missing.

Provider commit: `b3542f114`. Scoped API generation takes 0.867 seconds;
provider wrapper generation takes 3.931 seconds; provider build takes 10.483
seconds. Library checks pass (326 tests plus all shared cases, 41.708 seconds).
Self-host checks pass (462 tests, 137 numeric records, all probes; 149.967
seconds). The full pinned provider suite passes all 10,994 tests in 254.348
seconds. Native passes 1,149 tests (174.275 seconds); integration passes 268
tests (57.424 seconds). The clean bootstrap passes in 170.530 seconds, with
identical B/C SHA-256
`fbfe2cab47cfc5c5b64e88df86423737a121948f0c3c304dc76916cf96f8fc2e`.
The first generated-check run found an old Map policy test requiring the former
two-argument provider constructor. It now requires the one-argument API and
still rejects obsolete layout/transport arguments. Generated checks pass in
12.800 seconds; all 15 stress tests pass in 0.337 seconds. Runs above 30 seconds
remain speed bugs; no speed work is included.

The self-host linker's separate forced-WASI-import rule is still present.
Its reachability and ordinary import handling need a separate regression test;
the runtime builder no longer needs it.
