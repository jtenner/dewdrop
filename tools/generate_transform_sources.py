#!/usr/bin/env python3
"""Embed the ordinary Dew transform API for both compiler implementations."""
import json
from pathlib import Path
import sys
root = Path(__file__).resolve().parent.parent
parts = []
for name in ('ast', 'transform'):
    data = (root / 'lib/dewdrop' / (name + '.dew')).read_text()
    parts.append('///|\npub fn ' + name + '_source() -> Bytes {\n  b' + json.dumps(data) + '\n}\n')
output = '\n'.join(parts)
path = root / 'src/transforms/library.mbt'
if '--check' in sys.argv:
    if path.read_text() != output:
        sys.exit('transform sources are stale')
else:
    path.write_text(output)

parts = []
for name in ('ast', 'transform'):
    data = (root / 'lib/dewdrop' / (name + '.dew')).read_text()
    parts.append('fn ct_' + name + '_source() -> Bytes {\n  b' + json.dumps(data) + '\n}\n')
path = root / 'self_host/compiler/transform_library.dew'
output = '\n'.join(parts)
if '--check' in sys.argv:
    if path.read_text() != output:
        sys.exit('Dew transform sources are stale')
else:
    path.write_text(output)
