"""Run from the repository root with compiler C and its matching A request."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import tempfile
import time

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('compiler', type=Path)
parser.add_argument('template', type=Path)
parser.add_argument('output', type=Path, nargs='?')
args = parser.parse_args()
repo = Path.cwd()
source = Path(__file__).resolve().parent
assert (repo / 'tools/run-dew-facet.mjs').is_file(), 'run from repository root'
compiler = args.compiler.resolve(strict=True)
template = args.template.resolve(strict=True)
work = args.output.resolve() if args.output else Path(tempfile.mkdtemp(prefix='dewdrop-feature-probe-'))
work.mkdir(parents=True, exist_ok=True)

def copy_file(src, dst):
    if src.resolve() != dst.resolve():
        shutil.copyfile(src, dst)

copy_file(compiler, work / 'compiler-c.wasm')
copy_file(template, work / 'template.bin')
for name in ['main.dew', 'vault.dew', 'invalid.dew']:
    copy_file(source / name, work / name)
records = []
failed = False

def run(label, command, cwd):
    start = time.monotonic()
    try:
        result = subprocess.run(command, cwd=cwd, capture_output=True, text=True, timeout=28)
        status, stdout, stderr = result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired as error:
        status = 124
        stdout = error.stdout.decode() if isinstance(error.stdout, bytes) else error.stdout or ''
        stderr = error.stderr.decode() if isinstance(error.stderr, bytes) else error.stderr or ''
        stderr += '\ncompiler stage exceeded the 28-second limit\n'
    record = dict(label=label, command=[str(x) for x in command], cwd=str(cwd),
                  elapsed_seconds=time.monotonic()-start, exit_status=status,
                  stdout=stdout, stderr=stderr)
    records.append(record)
    (work / (label + '.log')).write_text(stdout + stderr)
    print(json.dumps(dict(label=label, seconds=record['elapsed_seconds'], status=status)), flush=True)
    return record

try:
    exported = run('export-memory', ['mise', 'exec', 'wasm-tools@1.262.0', '--', 'python3',
                   str(repo / 'tools/export-wasm-memory.py'), str(work / 'compiler-c.wasm'),
                   str(work / 'compiler-c-memory.wasm')], repo)
    assert exported['exit_status'] == 0, 'compiler memory export failed'
    rewritten = run('rewrite-request', ['python3', str(source / 'rewrite-request.py'),
                    str(work / 'template.bin'), str(work)], repo)
    assert rewritten['exit_status'] == 0, 'source request rewrite failed'
    for label in ['positive', 'negative']:
        output = work / (label + '-c.wasm')
        output.unlink(missing_ok=True)
        compiled = run(label + '-compile', ['node', '--stack-size=65500',
                       str(repo / 'tools/run-dew-facet.mjs'), str(work / 'compiler-c-memory.wasm'),
                       str(work / (label + '-request.bin'))], work)
        compiled['output_exists'] = output.exists()
        if output.exists():
            compiled['output_sha256'] = hashlib.sha256(output.read_bytes()).hexdigest()
            compiled['output_bytes'] = output.stat().st_size
        if label == 'positive':
            if compiled['exit_status'] != 0 or not output.exists():
                failed = True
            else:
                result = run('positive-runtime', ['node', str(source / 'run-output.mjs'), str(output)], work)
                failed |= result['exit_status'] != 0
        else:
            diagnostics = compiled['stdout'] + compiled['stderr']
            expected = any(message in diagnostics for message in [
                'MissingImportedConstructionField', 'MissingConstructionField',
                'missing imported construction field', 'missing construction field'])
            failed |= compiled['exit_status'] != 1 or output.exists() or not expected
except Exception as error:
    failed = True
    records.append(dict(label='harness-error', error=str(error)))
finally:
    digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    report = dict(status=1 if failed else 0, compiler_sha256=digest(work / 'compiler-c.wasm'),
                  template_sha256=digest(work / 'template.bin'),
                  fixture_sha256={name: digest(work / name) for name in ['main.dew', 'vault.dew', 'invalid.dew']},
                  harness_sha256={name: digest(source / name) for name in ['run.py', 'rewrite-request.py', 'run-output.mjs']},
                  results=records)
    host_compiler = work / 'compiler-c-memory.wasm'
    if host_compiler.exists():
        report['host_compiler_sha256'] = digest(host_compiler)
    (work / 'validation.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps(dict(status=report['status'], evidence=str(work / 'validation.json'))), flush=True)
raise SystemExit(report['status'])
