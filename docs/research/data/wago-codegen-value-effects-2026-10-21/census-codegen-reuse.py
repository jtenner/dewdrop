from pathlib import Path
from collections import Counter,deque
import re,json,time,resource
root=Path('/home/dev/Projects/dewdrop');out=root/'.tmp/wago-next-gc-perf/post-read-regions-profile/static-census';start=time.monotonic();functions=[];cur=None
alloc={'struct.new','struct.new_default','array.new','array.new_default','array.new_fixed','array.new_data','array.new_elem'}
writes={'struct.set','array.set','array.fill','array.copy','array.init_data','array.init_elem','table.set','table.grow','table.fill','table.copy','table.init','global.set','memory.grow','call_indirect','return_call_indirect','call_ref','return_call_ref','throw','throw_ref','try','try_table','any.convert_extern','extern.convert_any'}
def bad(op):return op in alloc or op in writes or '.store' in op or '.atomic.' in op or op.startswith('atomic.')
def finish(f):
 f['repeated_tests']=sum(max(0,n-1) for n in f.pop('tests').values());f['repeated_reads']=sum(max(0,n-1) for n in f.pop('reads').values());f.pop('control');f.pop('previous');f['closed']=f['own_closed'];functions.append(f)
for no,line in enumerate((root/'.tmp/wago-next-gc-perf/read-regions/compiler.wat').open(),1):
 m=re.match(r'  \(func (?:\$(\S+) )?\(;(\d+);\)',line)
 if m:
  assert cur is None
  cur=dict(name=m[1] or m[2],index=int(m[2]),line=no,calls=set(),own_closed=True,loops=[],control=[],previous=deque(maxlen=2),tests=Counter(),reads=Counter())
  if line.count('(')==line.count(')'):finish(cur);cur=None
  continue
 if cur is None:continue
 if line.startswith('  )'):finish(cur);cur=None;continue
 s=line.strip()
 if not s or s.startswith(('(;',';;','(local')):continue
 words=s.split();op=words[0];target=words[1].removeprefix('$') if op in ['call','return_call'] else None
 if target:cur['calls'].add(target)
 elif bad(op):cur['own_closed']=False
 for control in cur['control']:
  if control['kind']=='loop':
   control['op_count']+=1
   if target:control['calls'].add(target)
   elif bad(op):control['closed']=False
 if op in ['block','loop','if','try','try_table']:cur['control'].append(dict(kind=op,line=no,op_count=1,calls=set(),closed=True))
 elif op=='end' and cur['control']:
  c=cur['control'].pop()
  if c['kind']=='loop':cur['loops'].append(c)
 prev=list(cur['previous'])
 if op=='ref.test' and prev and len(prev[-1])==2 and prev[-1][0]=='local.get':cur['tests'][prev[-1][1]]+=1
 if op.startswith('struct.get') and len(prev)==2 and len(prev[0])==2 and prev[0][0]=='local.get' and prev[1][0]=='ref.cast':cur['reads'][(prev[0][1],prev[1][-1])]+=1
 cur['previous'].append(words)
assert cur is None
lookup={f['name']:f for f in functions};lookup.update({str(f['index']):f for f in functions});changed=True
while changed:
 changed=False
 for f in functions:
  if f['closed'] and any(t not in lookup or not lookup[t]['closed'] for t in f['calls']):f['closed']=False;changed=True
no_call=with_calls=loops=0;examples=[]
for f in functions:
 for loop in f['loops']:
  loops+=1
  if loop['closed'] and not loop['calls']:no_call+=1
  if loop['closed'] and all(t in lookup and lookup[t]['closed'] for t in loop['calls']):with_calls+=1;examples.append(dict(function=f['index'],name=f['name'],line=loop['line'],op_count=loop['op_count'],direct_calls=len(loop['calls'])))
report=dict(note='Loose source census only. No control-flow/dominance/alias/backend-helper/liveness/register-effect proof. Closed means no listed source allocation/write/unknown call; it does not certify no Go entry. Static sites are not dynamic coverage or profitable eligibility.',storage='Stream one function at a time; retain only compact module call and loop summaries, no body strings or module-wide value IR.',seconds=time.monotonic()-start,peak_rss_kib=int(next(x.split()[1] for x in Path("/proc/self/status").read_text().splitlines() if x.startswith("VmHWM:"))),resource_ru_maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,functions=len(functions),loops=loops,loops_without_calls_allocations_or_listed_writes=no_call,loops_allowing_transitively_read_only_source_callees=with_calls,transitive_read_only_source_functions=sum(f['closed'] for f in functions),functions_with_repeat_same_local_test=sum(f['repeated_tests']>0 for f in functions),extra_same_local_tests=sum(f['repeated_tests'] for f in functions),functions_with_repeat_same_local_cast_get=sum(f['repeated_reads']>0 for f in functions),extra_same_local_cast_get_sites=sum(f['repeated_reads'] for f in functions),potential_loops=examples)
(out/'census.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='potential_loops'},indent=2))
