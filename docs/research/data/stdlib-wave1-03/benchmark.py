"""Run under build.lock; emit small runtime/memory records, no saved binaries."""
import json
import pathlib
import subprocess
import time

root = pathlib.Path('.tmp')
for kind in ('prefix', 'dense'):
    for size in (1024, 8192, 65536):
        value = 'a' * size if kind == 'prefix' else 'a,' * (size // 2)
        delimiter = 'aaaaab' if kind == 'prefix' else ','
        source = root / f'{kind}-{size}.dew'
        wasm = source.with_suffix('.wasm')
        source.write_text(f'''open dew.std.string
open dew.std.text
pub fn main() -> U32 {{
  let parts = "{value}".view(0u32, {size}u32).split("{delimiter}".view(0u32, {len(delimiter)}u32))
  let mut count = 0u32
  for field in parts {{
    count = count + field.byte_length()
  }}
  assert(parts.source_scans() == {size}u32, "scan bound")
  assert(parts.comparisons() <= {2*size}u32, "comparison bound")
  assert(count == {size if kind == 'prefix' else size//2}u32, "field bytes")
  parts.source_scans()
}}
''')
        started = time.monotonic()
        subprocess.run(['moon', 'run', '--target', 'native', '-j1', 'src/module_snapshot_gen', '--', str(wasm), 'production', 'app.bench', 'bench.dew', str(source)], check=True)
        elapsed = time.monotonic() - started
        print(json.dumps({'kind': kind, 'bytes': size, 'compile_s': elapsed, 'over_30s': elapsed > 30}), flush=True)
        subprocess.run(['node', '--expose-gc', 'docs/research/data/stdlib-wave1-03/benchmark.mjs', str(wasm), str(size), kind], check=True)
