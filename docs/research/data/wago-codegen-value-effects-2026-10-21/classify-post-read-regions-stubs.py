from pathlib import Path
import json,collections,bisect
r=Path('/home/dev/Projects/dewdrop/.tmp/wago-next-gc-perf/post-read-regions-profile');raw=json.loads((r/'stub-attribution/ranges.json').read_text());regions=json.loads((r/'profile/code-map.json').read_text())['images'][0]['regions'];samples=json.loads((r/'profile/resolved-samples.json').read_text());bases={};names={}
for region in regions:
 if region['kind'] not in ['entry-adapter','guest-body']:continue
 f=region.get('function',0);bases[f]=min(bases.get(f,region['offset']),region['offset']);names[f]=region.get('name','')
lookup=collections.defaultdict(list)
for row in raw:
 f=row['Function'];assert f in bases,f
 row=dict(row,AbsoluteStart=bases[f]+row['Start'],AbsoluteEnd=bases[f]+row['End']);lookup[f].append(row)
counts=collections.Counter();where=collections.Counter();classified=[]
priority={'type-test':0,'type-test-first-field':0,'type-cast':0,'emitNativeStructAlloc':1}
for s in samples:
 f=(s.get('region') or {}).get('function',0);pc=s['offset'];matches=[x for x in lookup[f] if x['AbsoluteStart']<=pc<x['AbsoluteEnd']]
 match=min(matches,key=lambda x:(x['End']-x['Start'],priority.get(x['Kind'],9))) if matches else None
 kind=match['Kind'] if match else 'other-generated-code';counts[kind]+=1;where[(f,kind)]+=1;classified.append(dict(s,stub=match))
report=dict(note='Native byte identity confirmed. Metadata-only compilation maps per-function emitted stub ranges onto existing diagnostic samples. These are leaf-PC locations, not dynamic execution counts or measured removable time.',native_samples=len(samples),counts=[dict(kind=k,samples=n,share=n/len(samples)) for k,n in counts.most_common()],functions=[dict(function=f,name=names.get(f,''),kind=k,samples=n) for (f,k),n in where.most_common(40)])
(r/'stub-attribution/classification.json').write_text(json.dumps(report,indent=2));(r/'stub-attribution/classified-samples.json').write_text(json.dumps(classified));(r/'stub-attribution/absolute-ranges.json').write_text(json.dumps([x for rows in lookup.values() for x in rows]));print(json.dumps(report,indent=2)[:6500])
