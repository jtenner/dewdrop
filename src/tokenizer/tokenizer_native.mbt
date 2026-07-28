///|
#borrow(buffer)
extern "c" fn tokenizer_platform_read(
  fd : Int,
  buffer : Bytes,
  offset : Int,
  length : Int,
) -> Int = "dewdrop_tokenizer_read"

///|
#borrow(buffer)
extern "c" fn tokenizer_platform_move(
  buffer : Bytes,
  destination : Int,
  source : Int,
  length : Int,
) -> Unit = "dewdrop_tokenizer_move"

///|
extern "c" fn tokenizer_platform_page_size() -> Int = "dewdrop_tokenizer_page_size"
