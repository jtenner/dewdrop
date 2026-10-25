from pathlib import Path
import hashlib,json,os,platform,subprocess,sys,threading,time
root=Path.cwd();work=root/'.tmp/wago-profile-2026-10-20'
label,mode=sys.argv[1:]
host=work/'host-profile'
home=Path(os.environ.get('WAGO_PROFILE_HOME_OVERRIDE',str(work/'profile-home')))
if mode=='baseline':
    host=root/'.tmp/transforms-v5/worker-host-start/host'
    home=root/'.tmp/transform-workers/run-rvr6ozve/serial-home'
compiler=root/'.tmp/transform-workers/run-rvr6ozve/compiler.wasm'
profile=work/label;profile.mkdir()
command=[str(host),'run','-p8','--core','3','--local','--locked','--no-input','--gc-heap','512MiB','--gc-nursery','64MiB',str(compiler),'.tmp/wago-profile-2026-10-20/request.bin']
env=dict(os.environ,WAGO_HOME=str(home),DEW_TRANSFORM_WORKERS='2' if mode=='parallel' else '0',DEW_COMPILER_FINGERPRINT=hashlib.sha256((root/'.tmp/self-host-bootstrap/b/compiler.wasm').read_bytes()).hexdigest())
if mode.startswith('node'):
    import shutil
    host=Path(shutil.which('node'));compiler=work/'compiler-node.wasm'
    command=[str(host),'--stack-size=65500']
    if mode=='node-profile':command+=['--cpu-prof','--cpu-prof-dir='+str(profile)]
    command+=['tools/run-dew-facet.mjs',str(compiler),'.tmp/wago-profile-2026-10-20/request.bin']

if mode!='baseline':env.update(DEW_WAGO_DIAG='1',DEW_WAGO_PROFILE_DIR=str(profile))
if mode.startswith('stats'):env['DEW_WAGO_GCSTATS']='1';host=work/'host-stats';command[0]=str(host)
if os.environ.get('WAGO_PROFILE_HOST_OVERRIDE'):
    host=Path(os.environ['WAGO_PROFILE_HOST_OVERRIDE']).resolve();command[0]=str(host)
output=work/'output.wasm';cache=work/'output.cache'
for path in (output,cache):path.unlink(missing_ok=True)
started=time.monotonic()
with (profile/'run.log').open('wb') as log:
    child=subprocess.Popen(command,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT)
    timer=threading.Timer(300,child.kill);timer.start()
    if os.environ.get('WAGO_NATIVE_SAMPLE')=='1':
        from native_sample import sample_child
        status,usage,sampling=sample_child(child,profile)
        (profile/'native-samples.json').write_text(json.dumps(sampling)+'\n')
    else:_,status,usage=os.wait4(child.pid,0)
    child.returncode=os.waitstatus_to_exitcode(status);timer.cancel()
sample={'label':label,'mode':mode,'seconds':time.monotonic()-started,'user_seconds':usage.ru_utime,'system_seconds':usage.ru_stime,'rss_kib':usage.ru_maxrss,'exit':child.returncode,'command':command,'host_sha256':hashlib.sha256(host.read_bytes()).hexdigest(),'compiler_sha256':hashlib.sha256(compiler.read_bytes()).hexdigest(),'request_sha256':hashlib.sha256((work/'request.bin').read_bytes()).hexdigest(),'environment':{k:env[k] for k in ('WAGO_HOME','DEW_TRANSFORM_WORKERS','DEW_COMPILER_FINGERPRINT')},'platform':platform.platform(),'loadavg':os.getloadavg()}
if child.returncode==0:
    for path in (output,cache):sample[path.name+'_sha256']=hashlib.sha256(path.read_bytes()).hexdigest()
    subprocess.run(['wasm-tools','validate','--features','all',str(output)],check=True)
    subprocess.run(['node','-e','WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();if(instance.exports.main()!==42)throw Error("wrong output")})',str(output)],check=True)
    sample['validated_main']=42
    assert 'transform result cache: miss' in (profile/'run.log').read_text()
(profile/'sample.json').write_text(json.dumps(sample,indent=2)+'\n')
print(json.dumps(sample),flush=True)
if child.returncode:print((profile/'run.log').read_text());raise SystemExit(child.returncode)
