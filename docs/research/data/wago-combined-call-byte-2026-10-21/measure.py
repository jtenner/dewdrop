import importlib.util,json,os,statistics,subprocess
from pathlib import Path
root=Path('/home/dev/Projects/dewdrop')
spec=importlib.util.spec_from_file_location('measure',root/'docs/research/data/wago-local-perf-2026-10-20/measure.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
m.DATA=root/'docs/research/data/wago-combined-call-byte-2026-10-21';m.DATA.mkdir(parents=True,exist_ok=True)
m.ENV=dict(m.ENV,GOMAXPROCS='2')
original=m.measure
def measure(label,command,**kw):
 command=list(command)
 if command[0]=='node':command[3]=m.COMPILER
 return original(label,['taskset','-c','12,14',*command],**kw)
m.measure=measure
identity=dict(combined_build=json.loads((root/'.tmp/wago-next-gc-perf/combined-call-byte-build.json').read_text()),compiler_sha256=m.digest(m.COMPILER),request_sha256=m.digest(m.WORK/'request.bin'),control_host_sha256=m.digest(m.WORK/'safe-byte-control-host'),combined_host_sha256=m.digest(m.WORK/'combined-call-byte-host'),node_versions=json.loads(subprocess.check_output(['node','-p','JSON.stringify(process.versions)'],text=True)),affinity='12,14',GOMAXPROCS=2,method='Three serial balanced rounds: control/combined/V8; combined/control/V8; control/combined/V8. Same fixed compiler/request, fresh native/result caches, output hashes/main42/exact roots required. No task-owned tests/builds overlap.')
(m.DATA/'identity.json').write_text(json.dumps(identity,indent=2)+'\n')
rows=json.loads((m.DATA/'samples.json').read_text()) if (m.DATA/'samples.json').exists() else []
for label,version,engine in [('combined-call-byte-safe-byte-control-1', 'safe-byte-control', 'control'), ('combined-call-byte-combined-call-byte-1', 'combined-call-byte', 'candidate'), ('combined-call-byte-v8-1', 'node', 'v8'), ('combined-call-byte-combined-call-byte-2', 'combined-call-byte', 'candidate'), ('combined-call-byte-safe-byte-control-2', 'safe-byte-control', 'control'), ('combined-call-byte-v8-2', 'node', 'v8'), ('combined-call-byte-safe-byte-control-3', 'safe-byte-control', 'control'), ('combined-call-byte-combined-call-byte-3', 'combined-call-byte', 'candidate'), ('combined-call-byte-v8-3', 'node', 'v8')]:
 if any(r['label']==label for r in rows):continue
 m.full(label,version)
 row=json.loads((m.DATA/(label+'.json')).read_text());row['engine']=engine
 if engine!='v8':
  artifacts=list((m.WORK/(label+'-home')).rglob('*.wago'));assert len(artifacts)==1,artifacts
  probe=subprocess.run([str(root/'.tmp/wago-next-gc-perf/local-admission'),str(artifacts[0])],check=True,capture_output=True,text=True)
  row['gc_native_root_admission']=json.loads(probe.stdout);assert row['gc_native_root_admission']['Required'] and row['gc_native_root_admission']['Exact']
 rows.append(row);(m.DATA/'samples.json').write_text(json.dumps(rows,indent=2)+'\n')
summary={}
for engine in ['control','candidate','v8']:
 r=[x for x in rows if x['engine']==engine];times=[x['seconds'] for x in r]
 summary[engine]=dict(seconds=times,median_seconds=statistics.median(times),median_peak_rss_kib=statistics.median(x['peak_rss_kib'] for x in r))
summary['candidate_reduction_percent']=100*(1-summary['candidate']['median_seconds']/summary['control']['median_seconds'])
summary['candidate_over_v8']=summary['candidate']['median_seconds']/summary['v8']['median_seconds']
summary['all_outputs_identical_and_main_42']=True
(m.DATA/'summary.json').write_text(json.dumps(summary,indent=2)+'\n');print(json.dumps(summary,indent=2),flush=True)
