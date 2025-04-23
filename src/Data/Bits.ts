import * as B from "@fry/bits";

class Bits extends B.Bits {
  constructor(value: Buffer | number) {
    super(value);

    this._bitLength =
      typeof value === "number" && Number.isFinite(value)
        ? value
        : (value as Buffer).byteLength;
  }
  _bitLength = 0;

  get bitLength() {
    return this._bitLength;
  }

  set bitLength(value) {
    this._bitLength = value;
  }
}

export const zeros = (size: number) => new Bits(size);

export const empty = new Bits(0);

export const read = (size: number) => (index: number) => (bits: Bits) =>
  bits.seek(index).read(size);

export const read_signed =
  (size: number) => (index: number) => (bits: Bits) => {
    const shift = 32 - size;
    return (bits.seek(index).read(size) << shift) >> shift;
  };

export const length = (bits: Bits) => bits._length;
export const read_u8 = read(8);
export const read_u16 = read(16);
export const read_u32 = read(32);
export const read_u64 = (index: number) => (bits: Bits) => {
  const upper = BigInt(bits.seek(index).read(32));
  return (upper << 32n) | BigInt(bits.read(32));
};

export const read_i8 = read_signed(8);
export const read_i16 = read_signed(16);
export const read_i32 = read_signed(32);
export const read_i64 = (index: number) => (bits: Bits) =>
  BigInt.asIntN(64, read_u64(index)(bits));

export const write =
  (size: number) => (index: number) => (value: number) => (bits: Bits) =>
    bits.seek(index).write(value, size);

const TOP_FIVE = 0b1111_1000;
const TOP_FOUR = 0b1111_0000;
const TOP_THREE = 0b1110_0000;
const TOP_TWO = 0b1100_0000;
const BOTTOM_FIVE = 0b0001_1111;
const BOTTOM_TWO = 0b0000_0011;
const BOTTOM_SIX = 0b0011_1111;

// 0b0aaaaaaa <- ASCII
// 0b110b_bbbb 0b10bb_bbbb <- two bytes (bbbbb << 6 | bbbbbb)
// 0b1110_cccc 0b10cc_cccc 0b10cc_cccc <- three bytes
// 0b1111_0ddd 0b10dd_dddd 0b10dd_dddd 0b10dd_dddd <- four bytes

// one byte starts with 0
// two bytes starts with 110
// three bytes starts with 1110
// four bytes starts with 11110

export const read_utf8_char = (index: number) => (bits: Bits) => {
  if (bits.seek(index).remaining < 8) return -1;

  // ascii character short circut
  const byte = bits.read(8);
  if (byte < 0x80) return byte;

  const extra_bytes =
    // 0b1111_0ddd & 0b1111_1000 === 0b1111_0000
    // @ts-expect-error: (bool * number) === number
    (((byte & TOP_FIVE) === TOP_FOUR) * 3) |
    // 0b1110_cccc & 0b1111_0000 === 0b1110_0000
    // @ts-expect-error: (bool * number) === number
    (((byte & TOP_FOUR) === TOP_THREE) * 2) |
    // 0b110b_bbbb & 0b1110_0000 === 0b1100_0000
    // @ts-expect-error: (bool * number) === number
    (((byte & TOP_THREE) === TOP_TWO) * 1);
  const remaining = bits.remaining;
  if (extra_bytes === 0 || remaining < extra_bytes * 8) return -1;

  // up to the next 24 bits
  const rest = bits.read(8 * extra_bytes);

  // Byte one is okay if:
  // - (value >>> 22) & 0b11 === 0b10 and the extra bytes === 3
  // - or extra bytes < 3
  //
  // Byte two is okay if:
  // - (value >>> 14) & 0b11 === 0b10 and extra bytes >= 2
  // - or extra bytes === 1
  //
  // Byte three is valid if and only if:
  // - (value >>> 6) & 0b11 === 0b10
  //
  // The mask is calculated by performing (valid_3 & valid_2 & valid_1) - 1
  // which results in the following logic:
  //
  // - If all three bytes are valid utf8 encoded bytes, the result will yield 0
  // - If any of the bytes are invalid, the result yields -1
  //
  // Later, the calculation for the codepoint value is masked by a potential -1
  // which happens to represent an invalid codepoint. If the codepoint is valid,
  // the bitmask is 0 | n, which always returns n
  const all_valid_mask =
    // Byte 1 (0b10xxxxxx) matches, but only if extra bytes is 3 (otherwise valid)
    // @ts-expect-error: (boolean | number) === number
    (((extra_bytes <= 2) |
      // @ts-expect-error: (boolean & number) and (boolean & boolean) === number
      ((extra_bytes === 3) & (((rest >>> 22) & BOTTOM_TWO) === 0b10))) &
      // Byte 2 (0b10xxxxxx) matches, but only if extra bytes is >= 2 (otherwise valid)
      // @ts-expect-error: (boolean | number) === number
      ((extra_bytes === 1) |
        // @ts-expect-error: (boolean & number) and (boolean & boolean) === number
        ((extra_bytes >= 2) & (((rest >>> (8 + 6)) & BOTTOM_TWO) === 0b10))) &
      // always check Byte 3
      // @ts-expect-error: (boolean & number) === number
      (((rest >>> 6) & BOTTOM_TWO) === 0b10)) -
    1;

  return (
    all_valid_mask |
    // top bits
    ((byte & (BOTTOM_FIVE >>> (extra_bytes - 1))) << (extra_bytes * 6)) |
    // bits from byte 1 (if extra === 3)
    (((rest >>> 16) & BOTTOM_SIX) << 12) |
    // bits from byte 2 (if extra >= 2)
    (((rest >>> 8) & BOTTOM_SIX) << 6) |
    // final bottom six bits
    (rest & BOTTOM_SIX)
  );
};

export const from_string = (str: string) => new Bits(Buffer.from(str));

export const from_buffer = (buffer: Uint8Array) =>
  new Bits(Buffer.from(buffer));

export const from_words = (word_size: number) => (words: ArrayLike<number>) => {
  const bits = new Bits(word_size * words.length);
  for (let i = 0; i < words.length; i++) {
    bits.write(words[i]!, word_size);
  }
  return bits;
};

// This buffer is literally used just for conversions to floats
const temp = Buffer.allocUnsafe(8);

export const read_f32 = (index: number) => (bits: Bits) => {
  temp.writeUint32LE(read_u32(index)(bits), 0);
  return temp.readFloatLE(0);
};

export const read_f64 = (index: number) => (bits: Bits) => {
  temp.writeBigUInt64LE(read_u64(index)(bits), 0);
  return temp.readDoubleLE(0);
};

export const bits_to_hex = (bits: Bits) => bits.toString("hex");

export const bits_eq = (l: Bits) => (r: Bits) =>
  l.offset === r.offset && Buffer.compare(l.buffer, r.buffer) === 0;

export const concat_bits = (l: Bits) => (r: Bits) => {
  const result = new Bits(l._bitLength + r._bitLength);
  append_bits(result)(l);
  append_bits(result)(r);
  return result.seek(0);
};

export const append_bits = (l: Bits) => (r: Bits) => {
  // Appending bits assumes
  // - l is mutable, and is being assembled as part of a full concat operation
  // - all the bits from r will be copied into l
  // - l is big enough to contain everything from r

  // keep track of how many are left
  let bitsLeft = r.bitLength;

  // align l to 8 bits
  const nextBitAlignment = 8 - (l.bitLength % 8);

  // at most 32 bits to start writing. This will either:
  // - Bring l to the next 32 bit aligned location, or
  // - write all the bits from r and then exit
  const startBitCount = Math.min(nextBitAlignment, bitsLeft);

  // Read the bits from r, and then write them into the buffer
  let value = r.seek(0).read(startBitCount);

  // write startBitCount bits into l, and reduce the number of bits left
  l.write(value, startBitCount);
  let offset = l.offset;
  bitsLeft -= startBitCount;

  while (bitsLeft >= 64) {
    const currentByte = offset >>> 3;
    const value = read_u64(currentByte)(r);
    l.buffer.writeBigUInt64LE(value, currentByte);

    bitsLeft -= 64;
    offset += 64;
  }

  if (bitsLeft >= 32) {
    const currentByte = offset >>> 3;
    value = r.read(32);

    // wherever r is in terms of it's offset, we can read 32 bits from r and
    // manually write that value into l using the Buffer api. However, it won't
    // advance l's internal offset.
    l.buffer.writeUInt32LE(value, currentByte);

    bitsLeft -= 32;
    offset += 32;
  }

  l.offset = offset;
  if (bitsLeft === 0) return l;

  value = r.read(bitsLeft);
  l.write(value, bitsLeft);
  return l;
};
