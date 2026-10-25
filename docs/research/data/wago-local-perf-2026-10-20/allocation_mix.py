#!/usr/bin/env python3
"""Isolate struct-only and struct/array allocation in the installed Wago."""
import importlib.util
import json
import statistics
from pathlib import Path

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('measure',HERE/'measure.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
wasm=m.WORK/'allocation-mix.wasm'
artifact=m.WORK/'allocation-mix.wago'
m.measure('allocation-mix-parse',['wasm-tools','parse',HERE/'allocation-mix.wat','-o',wasm])
m.measure('allocation-mix-build',[m.INSTALLED,'build','--bare','--offline','--no-input','--output',artifact,wasm],cwd=m.WORK)
n=500000
rows=[]
for round_index in range(3):
    for export,expected in [('structs',n*(n-1)//2),('alternating',n*n)]:
        expected=((expected+2**31)%2**32)-2**31
        for batch in ([512,32] if round_index%2==0 else [32,512]):
            label=f'allocation-mix-{export}-batch{batch}-{round_index+1}'
            env=dict(m.ENV,WAGO_AMD64_GC_STRUCT_BATCH=str(batch))
            command=[m.INSTALLED,'run','--bare','--offline','--no-input','--allow-native-artifact','--gc-heap','512MiB','--gc-nursery','64MiB','--invoke',export,artifact,str(n)]
            row=m.measure(label,command,cwd=m.WORK,env=env)
            actual=(m.DATA/(label+'.log')).read_text().strip()
            assert actual==str(expected),(actual,expected)
            row.update(export=export,batch=batch,iterations=n,result=expected,artifact_sha256=m.digest(artifact))
            rows.append(row)
            (m.DATA/'allocation-mix-samples.json').write_text(json.dumps(rows,indent=2)+'\n')
summary=[]
for export in ['structs','alternating']:
    for batch in [512,32]:
        selected=[r for r in rows if (r['export'],r['batch'])==(export,batch)]
        summary.append(dict(export=export,batch=batch,median_seconds=statistics.median(r['seconds'] for r in selected),median_cpu_seconds=statistics.median(r['user_seconds']+r['system_seconds'] for r in selected)))
(m.DATA/'allocation-mix-summary.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
