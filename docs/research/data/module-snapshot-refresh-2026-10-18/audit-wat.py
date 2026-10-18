#!/usr/bin/env python3
"""Audit snapshot changes without compiling or accepting runtime expectations."""
import pathlib,re,subprocess,json,hashlib,collections,difflib,argparse
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--baseline',default='fc00559474')
parser.add_argument('--output',type=pathlib.Path,default=pathlib.Path('/tmp/dewdrop-snapshot-audit'))
args=parser.parse_args(); ROOT=pathlib.Path.cwd(); OUT=args.output; OUT.mkdir(parents=True,exist_ok=True)
TOKEN=re.compile(r'"(?:\\.|[^"\\])*"|\(;.*?;\)|;;[^\n]*|[()]|[^\s()]+',re.S)
TYPE_OPS={'struct.new':1,'struct.new_default':1,'struct.get':1,'struct.get_s':1,'struct.get_u':1,'struct.set':1,'array.new':1,'array.new_default':1,'array.new_fixed':1,'array.new_data':1,'array.new_elem':1,'array.get':1,'array.get_s':1,'array.get_u':1,'array.set':1,'array.fill':1,'array.copy':2,'array.init_data':1,'array.init_elem':1,'call_ref':1,'return_call_ref':1}
def digest(x):return hashlib.sha256(json.dumps(x,separators=(',',':')).encode()).hexdigest()
def parse(text):
 stack=[[]]
 for m in TOKEN.finditer(text):
  t=m[0]
  if t.startswith('(;') or t.startswith(';;'):continue
  if t=='(':stack.append([])
  elif t==')':
   a=stack.pop();stack[-1].append(a)
  else:stack[-1].append(t)
 assert len(stack)==1 and len(stack[0])==1
 return stack[0][0]
def normalize(node,labels):
 if not isinstance(node,list):return node
 out=[]; i=0
 while i<len(node):
  item=node[i]
  if isinstance(item,list):out.append(normalize(item,labels));i+=1;continue
  out.append(item)
  n=TYPE_OPS.get(item,0)
  if item=='ref.null' and i+1<len(node) and isinstance(node[i+1],str) and node[i+1].isdigit():n=1
  if i==0 and item in ['ref','type'] and len(node)>1 and isinstance(node[-1],str) and node[-1].isdigit():
   out.extend(node[1:-1]);out.append('TYPE:'+labels[int(node[-1])]);return out
  if i==0 and item=='sub':
   i+=1
   while i<len(node) and not isinstance(node[i],list):
    out.append('TYPE:'+labels[int(node[i])] if node[i].isdigit() else node[i]);i+=1
   continue
  if n:
   for j in range(n):
    i+=1;assert isinstance(node[i],str) and node[i].isdigit(),(item,node[i]);out.append('TYPE:'+labels[int(node[i])])
  i+=1
 return out
def decode(text):
 ast=parse(text);types=[];body=[];custom=[]
 for n in ast[1:]:
  if n[0]=='type':types.append(n[1:])
  elif n[0]=='rec':
   assert all(t[0]=='type' for t in n[1:]);types.extend(t[1:] for t in n[1:])
  elif n[0]=='@custom':custom.append(n)
  else:body.append(n)
 labels=['TYPE']*len(types)
 # Round count exceeds the deepest acyclic graph here. Cyclic labels remain
 # structural fingerprints, not proof of arbitrary nominal equivalence.
 for _ in range(64):labels=[digest(normalize(t,labels)) for t in types]
 return normalize(body,labels),collections.Counter(labels),custom
paths=subprocess.check_output(['git','diff','--name-only',args.baseline,'--','tests/module-snapshots'],text=True).splitlines(); records=[];remaining=[]
for p in paths:
 before=subprocess.check_output(['git','show',args.baseline+':'+p],text=True);after=pathlib.Path(p).read_text();r={'path':p,'before_sha256':hashlib.sha256(before.encode()).hexdigest(),'after_sha256':hashlib.sha256(after.encode()).hexdigest()}
 if p.endswith('.json'):
  a=json.loads(before);b=json.loads(after);r['changed_expectation_keys']=[k for k in sorted(a.keys()|b.keys()) if a.get(k)!=b.get(k)];remaining.append(p)
 else:
  a,at,ac=decode(before);b,bt,bc=decode(after);r.update(body_same_after_type_resolution=a==b,old_type_count=at.total(),new_type_count=bt.total(),added_type_shapes=dict(bt-at),removed_type_shapes=dict(at-bt),custom_sections_before=[x[1] for x in ac],custom_sections_after=[x[1] for x in bc],custom_sha256_before=digest(ac),custom_sha256_after=digest(bc))
  if a!=b:
   remaining.append(p);(OUT/(pathlib.Path(p).stem+'.normalized.diff')).write_text('\n'.join(difflib.unified_diff(json.dumps(a,indent=1).splitlines(),json.dumps(b,indent=1).splitlines()))+'\n')
 records.append(r)
report={'baseline':args.baseline,'method':'Parse printed WAT. Remove printer index/label comments and custom sections. Resolve all type uses through 64-round structural graph fingerprints, then compare every remaining body token, including constants, function indices, memory instructions, exports and data bytes. List type-shape multiset changes separately. This is a bounded structural audit, not proof of arbitrary nominal/recursive type equivalence. Runtime correctness is checked separately by both engines.','files':records,'changed_files':len(records),'body_equal_files':sum(r.get('body_same_after_type_resolution',False) for r in records),'remaining_files':remaining};(OUT/'wat-audit.json').write_text(json.dumps(report,indent=2)+'\n');print('files',len(records),'body equal',report['body_equal_files'],'remaining',len(remaining));print('\n'.join(remaining))
