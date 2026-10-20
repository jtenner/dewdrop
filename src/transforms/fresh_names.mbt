///|
// Index ASCII substrings, not tokens: comments and string contents also collide.
// At most ten short digit-prefix keys are produced for each occurrence.
fn index_fresh_names(source : Bytes, names : Map[String, Int32]) -> Unit {
  let prefix = b"__dew_transform_"
  let mut cursor = 0
  while cursor < source.length() {
    let mut matched = 0
    if source.length() - cursor >= prefix.length() {
      while matched < prefix.length() &&
            source[cursor + matched] == prefix[matched] {
        matched += 1
      }
    }
    if matched != prefix.length() {
      cursor += 1
      continue
    }
    let digits_start = cursor + prefix.length()
    let mut digits_end = digits_start
    while digits_end < source.length() &&
          source[digits_end] >= b'0' &&
          source[digits_end] <= b'9' {
      digits_end += 1
    }
    if digits_end == digits_start {
      cursor += 1
      continue
    }
    let mut suffix_end = digits_end
    while suffix_end < source.length() && source[suffix_end] == b'_' {
      suffix_end += 1
    }
    let digits = Int32::min(10, digits_end - digits_start)
    for length in 1..<(digits + 1) {
      let end = digits_start + length
      let key = text(source[cursor:end].to_owned())
      let suffix = if end == digits_end { suffix_end - digits_end } else { 0 }
      if names.get(key).unwrap_or(-1) < suffix {
        names[key] = suffix
      }
    }
    // An occurrence may start in the following underscore run, so do not skip it.
    cursor = digits_end
  }
}

///|
fn Machine::fresh_name(
  self : Machine,
  mi : Int32,
  offset : UInt32,
) -> String raise EvalError {
  let base = "__dew_transform_" + offset.to_string()
  guard self.plan.source_index().sources[mi].fresh_names.get(base)
    is Some(maximum) else {
    return base
  }
  let count = maximum + 1
  for _ in 0..<count {
    self.charge(16)
  }
  let out = StringBuilder::new()
  out.write_string(base)
  for _ in 0..<count {
    out.write_char('_')
  }
  out.to_string()
}
