from pathlib import Path
import subprocess,os,shutil
r=Path('/tmp/wago-pr997-root-faults-20261022');e=Path('/tmp/wago-pr997-root-faults-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/powershell/7.5.4:/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)
corpus=r/'tests/conformance/spec-v3';assert not list(corpus.iterdir());corpus.rmdir()
subprocess.run(['git','clone','--shared','--no-checkout','/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago/tests/conformance/spec-v3',str(corpus)],check=True)
subprocess.run(['git','checkout','--detach','9d36019973201a19f9c9ebb0f10828b2fe2374aa'],cwd=corpus,check=True)
try:
 run('final-normal-wago',[e/'candidate-fast.test','-test.count=1'],r/'src/wago')
 run('final-checked-wago',[go,'test','-p','2','-count=1','-tags=wago_regalloccheck','./src/wago','./tests/integration/runtimeconcurrency'])
finally:
 shutil.rmtree(corpus);corpus.mkdir()

subprocess.run(['python3',str(e/'arm.py'),'arm64-fast-guards'],cwd=e,check=True)
subprocess.run(['python3',str(e/'rv.py'),'rv64-fast-guards'],cwd=e,check=True)
subprocess.run(['python3',str(e/'lint.py')],cwd=e,check=True)
