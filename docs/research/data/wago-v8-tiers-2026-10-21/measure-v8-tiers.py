"""Isolate optimizing-tier impact; default V8 remains the primary comparison."""
import importlib.util
import json
import statistics
import subprocess
from pathlib import Path

root = Path('/home/dev/Projects/dewdrop')
spec = importlib.util.spec_from_file_location('measure', root/'docs/research/data/wago-local-perf-2026-10-20/measure.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.DATA = root/'docs/research/data/wago-v8-tiers-2026-10-21'
m.DATA.mkdir(parents=True, exist_ok=True)
m.ENV = dict(m.ENV, GOMAXPROCS='2')
original = m.measure
selected = ''

def measure(label, command, **kw):
    command = list(command)
    assert command[0] == 'node'
    command[3] = m.COMPILER
    if selected:
        command.insert(1, selected)
    return original(label, ['taskset', '-c', '12,14', *command], **kw)

m.measure = measure
identity = dict(compiler_sha256=m.digest(m.COMPILER), request_sha256=m.digest(m.WORK/'request.bin'),
               node_versions=json.loads(subprocess.check_output(['node', '-p', 'JSON.stringify(process.versions)'], text=True)),
               affinity='12,14', method='Serial balanced default/liftoff-only/no-liftoff; three samples each. Identical compiler/request, no transform result cache. Ablation only; primary V8 comparison always uses defaults.')
(m.DATA/'identity.json').write_text(json.dumps(identity, indent=2)+'\n')
rows = json.loads((m.DATA/'samples.json').read_text()) if (m.DATA/'samples.json').exists() else []
variants = [('default', ''), ('baseline-only', '--liftoff-only'), ('optimizing-only', '--no-liftoff')]
for round_index, order in enumerate([variants, variants[1:]+variants[:1], variants[2:]+variants[:2]], 1):
    for engine, flag in order:
        label = f'v8-tier-{engine}-{round_index}'
        if any(row['label'] == label for row in rows):
            continue
        selected = flag
        m.full(label, 'node')
        row = json.loads((m.DATA/(label+'.json')).read_text())
        row.update(engine=engine, tier_flag=flag)
        rows.append(row)
        (m.DATA/'samples.json').write_text(json.dumps(rows, indent=2)+'\n')
summary = {}
for engine, flag in variants:
    times = [row['seconds'] for row in rows if row['engine'] == engine]
    summary[engine] = dict(flag=flag, seconds=times, median_seconds=statistics.median(times))
summary['all_outputs_identical_and_main_42'] = True
(m.DATA/'summary.json').write_text(json.dumps(summary, indent=2)+'\n')
print(json.dumps(summary, indent=2), flush=True)
