///|
/// A decoded WTF-8 code point or a tagged tokenizer sentinel.
///
/// Values through U+10FFFF are decoded WTF-8 code points, including UTF-16
/// surrogates. Values above that range are reserved by this package.
pub type UtfCodepoint = UInt

///|
/// An absolute byte offset in the original WTF-8 input.
pub type ByteOffset = UInt64

///|
pub const MAX_WTF8_CODEPOINT : UtfCodepoint = 0x10FFFFU

///|
/// Base of the 256-value range used to preserve malformed raw bytes.
pub const INVALID_BYTE_BASE : UtfCodepoint = 0x110000U

///|
/// Base of the range used to report terminal source I/O errors.
pub const IO_ERROR_BASE : UtfCodepoint = 0x120000U

///|
/// Returns whether `value` is a decoded WTF-8 code point.
pub fn is_wtf8_codepoint(value : UtfCodepoint) -> Bool {
  value <= MAX_WTF8_CODEPOINT
}

///|
/// Returns whether `value` is a UTF-16 surrogate accepted by WTF-8.
pub fn is_surrogate(value : UtfCodepoint) -> Bool {
  value >= 0xD800U && value <= 0xDFFFU
}

///|
/// Returns whether `value` is a Unicode scalar value.
pub fn is_unicode_scalar(value : UtfCodepoint) -> Bool {
  is_wtf8_codepoint(value) && !is_surrogate(value)
}

///|
/// Returns whether `value` preserves one malformed source byte.
pub fn is_invalid_byte(value : UtfCodepoint) -> Bool {
  value >= INVALID_BYTE_BASE && value < INVALID_BYTE_BASE + 0x100U
}

///|
/// Extracts a preserved malformed source byte.
pub fn invalid_byte(value : UtfCodepoint) -> Byte? {
  guard is_invalid_byte(value) else { None }
  Some((value - INVALID_BYTE_BASE).to_byte())
}

///|
/// Returns whether `value` reports a terminal source I/O error.
pub fn is_io_error(value : UtfCodepoint) -> Bool {
  value >= IO_ERROR_BASE && value < IO_ERROR_BASE + 0x10000U
}

///|
/// Extracts the positive platform error code from an I/O sentinel.
pub fn io_error_code(value : UtfCodepoint) -> Int? {
  guard is_io_error(value) else { None }
  Some((value - IO_ERROR_BASE).reinterpret_as_int())
}

///|
/// A forward-only WTF-8 cursor.
///
/// `from_fd` allocates one reusable buffer and refills that same buffer for the
/// cursor's lifetime. `new` retains a caller-owned in-memory buffer without
/// copying it and is useful for tests and already-buffered sources.
pub struct Utf8Cursor {
  buffer : Bytes
  fd : Int
  refillable : Bool
  mut position : Int
  mut limit : Int
  mut base_offset : ByteOffset
  mut eof : Bool
  mut read_error : Int
  mut read_error_emitted : Bool
}

///|
/// Creates a cursor over an existing buffer without copying it.
pub fn Utf8Cursor::new(buffer : Bytes) -> Utf8Cursor {
  {
    buffer,
    fd: -1,
    refillable: false,
    position: 0,
    limit: buffer.length(),
    base_offset: 0UL,
    eof: true,
    read_error: 0,
    read_error_emitted: false,
  }
}

///|
/// Creates a cursor that repeatedly reads `fd` into one reusable buffer.
///
/// The default capacity is the host operating-system page size. The cursor
/// borrows the descriptor and never closes it.
pub fn Utf8Cursor::from_fd(fd : Int, buffer_size? : Int) -> Utf8Cursor {
  let capacity = match buffer_size {
    Some(size) => size
    None => tokenizer_platform_page_size()
  }
  guard capacity >= 4 else {
    abort("WTF-8 buffer capacity must be at least four bytes")
  }
  {
    buffer: Bytes::make(capacity, 0),
    fd,
    refillable: true,
    position: 0,
    limit: 0,
    base_offset: 0UL,
    eof: false,
    read_error: 0,
    read_error_emitted: false,
  }
}

///|
/// Returns the capacity of the retained or reusable byte buffer.
pub fn Utf8Cursor::buffer_capacity(self : Utf8Cursor) -> Int {
  self.buffer.length()
}

///|
/// Returns the absolute byte offset at which the next decode begins.
pub fn Utf8Cursor::byte_offset(self : Utf8Cursor) -> ByteOffset {
  self.base_offset + self.position.to_uint64()
}

///|
/// Returns the terminal descriptor error, if one occurred.
pub fn Utf8Cursor::read_error(self : Utf8Cursor) -> Int? {
  if self.read_error == 0 {
    None
  } else {
    Some(self.read_error)
  }
}

///|
/// Returns whether all input and any terminal I/O sentinel have been consumed.
pub fn Utf8Cursor::is_done(self : Utf8Cursor) -> Bool {
  self.eof &&
  self.position >= self.limit &&
  (self.read_error == 0 || self.read_error_emitted)
}

///|
/// Reads one buffered byte after the caller has established it is in bounds.
fn Utf8Cursor::byte_at(self : Utf8Cursor, index : Int) -> Int {
  self.buffer.unsafe_get(index).to_int()
}

///|
fn is_continuation(byte : Int) -> Bool {
  (byte & 0xC0) == 0x80
}

///|
/// Moves unread bytes to the beginning of the same reusable buffer.
fn Utf8Cursor::compact(self : Utf8Cursor) -> Unit {
  let consumed = self.position
  guard consumed > 0 else { return }
  let remaining = self.limit - consumed
  tokenizer_platform_move(self.buffer, 0, consumed, remaining)
  self.base_offset += consumed.to_uint64()
  self.position = 0
  self.limit = remaining
}

///|
/// Performs one read into free space in the existing buffer.
fn Utf8Cursor::refill_once(self : Utf8Cursor) -> Unit {
  guard self.refillable && !self.eof else { return }
  self.compact()
  let available = self.buffer.length() - self.limit
  guard available > 0 else { return }
  let count = tokenizer_platform_read(
    self.fd,
    self.buffer,
    self.limit,
    available,
  )
  if count > 0 {
    self.limit += count
  } else if count == 0 {
    self.eof = true
  } else {
    self.read_error = -count
    self.eof = true
  }
}

///|
/// Ensures that `needed` bytes are buffered from the current position.
fn Utf8Cursor::ensure(self : Utf8Cursor, needed : Int) -> Bool {
  while self.limit - self.position < needed && !self.eof {
    let old_limit = self.limit
    let old_position = self.position
    self.refill_once()
    if !self.eof && self.limit == old_limit && self.position == old_position {
      self.read_error = 5
      self.eof = true
    }
  }
  self.limit - self.position >= needed
}

///|
fn invalid_byte_sentinel(byte : Int) -> UtfCodepoint {
  INVALID_BYTE_BASE + byte.reinterpret_as_uint()
}

///|
fn io_error_sentinel(error : Int) -> UtfCodepoint {
  IO_ERROR_BASE + (error & 0xFFFF).reinterpret_as_uint()
}

///|
/// Preserves one malformed byte and advances by exactly one byte.
fn Utf8Cursor::invalid_at(self : Utf8Cursor, start : Int) -> UtfCodepoint {
  let byte = self.byte_at(start)
  self.position = start + 1
  invalid_byte_sentinel(byte)
}

///|
/// Decodes one unit from a known non-empty cursor.
///
/// Returning only the scalar/tagged value keeps callback traversal free from
/// the tuple/option construction required by the public pull interface.
fn Utf8Cursor::decode_next(self : Utf8Cursor) -> UtfCodepoint {
  let start = self.position
  let b0 = self.byte_at(start)
  match b0 {
    0x00..<0x80 => {
      self.position = start + 1
      b0.reinterpret_as_uint()
    }
    0xC2..<0xE0 => {
      guard self.ensure(2) else { return self.invalid_at(self.position) }
      let sequence_start = self.position
      let b1 = self.byte_at(sequence_start + 1)
      guard is_continuation(b1) else { return self.invalid_at(sequence_start) }
      let codepoint = ((b0 & 0x1F) << 6) | (b1 & 0x3F)
      self.position = sequence_start + 2
      codepoint.reinterpret_as_uint()
    }
    0xE0..<0xF0 => {
      guard self.ensure(3) else { return self.invalid_at(self.position) }
      let sequence_start = self.position
      let b1 = self.byte_at(sequence_start + 1)
      let b2 = self.byte_at(sequence_start + 2)
      let second_is_valid = if b0 == 0xE0 {
        b1 >= 0xA0 && b1 <= 0xBF
      } else {
        is_continuation(b1)
      }
      guard second_is_valid && is_continuation(b2) else {
        return self.invalid_at(sequence_start)
      }
      let codepoint = ((b0 & 0x0F) << 12) | ((b1 & 0x3F) << 6) | (b2 & 0x3F)
      self.position = sequence_start + 3
      codepoint.reinterpret_as_uint()
    }
    0xF0..<0xF5 => {
      guard self.ensure(4) else { return self.invalid_at(self.position) }
      let sequence_start = self.position
      let b1 = self.byte_at(sequence_start + 1)
      let b2 = self.byte_at(sequence_start + 2)
      let b3 = self.byte_at(sequence_start + 3)
      let second_is_valid = match b0 {
        0xF0 => b1 >= 0x90 && b1 <= 0xBF
        0xF4 => b1 >= 0x80 && b1 <= 0x8F
        _ => is_continuation(b1)
      }
      guard second_is_valid && is_continuation(b2) && is_continuation(b3) else {
        return self.invalid_at(sequence_start)
      }
      let codepoint = ((b0 & 0x07) << 18) |
        ((b1 & 0x3F) << 12) |
        ((b2 & 0x3F) << 6) |
        (b3 & 0x3F)
      self.position = sequence_start + 4
      codepoint.reinterpret_as_uint()
    }
    _ => self.invalid_at(start)
  }
}

///|
/// Decodes and returns the next `(UtfCodepoint, ByteOffset)` pair.
///
/// WTF-8 surrogate code points are returned directly. Malformed bytes and
/// terminal I/O failures are returned as tagged values above U+10FFFF.
pub fn Utf8Cursor::next(self : Utf8Cursor) -> (UtfCodepoint, ByteOffset)? {
  if self.ensure(1) {
    let offset = self.byte_offset()
    Some((self.decode_next(), offset))
  } else if self.read_error != 0 && !self.read_error_emitted {
    self.read_error_emitted = true
    Some((io_error_sentinel(self.read_error), self.byte_offset()))
  } else {
    None
  }
}

///|
/// Visits every decoded or tagged unit without constructing an output array.
pub fn Utf8Cursor::each(
  self : Utf8Cursor,
  yield_ : (UtfCodepoint, ByteOffset) -> Unit,
) -> Unit {
  while true {
    if self.ensure(1) {
      let offset = self.byte_offset()
      yield_(self.decode_next(), offset)
      continue
    }
    if self.read_error != 0 && !self.read_error_emitted {
      self.read_error_emitted = true
      yield_(io_error_sentinel(self.read_error), self.byte_offset())
    }
    break
  }
}

///|
/// Converts this cursor into MoonBit's two-value iterator interface.
pub fn Utf8Cursor::iter(self : Utf8Cursor) -> Iter2[UtfCodepoint, ByteOffset] {
  Iter2::new(fn() { self.next() })
}

///|
/// Creates a forward-only iterator over an existing buffer without copying it.
pub fn codepoints(buffer : Bytes) -> Iter2[UtfCodepoint, ByteOffset] {
  Utf8Cursor::new(buffer).iter()
}
