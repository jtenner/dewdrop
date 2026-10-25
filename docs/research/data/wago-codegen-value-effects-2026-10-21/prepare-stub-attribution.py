from pathlib import Path
import json,re
r=Path('/home/dev/Projects/dewdrop/.tmp/wago-next-gc-perf/post-read-regions-profile');src=r/'source';out=r/'stub-attribution';out.mkdir(exist_ok=False);backend=src/'src/core/compiler/backend/railshot/amd64';old=(backend/'gc_direct.go').read_text()
pat=re.compile(r'func \(f \*fn\) (emitNative\w+)\([^\n]*\) (?:\([^\n]*\) )?\{')
names=[]
def change(m):
 name=m[1];names.append(name)
 return m[0]+f'\n diagnosticStart := f.a.Len(); defer func() {{ diagnosticRecordStub(uint32(f.globalIdx), "{name}", diagnosticStart, f.a.Len()) }}()\n'
new=pat.sub(change,old);assert len(names)>10,names
copy=out/'gc_direct.go';copy.write_text(new)
hook=out/'diagnostic.go';hook.write_text('''package amd64
import("sync";"encoding/json";"os")
type diagnosticStub struct { Function uint32; Kind string; Start,End int }
var diagnosticStubs struct { sync.Mutex; Rows []diagnosticStub }
func diagnosticRecordStub(f uint32,k string,s,e int){if e<=s{return}; diagnosticStubs.Lock();diagnosticStubs.Rows=append(diagnosticStubs.Rows,diagnosticStub{f,k,s,e});diagnosticStubs.Unlock()}
func SaveDiagnosticStubs(path string){ diagnosticStubs.Lock();defer diagnosticStubs.Unlock();b,e:=json.Marshal(diagnosticStubs.Rows);if e!=nil{panic(e)};if e=os.WriteFile(path,b,0600);e!=nil{panic(e)} }
''')
(out/'overlay.json').write_text(json.dumps({'Replace':{str(backend/'gc_direct.go'):str(copy),str(backend/'diagnostic_stub_attribution.go'):str(hook)}},indent=2))
p=r/'host-source/attribute-stubs';p.mkdir();(p/'main.go').write_text('''package main
import("os";"fmt";"time";"crypto/sha256";wago "github.com/wago-org/wago";"github.com/wago-org/wago/src/core/compiler/backend/railshot/amd64")
func main(){ b,e:=os.ReadFile(os.Args[1]);if e!=nil{panic(e)};t:=time.Now();c,e:=wago.Compile(wago.NewRuntimeConfig().WithCoreFeatures(wago.CoreFeaturesV3),b);if e!=nil{panic(e)};defer c.Close();h:=sha256.New();if _,e=c.WriteCodeTo(h);e!=nil{panic(e)};fmt.Printf("native_sha256=%x compile_seconds=%.6f roots=%+v\\n",h.Sum(nil),time.Since(t).Seconds(),c.GCNativeRootAdmission());amd64.SaveDiagnosticStubs(os.Args[2])}
''')
print('Diagnostic metadata hooks:',len(names),names)
