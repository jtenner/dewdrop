from pathlib import Path
import json,sys
ROOT = Path(__file__).resolve().parents[1]
from wasm_simd_intrinsics import SIMD_INSTRUCTIONS, SIMD_LANE_INSTRUCTIONS
rows=list(SIMD_INSTRUCTIONS)+[r[:4] for r in SIMD_LANE_INSTRUCTIONS]
rows += [(f'v128.{op}', '', ('V128','V128'), 'V128') for op in ('and','or','xor')]
lines=['// Generated from tools/wasm_simd_intrinsics.py. Do not edit.',
'''fn ct_vector_canonical_float_word(word: U64, width: U32) -> U64 {
  if width == 64u32 {
    if (word & 9218868437227405312u64) == 9218868437227405312u64 && (word & 4503599627370495u64) != 0u64 {
      9221120237041090560u64
    } else {
      word
    }
  } else {
    let mut result = word
    let _ = while 0u64 {
      part if part < 2u64 => {
        let shift = part * 32u64
        let bits = (word >> shift) & 4294967295u64
        if (bits & 2139095040u64) == 2139095040u64 && (bits & 8388607u64) != 0u64 {
          result = (result & ((4294967295u64 << shift) ^ 18446744073709551615u64)) | (2143289344u64 << shift)
        }
        continue part + 1u64
      }
      _ => break ()
    }
    result
  }
}''',
'''fn ct_vector_canonical_float(value: V128, width: U32) -> CtValue {
  CtValue::Vector(ct_vector_canonical_float_word(ct_vector_host_low_bits(value), width), ct_vector_canonical_float_word(ct_vector_host_high_bits(value), width))
}''', 
'builtin ct_vector_host_splat(value: U64) -> V128 = "i64x2.splat"',
'builtin ct_vector_host_high(value: V128, high: U64) -> V128 = "i64x2.replace_lane 1"',
'builtin ct_vector_host_low_bits(value: V128) -> U64 = "i64x2.extract_lane 0"',
'builtin ct_vector_host_high_bits(value: V128) -> U64 = "i64x2.extract_lane 1"',
'''fn ct_vector_host_value(machine: CtMachine, value: CtValue) -> V128 {
  match value {
    Vector(low, high) => ct_vector_host_high(ct_vector_host_splat(low), high)
    _ => {
      let _ = ct_fail(machine, "Wasm vector instruction requires a 128-bit vector")
      ct_vector_host_splat(0u64)
    }
  }
}''',
'''fn ct_vector_host_result(value: V128) -> CtValue {
  CtValue::Vector(ct_vector_host_low_bits(value), ct_vector_host_high_bits(value))
}''']
for i,(op,_,inputs,out) in enumerate(rows):
 lines.append(f'builtin ct_vector_host_{i}('+', '.join(f'v{j}: {t}' for j,t in enumerate(inputs))+f') -> {out} = {json.dumps(op)}')
lines.append('''fn ct_vector_opcode(opcode: String) -> Bool {
  opcode.starts_with("v128.") || opcode.starts_with("i8x16.") || opcode.starts_with("i16x8.") || opcode.starts_with("i32x4.") || opcode.starts_with("i64x2.") || opcode.starts_with("f32x4.") || opcode.starts_with("f64x2.")
}
fn ct_vector_intrinsic(machine: CtMachine, opcode: String, args: Array<CtValue>) -> CtValue {
  match opcode {''')
for i,(op,_,inputs,out) in enumerate(rows):
 convert={'V128':'ct_vector_host_value(machine, ARG)', 'I32':'u64_into_i32(ct_raw_bits(machine, ARG))','I64':'u64_into_i64(ct_raw_bits(machine, ARG))','F32':'ct_float_f32(machine, ARG)','F64':'ct_float_f64(machine, ARG)'}
 args=', '.join(convert[t].replace('ARG',f'args[{j}u32]') for j,t in enumerate(inputs))
 ret={'V128':'ct_vector_host_result(result)', 'I32':'ct_number(u32_into_u64(i32_into_u32(result)), "I32")', 'I64':'ct_number(i64_into_u64(result), "I64")','F32':'CtValue::Floating(u32_into_u64(wasm_f32_to_bits(result)), "F32")','F64':'CtValue::Floating(wasm_f64_to_bits(result), "F64")'}[out]
 operation=op.split('.')[1].split(' ')[0]
 if out=='V128' and op.startswith(('f32x4.','f64x2.')) and operation not in ('eq','ne','lt','le','gt','ge','abs','neg','pmin','pmax','extract_lane','replace_lane','splat'):
  ret=f'ct_vector_canonical_float(result, {32 if op.startswith("f32") else 64}u32)'
 lines.append(f'''    {json.dumps(op)} => {{
      if args.length() != {len(inputs)}u32 {{
        return ct_fail(machine, "Wasm vector intrinsic argument count mismatch")
      }}
      let result = ct_vector_host_{i}({args})
      {ret}
    }}''')
lines.append('''    _ => {
      if opcode.starts_with("i8x16.shuffle ") && args.length() == 2u32 {
        let lanes = array_new::<String>()
        let mut start = 14u32
        let _ = while start {
          index if index <= opcode.byte_length() => {
            if index == opcode.byte_length() || opcode.byte_at(index) == 32u8 {
              lanes.push(opcode.slice(start, index))
              start = index + 1u32
            }
            continue index + 1u32
          }
          _ => break ()
        }
        if lanes.length() != 16u32 {
          return ct_fail(machine, "invalid Wasm vector shuffle")
        }
        let mut result = CtValue::Vector(0u64, 0u64)
        let _ = while 0u32 {
          lane if lane < 16u32 => {
            match ct_raw_immediate("lane ".concat(lanes[lane]), "lane ") {
              Some(selected) if selected < 32u32 => {
                let source = if selected < 16u32 {
                  args[0u32]
                } else {
                  args[1u32]
                }
                result = ct_vector_replace(machine, result, lane, ct_vector_byte(machine, source, selected % 16u32))
              }
              _ => return ct_fail(machine, "invalid Wasm vector shuffle lane")
            }
            continue lane + 1u32
          }
          _ => break ()
        }
        result
      } else {
        ct_fail(machine, "unsupported Wasm vector intrinsic or linear memory access: ".concat(opcode))
      }
    }
  }
}''')
output = 'open dew.std.array\nopen dew.std.string\n' + '\n'.join(lines) + '\n'
path = ROOT / 'self_host/compiler/transform_vectors_generated.dew'
if '--check' in sys.argv:
 if path.read_text() != output:
  raise SystemExit('transform vector dispatch is stale')
else:
 path.write_text(output)
