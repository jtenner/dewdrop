#!/usr/bin/env python3
"""Local, serial Wago smoke and timing checks. Run from the Dewdrop root."""
import hashlib
import io
import json
import os
from pathlib import Path
import platform
import shutil
import statistics
import struct
import subprocess
import sys
import tarfile
import threading
import time

ROOT = Path(__file__).resolve().parents[4]
DATA = Path(__file__).resolve().parent
WORK = ROOT / '.tmp/wago-local-perf-2026-10-20'
STACK = ROOT / '.tmp/wago-local-stack-2026-10-20/wago'
BASE = ROOT / '.tmp/wago-origin-main-2026-10-20/wago'
FACET = ROOT / '.tmp/wago-origin-main-2026-10-20/facet'
COMPILER = ROOT / '.tmp/transform-workers/run-rvr6ozve/compiler.wasm'
INSTALLED = Path('/home/dev/.local/share/wago/versions/local-gc-e2fe43ffc/standard/normal/wago-runtime')
ENV = dict(os.environ, GOWORK='off', CGO_ENABLED='0')


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def measure(label, command, *, cwd=ROOT, env=None, timeout=180):
    DATA.mkdir(parents=True, exist_ok=True)
    logpath = DATA / (label + '.log')
    start = time.monotonic()
    load_start = os.getloadavg()
    expired = threading.Event()
    with logpath.open('wb') as log:
        child = subprocess.Popen(list(map(str, command)), cwd=cwd, env=env or ENV,
                                 stdout=log, stderr=subprocess.STDOUT, start_new_session=True)
        def stop():
            expired.set()
            import signal
            os.killpg(child.pid, signal.SIGKILL)
        timer = threading.Timer(timeout, stop)
        timer.start()
        try:
            _, status, usage = os.wait4(child.pid, 0)
            child.returncode = os.waitstatus_to_exitcode(status)
        finally:
            timer.cancel()
    sample = dict(label=label, command=list(map(str, command)), cwd=str(cwd),
                  seconds=time.monotonic()-start, user_seconds=usage.ru_utime,
                  system_seconds=usage.ru_stime, peak_rss_kib=usage.ru_maxrss,
                  exit=child.returncode, timeout=expired.is_set(),
                  load_start=load_start, load_end=os.getloadavg())
    (DATA / (label + '.json')).write_text(json.dumps(sample, indent=2)+'\n')
    print(json.dumps(sample), flush=True)
    if child.returncode:
        raise RuntimeError(logpath.read_text(errors='replace'))
    return sample


def setup():
    WORK.mkdir(parents=True, exist_ok=False)
    source = WORK / 'stack-source'
    source.mkdir()
    archive = subprocess.check_output(['git', 'archive', 'HEAD'], cwd=STACK)
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        tar.extractall(source, filter='data')
    # Reference-local safety repairs are already in this stack. Worker support
    # remains a private host patch, as in the baseline host.
    subprocess.run(['git', 'init', '-q', str(source)], check=True)
    subprocess.run(['git', '-C', str(source), 'apply', str(ROOT / 'tools/wago-transform-host/patches/managed-isolated-fork.patch')], check=True)
    identity = dict(platform=platform.platform(), go=subprocess.check_output(['go','version'],text=True).strip(),
                    base_commit='7997c86c36e05cfba4c4f39cabb026a318f55fc0',
                    stack_commit=subprocess.check_output(['git','rev-parse','HEAD'],cwd=STACK,text=True).strip(),
                    installed_runtime_sha256=digest(INSTALLED), compiler_sha256=digest(COMPILER),
                    base_source=str(BASE), stack_source=str(source), facet_source=str(FACET),
                    cpu=Path('/proc/cpuinfo').read_text().split('model name\t: ',1)[1].splitlines()[0],
                    logical_cpus=os.cpu_count(), harness_sha256=digest(__file__))
    (DATA/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    measure('build-base-runtime', ['go','build','-trimpath','-tags','wago_runtime','-ldflags=-s -w -X main.version=base-7997c86c3','-o',WORK/'base-runtime','./cli/wago'], cwd=BASE)
    for name, runtime_source, rev in [('base',BASE,'7997c86c36e0'),('stack',source,identity['stack_commit'][:12])]:
        host = WORK / (name+'-host-source')
        host.mkdir()
        inputs = ROOT / 'tools/wago-transform-host'
        for path in [inputs/'go.mod',inputs/'go.sum',*inputs.glob('*.go')]:
            shutil.copyfile(path,host/path.name)
        main=host/'main.go'
        main.write_text(main.read_text().replace('7997c86c36e0',rev))
        with (host/'go.mod').open('a') as mod:
            mod.write('\nreplace github.com/wago-org/wago => '+json.dumps(str(runtime_source))+'\n')
            mod.write('replace github.com/jtenner/wago-facet => '+json.dumps(str(FACET))+'\n')
        source_hash=hashlib.sha256(b''.join(p.name.encode()+b'\0'+p.read_bytes()+b'\0' for p in sorted(host.glob('*.go')) if not p.name.endswith('_test.go'))).hexdigest()
        flags='-X main.runtimePatchIdentity=local-perf-'+rev+' -X main.workerPluginIdentity='+source_hash
        measure('build-'+name+'-host',['go','build','-mod=mod','-ldflags='+flags,'-o',WORK/(name+'-host'),'.'],cwd=host)
    identity.update({name+'_sha256':digest(WORK/name) for name in ['base-runtime','base-host','stack-host']})
    (DATA/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
    # Change only the two length-prefixed output paths. Every engine gets the
    # same request, and existing profile output files remain untouched.
    request=(ROOT/'.tmp/wago-profile-2026-10-20/request.bin').read_bytes()
    for suffix in ['wasm','cache']:
        old=('.tmp/wago-profile-2026-10-20/output.'+suffix).encode()
        new=str((WORK/('output.'+suffix)).relative_to(ROOT)).encode()
        needle=struct.pack('<I',len(old))+old
        assert request.count(needle)==1
        request=request.replace(needle,struct.pack('<I',len(new))+new)
    (WORK/'request.bin').write_bytes(request)


def native():
    compiler=COMPILER
    fib=STACK/'tests/fixtures/wasm/fib.wasm'
    samples=[]
    # Alternate version order and worker order across rounds.
    configurations=[('base',WORK/'base-runtime',1),('stack',INSTALLED,1),
                    ('base',WORK/'base-runtime',8),('stack',INSTALLED,8)]
    for round_index in range(3):
        for module_name,module in [('fib',fib),('dew-compiler',compiler)]:
            for name,binary,workers in configurations[::1 if round_index%2==0 else -1]:
                label=f'native-{module_name}-{name}-p{workers}-{round_index+1}'
                target=WORK/(label+'.wago')
                sample=measure(label,[binary,'build','--bare','--offline','--no-input','-p'+str(workers),'--output',target,module],cwd=WORK,timeout=30)
                sample.update(module=module_name,version=name,workers=workers,module_sha256=digest(module),artifact_bytes=target.stat().st_size)
                samples.append(sample)
                (DATA/'native-samples.json').write_text(json.dumps(samples,indent=2)+'\n')
                target.unlink()
    summary=[]
    for module in ['fib','dew-compiler']:
        for version in ['base','stack']:
            for workers in [1,8]:
                rows=[s for s in samples if (s['module'],s['version'],s['workers'])==(module,version,workers)]
                summary.append(dict(module=module,version=version,workers=workers,
                                    median_seconds=statistics.median(s['seconds'] for s in rows),
                                    median_cpu_seconds=statistics.median(s['user_seconds']+s['system_seconds'] for s in rows),
                                    median_peak_rss_kib=statistics.median(s['peak_rss_kib'] for s in rows)))
    (DATA/'native-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps(summary,indent=2),flush=True)


def full(label,version,warm=False,profile=False):
    home=WORK/(version+'-full-home' if warm else label+'-home')
    if warm:
        home=WORK/'stack-1-home'
    else:
        assert not home.exists(),home
    env=dict(ENV,WAGO_HOME=str(home),DEW_TRANSFORM_WORKERS='0',
             DEW_COMPILER_FINGERPRINT=digest(ROOT/'.tmp/self-host-bootstrap/b/compiler.wasm'))
    if profile:
        env['DEW_WAGO_PROFILE_DIR']=str(DATA/'stack-profile')
    for suffix in ['wasm','cache']:
        (WORK/('output.'+suffix)).unlink(missing_ok=True)
    if version=='node':
        cmd=['node','--stack-size=65500','tools/run-dew-facet.mjs',ROOT/'.tmp/wago-profile-2026-10-20/compiler-node.wasm',(WORK/'request.bin').relative_to(ROOT)]
    else:
        cmd=[WORK/(version+'-host'),'run','-p8','--core','3','--local','--locked','--no-input','--gc-heap','512MiB','--gc-nursery','64MiB',COMPILER,(WORK/'request.bin').relative_to(ROOT)]
        if profile:
            cmd[0]=WORK/'stack-profile-host'
    sample=measure(label,cmd,env=env)
    sample['environment']={key:env.get(key,'') for key in ['WAGO_HOME','DEW_TRANSFORM_WORKERS','WAGO_AMD64_GC_STRUCT_BATCH','DEW_WAGO_NATIVE_MAP','DEW_WAGO_PROFILE_DIR']}
    log=(DATA/(label+'.log')).read_text()
    assert 'transform result cache: miss' in log,log
    expected={'wasm':'89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb',
              'cache':'c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240'}
    for suffix,want in expected.items():
        file=WORK/('output.'+suffix)
        sample['output_'+suffix+'_sha256']=digest(file)
        assert digest(file)==want,(file,digest(file),want)
        shutil.copyfile(file,WORK/(label+'.'+suffix))
    subprocess.run(['wasm-tools','validate','--features','all',WORK/'output.wasm'],check=True)
    subprocess.run(['node','-e','WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();if(instance.exports.main()!==42)throw Error("wrong output")})',WORK/'output.wasm'],check=True)
    sample.update(validated_main=42,request_sha256=digest(WORK/'request.bin'),native_cache='warm' if warm else 'cold')
    (DATA/(label+'.json')).write_text(json.dumps(sample,indent=2)+'\n')


def profile():
    source=WORK/'profile-source'
    host=WORK/'profile-host-source'
    shutil.copytree(WORK/'stack-source',source,ignore=shutil.ignore_patterns('.git'))
    shutil.copytree(WORK/'stack-host-source',host)
    subprocess.run(['git','init','-q',source],check=True)
    patch=ROOT/'docs/research/data/wago-profile-2026-10-20/large-array-cancel/current-main-diagnostic.patch'
    subprocess.run(['git','-C',source,'apply','--check',patch],check=True)
    subprocess.run(['git','-C',source,'apply',patch],check=True)
    mod=host/'go.mod'
    mod.write_text(mod.read_text().replace(str(WORK/'stack-source'),str(source)))
    main=host/'main.go'
    content=main.read_text()
    assert 'diagnosticprofile' not in content
    content=content.replace('import (','import (\n "github.com/wago-org/wago/diagnosticprofile"',1)
    content=content.replace('func main() {','func main() {\n diagnosticprofile.Start()\n defer diagnosticprofile.Finish()',1)
    main.write_text(content)
    measure('build-stack-profile-host',['go','build','-mod=mod','-ldflags=-X main.runtimePatchIdentity=local-perf-profile-e2fe43ffc -X main.workerPluginIdentity=local-perf-profile','-o',WORK/'stack-profile-host','.'],cwd=host)
    full('stack-profile','stack',profile=True)
    measure('profile-cpu-top',['go','tool','pprof','-top','-nodecount=35',WORK/'stack-profile-host',DATA/'stack-profile/cpu.pprof'])
    measure('profile-cpu-cumulative',['go','tool','pprof','-top','-cum','-nodecount=35',WORK/'stack-profile-host',DATA/'stack-profile/cpu.pprof'])


if __name__=='__main__':
    action=sys.argv[1]
    if action=='setup': setup()
    elif action=='native': native()
    elif action=='profile': profile()
    elif action=='full': full(sys.argv[2],sys.argv[3],len(sys.argv)>4 and sys.argv[4]=='warm')
    else: raise SystemExit('use setup, native, or full LABEL base|stack|node [warm]')
