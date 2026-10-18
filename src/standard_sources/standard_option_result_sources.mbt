///|
pub fn standard_option_source() -> Bytes {
  b"pub enum Option<t> {\n  None\n  Some(t)\n}\n\npub trait Iter<t> {\n  fn next(self) -> Option<t>\n}\n\npub fn dew_option_u32_from_raw(index: U32) -> Option<U32> {\n  if index == 4294967295u32 {\n    Option::None\n  } else {\n    Option::Some(index)\n  }\n}\n\nimpl<t> Option<t> {\n  fn map<u>(self, transform: fn(t) -> u) -> Option<u> {\n    match self {\n      Option::Some(value) => Option::Some(transform(value))\n      Option::None => Option::None\n    }\n  }\n\n  fn and_then<u>(self, transform: fn(t) -> Option<u>) -> Option<u> {\n    match self {\n      Option::Some(value) => transform(value)\n      Option::None => Option::None\n    }\n  }\n\n  fn unwrap_or_else(self, fallback: fn() -> t) -> t {\n    match self {\n      Option::Some(value) => value\n      Option::None => fallback()\n    }\n  }\n}\n"
}

///|
pub fn standard_result_source() -> Bytes {
  b"pub enum Result<t, e> {\n  Ok(t)\n  Err(e)\n}\n\nimpl<t, e> Result<t, e> {\n  fn map<u>(self, transform: fn(t) -> u) -> Result<u, e> {\n    match self {\n      Result::Ok(value) => Result::Ok(transform(value))\n      Result::Err(error) => Result::Err(error)\n    }\n  }\n\n  fn map_err<f>(self, transform: fn(e) -> f) -> Result<t, f> {\n    match self {\n      Result::Ok(value) => Result::Ok(value)\n      Result::Err(error) => Result::Err(transform(error))\n    }\n  }\n\n  fn and_then<u>(self, transform: fn(t) -> Result<u, e>) -> Result<u, e> {\n    match self {\n      Result::Ok(value) => transform(value)\n      Result::Err(error) => Result::Err(error)\n    }\n  }\n\n  fn unwrap_or_else(self, fallback: fn(e) -> t) -> t {\n    match self {\n      Result::Ok(value) => value\n      Result::Err(error) => fallback(error)\n    }\n  }\n}\n"
}
