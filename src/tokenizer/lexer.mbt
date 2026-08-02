///|
/// A forward-only Dew token stream with two WTF-8 units of bounded lookahead.
pub struct Tokenizer {
  source : Utf8Cursor
  mut has_first : Bool
  mut first : UtfCodepoint
  mut first_offset : ByteOffset
  mut has_second : Bool
  mut second : UtfCodepoint
  mut second_offset : ByteOffset
  mut next_index : Int
  mut has_pending_newline : Bool
  mut pending_newline_offset : ByteOffset
  scratch : StringBuilder
}

///|
pub fn Tokenizer::new(source : Utf8Cursor) -> Tokenizer {
  {
    source,
    has_first: false,
    first: 0U,
    first_offset: 0UL,
    has_second: false,
    second: 0U,
    second_offset: 0UL,
    next_index: 0,
    has_pending_newline: false,
    pending_newline_offset: 0UL,
    scratch: StringBuilder(size_hint=32),
  }
}

///|
pub fn Tokenizer::from_bytes(bytes : Bytes) -> Tokenizer {
  Tokenizer::new(Utf8Cursor::new(bytes))
}

///|
pub fn Tokenizer::from_fd(fd : Int, buffer_size? : Int) -> Tokenizer {
  let source = match buffer_size {
    Some(size) => Utf8Cursor::from_fd(fd, buffer_size=size)
    None => Utf8Cursor::from_fd(fd)
  }
  Tokenizer::new(source)
}

///|
fn Tokenizer::fill_first(self : Tokenizer) -> Unit {
  guard !self.has_first else { return }
  if self.source.ensure(1) {
    self.first_offset = self.source.byte_offset()
    self.first = self.source.decode_next()
    self.has_first = true
  } else if self.source.read_error != 0 && !self.source.read_error_emitted {
    self.source.read_error_emitted = true
    self.first_offset = self.source.byte_offset()
    self.first = io_error_sentinel(self.source.read_error)
    self.has_first = true
  }
}

///|
fn Tokenizer::fill_second(self : Tokenizer) -> Unit {
  self.fill_first()
  guard self.has_first && !self.has_second else { return }
  if self.source.ensure(1) {
    self.second_offset = self.source.byte_offset()
    self.second = self.source.decode_next()
    self.has_second = true
  } else if self.source.read_error != 0 && !self.source.read_error_emitted {
    self.source.read_error_emitted = true
    self.second_offset = self.source.byte_offset()
    self.second = io_error_sentinel(self.source.read_error)
    self.has_second = true
  }
}

///|
fn Tokenizer::has_current(self : Tokenizer) -> Bool {
  self.fill_first()
  self.has_first
}

///|
fn Tokenizer::has_next_unit(self : Tokenizer) -> Bool {
  self.fill_second()
  self.has_second
}

///|
fn Tokenizer::advance(self : Tokenizer) -> Unit {
  self.fill_first()
  guard self.has_first else { return }
  if self.has_second {
    self.first = self.second
    self.first_offset = self.second_offset
    self.has_second = false
  } else {
    self.has_first = false
  }
}

///|
fn Tokenizer::peek(self : Tokenizer) -> (UtfCodepoint, ByteOffset)? {
  if self.has_current() {
    Some((self.first, self.first_offset))
  } else {
    None
  }
}

///|
fn Tokenizer::peek_second(self : Tokenizer) -> (UtfCodepoint, ByteOffset)? {
  self.fill_second()
  if self.has_second {
    Some((self.second, self.second_offset))
  } else {
    None
  }
}

///|
fn Tokenizer::take(self : Tokenizer) -> (UtfCodepoint, ByteOffset)? {
  guard self.has_current() else { None }
  let result = (self.first, self.first_offset)
  self.advance()
  Some(result)
}

///|
fn is_ascii_letter(value : UtfCodepoint) -> Bool {
  (value >= 0x41U && value <= 0x5AU) || (value >= 0x61U && value <= 0x7AU)
}

///|
fn is_ascii_digit(value : UtfCodepoint) -> Bool {
  value >= 0x30U && value <= 0x39U
}

///|
fn is_identifier_start(value : UtfCodepoint) -> Bool {
  if is_ascii_letter(value) || value == 0x5FU {
    true
  } else {
    value >= 0x80U && is_unicode_scalar(value) && !is_unicode_whitespace(value)
  }
}

///|
fn is_identifier_continue(value : UtfCodepoint) -> Bool {
  is_identifier_start(value) || is_ascii_digit(value)
}

///|
fn is_unicode_whitespace(value : UtfCodepoint) -> Bool {
  match value {
    0x09U
    | 0x0AU
    | 0x0BU
    | 0x0CU
    | 0x0DU
    | 0x20U
    | 0x85U
    | 0xA0U
    | 0x1680U
    | 0x2028U
    | 0x2029U
    | 0x202FU
    | 0x205FU
    | 0x3000U => true
    0x2000U..=0x200AU => true
    _ => false
  }
}

///|
fn is_horizontal_whitespace(value : UtfCodepoint) -> Bool {
  value == 0x20U || value == 0x09U
}

///|
fn is_newline(value : UtfCodepoint) -> Bool {
  value == 0x0AU || value == 0x0DU
}

///|
fn write_identifier_unit(builder : StringBuilder, value : UtfCodepoint) -> Unit {
  builder.write_char(value.reinterpret_as_int().unsafe_to_char())
}

///|
fn write_wtf8_unit(buffer : @buffer.Buffer, value : UtfCodepoint) -> Bool {
  match invalid_byte(value) {
    Some(byte) => {
      buffer.write_byte(byte)
      true
    }
    None => {
      guard is_wtf8_codepoint(value) else { return false }
      match value {
        0x0000U..<0x0080U => buffer.write_byte(value.to_byte())
        0x0080U..<0x0800U => {
          buffer.write_byte((0xC0U | (value >> 6)).to_byte())
          buffer.write_byte((0x80U | (value & 0x3FU)).to_byte())
        }
        0x0800U..<0x10000U => {
          buffer.write_byte((0xE0U | (value >> 12)).to_byte())
          buffer.write_byte((0x80U | ((value >> 6) & 0x3FU)).to_byte())
          buffer.write_byte((0x80U | (value & 0x3FU)).to_byte())
        }
        _ => {
          buffer.write_byte((0xF0U | (value >> 18)).to_byte())
          buffer.write_byte((0x80U | ((value >> 12) & 0x3FU)).to_byte())
          buffer.write_byte((0x80U | ((value >> 6) & 0x3FU)).to_byte())
          buffer.write_byte((0x80U | (value & 0x3FU)).to_byte())
        }
      }
      true
    }
  }
}

///|
fn Tokenizer::emit(
  self : Tokenizer,
  kind : TokenKind,
  offset : ByteOffset,
) -> Token {
  let token = Token::new(kind, offset, self.next_index)
  self.next_index += 1
  token
}

///|
fn Tokenizer::skip_trivia(self : Tokenizer) -> Unit {
  while self.has_current() {
    let value = self.first
    if is_newline(value) {
      break
    }
    if is_unicode_whitespace(value) {
      self.advance()
      continue
    }
    if value == 0x2FU && self.has_next_unit() && self.second == 0x2FU {
      self.advance()
      self.advance()
      while self.has_current() && !is_newline(self.first) {
        self.advance()
      }
      continue
    }
    break
  }
}

///|
fn Tokenizer::scan_identifier(self : Tokenizer) -> String {
  let builder = self.scratch
  builder.reset()
  while self.has_current() && is_identifier_continue(self.first) {
    let value = self.first
    self.advance()
    write_identifier_unit(builder, value)
  }
  builder.to_string()
}

///|
fn Tokenizer::scan_at_identifier(
  self : Tokenizer,
  offset : ByteOffset,
) -> Token {
  self.advance()
  guard self.has_current() && is_identifier_start(self.first) else {
    return self.emit(Error(InvalidAtIdentifier), offset)
  }
  let builder = self.scratch
  builder.reset()
  while self.has_current() && is_identifier_continue(self.first) {
    let value = self.first
    self.advance()
    write_identifier_unit(builder, value)
  }
  self.emit(AtIdentifier(builder.to_string()), offset)
}

///|
fn Tokenizer::scan_decimal_component(
  self : Tokenizer,
  builder : StringBuilder,
) -> Bool {
  let mut saw_digit = false
  let mut previous_underscore = false
  let mut valid = true
  while self.has_current() &&
        (is_ascii_digit(self.first) || self.first == 0x5FU) {
    let value = self.first
    self.advance()
    write_identifier_unit(builder, value)
    if is_ascii_digit(value) {
      saw_digit = true
      previous_underscore = false
    } else {
      if !saw_digit || previous_underscore {
        valid = false
      }
      previous_underscore = true
    }
  }
  valid && saw_digit && !previous_underscore
}

///|
fn Tokenizer::scan_integer_component(
  self : Tokenizer,
  builder : StringBuilder,
) -> (UInt64, Bool) {
  let mut magnitude = 0UL
  let mut overflow = false
  let mut saw_digit = false
  let mut previous_underscore = false
  let mut valid = true
  while self.has_current() &&
        (is_ascii_digit(self.first) || self.first == 0x5FU) {
    let value = self.first
    self.advance()
    write_identifier_unit(builder, value)
    if is_ascii_digit(value) {
      let digit = (value - 0x30U).to_uint64()
      if magnitude > (0xFFFFFFFFFFFFFFFFUL - digit) / 10UL {
        overflow = true
      } else {
        magnitude = magnitude * 10UL + digit
      }
      saw_digit = true
      previous_underscore = false
    } else {
      if !saw_digit || previous_underscore {
        valid = false
      }
      previous_underscore = true
    }
  }
  (magnitude, valid && saw_digit && !previous_underscore && !overflow)
}

///|
fn Tokenizer::scan_exponent(self : Tokenizer, builder : StringBuilder) -> Bool {
  guard self.has_current() && (self.first == 0x65U || self.first == 0x45U) else {
    return true
  }
  let exponent = self.first
  self.advance()
  write_identifier_unit(builder, exponent)
  if self.has_current() && (self.first == 0x2BU || self.first == 0x2DU) {
    let sign = self.first
    self.advance()
    write_identifier_unit(builder, sign)
  }
  self.scan_decimal_component(builder)
}

///|
fn Tokenizer::scan_numeric_width(
  self : Tokenizer,
  builder : StringBuilder,
) -> Int {
  guard self.has_current() else { return -1 }
  let first = self.first
  self.advance()
  write_identifier_unit(builder, first)
  if first == 0x38U {
    return 8
  }
  if first == 0x31U && self.has_current() && self.first == 0x36U {
    self.advance()
    write_identifier_unit(builder, 0x36U)
    return 16
  }
  if first == 0x33U && self.has_current() && self.first == 0x32U {
    self.advance()
    write_identifier_unit(builder, 0x32U)
    return 32
  }
  if first == 0x36U && self.has_current() && self.first == 0x34U {
    self.advance()
    write_identifier_unit(builder, 0x34U)
    return 64
  }
  -1
}

///|
fn Tokenizer::scan_number(
  self : Tokenizer,
  offset : ByteOffset,
  leading_dot : Bool,
) -> Token {
  let builder = self.scratch
  builder.reset()
  let mut magnitude = 0UL
  let mut valid = true
  if leading_dot {
    self.advance()
    builder.write_char('.')
    valid = self.scan_decimal_component(builder)
  } else {
    let result = self.scan_integer_component(builder)
    magnitude = result.0
    valid = result.1
  }
  let mut has_dot = leading_dot
  if !leading_dot &&
    self.has_current() &&
    self.first == 0x2EU &&
    self.has_next_unit() &&
    is_ascii_digit(self.second) {
    has_dot = true
    self.advance()
    builder.write_char('.')
    valid = self.scan_decimal_component(builder) && valid
  }
  if !has_dot {
    if self.has_current() && (self.first == 0x65U || self.first == 0x45U) {
      ignore(self.scan_exponent(builder))
      return self.emit(Error(InvalidFloat(builder.to_string())), offset)
    }
    if self.has_current() && self.first == 0x46U {
      self.advance()
      builder.write_char('F')
      return self.emit(Error(InvalidFloat(builder.to_string())), offset)
    }
    let kind = if self.has_current() && self.first == 0x69U {
      self.advance()
      builder.write_char('i')
      match self.scan_numeric_width(builder) {
        8 => I8(magnitude)
        16 => I16(magnitude)
        32 => I32(magnitude)
        64 => I64(magnitude)
        _ =>
          return self.emit(Error(InvalidInteger(builder.to_string())), offset)
      }
    } else if self.has_current() && self.first == 0x75U {
      self.advance()
      builder.write_char('u')
      match self.scan_numeric_width(builder) {
        8 => U8(magnitude)
        16 => U16(magnitude)
        32 => U32(magnitude)
        64 => U64(magnitude)
        _ =>
          return self.emit(Error(InvalidInteger(builder.to_string())), offset)
      }
    } else if self.has_current() && self.first == 0x55U {
      self.advance()
      builder.write_char('U')
      if self.has_current() && self.first == 0x4CU {
        self.advance()
        builder.write_char('L')
        U64(magnitude)
      } else {
        U32(magnitude)
      }
    } else if self.has_current() && self.first == 0x4CU {
      self.advance()
      builder.write_char('L')
      I64(magnitude)
    } else {
      I32(magnitude)
    }
    let in_range = match kind {
      I8(value) => value <= 0x80UL
      I16(value) => value <= 0x8000UL
      I32(value) => value <= 0x80000000UL
      I64(value) => value <= 0x8000000000000000UL
      U8(value) => value <= 0xFFUL
      U16(value) => value <= 0xFFFFUL
      U32(value) => value <= 0xFFFFFFFFUL
      U64(_) => true
      _ => false
    }
    if !valid || !in_range {
      return self.emit(Error(InvalidInteger(builder.to_string())), offset)
    }
    return self.emit(kind, offset)
  }
  valid = self.scan_exponent(builder) && valid
  let text = builder.to_string()
  let mut width = 64
  if self.has_current() && self.first == 0x46U {
    self.advance()
    width = 32
  } else if self.has_current() && self.first == 0x66U {
    self.advance()
    builder.write_char('f')
    width = self.scan_numeric_width(builder)
    if width != 32 && width != 64 {
      return self.emit(Error(InvalidFloat(builder.to_string())), offset)
    }
  }
  if !valid {
    return self.emit(Error(InvalidFloat(text)), offset)
  }
  let value = @string.parse_double(text) catch {
    _ => return self.emit(Error(InvalidFloat(text)), offset)
  }
  if width == 32 {
    self.emit(F32(Float::from_double(value)), offset)
  } else {
    self.emit(F64(value), offset)
  }
}

///|
fn hex_digit(value : UtfCodepoint) -> Int? {
  match value {
    0x30U..=0x39U => Some((value - 0x30U).reinterpret_as_int())
    0x41U..=0x46U => Some((value - 0x41U + 10U).reinterpret_as_int())
    0x61U..=0x66U => Some((value - 0x61U + 10U).reinterpret_as_int())
    _ => None
  }
}

///|
fn Tokenizer::scan_string(
  self : Tokenizer,
  offset : ByteOffset,
  bytes_literal : Bool,
) -> Token {
  ignore(self.take())
  let output = Buffer()
  while true {
    match self.peek() {
      None => return self.emit(Error(UnterminatedString), offset)
      Some((value, _)) if is_io_error(value) => {
        ignore(self.take())
        return self.emit(Error(SourceIo(io_error_code(value).unwrap())), offset)
      }
      Some((0x22U, _)) => {
        ignore(self.take())
        return self.emit(
          if bytes_literal {
            BytesLiteral(output.to_bytes())
          } else {
            StringLiteral(output.to_bytes())
          },
          offset,
        )
      }
      Some((value, _)) if is_newline(value) =>
        return self.emit(Error(UnterminatedString), offset)
      Some((0x5CU, _)) => {
        ignore(self.take())
        let escaped = match self.take() {
          Some((escaped, _)) => escaped
          None => return self.emit(Error(UnterminatedString), offset)
        }
        match escaped {
          0x22U => output.write_byte(b'"')
          0x5CU => output.write_byte(b'\\')
          0x6EU => output.write_byte(b'\n')
          0x72U => output.write_byte(b'\r')
          0x74U => output.write_byte(b'\t')
          0x30U => output.write_byte(b'\x00')
          0x62U => output.write_byte(b'\x08')
          0x66U => output.write_byte(b'\x0C')
          0x78U => {
            let first = match self.take() {
              Some((digit, _)) => hex_digit(digit)
              None => None
            }
            let second = match self.take() {
              Some((digit, _)) => hex_digit(digit)
              None => None
            }
            match (first, second) {
              (Some(high), Some(low)) =>
                output.write_byte(((high << 4) | low).to_byte())
              _ => return self.emit(Error(InvalidEscape(escaped)), offset)
            }
          }
          _ => return self.emit(Error(InvalidEscape(escaped)), offset)
        }
      }
      Some((value, _)) => {
        ignore(self.take())
        guard write_wtf8_unit(output, value) else {
          return self.emit(
            Error(SourceIo(io_error_code(value).unwrap())),
            offset,
          )
        }
      }
    }
  } nobreak {
    abort("unreachable string scanner termination")
  }
}

///|
fn Tokenizer::consume_newline(self : Tokenizer) -> ByteOffset? {
  guard self.has_current() && is_newline(self.first) else { return None }
  let offset = self.first_offset
  let value = self.first
  self.advance()
  if value == 0x0DU && self.has_current() && self.first == 0x0AU {
    self.advance()
  }
  Some(offset)
}

///|
fn Tokenizer::scan_multiline_string(
  self : Tokenizer,
  offset : ByteOffset,
) -> Token {
  ignore(self.take())
  ignore(self.take())
  let output = Buffer()
  while true {
    match self.peek() {
      None => return self.emit(MultilineString(output.to_bytes()), offset)
      Some((value, _)) if is_io_error(value) => {
        ignore(self.take())
        return self.emit(Error(SourceIo(io_error_code(value).unwrap())), offset)
      }
      Some((value, _)) if is_newline(value) => {
        let newline_offset = self.consume_newline().unwrap()
        while self.peek() is Some((space, _)) && is_horizontal_whitespace(space) {
          ignore(self.take())
        }
        match (self.peek(), self.peek_second()) {
          (Some((0x23U, _)), Some((0x7CU, _))) => {
            output.write_byte(b'\n')
            ignore(self.take())
            ignore(self.take())
          }
          _ => {
            self.has_pending_newline = true
            self.pending_newline_offset = newline_offset
            return self.emit(MultilineString(output.to_bytes()), offset)
          }
        }
      }
      Some((value, _)) => {
        ignore(self.take())
        guard write_wtf8_unit(output, value) else {
          return self.emit(
            Error(SourceIo(io_error_code(value).unwrap())),
            offset,
          )
        }
      }
    }
  } nobreak {
    abort("unreachable multiline string scanner termination")
  }
}

///|
fn Tokenizer::scan_symbol(
  self : Tokenizer,
  value : UtfCodepoint,
  offset : ByteOffset,
) -> Token {
  self.advance()
  let kind = match value {
    0x28U => Symbol(LeftParen)
    0x29U => Symbol(RightParen)
    0x7BU => Symbol(LeftBrace)
    0x7DU => Symbol(RightBrace)
    0x5BU => Symbol(LeftBracket)
    0x5DU => Symbol(RightBracket)
    0x5EU => Symbol(Caret)
    0x2BU => Symbol(Plus)
    0x2DU =>
      if self.has_current() && self.first == 0x3EU {
        self.advance()
        Symbol(Arrow)
      } else {
        Symbol(Minus)
      }
    0x2AU =>
      if self.has_current() && self.first == 0x2AU {
        self.advance()
        Symbol(Exponent)
      } else {
        Symbol(Star)
      }
    0x2FU => Symbol(Slash)
    0x25U => Symbol(Percent)
    0x3AU =>
      if self.has_current() && self.first == 0x3AU {
        self.advance()
        Symbol(DoubleColon)
      } else {
        Symbol(Colon)
      }
    0x3DU =>
      if self.has_current() && self.first == 0x3DU {
        self.advance()
        Symbol(EqualEqual)
      } else if self.has_current() && self.first == 0x3EU {
        self.advance()
        Symbol(FatArrow)
      } else {
        Symbol(Equal)
      }
    0x2CU => Symbol(Comma)
    0x3BU => Symbol(Semicolon)
    0x2EU =>
      if self.has_current() &&
        self.first == 0x2EU &&
        self.has_next_unit() &&
        self.second == 0x2EU {
        self.advance()
        self.advance()
        Symbol(Ellipsis)
      } else {
        Symbol(Dot)
      }
    0x3CU =>
      if self.has_current() && self.first == 0x3DU {
        self.advance()
        Symbol(LessEqual)
      } else if self.has_current() && self.first == 0x3CU {
        self.advance()
        Symbol(ShiftLeft)
      } else {
        Symbol(Less)
      }
    0x3EU =>
      if self.has_current() && self.first == 0x3DU {
        self.advance()
        Symbol(GreaterEqual)
      } else if self.has_current() && self.first == 0x3EU {
        self.advance()
        Symbol(ShiftRight)
      } else {
        Symbol(Greater)
      }
    0x21U =>
      if self.has_current() && self.first == 0x3DU {
        self.advance()
        Symbol(BangEqual)
      } else {
        Symbol(Bang)
      }
    0x26U =>
      if self.has_current() && self.first == 0x26U {
        self.advance()
        Symbol(LogicalAnd)
      } else {
        Symbol(Ampersand)
      }
    0x7CU =>
      if self.has_current() && self.first == 0x7CU {
        self.advance()
        Symbol(LogicalOr)
      } else {
        Symbol(Pipe)
      }
    _ => Error(UnexpectedUnit(value))
  }
  self.emit(kind, offset)
}

///|
/// Returns the next token. Horizontal whitespace and comments are trivia;
/// physical line endings are retained as `Newline` tokens.
pub fn Tokenizer::next(self : Tokenizer) -> Token? {
  if self.has_pending_newline {
    self.has_pending_newline = false
    return Some(self.emit(Newline, self.pending_newline_offset))
  }
  self.skip_trivia()
  guard self.has_current() else { return None }
  let value = self.first
  let offset = self.first_offset
  if is_newline(value) {
    ignore(self.consume_newline())
    return Some(self.emit(Newline, offset))
  }
  if is_io_error(value) {
    self.advance()
    return Some(
      self.emit(Error(SourceIo(io_error_code(value).unwrap())), offset),
    )
  }
  if is_invalid_byte(value) || is_surrogate(value) {
    self.advance()
    return Some(self.emit(Error(UnexpectedUnit(value)), offset))
  }
  if value == 0x62U && self.has_next_unit() && self.second == 0x22U {
    self.advance()
    return Some(self.scan_string(offset, true))
  }
  if is_identifier_start(value) {
    let identifier = self.scan_identifier()
    let kind = match keyword_from_identifier(identifier) {
      Some(keyword) => Keyword(keyword)
      None => Identifier(identifier)
    }
    return Some(self.emit(kind, offset))
  }
  if is_ascii_digit(value) {
    return Some(self.scan_number(offset, false))
  }
  if value == 0x2EU && self.has_next_unit() && is_ascii_digit(self.second) {
    return Some(self.scan_number(offset, true))
  }
  match value {
    0x22U => Some(self.scan_string(offset, false))
    0x23U =>
      if self.has_next_unit() && self.second == 0x7CU {
        Some(self.scan_multiline_string(offset))
      } else {
        Some(self.scan_symbol(value, offset))
      }
    0x40U => Some(self.scan_at_identifier(offset))
    _ => Some(self.scan_symbol(value, offset))
  }
}

///|
/// Converts this tokenizer into a streaming token iterator.
pub fn Tokenizer::iter(self : Tokenizer) -> Iter[Token] {
  Iter::new(fn() { self.next() })
}

///|
/// Tokenizes one already-buffered source without copying it.
pub fn tokens(bytes : Bytes) -> Iter[Token] {
  Tokenizer::from_bytes(bytes).iter()
}
