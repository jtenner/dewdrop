///|
fn standard_option_source() -> Bytes {
  b"pub enum Option<t> {\n  None\n  Some(t)\n}\n\npub fn dew_option_u32_from_raw(index: U32) -> Option<U32> {\n  if index == 4294967295u32 {\n    Option::None\n  } else {\n    Option::Some(index)\n  }\n}\n"
}

///|
fn standard_result_source() -> Bytes {
  b"pub enum Result<t, e> {\n  Ok(t)\n  Err(e)\n}\n"
}
