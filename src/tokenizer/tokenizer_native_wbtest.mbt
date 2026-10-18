///|
#cfg(target="native")
#borrow(bytes)
extern "c" fn tokenizer_test_open_bytes(bytes : Bytes, length : Int32) -> Int32 = "dewdrop_tokenizer_test_open_bytes"

///|
#cfg(target="native")
extern "c" fn tokenizer_test_close_fd(fd : Int32) -> Int32 = "dewdrop_tokenizer_close"
