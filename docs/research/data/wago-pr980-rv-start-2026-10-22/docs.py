from pathlib import Path
import os,subprocess
r=Path('/tmp/wago-pr980-rv-start-20261022');e=Path('/tmp/wago-pr980-rv-start-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',GOOS='linux',GOARCH='riscv64',GORISCV64='rva20u64',CGO_ENABLED='0')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
env.pop('GOOS',None);env.pop('GOARCH',None);env.pop('GORISCV64',None)
subprocess.run(['python3',str(e/'measure.py'),'docs-check',go,'run','./tests/tools/docs-check'],cwd=r,env=env,check=True)
