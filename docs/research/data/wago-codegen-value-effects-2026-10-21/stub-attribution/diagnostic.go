package amd64
import("sync";"encoding/json";"os")
type diagnosticStub struct { Function uint32; Kind string; Start,End int }
var diagnosticStubs struct { sync.Mutex; Rows []diagnosticStub }
func diagnosticRecordStub(f uint32,k string,s,e int){if e<=s{return}; diagnosticStubs.Lock();diagnosticStubs.Rows=append(diagnosticStubs.Rows,diagnosticStub{f,k,s,e});diagnosticStubs.Unlock()}
func SaveDiagnosticStubs(path string){ diagnosticStubs.Lock();defer diagnosticStubs.Unlock();b,e:=json.Marshal(diagnosticStubs.Rows);if e!=nil{panic(e)};if e=os.WriteFile(path,b,0600);e!=nil{panic(e)} }

func diagnosticTypeCheckKind(test,field bool)string {if field{return "type-test-first-field"};if test{return "type-test"};return "type-cast"}
