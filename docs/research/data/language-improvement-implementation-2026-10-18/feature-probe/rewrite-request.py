"""Rewrite only header/modules; preserve the fresh bootstrap request tail verbatim."""
from pathlib import Path
import struct,json,hashlib,sys
class Reader:
 def __init__(self,data):self.data=data;self.offset=0
 def u32(self):
  assert self.offset+4<=len(self.data)
  n=struct.unpack_from('<I',self.data,self.offset)[0];self.offset+=4;return n
 def bytes(self):
  n=self.u32();assert self.offset+n<=len(self.data)
  s=self.data[self.offset:self.offset+n];self.offset+=n;return s
 def string(self):return self.bytes().decode('utf-8')
def u32(n):return struct.pack('<I',n)
def blob(s):return u32(len(s))+s
def string(s):return blob(s.encode('utf-8'))
def decode(data):
 r=Reader(data)
 magic,version,command,kind,response=[r.u32() for _ in range(5)]
 assert magic==0x44574352 and version==1
 output=r.string() if response else None
 root=r.string();modules=[]
 for _ in range(r.u32()):
  name=r.string();files=[]
  for _ in range(r.u32()):files.append((r.string(),r.bytes()))
  modules.append((name,files))
 return dict(magic=magic,version=version,command=command,kind=kind,response=response,output=output,root=root,modules=modules,tail=data[r.offset:])
def imports(name):
 if name=='dew.std.option':return b'open dew.std.preamble\n'
 if name in ['dew.std.result','dew.std.text_runtime']:return b'open dew.std.preamble\nopen dew.std.option\n'
 if name in ['dew.std.string','dew.std.string_builder','dew.std.bytes_builder','dew.std.bytes']:
  return b'open dew.std.preamble\nopen dew.std.text_runtime\nopen dew.std.option\n'
 return b'open dew.std.preamble\nopen dew.std.option\nopen dew.std.result\n'
def build(template,directory):
 data=Path(template).read_bytes();request=decode(data);directory=Path(directory);directory.mkdir(parents=True,exist_ok=True)
 standard=[(n,f) for n,f in request['modules'] if n.startswith('dew.std.')]
 for name,path in [('dew.std.text','std/text.dew'),('dew.std.iter','std/iter.dew')]:
  if not any(n==name for n,_ in standard):
   standard.append((name,[('__dew_std_imports.dew',imports(name)),(path,Path(path).read_bytes())]))
 for label,source in [('positive','main.dew'),('negative','invalid.dew')]:
  output=directory/(label+'-c.wasm')
  modules=standard+[('probe.vault',[('vault.dew',(directory/'vault.dew').read_bytes())]),('probe.main',[(source,(directory/source).read_bytes())])]
  result=b''.join(u32(x) for x in [request['magic'],1,1,0,1])+string(output.name)+string('probe.main')+u32(len(modules))
  for name,files in modules:
   result+=string(name)+u32(len(files))
   for path,payload in files:result+=string(path)+blob(payload)
  result+=request['tail']
  encoded=directory/(label+'-request.bin');encoded.write_bytes(result)
  check=decode(result)
  assert check['tail']==request['tail']
  assert len(check['modules'])==len(modules) and check['root']=='probe.main'
  (directory/(label+'-request.json')).write_text(json.dumps(dict(template=str(template),template_sha256=hashlib.sha256(data).hexdigest(),request_sha256=hashlib.sha256(result).hexdigest(),tail_sha256=hashlib.sha256(request['tail']).hexdigest(),output=str(output),modules=[{'name':name,'files':[{'path':p,'source_sha256':hashlib.sha256(s).hexdigest(),'bytes':len(s)} for p,s in files]} for name,files in modules]),indent=2)+'\n')
  print(label,len(result),'bytes',len(modules),'modules')
if __name__=='__main__':build(sys.argv[1],sys.argv[2])
