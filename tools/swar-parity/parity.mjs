import { readFile } from "node:fs/promises";

const MASK32 = 0xffff_ffffn;
const MASK64 = 0xffff_ffff_ffff_ffffn;
const wasm = await readFile(process.argv[2] ?? new URL("./swar_parity.wasm", import.meta.url));
const { instance } = await WebAssembly.instantiate(wasm, {});
const e = instance.exports;

function u32(value) {
  return Number(BigInt.asUintN(32, BigInt(value)));
}
function i32arg(value) {
  return Number(BigInt.asIntN(32, BigInt(value)));
}
function u64(value) {
  return BigInt.asUintN(64, value);
}
function i64arg(value) {
  return BigInt.asIntN(64, value);
}
function wasmU32(name, ...args) {
  return u32(e[name](...args));
}
function wasmU64(name, ...args) {
  return u64(e[name](...args));
}
function mask(width) {
  return (1n << BigInt(width)) - 1n;
}
function lane(value, index, width) {
  return (value >> BigInt(index * width)) & mask(width);
}
function signedLane(value, index, width) {
  return BigInt.asIntN(width, lane(value, index, width));
}
function pack(totalWidth, laneWidth, fn) {
  let result = 0n;
  const count = totalWidth / laneWidth;
  for (let index = 0; index < count; index++) {
    result |= BigInt.asUintN(laneWidth, fn(index)) << BigInt(index * laneWidth);
  }
  return BigInt.asUintN(totalWidth, result);
}
function splat(totalWidth, laneWidth, value) {
  return pack(totalWidth, laneWidth, () => BigInt(value));
}
function replace(totalWidth, laneWidth, value, index, replacement) {
  const shift = BigInt((index & (totalWidth / laneWidth - 1)) * laneWidth);
  const laneMask = mask(laneWidth) << shift;
  return BigInt.asUintN(
    totalWidth,
    (value & ~laneMask) | (BigInt.asUintN(laneWidth, BigInt(replacement)) << shift),
  );
}
function addLanes(totalWidth, laneWidth, left, right) {
  return pack(totalWidth, laneWidth, (index) => lane(left, index, laneWidth) + lane(right, index, laneWidth));
}
function subLanes(totalWidth, laneWidth, left, right) {
  return pack(totalWidth, laneWidth, (index) => lane(left, index, laneWidth) - lane(right, index, laneWidth));
}
function mulLanes(totalWidth, laneWidth, left, right) {
  return pack(totalWidth, laneWidth, (index) => lane(left, index, laneWidth) * lane(right, index, laneWidth));
}
function compareLanes(totalWidth, laneWidth, left, right, signed, predicate) {
  return pack(totalWidth, laneWidth, (index) => {
    const a = signed ? signedLane(left, index, laneWidth) : lane(left, index, laneWidth);
    const b = signed ? signedLane(right, index, laneWidth) : lane(right, index, laneWidth);
    return predicate(a, b) ? mask(laneWidth) : 0n;
  });
}
function minLanes(totalWidth, laneWidth, left, right, signed) {
  return pack(totalWidth, laneWidth, (index) => {
    const a = signed ? signedLane(left, index, laneWidth) : lane(left, index, laneWidth);
    const b = signed ? signedLane(right, index, laneWidth) : lane(right, index, laneWidth);
    return a < b ? a : b;
  });
}
function maxLanes(totalWidth, laneWidth, left, right, signed) {
  return pack(totalWidth, laneWidth, (index) => {
    const a = signed ? signedLane(left, index, laneWidth) : lane(left, index, laneWidth);
    const b = signed ? signedLane(right, index, laneWidth) : lane(right, index, laneWidth);
    return a > b ? a : b;
  });
}
function absLanes(totalWidth, laneWidth, value) {
  return pack(totalWidth, laneWidth, (index) => {
    const item = signedLane(value, index, laneWidth);
    return item < 0n ? -item : item;
  });
}
function negLanes(totalWidth, laneWidth, value) {
  return pack(totalWidth, laneWidth, (index) => -signedLane(value, index, laneWidth));
}
function saturateSigned(value, laneWidth) {
  const minimum = -(1n << BigInt(laneWidth - 1));
  const maximum = (1n << BigInt(laneWidth - 1)) - 1n;
  return value < minimum ? minimum : value > maximum ? maximum : value;
}
function saturateUnsigned(value, laneWidth) {
  const maximum = mask(laneWidth);
  return value < 0n ? 0n : value > maximum ? maximum : value;
}
function addSatLanes(totalWidth, laneWidth, left, right, signed) {
  return pack(totalWidth, laneWidth, (index) => {
    const a = signed ? signedLane(left, index, laneWidth) : lane(left, index, laneWidth);
    const b = signed ? signedLane(right, index, laneWidth) : lane(right, index, laneWidth);
    return signed ? saturateSigned(a + b, laneWidth) : saturateUnsigned(a + b, laneWidth);
  });
}
function subSatLanes(totalWidth, laneWidth, left, right, signed) {
  return pack(totalWidth, laneWidth, (index) => {
    const a = signed ? signedLane(left, index, laneWidth) : lane(left, index, laneWidth);
    const b = signed ? signedLane(right, index, laneWidth) : lane(right, index, laneWidth);
    return signed ? saturateSigned(a - b, laneWidth) : saturateUnsigned(a - b, laneWidth);
  });
}
function avgrULanes(totalWidth, laneWidth, left, right) {
  return pack(totalWidth, laneWidth, (index) => (lane(left, index, laneWidth) + lane(right, index, laneWidth) + 1n) >> 1n);
}
function shlLanes(totalWidth, laneWidth, value, count) {
  const shift = count & (laneWidth - 1);
  return pack(totalWidth, laneWidth, (index) => lane(value, index, laneWidth) << BigInt(shift));
}
function shrULanes(totalWidth, laneWidth, value, count) {
  const shift = count & (laneWidth - 1);
  return pack(totalWidth, laneWidth, (index) => lane(value, index, laneWidth) >> BigInt(shift));
}
function shrSLanes(totalWidth, laneWidth, value, count) {
  const shift = count & (laneWidth - 1);
  return pack(totalWidth, laneWidth, (index) => signedLane(value, index, laneWidth) >> BigInt(shift));
}
function eqI8(totalWidth, left, right) {
  return pack(totalWidth, 8, (index) => lane(left, index, 8) === lane(right, index, 8) ? 0xffn : 0n);
}
function popcntI8(totalWidth, value) {
  return pack(totalWidth, 8, (index) => {
    let byte = Number(lane(value, index, 8));
    let count = 0;
    while (byte !== 0) {
      count += byte & 1;
      byte >>>= 1;
    }
    return BigInt(count);
  });
}
function bitmaskLanes(totalWidth, laneWidth, value) {
  let result = 0;
  for (let index = 0; index < totalWidth / laneWidth; index++) {
    result |= Number((lane(value, index, laneWidth) >> BigInt(laneWidth - 1)) & 1n) << index;
  }
  return result;
}
function allTrueLanes(totalWidth, laneWidth, value) {
  for (let index = 0; index < totalWidth / laneWidth; index++) {
    if (lane(value, index, laneWidth) === 0n) return 0;
  }
  return 1;
}

let state = 0x243f_6a88_85a3_08d3n;
function nextU32() {
  state = u64(state + 0x9e37_79b9_7f4a_7c15n);
  let z = state;
  z = u64((z ^ (z >> 30n)) * 0xbf58_476d_1ce4_e5b9n);
  z = u64((z ^ (z >> 27n)) * 0x94d0_49bb_1331_11ebn);
  return Number((z ^ (z >> 31n)) & MASK32);
}
function nextU64() {
  return (BigInt(nextU32()) << 32n) | BigInt(nextU32());
}

let checks = 0;
function check(label, actual, expected) {
  checks++;
  if (actual !== expected) {
    throw new Error(`${label}: expected ${expected}, got ${actual}`);
  }
}

const edge32 = [0n, 1n, MASK32, 0x8000_0000n, 0x7fff_ffffn, 0x0080_7f01n, 0xff00_00ffn];
const edge64 = [0n, 1n, MASK64, 0x8000_0000_0000_0000n, 0x7fff_ffff_ffff_ffffn, 0x0080_7f01_ff00_aa55n, 0xff00_00ff_8000_7f01n];

function checkExtendedInteger(totalWidth, laneWidth, signedPrefix, unsignedPrefix, a, b) {
  const wasm = totalWidth === 32
    ? (name, left, right) => wasmU32(name, i32arg(left), i32arg(right))
    : (name, left, right) => wasmU64(name, i64arg(left), i64arg(right));
  const wasmUnary = totalWidth === 32
    ? (name, value) => wasmU32(name, i32arg(value))
    : (name, value) => wasmU64(name, i64arg(value));
  const expected = (value) => totalWidth === 32 ? Number(BigInt.asUintN(32, value)) : BigInt.asUintN(64, value);
  const signedComparisons = {
    ne: (x, y) => x !== y,
    lt: (x, y) => x < y,
    le: (x, y) => x <= y,
    gt: (x, y) => x > y,
    ge: (x, y) => x >= y,
  };
  const unsignedComparisons = signedComparisons;

  check(`${signedPrefix} eq`, wasm(`t_${signedPrefix}_eq`, a, b), expected(compareLanes(totalWidth, laneWidth, a, b, true, (x, y) => x === y)));
  check(`${signedPrefix} mul`, wasm(`t_${signedPrefix}_mul`, a, b), expected(mulLanes(totalWidth, laneWidth, a, b)));
  check(`${signedPrefix} min`, wasm(`t_${signedPrefix}_min`, a, b), expected(minLanes(totalWidth, laneWidth, a, b, true)));
  check(`${signedPrefix} max`, wasm(`t_${signedPrefix}_max`, a, b), expected(maxLanes(totalWidth, laneWidth, a, b, true)));
  check(`${signedPrefix} abs`, wasmUnary(`t_${signedPrefix}_abs`, a), expected(absLanes(totalWidth, laneWidth, a)));
  check(`${signedPrefix} neg`, wasmUnary(`t_${signedPrefix}_neg`, a), expected(negLanes(totalWidth, laneWidth, a)));
  check(`${signedPrefix} add_sat`, wasm(`t_${signedPrefix}_add_sat`, a, b), expected(addSatLanes(totalWidth, laneWidth, a, b, true)));
  check(`${signedPrefix} sub_sat`, wasm(`t_${signedPrefix}_sub_sat`, a, b), expected(subSatLanes(totalWidth, laneWidth, a, b, true)));
  check(`${signedPrefix} bitmask`, wasmU32(`t_${signedPrefix}_bitmask`, totalWidth === 32 ? i32arg(a) : i64arg(a)), bitmaskLanes(totalWidth, laneWidth, a));
  check(`${signedPrefix} all_true`, e[`t_${signedPrefix}_all_true`](totalWidth === 32 ? i32arg(a) : i64arg(a)), allTrueLanes(totalWidth, laneWidth, a));
  for (const [name, predicate] of Object.entries(signedComparisons)) {
    check(`${signedPrefix} ${name}`, wasm(`t_${signedPrefix}_${name}`, a, b), expected(compareLanes(totalWidth, laneWidth, a, b, true, predicate)));
  }

  check(`${unsignedPrefix} eq`, wasm(`t_${unsignedPrefix}_eq`, a, b), expected(compareLanes(totalWidth, laneWidth, a, b, false, (x, y) => x === y)));
  check(`${unsignedPrefix} mul`, wasm(`t_${unsignedPrefix}_mul`, a, b), expected(mulLanes(totalWidth, laneWidth, a, b)));
  check(`${unsignedPrefix} min`, wasm(`t_${unsignedPrefix}_min`, a, b), expected(minLanes(totalWidth, laneWidth, a, b, false)));
  check(`${unsignedPrefix} max`, wasm(`t_${unsignedPrefix}_max`, a, b), expected(maxLanes(totalWidth, laneWidth, a, b, false)));
  check(`${unsignedPrefix} avgr`, wasm(`t_${unsignedPrefix}_avgr`, a, b), expected(avgrULanes(totalWidth, laneWidth, a, b)));
  check(`${unsignedPrefix} add_sat`, wasm(`t_${unsignedPrefix}_add_sat`, a, b), expected(addSatLanes(totalWidth, laneWidth, a, b, false)));
  check(`${unsignedPrefix} sub_sat`, wasm(`t_${unsignedPrefix}_sub_sat`, a, b), expected(subSatLanes(totalWidth, laneWidth, a, b, false)));
  check(`${unsignedPrefix} bitmask`, wasmU32(`t_${unsignedPrefix}_bitmask`, totalWidth === 32 ? i32arg(a) : i64arg(a)), bitmaskLanes(totalWidth, laneWidth, a));
  check(`${unsignedPrefix} all_true`, e[`t_${unsignedPrefix}_all_true`](totalWidth === 32 ? i32arg(a) : i64arg(a)), allTrueLanes(totalWidth, laneWidth, a));
  for (const [name, predicate] of Object.entries(unsignedComparisons)) {
    check(`${unsignedPrefix} ${name}`, wasm(`t_${unsignedPrefix}_${name}`, a, b), expected(compareLanes(totalWidth, laneWidth, a, b, false, predicate)));
  }
}

function checkSwar32(a, b, index, shift, lane8, lane16) {
  const ai = i32arg(a);
  const bi = i32arg(b);
  check("s32 splat i8", wasmU32("s32_splat_i8", Number(BigInt.asIntN(8, BigInt(lane8)))), Number(splat(32, 8, lane8)));
  check("s32 splat i16", wasmU32("s32_splat_i16", Number(BigInt.asIntN(16, BigInt(lane16)))), Number(splat(32, 16, lane16)));
  check("s32 extract i8 s", e.s32_extract_i8_s(ai, index), Number(signedLane(a, index & 3, 8)));
  check("s32 extract i8 u", e.s32_extract_i8_u(ai, index), Number(lane(a, index & 3, 8)));
  check("s32 extract i16 s", e.s32_extract_i16_s(ai, index), Number(signedLane(a, index & 1, 16)));
  check("s32 extract i16 u", e.s32_extract_i16_u(ai, index), Number(lane(a, index & 1, 16)));
  check("s32 replace i8", wasmU32("s32_replace_i8", ai, index, Number(BigInt.asIntN(8, BigInt(lane8)))), Number(replace(32, 8, a, index, lane8)));
  check("s32 replace i16", wasmU32("s32_replace_i16", ai, index, Number(BigInt.asIntN(16, BigInt(lane16)))), Number(replace(32, 16, a, index, lane16)));
  check("s32 add i8", wasmU32("s32_add_i8", ai, bi), Number(addLanes(32, 8, a, b)));
  check("s32 sub i8", wasmU32("s32_sub_i8", ai, bi), Number(subLanes(32, 8, a, b)));
  check("s32 add i16", wasmU32("s32_add_i16", ai, bi), Number(addLanes(32, 16, a, b)));
  check("s32 sub i16", wasmU32("s32_sub_i16", ai, bi), Number(subLanes(32, 16, a, b)));
  check("s32 shl i8", wasmU32("s32_shl_i8", ai, shift), Number(shlLanes(32, 8, a, shift)));
  check("s32 shr i8 s", wasmU32("s32_shr_i8_s", ai, shift), Number(shrSLanes(32, 8, a, shift)));
  check("s32 shr i8 u", wasmU32("s32_shr_i8_u", ai, shift), Number(shrULanes(32, 8, a, shift)));
  check("s32 shl i16", wasmU32("s32_shl_i16", ai, shift), Number(shlLanes(32, 16, a, shift)));
  check("s32 shr i16 s", wasmU32("s32_shr_i16_s", ai, shift), Number(shrSLanes(32, 16, a, shift)));
  check("s32 shr i16 u", wasmU32("s32_shr_i16_u", ai, shift), Number(shrULanes(32, 16, a, shift)));
  check("s32 any true", e.s32_any_true(ai), a === 0n ? 0 : 1);
  check("s32 all true i8", e.s32_all_true_i8(ai), allTrueLanes(32, 8, a));
  check("s32 bitmask i8", wasmU32("s32_bitmask_i8", ai), bitmaskLanes(32, 8, a));
  check("s32 popcnt i8", wasmU32("s32_popcnt_i8", ai), Number(popcntI8(32, a)));
  check("s32 eq i8", wasmU32("s32_eq_i8", ai, bi), Number(eqI8(32, a, b)));
  checkExtendedInteger(32, 8, "i8x4", "u8x4", a, b);
  checkExtendedInteger(32, 16, "i16x2", "u16x2", a, b);
}

function checkSwar64(a, b, index, shift, lane8, lane16, lane32) {
  const ai = i64arg(a);
  const bi = i64arg(b);
  check("s64 splat i8", wasmU64("s64_splat_i8", Number(BigInt.asIntN(8, BigInt(lane8)))), splat(64, 8, lane8));
  check("s64 splat i16", wasmU64("s64_splat_i16", Number(BigInt.asIntN(16, BigInt(lane16)))), splat(64, 16, lane16));
  check("s64 splat i32", wasmU64("s64_splat_i32", i32arg(lane32)), splat(64, 32, lane32));
  check("s64 extract i8 s", e.s64_extract_i8_s(ai, index), Number(signedLane(a, index & 7, 8)));
  check("s64 extract i8 u", e.s64_extract_i8_u(ai, index), Number(lane(a, index & 7, 8)));
  check("s64 extract i16 s", e.s64_extract_i16_s(ai, index), Number(signedLane(a, index & 3, 16)));
  check("s64 extract i16 u", e.s64_extract_i16_u(ai, index), Number(lane(a, index & 3, 16)));
  check("s64 extract i32 s", u32(e.s64_extract_i32_s(ai, index)), u32(signedLane(a, index & 1, 32)));
  check("s64 extract i32 u", u32(e.s64_extract_i32_u(ai, index)), Number(lane(a, index & 1, 32)));
  check("s64 replace i8", wasmU64("s64_replace_i8", ai, index, Number(BigInt.asIntN(8, BigInt(lane8)))), replace(64, 8, a, index, lane8));
  check("s64 replace i16", wasmU64("s64_replace_i16", ai, index, Number(BigInt.asIntN(16, BigInt(lane16)))), replace(64, 16, a, index, lane16));
  check("s64 replace i32", wasmU64("s64_replace_i32", ai, index, i32arg(lane32)), replace(64, 32, a, index, lane32));
  for (const width of [8, 16, 32]) {
    check(`s64 add i${width}`, wasmU64(`s64_add_i${width}`, ai, bi), addLanes(64, width, a, b));
    check(`s64 sub i${width}`, wasmU64(`s64_sub_i${width}`, ai, bi), subLanes(64, width, a, b));
    check(`s64 shl i${width}`, wasmU64(`s64_shl_i${width}`, ai, shift), shlLanes(64, width, a, shift));
    check(`s64 shr i${width} s`, wasmU64(`s64_shr_i${width}_s`, ai, shift), shrSLanes(64, width, a, shift));
    check(`s64 shr i${width} u`, wasmU64(`s64_shr_i${width}_u`, ai, shift), shrULanes(64, width, a, shift));
  }
  check("s64 any true", e.s64_any_true(ai), a === 0n ? 0 : 1);
  check("s64 all true i8", e.s64_all_true_i8(ai), allTrueLanes(64, 8, a));
  check("s64 bitmask i8", wasmU32("s64_bitmask_i8", ai), bitmaskLanes(64, 8, a));
  check("s64 popcnt i8", wasmU64("s64_popcnt_i8", ai), popcntI8(64, a));
  check("s64 eq i8", wasmU64("s64_eq_i8", ai, bi), eqI8(64, a, b));
  checkExtendedInteger(64, 8, "i8x8", "u8x8", a, b);
  checkExtendedInteger(64, 16, "i16x4", "u16x4", a, b);
  checkExtendedInteger(64, 32, "i32x2", "u32x2", a, b);
}

for (const a of edge32) {
  for (const b of edge32) checkSwar32(a, b, Number(a & 7n), Number(b & 31n), Number(a & 0xffn), Number(b & 0xffffn));
}
for (const a of edge64) {
  for (const b of edge64) checkSwar64(a, b, Number(a & 15n), Number(b & 63n), Number(a & 0xffn), Number(b & 0xffffn), Number(a & MASK32));
}
for (let run = 0; run < 256; run++) {
  const a64 = nextU64();
  const b64 = nextU64();
  const a32 = a64 & MASK32;
  const b32 = b64 & MASK32;
  const index = nextU32() & 15;
  const shift = nextU32() & 63;
  const lane8 = nextU32() & 0xff;
  const lane16 = nextU32() & 0xffff;
  const lane32 = nextU32();
  checkSwar32(a32, b32, index, shift, lane8, lane16);
  checkSwar64(a64, b64, index, shift, lane8, lane16, lane32);
}

console.log(`SWAR parity passed: ${checks} checks`);
