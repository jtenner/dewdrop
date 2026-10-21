from pathlib import Path
import subprocess,time,json,os
out=Path('/tmp/wago-four-seconds/simd');work=Path('/tmp/wago-gc-immutable-loop-homes');env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='2')
def run(label,args,cwd,extra={}):
 t=time.monotonic();r=subprocess.run(args,cwd=cwd,env=dict(env,**extra),capture_output=True,text=True);record={'seconds':time.monotonic()-t,'exit':r.returncode};(out/(label+'.log')).write_text(r.stdout+r.stderr);(out/(label+'.json')).write_text(json.dumps(record,indent=2));print(label,record,flush=True);r.check_returncode()
run('build',['python3',str(out/'build.py')],work)
run('admission-build',['go','test','-c','-tags','wago_codegenstats','-overlay',str(out/'admission/overlay.json'),'-o',str(out/'admission/candidate.test'),'./src/wago'],work)
run('admission-run',[str(out/'admission/candidate.test'),'-test.run=^TestRealSharedGetterStaticAdmission$','-test.count=1','-test.v'],work/'src/wago',{'WAGO_REAL_COMPILER_WASM':'/home/dev/Projects/dewdrop/.tmp/transform-workers/run-rvr6ozve/compiler.wasm','WAGO_REAL_COMPILER_STATS':str(out/'admission/candidate.json')})
r=json.loads((out/'admission/candidate.json').read_text());print({k:r[k] for k in ['compile_seconds','native_sha256','reused_resolutions','affected_functions','native_bytes','root_admission']})
