from pathlib import Path
import argparse
import hashlib
import json
import os
import platform
import statistics
import subprocess
import tempfile
import time

BASELINE = "9d86b829292b1efa8f1aca32b0ff49565c878ee0"
REPOSITORY = Path(subprocess.check_output(["git", "rev-parse", "--show-toplevel"], text=True).strip())
HERE = Path(__file__).resolve().parent
parser = argparse.ArgumentParser(description="Measure runner RSS without replacing saved research data.")
parser.add_argument("--output", type=Path, help="JSON report path; default is a unique system temporary directory")
arguments = parser.parse_args()
output = arguments.output or Path(tempfile.mkdtemp(prefix="dew-run-readv-report-")) / "rss.json"
output.parent.mkdir(parents=True, exist_ok=True)
fixture = HERE / "read-stream.wasm"
current = REPOSITORY / "tools/dew-run.mjs"
old_source = subprocess.check_output(["git", "show", BASELINE + ":tools/dew-run.mjs"], cwd=REPOSITORY)
new_source = current.read_bytes()
sha = lambda data: hashlib.sha256(data).hexdigest()
load_before = os.getloadavg()
records = []
worker = "import subprocess,resource,json,sys; r=subprocess.run(sys.argv[1:],stdin=sys.stdin.buffer,stdout=subprocess.PIPE,stderr=subprocess.PIPE); sys.stdout.buffer.write(r.stdout); print(json.dumps({'peak_rss_kib':resource.getrusage(resource.RUSAGE_CHILDREN).ru_maxrss,'stderr':r.stderr.decode()}),file=sys.stderr); sys.exit(r.returncode)"
with tempfile.TemporaryDirectory(prefix="dew-run-readv-rss-") as temp:
    baseline = Path(temp) / "before.mjs"
    final = Path(temp) / "after.mjs"
    baseline.write_bytes(old_source)
    final.write_bytes(new_source)
    variants = [("before", baseline), ("after", final)]
    for size in (1024 * 1024, 64 * 1024 * 1024):
        payload = b"x" * size
        for sample in range(3):
            order = variants if sample % 2 == 0 else list(reversed(variants))
            for identity, runner in order:
                command = ["python3", "-c", worker, "node", str(runner), str(fixture)]
                start = time.monotonic()
                result = subprocess.run(command, input=payload, capture_output=True, timeout=15, check=True)
                elapsed = time.monotonic() - start
                metrics = json.loads(result.stderr)
                actual = int.from_bytes(result.stdout, "little")
                assert len(result.stdout) == 4 and actual == size, (actual, size, result.stdout)
                assert metrics["stderr"] == "", metrics
                records.append(dict(identity=identity, input_bytes=size, sample=sample,
                                    order=[name for name, _ in order],
                                    peak_rss_kib=metrics["peak_rss_kib"],
                                    elapsed_seconds=elapsed, processed_bytes=actual))
assert current.read_bytes() == new_source, "runner source changed during measurement"
report = dict(baseline=BASELINE,
              node=subprocess.check_output(["node", "--version"], text=True).strip(),
              platform=platform.platform(), architecture=platform.machine(),
              load_before=load_before, load_after=os.getloadavg(),
              baseline_runner_sha256=sha(old_source), after_runner_sha256=sha(new_source),
              fixture_sha256=sha(fixture.read_bytes()), harness_sha256=sha(Path(__file__).read_bytes()),
              method="fresh Node via fresh Python worker; alternating pairs; normal host load; no CPU pinning or warmup; source snapshots; byte count asserted",
              samples=records)
summary = {}
for size in (1024 * 1024, 64 * 1024 * 1024):
    summary[str(size)] = {}
    for identity in ("before", "after"):
        rows = [row for row in records if row["input_bytes"] == size and row["identity"] == identity]
        summary[str(size)][identity] = dict(
            median_peak_rss_kib=statistics.median(row["peak_rss_kib"] for row in rows),
            median_elapsed_ms=statistics.median(row["elapsed_seconds"] for row in rows) * 1000)
report["summary"] = summary
output.write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(dict(report_path=str(output.resolve()), after_runner_sha256=report["after_runner_sha256"], summary=summary), indent=2))
