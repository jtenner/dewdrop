from pathlib import Path
import subprocess,os,shutil
r=Path('/tmp/wago-pr997-root-faults-20261022');e=Path('/tmp/wago-pr997-root-faults-evidence');go='/home/dev/.local/share/mise/installs/go/1.27.1/bin/go'
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOMAXPROCS='2',DOTNET_SYSTEM_GLOBALIZATION_INVARIANT='1',WAGO_SPEC_INTERPRETER='/home/dev/Projects/wago/.tools/spec-interpreter-9d36019973201a19f9c9ebb0f10828b2fe2374aa/wasm',WAGO_SPEC_INTERPRETER_REVISION='9d36019973201a19f9c9ebb0f10828b2fe2374aa')
env.pop('GOWORK',None)
env['PATH']='/home/dev/.local/share/mise/installs/powershell/7.5.4:/home/dev/.local/share/mise/installs/go/1.27.1/bin:/home/dev/Projects/wago/.tools/wabt-1.0.41-linux-x64/bin:/home/dev/.local/share/mise/installs/wasm-tools/1.251.0/bin:/home/dev/.local/share/mise/installs/node/24.21.0/bin:'+env['PATH']
def run(label,args,cwd=r):
 print('START',label,flush=True);subprocess.run(['python3',str(e/'measure.py'),label,*map(str,args)],cwd=cwd,env=env,check=True)

baseline=Path('/tmp/wago-pr997-main-sync-20261022')
fixture=(r/'src/wago/gc_foreign_frame_roots_test.go').read_text().split('func TestGCScalarAdapterCallerOwnership')[0]
fixture += '\nfunc BenchmarkGCScalarRelayCompile(b *testing.B) {\n data := gcScalarAdapterCallerModule("direct", false, false)\n cfg := NewRuntimeConfig().WithCoreFeatures(CoreFeaturesV3)\n once, err := Compile(cfg, data)\n if err != nil { b.Fatal(err) }\n blob, err := once.MarshalBinary()\n if err != nil { b.Fatal(err) }\n b.ReportMetric(float64(len(blob)), "artifact-B")\n once.Close()\n b.ReportAllocs()\n b.ResetTimer()\n for i := 0; i < b.N; i++ {\n  c, err := Compile(cfg, data)\n  if err != nil { b.Fatal(err) }\n  b.ReportMetric(float64(c.CodeSize()), "native-B")\n  b.ReportMetric(float64(c.GCNativeRootAdmission().MetadataBytes), "return-map-B")\n  c.Close()\n }\n}\n'
paths=[]
try:
 for label,checkout in [('baseline',baseline),('candidate',r)]:
  temporary=checkout/'src/wago/zz_pr997_unwind_cost_test.go'
  # Candidate already owns the fixture helper.
  code=fixture if label=='baseline' else 'package wago\n\nimport \"testing\"\n\n'+fixture[fixture.index('func BenchmarkGCScalarRelayCompile'):]
  code=code.replace('\t"context"\n','').replace('\t"fmt"\n','')
  temporary.write_text(code);paths.append(temporary)
  run('bench-build-'+label,[go,'test','-p','2','-c','-o',e/(label+'.test'),'./src/wago'],checkout)
 for iteration in range(3):
  for label in (['baseline','candidate'] if iteration%2==0 else ['candidate','baseline']):
   run('bench-'+label+'-'+str(iteration),[e/(label+'.test'),'-test.run=^$','-test.bench=Benchmark(GCNativeFrameRootsMappedStack|GCExtern(LocalRoots|ForeignRoots)|GCScalarRelayCompile|HostRoundtripLoopCaller)$','-test.benchtime=200ms','-test.count=1'],(baseline if label=='baseline' else r)/'src/wago')
finally:
 for path in paths: path.unlink(missing_ok=True)
