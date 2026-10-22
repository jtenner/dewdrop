from pathlib import Path
import re,collections,json,time
s=time.monotonic();lines=Path('/tmp/wago-gc-scalar-evidence/compiler.wat').read_text().splitlines();types={};funcs=[];current=None
for lineno,line in enumerate(lines):
 m=re.match(r'\s*\(type \(;(\d+);\).*',line)
 if m:types[int(m[1])]=line
 if line.startswith('  (func '):
  if current:funcs.append(current)
  current={'name':line,'line':lineno+1,'ops':[]}
 elif current and line.startswith('  )'):funcs.append(current);current=None
 elif current:current['ops'].append(line.strip())
counts=collections.Counter();examples=[]
for f in funcs:
 ops=f['ops']
 for i,line in enumerate(ops):
  m=re.fullmatch(r'struct.new (\d+)',line)
  if not m:continue
  typ=int(m[1]);td=types[typ];scalar='struct ' in td and 'ref' not in td and 'i8' not in td and 'i16' not in td and 'v128' not in td
  if not scalar:continue
  counts['scalar constructors']+=1
  tail=ops[i+1:];j=0
  if tail and re.fullmatch(r'local.set \d+',tail[0]):
   loc=int(tail[0].split()[1]);counts['local set']+=1
   if len(tail)>1 and tail[1]==f'local.get {loc}':j=2
   else:continue
  elif tail and re.fullmatch(r'local.tee \d+',tail[0]):loc=int(tail[0].split()[1]);j=1
  else:continue
  counts['adjacent local projection']+=1
  if j<len(tail) and tail[j].startswith('ref.cast '):j+=1
  if j>=len(tail) or not tail[j].startswith('struct.get '):continue
  counts['get projection']+=1
  if any(re.fullmatch(rf'local.(get|tee|set) {loc}',x) for x in tail[j+1:]):continue
  counts['no later local access']+=1
  if len(examples)<25:examples.append({'func':f['name'],'type':td,'around':ops[max(0,i-4):i+12]})
r={'seconds':time.monotonic()-s,'counts':dict(counts),'examples':examples};Path('/tmp/wago-gc-scalar-evidence/local-projection-census.json').write_text(json.dumps(r,indent=2));print(json.dumps(r,indent=2))
