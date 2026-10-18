///|
#borrow(buffer)
extern "c" fn tokenizer_platform_read(
  fd : Int32,
  buffer : Bytes,
  offset : Int32,
  length : Int32,
) -> Int32 = "dewdrop_tokenizer_read"

///|
#borrow(buffer)
extern "c" fn tokenizer_platform_move(
  buffer : Bytes,
  destination : Int32,
  source : Int32,
  length : Int32,
) -> Unit = "dewdrop_tokenizer_move"

///|
extern "c" fn tokenizer_platform_page_size() -> Int32 = "dewdrop_tokenizer_page_size"
