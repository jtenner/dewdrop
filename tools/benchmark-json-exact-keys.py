#!/usr/bin/env python3
"""Compare Bloom+linear JSON duplicate checks against exact Set tracking."""

from __future__ import annotations

import argparse
import importlib.util
import json
import os
import platform
import shutil
import statistics
import subprocess
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
TMP = ROOT / ".tmp" / "json-exact-keys-benchmark"
FIXTURES = ("small", "medium", "large")
OPERATIONS = ("parse_string", "validate_json", "roundtrip")


def load_comparison() -> Any:
    path = ROOT / "tools" / "benchmark-json-comparison.py"
    spec = importlib.util.spec_from_file_location("dew_json_comparison", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"cannot load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(command: list[str], *, capture: bool = False) -> subprocess.CompletedProcess[str]:
    return subprocess.run(command, cwd=ROOT, check=True, text=True, capture_output=capture)


def exact_source(source: str) -> str:
    source = source.replace("open dew.std.io\n", "open dew.std.io\nopen dew.std.set\n", 1)
    start = source.index("fn json_parse_object(")
    end = source.index("\nfn json_parse_value(", start)
    old = source[start:end]
    new = '''fn json_parse_object(
  parser: JsonParser,
  depth: U32,
) -> Result<JsonValue, JsonParseError> {
  let members = Array::new()
  let keys = Set::empty()
  json_parser_set_offset(parser, json_parser_offset(parser) + 1u32)
  json_parser_skip_whitespace(parser)
  if json_parser_offset(parser) < parser.input.byte_length() &&
    parser.input.byte_at(json_parser_offset(parser)) == 125u8 {
    json_parser_set_offset(parser, json_parser_offset(parser) + 1u32)
    Result::Ok(JsonValue::Object(members))
  } else {
    while true {
      true => {
      let key_offset = json_parser_offset(parser)
      if key_offset >= parser.input.byte_length() {
        break Result::Err(JsonParseError::UnexpectedEnd(key_offset))
      } else if parser.input.byte_at(key_offset) != 34u8 {
        break Result::Err(JsonParseError::UnexpectedByte(key_offset, parser.input.byte_at(key_offset)))
      } else {
      }
      let key = match json_parse_string(parser) {
        Result::Ok(value) => value
        Result::Err(error) => break Result::Err(error)
      }
      if keys.insert(key) == false {
        break Result::Err(JsonParseError::DuplicateObjectKey(key_offset, key))
      } else {
      }
      json_parser_skip_whitespace(parser)
      let colon = json_parser_offset(parser)
      if colon >= parser.input.byte_length() {
        break Result::Err(JsonParseError::UnexpectedEnd(colon))
      } else if parser.input.byte_at(colon) != 58u8 {
        break Result::Err(JsonParseError::UnexpectedByte(colon, parser.input.byte_at(colon)))
      } else {
      }
      json_parser_set_offset(parser, colon + 1u32)
      json_parser_skip_whitespace(parser)
      let member_value = match json_parse_value(parser, depth + 1u32) {
        Result::Ok(value) => value
        Result::Err(error) => break Result::Err(error)
      }
      members.push(JsonMember {
        key: key
        value: member_value
      })
      json_parser_skip_whitespace(parser)
      let offset = json_parser_offset(parser)
      if offset >= parser.input.byte_length() {
        break Result::Err(JsonParseError::UnexpectedEnd(offset))
      } else {
      }
      let byte = parser.input.byte_at(offset)
      if byte == 125u8 {
        json_parser_set_offset(parser, offset + 1u32)
        break Result::Ok(JsonValue::Object(members))
      } else if byte == 44u8 {
        json_parser_set_offset(parser, offset + 1u32)
        json_parser_skip_whitespace(parser)
      } else {
        break Result::Err(JsonParseError::UnexpectedByte(offset, byte))
      }
      continue true
      }
    }
  }
}'''
    source = source[:start] + new + source[end:]
    marker = "      } else if byte == 123u8 {\n"
    start = source.index(marker, source.index("fn json_validate_value("))
    block_start = start + len(marker)
    block_end = source.index("      } else {\n        Result::Err(JsonParseError::UnexpectedByte(offset, byte))", block_start)
    old_body = source[block_start:block_end]
    new_body = '''        let keys = Set::empty()
        json_parser_set_offset(parser, offset + 1u32)
        json_parser_skip_whitespace(parser)
        if json_parser_offset(parser) < parser.input.byte_length() &&
          parser.input.byte_at(json_parser_offset(parser)) == 125u8 {
          json_parser_set_offset(parser, json_parser_offset(parser) + 1u32)
          Result::Ok(json_unit())
        } else {
          while true {
            true => {
              let key_offset = json_parser_offset(parser)
              if key_offset >= parser.input.byte_length() {
                break Result::Err(JsonParseError::UnexpectedEnd(key_offset))
              } else if parser.input.byte_at(key_offset) != 34u8 {
                break Result::Err(JsonParseError::UnexpectedByte(key_offset, parser.input.byte_at(key_offset)))
              } else {
              }
              let key = match json_parse_string(parser) {
                Result::Ok(value) => value
                Result::Err(error) => break Result::Err(error)
              }
              if keys.insert(key) == false {
                break Result::Err(JsonParseError::DuplicateObjectKey(key_offset, key))
              } else {
              }
              json_parser_skip_whitespace(parser)
              let colon = json_parser_offset(parser)
              if colon >= parser.input.byte_length() {
                break Result::Err(JsonParseError::UnexpectedEnd(colon))
              } else if parser.input.byte_at(colon) != 58u8 {
                break Result::Err(JsonParseError::UnexpectedByte(colon, parser.input.byte_at(colon)))
              } else {
              }
              json_parser_set_offset(parser, colon + 1u32)
              json_parser_skip_whitespace(parser)
              match json_validate_value(parser, depth + 1u32) {
                Result::Err(error) => break Result::Err(error)
                Result::Ok(_) => {}
              }
              json_parser_skip_whitespace(parser)
              let next = json_parser_offset(parser)
              if next >= parser.input.byte_length() {
                break Result::Err(JsonParseError::UnexpectedEnd(next))
              } else {
              }
              let delimiter = parser.input.byte_at(next)
              if delimiter == 125u8 {
                json_parser_set_offset(parser, next + 1u32)
                break Result::Ok(json_unit())
              } else if delimiter == 44u8 {
                json_parser_set_offset(parser, next + 1u32)
                json_parser_skip_whitespace(parser)
                continue true
              } else {
                break Result::Err(JsonParseError::UnexpectedByte(next, delimiter))
              }
            }
          }
        }
'''
    return source[:block_start] + new_body + source[block_end:]


def prepare_roots() -> dict[str, Path]:
    roots = {}
    for variant in ("bloom", "exact"):
        root = TMP / "packages" / variant
        shutil.rmtree(root, ignore_errors=True)
        shutil.copytree(ROOT / "std", root / "std")
        roots[variant] = root
    path = roots["exact"] / "std" / "json.dew"
    path.write_text(exact_source(path.read_text(encoding="utf-8")), encoding="utf-8")
    return roots


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--json-as-dir", type=Path, default=ROOT / ".tmp" / "json-as")
    parser.add_argument("--samples", type=int, default=101)
    parser.add_argument("--rounds", type=int, default=5)
    parser.add_argument("--target-batch-bytes", type=int, default=262144)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    comparison = load_comparison()
    roots = prepare_roots()
    specs = []
    env = dict(os.environ)
    env.update({"DEW_PARSE_EVENT_CACHE":"0","DEW_INTERFACE_CACHE":"0","DEW_BODY_CACHE":"0","DEW_BUILD_CACHE":"0"})
    for name in FIXTURES:
        document = comparison.extract_json_as_fixture(args.json_as_dir.resolve(), name)
        directory = TMP / "modules" / name
        directory.mkdir(parents=True, exist_ok=True)
        source_path = directory / "benchmark.dew"
        source_path.write_text(
            "open dew.std.set\n" + comparison.dew_source(document),
            encoding="utf-8",
        )
        variants = {}
        sizes = {}
        for variant, root in roots.items():
            wasm = directory / f"benchmark-{variant}.wasm"
            subprocess.run([str(ROOT/"tools"/"dew"),"build",str(source_path),"--package-root",str(root),"-o",str(wasm)],cwd=ROOT,check=True,text=True,capture_output=True,env=env)
            variants[variant] = str(wasm)
            sizes[variant] = wasm.stat().st_size
        specs.append({"name":name,"bytes":len(document.encode()),"rootSize":comparison.fixture_root_size(document),"variants":variants,"sizes":sizes})
    specs_path = TMP / "specs.json"
    specs_path.write_text(json.dumps(specs), encoding="utf-8")
    runner = r'''const fs=require('fs'),{performance}=require('perf_hooks');(async()=>{const ss=JSON.parse(fs.readFileSync(process.argv[1])),samples=+process.argv[2],rounds=+process.argv[3],target=+process.argv[4],ops=[['parse_string',s=>s.rootSize],['validate_json',s=>s.rootSize],['roundtrip',s=>s.bytes]],out={};for(const s of ss){const ins={};for(const v of ['bloom','exact'])ins[v]=(await WebAssembly.instantiate(fs.readFileSync(s.variants[v]),{})).instance;const batch=Math.max(1,Math.min(5000,Math.floor(target/s.bytes)));out[s.name]={batch,rounds:[]};for(const [op,e] of ops)for(const v of ['bloom','exact'])for(let w=0;w<30;w++)if(ins[v].exports[op](batch)!==e(s)*batch)throw Error('bad');for(let r=0;r<rounds;r++){let row={};for(const [op] of ops)row[op]={bloom:[],exact:[]};for(let n=0;n<samples;n++)for(let oi=0;oi<ops.length;oi++){const [op,e]=ops[(n+r+oi)%ops.length],order=(n+r)%2?['exact','bloom']:['bloom','exact'];for(const v of order){let t=performance.now(),a=ins[v].exports[op](batch),ns=(performance.now()-t)*1e6/batch;if(a!==e(s)*batch)throw Error('bad');row[op][v].push(ns)}}out[s.name].rounds.push(row)}}process.stdout.write(JSON.stringify(out))})().catch(e=>{console.error(e);process.exit(1)})'''
    raw=json.loads(run(["node","-e",runner,str(specs_path),str(args.samples),str(args.rounds),str(args.target_batch_bytes)],capture=True).stdout)
    fixtures={}
    for spec in specs:
        operations={}
        for op in OPERATIONS:
            bs=[]; es=[]; ds=[]
            for row in raw[spec['name']]['rounds']:
                b=statistics.median(row[op]['bloom']); e=statistics.median(row[op]['exact']); bs.append(b);es.append(e);ds.append((e/b-1)*100)
            operations[op]={"bloom_ns_per_op":round(statistics.median(bs),2),"exact_ns_per_op":round(statistics.median(es),2),"delta_percent":round(statistics.median(ds),2)}
        fixtures[spec['name']]={"input_bytes":spec['bytes'],"wasm_bytes":spec['sizes'],"operations":operations}
    report={"environment":{"platform":platform.platform(),"node":run(["node","--version"],capture=True).stdout.strip()},"methodology":{"samples_per_round":args.samples,"rounds":args.rounds,"warmups":30},"fixtures":fixtures}
    encoded=json.dumps(report,indent=2,sort_keys=True)+"\n"
    if args.output: args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text(encoded,encoding="utf-8")
    print(encoded,end="")

if __name__ == "__main__": main()
