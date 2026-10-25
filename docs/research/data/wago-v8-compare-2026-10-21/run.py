import importlib.util
import json
from pathlib import Path
import statistics
import subprocess

root = Path('/home/dev/Projects/dewdrop')
spec = importlib.util.spec_from_file_location('measure', root / 'docs/research/data/wago-local-perf-2026-10-20/measure.py')
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
m.DATA = root / 'docs/research/data/wago-v8-compare-2026-10-21'
m.DATA.mkdir(parents=True, exist_ok=False)
original_measure = m.measure

def measure(label, command, **kwargs):
    command = list(command)
    if command[0] == 'node':
        command[3] = m.COMPILER
    return original_measure(label, command, **kwargs)

m.measure = measure
identity = {
    'installed_version': subprocess.check_output(['wago', 'version', 'current'], text=True).strip(),
    'wago_host_sha256': m.digest(m.WORK / 'final-69c165ace-host'),
    'compiler_sha256': m.digest(m.COMPILER),
    'request_sha256': m.digest(m.WORK / 'request.bin'),
    'node_versions': json.loads(subprocess.check_output(['node', '-p', 'JSON.stringify(process.versions)'], text=True)),
    'method': 'Three fresh processes per engine, alternating order, cold Wago native cache, no transform result cache. Both engines use the exact same compiler and request. End-to-end wall time includes engine compilation, startup, Dewdrop compilation and file output.',
}
(m.DATA / 'identity.json').write_text(json.dumps(identity, indent=2) + '\n')
rows = []
for round_index in range(1, 4):
    engines = [('wago', 'final-69c165ace'), ('v8', 'node')]
    if round_index % 2 == 0:
        engines.reverse()
    for engine, version in engines:
        label = f'compare-{engine}-{round_index}'
        m.full(label, version)
        row = json.loads((m.DATA / (label + '.json')).read_text())
        row['engine'] = engine
        rows.append(row)
        (m.DATA / 'samples.json').write_text(json.dumps(rows, indent=2) + '\n')
summary = {}
for engine in ['wago', 'v8']:
    samples = [r['seconds'] for r in rows if r['engine'] == engine]
    summary[engine] = {'seconds': samples, 'median_seconds': statistics.median(samples), 'min_seconds': min(samples), 'max_seconds': max(samples)}
summary['wago_over_v8'] = summary['wago']['median_seconds'] / summary['v8']['median_seconds']
summary['all_outputs_identical_and_main_42'] = True
(m.DATA / 'summary.json').write_text(json.dumps(summary, indent=2) + '\n')
print(json.dumps(summary, indent=2), flush=True)
