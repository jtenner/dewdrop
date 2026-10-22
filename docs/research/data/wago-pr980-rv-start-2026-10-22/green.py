from pathlib import Path
import os,subprocess
r=Path('/tmp/wago-pr980-rv-start-20261022');e=Path('/tmp/wago-pr980-rv-start-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',GOOS='linux',GOARCH='riscv64',GORISCV64='rva20u64',CGO_ENABLED='0')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
def run(label,regex,count,tags):
 cmd=[go,'test','-p','1','-v','-count='+str(count),'-timeout=2m','-tags='+tags,'-exec',str(r/'scripts/qemu-riscv64.sh'),'./src/wago','-run',regex]
 subprocess.run(['python3',str(e/'measure.py'),label,*cmd],cwd=r,env=env,check=True)
for label,tags in [('ordinary',''),('checked','wago_regalloccheck')]:
 run('shutdown-gated-'+label,'^TestRV64PublicNativeImportedStartStateReentryAndLifecycle$/^shared.*-runtime-close$',50,tags)
 run('imported-native-start-'+label,'^TestRV64PublicNativeImportedStart',3,tags)
