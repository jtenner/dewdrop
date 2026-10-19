#!/usr/bin/env python3
"""Check that the host adapter keeps function references and explicit traps."""
import importlib.util
from pathlib import Path
import subprocess
import tempfile

spec = importlib.util.spec_from_file_location('wago_adapter', Path(__file__).with_name('prepare-wago-compiler.py'))
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)

with tempfile.TemporaryDirectory(prefix='dewdrop-wago-adapter-') as temp:
    directory = Path(temp)
    for named in (False, True):
        source = '''(module
          (type (func (result i32)))
          (import "__moonbit_fs_unstable" "unused" (func NAMED (type 0)))
          (import "facet" "answer" (func (type 0)))
          (import "spectest" "print" (func (type 0)))
          (table 1 funcref)
          (elem (i32.const 0) func 1)
          (func (export "main") (result i32) call 1)
          (func (export "unused") (result i32) call CALLEE)
          (func (export "indirect") (result i32) i32.const 0 call_indirect (type 0))
        )'''.replace('NAMED', '$unused' if named else '').replace('CALLEE', '$unused' if named else '0')
        original = directory / 'original.wasm'
        output = directory / 'adapted.wasm'
        subprocess.run(['wasm-tools', 'parse', '-', '-o', str(original)], input=source, text=True, check=True)
        printed = subprocess.check_output(['wasm-tools', 'print', str(original)], text=True)
        converted = adapter.adapt(printed)
        subprocess.run(['wasm-tools', 'parse', '-', '-o', str(output)], input=converted, text=True, check=True)
        subprocess.run(['wasm-tools', 'validate', '--features', 'all', str(output)], check=True)
        subprocess.run(['node', '-e', '''
          WebAssembly.instantiate(require('fs').readFileSync(process.argv[1]), {facet:{answer:()=>42}}).then(({instance})=>{
            if(instance.exports.main()!==42 || instance.exports.indirect()!==42) throw Error('import target changed');
            let trapped=false;
            try {instance.exports.unused()} catch(error) {if(!(error instanceof WebAssembly.RuntimeError)) throw error; trapped=true;}
            if(!trapped) throw Error('unused import must trap');
          });''', str(output)], check=True)
print('Wago adapter: 2 cases passed')
