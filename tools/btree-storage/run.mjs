import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
const root = process.argv[2];
const load = name => new WebAssembly.Instance(new WebAssembly.Module(fs.readFileSync(path.join(root, name + '.wasm')))).exports;
const carriers = load('carriers-inspect');
assert.equal(carriers.i32_pair(-42), -42);
assert.equal(carriers.i64_pair(-4294967297n), -4294967297n);
assert.equal(BigInt.asUintN(64, carriers.u64_pair(0xffffffffffffffffn)), 0xffffffffffffffffn);
assert.equal(carriers.f32_pair(-1.5), -1.5);
assert.equal(carriers.f64_pair(-1.5), -1.5);
assert.equal(carriers.bool_pair(1), 1);
assert.equal(carriers.u8_pair(255), 255);
assert.equal(carriers.i16_pair(-32768), -32768);
const refs = carriers.reference_case();
for (let i=0; i<8; i++) assert.equal(carriers.slot_null(refs, i), i >= 4 ? 1 : 0, `reference slot ${i}`);
assert.equal(carriers.slot_same(refs, 0, 3), 1);
const rep = load('representation-inspect');
const common = rep.common_pair(-42, 0xffffffff);
assert.equal(rep.slot_i32(common, 0), -42);
assert.equal(rep.slot_i32(common, 1) >>> 0, 0xffffffff);
assert.equal(rep.slot_i32(common, 4), 0);
assert.equal(rep.slot_i32(common, 5), 0);
for (const bits of [0n, 0x8000000000000000n, 0x7ff0000000000001n, 0x7ff8123456789abcn, 0xffffffffffffffffn]) {
  assert.equal(BigInt.asUintN(64,rep.mixed_roundtrip(bits)),bits);
  const a = rep.mixed_pair_bits(0xffffffff, bits);
  assert.equal(BigInt.asUintN(64, rep.block_low(a, 0)), 0xffffffffn);
  assert.equal(BigInt.asUintN(64, rep.block_high(a, 0)), bits);
  assert.equal(rep.block_low(a, 2), 0n);
  assert.equal(rep.block_high(a, 2), 0n);
}
for (const bits of [0, 0x80000000, 0x7f800001, 0x7fc12345, 0xffffffff]) {
  assert.equal(rep.float_roundtrip(bits) >>> 0,bits);
  const a = rep.float_pair_bits(-1, bits);
  assert.equal(BigInt.asUintN(64, rep.block_low(a, 0)), 0xffffffffn);
  assert.equal(BigInt.asUintN(64, rep.block_high(a, 0)), BigInt(bits));
}
const narrow = rep.signed_narrow_pair(-32768,255);
assert.equal(rep.slot_i32(narrow,0),-32768);
assert.equal(rep.slot_i32(narrow,1),255);
assert.equal(rep.signed_narrow_load(narrow),-32768);
for (const bit of [0,1]) {
  const a=rep.bool_narrow_pair(bit,255);
  assert.equal(rep.slot_i32(a,0),bit);
  assert.equal(rep.slot_i32(a,1),255);
}
const vector = rep.vector_pair_case();
assert.equal(rep.block_low(vector, 0), 7n);
assert.equal(rep.block_high(vector, 0), 9n);
assert.equal(rep.block_low(vector, 1), 42n);
assert.equal(rep.block_high(vector, 1), 0n);
for (const index of [4, 5]) {
  assert.equal(rep.block_low(vector, index), 0n);
  assert.equal(rep.block_high(vector, index), 0n);
}
const simd = load('simd');
let comparisons = 0;
for (const [width, lanes] of [[16,8],[32,4],[64,2]]) {
  const max = (1n << BigInt(width)) - 1n;
  const sign = 1n << BigInt(width-1);
  const cast = n => width === 64 ? n : Number(n);
  for (let lane=0; lane<lanes; lane++) for (const x of [0n, 1n, sign-1n, sign, max]) {
    const result = simd['lane'+width](lane, cast(x));
    assert.equal(width === 64 ? BigInt.asUintN(64, result) : BigInt(result >>> 0), x);
  }
  const stored = [0n,sign,max].slice(0,lanes);
  for (const q of [0n,1n,sign-1n,sign,sign+1n,max-1n,max]) for (let live=0;live<=stored.length;live++) for(const eq of [0,1]) {
    const expected = stored.slice(0,live).reduce((mask,v,i) => mask | ((eq ? v === q : v < q) ? 1 << i : 0),0);
    assert.equal(simd['rank'+width](cast(q),live,eq),expected,`rank${width} query=${q} live=${live} equal=${eq}`);
    comparisons++;
  }
}
const u64s = [0n,1n,0x7fffffffffffffffn,0x8000000000000000n,0xfffffffffffffffen,0xffffffffffffffffn];
for (const a of u64s) for(const b of u64s) for(const q of u64s) for(let live=0; live<=2; live++) for(const eq of [0,1]) {
  const expected=[a,b].slice(0,live).reduce((mask,v,i)=>mask|((eq ? v===q : v<q) ? 1<<i : 0),0);
  assert.equal(simd.rank64_pair(a,b,q,live,eq),expected);
  comparisons++;
}
const opaque=load('opaque');
assert.equal(opaque.run(),42);
for(const x of [0n,42n,0xffffffffffffffffn]) {
  assert.equal(BigInt.asUintN(64,opaque.present(x)),x);
  assert.equal(opaque.absent(x),0n);
}
console.log(JSON.stringify({result:'passed',simd_mask_checks:comparisons,reference_slots:{live:4,cleared:2,permanent_defaults:2},float_bits:'zero, negative zero, signalling/quiet NaNs and all ones preserved',opaque:'identity, private getters and optional evidence'},null,2));
