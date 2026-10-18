#!/usr/bin/env python3
"""Measure the actual oversized-list tests after a native parser test build.

From the repository root:
  DEW_NATIVE_TEST_PACKAGES=parser tools/test-native.sh --filter '*parse-event*'
  python3 docs/research/data/parse-cache-depth-admission-2026-10-18/measure_item_admission.py

The direct runner measurements exclude Moon and compiler memory. wait4 reports
native process peak RSS in KiB on Linux. All native test results are checked.
"""
from pathlib import Path
import hashlib
import json
import os
import subprocess
import tempfile
import time

root = Path('_build/native/debug/test/jtenner/dewdrop/parser')
binary = root / 'parser.whitebox_test.exe'
metadata = json.loads((root / '__whitebox_test_info.json').read_text())
filename = 'parse_event_artifact_wbtest.mbt'
names = {
    'parse-event oversized array rejects before writing or walking elements',
    'parse-event oversized event count rejects before writer allocation',
}
selected = [test for test in metadata['tests'][filename] if test['name'] in names]
assert len(selected) == len(names), 'Required oversized-list tests are missing'
samples = []
for test in selected:
    for sample in range(3):
        index = test['index']
        command = [str(binary), f'{filename}:{index}-{index + 1}']
        start = time.perf_counter()
        with tempfile.TemporaryFile(mode='w+') as output:
            child = subprocess.Popen(command, stdout=output, stderr=subprocess.STDOUT)
            _, status, usage = os.wait4(child.pid, 0)
            child.returncode = os.waitstatus_to_exitcode(status)
            elapsed = time.perf_counter() - start
            output.seek(0)
            text = output.read()
        records = [json.loads(line) for line in text.splitlines() if line.startswith('{')]
        results = [record for record in records if record.get('type') == 'result']
        assert child.returncode == 0, text
        assert len(results) == 1 and results[0]['message'] == '', text
        samples.append({
            'index': index,
            'sample': sample,
            'elapsed_seconds': elapsed,
            'peak_rss_kib': usage.ru_maxrss,
            'exit': child.returncode,
        })
print(json.dumps({
    'binary_sha256': hashlib.sha256(binary.read_bytes()).hexdigest(),
    'artifact_source_sha256': hashlib.sha256(
        Path('src/parser/parse_event_artifact.mbt').read_bytes()
    ).hexdigest(),
    'samples': samples,
}, indent=2))
