#!/usr/bin/env python3
"""Rebuild the private Wago diagnostic host from a pinned baseline identity."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile

root = Path(__file__).resolve().parents[4]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('baseline_host', type=Path)
parser.add_argument('output', type=Path)
parser.add_argument('--gcstats', action='store_true')
args = parser.parse_args()
baseline = args.baseline_host.resolve()
identity = json.loads(baseline.with_name(baseline.name + '.identity.json').read_text())
assert identity['version'] == 'v0.0.0-20260915172549-2dd978ccda6f'
source = Path(identity['private_source'])
assert source.is_dir(), source
assert hashlib.sha256(baseline.read_bytes()).hexdigest() == identity['host_sha256']
work = Path(tempfile.mkdtemp(prefix='wago-profile-repro-', dir=root / '.tmp'))
shutil.copytree(source, work / 'wago')
host = work / 'host'
host.mkdir()
inputs = root / 'tools/wago-transform-host'
digest = hashlib.sha256()
for path in [inputs/'go.mod', inputs/'go.sum', *sorted(inputs.glob('*.go'))]:
    data = path.read_bytes()
    (host/path.name).write_bytes(data)
    if not path.name.endswith('_test.go'):
        digest.update(path.name.encode() + b'\0' + data + b'\0')
assert digest.hexdigest() == identity['host_source_sha256'], 'host sources differ from the baseline'
with (host/'go.mod').open('a') as stream:
    stream.write('\nreplace github.com/wago-org/wago => ' + json.dumps(str(work/'wago')) + '\n')
patch = Path(__file__).with_name('diagnostic.patch')
subprocess.run(['git', 'init', '-q', str(work)], check=True)
subprocess.run(['git', '-C', str(work), 'apply', '--check', str(patch)], check=True)
subprocess.run(['git', '-C', str(work), 'apply', str(patch)], check=True)
command = ['mise', 'exec', 'go@1.27.2', '--', 'go', 'build', '-C', str(host), '-mod=mod']
if args.gcstats:
    command.append('-tags=wago_gcstats')
output = args.output.resolve()
output.parent.mkdir(parents=True, exist_ok=True)
command += ['-o', str(output), '.']
subprocess.run(command, check=True, env=dict(os.environ, GOWORK='off'))
report = {'baseline': identity, 'diagnostic_patch_sha256': hashlib.sha256(patch.read_bytes()).hexdigest(),
          'gcstats': args.gcstats, 'command': command, 'private_source': str(work),
          'host_sha256': hashlib.sha256(output.read_bytes()).hexdigest()}
output.with_name(output.name+'.diagnostic.json').write_text(json.dumps(report, indent=2)+'\n')
print(output)
