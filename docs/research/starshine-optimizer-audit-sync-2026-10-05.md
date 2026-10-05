# Starshine optimizer audit sync (2026-10-05)

Dewdrop pins Starshine `8191ec0b95cba53b7c80ac7bcff9efd0959ce14a`, now on
Starshine's remote `master`. This fast-forward carries Dewdrop's FFI export and
native-test fixes, its tuple-tail regression, and the four optimizer safety,
correctness, and documentation commits previously on Starshine `main`. The old
local Starshine `master` commit `3bb96abca` is patch-equivalent to changes
already present on remote `master`; its original pointer remains in the local
`archive/master-pre-sync-2026-10-05` branch.

The integrated Starshine pass package compiled and passed 9,094/9,094 native
release tests. Its IR package passed 648/648 native release tests. The FFI
export check passed with 4,235 concrete functions exported; 27 symbols still
use explicit concrete wrappers. The native debug test linker cannot lower
Starshine's non-null value-record arrays, so the repository's release-mode test
lane is required. The prior full Starshine suite had one aggregate spec-harness
failure from eight WAST validation-expectation mismatches; the integrated
commits do not change `src/wast` or `tests/spec`.

The generated Dewdrop FFI manifest and self-host fingerprint use the new
Starshine revision. The provider Wasm bytes and export count are unchanged.
The generated-source check passed. Dewdrop's native lane passed 1,375/1,375
tests, and its compiler/backend integration lane passed 272/272 tests against
this pin. The stress lane passed 15/15, and the CLI cache/ABI check passed.
