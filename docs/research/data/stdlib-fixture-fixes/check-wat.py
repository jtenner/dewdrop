#!/usr/bin/env python3
"""Validate and execute base/current expected WAT; no Dew files are changed."""
import importlib.util
import json
import subprocess
import sys
import tempfile
import time
from pathlib import Path

ROOT = Path.cwd()
DATA = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('snapshots', ROOT / 'tools/module-snapshots/run.py')
runner = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = runner
spec.loader.exec_module(runner)
with tempfile.TemporaryDirectory(prefix='wave1-wat-review-') as directory:
    scratch = Path(directory)
    wago = scratch / 'wago-runner'
    started = time.perf_counter()
    runner.build_wago_runner(wago)
    print(f'wago build seconds: {time.perf_counter() - started:.3f}', flush=True)
    import gzip
    for diff in sorted(DATA.glob('*.diff.gz')):
        fixture = gzip.decompress(diff.read_bytes()).decode().splitlines()[0][4:]
        source = ROOT / fixture
        expected = json.loads(source.with_suffix('.json').read_text())
        host = expected.get('host', {})
        versions = [('old', subprocess.check_output(['git', 'show', f'b9fcc8ea:{fixture}'])), ('new', source.read_bytes())]
        for label, content in versions:
            wat = scratch / (source.stem + '.' + label + '.wat')
            binary = wat.with_suffix('.wasm')
            wat.write_bytes(content)
            started = time.perf_counter()
            subprocess.run(['wasm-tools', 'parse', str(wat), '-o', str(binary)], check=True)
            subprocess.run(['wasm-tools', 'validate', '--features', 'all', str(binary)], check=True)
            result = {'fixture': fixture, 'version': label, 'parse_validate_seconds': round(time.perf_counter() - started, 3), 'validate_exit': 0}
            for runtime, execute in [('node', lambda: runner.run_main_node(binary, host, 'production')), ('wago', lambda: runner.run_main_wago(wago, binary, host, 'production'))]:
                started = time.perf_counter()
                result[runtime] = execute()
                result[runtime + '_seconds'] = round(time.perf_counter() - started, 3)
                assert result[runtime] == expected['output'], result
            print(json.dumps(result), flush=True)
