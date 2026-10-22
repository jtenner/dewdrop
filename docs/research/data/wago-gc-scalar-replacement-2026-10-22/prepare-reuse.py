"""Prepare the final private candidate after prepare.py; never install it."""
from pathlib import Path
import hashlib,json,os,shutil,subprocess,time
repo=Path('/tmp/wago-gc-scalar-replacement-20261022')
ev=Path('/tmp/wago-gc-scalar-evidence')
source=ev/'reuse-source';host=ev/'reuse-host-source'
assert not source.exists() and not host.exists()
shutil.copytree(ev/'control-source',source,copy_function=os.link,ignore=shutil.ignore_patterns('.git'))
for name in ['go.mod','go.sum','src/core/runtime/gc/native/promotion_sort.go','src/core/runtime/gc/native/promotion_sort_test.go']:
 target=source/name
 data=(repo/name).read_bytes() if name.endswith('.go') else target.read_bytes()
 target.unlink();target.write_bytes(data)
shutil.copytree(ev/'control-host-source',host)
p=host/'go.mod';p.write_text(p.read_text().replace(str(ev/'control-source'),str(source)))
cmd=['go','build','-mod=mod','-ldflags=-X=main.runtimePatchIdentity=gc-sort-reuse','-o',str(ev/'reuse-host'),'.']
start=time.monotonic()
p=subprocess.run(cmd,cwd=host,env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',CGO_ENABLED='0',GOWORK='off'),capture_output=True,text=True)
record=dict(command=cmd,seconds=time.monotonic()-start,exit=p.returncode,stdout=p.stdout,stderr=p.stderr)
if p.returncode==0:record['sha256']=hashlib.sha256((ev/'reuse-host').read_bytes()).hexdigest()
(ev/'reuse-build.json').write_text(json.dumps(record,indent=2)+'\n')
print(json.dumps(record));assert p.returncode==0
