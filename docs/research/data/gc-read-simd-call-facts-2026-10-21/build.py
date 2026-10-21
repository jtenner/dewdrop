from pathlib import Path
import shutil,subprocess,time,json
out=Path('/tmp/wago-four-seconds/simd');src=out/'source';host=out/'host-source';work=Path('/tmp/wago-gc-immutable-loop-homes')
if not src.exists():shutil.copytree('/tmp/wago-four-seconds/plain-source',src,symlinks=True)
files=subprocess.check_output(['git','diff','--name-only'],cwd=work,text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=work,text=True).splitlines()
for n in files:
 p=src/n;p.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(work/n,p)
if not host.exists():shutil.copytree('/tmp/wago-four-seconds/plain-host-source',host)
p=host/'go.mod';p.write_text(p.read_text().replace('/tmp/wago-four-seconds/plain-source',str(src)))
t=time.monotonic();r=subprocess.run(['go','build','-mod=mod','-ldflags=-X main.runtimePatchIdentity=simd-read-call-facts','-o',str(out/'host'),'.'],cwd=host);record={'elapsed':time.monotonic()-t,'exit':r.returncode};(out/'build.json').write_text(json.dumps(record,indent=2));print(record);r.check_returncode()
