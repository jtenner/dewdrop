///|
fn cache_platform_supported() -> Bool {
  true
}

///|
#borrow(path, content)
extern "c" fn cache_platform_atomic_write(
  path : Bytes,
  path_length : Int32,
  content : Bytes,
) -> Int32 = "dewdrop_parse_event_cache_atomic_write"
