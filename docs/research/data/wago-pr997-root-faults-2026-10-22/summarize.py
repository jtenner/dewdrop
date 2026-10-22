from pathlib import Path
import json,statistics,math
root=Path(__file__).parent

def samples(prefix,label):
 result={}
 for i in range(3):
  for line in (root/f'{prefix}{label}-{i}.log').read_text().splitlines():
   if not line.startswith('Benchmark'):continue
   words=line.split();metrics={}
   for j in range(2,len(words)-1,2):
    try:metrics[words[j+1]]=float(words[j])
    except ValueError:pass
   result.setdefault(words[0],[]).append(metrics)
 return {name:{unit:statistics.median(row[unit] for row in rows) for unit in rows[0]} for name,rows in result.items()}
all_results={}
for group,prefix in [('initial','bench-'),('fast_guards','fast-guards-')]:
 base,candidate=samples(prefix,'baseline'),samples(prefix,'candidate')
 rows=[]
 for name in base.keys()&candidate.keys():
  rows.append({'name':name,'baseline':base[name],'candidate':candidate[name],'percent_ns':100*(candidate[name]['ns/op']/base[name]['ns/op']-1)})
 all_results[group]=sorted(rows,key=lambda row:row['name'])
(root/'benchmark-summary.json').write_text(json.dumps(all_results,indent=2)+'\n')
for group,rows in all_results.items():
 print(group)
 for row in rows:
  if row['name'].startswith('BenchmarkGC') or ('/parallelfalse/host1/n64-' in row['name']):print(row['name'],row['baseline'],row['candidate'],round(row['percent_ns'],2))
 hosts=[row for row in rows if row['name'].startswith('BenchmarkHost')]
 if hosts:print('host geomean percent',100*(math.exp(statistics.mean(math.log(1+row['percent_ns']/100) for row in hosts))-1))
