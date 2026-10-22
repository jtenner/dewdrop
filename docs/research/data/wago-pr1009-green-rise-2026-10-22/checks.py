from pathlib import Path
import os,subprocess
r=Path('/tmp/wago-pr1009-main-sync-20261022');e=Path('/tmp/wago-pr1009-green-rise-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',GOOS='linux',GOARCH='riscv64',GORISCV64='rva20u64',CGO_ENABLED='0')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
for name,tags in [('imported-start-default',''),('imported-start-checked','wago_regalloccheck')]:
 cmd=[go,'test','-p','1','-v','-count=10','-timeout=2m','-tags='+tags,'-exec',str(r/'scripts/qemu-riscv64.sh'),'./src/wago','-run','^TestRV64PublicReferenceFunctionImportedStartGo$']
 print('START',name,flush=True)
 subprocess.run(['python3',str(e/'measure.py'),name,*cmd],cwd=r,env=env,check=True)
