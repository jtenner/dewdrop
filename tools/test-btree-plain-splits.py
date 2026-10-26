#!/usr/bin/env python3
"""Step-4 plain splits: shared tests, raw/O4s constructors, slots and loop costs."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import platform
import re
import statistics
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
BASE = 'e102287f61dd75e70e18a5be34c2301e60a1726d'


def module(name, file):
    spec = importlib.util.spec_from_file_location(name, file)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def summary(samples):
    result = {}
    for name in dict.fromkeys(s['name'] for s in samples):
        values = [s['ns_per_operation'] for s in samples if s['name'] == name]
        result[name] = dict(samples=len(values), median_ns=statistics.median(values),
                            minimum_ns=min(values), maximum_ns=max(values))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('compiler', type=Path)
    parser.add_argument('generator', type=Path)
    parser.add_argument('starshine', type=Path)
    parser.add_argument('--output', type=Path)
    parser.add_argument('--correctness-only', action='store_true',
                        help='run tests and structural checks without cost or allocation measurements')
    parser.add_argument('--tests-only', action='store_true')
    parser.add_argument('--physical-only', action='store_true')
    args = parser.parse_args()
    output = (args.output or ROOT / '.tmp/btree-step-4' / ('correctness' if args.correctness_only else 'final')).resolve()
    output.mkdir(parents=True, exist_ok=True)
    records = []
    compiler, generator, starshine = [p.resolve() for p in (args.compiler, args.generator, args.starshine)]
    assemble = module('btree_assemble', ROOT / 'tools/dew-test/assemble.py')
    recorder = module('btree_record', ROOT / 'tools/btree-fit/record.py')
    fit = module('btree_fit', ROOT / 'tools/test-btree-plain-fit.py')

    def run(name, command, compiler_activity=False, expected_failure=None):
        command = [str(x) for x in command]
        start = time.monotonic()
        result = subprocess.run(command, cwd=ROOT, capture_output=True,
                                env=dict(os.environ, DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE='0'))
        seconds = time.monotonic() - start
        (output / (name + '.stdout')).write_bytes(result.stdout)
        (output / (name + '.stderr')).write_bytes(result.stderr)
        records.append(dict(name=name, command=command, seconds=seconds, exit=result.returncode,
                            compiler_activity=compiler_activity, over_30_seconds=seconds > 30,
                            expected_failure=expected_failure))
        (output / 'commands.json').write_text(json.dumps(records, indent=2)+'\n')
        print(f'{name}: exit {result.returncode}, {seconds:.3f} seconds', flush=True)
        if compiler_activity and seconds > 30:
            print('PERFORMANCE BUG: compiler activity exceeded 30 seconds; retain the raw command and logs', flush=True)
        if expected_failure is not None:
            diagnostic = (result.stdout + result.stderr).decode(errors='replace')
            if result.returncode == 0 or expected_failure not in diagnostic:
                raise AssertionError(f'{name}: missing expected failure {expected_failure!r}; see {output}')
        elif result.returncode:
            raise AssertionError(f'{name} failed; see {output}')
        return result.stdout.decode()

    sources = [ROOT / 'std/collections/btree.dew', ROOT / 'tools/btree-plans/providers.dew']
    sources += [ROOT / 'std/tests' / p for p in assemble.PRIVATE_BTREE_TESTS]
    paths = sources + [Path(__file__).resolve(), ROOT / 'tools/dew-test/assemble.py', ROOT / 'tools/test-btree-plain-fit.py']
    paths += sorted((ROOT / 'tools/btree-splits').glob('*')) + sorted((ROOT / 'tools/btree-fit').glob('*'))
    identity = dict(mode='correctness-only' if args.correctness_only else 'full',
        tests_only=args.tests_only, physical_only=args.physical_only,
        base=BASE, design='5922ea1a12ede3913f97b9b7bdac1f90343240f1',
        upstream='8adae97a0ed97e5c98fa2790312eb0aec9719846',
        source_head=subprocess.check_output(['git','rev-parse','HEAD'], cwd=ROOT, text=True).strip(),
        sources={str(p.relative_to(ROOT)): digest(p) for p in paths if p.is_file()},
        tools={str(p): digest(p) for p in (compiler,generator,starshine)},
        compiler_reuse='explicit binary paths and hashes; on-disk standard root; build provenance recorded separately',
        DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE='0',
        platform=platform.platform(), architecture=platform.machine(),
        cpu=Path('/proc/cpuinfo').read_text().split('model name',1)[-1].splitlines()[0].strip('\t :'),
        gc='Node default WasmGC; no custom flags; native execution; no emulation',
        node=run('node-version',['node','--version']).strip(),
        v8=run('v8-version',['node','-p','process.versions.v8']).strip(),
        moon=run('moon-version',['moon','version']).strip(),
        wasm_tools=run('wasm-tools-version',['wasm-tools','--version']).strip(),
        checkout_starshine_pin=run('checkout-starshine-pin',['git','-C','starshine-mb','rev-parse','HEAD']).strip(),
        optimizer_provenance='tools records the binary hash; the checkout pin alone does not establish binary build provenance')
    flags = json.loads((ROOT/'tools/starshine-experiments/pipelines.json').read_text())['pipelines']['O4s']
    assert flags == ['--optimize-level','4','--shrink-level','1','--optimize'], 'O4s changed'
    identity['O4s'] = flags
    (output/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    if not args.physical_only:
        command = [generator,output/'private.wasm','probe.split']
        for source in sources:
            command += ['probe.split',source.relative_to(ROOT),source]
        run('private-compile',command,True)
        run('private-raw',['node',ROOT/'tools/dew-test/run.mjs','--wasm',output/'private.wasm','--label','B-tree step-4 combined private tests'])
        run('private-O4s',[starshine,*flags,output/'private.wasm','-o',output/'private-O4s.wasm'],True)
        run('private-O4s-validate',['wasm-tools','validate',output/'private-O4s.wasm'],True)
        run('private-O4s-runtime',['node',ROOT/'tools/dew-test/run.mjs','--wasm',output/'private-O4s.wasm','--label','B-tree step-4 combined O4s private tests'])
        run('exact-diagnostics',['node',ROOT/'tools/btree-splits/diagnostics.mjs',output/'private.wasm',output/'diagnostics.json'])
        public = ROOT/'std/tests/btree_plans_providers_test.dew'
        run('public-compile',[generator,output/'public.wasm','probe.public','probe.public',public.relative_to(ROOT),public],True)
        run('public-runtime',['node',ROOT/'tools/dew-test/run.mjs','--wasm',output/'public.wasm','--label','B-tree public providers'])
    if not args.tests_only:
        physical = [ROOT/'std/collections/btree.dew', ROOT/'tools/btree-fit/physical.dew', ROOT/'tools/btree-fit/carriers.dew',
                    ROOT/'tools/btree-splits/physical.dew', ROOT/'tools/btree-splits/carriers.dew']
        run('physical-compile',[compiler,'build','--root','probe.fit','--module','probe.fit',*physical,'-o',output/'raw.wasm'],True)
        run('physical-O4s',[starshine,*flags,output/'raw.wasm','-o',output/'O4s.wasm'],True)
        for variant in ('raw','O4s'):
            binary = output/f'{variant}.wasm'
            run(variant+'-validate',['wasm-tools','validate',binary],True)
            wat = run(variant+'-print',['wasm-tools','print',binary],True)
            (output/f'{variant}.wat').write_text(wat)
            types = {int(i): body for i, body in re.findall(r"^  \(type \(;(\d+);\) (.*)$", wat, re.M)}
            functions = {int(m[1]): m[0] for m in re.finditer(r"^  \(func \(;(\d+);\).*?^  \)", wat, re.M | re.S)}
            exports = {name: int(i) for name, i in re.findall(r'\(export "([^"]+)" \(func (\d+)\)\)', wat)}
            unit_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports['unit_body']])[1])
            tree_type = int(re.search(r"\(result \(ref (\d+)\)\)", functions[exports['make_empty']])[1])
            assert types[unit_type].count('(field ') == 1, 'Unit body has only a key array'
            assert types[tree_type].count('(field ') == 10, 'map adds one lazy work reference; no plain prefix object'
            identity.setdefault('gc_shapes', {})[variant] = dict(unit_body=types[unit_type],plain_tree=types[tree_type])
            if variant == 'raw':
                assert 'call_ref' not in wat, 'source comparator/policy dispatch is direct'
            if args.correctness_only:
                inspected, _ = recorder.instrument(wat, allocations=False)
                (output/f'{variant}-inspect.wat').write_text(inspected)
                run(variant+'-inspect-build',['wasm-tools','parse',output/f'{variant}-inspect.wat','-o',output/f'{variant}-inspect.wasm'],True)
                run(variant+'-inspect-validate',['wasm-tools','validate',output/f'{variant}-inspect.wasm'],True)
                # The same module must expose both missed reference-work checks.
                # Only these temporary negative-control runner copies omit that check.
                runner = (ROOT/'tools/btree-splits/run.mjs').read_text()
                if runner.count('    checkWork(tree, kind);') != 1 or runner.count('for (const slot of [0, 16])') != 1:
                    raise AssertionError('negative-control source markers must each occur exactly once')
                for slot in (0, 16):
                    broken = runner.replace('    checkWork(tree, kind);',
                                            "    if (kind !== 'ref') checkWork(tree, kind);")
                    broken = broken.replace('for (const slot of [0, 16])', f'for (const slot of [{slot}])')
                    control = output/f'{variant}-missed-work-{slot}.mjs'
                    control.write_text(broken)
                    run(f'{variant}-missed-work-{slot}', ['node',control,output,variant,'correctness'],
                        expected_failure=f'retained reference work slot {slot}: missing diagnostic assertion')
                run(variant+'-split-correctness',['node',ROOT/'tools/btree-splits/run.mjs',output,variant,'correctness'])
                continue
            identity.setdefault('static_instructions',{})[variant] = {op:len(re.findall(rf'(?m)^\s*{re.escape(op)}(?: |$)',wat))
                for op in ('call','call_ref','return_call','array.get','array.copy','array.new_default','array.new_fixed','struct.new','loop','if','br_if','br_table')}
            inspected, sites = recorder.instrument(wat,instructions=True)
            (output/f'{variant}-inspect.wat').write_text(inspected)
            (output/f'{variant}-sites.json').write_text(json.dumps(sites,indent=2)+'\n')
            run(variant+'-instrument',['wasm-tools','parse',output/f'{variant}-inspect.wat','-o',output/f'{variant}-inspect.wasm'],True)
            run(variant+'-inspect-validate',['wasm-tools','validate',output/f'{variant}-inspect.wasm'],True)
            run(variant+'-split-allocation-and-slots',['node',ROOT/'tools/btree-splits/run.mjs',output,variant,'inspect'])
            # Keep every step-3 warm allocation and physical Unit check in force.
            run(variant+'-prior-allocation-checks',['node',ROOT/'tools/btree-fit/run.mjs',output,variant,'inspect'])
            run(variant+'-strip',['wasm-tools','strip',binary,'-o',output/f'{variant}-stripped.wasm'],True)
        if not args.correctness_only:
            # Matched root-leaf export sets for before/after runtime and code size.
            baseline = output/'base-btree.dew'
            baseline.write_bytes(subprocess.check_output(['git','show',BASE+':std/collections/btree.dew'],cwd=ROOT))
            identity['baseline_source_sha256'] = digest(baseline)
            for name, source in [('base',baseline),('fit',ROOT/'std/collections/btree.dew')]:
                run(name+'-compile',[compiler,'build','--root','probe.fit','--module','probe.fit',source,ROOT/'tools/btree-fit/physical.dew',ROOT/'tools/btree-fit/carriers.dew','-o',output/f'{name}-raw.wasm'],True)
                run(name+'-O4s',[starshine,*flags,output/f'{name}-raw.wasm','-o',output/f'{name}-O4s.wasm'],True)
                for variant in ('raw','O4s'):
                    run(f'{name}-{variant}-validate',['wasm-tools','validate',output/f'{name}-{variant}.wasm'],True)
                    run(f'{name}-{variant}-strip',['wasm-tools','strip',output/f'{name}-{variant}.wasm','-o',output/f'{name}-{variant}-stripped.wasm'],True)
                    wat = run(f'{name}-{variant}-print',['wasm-tools','print',output/f'{name}-{variant}.wasm'],True)
                    inspected, sites = recorder.instrument(wat,instructions=True)
                    (output/f'{name}-{variant}-inspect.wat').write_text(inspected)
                    (output/f'{name}-{variant}-sites.json').write_text(json.dumps(sites,indent=2)+'\n')
                    run(f'{name}-{variant}-instrument',['wasm-tools','parse',output/f'{name}-{variant}-inspect.wat','-o',output/f'{name}-{variant}-inspect.wasm'],True)
                    run(f'{name}-{variant}-inspect-validate',['wasm-tools','validate',output/f'{name}-{variant}-inspect.wasm'],True)
                    run(f'{name}-{variant}-instructions',['node',ROOT/'tools/btree-splits/control-instructions.mjs',output,f'{name}-{variant}'])
            # Each subprocess has its own engine/GC history; A/B launch order alternates.
            for process in range(4):
                controls = ['base-raw','fit-raw','base-O4s','fit-O4s']
                if process%2: controls.reverse()
                for variant in controls:
                    run(f'{variant}-cost-{process}',['node',ROOT/'tools/btree-fit/run.mjs',output,variant,'cost',process])
                variants = ['raw','O4s'] if process%2 == 0 else ['O4s','raw']
                for variant in variants:
                    run(f'{variant}-split-cost-{process}',['node',ROOT/'tools/btree-splits/run.mjs',output,variant,'cost',process])
            runtime = {}
            for variant in ('base-raw','fit-raw','base-O4s','fit-O4s'):
                samples = [s for i in range(4) for s in json.loads((output/f'{variant}-cost-{i}.json').read_text())['samples']]
                runtime[variant] = summary(samples)
            for variant in ('raw','O4s'):
                samples = [s for i in range(4) for s in json.loads((output/f'{variant}-split-cost-{i}.json').read_text())['samples']]
                runtime[variant] = summary(samples)
            (output/'runtime-summary.json').write_text(json.dumps(runtime,indent=2)+'\n')
    identity['modules'] = {p.name:dict(bytes=p.stat().st_size,code_section_bytes=fit.code_section_bytes(p),sha256=digest(p)) for p in sorted(output.glob('*.wasm'))}
    (output/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    print('B-tree correctness checks passed.' if args.correctness_only else
          'Step-4 selected checks passed. Heap bytes/GC and later tree stages are not established.')


if __name__ == '__main__':
    main()
