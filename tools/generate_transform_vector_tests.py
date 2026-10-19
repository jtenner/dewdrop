#!/usr/bin/env python3
"""Generate fixed SIMD tests from real Wasm; arithmetic NaNs use our canonical policy."""
from pathlib import Path
import json, sys, struct, subprocess, tempfile, time
from wasm_simd_intrinsics import SIMD_INSTRUCTIONS, SIMD_LANE_INSTRUCTIONS
ROOT = Path(__file__).resolve().parents[1]

def measured(label, command):
 start = time.monotonic()
 subprocess.run(command, cwd=ROOT, check=True)
 elapsed = time.monotonic()-start
 print(f'self-host timing: {label}: {elapsed:.3f} seconds', file=sys.stderr)
 if elapsed > 30:
  print(f'self-host performance bug: {label} exceeded 30 seconds', file=sys.stderr)

rows=list(SIMD_INSTRUCTIONS)+[r[:4] for r in SIMD_LANE_INSTRUCTIONS]
rows += [(f'v128.{op}', '', ('V128','V128'), 'V128') for op in ('and','or','xor')]
rows += [('i8x16.shuffle 31 0 30 1 29 2 28 3 27 4 26 5 25 6 24 7','',('V128','V128'),'V128')]
mask=(1<<64)-1
cases=[]; funcs=[]
for row in rows:
 op,_,inputs,out=row
 for sample in range(3):
  vals=[]; wat=[]
  for index,kind in enumerate(inputs):
   if kind=='V128':
    patterns=[(0x807fff010080ff7f,0xff7f0080800100ff),(0x7fffffff80000000,0xffffffff00000001),(0x0102040810204080,0x8040201008040201)]
    low,high=patterns[(sample+index)%3]
    if op.startswith(('f32x4.','i32x4.trunc_sat_f32')) or 'promote_low_f32' in op:
     patterns=[(0x8000000000000000,0x7fc000007f800000),(0xc020000040200000,0x3f800000bf800000),(0x7f800001ffc00042,0x4f800000cf000000)]
     low,high=patterns[(sample+index)%3]
    if op.startswith(('f64x2.','i32x4.trunc_sat_f64')) or 'demote_f64' in op:
     patterns=[(0x8000000000000000,0),(0x4004000000000000,0xc004000000000000),(0x7ff0000000000042,0xfff0000000000000)]
     low,high=patterns[(sample+index)%3]
    vals.append(['V128',low,high]);wat.append(f'v128.const i64x2 0x{low:x} 0x{high:x}')
   elif kind in ('I32','I64'):
    bits=([37,0xffffffff,0x80000000] if kind=='I32' else [0x1234567887654321,mask,1<<63])[sample]
    vals.append([kind,bits]);wat.append(f'{kind.lower()}.const 0x{bits:x}')
   else:
    value=[2.5,-0.0,-7.25][sample]
    bits=int.from_bytes(struct.pack('<f' if kind=='F32' else '<d',value),'little')
    vals.append([kind,bits]);wat.append(f'{kind.lower()}.const {value.hex()}')
  idx=len(cases)
  if out=='V128':
   tail='local.set $v local.get $v i64x2.extract_lane 0 local.get $v i64x2.extract_lane 1'; result='i64 i64';local='(local $v v128)'
  else:
   tail={'I32':'i64.extend_i32_u','I64':'','F32':'i32.reinterpret_f32 i64.extend_i32_u','F64':'i64.reinterpret_f64'}[out];result='i64';local=''
  funcs.append(f'(func (export "c{idx}") (result {result}) {local} '+ ' '.join(wat)+f' {op} {tail})')
  cases.append({'opcode':op,'args':vals,'out':out})
with tempfile.TemporaryDirectory(prefix='dew-vector-oracle-') as directory:
 wat=Path(directory)/'oracle.wat'
 wasm=Path(directory)/'oracle.wasm'
 expected=Path(directory)/'expected.json'
 wat.write_text('(module\n'+'\n'.join(funcs)+'\n)')
 measured('vector oracle Wasm assembly', ['mise','exec','wasm-tools@1.262.0','--','wasm-tools','parse',str(wat),'-o',str(wasm)])
 javascript = """
 import fs from 'node:fs';
 const {instance}=await WebAssembly.instantiate(fs.readFileSync(process.argv[1]));
 const expected=[];
 for(let i=0;i<COUNT;i++) {
   const value=instance.exports['c'+i]();
   expected.push((Array.isArray(value)?value:[value]).map(x=>BigInt.asUintN(64,x).toString()));
 }
 fs.writeFileSync(process.argv[2],JSON.stringify(expected));
 """.replace('COUNT',str(len(cases)))
 measured('vector oracle execution', ['node','--input-type=module','--eval',javascript,str(wasm),str(expected)])
 for case,result in zip(cases,json.loads(expected.read_text()),strict=True):
  case['expected']=result

def value(v,dew):
 k,*bits=v
 suffix='u64' if dew else 'UL'
 prefix='CtValue::' if dew else ''
 if k=='V128': return prefix+'Vector('+', '.join(str(x)+suffix for x in bits)+')'
 return prefix+('Floating' if k.startswith('F') else 'Number')+'('+str(bits[0])+suffix+', '+json.dumps(k)+')'
def width(c):
 op=c['opcode']
 if not op.startswith(('f32x4.','f64x2.')): return 0
 operation=op.split('.')[1].split(' ')[0]
 if operation in ('eq','ne','lt','le','gt','ge','abs','neg','pmin','pmax','extract_lane','replace_lane','splat'):return 0
 return 32 if op.startswith('f32') else 64
for dew in (False,True):
 out=[]
 if dew:
  out.append('''fn ct_vector_test_equal(machine: CtMachine, actual: CtValue, expected: CtValue) -> Bool {
  if machine.error.byte_length() != 0u32 {
    return false
  }
  match (actual, expected) {
    (Vector(al, ah), Vector(bl, bh)) => al == bl && ah == bh
    (Floating(a, _), Floating(b, _)) => a == b
    _ => ct_raw_bits(machine, actual) == ct_raw_bits(machine, expected)
  }
}''')
 else:
  out.append('''///|
fn vector_test_equal(actual : Value, expected : Value) -> Bool raise EvalError {
  match (actual, expected) {
    (Vector(al, ah), Vector(bl, bh)) => al == bl && ah == bh
    (Floating(a, _), Floating(b, _)) => a == b
    _ => raw_bits(actual) == raw_bits(expected)
  }
}''')
 for base in range(0,len(cases),48):
  out.append(('' if dew else '///|\n')+f'test "Wasm vector oracle {base}-{min(base+48,len(cases))-1}" {{')
  if dew:out.append('  let machine = ct_machine(ct_test_plan(b""))')
  for c in cases[base:base+48]:
   args='['+', '.join(value(v,dew) for v in c['args'])+']'
   words=[int(x) for x in c['expected']]
   lane_width=width(c)
   if c['out']=='V128' and lane_width:
    exp=(0x7f800000 if lane_width==32 else 0x7ff0000000000000)
    frac=(0x7fffff if lane_width==32 else 0xfffffffffffff)
    canonical=(0x7fc00000 if lane_width==32 else 0x7ff8000000000000)
    for wi,word in enumerate(words):
     for shift in range(0,64,lane_width):
      bits=(word>>shift)&((1<<lane_width)-1)
      if bits&exp==exp and bits&frac:
       words[wi]=(words[wi]&~(((1<<lane_width)-1)<<shift))|(canonical<<shift)
   expected=value([c['out']]+words,dew)
   op=json.dumps(c['opcode'])
   if dew:out.append(f'  assert(ct_vector_test_equal(machine, ct_vector_intrinsic(machine, {op}, {args}), {expected}), {op})')
   else:out.append(f'  assert_true(vector_test_equal(vector_intrinsic({op}, {args}), {expected}), msg={op})')
  out.append('}')
 path = ROOT / ('self_host/compiler/transform_vector_test.dew' if dew else 'src/transforms/vectors_wbtest.mbt')
 output = '\n'.join(out)+'\n'
 if '--check' in sys.argv:
  if path.read_text() != output:
   raise SystemExit(str(path.relative_to(ROOT))+' is stale')
 else:
  path.write_text(output)
