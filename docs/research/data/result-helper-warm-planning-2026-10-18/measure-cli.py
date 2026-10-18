#!/usr/bin/env python3
import hashlib,json,os,pathlib,statistics,subprocess,time
work=pathlib.Path(__file__).resolve().parent
root=pathlib.Path.cwd()
records=[]
def run(variant, phase, iteration):
 env=os.environ.copy()
 env.update(DEW_CACHE_DIR=str(work/variant/"cache"),DEW_COMPILER_FINGERPRINT="cli-"+hashlib.sha256((work/"dew_cli.exe").read_bytes()).hexdigest(),DEW_PARSE_EVENT_CACHE="1",DEW_INTERFACE_CACHE="0",DEW_BODY_CACHE="0",DEW_BODY_FAMILY_CACHE="0",DEW_PLAN_CACHE="1",DEW_CACHE_PACK="1",DEW_PROGRAM_CACHE="0")
 cmd=[str(work/"dew_cli.exe"),"check","--std-root",str(work/variant),"--no-program-cache","--no-interface-cache","--no-body-cache","--plan-cache","--cache-report",str(work/"main.dew")]
 started=time.perf_counter_ns()
 result=subprocess.run(cmd,cwd=root,env=env,capture_output=True,text=True,timeout=30)
 elapsed=(time.perf_counter_ns()-started)/1e6
 rec=dict(variant=variant,phase=phase,iteration=iteration,elapsed_ms=elapsed,command=cmd,exit=result.returncode,stdout=result.stdout,stderr=result.stderr)
 records.append(rec)
 (work/"cli-raw.json").write_text(json.dumps(records,indent=2)+"\n")
 if result.returncode:raise RuntimeError(rec)
 expected="fragment hits 5, fragment misses 0" if variant=="old" else "fragment hits 4, fragment misses 0"
 if phase=="warm" and expected not in result.stdout:raise RuntimeError("warm cache status mismatch: "+str(rec))
 print(json.dumps({k:rec[k] for k in ["variant","phase","iteration","elapsed_ms","exit"]}),flush=True)
for variant in ["old","new"]:
 run(variant,"cold",0)
 for i in range(3):run(variant,"warmup",i)
for i in range(21):
 for variant in (["old","new"] if i%2==0 else ["new","old"]):run(variant,"warm",i)
summary={}
for variant in ["old","new"]:
 values=[r["elapsed_ms"] for r in records if r["variant"]==variant and r["phase"]=="warm"]
 files=[p for p in (work/variant/"cache").rglob("*") if p.is_file()]
 summary[variant]=dict(median_ms=statistics.median(values),mean_ms=statistics.mean(values),stdev_ms=statistics.stdev(values),min_ms=min(values),max_ms=max(values),samples=values,cache_bytes=sum(p.stat().st_size for p in files),cache_files=len(files))
(work/"cli-summary.json").write_text(json.dumps(summary,indent=2)+"\n")
print(json.dumps(summary,indent=2),flush=True)
