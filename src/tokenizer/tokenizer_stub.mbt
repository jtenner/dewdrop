///|
fn tokenizer_platform_read(
  _fd : Int32,
  _buffer : Bytes,
  _offset : Int32,
  _length : Int32,
) -> Int32 {
  -38
}

///|
fn tokenizer_platform_move(
  _buffer : Bytes,
  _destination : Int32,
  _source : Int32,
  _length : Int32,
) -> Unit {

}

///|
fn tokenizer_platform_page_size() -> Int32 {
  4096
}
