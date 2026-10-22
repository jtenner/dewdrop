from pathlib import Path
import shutil,subprocess,json,hashlib,os
r=Path('/tmp/wago-gc-deferred-20261022');e=Path('/tmp/wago-gc-deferred-evidence');p=Path('/home/dev/Projects/dewdrop');d=p/'docs/research/data/wago-gc-deferred-2026-10-22'
d.mkdir(parents=True,exist_ok=True)
for source in list(e.glob('*.json'))+list(e.glob('*.log'))+list((e/'measurements').glob('*.json'))+list((e/'measurements').glob('*.log')):
 if source.stat().st_size<2<<20:shutil.copyfile(source,d/source.name)
for name in ['deferred-gc-implementation-2026-10-22.md','concurrent-marking-design-2026-10-22.md']:
 shutil.copyfile(r/'docs/research'/name,d/name)
for f in ['/tmp/wago-deferred-run.py','/tmp/wago-deferred-final-matrix.py','/tmp/wago-deferred-final-matrix-r2.py','/tmp/wago-deferred-final-source.py','/tmp/wago-deferred-final-builds.py','/tmp/wago-deferred-final-measure.py','/tmp/wago-deferred-prepare-hosts.py']:
 shutil.copyfile(f,d/Path(f).name)
patches=d/'patches';patches.mkdir(exist_ok=True)
subprocess.run(['git','format-patch','--no-signature','--zero-commit','-o',str(patches),'9d84600f1..HEAD'],cwd=r,check=True,stdout=subprocess.DEVNULL)
identity={'base':subprocess.check_output(['git','rev-parse','9d84600f1'],cwd=r,text=True).strip(),'head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=r,text=True).strip(),'branch':'dewdrop/gc-deferred-20261022','worktree':str(r),'patches':[{'name':f.name,'sha256':hashlib.sha256(f.read_bytes()).hexdigest()} for f in sorted(patches.glob('*.patch'))],'arm64_user_file_sha256':hashlib.sha256((p/'.tmp/wago-local-stack-2026-10-20/wago/src/core/compiler/backend/railshot/arm64/call.go').read_bytes()).hexdigest()}
(d/'series.json').write_text(json.dumps(identity,indent=2)+'\n')
print('Saved',len(identity['patches']),'patches and bounded text evidence to',d)
