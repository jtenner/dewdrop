from pathlib import Path
import json,subprocess,os,time,hashlib,shutil
root=Path('/home/dev/Projects/dewdrop');tree=root/'.tmp/wago-shared-getter';out=root/'.tmp/wago-next-gc-perf/shared-getter-v2';backend=tree/'src/core/compiler/backend/railshot/amd64';base='073b2f61880e965d3c33ba83e32f72e9391a845d'
repl={}
for name in ['call.go','compile.go','gc_shared_getter.go']:
 target=backend/name;copy=out/(name+'.base.txt')
 content=b'//go:build amd64\n\npackage amd64\n' if name=='gc_shared_getter.go' else subprocess.check_output(['git','show',base+':src/core/compiler/backend/railshot/amd64/'+name],cwd=tree)
 copy.write_bytes(content);repl[str(target)]=str(copy)
overlay=out/'control-overlay.json';overlay.write_text(json.dumps({'Replace':repl},indent=2));env=dict(os.environ,CGO_ENABLED='0',GOMAXPROCS='2');rows=[]
for name in ['control','candidate']:
 cmd=['go','test','-p','2','-c','-o',str(out/(name+'.test'))]
 if name=='control':cmd+=['-overlay',str(overlay)]
 cmd+=['./src/wago'];t=time.monotonic();r=subprocess.run(cmd,cwd=tree,env=env,capture_output=True,text=True);row=dict(variant=name,command=cmd,seconds=time.monotonic()-t,exit=r.returncode,stdout=r.stdout,stderr=r.stderr);rows.append(row);assert not r.returncode,row;row['sha256']=hashlib.sha256((out/(name+'.test')).read_bytes()).hexdigest();(out/'build-micro.json').write_text(json.dumps(rows,indent=2));print('micro build',name,row['seconds'],flush=True)
admission=out/'admission';admission.mkdir(exist_ok=False);old=root/'.tmp/wago-next-gc-perf/test-field-prefix/admission'
for name in ['prepare.py','capture_test.go.txt']:
 s=(old/name).read_text().replace('TestFieldPrefix','SharedGetter').replace('test_field_prefix','shared_getter').replace('gc-test-field-prefix-read','gc-shared-getter-inline')
 (admission/name).write_text(s)
subprocess.run(['python3',str(admission/'prepare.py'),str(tree)],check=True);candidate=json.loads((admission/'overlay.json').read_text())['Replace'];(admission/'control-overlay.json').write_text(json.dumps({'Replace':{**repl,**candidate}},indent=2))
rows=[]
for name in ['control','candidate']:
 which=admission/('control-overlay.json' if name=='control' else 'overlay.json');cmd=['go','test','-p','2','-tags=wago_codegenstats,wago_regalloccheck','-overlay',str(which),'-run','^TestRealSharedGetterStaticAdmission$','-count=1','-v','./src/wago'];t=time.monotonic();r=subprocess.run(cmd,cwd=tree,env=dict(env,WAGO_REAL_COMPILER_WASM=str(root/'.tmp/transform-workers/run-rvr6ozve/compiler.wasm'),WAGO_REAL_COMPILER_STATS=str(admission/(name+'.json')),WAGO_ALLOW_ZERO_FUSIONS='1' if name=='control' else '0'),capture_output=True,text=True);row=dict(variant=name,command=cmd,seconds=time.monotonic()-t,exit=r.returncode,stdout=r.stdout,stderr=r.stderr);rows.append(row);(admission/'run.json').write_text(json.dumps(rows,indent=2));print(json.dumps(row),flush=True);assert not r.returncode
