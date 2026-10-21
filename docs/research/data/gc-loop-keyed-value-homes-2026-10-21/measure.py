from pathlib import Path
import importlib.util,sys,os
r=Path('/home/dev/Projects/dewdrop');out=Path('/tmp/wago-four-seconds/loop-keyed');data=out/'measurements';data.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('measure',r/'docs/research/data/wago-local-perf-2026-10-20/measure.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);m.DATA=data;m.ENV=dict(m.ENV,GOMAXPROCS='2')
original=m.measure
binaries={'control':Path('/tmp/wago-four-seconds/simd/host'),'candidate':out/'host'}
def measure(label,command,**kw):
 command=list(command);engine=label.split('-')[2];command[0]=binaries[engine]
 kw['env']=dict(kw['env'],WAGO_HOME=str(out/'homes'/label))
 result=original(label,['taskset','-c','12,14',*command],**kw)
 result['actual_environment']={'WAGO_HOME':kw['env']['WAGO_HOME'],'GOMAXPROCS':'2'}
 return result
m.measure=measure
for selection in sys.argv[1:]:
 engine,round=selection.split(':');label='4s-loop-'+engine+'-'+round
 assert not(data/(label+'.json')).exists(),label
 m.full(label,engine)
