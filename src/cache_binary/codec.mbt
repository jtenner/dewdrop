///|
/// Maximum single allocation requested by a persistent artifact decoder.
let maximum_blob_bytes = 0x10000000

///|
/// Maximum number of entries accepted from one persistent artifact array.
let maximum_array_items = 0x01000000

///|
/// Fixed common container magic. Schema versions are stored separately.
let artifact_magic : Bytes = b"DEWART\x00\x01"

///|
/// Allocation-conscious canonical binary writer.
pub struct Writer {
  output : Buffer
}

///|
pub fn Writer::new(size_hint? : Int = 0) -> Writer {
  { output: Buffer(size_hint=if size_hint < 0 { 0 } else { size_hint }) }
}

///|
pub fn Writer::length(self : Writer) -> Int {
  self.output.length()
}

///|
pub fn Writer::to_bytes(self : Writer) -> Bytes {
  self.output.to_bytes()
}

///|
pub fn Writer::write_byte(self : Writer, value : Byte) -> Unit {
  self.output.write_byte(value)
}

///|
pub fn Writer::write_raw(self : Writer, value : Bytes) -> Unit {
  self.output.write_bytes(value)
}

///|
pub fn Writer::write_var_u64(self : Writer, value : UInt64) -> Unit {
  let mut rest = value
  while rest >= 0x80UL {
    self.output.write_byte(((rest & 0x7fUL) | 0x80UL).to_byte())
    rest = rest >> 7
  }
  self.output.write_byte(rest.to_byte())
}

///|
pub fn Writer::write_zigzag_int(self : Writer, value : Int) -> Unit {
  let bits = value.reinterpret_as_uint()
  let sign = 0U - (bits >> 31)
  self.write_var_u64(((bits << 1) ^ sign).to_uint64())
}

///|
pub fn Writer::write_u32_le(self : Writer, value : UInt) -> Unit {
  self.output.write_byte((value & 0xffU).to_byte())
  self.output.write_byte(((value >> 8) & 0xffU).to_byte())
  self.output.write_byte(((value >> 16) & 0xffU).to_byte())
  self.output.write_byte(((value >> 24) & 0xffU).to_byte())
}

///|
pub fn Writer::write_u64_le(self : Writer, value : UInt64) -> Unit {
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    self.output.write_byte(((value >> shift) & 0xffUL).to_byte())
  }
}

///|
pub fn Writer::write_f32(self : Writer, value : Float) -> Unit {
  self.write_u32_le(value.reinterpret_as_uint())
}

///|
pub fn Writer::write_f64(self : Writer, value : Double) -> Unit {
  self.write_u64_le(value.reinterpret_as_uint64())
}

///|
pub fn Writer::write_bool(self : Writer, value : Bool) -> Unit {
  self.output.write_byte(if value { 1 } else { 0 })
}

///|
pub fn Writer::write_option_tag(self : Writer, present : Bool) -> Unit {
  self.write_bool(present)
}

///|
pub fn Writer::write_bytes(self : Writer, value : Bytes) -> Unit {
  self.write_var_u64(value.length().to_uint64())
  self.output.write_bytes(value)
}

///|
pub fn Writer::write_string(self : Writer, value : String) -> Unit {
  self.write_bytes(@utf8.encode(value))
}

///|
/// Sections are length-prefixed and must be decoded by a bounded sub-reader.
pub fn Writer::write_section(self : Writer, value : Bytes) -> Unit {
  self.write_bytes(value)
}

///|
/// Sticky, non-panicking decoder over one bounded byte range.
pub struct Reader {
  bytes : Bytes
  start : Int
  end : Int
  mut offset : Int
  context : String
  mut error : String?
}

///|
pub fn Reader::new(bytes : Bytes, context? : String = "artifact") -> Reader {
  { bytes, start: 0, end: bytes.length(), offset: 0, context, error: None }
}

///|
fn Reader::bounded(
  bytes : Bytes,
  start : Int,
  end : Int,
  context : String,
) -> Reader {
  { bytes, start, end, offset: start, context, error: None }
}

///|
pub fn Reader::position(self : Reader) -> Int {
  self.offset - self.start
}

///|
pub fn Reader::remaining(self : Reader) -> Int {
  if self.offset <= self.end {
    self.end - self.offset
  } else {
    0
  }
}

///|
pub fn Reader::failed(self : Reader) -> Bool {
  self.error is Some(_)
}

///|
pub fn Reader::fail(self : Reader, field : String, message : String) -> Unit {
  if self.error is None {
    self.error = Some(
      "\{self.context}.\{field} at byte \{self.offset - self.start}: \{message}",
    )
  }
}

///|
pub fn Reader::read_byte(self : Reader, field : String) -> Byte {
  if self.error is Some(_) {
    return 0
  }
  if self.offset >= self.end {
    self.fail(field, "truncated value")
    return 0
  }
  let value = self.bytes[self.offset]
  self.offset += 1
  value
}

///|
pub fn Reader::read_var_u64(self : Reader, field : String) -> UInt64 {
  if self.error is Some(_) {
    return 0UL
  }
  let start = self.offset
  let mut value = 0UL
  let mut shift = 0
  for index in 0..<10 {
    let byte = self.read_byte(field).to_uint()
    if self.error is Some(_) {
      return 0UL
    }
    if index == 9 && byte > 1U {
      self.fail(field, "unsigned varint overflow")
      return 0UL
    }
    value = value | ((byte & 0x7fU).to_uint64() << shift)
    if byte < 0x80U {
      let used = self.offset - start
      if used > 1 {
        let minimum = 1UL << ((used - 1) * 7)
        if value < minimum {
          self.fail(field, "non-canonical unsigned varint")
          return 0UL
        }
      }
      return value
    }
    shift += 7
  }
  self.fail(field, "unterminated unsigned varint")
  0UL
}

///|
pub fn Reader::read_zigzag_int(self : Reader, field : String) -> Int {
  let encoded = self.read_var_u64(field)
  if encoded > 0xffffffffUL {
    self.fail(field, "signed varint overflow")
    return 0
  }
  let value = ((encoded >> 1) ^ (0UL - (encoded & 1UL))).to_uint()
  value.reinterpret_as_int()
}

///|
pub fn Reader::read_u32_le(self : Reader, field : String) -> UInt {
  let b0 = self.read_byte(field).to_uint()
  let b1 = self.read_byte(field).to_uint()
  let b2 = self.read_byte(field).to_uint()
  let b3 = self.read_byte(field).to_uint()
  b0 | (b1 << 8) | (b2 << 16) | (b3 << 24)
}

///|
pub fn Reader::read_u64_le(self : Reader, field : String) -> UInt64 {
  let mut value = 0UL
  for shift in [0, 8, 16, 24, 32, 40, 48, 56] {
    value = value | (self.read_byte(field).to_uint().to_uint64() << shift)
  }
  value
}

///|
pub fn Reader::read_f32(self : Reader, field : String) -> Float {
  Float::reinterpret_from_uint(self.read_u32_le(field))
}

///|
pub fn Reader::read_f64(self : Reader, field : String) -> Double {
  self.read_u64_le(field).reinterpret_as_double()
}

///|
pub fn Reader::read_bool(self : Reader, field : String) -> Bool {
  match self.read_byte(field) {
    0 => false
    1 => true
    _ => {
      self.fail(field, "invalid Boolean tag")
      false
    }
  }
}

///|
pub fn Reader::read_option_tag(self : Reader, field : String) -> Bool {
  match self.read_byte(field) {
    0 => false
    1 => true
    _ => {
      self.fail(field, "invalid option tag")
      false
    }
  }
}

///|
pub fn Reader::read_count(self : Reader, maximum : Int, field : String) -> Int {
  let encoded = self.read_var_u64(field)
  let limit = if maximum < 0 || maximum > maximum_array_items {
    maximum_array_items
  } else {
    maximum
  }
  if encoded > limit.to_uint64() {
    self.fail(field, "count exceeds limit \{limit}")
    0
  } else if encoded > self.remaining().to_uint64() {
    self.fail(field, "count exceeds remaining payload")
    0
  } else {
    encoded.to_int()
  }
}

///|
pub fn Reader::skip(self : Reader, length : Int, field : String) -> Unit {
  if length < 0 || length > self.remaining() {
    self.fail(field, "invalid or truncated skipped range")
    return
  }
  self.offset += length
}

///|
pub fn Reader::read_raw_bytes(
  self : Reader,
  length : Int,
  maximum : Int,
  field : String,
) -> Bytes {
  if length < 0 || length > maximum || length > maximum_blob_bytes {
    self.fail(field, "byte length exceeds limit")
    return b""
  }
  if length > self.remaining() {
    self.fail(field, "truncated byte string")
    return b""
  }
  let output = Buffer(size_hint=length)
  let end = self.offset + length
  while self.offset < end {
    output.write_byte(self.bytes[self.offset])
    self.offset += 1
  }
  output.to_bytes()
}

///|
pub fn Reader::read_bytes(
  self : Reader,
  maximum : Int,
  field : String,
) -> Bytes {
  let encoded = self.read_var_u64(field)
  let limit = if maximum < 0 || maximum > maximum_blob_bytes {
    maximum_blob_bytes
  } else {
    maximum
  }
  if encoded > limit.to_uint64() || encoded > self.remaining().to_uint64() {
    self.fail(field, "invalid or excessive byte length")
    return b""
  }
  self.read_raw_bytes(encoded.to_int(), limit, field)
}

///|
pub fn Reader::read_string(
  self : Reader,
  maximum : Int,
  field : String,
) -> String {
  let bytes = self.read_bytes(maximum, field)
  if self.error is Some(_) {
    return ""
  }
  @utf8.decode(bytes) catch {
    _ => {
      self.fail(field, "invalid UTF-8")
      ""
    }
  }
}

///|
pub fn Reader::read_section(
  self : Reader,
  maximum : Int,
  field : String,
) -> Reader {
  let encoded = self.read_var_u64(field)
  let limit = if maximum < 0 || maximum > maximum_blob_bytes {
    maximum_blob_bytes
  } else {
    maximum
  }
  if encoded > limit.to_uint64() || encoded > self.remaining().to_uint64() {
    self.fail(field, "invalid or excessive section length")
    return Reader::bounded(
      self.bytes,
      self.offset,
      self.offset,
      self.context + "." + field,
    )
  }
  let length = encoded.to_int()
  let start = self.offset
  self.offset += length
  Reader::bounded(self.bytes, start, start + length, self.context + "." + field)
}

///|
pub fn Reader::finish(self : Reader) -> Result[Unit, String] {
  match self.error {
    Some(error) => Err(error)
    None if self.offset != self.end =>
      Err(
        "\{self.context} at byte \{self.offset - self.start}: trailing or unread bytes",
      )
    None => Ok(())
  }
}

///|
fn digest_equal(left : FixedArray[Byte], right : FixedArray[Byte]) -> Bool {
  if left.length() != right.length() {
    return false
  }
  for index in 0..<left.length() {
    if left[index] != right[index] {
      return false
    }
  }
  true
}

///|
/// Common checksummed persistent-artifact container.
pub fn wrap_artifact(
  kind : Int,
  version : UInt,
  provenance : Array[FixedArray[Byte]],
  payload : Bytes,
) -> Result[Bytes, String] {
  if kind < 0 || kind > 255 {
    return Err("artifact kind is out of range")
  }
  if provenance.length() > 255 {
    return Err("artifact provenance count exceeds limit")
  }
  for digest in provenance {
    if digest.length() != 32 {
      return Err("artifact provenance digest must be SHA-256")
    }
  }
  let writer = Writer::new(
    size_hint=artifact_magic.length() +
      49 +
      provenance.length() * 32 +
      payload.length(),
  )
  writer.write_raw(artifact_magic)
  writer.write_byte(kind.to_byte())
  writer.write_u32_le(version)
  writer.write_u32_le(0U)
  writer.write_u64_le(payload.length().to_uint64())
  writer.write_var_u64(provenance.length().to_uint64())
  for digest in provenance {
    for byte in digest {
      writer.write_byte(byte)
    }
  }
  for byte in @crypto.sha256(payload) {
    writer.write_byte(byte)
  }
  writer.write_raw(payload)
  Ok(writer.to_bytes())
}

///|
pub fn unwrap_artifact(
  bytes : Bytes,
  expected_kind : Int,
  expected_version : UInt,
  expected_provenance : Array[FixedArray[Byte]],
) -> Result[Bytes, String] {
  let reader = Reader::new(bytes, context="artifact")
  let magic = reader.read_raw_bytes(
    artifact_magic.length(),
    artifact_magic.length(),
    "magic",
  )
  if magic != artifact_magic {
    return Err("artifact.magic at byte 0: unsupported artifact magic")
  }
  let kind = reader.read_byte("kind").to_int()
  if kind != expected_kind {
    return Err("artifact.kind: unsupported artifact kind")
  }
  if reader.read_u32_le("version") != expected_version {
    return Err("artifact.version: unsupported artifact version")
  }
  if reader.read_u32_le("flags") != 0U {
    return Err("artifact.flags: unsupported artifact flags")
  }
  let payload_length = reader.read_u64_le("payload_length")
  let provenance_count = reader.read_count(255, "provenance_count")
  if provenance_count != expected_provenance.length() {
    return Err("artifact.provenance_count: provenance count mismatch")
  }
  for index in 0..<provenance_count {
    let encoded = reader.read_raw_bytes(32, 32, "provenance")
    let expected = expected_provenance[index]
    if encoded.length() != 32 {
      return Err("artifact.provenance: truncated provenance digest")
    }
    let actual : FixedArray[Byte] = FixedArray::make(32, 0)
    for digest_index in 0..<32 {
      actual[digest_index] = encoded[digest_index]
    }
    if !digest_equal(actual, expected) {
      return Err("artifact.provenance: provenance mismatch")
    }
  }
  let expected_checksum = reader.read_raw_bytes(32, 32, "payload_sha256")
  if payload_length > maximum_blob_bytes.to_uint64() ||
    payload_length > reader.remaining().to_uint64() {
    return Err("artifact.payload_length: invalid payload length")
  }
  let payload = reader.read_raw_bytes(
    payload_length.to_int(),
    maximum_blob_bytes,
    "payload",
  )
  match reader.finish() {
    Err(error) => return Err(error)
    Ok(_) => ()
  }
  let actual = @crypto.sha256(payload)
  if expected_checksum.length() != 32 {
    return Err("artifact.payload_sha256: truncated checksum")
  }
  for index in 0..<32 {
    if expected_checksum[index] != actual[index] {
      return Err("artifact.payload_sha256: checksum mismatch")
    }
  }
  Ok(payload)
}
