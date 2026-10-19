# Compile request decoder allocation bounds

The source-pool extension exposed two count checks that ran too late. The native
decoder read a pool count with a separate 1,024-module allowance. Both readers
could set a total-file error and then keep adding file records. The old active
module path had the same file-loop fault.

Both compilers now use a shared module reader with one file counter for active
and pooled modules. The exact limits remain:

- At most 1,024 active and pooled modules combined. The pool count is checked
  against `1,024 - active_module_count` before its module records are read.
- At most 4,096 files per module, with at least one file.
- At most 65,536 active and pooled files combined. Each file count is checked
  against the remaining total before file records are read or added.

The readers return immediately when a module header or file record is invalid
or truncated. They keep the first diagnostic. The outer decoders return that
error instead of reading later payload sections. A partial module is never
added after a failed file record. Source bytes remain opaque, including unused
invalid UTF-8 source. Existing per-source and total-request byte limits are
unchanged. EOF after the fingerprint still means an empty optional pool.

## Validation

Small metadata regressions check the remaining module allowance, a two-file
header with room for only one file, and a two-file header with no file data. They
check that the reader keeps its offset at byte 12 and adds no partial module.
These tests need no large allocation. Both new Dew tests failed before the fix;
the raw log is `.tmp/request-codec-bounds/red.log`. Test generation took 5.774
seconds and linking took 1.240 seconds. The fixed shared reader passed both focused Dew tests and all six request tests.
The Dew test module took 6.044 seconds to generate and 1.311 seconds to link.
The native codec lane passed all 10 tests; its raw log is
`.tmp/request-codec-bounds/native.log`. The final outer-decoder early-return follow-up also passes all six Dew request
tests; build times are in `.tmp/request-codec-bounds/final-build.log` and results
are in `.tmp/request-codec-bounds/final.log`.
