#!/usr/bin/env python3
"""Compare JSON workloads with scalar-loop versus WasmGC array.copy Array growth."""

from __future__ import annotations

import argparse
import fcntl
import importlib.util
import json
import os
import platform
import statistics
import subprocess
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator

ROOT=Path(__file__).resolve().parents[1]
TMP=ROOT/".tmp"/"json-array-copy-benchmark"
RUNTIME=ROOT/"src/backend/starshine_array_runtime.mbt"
LOCK=ROOT/".tmp"/"array-growth-benchmark.lock"
COPY='''  grow.push(starshine_array_local_get(backing_local))
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  grow.push(starshine_match_cast(array_type))
  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  append_starshine_instructions(
    grow,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  grow.push(
    @lib.Instruction::array_copy(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )'''
LOOP='''  grow.push(@lib.Instruction::i32_const(@lib.I32::new(0)))
  grow.push(starshine_array_local_set(index_local))
  let copy_loop : Array[@lib.Instruction] = [
    starshine_array_local_get(index_local),
  ]
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 1),
  )
  copy_loop.push(@lib.Instruction::i32_ge_u())
  copy_loop.push(@lib.Instruction::br_if(@lib.LabelIdx::new(1U)))
  copy_loop.push(starshine_array_local_get(backing_local))
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  append_starshine_instructions(
    copy_loop,
    starshine_array_wrapper_field(wrapper_type, wrapper_local, 0),
  )
  copy_loop.push(starshine_match_cast(array_type))
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(
    @lib.Instruction::array_get(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(
    @lib.Instruction::array_set(
      @lib.TypeIdx::new(array_type.reinterpret_as_uint()),
    ),
  )
  copy_loop.push(starshine_array_local_get(index_local))
  copy_loop.push(@lib.Instruction::i32_const(@lib.I32::new(1)))
  copy_loop.push(@lib.Instruction::i32_add())
  copy_loop.push(starshine_array_local_set(index_local))
  copy_loop.push(@lib.Instruction::br(@lib.LabelIdx::new(0U)))
  grow.push(
    @lib.Instruction::block(
      @lib.BlockType::void_(),
      @lib.Expr::new([
        @lib.Instruction::loop_(
          @lib.BlockType::void_(),
          @lib.Expr::new(copy_loop),
        ),
      ]),
    ),
  )'''
OPS=("parse_string","parse_retained","validate_json","stringify","roundtrip","canonical_roundtrip")

def load_comp()->Any:
 p=ROOT/"tools/benchmark-json-comparison.py";s=importlib.util.spec_from_file_location("c",p)
 if s is None or s.loader is None:raise RuntimeError(p)
 m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m

def run(c:list[str],capture=False,env=None):return subprocess.run(c,cwd=ROOT,check=True,text=True,capture_output=capture,env=env)

@contextmanager
def backend_variant_lock() -> Iterator[None]:
 LOCK.parent.mkdir(parents=True,exist_ok=True)
 with LOCK.open("w",encoding="utf-8") as lock:
  fcntl.flock(lock.fileno(),fcntl.LOCK_EX)
  try: yield
  finally: fcntl.flock(lock.fileno(),fcntl.LOCK_UN)

def main():
 a=argparse.ArgumentParser();a.add_argument('--json-as-dir',type=Path,default=ROOT/'.tmp/json-as');a.add_argument('--samples',type=int,default=101);a.add_argument('--rounds',type=int,default=5);a.add_argument('--target-batch-bytes',type=int,default=262144);a.add_argument('--output',type=Path);x=a.parse_args();comp=load_comp();specs=[];env={**os.environ,'DEW_BUILD_CACHE':'0','DEW_PARSE_EVENT_CACHE':'0','DEW_INTERFACE_CACHE':'0','DEW_BODY_CACHE':'0'}
 with backend_variant_lock():
  original=RUNTIME.read_text()
  if original.count(COPY)!=1:raise RuntimeError('expected copy block')
  try:
   for variant in ('copy','loop'):
    if variant=='loop':RUNTIME.write_text(original.replace(COPY,LOOP))
    for name in ('small','medium','large'):
     doc=comp.extract_json_as_fixture(x.json_as_dir.resolve(),name);q=TMP/name;q.mkdir(parents=True,exist_ok=True);src=q/'benchmark.dew';src.write_text(comp.dew_source(doc));wasm=q/f'{variant}.wasm';run([str(ROOT/'tools/dew'),'build',str(src),'-o',str(wasm)],True,env);s=next((v for v in specs if v['name']==name),None)
     if s is None:s={'name':name,'bytes':len(doc.encode()),'rootSize':comp.fixture_root_size(doc),'variants':{},'sizes':{}};specs.append(s)
     s['variants'][variant]=str(wasm);s['sizes'][variant]=wasm.stat().st_size
  finally:RUNTIME.write_text(original)
 p=TMP/'specs.json';p.write_text(json.dumps(specs));js=r'''const fs=require('fs'),{performance}=require('perf_hooks');(async()=>{let ss=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],ops=[['parse_string',s=>s.rootSize],['parse_retained',s=>s.rootSize],['validate_json',s=>s.rootSize],['stringify',s=>s.bytes],['roundtrip',s=>s.bytes],['canonical_roundtrip',s=>s.bytes]],out={};for(let s of ss){let ins={};for(let v of ['loop','copy'])ins[v]=(await WebAssembly.instantiate(fs.readFileSync(s.variants[v]),{})).instance;let b=Math.max(1,Math.min(5000,Math.floor(target/s.bytes)));for(let [op,e] of ops)for(let v of ['loop','copy'])for(let w=0;w<30;w++)if(ins[v].exports[op](b)!==e(s)*b)throw Error('bad');out[s.name]={rounds:[]};for(let r=0;r<rounds;r++){let row={};for(let [op] of ops)row[op]={loop:[],copy:[]};for(let n=0;n<samples;n++)for(let oi=0;oi<ops.length;oi++){let [op,e]=ops[(n+r+oi)%ops.length],order=(n+r)%2?['copy','loop']:['loop','copy'];for(let v of order){let t=performance.now(),z=ins[v].exports[op](b),ns=(performance.now()-t)*1e6/b;if(z!==e(s)*b)throw Error('bad');row[op][v].push(ns)}}out[s.name].rounds.push(row)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})''';raw=json.loads(run(['node','-e',js,str(p),str(x.samples),str(x.rounds),str(x.target_batch_bytes)],True).stdout);fixtures={}
 for s in specs:
  od={}
  for op in OPS:
   ls=[];cs=[];ds=[]
   for r in raw[s['name']]['rounds']:
    l=statistics.median(r[op]['loop']);c=statistics.median(r[op]['copy']);ls.append(l);cs.append(c);ds.append((c/l-1)*100)
   od[op]={'loop_ns_per_op':round(statistics.median(ls),2),'copy_ns_per_op':round(statistics.median(cs),2),'delta_percent':round(statistics.median(ds),2),'round_deltas_percent':[round(value,2) for value in ds]}
  fixtures[s['name']]={'wasm_bytes':s['sizes'],'operations':od}
 report={'environment':{'platform':platform.platform(),'node':run(['node','--version'],True).stdout.strip()},'methodology':{'samples_per_round':x.samples,'rounds':x.rounds,'warmups':30,'negative_delta_is_faster':True},'fixtures':fixtures};enc=json.dumps(report,indent=2,sort_keys=True)+'\n'
 if x.output:x.output.parent.mkdir(parents=True,exist_ok=True);x.output.write_text(enc)
 print(enc,end='')
if __name__=='__main__':main()
