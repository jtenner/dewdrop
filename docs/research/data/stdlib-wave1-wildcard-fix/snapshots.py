#!/usr/bin/env python3
"""Run the normal fixture check and preserve its exact WAT for review."""
import gzip
import hashlib
import json
import difflib
import importlib.util
from pathlib import Path
import sys
root = Path.cwd()
spec = importlib.util.spec_from_file_location('snapshot_runner', root / 'tools/module-snapshots/run.py')
r = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = r
spec.loader.exec_module(r)
r.check_wasm_tools_version()
compiler = r.build_snapshot_compiler(root / '_build')
temp = root / '.tmp/wildcard/snapshots'
temp.mkdir(parents=True, exist_ok=True)
wago = temp / 'wago-runner'
r.build_wago_runner(wago)
source = root / 'tests/module-snapshots/modules/std-wildcard-runtime.dew'
observed = {"runtime": {}, "compilations": []}
compile_fixture = r.compile_fixture
def compile_and_record(*args):
    compiled, errors, warnings = compile_fixture(*args)
    observed["compilations"].append({"compiled": compiled, "errors": errors, "warnings": warnings})
    return compiled, errors, warnings
r.compile_fixture = compile_and_record
for name in ('node', 'wago'):
    original = getattr(r, 'run_main_' + name)
    def record_runtime(*args, original=original, name=name):
        output = original(*args)
        observed['runtime'][name] = output
        return output
    setattr(r, 'run_main_' + name, record_runtime)
result = r.process_fixture(source, temp, compiler, wago, ['node', 'wago'], False, False)
r.emit_result(result)
wat = temp / 'modules__std-wildcard-runtime.wat'
binary = temp / 'modules__std-wildcard-runtime.wasm'
if binary.exists():
    r.run(['wasm-tools', 'validate', str(binary)])
    r.render_wat(binary, wat)
if wat.exists():
    evidence = root / 'docs/research/data/stdlib-wave1-wildcard-fix'
    (evidence / 'std-wildcard-runtime.actual.wat.gz').write_bytes(gzip.compress(wat.read_bytes(), mtime=0))
    old = source.with_suffix('.wat').read_bytes()
    new = wat.read_bytes()
    observed['old_wat_sha256'] = hashlib.sha256(old).hexdigest()
    observed['new_wat_sha256'] = hashlib.sha256(new).hexdigest()
    observed['old_json_sha256'] = hashlib.sha256(source.with_suffix('.json').read_bytes()).hexdigest()
    diff = ''.join(difflib.unified_diff(old.decode().splitlines(True), new.decode().splitlines(True), fromfile='expected.wat', tofile='actual.wat'))
    (evidence / 'std-wildcard-runtime.diff.gz').write_bytes(gzip.compress(diff.encode(), mtime=0))
    (evidence / 'snapshot-result.json').write_text(json.dumps(observed, indent=2) + '\n')
print(f'focused snapshots: passed={int(not result.failed)} failed={int(result.failed)}; repeat and Node/Wago checks enabled')
sys.exit(int(result.failed))
