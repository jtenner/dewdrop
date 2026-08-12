///|
fn cache_platform_supported() -> Bool {
  false
}

///|
fn cache_platform_atomic_write(
  _path : Bytes,
  _path_length : Int,
  _content : Bytes,
) -> Int {
  -38
}
