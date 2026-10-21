from pathlib import Path
import subprocess,time,json,os
root=Path('/tmp/wago-gc-loop-keyed-value-homes');out=Path('/tmp/wago-four-seconds/loop-keyed');env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
corpus=root/'tests/conformance/spec-v3';assert corpus.is_dir() and not corpus.is_symlink();corpus.rmdir();corpus.symlink_to('/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago/tests/conformance/spec-v3',target_is_directory=True)
try:
 for name,tags,packages,extra in [('normal',None,['./src/core/compiler/backend/railshot/amd64','./src/core/runtime/gc/native','./src/core/runtime','./src/wago'],[]),('checked','wago_regalloccheck',['./src/core/compiler/backend/railshot/amd64','./src/core/runtime/gc/native','./src/core/runtime','./src/wago'],[]),('focused-stats','wago_codegenstats',['./src/core/compiler/backend/railshot/amd64','./src/wago'],['-run','TestGC(Read(Call|Load|SIMD)|LoopValue)'])]:
  args=['go','test']+(['-tags',tags] if tags else [])+packages+extra+['-count=1','-timeout=90s'];t=time.monotonic();r=subprocess.run(args,cwd=root,env=env,capture_output=True,text=True);record={'command':args,'seconds':time.monotonic()-t,'exit':r.returncode};(out/(name+'.log')).write_text(r.stdout+r.stderr);(out/(name+'.json')).write_text(json.dumps(record,indent=2));print(name,record,flush=True);print(r.stdout[-1300:],flush=True);r.check_returncode()
finally:
 corpus.unlink();corpus.mkdir()
