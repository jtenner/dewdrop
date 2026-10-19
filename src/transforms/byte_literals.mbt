///|
fn Machine::byte_value(self : Machine, value : Value) -> Bytes raise EvalError {
  let value = reference_base(value)
  if value is ByteText(content) { return content }
  let backing = self.raw_struct_get(value, 0)
  let start = raw_bits(self.raw_struct_get(value, 1))
  let length = raw_bits(self.raw_struct_get(value, 2))
  let capacity = self.raw_array_length(backing) * 16UL
  guard start <= capacity && length <= capacity - start && length <= 4_194_304UL else {
    raise Failed("Bytes reference range is out of bounds")
  }
  self.charge(length.to_int())
  let output = @buffer.new(size_hint=length.to_int())
  let mut chunk = Vector(0UL, 0UL)
  for index in 0..<length.to_int() {
    self.charge(0)
    let absolute = start + index.to_uint64()
    if index == 0 || (absolute & 15UL) == 0UL {
      chunk = self.raw_array_get(backing, absolute >> 4)
    }
    output.write_byte(vector_byte(chunk, (absolute & 15UL).to_int()).to_byte())
  }
  output.to_bytes()
}

///|
fn Machine::render_bytes(self : Machine, value : Value) -> String raise EvalError {
  let content = self.byte_value(value)
  guard content.length() <= (1_048_576 - 3) / 4 else {
    raise Failed("generated source size limit exceeded")
  }
  self.charge(content.length() * 4 + 3)
  let output = @buffer.new(size_hint=content.length() * 4 + 3)
  output.write_bytes(b"b\"")
  let digits = b"0123456789abcdef"
  for index in 0..<content.length() {
    self.charge(0)
    let bits = content[index].to_int()
    output.write_bytes(b"\\x")
    output.write_byte(digits[bits >> 4])
    output.write_byte(digits[bits & 15])
  }
  output.write_byte(b'"')
  @utf8.decode_lossy(output.to_bytes())
}
