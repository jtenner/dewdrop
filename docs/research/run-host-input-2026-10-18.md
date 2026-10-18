# Run host input reads — 2026-10-18

This is a historical record of the first demand-driven `readSync` host. Its
nine-test count, partial-error behavior, and measured runner hash describe that
implementation. The current bounded vector host and its tests are recorded in
[the final `readvSync` follow-up](run-host-readv-2026-10-18.md).

## Initial change (historical)

The first implementation changed `tools/dew-run.mjs` to read stdin only when the guest calls WASI
`fd_read`. It reads into the guest memory view. It does not load and copy the
whole input before the program starts. Programs can write output before input
is available, and programs that do not read input can exit with stdin open.

The host checks all iovec and result ranges before reading. A short read,
including EOF, returns at once. Empty buffers do not trigger a host read.
Interrupted reads retry. Host errors return WASI errno values. A later host
error preserves a successful partial read. This host exposes only descriptor
0 for reading; other descriptors return BADF. The file and process adapters
still need their own full WASI host.

## Initial tests (historical)

The old host failed the new open-stdin test after its 5-second timeout. With
that initial fix, `node --test tools/test-dew-run.mjs` passed all 9 tests in 0.33 seconds.
Tests cover open stdin, output before input, repeated incremental reads without
EOF, exact byte data, short reads across iovecs, empty iovecs, multiple buffers,
EOF, invalid descriptors, invalid guest ranges, and a Linux host read error.
The fixtures are Core Wasm bytes made in the test. They need no Dew build.
The host error test uses a directory as stdin and is Linux-only.

The Node metadata group plus those initial tests passed all 17 tests:

```sh
node --test tools/dew-test/metadata.test.mjs tools/dew-abi-metadata.test.mjs tools/test-dew-run.mjs
```

`tools/check-generated.sh` includes the new tests in this same test group.
No MoonBit compiler build or test ran for this change.

## Memory and runtime samples

The baseline runner is from commit
`9d86b829292b1efa8f1aca32b0ff49565c878ee0`. Each sample starts a fresh Node
process. Before and after samples alternate. Python sends input through a
pipe. The same guest reads until EOF in requests of at most 65,536 bytes, then
writes the total byte count. Every sample checked that count against the full
input size. No sample blocked or timed out.

The parent uses a fresh Python worker for each Node process and records the
Node child's `resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss`.
RSS includes the Node engine and guest, not the Python sender. Elapsed time
includes the worker and Node startup, fixture load, and pipe transfer. It is
not a standalone language runtime benchmark. No warmup or CPU pinning was
used. Source size and allocation counts were not used to claim a memory gain.

Environment: Node v24.21.0, Linux 6.12.111 Debian 13, x86_64, glibc 2.41.
The WAT fixture was parsed with `wasm-tools` 1.262.0 in 0.002566 seconds.
Fixture SHA-256:
`1ec057a2634abbe825b731b4de8ff95be1f2b0c6f4387ad85972d2ebcff8ec5f`.
Changed runner SHA-256:
`5324eb9230a5b647286af04dceba322e30c6ed5fe5997778ae2c68eb43816d65`.

| Input MiB | Sample | Before peak KiB | After peak KiB | Before ms | After ms |
| --- | --- | --- | --- | --- | --- |
| 1 | 1 | 54892 | 50920 | 39.531 | 37.305 |
| 1 | 2 | 55004 | 50768 | 39.347 | 39.236 |
| 1 | 3 | 54836 | 51116 | 39.856 | 38.383 |
| 1 | 4 | 54480 | 50768 | 40.516 | 38.304 |
| 1 | 5 | 52656 | 51240 | 40.741 | 39.660 |
| 64 | 1 | 304332 | 61048 | 135.279 | 83.853 |
| 64 | 2 | 304188 | 60356 | 130.588 | 82.484 |
| 64 | 3 | 303660 | 61400 | 133.469 | 81.369 |
| 64 | 4 | 303996 | 60824 | 135.265 | 86.984 |
| 64 | 5 | 303444 | 60276 | 136.521 | 82.442 |

For 64 MiB, median peak RSS fell from 303,996 KiB to 60,824 KiB
(80.0% lower). For 1 MiB, it fell from 54,836 KiB to 50,920 KiB.
Median elapsed time for 64 MiB was 135.265 ms before and 82.484 ms after.
The main result is the removed full input retention. The elapsed samples
include startup and pipe scheduling, so they do not establish a cross-host
throughput guarantee. Typed-array views and V8 can still cause transient
allocation and RSS variation. No new full-size input buffer is retained.

## Reproduce the samples

The exact harness below writes its fixture, baseline runner, and raw JSON
under `/tmp/dewdrop-review-2026-10-18/features`. Run it from the repository
root with `mise exec wasm-tools@1.262.0 -- python3 PATH_TO_SAVED_SCRIPT`.
It uses no installed `/usr/bin/time`. The fixture and runner identities are
included in its output.

```python
from pathlib import Path
import subprocess,time,json,platform,hashlib
root=Path('/tmp/dewdrop-review-2026-10-18/features')
baseline=root/'dew-run-before.mjs'
baseline.write_bytes(subprocess.check_output(['git','show','9d86b829292b1efa8f1aca32b0ff49565c878ee0:tools/dew-run.mjs']))
wat=root/'read-stream.wat'
wat.write_text('''(module
 (import "wasi_snapshot_preview1" "fd_read" (func $read (param i32 i32 i32 i32) (result i32)))
 (import "wasi_snapshot_preview1" "fd_write" (func $write (param i32 i32 i32 i32) (result i32)))
 (memory (export "memory") 2)
 (data (i32.const 0) "\\40\\00\\00\\00\\00\\00\\01\\00")
 (data (i32.const 8) "\\24\\00\\00\\00\\04\\00\\00\\00")
 (func (export "main")
  (block $done (loop $next
   (if (call $read (i32.const 0) (i32.const 0) (i32.const 1) (i32.const 32)) (then unreachable))
   (br_if $done (i32.eqz (i32.load (i32.const 32))))
   (i32.store (i32.const 36) (i32.add (i32.load (i32.const 36)) (i32.load (i32.const 32))))
   (br $next)))
  (drop (call $write (i32.const 1) (i32.const 8) (i32.const 1) (i32.const 40)))))''')
start=time.monotonic()
subprocess.run(['wasm-tools','parse',str(wat),'-o',str(root/'read-stream.wasm')],check=True)
parse_seconds=time.monotonic()-start
records=[]
for size in (1024*1024,64*1024*1024):
 payload=b'x'*size
 for sample in range(5):
  for identity,runner in [('before',baseline),('after',Path('tools/dew-run.mjs'))]:
   rss=root/'max-rss.txt'
   worker="import subprocess,resource,json,sys; r=subprocess.run(sys.argv[1:],stdin=sys.stdin.buffer,stdout=subprocess.PIPE,stderr=subprocess.PIPE); sys.stdout.buffer.write(r.stdout); print(json.dumps({'peak_rss_kib':resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,'stderr':r.stderr.decode()}),file=sys.stderr); sys.exit(r.returncode)"
   command=['python3','-c',worker,'node',str(runner),str(root/'read-stream.wasm')]
   start=time.monotonic()
   result=subprocess.run(command,input=payload,capture_output=True,timeout=15,check=True)
   elapsed=time.monotonic()-start
   actual=int.from_bytes(result.stdout,'little')
   assert actual==size,(actual,size,result.stderr)
   records.append(dict(identity=identity,input_bytes=size,sample=sample,peak_rss_kib=json.loads(result.stderr)['peak_rss_kib'],elapsed_seconds=elapsed,processed_bytes=actual))
report=dict(baseline='9d86b829292b1efa8f1aca32b0ff49565c878ee0',node=subprocess.check_output(['node','--version'],text=True).strip(),platform=platform.platform(),architecture=platform.machine(),wasm_tools_parse_seconds=parse_seconds,fixture_sha256=hashlib.sha256((root/'read-stream.wasm').read_bytes()).hexdigest(),after_runner_sha256=hashlib.sha256(Path('tools/dew-run.mjs').read_bytes()).hexdigest(),samples=records)
(root/'run-host-rss.json').write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report,indent=2))
```
