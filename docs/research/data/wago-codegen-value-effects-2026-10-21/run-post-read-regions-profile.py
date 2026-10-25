from pathlib import Path
import importlib.util,json,os,subprocess,threading,time,types,hashlib
r=Path('/home/dev/Projects/dewdrop');out=r/'.tmp/wago-next-gc-perf/post-read-regions-profile';dest=out/'profile';dest.mkdir(exist_ok=False)
def module(n,p):
 s=importlib.util.spec_from_file_location(n,p);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
m=module('measure',r/'docs/research/data/wago-local-perf-2026-10-20/measure.py');sampler=module('sampler',r/'docs/research/data/wago-profile-2026-10-20/native_sample.py');env=dict(m.ENV,GOMAXPROCS='2',WAGO_HOME=str(out/'profile-home'),DEW_TRANSFORM_WORKERS='0',DEW_COMPILER_FINGERPRINT=m.digest(r/'.tmp/self-host-bootstrap/b/compiler.wasm'),DEW_WAGO_PROFILE_DIR=str(dest),DEW_WAGO_NATIVE_MAP='1');cmd=['taskset','-c','12,14',out/'profile-host','run','-p8','--core','3','--local','--locked','--no-input','--gc-heap','512MiB','--gc-nursery','64MiB',m.COMPILER,(m.WORK/'request.bin').relative_to(r)]
for suffix in ['wasm','cache']:(m.WORK/('output.'+suffix)).unlink(missing_ok=True)
t=time.monotonic()
with (out/'sample.log').open('wb') as log:
 child=subprocess.Popen(list(map(str,cmd)),cwd=r,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
 def stop():
  import signal
  os.killpg(child.pid,signal.SIGKILL)
 timer=threading.Timer(600,stop);timer.start()
 try:status,usage,sampling=sampler.sample_child(child,dest)
 finally:timer.cancel()
code=os.waitstatus_to_exitcode(status);row=dict(command=list(map(str,cmd)),seconds=time.monotonic()-t,user_seconds=usage.ru_utime,system_seconds=usage.ru_stime,peak_rss_kib=usage.ru_maxrss,exit=code,compiler_sha256=m.digest(m.COMPILER),request_sha256=m.digest(m.WORK/'request.bin'),host_sha256=m.digest(out/'profile-host'),method='Diagnostic leaf-PC probes plus Go CPU profile; source/site maps only; no per-helper counters. Not a matched runtime benchmark.')
(out/'sample.json').write_text(json.dumps(row,indent=2)+'\n');(dest/'native-samples.json').write_text(json.dumps(sampling)+'\n');print(json.dumps(row),flush=True);assert not code,(out/'sample.log').read_text()[-6000:]
for suffix,want in [('wasm','89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb'),('cache','c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240')]:assert m.digest(m.WORK/('output.'+suffix))==want
subprocess.run(['wasm-tools','validate','--features','all',m.WORK/'output.wasm'],check=True);subprocess.run(['node','-e','WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();if(instance.exports.main()!==42)throw Error("wrong output")})',m.WORK/'output.wasm'],check=True)
original=r/'docs/research/data/wago-local-perf-2026-10-20/isolate_gc.py';s=original.read_text();a=s.index("    log=(DATA/'instruction-profile.log').read_text()");b=s.index('\n\ndef helpers():',a);s=s[:a]+"    print(json.dumps(report,indent=2)[:6000])\n"+s[b:];(out/'analyze.py').write_text(s);ns={'__file__':str(original),'__name__':'combined_profile_analysis'};exec(compile(s,str(original),'exec'),ns);ns['OUT']=dest;ns['DATA']=out;ns['analyze']()
for name,args in [('cpu-top',['-top','-nodecount=40']),('cpu-cumulative',['-top','-cum','-nodecount=60'])]:
 run=subprocess.run(['go','tool','pprof',*args,str(out/'profile-host'),str(dest/'cpu.pprof')],capture_output=True,text=True);(out/(name+'.log')).write_text(run.stdout+run.stderr);assert not run.returncode
print('Profile output validates/main42; native samples resolved and Go CPU reports saved.',flush=True)
