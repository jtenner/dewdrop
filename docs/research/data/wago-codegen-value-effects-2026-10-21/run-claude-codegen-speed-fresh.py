from pathlib import Path
import json, os, subprocess, time

root = Path('/home/dev/Projects/dewdrop')
out = root/'.tmp/wago-next-gc-perf/claude-codegen-speed-fresh'
out.mkdir(exist_ok=False)
prompt = 'Fresh independent research only of Wago AMD64 GC code generation. Read/Grep/Glob only. Do not edit, build, test, benchmark, use network or start agents. Finish within 36 turns and 1600 words. User explicitly asks Astra and Claude for another look: they believe generated GC code is too slow and authorize extra compilation time and compiler memory for faster GC execution, while asking to keep peak RSS low. Find substantive algorithmic codegen improvements, not another tiny peephole. Current installed combined branch is /home/dev/Projects/dewdrop/.tmp/wago-local-stack-2026-10-20/wago at40cfab8d8ec32ca3eff1cd178fa746cb2eeb82b0. Only an unrelated existing ARM64 call.go edit is dirty; preserve it. Read current source afresh first; then consult docs. Source src/core/compiler/backend/railshot/amd64/{gc_read_region.go,gc_direct.go,gc_test_field.go,gc_resolver.go,gc_struct.go,call.go,inline.go,compile.go,driver.go}, optimization and runtime/gc/native as needed. Latest bounded read-region pass is already installed and reduced full fixed Dewdrop compilation median35.439423 to34.424798s (2.863%), ordinary/pressure microkernels~11%, native bytes+4.51%. It expands <=192byte helper bodies,<=2 nestedifs,8 GC groups,16regions/caller; those conservative admission bounds are not a user requirement. Assess better analysis/IR/loop optimizations/effect summaries/provenance/scalar replacement rather than assuming only tiny bounded passes are possible. Read /home/dev/Projects/dewdrop/docs/research/wago-read-regions-2026-10-21.md for evidence; /home/dev/Projects/dewdrop/docs/research/wago-fresh-whole-gc-audit-2026-10-21.md includes older073 profile80.25% generated code12.77% minorGC (not causal GC-opcode attribution). Root is collecting a new exact-head diagnostic profile. Known V8 is4s; do not rerun V8. Keep the exact pinned compiler Wasm/request unchanged; application algorithm edits are a separate question. Maintain stable-handle GC design, exact roots, host/reentry/foreign/malformed metadata safety and trap order. Current installed numericinline,forwarders,reference-registerABI,test-first-field fusion,native arrays,allocation batching and wrapper address reuse already exist. Held getter inline~29%kernel butflatwholejob; positive final-typefacts0.35%flat; warmhandle recycling319%slower/canonical12%slower/per-callsite stubs4.7%slower. Previous Claude proposed fresh constructor provenance to omit repeated reference-field checks; validate whether that is actually implementable/useful and consider independent alternatives. Deliver ranked3-5 changes: exact path/function and eliminated repeated work, likely coverage in this pinned workload, compile-time/memory/code-size/runtime cost, proof obligations/invalidations and smallest static/dynamic measurement to accept or reject it. Pick one top next experiment, with conservative first implementation and a stronger follow-on if useful. Distinguish measured facts, source facts and inference; no speed guarantees. Avoid changes keyed on names/indices/module paths. Return the report, do not save it yourself.'
cmd = ['claude','-p','--model','opus','--effort','high','--permission-mode','plan',
       '--permission-prompts','none','--tools','Read,Glob,Grep','--allowedTools','Read,Glob,Grep',
       '--strict-mcp-config','--mcp-config','{"mcpServers":{}}','--output-format','stream-json',
       '--verbose','--max-budget-usd','5','--max-turns','38',prompt]
(out/'request.json').write_text(json.dumps(dict(command=cmd, role='independent hot algorithm research'),indent=2)+'\n')
start=time.monotonic()
with (out/'events.jsonl').open('w') as stdout, (out/'stderr.log').open('w') as stderr:
    run=subprocess.run(cmd,cwd=root,stdout=stdout,stderr=stderr,env=os.environ)
result=None
for line in (out/'events.jsonl').read_text().splitlines():
    row=json.loads(line)
    if row.get('type')=='result': result=row
(out/'run.json').write_text(json.dumps(dict(seconds=time.monotonic()-start,exit=run.returncode,result=result),indent=2)+'\n')
if result:
    (out/'report.md').write_text(result.get('result','')+'\n')
print(json.dumps(dict(seconds=time.monotonic()-start,exit=run.returncode,result_type=result.get('subtype') if result else None)),flush=True)
