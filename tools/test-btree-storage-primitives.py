#!/usr/bin/env python3
"""Run step-1 storage probes with an existing native CLI and test generator."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import platform
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('compiler', type=Path)
    parser.add_argument('generator', type=Path)
    parser.add_argument('--output', type=Path, default=ROOT / '.tmp/btree-step-1/final')
    args = parser.parse_args()
    compiler, generator, output = args.compiler.resolve(), args.generator.resolve(), args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    samples = []

    def run(name, command, expected=0, diagnostic=None):
        command = [str(x) for x in command]
        start = time.monotonic()
        result = subprocess.run(command, cwd=ROOT, env=dict(os.environ, DEW_STD_ROOT=str(ROOT), DEW_PROGRAM_CACHE='0'), capture_output=True)
        elapsed = time.monotonic() - start
        (output / (name + '.stdout')).write_bytes(result.stdout)
        (output / (name + '.stderr')).write_bytes(result.stderr)
        samples.append(dict(name=name, command=command, seconds=elapsed, exit=result.returncode))
        (output / 'commands.json').write_text(json.dumps(samples, indent=2) + '\n')
        print(f'{name}: exit {result.returncode}, {elapsed:.3f} seconds', flush=True)
        if elapsed > 30:
            print('PERFORMANCE BUG: command exceeded 30 seconds', flush=True)
        if result.returncode != expected:
            raise AssertionError(f'{name}: expected exit {expected}; see {output}')
        if diagnostic and diagnostic not in (result.stdout + result.stderr).decode():
            raise AssertionError(f'{name}: missing diagnostic {diagnostic!r}')
        return result.stdout

    identity = dict(base='274ea5873deb4b239914ac76e89b6679ba34ac84', head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(), platform=platform.platform(), machine=platform.machine(), node=subprocess.check_output(['node','--version'],text=True).strip(), cpu=Path('/proc/cpuinfo').read_text().split('model name',1)[-1].splitlines()[0].strip('\t :'), gc='Node default WasmGC, no custom flags', emission='raw native release CLI, program cache off', compiler_sha256=hashlib.sha256(compiler.read_bytes()).hexdigest(), generator_sha256=hashlib.sha256(generator.read_bytes()).hexdigest())
    identity['source_sha256'] = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted((ROOT / 'tools/btree-storage').rglob('*')) if p.is_file() and p.suffix in {'.dew', '.mjs'}}
    identity['runner_sha256'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    identity['std_tests_sha256'] = hashlib.sha256((ROOT / 'std/tests/btree_storage_primitives_test.dew').read_bytes()).hexdigest()
    (output / 'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    prefix = [compiler, 'build', '--root', 'probe.main', '--module', 'probe.main']
    wasmtools = ['mise','exec','wasm-tools@1.262.0','--','wasm-tools']
    sources = ROOT / 'tools/btree-storage'
    texts = {}
    for name in ['carriers','representation','simd','opaque']:
        files = [sources / (name + '.dew')] if name != 'opaque' else [sources / 'consumer.dew','--module','probe.opaque',sources / 'opaque.dew']
        path = output / (name + '.wasm')
        run(name, prefix + files + ['-o', path])
        run(name + '-validate', wasmtools + ['validate',path])
        wat = run(name + '-print', wasmtools + ['print',path]).decode()
        (output / (name + '.wat')).write_text(wat)
        texts[name] = wat

    allocations = {}
    def funcs(wat):
        return {int(m.group(1)): m.group(0) for m in re.finditer(r'^  \(func \(;(\d+);\).*?^  \)',wat,re.M|re.S)}
    for name, wat in texts.items():
        bodies=funcs(wat)
        def reachable(index, seen=None):
            seen=set() if seen is None else seen
            if index in seen:
                return ''
            seen.add(index)
            body=bodies[index]
            return body + '\n' + '\n'.join(reachable(int(n),seen) for n in re.findall(r'^    call (\d+)$',body,re.M))
        for export,index in re.findall(r'\(export "([^"]+)" \(func (\d+)\)\)',wat):
            body=reachable(int(index))
            allocations[name+'.'+export]=dict(array_new_default=re.findall(r'array.new_default (\d+)',body),struct_new=re.findall(r'struct.new (\d+)',body),calls=re.findall(r'^    call (\d+)$',body,re.M))
        if name == 'simd':
            for opcode in ['i16x8.lt_u','i32x4.lt_u','i64x2.lt_s','v128.xor','i16x8.bitmask','i32x4.bitmask','i64x2.bitmask']:
                assert opcode in wat, opcode
            assert 'array.get' not in wat and 'struct.new' not in wat
        if name == 'opaque':
            assert 'ref.eq' in wat and 'call_ref' not in wat
    for name in ['i32_pair','i64_pair','u64_pair','f32_pair','f64_pair','v128_pair','string_pair','bool_pair','u8_pair','i16_pair','option_pair','nested_option_pair']:
        a=allocations['carriers.'+name]
        assert len(a['array_new_default']) == 1 and not a['struct_new'], (name,a)
    assert len(allocations['representation.unit_storage']['array_new_default']) == 1
    assert len(allocations['representation.value_storage']['array_new_default']) == 2
    for name in ['common_pair','mixed_pair','float_pair','vector_pair','bool_narrow_pair','signed_narrow_pair']:
        a=allocations['representation.'+name]
        assert len(a['array_new_default']) == 1 and not a['struct_new'], (name,a)
    for name in ['reference_columns', 'distinct_reference_columns']:
        a = allocations['representation.' + name]
        assert len(a['array_new_default']) == 2 and len(a['struct_new']) == 1, (name, a)
    (output/'allocations.json').write_text(json.dumps(allocations,indent=2)+'\n')

    helpers = '''
  (func (export "slot_i32") (param eqref i32) (result i32)
    local.get 0 ref.cast (ref 0) local.get 1 array.get 0)
  (func (export "slot_null") (param eqref i32) (result i32)
    local.get 0 ref.cast (ref 5) local.get 1 array.get 5 ref.is_null)
  (func (export "slot_same") (param eqref i32 i32) (result i32)
    local.get 0 ref.cast (ref 5) local.get 1 array.get 5
    local.get 0 ref.cast (ref 5) local.get 2 array.get 5 ref.eq)
  (func (export "block_low") (param eqref i32) (result i64)
    local.get 0 ref.cast (ref 4) local.get 1 array.get 4 i64x2.extract_lane 0)
  (func (export "block_high") (param eqref i32) (result i64)
    local.get 0 ref.cast (ref 4) local.get 1 array.get 4 i64x2.extract_lane 1)
'''
    for name in ['carriers','representation']:
        wat=texts[name]
        for index,type_ in [(0,'i32'),(4,'v128'),(5,'eqref')]:
            assert f'(type (;{index};) (array (mut {type_})))' in wat, 'inspector type changed'
        inspected=output/(name+'-inspect.wat')
        inspected.write_text(wat.rstrip()[:-1]+helpers+')\n')
        path=output/(name+'-inspect.wasm')
        run(name+'-inspect-assemble',wasmtools+['parse',inspected,'-o',path])
        run(name+'-inspect-validate',wasmtools+['validate',path])
    run('runtime', ['node',sources/'run.mjs',output])

    # These invalid consumer inputs must keep their diagnostics. The valid consumer
    # above proves that opaque values can cross the same module boundary.
    for name,body,diagnostic in [
        ('read','value.slots','UnknownFieldForType'),
        ('write','value.count = 0u32','UnknownFieldForType'),
        ('construct','Opaque::{\n    slots: wasm_array_new_default::<I64>(3u32)\n    count: 1u32\n  }','UnknownConstructionField'),
        ('pattern','match value {\n    Opaque {\n      count\n      ...\n    } => count\n  }','UnknownPatternField'),
    ]:
        source=output/('denied-'+name+'.dew')
        source.write_text('open probe.opaque\nopen dew.std.wasm.intrinsics\npub fn denied(value: Opaque<I64>) -> Unit {\n  '+body+'\n}\n')
        run('privacy-'+name,prefix+[source,'--module','probe.opaque',sources/'opaque.dew','-o',output/('denied-'+name+'.wasm')],expected=1,diagnostic=diagnostic)
    for name in ['f32','f64']:
        run('cast-limit-'+name,prefix+[sources/'cast-limits'/(name+'.dew'),'-o',output/(name+'.wasm')],expected=1,diagnostic='InvalidBuiltinSignature')
    testfile=ROOT/'std/tests/btree_storage_primitives_test.dew'
    run('std-generate',[generator,output/'tests.wasm','probe.tests','probe.tests',testfile.relative_to(ROOT),testfile])
    run('std-validate',wasmtools+['validate',output/'tests.wasm'])
    run('std-runtime',['node',ROOT/'tools/dew-test/run.mjs','--wasm',output/'tests.wasm','--label','B-tree storage primitives'])
    identity['modules']={p.name:dict(bytes=p.stat().st_size,sha256=hashlib.sha256(p.read_bytes()).hexdigest()) for p in output.glob('*.wasm')}
    (output/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    print('Storage primitive probes passed. No B-tree engine is implemented.')


if __name__ == '__main__':
    main()
