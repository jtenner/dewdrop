from pathlib import Path
import subprocess,os,shutil
r=Path('/tmp/wago-pr997-main-sync-20261022');e=Path('/tmp/wago-pr997-main-sync-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/powershell/7.5.4:/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)
for arch,runner,pattern in [
 ('arm64','/usr/bin/qemu-aarch64','Test(GCExtern|GCNativeFrame|GCCollectFrameRoots)'),
 ('riscv64',str(r/'scripts/qemu-riscv64.sh'),'Test(GCNativeFrame|GCCollectFrameRoots|RV64PublicGCExtern)')]:
 env.update(GOOS='linux',GOARCH=arch,CGO_ENABLED='0')
 run(arch+'-gc-qemu',[go,'test','-p','1','-count=1','-timeout=3m','-exec',runner,'./src/wago','-run',pattern])
