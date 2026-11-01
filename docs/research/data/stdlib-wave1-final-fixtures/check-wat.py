#!/usr/bin/env python3
"""Validate and run the four reviewed old/new modules without changing sources."""
import gzip,importlib.util,json,subprocess,sys,tempfile,time
from pathlib import Path
ROOT=Path.cwd();D=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('snapshots',ROOT/'tools/module-snapshots/run.py');runner=importlib.util.module_from_spec(spec);sys.modules[spec.name]=runner;spec.loader.exec_module(runner)
with tempfile.TemporaryDirectory(prefix='wave1-final-wat-',dir=ROOT/'_build') as tmp:
 scratch=Path(tmp);wago=scratch/'wago-runner';start=time.perf_counter();runner.build_wago_runner(wago);print('wago build seconds',round(time.perf_counter()-start,3),flush=True)
 for r in json.loads((D/'review.json').read_text()):
  source=ROOT/r['fixture'];expected=json.loads(source.with_suffix('.json').read_text());host=expected.get('host',{})
  for label,content in [('old',subprocess.check_output(['git','show','1caf8f48:'+r['fixture']])),('new',gzip.decompress((D/(source.stem+'.new.wat.gz')).read_bytes()))]:
   wat=scratch/(source.stem+'.'+label+'.wat');binary=wat.with_suffix('.wasm');wat.write_bytes(content);start=time.perf_counter()
   subprocess.run(['wasm-tools','parse',str(wat),'-o',str(binary)],check=True);subprocess.run(['wasm-tools','validate','--features','all',str(binary)],check=True)
   result={'fixture':r['fixture'],'version':label,'parse_validate_seconds':round(time.perf_counter()-start,3)}
   for runtime,execute in [('node',lambda:runner.run_main_node(binary,host,runner.fixture_mode(source.with_suffix('.dew')))),('wago',lambda:runner.run_main_wago(wago,binary,host,runner.fixture_mode(source.with_suffix('.dew'))))]:
    start=time.perf_counter();result[runtime]=execute();result[runtime+'_seconds']=round(time.perf_counter()-start,3);assert result[runtime]==expected['output'],result
   print(json.dumps(result),flush=True)
