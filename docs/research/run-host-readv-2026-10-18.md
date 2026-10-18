# Bounded vector reads in the run host

Date: 2026-10-18

## Fault and fix

The first demand-driven stdin change used one `readSync` call per guest vector.
A short first vector returned correctly. If the pipe supplied exactly enough
bytes to fill that first vector and stayed open, the next vector caused a
second blocking read. A two-vector test with capacities 3 and 4 and only three
input bytes reproduced the fault: the old runner needed the test's 5-second
kill timeout.

The host now validates the complete guest vector table and every buffer range
before it builds views or reads input. It then creates at most 64 nonempty
`Uint8Array` views over guest memory and calls `readvSync` once. It does not
copy input through a staging buffer. A caller that supplies more vectors can
receive a legal prefix short read and must advance its own vectors before its
next call. Empty vectors do not count toward the view bound. An all-empty list
returns zero without a host read.

The result count is the host's byte count. `EINTR` retries the same read. Other
host errors set the result count to zero and return the mapped WASI errno.
Partial successful reads return immediately. The runner still exposes only
stdin for reading.

## Platform limits

[Node's `readvSync` API](https://nodejs.org/docs/latest-v24.x/api/fs.html#fsreadvsyncfd-buffers-position)
accepts array-buffer views and returns the byte count. The Node v24.21.0 bundled
[POSIX libuv source](https://github.com/nodejs/node/blob/v24.21.0/deps/uv/src/unix/fs.c#L473-L499)
clamps the vector count to the host `IOV_MAX` and makes one `readv` call for
multiple views. The runner's own cap bounds temporary view objects and references;
it does not assume that every host accepts 64 vectors in one call. A smaller
host limit also yields a legal prefix read.

The bundled [Windows libuv source](https://github.com/nodejs/node/blob/v24.21.0/deps/uv/src/win/fs.c#L827-L844)
implements a vector read as repeated `ReadFile` calls. Passing several views
would keep the same blocking risk on Windows. The runner therefore uses one
nonempty view on Windows. It adds no `fstat` call and retains no full input
buffer. Public WASI callers must already handle short reads.

Native tests ran on Linux. A child-process test forces the Windows selection
rule and checks that exactly one view reaches Node. This tests the runner's
branch; it is not a native Windows runtime measurement.

## Tests

The first vector-read run passed all 14 `node --test tools/test-dew-run.mjs`
tests in 0.444 seconds.
The exact-first-vector pipe test now returns in about 21 ms with stdin still
open. Added tests cover 65 nonempty vectors and caller reads of remaining data,
an invalid range after the 64-view bound before any input, `EINTR` retry, and
the Windows one-view selection rule. Existing multi-vector, EOF, empty-vector,
byte-preservation, invalid descriptor/range, and Linux host-error tests pass.
The multi-vector test checks the legal Windows prefix counts separately.

[Failing test](data/run-host-readv-2026-10-18/red.stdout) and
[passing tests](data/run-host-readv-2026-10-18/green.stdout) are retained.
Node syntax checks and `git diff --check` also pass. No Moon build ran.

A review follow-up added an `EAGAIN` test that requires zero reported bytes and
WASI errno 6 without waiting for input. The simulated Windows hook now writes
its expected/actual view count to stderr and exits with status 70 on a mismatch.
The runner cannot turn that test failure into a generic WASI I/O error. A direct
hook check with two views confirmed the message and exit status.

All 15 runner tests then passed in 0.458 seconds. The
[follow-up test record](data/run-host-readv-2026-10-18/review-polish-tests.json)
and [hook diagnostic](data/run-host-readv-2026-10-18/hook-diagnostic.json) retain
the results. The production runner stayed unchanged, with the same `d6d545ae...`
hash recorded below. The follow-up changed tests, notes, and report output paths.

## Final-source memory samples

This is a follow-up to the earlier
[run-host input measurements](run-host-input-2026-10-18.md). Those historical
samples remain unchanged. The baseline is commit
`9d86b829292b1efa8f1aca32b0ff49565c878ee0`.

Final runner SHA-256:
`d6d545ae0cb82b91186c5864ecda412ecdaf2e98dd6cb0ee8e37f83759e81bb1`.
Baseline runner SHA-256:
`797130445cee84f691fe375654e466172c2bc2517f632b4f418d7559d0828413`.
The reused fixture SHA-256 is
`1ec057a2634abbe825b731b4de8ff95be1f2b0c6f4387ad85972d2ebcff8ec5f`.

The same guest reads 65,536-byte requests until EOF and returns a four-byte
processed-byte count. Every sample checks that output against the exact input
size. The harness snapshots both runner sources and checks that the working
source stays unchanged during the run. Three fresh-process pairs per size use
alternating before/after order; the second pair reverses the order. The host
was under normal load, without CPU pinning or warmup. Other repository work
was active. Raw load averages are in the record.

Peak RSS is the Node child's `RUSAGE_CHILDREN.ru_maxrss`, read by a fresh Python
worker. It includes Node and the guest, and excludes the Python input sender.
Elapsed time includes Python/Node startup and pipe transfer, so it is not a
standalone throughput benchmark. Typed-array views and V8 can still allocate
transiently. These samples establish neither native Windows behavior nor a
cross-host throughput bound.

| Input MiB | Pair | Before peak KiB | Final peak KiB | Before ms | Final ms |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 54948 | 51080 | 48.844 | 46.639 |
| 1 | 2 | 55032 | 51032 | 51.143 | 48.909 |
| 1 | 3 | 54728 | 51016 | 49.815 | 46.825 |
| 64 | 1 | 304100 | 60580 | 141.652 | 88.912 |
| 64 | 2 | 302888 | 60508 | 138.742 | 88.806 |
| 64 | 3 | 306168 | 60732 | 134.600 | 92.389 |

For 64 MiB, median peak RSS was 304,100 KiB before and 60,580 KiB after,
80.1% lower. Median elapsed time was 138.742 ms before and 88.912 ms after.
For the 1 MiB control, median peak RSS was 54,948 KiB before and 51,032 KiB
after. The data support retaining the bounded direct-read change without a
full-input memory regression; they do not isolate the cost of a single view.

[Raw samples](data/run-host-readv-2026-10-18/final-rss.json), the
[fixture](data/run-host-readv-2026-10-18/read-stream.wat), and the
[harness](data/run-host-readv-2026-10-18/measure.py) are retained. To repeat from
the repository root:

```sh
python3 docs/research/data/run-host-readv-2026-10-18/measure.py --output .tmp/run-host-readv-repeat.json
```

Without `--output`, the harness creates a unique system temporary directory and
prints the report path. A repeat run no longer replaces the saved `final-rss.json`
report. The saved measurements above are unchanged; their recorded harness hash
refers to the first harness revision. The output-path change does not alter the
measurement loop or the production runner.


Default and explicit output paths were both run successfully. The saved report's
SHA-256 stayed unchanged in both checks. The
[output-path checks](data/run-host-readv-2026-10-18/harness-output-check.json)
record their paths, commands, and times. These checks verify report handling;
they do not replace the historical samples or add a new performance claim.
