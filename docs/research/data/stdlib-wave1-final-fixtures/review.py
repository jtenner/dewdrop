#!/usr/bin/env python3
"""Extract full diffs with strict hunk counts and replay only checked lines."""
import gzip, hashlib, json, re, subprocess
from pathlib import Path
D=Path(__file__).resolve().parent
log=gzip.decompress((D/'before.log.gz').read_bytes()).decode().splitlines(True)
results=[]
i=0
while i<len(log):
 if not log[i].startswith('--- tests/module-snapshots/'):
  i+=1;continue
 lines=log[i:i+2]; fixture=lines[0][4:].strip();i+=2
 while i<len(log) and log[i].startswith('@@ '):
  header=log[i];lines.append(header);i+=1
  m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',header);assert m
  a,b=int(m[2] or 1),int(m[4] or 1)
  while a or b:
   s=log[i];i+=1
   # Timing lines are emitted by other jobs; they are never diff content.
   if s.startswith('snapshot compile timing:'):continue
   assert s[0] in ' +-',(fixture,s)
   lines.append(s)
   if s[0] in ' -':a-=1
   if s[0] in ' +':b-=1
   assert a>=0 and b>=0
  while i<len(log) and log[i].startswith('snapshot compile timing:'):i+=1
 diff=''.join(lines);old=subprocess.check_output(['git','show','1caf8f48:'+fixture]).decode();oldlines=old.splitlines(True)
 new=[];pos=0;k=2;hunks=0
 while k<len(lines):
  m=re.match(r'@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@',lines[k]);assert m
  start=int(m[1])-1;new+=oldlines[pos:start];pos=start;k+=1;a=b=0
  while a<int(m[2] or 1) or b<int(m[4] or 1):
   s=lines[k];k+=1
   if s[0] in ' -':assert oldlines[pos]==s[1:];pos+=1;a+=1
   if s[0] in ' +':new.append(s[1:]);b+=1
  hunks+=1
 new+=''.join(oldlines[pos:]).splitlines(True);new=''.join(new)
 stem=Path(fixture).stem
 (D/(stem+'.diff.gz')).write_bytes(gzip.compress(diff.encode(),mtime=0))
 (D/(stem+'.new.wat.gz')).write_bytes(gzip.compress(new.encode(),mtime=0))
 record={'fixture':fixture,'hunks':hunks}
 for label,value in [('old',old),('new',new),('diff',diff)]:record[label+'_sha256']=hashlib.sha256(value.encode()).hexdigest();record[label+'_lines']=len(value.splitlines())
 # Inspect complete custom section bytes, including printable bytes and escapes.
 def payload(t):
  s=t.splitlines()[1].split('(before first) "')[1][:-2]
  return re.sub(r'\\([0-9a-f]{2})',lambda m:chr(int(m[1],16)),s).encode('latin1')
 x,y=payload(old),payload(new)
 changes=[]
 import difflib
 for tag,a,b,c,d in difflib.SequenceMatcher(None,x,y,autojunk=False).get_opcodes():
  if tag!='equal':changes.append({'old_offset':a,'new_offset':c,'old_hex':x[a:b].hex(),'new_hex':y[c:d].hex()})
 record['facts_bytes']=[len(x),len(y)];record['facts_changes']=changes
 if stem!='iter-combinators-runtime':
  assert old.splitlines()[2:]==new.splitlines()[2:]
 else:
  def tm(n):return n+2 if 72<=n<75 else n+3 if n>=75 else n
  def conv(t):
   t=re.sub(r'\(;(\d+);\)',lambda m:f'(;{tm(int(m[1]))};)',t,count=1) if t.startswith('  (type') else t
   return re.sub(r'(\(type |\(ref |\(ref null |\bstruct.new |\bstruct.get |\bstruct.set |\barray.new_fixed |\bcall_ref )(\d+)',lambda m:m[1]+str(tm(int(m[2]))),t)
  def funcs(t):return {int(m[1]):m[0] for m in re.finditer(r'^  \(func \(;(\d+);\).*?(?=^  \(func|^\)$)',t,re.M|re.S)}
  of,nf=funcs(old),funcs(new);assert of.keys()==nf.keys()
  for n,body in of.items():assert conv(body)==nf[n],n
  record['exact_mapped_function_bodies']=len(of)
  oldtypes={int(re.search(r'\(;(\d+);\)',s)[1]):s for s in old.splitlines(True) if re.match(r'  \(type \(;',s)};newtypes={int(re.search(r'\(;(\d+);\)',s)[1]):s for s in new.splitlines(True) if re.match(r'  \(type \(;',s)}
  for n,t in oldtypes.items():assert conv(t)==newtypes[tm(n)],(n,t,newtypes[tm(n)])
  record['added_types']=[t.strip() for n,t in newtypes.items() if n not in {tm(k) for k in oldtypes}]
  # Every non-facts/non-type line is checked, not just function bodies.
  assert conv("".join(s for s in old.splitlines(True)[2:] if not s.startswith("  (type")))=="".join(s for s in new.splitlines(True)[2:] if not s.startswith("  (type"))
 results.append(record)
(D/'review.json').write_text(json.dumps(results,indent=2)+'\n')
print(json.dumps(results,indent=2))
