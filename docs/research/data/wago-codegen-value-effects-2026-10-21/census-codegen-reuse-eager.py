from pathlib import Path
from collections import Counter
import re,json,time,resource
root=Path('/home/dev/Projects/dewdrop');out=root/'.tmp/wago-next-gc-perf/post-read-regions-profile/static-census';start=time.monotonic();functions=[];cur=None
for no,line in enumerate((root/'.tmp/wago-next-gc-perf/read-regions/compiler.wat').open(),1):
 m=re.match(r'  \(func (?:\$(\S+) )?\(;(\d+);\)',line)
 if m:
  cur=dict(name=m[1] or m[2],index=int(m[2]),line=no,ops=[]);functions.append(cur);continue
 if cur and line.strip() and not line.lstrip().startswith(('(;',';;','(local')):
  if line.startswith('  )'):cur=None;continue
  cur['ops'].append((no,line.strip()))
lookup={f['name']:f for f in functions};lookup.update({str(f['index']):f for f in functions})
alloc={'struct.new','struct.new_default','array.new','array.new_default','array.new_fixed','array.new_data','array.new_elem'}
writes={'struct.set','array.set','array.fill','array.copy','array.init_data','array.init_elem','table.set','table.grow','table.fill','table.copy','table.init','global.set','memory.grow','call_indirect','return_call_indirect','call_ref','return_call_ref','throw','throw_ref','try','try_table','any.convert_extern','extern.convert_any'}
def bad(op):return op in alloc or op in writes or '.store' in op or '.atomic.' in op or op.startswith('atomic.')
for f in functions:
 f.update(calls=set(),own_closed=True,loops=[],tests=Counter(),reads=Counter());stack=[]
 for i,(line,s) in enumerate(f['ops']):
  op=s.split()[0]
  if op in ['call','return_call']:f['calls'].add(s.split()[1].removeprefix('$'))
  elif bad(op):f['own_closed']=False
  if op in ['block','loop','if','try','try_table']:stack.append((op,i))
  elif op=='end' and stack:
   kind,j=stack.pop()
   if kind=='loop':f['loops'].append((j,i))
  if op=='ref.test' and i>0:
   prev=f['ops'][i-1][1].split()
   if len(prev)==2 and prev[0]=='local.get':f['tests'][prev[1]]+=1
  if op.startswith('struct.get') and i>1:
   prev=f['ops'][i-2][1].split();cast=f['ops'][i-1][1].split()
   if len(prev)==2 and prev[0]=='local.get' and cast[0]=='ref.cast':f['reads'][(prev[1],cast[-1])]+=1
 f['closed']=f['own_closed']
changed=True
while changed:
 changed=False
 for f in functions:
  if f['closed'] and any(t not in lookup or not lookup[t]['closed'] for t in f['calls']):f['closed']=False;changed=True
no_call=with_calls=loops=0;examples=[]
for f in functions:
 for a,b in f['loops']:
  loops+=1;body=f['ops'][a:b+1];ops=[s.split()[0] for _,s in body];calls=[s.split()[1].removeprefix('$') for _,s in body if s.split()[0] in ['call','return_call']];local_ok=not any(bad(o) for o in ops)
  if local_ok and not calls:no_call+=1
  if local_ok and all(t in lookup and lookup[t]['closed'] for t in calls):with_calls+=1;examples.append(dict(function=f['index'],name=f['name'],line=body[0][0],op_count=len(body),direct_calls=len(calls)))
report=dict(note='Loose source census only. No control-flow/dominance/alias/backend-helper/liveness/register-effect proof. Closed means no listed source allocation/write/unknown call; it does not certify no Go entry. Static sites are not dynamic coverage or profitable eligibility.',seconds=time.monotonic()-start,peak_rss_kib=int(next(x.split()[1] for x in Path("/proc/self/status").read_text().splitlines() if x.startswith("VmHWM:"))),resource_ru_maxrss_kib=resource.getrusage(resource.RUSAGE_SELF).ru_maxrss,functions=len(functions),loops=loops,loops_without_calls_allocations_or_listed_writes=no_call,loops_allowing_transitively_read_only_source_callees=with_calls,transitive_read_only_source_functions=sum(f['closed'] for f in functions),functions_with_repeat_same_local_test=sum(any(n>1 for n in f['tests'].values()) for f in functions),extra_same_local_tests=sum(sum(max(0,n-1) for n in f['tests'].values()) for f in functions),functions_with_repeat_same_local_cast_get=sum(any(n>1 for n in f['reads'].values()) for f in functions),extra_same_local_cast_get_sites=sum(sum(max(0,n-1) for n in f['reads'].values()) for f in functions),potential_loops=examples)
(out/'census-eager-memory.json').write_text(json.dumps(report,indent=2));print(json.dumps({k:v for k,v in report.items() if k!='potential_loops'},indent=2))
