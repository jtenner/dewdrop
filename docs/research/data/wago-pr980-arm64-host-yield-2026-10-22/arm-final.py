from pathlib import Path
import subprocess,os,shutil
r=Path('/tmp/wago-pr980-ci-fix');e=Path('/tmp/wago-pr980-retry-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/powershell/7.5.4:/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)
env.update(GOOS='linux',GOARCH='arm64',CGO_ENABLED='0',GODEBUG='asyncpreemptoff=1')
run('arm64-runtime-focused-checked',[go,'test','-p','1','-count=10','-tags=wago_regalloccheck,wago_inline_host_experiment','-exec','/usr/bin/qemu-aarch64','./src/core/runtime','-run','Test(InlineHostBridge|InlineBoundedBridge|LiveBounded|BoundedHelper)'])
run('arm64-yield-array-stats-final',[go,'test','-p','1','-count=10','-timeout=2m','-tags=wago_regalloccheck,wago_codegenstats','-exec','/usr/bin/qemu-aarch64','./src/wago','-run','Test(BoundedHostYield|BoundedCallerHost|GCGeneralArrayLen)'])
env['GOOS']='darwin'
env.pop('GODEBUG',None)
run('darwin-arm64-runtime-build',[go,'test','-c','-p','1','-o',str(e/'runtime-darwin-arm64.test'),'./src/core/runtime'])
run('darwin-arm64-wago-build',[go,'test','-c','-p','1','-tags=wago_codegenstats,wago_regalloccheck','-o',str(e/'wago-darwin-arm64.test'),'./src/wago'])
