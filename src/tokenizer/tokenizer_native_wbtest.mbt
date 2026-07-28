///|
#cfg(target="native")
#borrow(bytes)
extern "c" fn tokenizer_test_open_bytes(bytes : Bytes, length : Int) -> Int = "dewdrop_tokenizer_test_open_bytes"

///|
#cfg(target="native")
extern "c" fn tokenizer_test_close_fd(fd : Int) -> Int = "dewdrop_tokenizer_close"
