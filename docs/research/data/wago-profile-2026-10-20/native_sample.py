"""Bounded leaf-PC probes of our own child; detach after each address read."""
import ctypes,os,time,random
from pathlib import Path
lib=ctypes.CDLL(None,use_errno=True)
lib.ptrace.argtypes=[ctypes.c_ulong,ctypes.c_ulong,ctypes.c_void_p,ctypes.c_void_p]
lib.ptrace.restype=ctypes.c_long
WALL=0x40000000

def sample_child(child,destination):
    samples=[];previous={};errors={};stopped_ns=0;start=time.monotonic()
    rng=random.Random(20261020)
    def error(key):errors[key]=errors.get(key,0)+1
    def result():return {'samples':samples,'errors':errors,'stop_ns':stopped_ns,'duration_s':time.monotonic()-start,'method':'brief ptrace leaf-PC probes of up to 3 CPU-active threads, every 20-30 ms, after code mapping; no stacks; not a hardware CPU profile'}
    while True:
        pid,status,usage=os.wait4(child.pid,os.WNOHANG)
        if pid:return status,usage,result()
        if not (destination/'code-map.json').exists():time.sleep(.025);continue
        active=[]
        try:tasks=list((Path('/proc')/str(child.pid)/'task').iterdir())
        except FileNotFoundError:continue
        for task in tasks:
            try:
                text=(task/'stat').read_text();fields=text[text.rfind(')')+2:].split()
                ticks=int(fields[11])+int(fields[12]);tid=int(task.name)
                delta=ticks-previous.get(tid,ticks);previous[tid]=ticks
                if delta>0:active.append((delta,tid))
            except (FileNotFoundError,ProcessLookupError):pass
        for delta,tid in sorted(active,reverse=True)[:3]:
            seized=False;stopped=False;forward=0;before=time.monotonic_ns()
            try:
                if lib.ptrace(0x4206,tid,None,None)!=0:error('seize:'+str(ctypes.get_errno()));continue
                seized=True
                if lib.ptrace(0x4207,tid,None,None)!=0:error('interrupt:'+str(ctypes.get_errno()));continue
                _,stop,thread_usage=os.wait4(tid,WALL)
                if os.WIFEXITED(stop) or os.WIFSIGNALED(stop):
                    seized=False
                    if tid==child.pid:return stop,thread_usage,result()
                    continue
                stopped=True
                # Forward real signals. PTRACE_EVENT_STOP is our own interrupt.
                if stop>>16!=128:forward=os.WSTOPSIG(stop)
                regs=(ctypes.c_ulonglong*27)()
                if lib.ptrace(12,tid,None,ctypes.cast(ctypes.byref(regs),ctypes.c_void_p))==0:
                    samples.append({'s':time.monotonic()-start,'tid':tid,'rip':int(regs[16]),'delta_ticks':delta})
                else:error('getregs:'+str(ctypes.get_errno()))
            except (FileNotFoundError,ProcessLookupError,ChildProcessError):error('task_exit')
            finally:
                if seized and stopped:
                    if lib.ptrace(17,tid,None,ctypes.c_void_p(forward))!=0:error('detach:'+str(ctypes.get_errno()))
                stopped_ns+=time.monotonic_ns()-before
        time.sleep(rng.uniform(.020,.030))
