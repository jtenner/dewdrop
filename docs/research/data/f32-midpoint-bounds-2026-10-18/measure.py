from pathlib import Path
import subprocess,time,json,platform,hashlib,sys
root=Path(sys.argv[1])
harness=Path(__file__).with_name('measure.mjs')
records=[]
for count in [1024,4096,16384,65536]:
 for sample in range(3):
  for identity in ['before','after']:
   command=['node','--no-liftoff','--expose-gc',str(harness),str(root/(identity+'.wasm')),str(count)]
   start=time.monotonic();r=subprocess.run(command,text=True,capture_output=True,timeout=20)
   if r.returncode:raise RuntimeError((command,r.stdout,r.stderr))
   result=dict(identity=identity,sample=sample,wallSeconds=time.monotonic()-start,**json.loads(r.stdout))
   records.append(result);print(json.dumps(result),flush=True)
report=dict(node=subprocess.check_output(['node','--version'],text=True).strip(),environment=platform.platform(),architecture=platform.machine(),fixtures={i:hashlib.sha256((root/(i+'.wasm')).read_bytes()).hexdigest() for i in ['before','after']},samples=records)
(root/'samples.json').write_text(json.dumps(report,indent=2)+'\n')
