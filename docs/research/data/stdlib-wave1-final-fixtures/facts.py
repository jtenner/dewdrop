"""Decode the complete v1 record using the pinned encoder's field order.
Field schemas are read from Encode implementations; unknown forms fail loudly.
"""
import re,json,gzip,subprocess
from pathlib import Path
D=Path(__file__).resolve().parent
source=Path('starshine-mb/src/binary/compiler_facts_encode.mbt').read_text()
blocks=dict(re.findall(r'pub impl Encode for (\w+) with fn encode\(value, buf\) \{(.*?)(?=\n///\||\Z)',source,re.S))
# Field types from the representation's declared structs.
texts='\n'.join(p.read_text() for p in Path('starshine-mb/src').rglob('*.mbt') if 'representation' in str(p))
structs={}
for name,body in re.findall(r'(?:pub\([^)]*\) |pub )?struct (\w+)\s*\{([^}]+)\}',texts):
 structs[name]=dict(re.findall(r'(\w+)\s*:\s*([^\n]+)',body))
class Decoder:
 def __init__(self,b):self.b=b;self.p=0;self.fields={}
 def uint(self):
  n=s=0
  while True:
   b=self.b[self.p];self.p+=1;n|=(b&127)<<s;s+=7
   if b<128:return n
 def get(self,t,path='root'):
  t=t.strip().replace('@representation.','')
  start=self.p
  if t.endswith('?'):
   tag=self.uint();assert tag in (0,1);v=self.get(t[:-1],path) if tag else None
  elif t.startswith('Array['):v=[self.get(t[6:-1],path+f'[{i}]') for i in range(self.uint())]
  elif t in ('UInt32','UInt64','Int64','Bool'):v=self.uint()
  elif t=='String':n=self.uint();v=self.b[self.p:self.p+n].decode();self.p+=n
  elif t in ('ClosedFunctionSet','ClosedGlobalSet','ClosedMemorySet','ClosedTableSet','ClosedTypeViewSet'):v=self.get('Array[UInt32]',path)
  elif t in ('EffectMask','ParameterUseMask','EscapeSinkMask','FloatClassMask'):v=self.uint()
  elif t in ('WorldMode','IntWidth','FloatWidth','NullabilityFacts','VectorLaneShape','TemperatureHint','InlinePolicy','MutationPhase','RelationKind','OptimizationGoal'):v=self.uint()
  elif t=='FactHeapType':
   tag=self.uint();v={'tag':tag};assert tag<=15
   if tag==0:v['type_index']=self.get('UInt32',path+'.type_index')
  elif t=='HeapDomain':
   tag=self.uint();assert tag<=2;v={'tag':tag,'value':self.get('Array[FactHeapType]' if tag==2 else 'FactHeapType',path+'.heap')}
  elif t=='FactValue':
   tag=self.uint();ts=['IntConstant','UInt32','UInt64','V128Bits','FactHeapType','UInt32','UInt32'];v={'tag':tag,'value':self.get(ts[tag],path+'.value')}
  elif t=='ResultIdentityFacts':
   tag=self.uint();assert tag in (0,1);v={'tag':tag}
   if tag:v['aliases']=self.get('Array[AliasSource]',path+'.aliases')
  elif t=='AliasSource':
   tag=self.uint();v={'tag':tag,'value':self.get(['UInt32','UInt32','ValueSite'][tag],path+'.alias')}
  elif t=='ValueRef':
   tag=self.uint();v={'tag':tag,'value':self.get(['ValueSite','ParameterRef','FunctionResultRef','UInt32'][tag],path+'.value')}
  elif t=='ClosedValueSet':v=self.get('Array[FactValue]',path)
  elif t=='WriteFacts':
   tag=self.uint();assert tag<=2;v={'tag':tag}
   if tag==2:v['sites']=self.get('Array[CodeSite]',path+'.sites')
  elif t=='TypePopulation':
   tag=self.uint();assert tag<=1;v={'tag':tag}
   if tag:v['types']=self.get('Array[FactHeapType]',path+'.types')
  elif t=='TypeView':
   tag=self.uint();assert tag in (0,1);v={'tag':tag,'type_index':self.get('UInt32',path+'.type_index')}
  elif t=='AllocationKind':v={'tag':self.uint(),'type_index':self.get('UInt32',path+'.type_index')}
  elif t in structs and t in blocks:
   fields=re.findall(r'(?:value\.(\w+))',blocks[t]);order=list(dict.fromkeys(fields))
   assert set(order)==set(structs[t]),(t,order,structs[t])
   v={f:self.get(structs[t][f],path+'.'+f) for f in order}
  elif t=='CompilerFactCustomSection':v={'version':self.get('UInt32',path+'.version'),'module_fingerprint':self.get('UInt64?',path+'.module_fingerprint'),'facts':self.get('OptimizationFactsSec',path+'.facts')}
  else:raise AssertionError((t,path,self.p))
  self.fields[path]=(start,self.p,v)
  return v

def payload(text):
 s=text.splitlines()[1].split('(before first) "')[1][:-2]
 return re.sub(r'\\([0-9a-f]{2})',lambda m:chr(int(m[1],16)),s).encode('latin1')
results=[]
for r in json.loads((D/'review.json').read_text()):
 old=subprocess.check_output(['git','show','1caf8f48:'+r['fixture']]).decode();new=gzip.decompress((D/(Path(r['fixture']).stem+'.new.wat.gz')).read_bytes()).decode()
 ds=[]
 for text in (old,new):
  d=Decoder(payload(text));value=d.get('CompilerFactCustomSection');assert d.p==len(d.b),(d.p,len(d.b));ds.append(d)
  (D/(Path(r['fixture']).stem+('.old' if len(ds)==1 else '.new')+'.facts.json.gz')).write_bytes(gzip.compress(json.dumps(value,sort_keys=True,indent=2).encode(),mtime=0))
 changes=[]
 assert ds[0].fields.keys()==ds[1].fields.keys()
 for p,(a,b,v) in ds[0].fields.items():
  w=ds[1].fields[p][2]
  if v!=w and not isinstance(v,(dict,list)):
   changes.append({'field':p,'old':v,'new':w,'offset':a})
 for c in changes:
  if 'iter-combinators' in r['fixture']:
   assert c['field'].endswith(('.signature','.type_index')) and c['new']==c['old']+3,c
  else:
   assert '.provenance.' in c['field'],c
   assert c['new']-c['old']==(2214 if c['field'].endswith('.source_offset') else 5),c
 results.append({'fixture':r['fixture'],'decoded_bytes':[d.p for d in ds],'changes':changes})
(D/'facts.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
