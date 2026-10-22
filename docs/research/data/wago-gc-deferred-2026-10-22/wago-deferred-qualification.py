from pathlib import Path
import subprocess,os
r=Path('/tmp/wago-gc-deferred-20261022');e=Path('/tmp/wago-gc-deferred-evidence')
env=dict(os.environ,GOCACHE='/tmp/wago-pr980-go-cache',GOWORK='off',GOMAXPROCS='4')
subprocess.run(['python3','/tmp/wago-deferred-run.py','gc-final-race-after-layout','go','test','-race','-count=1','-tags','wago_gc_workers wago_gc_concurrent wagodebug','-run','TestConcurrent|TestParallel|TestBackground|TestImmixLargeReuseFailure','./src/core/runtime/gc/native'],cwd=r,env=env,check=True)
subprocess.run(['python3','/tmp/wago-deferred-run.py','gc-final-concurrent-artifact-gates',str(e/'wago-concurrent-regalloc.test'),'-test.run=TestCompiledGenericGCArtifactRejectsNativeABIMismatch|TestGCConcurrent','-test.count=1','-test.timeout=30s'],cwd=r/'src/wago',env=env,check=True)
for version,round in [('control','q1'),('final','q1'),('final','q2'),('control','q2'),('control','q3'),('final','q3')]:
 print('START QUALIFICATION',version,round,flush=True)
 subprocess.run(['python3','/tmp/wago-deferred-final-measure.py',version,round],cwd='/home/dev/Projects/dewdrop',check=True)
