from pathlib import Path
import os,subprocess
r=Path('/tmp/wago-pr997-main-sync-20261022');e=Path('/tmp/wago-pr997-rise-split-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
subprocess.run(['python3',str(e/'measure.py'),'docs-check',go,'run','./tests/tools/docs-check'],cwd=r,env=env,check=True)
