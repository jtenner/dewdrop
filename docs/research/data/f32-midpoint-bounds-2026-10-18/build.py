from pathlib import Path
import subprocess,time,os,json,sys,hashlib
root=Path(sys.argv[1]);root.mkdir(parents=True,exist_ok=True)
fixture=Path(__file__).with_name('scaling.dew')
(root/'tokenizer-before.dew').write_bytes(subprocess.check_output(['git','show','6a881286bc3f3a99e3f02b08224f313eada894d7:self_host/compiler/tokenizer.dew']))
env=dict(os.environ,DEW_STD_ROOT=str(Path.cwd()))
for identity,tokenizer in [('before',root/'tokenizer-before.dew'),('after',Path('self_host/compiler/tokenizer.dew'))]:
 command=['_build/native/release/build/jtenner/dewdrop/dew_test_gen/dew_test_gen.exe',str(root/(identity+'.wasm')),'self_host.compiler']
 for name,path in [('compiler_value_primitives.dew',Path('self_host/compiler/compiler_value_primitives.dew')),('tokenizer.dew',tokenizer),('tokenizer_f32_decimal_test.dew',Path('self_host/compiler/tokenizer_f32_decimal_test.dew')),('tokenizer_f32_bounded_test.dew',Path('self_host/compiler/tokenizer_f32_bounded_test.dew')),('scaling.dew',fixture)]:
  command+=['self_host.compiler',name,str(path)]
 start=time.monotonic();r=subprocess.run(command,env=env,text=True,capture_output=True,timeout=25)
 (root/(identity+'-generate.log')).write_text(r.stdout+r.stderr)
 print(identity,round(time.monotonic()-start,3),r.returncode,r.stdout[-500:],r.stderr[-500:])
 if r.returncode:raise SystemExit(r.returncode)
