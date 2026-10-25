#!/usr/bin/env python3
"""Private instruction attribution: named helper frames and sampled native PCs."""
import importlib.util
import bisect
from collections import Counter
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import threading
import time

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('measurement',HERE/'measure.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
ROOT,WORK,DATA=m.ROOT,m.WORK,m.DATA
SOURCE=WORK/'instruction-source'
HOST=WORK/'instruction-host-source'
OUT=WORK/'instruction-profile'


def replace(path,old,new):
    text=path.read_text()
    assert text.count(old)==1,(str(path),old,text.count(old))
    path.write_text(text.replace(old,new))


def setup():
    shutil.copytree(WORK/'profile-source',SOURCE,ignore=shutil.ignore_patterns('.git'))
    shutil.copytree(WORK/'profile-host-source',HOST)
    mod=HOST/'go.mod'
    mod.write_text(mod.read_text().replace(str(WORK/'profile-source'),str(SOURCE)))
    helper_source=SOURCE/'src/wago/gc_array_helper.go'
    signature='func (in *Instance) dispatchGCHelperParkedOnStack(ctrl uintptr, helper, safepoint uint32, args, results []uint64, stack *coreruntime.Engine) {'
    replace(helper_source,signature,signature.replace('dispatchGCHelperParkedOnStack','diagnosticDispatchGCOriginal'))
    names={1:'StructNewDefault',2:'StructGet',3:'StructSet',4:'StructGetS',5:'StructGetU',6:'RefTest',7:'TableSet',8:'AnyConvertExtern',9:'ExternConvertAny',10:'RefCast',11:'StructNew',12:'FinalCastStructGet',13:'FinalCastArrayLen',14:'FunctionRefTest',15:'DeadStructNew',16:'ArrayNewDefault',17:'ArrayGet',18:'ArrayGetS',19:'ArrayGetU',20:'ArraySet',21:'ArrayLen',22:'ArrayNewFixed',23:'ArrayNew',24:'ArrayNewData',25:'ArrayNewElem',26:'ElemDrop',27:'ArrayFill',28:'ArrayCopy',29:'ArrayInitData',30:'ArrayInitElem',31:'ArrayNewFixedV128',32:'ArrayNewDefaultRefill',33:'ArrayNewRefill',34:'ArrayNewFixedRefill',36:'DeadArrayNewDefault',37:'DeadArrayNew',38:'DeadArrayNewData',39:'DeadArrayNewFixed',40:'DeadStructNewRefill',42:'DeadStructNewBatch',43:'DeadArrayNewBatch'}
    content='''package wago
import (
 coreruntime "github.com/wago-org/wago/src/core/runtime"
 nativegc "github.com/wago-org/wago/src/core/runtime/gc/native"
)
// Diagnostic only: one serialized guest invocation, read after it returns.
var diagnosticHelperCounts [64]uint64
func DiagnosticGCHelperCounts() [64]uint64 { return diagnosticHelperCounts }
func DiagnosticGCReset() { clear(diagnosticHelperCounts[:]); nativegc.DiagnosticResetBatches() }
'''+signature+'''
 if helper >= uint32(len(diagnosticHelperCounts)) { panic("diagnostic helper ID out of range") }
 diagnosticHelperCounts[helper]++
 nativegc.DiagnosticCurrentHelper=helper
 switch helper {
'''
    for number,name in names.items():
        content+=f'case {number}: in.diagnosticGC{name}(ctrl,helper,safepoint,args,results,stack)\n'
    content+='default: in.diagnosticDispatchGCOriginal(ctrl,helper,safepoint,args,results,stack)\n}\nnativegc.DiagnosticCurrentHelper=0\n}\n'
    for name in names.values():
        content+='//go:noinline\n'+signature.replace('dispatchGCHelperParkedOnStack','diagnosticGC'+name)+'\n in.diagnosticDispatchGCOriginal(ctrl,helper,safepoint,args,results,stack)\n}\n'
    (SOURCE/'src/wago/diagnostic_gc_helpers.go').write_text(content)
    (SOURCE/'diagnostic_gc.go').write_text('''package wago
import inner "github.com/wago-org/wago/src/wago"
func DiagnosticGCHelperCounts() [64]uint64 { return inner.DiagnosticGCHelperCounts() }
func DiagnosticGCReset() { inner.DiagnosticGCReset() }
''')
    (DATA/'helper-names.json').write_text(json.dumps(names,indent=2)+'\n')
    gc=SOURCE/'src/core/runtime/gc/native'
    (gc/'diagnostic_batches.go').write_text('''package gc
// Diagnostic only: the private host runs one serialized guest invocation.
var DiagnosticCurrentHelper uint32
type DiagnosticBatch struct {
 Batches uint64 `json:"batches"`
 Reserved uint64 `json:"reserved"`
 Consumed uint64 `json:"consumed"`
 Canceled uint64 `json:"canceled"`
 StructBatches uint64 `json:"struct_batches"`
 ArrayBatches uint64 `json:"array_batches"`
}
var diagnosticBatches [64]DiagnosticBatch
var diagnosticHistogram [513]uint64
func DiagnosticBatchCounts() ([64]DiagnosticBatch,[513]uint64) { return diagnosticBatches,diagnosticHistogram }
func DiagnosticResetBatches() { clear(diagnosticBatches[:]); clear(diagnosticHistogram[:]); DiagnosticCurrentHelper=0 }
func diagnosticRecordBatch(end,used uint32,structure bool) {
 if end==0 {return}
 if DiagnosticCurrentHelper>=64 || used>end || used>=513 {panic("invalid diagnostic native batch")}
 s:=&diagnosticBatches[DiagnosticCurrentHelper]
 s.Batches++;s.Reserved+=uint64(end);s.Consumed+=uint64(used);s.Canceled+=uint64(end-used)
 if structure {s.StructBatches++} else {s.ArrayBatches++}
 diagnosticHistogram[used]++
}
''')
    replace(gc/'native_alloc.go','\tcanceled := false','\tdiagnosticRecordBatch(end,used,s.ChunkEnd==0)\n\tcanceled := false')
    diag=SOURCE/'diagnosticprofile/profile.go'
    replace(diag,'import(', 'import(nativegc "github.com/wago-org/wago/src/core/runtime/gc/native";')
    replace(diag,'func Snapshot(in *wago.Instance){','func Snapshot(in *wago.Instance){ batches,hist:=nativegc.DiagnosticBatchCounts(); Event("gc_instruction_helpers",map[string]any{"counts":wago.DiagnosticGCHelperCounts(),"batches":batches,"batch_consumed_histogram":hist});')
    diag.write_text(diag.read_text()+'''
func SaveCodeMap(s *wago.CodeProfile) {
 images,_,status:=s.Snapshot()
 if status.Dropped!=0 {panic("instruction profile metadata lost")}
 data,err:=json.Marshal(map[string]any{"images":images,"status":status});if err!=nil {panic(err)}
 path:=filepath.Join(os.Getenv("DEW_WAGO_PROFILE_DIR"),"code-map.json")
 if err=os.WriteFile(path,data,0600);err!=nil {panic(err)}
}
''')
    cmd=SOURCE/'cli/runtime/commands/run/command.go'
    replace(cmd,'config := selection.RuntimeConfig()','profileSession:=wago.NewCodeProfile(wago.CodeProfileOptions{SourceMaps:true,MaxBytes:512<<20})\n defer profileSession.Close()\n config := selection.RuntimeConfig()\n if os.Getenv("DEW_WAGO_NATIVE_MAP")!="0" {config=config.WithCodeProfile(profileSession)}')
    replace(cmd,'for _, invocation := range invocations {','if os.Getenv("DEW_WAGO_NATIVE_MAP")!="0" {diagnosticprofile.SaveCodeMap(profileSession)}\n wago.DiagnosticGCReset()\n for _, invocation := range invocations {')
    m.measure('build-instruction-host',['go','build','-mod=mod','-tags=wago_profile','-ldflags=-X main.runtimePatchIdentity=instruction-profile-e2fe43ffc -X main.workerPluginIdentity=instruction-profile','-o',WORK/'instruction-host','.'],cwd=HOST)


def run():
    OUT.mkdir(exist_ok=False)
    p=ROOT/'docs/research/data/wago-profile-2026-10-20/native_sample.py'
    spec=importlib.util.spec_from_file_location('native_sample',p)
    sampler=importlib.util.module_from_spec(spec);spec.loader.exec_module(sampler)
    home=WORK/'instruction-home'
    assert not home.exists()
    env=dict(m.ENV,WAGO_HOME=str(home),DEW_TRANSFORM_WORKERS='0',DEW_COMPILER_FINGERPRINT=m.digest(ROOT/'.tmp/self-host-bootstrap/b/compiler.wasm'),DEW_WAGO_PROFILE_DIR=str(OUT))
    cmd=[WORK/'instruction-host','run','-p8','--core','3','--local','--locked','--no-input','--gc-heap','512MiB','--gc-nursery','64MiB',m.COMPILER,(WORK/'request.bin').relative_to(ROOT)]
    for suffix in ['wasm','cache']:(WORK/('output.'+suffix)).unlink(missing_ok=True)
    start=time.monotonic()
    with (DATA/'instruction-profile.log').open('wb') as log:
        child=subprocess.Popen(list(map(str,cmd)),cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        def stop():
            import signal
            os.killpg(child.pid,signal.SIGKILL)
        timer=threading.Timer(600,stop);timer.start()
        try: status,usage,sampling=sampler.sample_child(child,OUT)
        finally: timer.cancel()
        child.returncode=os.waitstatus_to_exitcode(status)
    sample=dict(seconds=time.monotonic()-start,user_seconds=usage.ru_utime,system_seconds=usage.ru_stime,peak_rss_kib=usage.ru_maxrss,exit=child.returncode,command=list(map(str,cmd)),host_sha256=m.digest(WORK/'instruction-host'),sampler_sha256=m.digest(p),harness_sha256=m.digest(__file__))
    (DATA/'instruction-profile.json').write_text(json.dumps(sample,indent=2)+'\n')
    (OUT/'native-samples.json').write_text(json.dumps(sampling)+'\n')
    print(json.dumps(sample),flush=True)
    if child.returncode: raise RuntimeError((DATA/'instruction-profile.log').read_text(errors='replace'))
    for suffix,want in [('wasm','89af055df4b2a4e44be109f10f50d98b5e29deb4810194aca234c9e019912fbb'),('cache','c3a9142e2f4a1186fb5d47f78dfea5adcbf1892e52ff0a803a7c3332e7236240')]:
        assert m.digest(WORK/('output.'+suffix))==want,suffix
    subprocess.run(['wasm-tools','validate','--features','all',WORK/'output.wasm'],check=True)
    subprocess.run(['node','-e','WebAssembly.instantiate(require("fs").readFileSync(process.argv[1])).then(({instance})=>{instance.exports.__dew_init?.();if(instance.exports.main()!==42)throw Error("wrong output")})',WORK/'output.wasm'],check=True)
    sample['validated_main']=42
    (DATA/'instruction-profile.json').write_text(json.dumps(sample,indent=2)+'\n')
    m.measure('instruction-cpu-helpers',['go','tool','pprof','-top','-cum','-nodecount=80','-focus=diagnosticGC',WORK/'instruction-host',OUT/'cpu.pprof'])
    m.measure('instruction-cpu-top',['go','tool','pprof','-top','-nodecount=40',WORK/'instruction-host',OUT/'cpu.pprof'])


def uleb(data,pos):
    value=0;shift=0
    while True:
        byte=data[pos];pos+=1;value|=(byte&127)<<shift
        if byte<128: return value,pos
        shift+=7
        if shift>70: raise ValueError('overlong LEB')


def wasm_bodies():
    data=m.COMPILER.read_bytes();pos=8;imports=0;bodies=[]
    def name(pos):
        size,pos=uleb(data,pos);return pos+size
    def valtype(pos):
        byte=data[pos];pos+=1
        if byte in (0x63,0x64): _,pos=uleb(data,pos)
        return pos
    def limits(pos):
        flags,pos=uleb(data,pos);_,pos=uleb(data,pos)
        if flags&1: _,pos=uleb(data,pos)
        return pos
    while pos<len(data):
        kind=data[pos];size,start=uleb(data,pos+1);end=start+size
        if kind==2:
            count,p=uleb(data,start)
            for _ in range(count):
                p=name(name(p));tag=data[p];p+=1
                if tag==0: imports+=1;_,p=uleb(data,p)
                elif tag==1: p=limits(valtype(p))
                elif tag==2: p=limits(p)
                elif tag==3: p=valtype(p)+1
                elif tag==4: p+=1;_,p=uleb(data,p)
                else: raise ValueError(('import kind',tag))
            assert p==end
        if kind==10:
            count,p=uleb(data,start)
            for _ in range(count):
                size,p=uleb(data,p);bodies.append(data[p:p+size]);p+=size
            assert p==end
        pos=end
    return imports,bodies


GC_NAMES=['struct.new','struct.new_default','struct.get','struct.get_s','struct.get_u','struct.set','array.new','array.new_default','array.new_fixed','array.new_data','array.new_elem','array.get','array.get_s','array.get_u','array.set','array.len','array.fill','array.copy','array.init_data','array.init_elem','ref.test','ref.test_null','ref.cast','ref.cast_null','br_on_cast','br_on_cast_fail','any.convert_extern','extern.convert_any','ref.i31','i31.get_s','i31.get_u']


def analyze():
    code=json.loads((OUT/'code-map.json').read_text())
    sampling=json.loads((OUT/'native-samples.json').read_text())
    imports,bodies=wasm_bodies()
    images=code['images']
    indexes=[]
    for image in images:
        indexes.append({field:([r['offset'] for r in image.get(field,[])],image.get(field,[])) for field in ['sources','regions','compiler_sites']})
    def lookup(index,offset,field):
        starts,rows=index[field];i=bisect.bisect_right(starts,offset)-1
        if i>=0 and offset<rows[i]['offset']+rows[i]['size']: return rows[i]
        return None
    def opcode(function,offset):
        if not imports<=function<imports+len(bodies): return 'invalid-function'
        body=bodies[function-imports]
        if offset>=len(body): return 'invalid-offset'
        op=body[offset]
        if op==0xfb:
            sub,_=uleb(body,offset+1)
            return GC_NAMES[sub] if sub<len(GC_NAMES) else 'gc.'+str(sub)
        names={0xd0:'ref.null',0xd1:'ref.is_null',0xd2:'ref.func',0xd3:'ref.eq',0xd4:'ref.as_non_null',0xd5:'br_on_null',0xd6:'br_on_non_null',0x20:'local.get',0x21:'local.set',0x22:'local.tee',0x10:'call',0x11:'call_indirect',0x12:'return_call',0x0b:'end',0x0c:'br',0x0d:'br_if',0x0e:'br_table',0x04:'if',0x05:'else',0x41:'i32.const',0x42:'i64.const'}
        return names.get(op,'op.0x'+format(op,'02x'))
    counts=Counter();regions=Counter();sites=Counter();functions=Counter();native=0
    details=[]
    for sample in sampling['samples']:
        pc=sample['rip'];found=False
        for image,index in zip(images,indexes):
            offset=pc-image['base']
            if not 0<=offset<image['size']: continue
            native+=1;found=True
            region=lookup(index,offset,'regions')
            source=lookup(index,offset,'sources')
            site=lookup(index,offset,'compiler_sites')
            region_name=(region.get('name') or region['kind']) if region else 'unmapped-region'
            regions[region_name]+=1
            if source:
                label=opcode(source['function'],source['wasm_offset'])
                functions[(source['function'],label)]+=1
            else: label='unmapped-source:'+region_name
            counts[label]+=1
            if site: sites[(label,site['kind'])]+=1
            details.append(dict(pc=pc,offset=offset,instruction=label,source=source,region=region,site=site))
            break
        if not found: counts['outside-native-images']+=1
    def rows(counter,key):
        return [{key:list(name) if isinstance(name,tuple) else name,'samples':count} for name,count in counter.most_common()]
    report=dict(method=sampling['method'],total_samples=len(sampling['samples']),native_samples=native,errors=sampling['errors'],stop_ns=sampling['stop_ns'],duration_s=sampling['duration_s'],metadata_status=code['status'],instructions=rows(counts,'instruction'),regions=rows(regions,'region'),sites=rows(sites,'instruction_and_site'),functions=rows(functions,'function_and_instruction'))
    (DATA/'native-instruction-samples.json').write_text(json.dumps(report,indent=2)+'\n')
    (OUT/'resolved-samples.json').write_text(json.dumps(details)+'\n')
    print(json.dumps(report,indent=2)[:6000])


def helpers():
    m.measure('build-helper-counter-host',['go','build','-mod=mod','-ldflags=-X main.runtimePatchIdentity=helper-counts-e2fe43ffc -X main.workerPluginIdentity=helper-counts','-o',WORK/'helper-counter-host','.'],cwd=HOST)
    m.ENV['DEW_WAGO_NATIVE_MAP']='0'
    for label,batch in [('helper-counter-default','512'),('helper-counter-batch32','32')]:
        m.ENV['DEW_WAGO_PROFILE_DIR']=str(DATA/label)
        m.ENV['WAGO_AMD64_GC_STRUCT_BATCH']=batch
        m.full(label,'helper-counter')
    for label in ['helper-counter-default','helper-counter-batch32']:
        m.measure(label+'-cpu',['go','tool','pprof','-top','-cum','-nodecount=90','-focus=diagnosticGC',WORK/'helper-counter-host',DATA/label/'cpu.pprof'])


if __name__=='__main__':
    if sys.argv[1]=='setup': setup()
    elif sys.argv[1]=='run': run()
    elif sys.argv[1]=='analyze': analyze()
    elif sys.argv[1]=='helpers': helpers()
    else: raise SystemExit('use setup or run')
