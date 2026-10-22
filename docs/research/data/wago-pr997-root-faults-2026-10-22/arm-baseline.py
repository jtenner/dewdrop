from pathlib import Path
import os,subprocess,sys
r=Path('/tmp/wago-pr997-root-faults-20261022');e=Path('/tmp/wago-pr997-root-faults-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2')
env.pop('GOWORK',None)
env.update(GOOS='linux',GOARCH='arm64',CGO_ENABLED='0')
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:'+env['PATH']

r=Path('/tmp/wago-pr997-main-sync-20261022')
p=subprocess.run(['python3',str(e/'measure.py'),'arm64-threads-baseline',go,'test','-p','1','-v','-count=1','-timeout=1m','-tags=wago_regalloccheck','-exec','/usr/bin/qemu-aarch64','./tests/integration/runtimeconcurrency','-run','^TestRuntimeConcurrencyHarness$/^seed-439000001$/^threads-shared-memory-wait-close$'],cwd=r,env=env)
sys.exit(p.returncode)
