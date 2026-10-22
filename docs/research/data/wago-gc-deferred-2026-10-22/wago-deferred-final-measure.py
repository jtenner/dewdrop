from pathlib import Path
import types,os,sys,json,hashlib
project=Path('/home/dev/Projects/dewdrop');e=Path('/tmp/wago-gc-deferred-evidence')
p=project/'docs/research/data/wago-local-perf-2026-10-20/measure.py'
source=p.read_text().replace('exit=child.returncode, timeout=expired.is_set(),','exit=child.returncode, timeout=expired.is_set(),\n                  minor_faults=usage.ru_minflt, major_faults=usage.ru_majflt,\n                  voluntary_context_switches=usage.ru_nvcsw, involuntary_context_switches=usage.ru_nivcsw,')
m=types.ModuleType('measure');m.__file__=str(p);exec(compile(source,str(p),'exec'),m.__dict__)
m.DATA=e/'measurements';m.ENV=dict(m.ENV,GOMAXPROCS='2')
assert m.digest(m.COMPILER)=='c64fcf044b72cb7356ad598a35670045931337cfa7a6bb9d5916cd304b23fba6'
assert m.digest(m.WORK/'request.bin')=='077b0ff0271706cc3034f3e06c7a228f227c49aeec7786d21373b2072af89c72'
version,round=sys.argv[1:];label='gc-deferred-'+version+'-'+round
assert not (m.DATA/(label+'.json')).exists()
original=m.measure

def measure(label,command,**kw):
 cmd=list(command);cmd[0]=e/(version+'-host')
 actual_home=e/'homes'/label;assert not actual_home.exists()
 kw['env']['WAGO_HOME']=str(actual_home)
 sample=original(label,['taskset','-c','12,14',*cmd],**kw)
 sample['gomaxprocs']=2
 sample['host_sha256']=hashlib.sha256((e/(version+'-host')).read_bytes()).hexdigest()
 return sample
m.measure=measure;m.full(label,version)
