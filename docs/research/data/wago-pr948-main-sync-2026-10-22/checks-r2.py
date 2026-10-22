from pathlib import Path
import subprocess,os
r=Path('/tmp/wago-pr948-main-sync-20261022');e=Path('/tmp/wago-pr948-main-sync-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)
corpus=r/'tests/conformance/spec-v3';assert not list(corpus.iterdir());corpus.rmdir();corpus.symlink_to('/home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago/tests/conformance/spec-v3',target_is_directory=True)
try:
 run('normal-root-r2',[go,'test','-p','2','-count=1','./...'])
 run('checked-root',[go,'test','-p','2','-count=1','-tags=wago_regalloccheck','./...'])
 run('checked-bench',[go,'test','-p','2','-count=1','-tags=wago_regalloccheck','./...'],r/'bench')
finally:
 corpus.unlink();corpus.mkdir()
