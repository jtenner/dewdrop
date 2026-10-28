#!/usr/bin/env python3
"""Narrow native bootstrap contract checks. No Dew compiler build or timing workload."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import struct
import subprocess
import tempfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent.parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--evidence', type=Path, required=True)
    parser.add_argument('--revision', help='Read production inputs from an exact Git revision')
    args = parser.parse_args()
    args.evidence.mkdir(parents=True, exist_ok=True)
    evidence = {'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(), 'checks': []}
    failures = []
    with tempfile.TemporaryDirectory(prefix='dew-bootstrap-contract-') as temp:
        project = Path(temp)
        source = project / 'src'
        source.mkdir()
        if args.revision:
            evidence['production_revision'] = subprocess.check_output(['git', 'rev-parse', args.revision], cwd=ROOT, text=True).strip()
            paths = subprocess.check_output(['git', 'ls-tree', '-r', '--name-only', args.revision, 'src/dew_bootstrap'], cwd=ROOT, text=True).splitlines()
            for name in paths:
                path = Path(name)
                if (path.suffix in ('.mbt', '.c') and not path.name.endswith(('_test.mbt', '_wbtest.mbt'))) or path.name == 'moon.pkg':
                    (source / path.name).write_bytes(subprocess.check_output(['git', 'show', args.revision + ':' + name], cwd=ROOT))
        else:
            for path in HERE.iterdir():
                if path.suffix in ('.mbt', '.c') and not path.name.endswith(('_test.mbt', '_wbtest.mbt')):
                    shutil.copy2(path, source / path.name)
            shutil.copy2(HERE / 'moon.pkg', source / 'moon.pkg')
        main_path = source / 'main.mbt'
        main_path.write_text(main_path.read_text().split('fn main {')[0] + (HERE / 'package_contract_driver.mbt.fixture').read_text())
        (project / 'moon.mod').write_text('name = "fixture/bootstrap-contract"\nversion = "0.1.0"\nsource = "src"\nimport { "moonbitlang/x@0.5.5", }\n')
        (project / 'moon.work').write_text('members = ["."]\n')
        command = ['moon', 'build', '--target', 'native', 'src']
        start = time.monotonic()
        process = subprocess.Popen(command, cwd=project, text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, start_new_session=True)
        try:
            stdout, stderr = process.communicate(timeout=30)
            build = subprocess.CompletedProcess(command, process.returncode, stdout, stderr)
        except subprocess.TimeoutExpired:
            os.killpg(process.pid, signal.SIGKILL)
            stdout, stderr = process.communicate()
            build = subprocess.CompletedProcess(command, 124, stdout, stderr + "\nNarrow build exceeded 30 seconds; process group stopped.\n")
        evidence['build'] = {'command': command, 'wall_seconds': time.monotonic() - start, 'exit': build.returncode, 'stdout': build.stdout, 'stderr': build.stderr}
        if build.returncode:
            (args.evidence / 'results.json').write_text(json.dumps(evidence, indent=2))
            print(build.stdout + build.stderr)
            raise SystemExit(build.returncode)
        exe = next(project.glob('_build/native/**/*.exe'))
        evidence['binary_sha256'] = hashlib.sha256(exe.read_bytes()).hexdigest()
        evidence['source_sha256'] = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in source.iterdir() if p.is_file()}
        workspace = project / 'workspace'
        workspace.mkdir()
        env = dict(os.environ, DEW_CACHE_DIR=str(project / 'cache'), DEW_REPOSITORY_ROOT=str(ROOT))
        counter = 0

        def run(action, path, *more):
            command = [str(exe), action, str(path), *more]
            proc = subprocess.run(command, text=True, capture_output=True, env=env, timeout=10)
            return command, proc

        def check(name, action, path, expected='', valid=False, more=(), exact=None):
            command, proc = run(action, path, *more)
            passed = (proc.returncode == 0 and expected in proc.stdout) if valid else (proc.returncode == 2 and expected.lower() in (proc.stdout + proc.stderr).lower())
            if exact is not None:
                actual_lines = proc.stdout.splitlines()
                if action == 'sources':
                    actual_lines = ['/' + line.lstrip('/') for line in actual_lines]
                passed = passed and actual_lines == exact
            evidence['checks'].append({'name': name, 'command': command, 'stdout': proc.stdout, 'stderr': proc.stderr, 'exit': proc.returncode, 'expected': expected, 'exact_lines': exact, 'valid': valid, 'pass': passed})
            print(('PASS ' if passed else 'FAIL ') + name)
            if not passed:
                failures.append(name)
            return proc

        def package(fields=None, raw=None):
            nonlocal counter
            counter += 1
            folder = workspace / str(counter)
            folder.mkdir()
            (folder / 'dew.json').write_text(raw if raw is not None else json.dumps(fields or {'name': '@fixture/root', 'version': '1.0.0'}))
            (folder / 'main.dew').write_text('pub fn value() -> U32 { 1u32 }\n')
            return folder

        def lock(folder, **changes):
            entry = {'name': '@fixture/dep', 'version': '1.0.0', 'source': 'file:dep', 'path': 'dep', 'integrity': 'sha256-' + 'a' * 64, 'interface': 'b' * 64}
            entry.update(changes)
            result = {'lockfileVersion': 1, 'packages': [entry]}
            (folder / 'dew.lock').write_text(json.dumps(result))
            return result

        check('manifest absent dependencies', 'manifest', package() / 'dew.json', 'dependencies=0', True)
        for name, value, error in [
            ('unknown field', {'name': '@fixture/root', 'version': '1.0.0', 'extra': True}, 'unknown'),
            ('uppercase name', {'name': '@Fixture/root', 'version': '1.0.0'}, 'name'),
            ('unicode name', {'name': '@fixture/røot', 'version': '1.0.0'}, 'name'),
            ('long name', {'name': '@fixture/' + 'a' * 247, 'version': '1.0.0'}, 'name'),
            *[(f'version {v}', {'name': '@fixture/root', 'version': v}, 'version') for v in ['01.0.0', '1.2', '4294967296.0.0', '1.0.0-4294967296', '1.0.0-01', '1.0.0+', '1.0.0-', '1.0.0+a+b', '1.0.0-' + 'a'*250]],
            *[(f'requirement {v[:25]}', {'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {'@fixture/dep': v}}, 'requirement') for v in ['', 'latest', '^1.0', 'git+url', 'git+#ref', 'git+url#', 'git+url#ref\0', 'x' * 2049]],
            ('dependency count', {'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {f'@fixture/d{i}': '*' for i in range(257)}}, 'dependencies'),
        ]:
            check('manifest ' + name, 'manifest', package(value) / 'dew.json', error)
        for name, raw in [
            ('duplicate', '{"name":"@fixture/root","name":"@fixture/root","version":"1.0.0"}'),
            ('escaped duplicate', '{"name":"@fixture/root","na\\u006de":"@fixture/root","version":"1.0.0"}'),
            ('dependency duplicate', '{"name":"@fixture/root","version":"1.0.0","dependencies":{"@fixture/dep":"*","@fixture/dep":"*"}}'),
        ]:
            check('manifest ' + name, 'manifest', package(raw=raw) / 'dew.json', 'duplicate')
        check('manifest byte bound', 'manifest', package(raw=' ' * 1048576 + '{"name":"@fixture/root","version":"1.0.0"}') / 'dew.json', 'bound')
        for version in ['0.0.0', '4294967295.0.0', '1.0.0-4294967295+01', '1.0.0-alpha.1+build']:
            check('valid version ' + version, 'manifest', package({'name': '@fixture/root', 'version': version}) / 'dew.json', 'ok', True)
        for requirement in ['*', '^0.0.1', '~1.2.3', '1.0.0+build', 'git+https://host/repo#main']:
            check('valid requirement ' + requirement, 'manifest', package({'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {'@fixture/dep': requirement}}) / 'dew.json', 'ok', True)

        for field, value, error in [('extra', 1, 'unknown'), ('name', '@Fixture/dep', 'name'), ('version', '01.0.0', 'version'), ('source', '', 'source'), ('source', 'x'*2049, 'source'), ('source', 'bad\0source', 'source'), ('path', '../outside', 'path'), ('path', '/outside', 'path'), ('path', 'dep\\escape', 'path'), ('path', 'C:/outside', 'path'), ('path', 'dep//nested', 'path'), ('integrity', 'sha256-' + 'z'*64, 'integrity'), ('interface', 'z'*64, 'interface')]:
            folder = package()
            lock(folder, **{field: value})
            check('lock ' + field + ' ' + repr(value[:20] if isinstance(value, str) else value), 'lock', folder / 'dew.lock', error)
        for name, raw, error in [('unknown root', '{"lockfileVersion":1,"packages":[],"extra":1}', 'unknown'), ('duplicate root', '{"lockfileVersion":1,"lockfileVersion":1,"packages":[]}', 'duplicate'), ('escaped duplicate', '{"lockfileVersion":1,"packages":[],"packa\\u0067es":[]}', 'duplicate'), ('version spelling', '{"lockfileVersion":1.0,"packages":[]}', 'version')]:
            folder = package()
            (folder / 'dew.lock').write_text(raw)
            check('lock ' + name, 'lock', folder / 'dew.lock', error)
        folder = package()
        obj = lock(folder)
        obj['packages'] *= 4097
        (folder / 'dew.lock').write_text(json.dumps(obj))
        check('lock count', 'lock', folder / 'dew.lock', 'count')

        for action in ['sources', 'integrity']:
            for kind in ['symlink source', 'symlink directory', 'root directory .dew', 'oversize source']:
                folder = package()
                if kind == 'symlink source':
                    (folder / 'main.dew').unlink()
                    (folder / 'main.dew').symlink_to(workspace / 'external.dew')
                    (workspace / 'external.dew').write_text('outside')
                elif kind == 'symlink directory':
                    external = project / ('external-src-' + str(counter))
                    external.mkdir()
                    (external / 'main.dew').write_text('outside')
                    (folder / 'src').symlink_to(external, target_is_directory=True)
                elif kind == 'root directory .dew':
                    (folder / 'folder.dew').mkdir()
                else:
                    with (folder / 'main.dew').open('wb') as file:
                        file.truncate(16777217)
                # A root directory is ignored; the only selected file stays main.dew.
                check(action + ' ' + kind, action, folder / 'dew.json', 'main.dew' if kind == 'root directory .dew' and action == 'sources' else ('sha256-' if kind == 'root directory .dew' else ('bound' if kind == 'oversize source' else 'link')), kind == 'root directory .dew', more=('false',) if action == 'sources' else (), exact=[str(folder / 'main.dew')] if action == 'sources' and kind == 'root directory .dew' else None)
        folder = package()
        (folder / 'src').mkdir()
        (folder / 'src/z.dew').write_text('z')
        (folder / 'src/a_test.dew').write_text('test')
        check('source excludes tests', 'sources', folder / 'dew.json', 'z.dew', True, ('false',))
        check('source includes tests', 'sources', folder / 'dew.json', 'a_test.dew', True, ('true',))

        for name, request, version, source_text, actual_name, actual_version, error in [
            ('range', '^2.0.0', '1.0.0', 'file:dep', '@fixture/dep', '1.0.0', 'requirement'),
            ('wildcard prerelease', '*', '1.0.0-alpha', 'file:dep', '@fixture/dep', '1.0.0-alpha', 'requirement'),
            ('git', 'git+url#main', '1.0.0', 'git+url#other', '@fixture/dep', '1.0.0', 'source'),
            ('identity', '*', '1.0.0', 'file:dep', '@fixture/other', '1.0.0', 'identity'),
            ('version identity', '*', '1.0.0', 'file:dep', '@fixture/dep', '1.0.1', 'identity'),
        ]:
            folder = package({'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {'@fixture/dep': request}})
            dep = folder / 'dep'
            dep.mkdir()
            (dep / 'dew.json').write_text(json.dumps({'name': actual_name, 'version': actual_version}))
            (dep / 'main.dew').write_text('dependency')
            _, integrity = run('integrity', dep / 'dew.json')
            lock(folder, version=version, source=source_text, integrity=integrity.stdout.strip())
            check('graph ' + name, 'graph', folder / 'dew.json', error)
        for name, exists in [('existing', True), ('missing restore', False)]:
            folder = package({'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {'@fixture/dep': '*'}})
            outside = project / ('outside-' + str(counter))
            outside.mkdir()
            if exists:
                (outside / 'dew.json').write_text('{"name":"@fixture/dep","version":"1.0.0"}')
                (outside / 'main.dew').write_text('dependency')
            (folder / 'dep').symlink_to(outside, target_is_directory=True)
            lock(folder)
            check('graph symlink ' + name, 'graph', folder / 'dew.json', 'link')

        def capsule(entry, dependencies, files):
            def field(value):
                value = value.encode() if isinstance(value, str) else value
                return struct.pack('<I', len(value)) + value
            payload = b'DEWPKG1\0' + b''.join(field(entry[k]) for k in ['name', 'version', 'source', 'integrity', 'interface'])
            payload += struct.pack('<I', len(dependencies)) + b''.join(field(n) + field(r) for n, r in dependencies)
            payload += struct.pack('<I', len(files)) + b''.join(field(n) + field(b) for n, b in files)
            return payload + hashlib.sha256(payload).digest()

        for name, deps, files, error in [
            ('bad dependency', [('@Bad/dep', '*')], [('main.dew', b'x')], 'dependency'),
            ('bad requirement', [('@fixture/dep', 'latest')], [('main.dew', b'x')], 'requirement'),
            ('duplicate dependency', [('@fixture/dep', '*'), ('@fixture/dep', '*')], [('main.dew', b'x')], 'duplicate'),
            ('oversize file', [], [('main.dew', b'x' * 16777217)], 'bound'),
            ('prefix conflict', [], [('a.dew', b'a'), ('a.dew/b.dew', b'b')], 'directory'),
            ('reverse prefix conflict', [], [('a.dew/b.dew', b'b'), ('a.dew', b'a')], 'directory'),
            ('duplicate path', [], [('main.dew', b'a'), ('main.dew', b'b')], 'duplicate'),
            ('drive path', [], [('C:/main.dew', b'a')], 'unsafe'),
        ]:
            folder = package()
            obj = lock(folder)
            _, result = run('artifact-path', folder / 'dew.lock')
            artifact = Path(result.stdout.strip())
            artifact.parent.mkdir(parents=True, exist_ok=True)
            artifact.write_bytes(capsule(obj['packages'][0], deps, files))
            check('restore ' + name, 'restore', folder / 'dew.lock', error)
            if (folder / 'dep').exists():
                failures.append('restore wrote before validating ' + name)
                print('FAIL restore wrote before validating ' + name)

        # Source order and ignored-file rules apply to compile, integrity and store.
        folder = package()
        (folder / 'src/a').mkdir(parents=True)
        (folder / 'src/a/nested.dew').write_text('nested')
        (folder / 'src/a.dew').write_text('sibling')
        (folder / 'src/z_test.dew').write_text('test')
        check('source exact global order', 'sources', folder / 'dew.json', '', True, ('true',), [str(folder / 'src/a.dew'), str(folder / 'src/a/nested.dew'), str(folder / 'src/z_test.dew')])
        check('source exact compile inventory', 'sources', folder / 'dew.json', '', True, ('false',), [str(folder / 'src/a.dew'), str(folder / 'src/a/nested.dew')])
        with (folder / 'src/ignored.txt').open('wb') as file:
            file.truncate(16777217)
        check('source ignores large non-source file', 'sources', folder / 'dew.json', '', True, ('false',), [str(folder / 'src/a.dew'), str(folder / 'src/a/nested.dew')])
        folder = package(raw='{"name":"@fixture/root","version":"1.0.0"}' + ' ' * (1048576 - 42))
        # The exact byte limit uses the actual UTF-8 length, not a string estimate.
        raw = '{"name":"@fixture/root","version":"1.0.0"}'
        (folder / 'dew.json').write_text(raw + ' ' * (1048576 - len(raw)))
        check('manifest exact byte limit', 'manifest', folder / 'dew.json', 'ok', True)
        for version in ['1.0.0+4294967296', '1.0.0-123abc', '1.0.0-' + 'a'*249]:
            check('valid version edge ' + version[:30], 'manifest', package({'name': '@fixture/root', 'version': version}) / 'dew.json', 'ok', True)
        for request, version, accepted in [
            ('^1.2.3', '1.9.9', True), ('^1.2.3', '2.0.0', False),
            ('^0.2.3', '0.2.9', True), ('^0.2.3', '0.3.0', False),
            ('^0.0.3', '0.0.3+build', True), ('^0.0.3', '0.0.4', False),
            ('~1.2.3', '1.2.9', True), ('~1.2.3', '1.3.0', False),
            ('~1.2.3', '1.2.2', False), ('~1.2.3', '1.2.4-alpha', False),
            ('1.2.3+build', '1.2.3+other', True), ('1.2.3', '1.2.4', False),
            ('1.2.3-alpha.9', '1.2.3-alpha.10', False),
            ('^1.2.3-alpha.9', '1.2.3-alpha.10', False),
            ('^1.2.3-alpha.9', '1.2.3', True),
            ('^1.2.3-alpha.9', '1.2.3-alpha.9+build', True),
            ('git+url#main', '1.0.0', True),
        ]:
            folder = package({'name': '@fixture/root', 'version': '1.0.0', 'dependencies': {'@fixture/dep': request}})
            dep = folder / 'dep'
            dep.mkdir()
            (dep / 'dew.json').write_text(json.dumps({'name': '@fixture/dep', 'version': version}))
            (dep / 'main.dew').write_text('dependency')
            _, result = run('integrity', dep / 'dew.json')
            lock(folder, version=version, source=request if request.startswith('git+') else 'file:dep', integrity=result.stdout.strip())
            check('range ' + request + ' -> ' + version, 'graph', folder / 'dew.json', 'ok' if accepted else 'requirement', accepted)
            if accepted:
                shutil.rmtree(dep)
                check('graph cached restore ' + request + ' -> ' + version, 'graph', folder / 'dew.json', 'ok', True)

        # In-memory integrity before restore must bind the conventional inventory.
        def source_integrity(entry, deps, files):
            def field(value):
                value = value.encode() if isinstance(value, str) else value
                return struct.pack('<I', len(value)) + value
            module = entry['name'][1:].replace('/', '.').replace('-', '_')
            data = b'DEW_PACKAGE_INTEGRITY_V1\0' + field(entry['name']) + field(entry['version']) + field(module)
            data += b''.join(field(n) + field(b) for n, b in sorted(files))
            data += b''.join(field(n) + field(r) for n, r in sorted(deps))
            return 'sha256-' + hashlib.sha256(data).hexdigest()

        for name, files, accepted in [
            ('nested parent order', [('src/a/b/c.dew', b'nested'), ('src/z_test.dew', b'test')], True),
            ('root test files', [('main.dew', b'main'), ('value_test.dew', b'test')], True),
            ('mixed inventory', [('main.dew', b'main'), ('src/value.dew', b'value')], False),
            ('nonconventional tree', [('other/value.dew', b'value')], False),
        ]:
            folder = package()
            obj = lock(folder)
            obj['packages'][0]['integrity'] = source_integrity(obj['packages'][0], [], files)
            (folder / 'dew.lock').write_text(json.dumps(obj))
            _, result = run('artifact-path', folder / 'dew.lock')
            artifact = Path(result.stdout.strip())
            artifact.parent.mkdir(parents=True, exist_ok=True)
            artifact.write_bytes(capsule(obj['packages'][0], [], files))
            check('restore ' + name, 'restore', folder / 'dew.lock', 'ok' if accepted else 'nonconventional', accepted)
            if accepted:
                check('restore integrity ' + name, 'integrity', folder / 'dep/dew.json', obj['packages'][0]['integrity'], True)
            elif (folder / 'dep').exists():
                failures.append('restore wrote before inventory validation ' + name)

        for name, dependencies, files, error in [
            ('bad source integrity', [], [('main.dew', b'wrong')], 'integrity'),
            ('unsafe dot path', [], [('./main.dew', b'x')], 'unsafe'),
            ('unsafe backslash path', [], [('src\\main.dew', b'x')], 'unsafe'),
            ('unsafe manifest prefix', [], [('dew.json/main.dew', b'x')], 'unsafe'),
        ]:
            folder = package()
            obj = lock(folder)
            _, result = run('artifact-path', folder / 'dew.lock')
            artifact = Path(result.stdout.strip())
            artifact.parent.mkdir(parents=True, exist_ok=True)
            artifact.write_bytes(capsule(obj['packages'][0], dependencies, files))
            check('restore ' + name, 'restore', folder / 'dew.lock', error)
            if (folder / 'dep').exists():
                failures.append('restore wrote before validation ' + name)

        # Local artifacts above the 64 MiB public cap still fit the 256 MiB codec.
        # Inspect the constant only here; near-limit I/O is a held workload.
        constant_source = (source / 'package_artifact.mbt').read_text()
        if 'BOOTSTRAP_PACKAGE_ARTIFACT_MAX_BYTES : Int32 = 268435456' not in constant_source:
            failures.append('local artifact limit changed')

        # Identity must be checked by store itself, even on a cache hit.
        folder = package()
        dep = folder / 'dep'
        dep.mkdir()
        (dep / 'dew.json').write_text('{"name":"@fixture/other","version":"1.0.0"}')
        (dep / 'main.dew').write_text('dependency')
        lock(folder)
        check('store identity', 'store', folder / 'dew.lock', 'identity')

    evidence['failures'] = failures
    evidence['exit'] = 1 if failures else 0
    (args.evidence / 'results.json').write_text(json.dumps(evidence, indent=2))
    print(f'{len(evidence["checks"])} checks; {len(failures)} failures')
    raise SystemExit(evidence['exit'])


if __name__ == '__main__':
    main()
