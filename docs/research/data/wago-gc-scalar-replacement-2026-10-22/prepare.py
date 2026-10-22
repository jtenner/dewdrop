from pathlib import Path
import shutil,subprocess,time,os,json,hashlib
project=Path('/home/dev/Projects/dewdrop'); out=Path('/tmp/wago-gc-scalar-evidence'); out.mkdir(exist_ok=False)
frozen=Path('/tmp/wago-gc-deferred-evidence')
for name in ['control','candidate','profile']:
 source=out/(name+'-source'); host=out/(name+'-host-source')
 shutil.copytree(frozen/'final-source',source,ignore=shutil.ignore_patterns('.git'))
 shutil.copytree(frozen/'final-host-source',host)
 p=host/'go.mod'; p.write_text(p.read_text().replace(str(frozen/'final-source'),str(source)))
# Adapt the existing diagnostic-only profiler to this exact frozen source.
template=(project/'docs/research/data/wago-codegen-value-effects-2026-10-21/prepare-post-read-regions-profile.py').read_text()
start=template.index("diag=source/'diagnosticprofile'")
body=template[start:]
body=body.replace("'post-read-regions-profile-40cfab8d8'","'scalar-baseline-7f748b9ed'")
body=body.replace('post-read-regions-profile-40cfab8d8','scalar-baseline-7f748b9ed')
body=body.replace("production_base=commit","production_base='7f748b9ed0cb2822a69af4913871ccb0a1aa193f'")
body=body.replace("GOMAXPROCS='2'","GOMAXPROCS='2',GOCACHE='/tmp/wago-pr980-go-cache'")
r=project; source=out/'profile-source';host=out/'profile-host-source'; t=time.monotonic()
exec(compile(body,'diagnostic-prepare','exec'))
