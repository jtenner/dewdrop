from pathlib import Path
import os,subprocess
r=Path('/tmp/wago-pr980-rv-start-20261022');e=Path('/tmp/wago-pr980-rv-start-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',GOOS='linux',GOARCH='riscv64',GORISCV64='rva20u64',CGO_ENABLED='0')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
cmd=[go,'test','-p','1','-v','-count=1','-timeout=2m','-tags=wago_regalloccheck','-exec',str(r/'scripts/qemu-riscv64.sh'),'./src/wago','-run','^TestRV64PublicNativeImportedStartStateReentryAndLifecycle$/^sharedtrue-artifactfalse-runtimetrue-runtime-close$']
p=subprocess.run(['python3',str(e/'measure.py'),'shutdown-gated-red',*cmd],cwd=r,env=env)
assert p.returncode==1,p.returncode
