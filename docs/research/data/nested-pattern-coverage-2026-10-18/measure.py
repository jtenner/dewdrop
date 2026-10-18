#!/usr/bin/env python3
"""Measure direct native CLI checks; Linux wait4 reports child peak RSS in KiB."""
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
INPUTS = Path(__file__).resolve().parent
CLI = REPO / '_build/native/release/build/jtenner/dewdrop/dew_cli/dew_cli.exe'
FLAGS = ['check', '--no-cache-pack', '--no-program-cache', '--no-parse-event-cache',
         '--no-interface-cache', '--no-body-cache', '--no-plan-cache']
results = []
with tempfile.TemporaryDirectory(prefix='dewdrop-pattern-footprint-') as temp:
    for case in ['simple', 'nested-runtime', 'nested-budget']:
        for sample in range(3):
            args = [str(CLI), *FLAGS, str(INPUTS / (case + '.dew'))]
            stdout = Path(temp) / 'stdout'
            stderr = Path(temp) / 'stderr'
            with stdout.open('w') as out, stderr.open('w') as err:
                started = time.perf_counter()
                child = subprocess.Popen(args, cwd=REPO, stdout=out, stderr=err)
                _, status, usage = os.wait4(child.pid, 0)
                elapsed = time.perf_counter() - started
                child.returncode = os.waitstatus_to_exitcode(status)
            expected = 1 if case == 'nested-budget' else 0
            if child.returncode != expected:
                raise RuntimeError(f'{case}: {stdout.read_text()}{stderr.read_text()}')
            results.append(dict(case=case, sample=sample, command=args,
                                exit=child.returncode, wall_seconds=elapsed,
                                peak_rss_kib=usage.ru_maxrss,
                                stdout=stdout.read_text(), stderr=stderr.read_text()))
summary = {case: dict(median_wall_seconds=statistics.median(
    item['wall_seconds'] for item in results if item['case'] == case),
    peak_rss_kib=max(item['peak_rss_kib'] for item in results if item['case'] == case))
    for case in ['simple', 'nested-runtime', 'nested-budget']}
record = dict(binary=str(CLI), binary_sha256=hashlib.sha256(CLI.read_bytes()).hexdigest(),
              head=subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=REPO, text=True).strip(),
              platform=platform.platform(), architecture=platform.machine(),
              cache_policy='All CLI cache layers disabled; prebuilt native binary; no rebuild.',
              samples=results, summary=summary)
(INPUTS / 'footprint.json').write_text(json.dumps(record, indent=2) + '\n')
print(json.dumps(summary, indent=2))
