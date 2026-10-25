from pathlib import Path
import shutil,subprocess,time,os,json,hashlib,io,tarfile
r=Path('/home/dev/Projects/dewdrop');p=r/'.tmp/wago-next-gc-perf';base=r/'.tmp/wago-local-stack-2026-10-20/wago';out=p/'post-read-regions-profile';source=out/'source';host=out/'host-source';t=time.monotonic();out.mkdir(exist_ok=False)
commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=base,text=True).strip()
assert commit=='40cfab8d8ec32ca3eff1cd178fa746cb2eeb82b0'
source.mkdir()
archive=subprocess.check_output(['git','archive',commit],cwd=base)
with tarfile.open(fileobj=io.BytesIO(archive)) as tar:tar.extractall(source,filter='data')
subprocess.run(['git','init','-q',str(source)],check=True)
patch=r/'tools/wago-transform-host/patches/managed-isolated-fork.patch'
assert hashlib.sha256(patch.read_bytes()).hexdigest()=='3f016f6442cc891cf982b5edf6f4de9952e7cb03b634c5c40f5c4e7f8842ec87'
subprocess.run(['git','-C',str(source),'apply','--check',str(patch)],check=True)
subprocess.run(['git','-C',str(source),'apply',str(patch)],check=True)
host.mkdir();oldhost=r/'.tmp/wago-batch-cancel-full/host-source'
for f in oldhost.iterdir():
 if f.is_file() and (f.suffix=='.go' or f.name in ['go.mod','go.sum']):shutil.copyfile(f,host/f.name)
mod=host/'go.mod';oldbase=str(r/'.tmp/wago-batch-cancel-full/source');assert mod.read_text().count(oldbase)==1;mod.write_text(mod.read_text().replace(oldbase,str(source)))
diag=source/'diagnosticprofile';diag.mkdir();s=(r/'.tmp/wago-local-perf-2026-10-20/profile-source/diagnosticprofile/profile.go').read_text();s+='''
func SaveCodeMap(s *wago.CodeProfile) {images,_,status:=s.Snapshot();if status.Dropped!=0{panic("native profile metadata lost")};data,err:=json.Marshal(map[string]any{"images":images,"status":status});if err!=nil{panic(err)};if err=os.WriteFile(filepath.Join(os.Getenv("DEW_WAGO_PROFILE_DIR"),"code-map.json"),data,0600);err!=nil{panic(err)}}
''';(diag/'profile.go').write_text(s)
name='cli/runtime/commands/run/command.go';file=source/name;s=file.read_text()
def replace(old,new):
 global s
 assert s.count(old)==1,(old,s.count(old));s=s.replace(old,new)
replace('import (','import (\n"github.com/wago-org/wago/diagnosticprofile"\n"time"')
replace('config := selection.RuntimeConfig()','profileSession:=wago.NewCodeProfile(wago.CodeProfileOptions{SourceMaps:true,MaxBytes:512<<20})\n defer profileSession.Close()\n config := selection.RuntimeConfig().WithCodeProfile(profileSession)')
replace('module, err := loadModule(', 'loadStart := time.Now()\n module, err := loadModule(')
replace('var instance *wago.Instance','diagnosticprofile.Event("module_load",map[string]any{"seconds":time.Since(loadStart).Seconds()})\n var instance *wago.Instance')
replace('finish := func() error {','finish := func() error {\n diagnosticprofile.Snapshot(instance)\n defer diagnosticprofile.Finish()')
replace('instance, err = instantiate(', 'instantiateStart := time.Now()\n instance, err = instantiate(')
replace('for _, invocation := range invocations {','diagnosticprofile.Event("instantiate",map[string]any{"seconds":time.Since(instantiateStart).Seconds()})\n diagnosticprofile.SaveCodeMap(profileSession)\n for _, invocation := range invocations {\n invokeStart := time.Now()')
replace('result, err := instance.Invoke(invocation.export, invocation.values...)','result, err := instance.Invoke(invocation.export, invocation.values...)\n diagnosticprofile.Event("invoke",map[string]any{"seconds":time.Since(invokeStart).Seconds()})');file.write_text(s)
# Entry profile hook was in the old host main, not the CLI command.
for file in host.glob('*.go'):
 s=file.read_text()
 if 'func main() {' in s:
  s=s.replace('import (','import (\n "github.com/wago-org/wago/diagnosticprofile"',1);s=s.replace('func main() {','func main() {\n diagnosticprofile.Start()\n defer diagnosticprofile.Finish()',1);file.write_text(s)
subprocess.run(['gofmt','-w',str(diag/'profile.go'),str(source/name),*map(str,host.glob('*.go'))],check=True)
cmd=['go','build','-mod=mod','-tags=wago_profile','-ldflags=-X main.runtimePatchIdentity=post-read-regions-profile-40cfab8d8 -X main.workerPluginIdentity=post-read-regions-profile-40cfab8d8','-o',str(out/'profile-host'),'.'];start=time.monotonic();run=subprocess.run(cmd,cwd=host,env=dict(os.environ,CGO_ENABLED='0',GOWORK='off',GOFLAGS='-buildvcs=false',GOMAXPROCS='2'),capture_output=True,text=True);row=dict(command=cmd,build_seconds=time.monotonic()-start,total_prepare_seconds=time.monotonic()-t,exit=run.returncode,stdout=run.stdout,stderr=run.stderr,production_base=commit,diagnostics='Only CLI Go profiling and native source/site metadata; no collector/helper counters or runtime instruction changes. Never install.')
if not run.returncode:row['host_sha256']=hashlib.sha256((out/'profile-host').read_bytes()).hexdigest()
(out/'build.json').write_text(json.dumps(row,indent=2)+'\n');print(json.dumps(row),flush=True);assert not run.returncode,row
