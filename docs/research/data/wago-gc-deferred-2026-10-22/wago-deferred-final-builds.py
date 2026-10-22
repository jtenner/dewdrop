from pathlib import Path
import os,subprocess,json,hashlib
r=Path('/tmp/wago-gc-deferred-20261022');e=Path('/tmp/wago-gc-deferred-evidence')
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='2',CGO_ENABLED='0')
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3','/tmp/wago-deferred-run.py',label,*map(str,args)],cwd=cwd,env=env,check=True)
run('gc-final-workers-core',['go','test','-count=1','-tags','wago_gc_workers wagodebug','./src/core/runtime/gc/native'])
run('gc-final-guard-core',['go','test','-count=1','-tags','wago_guardpage','./src/core/runtime/gc/native','./internal/virtualmem'])
run('gc-final-guard-wago',['go','test','-count=1','-tags','wago_guardpage','-run','^TestGC','./src/wago'])
for name,tags in [('final',''),('workers','wago_gc_workers'),('concurrent','wago_gc_workers wago_gc_concurrent')]:
 args=['go','build','-mod=mod']
 if tags:args+=['-tags',tags]
 args+=['-ldflags=-X=main.runtimePatchIdentity=deferred-final-'+name,'-o',e/(name+'-host'),'.']
 run('gc-final-host-build-'+name,args,e/'final-host-source')
record={name:{'bytes':(e/(name+'-host')).stat().st_size,'sha256':hashlib.sha256((e/(name+'-host')).read_bytes()).hexdigest()} for name in ['control','final','workers','concurrent']}
(e/'linked-host-sizes.json').write_text(json.dumps(record,indent=2)+'\n');print(json.dumps(record),flush=True)
