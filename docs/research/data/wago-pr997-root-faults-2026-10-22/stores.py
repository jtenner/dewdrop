from pathlib import Path
import os,subprocess,sys
r=Path('/tmp/wago-pr997-root-faults-20261022');e=Path('/tmp/wago-pr997-root-faults-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/go/1.27.1/bin:'+env['PATH']
label=sys.argv[1]
p=subprocess.run(['python3',str(e/'measure.py'),label,go,'test','-p','1','-v','-count=1','-timeout=2m','-tags=wago_regalloccheck','./src/wago','-run','^TestGCScalarAdapterRevisitedDomainAcrossStores$'],cwd=r,env=env)
sys.exit(p.returncode)
