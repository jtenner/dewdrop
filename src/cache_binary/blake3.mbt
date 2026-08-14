///|
/// BLAKE3 flags from the public BLAKE3 specification.
let blake3_chunk_start = 1U

///|
let blake3_chunk_end = 2U

///|
let blake3_parent = 4U

///|
let blake3_root = 8U

///|
let blake3_iv : FixedArray[UInt] = [
  0x6a09e667U, 0xbb67ae85U, 0x3c6ef372U, 0xa54ff53aU, 0x510e527fU, 0x9b05688cU, 0x1f83d9abU,
  0x5be0cd19U,
]

///|
let blake3_message_permutation : FixedArray[Int] = [
  2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8,
]

///|
priv struct Blake3Output {
  input_chaining_value : FixedArray[UInt]
  block_words : FixedArray[UInt]
  counter : UInt64
  block_length : UInt
  flags : UInt
}

///|
fn blake3_rotate_right(value : UInt, count : Int) -> UInt {
  (value >> count) | (value << (32 - count))
}

///|
fn blake3_mix(
  state : FixedArray[UInt],
  a : Int,
  b : Int,
  c : Int,
  d : Int,
  left : UInt,
  right : UInt,
) -> Unit {
  state[a] = state[a] + state[b] + left
  state[d] = blake3_rotate_right(state[d] ^ state[a], 16)
  state[c] = state[c] + state[d]
  state[b] = blake3_rotate_right(state[b] ^ state[c], 12)
  state[a] = state[a] + state[b] + right
  state[d] = blake3_rotate_right(state[d] ^ state[a], 8)
  state[c] = state[c] + state[d]
  state[b] = blake3_rotate_right(state[b] ^ state[c], 7)
}

///|
fn blake3_round(state : FixedArray[UInt], message : FixedArray[UInt]) -> Unit {
  blake3_mix(state, 0, 4, 8, 12, message[0], message[1])
  blake3_mix(state, 1, 5, 9, 13, message[2], message[3])
  blake3_mix(state, 2, 6, 10, 14, message[4], message[5])
  blake3_mix(state, 3, 7, 11, 15, message[6], message[7])
  blake3_mix(state, 0, 5, 10, 15, message[8], message[9])
  blake3_mix(state, 1, 6, 11, 12, message[10], message[11])
  blake3_mix(state, 2, 7, 8, 13, message[12], message[13])
  blake3_mix(state, 3, 4, 9, 14, message[14], message[15])
}

///|
fn blake3_permute(message : FixedArray[UInt]) -> FixedArray[UInt] {
  let permuted = FixedArray::make(16, 0U)
  for index in 0..<16 {
    permuted[index] = message[blake3_message_permutation[index]]
  }
  permuted
}

///|
fn blake3_compress(
  output : Blake3Output,
  root_counter? : UInt64 = output.counter,
) -> FixedArray[UInt] {
  let state = FixedArray::make(16, 0U)
  for index in 0..<8 {
    state[index] = output.input_chaining_value[index]
  }
  for index in 0..<4 {
    state[8 + index] = blake3_iv[index]
  }
  state[12] = root_counter.to_uint()
  state[13] = (root_counter >> 32).to_uint()
  state[14] = output.block_length
  state[15] = output.flags
  let mut message = output.block_words
  for round in 0..<7 {
    blake3_round(state, message)
    if round != 6 {
      message = blake3_permute(message)
    }
  }
  let result = FixedArray::make(16, 0U)
  for index in 0..<8 {
    result[index] = state[index] ^ state[index + 8]
    result[index + 8] = state[index + 8] ^ output.input_chaining_value[index]
  }
  result
}

///|
fn Blake3Output::chaining_value(self : Blake3Output) -> FixedArray[UInt] {
  let words = blake3_compress(self)
  let output = FixedArray::make(8, 0U)
  for index in 0..<8 {
    output[index] = words[index]
  }
  output
}

///|
fn Blake3Output::root_digest(self : Blake3Output) -> FixedArray[Byte] {
  let rooted = { ..self, flags: self.flags | blake3_root }
  let words = blake3_compress(rooted, root_counter=0UL)
  let digest = FixedArray::make(32, (0 : Byte))
  for index in 0..<8 {
    let word = words[index]
    digest[index * 4] = (word & 0xffU).to_byte()
    digest[index * 4 + 1] = ((word >> 8) & 0xffU).to_byte()
    digest[index * 4 + 2] = ((word >> 16) & 0xffU).to_byte()
    digest[index * 4 + 3] = ((word >> 24) & 0xffU).to_byte()
  }
  digest
}

///|
fn blake3_block_words(
  input : Bytes,
  start : Int,
  length : Int,
) -> FixedArray[UInt] {
  let words = FixedArray::make(16, 0U)
  for byte_index in 0..<length {
    let word_index = byte_index / 4
    let shift = byte_index % 4 * 8
    words[word_index] = words[word_index] |
      (input[start + byte_index].to_uint() << shift)
  }
  words
}

///|
fn blake3_chunk_output(
  input : Bytes,
  start : Int,
  length : Int,
  chunk_counter : UInt64,
) -> Blake3Output {
  let block_count = if length == 0 { 1 } else { (length + 63) / 64 }
  let chaining_value = FixedArray::make(8, 0U)
  for index in 0..<8 {
    chaining_value[index] = blake3_iv[index]
  }
  let mut final_output : Blake3Output = {
    input_chaining_value: chaining_value,
    block_words: FixedArray::make(16, 0U),
    counter: chunk_counter,
    block_length: 0U,
    flags: blake3_chunk_start | blake3_chunk_end,
  }
  for block_index in 0..<block_count {
    let block_start = start + block_index * 64
    let remaining = length - block_index * 64
    let block_length = if remaining <= 0 {
      0
    } else if remaining < 64 {
      remaining
    } else {
      64
    }
    let mut flags = 0U
    if block_index == 0 {
      flags = flags | blake3_chunk_start
    }
    if block_index + 1 == block_count {
      flags = flags | blake3_chunk_end
    }
    final_output = {
      input_chaining_value: chaining_value.copy(),
      block_words: blake3_block_words(input, block_start, block_length),
      counter: chunk_counter,
      block_length: block_length.reinterpret_as_uint(),
      flags,
    }
    if block_index + 1 != block_count {
      let next = final_output.chaining_value()
      for index in 0..<8 {
        chaining_value[index] = next[index]
      }
    }
  }
  final_output
}

///|
fn blake3_parent_output(
  left : FixedArray[UInt],
  right : FixedArray[UInt],
) -> Blake3Output {
  let block = FixedArray::make(16, 0U)
  for index in 0..<8 {
    block[index] = left[index]
    block[index + 8] = right[index]
  }
  {
    input_chaining_value: blake3_iv.copy(),
    block_words: block,
    counter: 0UL,
    block_length: 64U,
    flags: blake3_parent,
  }
}

///|
/// Portable BLAKE3-256. Its 32-bit add/XOR/rotate compression is designed for
/// SIMD implementations, while this scalar form remains identical on every
/// MoonBit target.
pub fn blake3(input : Bytes) -> FixedArray[Byte] {
  let chunk_count = if input.length() == 0 {
    1
  } else {
    (input.length() + 1023) / 1024
  }
  if chunk_count == 1 {
    return blake3_chunk_output(input, 0, input.length(), 0UL).root_digest()
  }
  let level : Array[FixedArray[UInt]] = []
  for chunk_index in 0..<chunk_count {
    let start = chunk_index * 1024
    let remaining = input.length() - start
    let length = if remaining < 1024 { remaining } else { 1024 }
    level.push(
      blake3_chunk_output(input, start, length, chunk_index.to_uint64()).chaining_value(),
    )
  }
  let mut current = level
  let mut root : Blake3Output? = None
  while current.length() > 1 {
    let next : Array[FixedArray[UInt]] = []
    let mut index = 0
    while index < current.length() {
      if index + 1 == current.length() {
        next.push(current[index])
        index += 1
      } else {
        let parent = blake3_parent_output(current[index], current[index + 1])
        root = Some(parent)
        next.push(parent.chaining_value())
        index += 2
      }
    }
    current = next
  }
  match root {
    Some(value) => value.root_digest()
    None => abort("BLAKE3 tree root is missing")
  }
}

///|
pub fn blake3_hash32(input : Bytes) -> UInt {
  let digest = blake3(input)
  digest[0].to_uint() |
  (digest[1].to_uint() << 8) |
  (digest[2].to_uint() << 16) |
  (digest[3].to_uint() << 24)
}
