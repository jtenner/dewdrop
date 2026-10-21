from pathlib import Path
import importlib.util,json,os,sys
r=Path('/home/dev/Projects/dewdrop');out=Path('/tmp/wago-four-seconds');data=out/'measurements';data.mkdir(exist_ok=True)
s=importlib.util.spec_from_file_location('measure',r/'docs/research/data/wago-local-perf-2026-10-20/measure.py');m=importlib.util.module_from_spec(s);s.loader.exec_module(m);m.DATA=data;m.ENV=dict(m.ENV,GOMAXPROCS='2')
original=m.measure
binaries={'control':r/'.tmp/wago-local-perf-2026-10-20/value-checks-final-host','candidate':out/'candidate-host'}
def measure(label,command,**kw):
 command=list(command);engine=label.split('-')[2];command[0]=binaries[engine]
 kw['env']=dict(kw['env'],WAGO_HOME=str(out/'homes'/label))
 return original(label,['taskset','-c','12,14',*command],**kw)
m.measure=measure
for selection in sys.argv[1:]:
 engine,round=selection.split(':')
 label='4s-callfacts-'+engine+'-'+round
 assert not (data/(label+'.json')).exists(),label
 m.full(label,engine)
