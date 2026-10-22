from pathlib import Path
import os,shutil,subprocess,json,hashlib
repo=Path('/tmp/wago-gc-deferred-20261022');ev=Path('/tmp/wago-gc-deferred-evidence');base='9d84600f1'
target=ev/'final-source'
if target.exists(): shutil.rmtree(target)
shutil.copytree(ev/'control-source',target,copy_function=os.link,symlinks=True,ignore=shutil.ignore_patterns('.git'))
patch=subprocess.check_output(['git','diff','--binary',base,'HEAD'],cwd=repo)
(ev/'deferred-combined.patch').write_bytes(patch)
files=subprocess.check_output(['git','diff','--name-only',base,'HEAD'],cwd=repo,text=True).splitlines()
for name in files:
 p=target/name
 if not p.exists():
  old=subprocess.run(['git','show',base+':'+name],cwd=repo,stdout=subprocess.PIPE,stderr=subprocess.DEVNULL)
  if old.returncode==0:
   p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(old.stdout)
 if p.is_file() and not p.is_symlink():
  data=p.read_bytes();p.unlink();p.write_bytes(data)
subprocess.run(['git','init','-q',str(target)],check=True)
subprocess.run(['git','apply','--check',str(ev/'deferred-combined.patch')],cwd=target,check=True)
subprocess.run(['git','apply',str(ev/'deferred-combined.patch')],cwd=target,check=True)
# Ensure all changed production sources match the committed implementation,
# except reference_store.go which intentionally retains the frozen managed fork.
for name in files:
 p=repo/name;q=target/name
 if p.is_file() and name!='src/wago/reference_store.go':assert q.read_bytes()==p.read_bytes(),name
host=ev/'final-host-source';shutil.copytree(ev/'control-host-source',host)
p=host/'go.mod';p.write_text(p.read_text().replace(str(ev/'control-source'),str(target)))
identity={'base':subprocess.check_output(['git','rev-parse',base],cwd=repo,text=True).strip(),'candidate':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),'private_fork_files':['src/wago/managed_instances.go','src/wago/reference_store.go','src/wago/runtime.go'],'combined_patch_sha256':hashlib.sha256(patch).hexdigest(),'candidate_source':str(target),'host_source':str(host),'note':'Frozen matched host; current Dewdrop Facet host is not replaced.'}
for label,path in [('host',host),('source',target)]:
 manifest={str(p.relative_to(path)):hashlib.sha256(p.read_bytes()).hexdigest() for p in sorted(path.rglob('*')) if p.is_file() and '.git' not in p.parts and (p.suffix=='.go' or p.name in ['go.mod','go.sum'])}
 (ev/(label+'-final-manifest.json')).write_text(json.dumps(manifest,indent=2)+'\n')
(ev/'qualification-identity.json').write_text(json.dumps(identity,indent=2)+'\n')
print(json.dumps(identity))
