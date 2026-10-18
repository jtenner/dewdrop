#!/usr/bin/env python3
"""Compare direct native compiler processes; Linux wait4 RSS is process peak."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import statistics
import subprocess
import tempfile
import time

REPO = Path(__file__).resolve().parents[4]
parser = argparse.ArgumentParser()
parser.add_argument('--before', type=Path, required=True)
parser.add_argument('--after', type=Path, default=REPO / '_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe')
args = parser.parse_args()
binaries = {'before': args.before.resolve(), 'after': args.after.resolve()}
identities = {name: hashlib.sha256(path.read_bytes()).hexdigest() for name, path in binaries.items()}
source = REPO / 'tests/module-snapshots/functions/generic-aggregate-callback-adapter-runtime.dew'
flags = ['--no-cache-pack', '--no-program-cache', '--no-parse-event-cache',
         '--no-interface-cache', '--no-body-cache', '--no-plan-cache']
head = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=REPO, text=True).strip()
status = subprocess.check_output(['git', '--no-optional-locks', 'status', '--porcelain=v1', '--untracked-files=all'], cwd=REPO, text=True)
samples = []
with tempfile.TemporaryDirectory(prefix='dewdrop-callback-cost-') as temp:
    for sample in range(5):
        for name in ['before', 'after']:
            output = Path(temp) / (name + '.wasm')
            stdout, stderr = Path(temp) / 'stdout', Path(temp) / 'stderr'
            command = [str(binaries[name]), 'build', *flags, str(source), '-o', str(output)]
            with stdout.open('w') as out, stderr.open('w') as err:
                started = time.perf_counter()
                child = subprocess.Popen(command, cwd=REPO, stdout=out, stderr=err)
                _, code, usage = os.wait4(child.pid, 0)
                elapsed = time.perf_counter() - started
                child.returncode = os.waitstatus_to_exitcode(code)
            if child.returncode:
                raise RuntimeError(stdout.read_text() + stderr.read_text())
            samples.append(dict(variant=name, sample=sample, command=command,
                                wall_seconds=elapsed, peak_rss_kib=usage.ru_maxrss,
                                wasm_bytes=output.stat().st_size,
                                wasm_sha256=hashlib.sha256(output.read_bytes()).hexdigest(),
                                stdout=stdout.read_text(), stderr=stderr.read_text()))
for name, path in binaries.items():
    if hashlib.sha256(path.read_bytes()).hexdigest() != identities[name]:
        raise RuntimeError('Compiler binary changed during measurement: ' + name)
record = dict(head=head, status_before_samples=status,
              binary_paths={name: str(path) for name, path in binaries.items()},
              binary_sha256=identities, input_sha256=hashlib.sha256(source.read_bytes()).hexdigest(),
              harness_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              platform=platform.platform(), architecture=platform.machine(),
              limits='Five alternating process samples on a shared host; RSS is not an allocation count. No isolated compiler speedup claim.',
              summary={name: dict(median_wall_seconds=statistics.median(s['wall_seconds'] for s in samples if s['variant'] == name),
                                  peak_rss_kib=max(s['peak_rss_kib'] for s in samples if s['variant'] == name),
                                  wasm_bytes=next(s['wasm_bytes'] for s in samples if s['variant'] == name))
                       for name in binaries}, samples=samples)
Path(__file__).with_name('samples.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(record['summary'], indent=2))
