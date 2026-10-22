from pathlib import Path
import os,shutil,subprocess,json,hashlib
repo=Path('/tmp/wago-gc-deferred-20261022');root=Path('/tmp/wago-gc-deferred-evidence');baseline=Path('/tmp/wago-four-seconds/simd/source')
def replace_bytes(path,data):
 path.parent.mkdir(parents=True,exist_ok=True)
 if path.exists() or path.is_symlink():path.unlink()
 path.write_bytes(data)
for name in ['control','compact']:
 target=root/(name+'-source')
 assert not target.exists(),target
 shutil.copytree(baseline,target,copy_function=os.link,symlinks=True)
 for n in ['go.mod','go.sum']:replace_bytes(target/n,(baseline/n).read_bytes())
 for n in ['src/core/compiler/backend/railshot/amd64/gc_read_call_facts.go','src/core/compiler/backend/railshot/amd64/gc_read_call_facts_test.go','src/core/compiler/backend/railshot/amd64/gc_read_region.go']:
  replace_bytes(target/n,subprocess.check_output(['git','show','9d84600f1:'+n],cwd=repo))
 if name=='compact':
  files=subprocess.check_output(['git','diff','--name-only','9d84600f1'],cwd=repo,text=True).splitlines()+subprocess.check_output(['git','ls-files','--others','--exclude-standard'],cwd=repo,text=True).splitlines()
  for n in set(files):
   p=repo/n
   if p.is_file():replace_bytes(target/n,p.read_bytes())
   elif (target/n).exists():(target/n).unlink()
 host=root/(name+'-host-source');shutil.copytree('/tmp/wago-four-seconds/simd/host-source',host)
 mod=host/'go.mod';mod.write_text(mod.read_text().replace('/tmp/wago-four-seconds/simd/source',str(target)))
 print(name,target,flush=True)
