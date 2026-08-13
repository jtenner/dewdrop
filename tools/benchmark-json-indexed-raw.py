#!/usr/bin/env python3
"""Benchmark a generated root-level structural index over validated raw JSON."""

from __future__ import annotations

import argparse
import importlib.util
import json
import platform
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT=Path(__file__).resolve().parents[1]
TMP=ROOT/".tmp"/"json-indexed-raw"
FIXTURES=("small","medium","large")


def load_comparison()->Any:
 p=ROOT/"tools"/"benchmark-json-comparison.py";s=importlib.util.spec_from_file_location("comp",p)
 if s is None or s.loader is None: raise RuntimeError(p)
 m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m


def run(c:list[str],capture=False):return subprocess.run(c,cwd=ROOT,check=True,text=True,capture_output=capture)

def ws(d:bytes,i:int)->int:
 while i<len(d) and d[i] in b" \t\r\n":i+=1
 return i

def string_end(d:bytes,i:int)->int:
 assert d[i]==34;i+=1
 while True:
  if d[i]==34:return i+1
  i+=2 if d[i]==92 else 1

def value_end(d:bytes,i:int)->int:
 i=ws(d,i);b=d[i]
 if b==34:return string_end(d,i)
 if b in (91,123):
  stack=[93 if b==91 else 125];i+=1
  while stack:
   b=d[i]
   if b==34:i=string_end(d,i);continue
   if b==91:stack.append(93)
   elif b==123:stack.append(125)
   elif b==stack[-1]:stack.pop()
   i+=1
  return i
 while i<len(d) and d[i] not in b" \t\r\n,}]":i+=1
 return i

def root_slices(doc:str):
 d=doc.encode();i=ws(d,1);out=[]
 while d[i]!=125:
  ks=i;ke=string_end(d,i);key=json.loads(d[ks:ke]);i=ws(d,ke);assert d[i]==58
  vs=ws(d,i+1);ve=value_end(d,vs);out.append((key,vs,ve));i=ws(d,ve)
  if d[i]==44:i=ws(d,i+1)
 return out

def source(doc:str,c:Any)->str:
 slices=root_slices(doc);lit=c.dew_string_literal(doc)
 pushes=[]
 for key,start,end in slices:
  pushes.append(f'''  entries.push(JsonRootEntry {{
    key: {c.dew_string_literal(key)}
    start: {start}u32
    length: {end-start}u32
  }})''')
 last=slices[-1][0]
 return f'''open dew.std.array
open dew.std.json
open dew.std.string

struct JsonRootEntry {{
  key: String
  start: U32
  length: U32
}}
struct IndexedRaw {{
  document: JsonRawDocument
  entries: Array<JsonRootEntry>
}}

fn document() -> String {{
  {lit}
}}

fn build_index() -> Result<IndexedRaw, JsonParseError> {{
  match json_parse_raw_document(document()) {{
    Result::Err(error) => Result::Err(error)
    Result::Ok(document) => {{
      let entries = Array::new()
{chr(10).join(pushes)}
      Result::Ok(IndexedRaw {{
        document: document
        entries: entries
      }})
    }}
  }}
}}

fn string_equal(left: String, right: String) -> Bool {{
  left.equals(right)
}}

fn lookup(index: IndexedRaw, key: String) -> Result<JsonValue, JsonParseError> {{
  let source = index.document.source()
  let mut current = 0u32
  while current {{
    value if value < index.entries.length() => {{
      let entry = index.entries.get_unchecked(value)
      if string_equal(entry.key, key) {{
        break json_parse_retained(source.view(entry.start, entry.length).to_string())
      }} else {{
        continue value + 1u32
      }}
    }}
    _ => break Result::Ok(JsonValue::Null)
  }}
}}

fn weight(value: JsonValue) -> U32 {{
  match value {{
    JsonValue::Null => 1u32
    JsonValue::Bool(_) => 1u32
    JsonValue::Number(v) => v.byte_length()
    JsonValue::ValidatedNumber(v) => v.lexeme().byte_length()
    JsonValue::String(v) => v.byte_length()
    JsonValue::ValidatedString(v) => v.string().byte_length()
    JsonValue::Array(v) => v.length()
    JsonValue::Object(v) => v.length()
  }}
}}

fn repeat(remaining: U32, total: U32) -> U32 {{
  if remaining == 0u32 {{
    total
  }} else {{
    match build_index() {{
      Result::Err(_) => total
      Result::Ok(index) => match lookup(index, {c.dew_string_literal(last)}) {{
        Result::Err(_) => total
        Result::Ok(value) => repeat(remaining - 1u32, total + weight(value))
      }}
    }}
  }}
}}
pub fn indexed_lookup(iterations: U32) -> U32 {{
  repeat(iterations, 0u32)
}}
pub fn expected() -> U32 {{
  repeat(1u32, 0u32)
}}
'''

def main():
 a=argparse.ArgumentParser();a.add_argument('--json-as-dir',type=Path,default=ROOT/'.tmp/json-as');a.add_argument('--samples',type=int,default=101);a.add_argument('--rounds',type=int,default=5);a.add_argument('--target-batch-bytes',type=int,default=262144);a.add_argument('--output',type=Path);x=a.parse_args();c=load_comparison();specs=[]
 for n in FIXTURES:
  d=c.extract_json_as_fixture(x.json_as_dir.resolve(),n);q=TMP/n;q.mkdir(parents=True,exist_ok=True);src=q/'benchmark.dew';src.write_text(source(d,c));w=q/'benchmark.wasm';run([str(ROOT/'tools/dew'),'build',str(src),'-o',str(w)],True);specs.append({'name':n,'bytes':len(d.encode()),'wasm':str(w),'wasmBytes':w.stat().st_size})
 p=TMP/'specs.json';p.write_text(json.dumps(specs));js=r'''const fs=require('fs'),{performance}=require('perf_hooks');(async()=>{let ss=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],out={};for(let s of ss){let i=(await WebAssembly.instantiate(fs.readFileSync(s.wasm),{})).instance,b=Math.max(1,Math.min(5000,Math.floor(target/s.bytes))),e=i.exports.expected();for(let w=0;w<30;w++)if(i.exports.indexed_lookup(b)!==e*b)throw Error('bad');out[s.name]=[];for(let r=0;r<rounds;r++){let xs=[];for(let n=0;n<samples;n++){let t=performance.now(),v=i.exports.indexed_lookup(b);xs.push((performance.now()-t)*1e6/b);if(v!==e*b)throw Error('bad')}out[s.name].push(xs)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})''';raw=json.loads(run(['node','-e',js,str(p),str(x.samples),str(x.rounds),str(x.target_batch_bytes)],True).stdout);fixtures={}
 for s in specs:fixtures[s['name']]={'ns_per_op':round(statistics.median(statistics.median(r) for r in raw[s['name']]),2),'wasm_bytes':s['wasmBytes']}
 report={'environment':{'platform':platform.platform(),'node':run(['node','--version'],True).stdout.strip()},'methodology':{'prototype':'validate source, construct root index, parse one selected value','samples_per_round':x.samples,'rounds':x.rounds,'warmups':30},'fixtures':fixtures};enc=json.dumps(report,indent=2,sort_keys=True)+'\n'
 if x.output:x.output.parent.mkdir(parents=True,exist_ok=True);x.output.write_text(enc)
 print(enc,end='')
if __name__=='__main__':main()
