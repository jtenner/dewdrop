///|
fn tokenizer_platform_read(
  _fd : Int,
  _buffer : Bytes,
  _offset : Int,
  _length : Int,
) -> Int {
  -38
}

///|
fn tokenizer_platform_move(
  _buffer : Bytes,
  _destination : Int,
  _source : Int,
  _length : Int,
) -> Unit {

}

///|
fn tokenizer_platform_page_size() -> Int {
  4096
}
