import * as B from "@fry/bits";

// TODO: Implement writer maybe?
const Bits = B.Bits;

/** @type {(size: number) => Bits} */
export const zeros = (size) => new Bits(size);

/** @type {Bits} */
export const empty = new Bits(0);

/** @type {(size: number) => (index: number) => (bits: Bits) => number} */
export const read = (size) => (index) => (bits) => bits.seek(index).read(size);

/** @type {(size: number) => (index: number) => (bits: Bits) => number} */
export const read_signed = (size) => (index) => (bits) => {
  const shift = 32 - size;
  return (bits.seek(index).read(size) << shift) >> shift;
};

/** @type {(bits: Bits) => number} */
export const length = (bits) => bits._length;

/** @type {ReturnType<read>} */
export const read_u8 = read(8);
/** @type {ReturnType<read>} */
export const read_u16 = read(16);
/** @type {ReturnType<read>} */
export const read_u32 = read(32);

/** @type{(index: number) => (bits: Bits) => BigInt} */
export const read_u64 = (index) => (bits) => {
  const upper = BigInt(bits.seek(index).read(32));
  return (upper << 32n) | BigInt(bits.read(32));
};

/** @type {ReturnType<read>} */
export const read_i8 = read_signed(8);
/** @type {ReturnType<read>} */
export const read_i16 = read_signed(16);
/** @type {ReturnType<read>} */
export const read_i32 = read_signed(32);

/** @type{(index: number) => (bits: Bits) => BigInt} */
export const read_i64 = (index) => (bits) =>
  BigInt.asIntN(64, read_u64(index)(bits));

const TOP_FIVE = 0b1111_1000;
const TOP_FOUR = 0b1111_0000;
const TOP_THREE = 0b1110_0000;
const TOP_TWO = 0b1100_0000;
const BOTTOM_FIVE = 0b0001_1111;
const BOTTOM_TWO = 0b0000_0011;
const BOTTOM_SIX = 0b0011_1111;

/** @type{(index:number) => (bits: Bits) => number} */
export const read_utf8_char = (index) => (bits) => {
  if (bits.seek(index).remaining < 8) return -1;

  // ascii character short circut
  const byte = bits.read(8);
  if (byte < 0x80) return byte;

  const extra_bytes =
    (((byte & TOP_FIVE) === TOP_FOUR) * 3) |
    (((byte & TOP_FOUR) === TOP_THREE) * 2) |
    (((byte & TOP_THREE) === TOP_TWO) * 1);
  const remaining = bits.remaining;
  if (extra_bytes === 0 || remaining < extra_bytes * 8) return -1;

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
    (((extra_bytes <= 2) |
      ((extra_bytes === 3) & (((rest >>> 22) & BOTTOM_TWO) === 0b10))) &
      // Byte 2 (0b10xxxxxx) matches, but only if extra bytes is >= 2 (otherwise valid)
      ((extra_bytes === 1) |
        ((extra_bytes >= 2) & (((rest >>> (8 + 6)) & BOTTOM_TWO) === 0b10))) &
      // always check Byte 3
      (((rest >>> 6) & BOTTOM_TWO) === 0b10)) -
    1;

  return (
    all_valid_mask |
    // top bits
    ((byte & (BOTTOM_FIVE >>> (extra_bytes - 1))) << (extra_bytes * 6)) |
    // bits from byte 1 (if extra === 3)
    (((extra_bytes === 3) * ((rest >>> 16) & BOTTOM_SIX)) << 12) |
    // bits from byte 2 (if extra >= 2)
    (((extra_bytes >= 2) * ((rest >>> 8) & BOTTOM_SIX)) << 6) |
    // final bottom six bits
    (rest & BOTTOM_SIX)
  );
};

/** @type {(str: string) => Bits} */
export const from_string = (str) => new Bits(Buffer.from(str));

/** @type {(buffer: Uint8Array) => Bits} */
export const from_buffer = (buffer) => Buffer.from(buffer);

/** @type {(word_size: number) => (words: ArrayLike<number>) => Bits} */
export const from_words = (word_size) => (words) => {
  const bits = new Bits(word_size * words.length);
  for (let i = 0; i < words.length; i++) {
    bits.write(words[i], size);
  }
  return bits;
};

// This buffer is literally used just for conversions to floats
const temp = Buffer.allocUnsafe(8);

/** @type {(index: number) => (bits: Bits) => number} */
export const read_f32 = (index) => (bits) => {
  temp.writeUint32LE(read_u32(index)(bits), 0);
  return temp.readFloatLE(0);
};

/** @type {(index: number) => (bits: Bits) => number} */
export const read_f64 = (index) => (bits) => {
  temp.writeBigUInt64LE(read_u64(index)(bits), 0);
  return temp.readDoubleLE(0);
};

/** @type {(bits: Bits) => string} */
export const bits_to_hex = (bits) => bits.toString("hex");

/** @type {(l: Bits) => (r: Bits) => boolean} */
export const bits_eq = (l) => (r) =>
  l.offset === r.offset && Buffer.compare(l.buffer, r.buffer) === 0;

/** @type {(l: Bits) => (r: Bits) => Bits} */
export const concat_bits = (l) => (r) => {
  const buffer = Buffer.concat([l.buffer, r.buffer]);
  return new Bits(buffer);
};
