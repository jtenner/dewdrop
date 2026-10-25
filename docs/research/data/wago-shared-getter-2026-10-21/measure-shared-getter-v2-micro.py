from pathlib import Path
import subprocess,time,json,os,re,statistics
out=Path('/home/dev/Projects/dewdrop/.tmp/wago-next-gc-perf/shared-getter-v2');tree='/home/dev/Projects/dewdrop/.tmp/wago-shared-getter/src/wago';rows=[]
for i,name in enumerate(['control','candidate','candidate','control']*3):
 cmd=['taskset','-c','15',str(out/(name+'.test')),'-test.run=^$','-test.bench=^BenchmarkGCSharedGetterCall$/^loop-i32$/^inline-true$','-test.benchtime=200ms','-test.count=1'];t=time.monotonic();r=subprocess.run(cmd,cwd=tree,env=dict(os.environ,GOMAXPROCS='1'),stdout=subprocess.PIPE,stderr=subprocess.STDOUT,text=True);(out/f'micro-{i:02}-{name}.log').write_text(r.stdout);assert not r.returncode,r.stdout
 parsed=re.findall(r'BenchmarkGCSharedGetterCall/(\S+)\s+\d+\s+([0-9.]+) ns/op',r.stdout);assert len(parsed)==1,r.stdout
 for shape,ns in parsed:rows.append(dict(run=i,variant=name,shape=shape,ns=float(ns),seconds=time.monotonic()-t))
 (out/'micro-samples.json').write_text(json.dumps(rows,indent=2));print(i,name,round(time.monotonic()-t,2),flush=True)
summary={}
for shape in ['loop-i32/inline-true']:
 d={n:{'samples':[r['ns'] for r in rows if r['shape']==shape and r['variant']==n]} for n in ['control','candidate']}
 for v in d.values():v['median']=statistics.median(v['samples'])
 d['change_percent']=100*(d['candidate']['median']/d['control']['median']-1);summary[shape]=d
(out/'micro-summary.json').write_text(json.dumps(summary,indent=2));print(json.dumps(summary,indent=2))
