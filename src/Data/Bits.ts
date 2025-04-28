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

export const read_impl = (size: number) => (index: number) => (bits: Bits) =>
  bits.seek(index).read(size);

export const read_signed_impl =
  (size: number) => (index: number) => (bits: Bits) => {
    const shift = 32 - size;
    return (bits.seek(index).read(size) << shift) >> shift;
  };

export const length = (bits: Bits) => bits._length;

export const read_u64_impl = (index: number) => (bits: Bits) => {
  const upper = BigInt(bits.seek(index).read(32));
  return (upper << 32n) | BigInt(bits.read(32));
};

export const read_i64_impl = (index: number) => (bits: Bits) =>
  BigInt.asIntN(64, read_u64_impl(index)(bits));

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

export const read_utf8_char_impl = (index: number) => (bits: Bits) => {
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

export const from_buffer_impl = (buffer: Uint8Array) =>
  new Bits(Buffer.from(buffer));

export const from_words = (word_size: number) => (words: ArrayLike<number>) => {
  const bits = new Bits(word_size * words.length);
  for (let i = 0; i < words.length; i++) {
    bits.write(words[i]!, word_size);
  }
  return bits;
};

export const to_words = (word_size: number) => (bits: Bits) => {
  const result = [] as number[];
  bits.seek(0);
  while (true) {
    if (bits.remaining) {
      const word = bits.read(Math.min(word_size, bits.remaining));
      result.push(word);
    } else return result;
  }
};

// This buffer is literally used just for conversions to floats
const temp = Buffer.allocUnsafe(8);

const read_u8_impl = read_impl(8);
const read_u16_impl = read_impl(16);
const read_u32_impl = read_impl(32);

export const read_f32_impl = (index: number) => (bits: Bits) => {
  temp.writeUint32LE(read_u32_impl(index)(bits), 0);
  return temp.readFloatLE(0);
};

export const read_f64_impl = (index: number) => (bits: Bits) => {
  temp.writeBigUInt64LE(read_u64_impl(index)(bits), 0);
  return temp.readDoubleLE(0);
};

export const bits_to_hex = (bits: Bits) => bits.toString("hex");

export const concat_bits = (l: Bits) => (r: Bits) => {
  const result = new Bits(l._bitLength + r._bitLength);
  append_bits(result)(l);
  append_bits(result)(r);
  return result.seek(0);
};

const grow = (new_size: number) => (bits: Bits) => {
  if (new_size > bits.buffer.byteLength << 3) {
    const new_byte_count = 1 + (new_size >>> 2); // size / 8 * 2
    const buffer = Buffer.alloc(new_byte_count);
    buffer.set(bits.buffer, 0);
    const new_bits = new Bits(buffer);
    new_bits._offset = bits._offset;
    new_bits._bitLength = new_size;
    return new_bits;
  }

  bits._bitLength = new_size;
  return bits;
};

export const append_bits = (l: Bits) => (r: Bits) => {
  const target_length = l.bitLength + r.bitLength;
  const target = target_length > l.bitLength ? l : grow(target_length)(l);

  // Appending bits assumes
  // - l is mutable, and is being assembled as part of a full concat operation
  // - all the bits from r will be copied into l
  // - l is big enough to contain everything from r

  // keep track of how many are left
  let bitsLeft = r.bitLength;

  // align l to 8 bits
  const nextBitAlignment = 8 - (target.bitLength % 8);

  // at most 32 bits to start writing. This will either:
  // - Bring l to the next 32 bit aligned location, or
  // - write all the bits from r and then exit
  const startBitCount = Math.min(nextBitAlignment, bitsLeft);

  // Read the bits from r, and then write them into the buffer
  let value = r.seek(0).read(startBitCount);

  // write startBitCount bits into l, and reduce the number of bits left
  target.write(value, startBitCount);
  let offset = target.offset;
  bitsLeft -= startBitCount;
  while (bitsLeft >= 64) {
    const currentByte = offset >>> 3;
    const value = read_u64_impl(currentByte)(r);
    target.buffer.writeBigUInt64LE(value, currentByte);

    bitsLeft -= 64;
    offset += 64;
  }

  if (bitsLeft >= 32) {
    const currentByte = offset >>> 3;
    value = r.read(32);

    // wherever r is in terms of it's offset, we can read 32 bits from r and
    // manually write that value into l using the Buffer api. However, it won't
    // advance l's internal offset.
    target.buffer.writeUInt32LE(value, currentByte);

    // reduce the number of bits left and advance the counter
    bitsLeft -= 32;
    offset += 32;
  }

  target.offset = offset;
  if (bitsLeft === 0) return target;

  value = r.read(bitsLeft);
  target.write(value, bitsLeft);
  return target;
};

export const read_buffer_impl =
  (index: number) => (bytes: number) => (bits: Bits) => {
    let bits_left = Math.min(bytes * 8, bits.remaining);
    const total_bytes = bits_left / 8 + Math.min(bits_left & 7, 1);
    const buffer = Buffer.alloc(total_bytes);
    let offset = index;
    let cursor = 0;

    while (bits_left >= 64) {
      buffer.writeBigUInt64LE(read_u64_impl(offset)(bits), cursor);

      cursor += 8;
      offset += 64;
      bits_left -= 64;
    }

    if (bits_left >= 32) {
      buffer.writeUInt32LE(read_u32_impl(offset)(bits), cursor);

      cursor += 4;
      offset += 32;
      bits_left -= 32;
    }

    if (bits_left >= 16) {
      buffer.writeUInt16LE(read_u16_impl(offset)(bits), cursor);

      cursor += 2;
      offset += 16;
      bits_left -= 16;
    }

    if (bits_left >= 8) {
      buffer.writeUInt8(read_u8_impl(offset)(bits), cursor);

      cursor += 1;
      offset += 8;
      bits_left -= 8;
    }

    // the last_value itself must be shifted to align with the buffer
    // except that there may only be a partial byte left
    if (bits_left > 0) {
      const last_value = read_impl(bits_left)(offset)(bits);
      buffer.writeUInt8(last_value << (8 - bits_left), cursor);
    }

    return buffer;
  };

export const offset_impl = (bits: Bits) => bits.offset;

export const write_string_impl = (str: string) => (bits: Bits) => {
  const contents = new Bits(Buffer.from(str));
  return append_bits(bits)(contents);
};

export const write_impl = (size: number) => (value: number) => (bits: Bits) => {
  const target = grow(size + bits._bitLength)(bits);
  return target.write(value, size);
};
export const write_64 = (value: bigint) => (bits: Bits) => {
  const target = grow(64 + bits._bitLength)(bits);
  const cast = BigInt.asUintN(64, value);
  return target
    .write(Number(cast >> 32n), 32)
    .write(Number(cast & 0xffff_ffffn), 32);
};

// foreign import read_string_impl :: ByteLength -> Bits -> Maybe String -> (String -> Maybe String) -> Maybe String
export const read_string_impl =
  <t>(byte_length: number) =>
  (offset: number) =>
  (bits: Bits) =>
  (nothing: t) =>
  (just: (value: string) => t) => {
    if ((byte_length << 3) + offset < bits._bitLength) return nothing;
    const buffer = read_buffer_impl(offset)(byte_length)(bits);
    try {
      return just(buffer.toString("utf8"));
    } catch (_) {
      return nothing;
    }
  };

export const ord_bits_impl = (bits_l: Bits) => (bits_r: Bits) => {
  if (bits_l._bitLength > bits_r._bitLength) return 1;
  if (bits_l._bitLength < bits_r._bitLength) return -1;

  let remaining = bits_l._bitLength;
  let at = 0;
  while (remaining > 64) {
    const left = read_u64_impl(at)(bits_l);
    const right = read_u64_impl(at)(bits_r);
    if (left > right) return 1;
    if (left < right) return -1;
    remaining -= 64;
    at += 64;
  }

  if (remaining > 32) {
    const left = read_u32_impl(at)(bits_l);
    const right = read_u32_impl(at)(bits_r);
    if (left > right) return 1;
    if (left < right) return -1;
    remaining -= 32;
    at += 32;
  }

  if (remaining > 0) {
    const left = read_impl(remaining)(at)(bits_l);
    const right = read_impl(remaining)(at)(bits_r);
    if (left > right) return 1;
    if (left < right) return -1;
  }

  return 0;
};

export const eq_bits = (bits_l: Bits) => (bits_r: Bits) =>
  ord_bits_impl(bits_l)(bits_r) === 0;
