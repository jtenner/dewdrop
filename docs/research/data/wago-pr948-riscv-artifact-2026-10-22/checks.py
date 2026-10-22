from pathlib import Path
import subprocess,os,shutil
r=Path('/tmp/wago-pr948-main-sync-20261022');e=Path('/tmp/wago-pr948-riscv-artifact-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/powershell/7.5.4:/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)
env.update(GOOS='linux',GOARCH='riscv64',GORISCV64='rva20u64',CGO_ENABLED='0')
env['WAGO_RV64_TABLE_STAGE_ARTIFACT_DIR']=str(e/'table-fixtures')
env['WAGO_RV64_TABLE_STAGE_ARTIFACT_MODE']='prepare'
run('source-dispatcher-and-cached-starts',[go,'test','-p','1','-v','-count=2','-timeout=2m','-tags=wago_regalloccheck','-exec',str(r/'scripts/qemu-riscv64.sh'),'./src/wago','-run','Test(RV64ManagedDispatcherBuiltinMatchesSource|RV64ManagedVoidTableHostAndRetiredProducer|CachedStartFunctions|CompiledCodecVersion7Contract)$'])
env['WAGO_RV64_TABLE_STAGE_ARTIFACT_MODE']='load'
run('precompiled-managed-dispatch',[go,'test','-p','1','-v','-count=2','-timeout=2m','-tags=wago_precompiled,wago_regalloccheck','-exec',str(r/'scripts/qemu-riscv64.sh'),'./src/wago','-run','^TestRV64ManagedVoidTableHostAndRetiredProducer$'])
