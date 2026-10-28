///|
/// Version 1 checks shared by manifest, lock and local artifact inputs.
const BOOTSTRAP_PACKAGE_SOURCE_MAX_BYTES : Int32 = 16777216

///|
fn bootstrap_package_relative_path_valid(path : String) -> Bool {
  let bytes = @utf8.encode(path)
  if bytes.length() == 0 || bytes.length() > 4096 || bytes[0] == b'/' {
    return false
  }
  // A drive-qualified path is absolute on Windows, even on a Unix reader.
  if bytes.length() >= 3 &&
    bytes[1] == b':' &&
    bytes[2] == b'/' &&
    (
      (bytes[0] >= b'A' && bytes[0] <= b'Z') ||
      (bytes[0] >= b'a' && bytes[0] <= b'z')
    ) {
    return false
  }
  let mut start = 0
  for index in 0..<=bytes.length() {
    if index < bytes.length() &&
      (bytes[index] == b'\\' || bytes[index] == b'\x00') {
      return false
    }
    if index == bytes.length() || bytes[index] == b'/' {
      let length = index - start
      if length == 0 ||
        (length == 1 && bytes[start] == b'.') ||
        (length == 2 && bytes[start] == b'.' && bytes[start + 1] == b'.') {
        return false
      }
      start = index + 1
    }
  }
  true
}

///|
fn bootstrap_contract_known_fields(
  fields : Map[String, Json],
  allowed : Array[String],
  context : String,
) -> Unit {
  for key in fields.keys() {
    if !allowed.contains(key) {
      bootstrap_fail("unknown \{context} field: \{key}")
    }
  }
}

///|
fn bootstrap_contract_number(text : String) -> UInt32? {
  let bytes = @utf8.encode(text)
  if bytes.length() == 0 || (bytes.length() > 1 && bytes[0] == b'0') {
    return None
  }
  let mut number = 0U
  for byte in bytes {
    if byte < b'0' || byte > b'9' {
      return None
    }
    let digit = byte.to_uint() - 48U
    if number > 429496729U || (number == 429496729U && digit > 5U) {
      return None
    }
    number = number * 10U + digit
  }
  Some(number)
}

///|
struct BootstrapSemVer {
  core : Array[UInt32]
  pre : Array[String]
}

///|
fn bootstrap_contract_identifiers(
  text : String,
  numeric_rules : Bool,
) -> Array[String]? {
  let parts = text.split(".").map(part => part.to_owned()).to_array()
  for part in parts {
    if part == "" {
      return None
    }
    let mut numeric = true
    for byte in @utf8.encode(part) {
      let digit = byte >= b'0' && byte <= b'9'
      if !digit &&
        !(byte >= b'a' && byte <= b'z') &&
        !(byte >= b'A' && byte <= b'Z') &&
        byte != b'-' {
        return None
      }
      if !digit {
        numeric = false
      }
    }
    if numeric_rules && numeric && bootstrap_contract_number(part) is None {
      return None
    }
  }
  Some(parts)
}

///|
fn bootstrap_contract_semver(text : String) -> BootstrapSemVer? {
  let length = @utf8.encode(text).length()
  if length == 0 || length > 255 {
    return None
  }
  let builds = text.split("+").map(part => part.to_owned()).to_array()
  if builds.length() > 2 {
    return None
  }
  if builds.length() == 2 &&
    bootstrap_contract_identifiers(builds[1], false) is None {
    return None
  }
  let main = builds[0]
  let mut dash = -1
  for index in 0..<main.length() {
    if main[index] == '-' {
      dash = index
      break
    }
  }
  let core_text = if dash >= 0 { main[:dash].to_owned() } else { main }
  let pre = if dash >= 0 {
    match bootstrap_contract_identifiers(main[dash + 1:].to_owned(), true) {
      None => return None
      Some(value) => value
    }
  } else {
    []
  }
  let parts = core_text.split(".").to_array()
  if parts.length() != 3 {
    return None
  }
  let core : Array[UInt32] = []
  for part in parts {
    match bootstrap_contract_number(part.to_owned()) {
      None => return None
      Some(value) => core.push(value)
    }
  }
  Some({ core, pre, })
}

///|
fn bootstrap_contract_semver_compare(
  left : BootstrapSemVer,
  right : BootstrapSemVer,
) -> Int32 {
  for index in 0..<3 {
    if left.core[index] < right.core[index] {
      return -1
    }
    if left.core[index] > right.core[index] {
      return 1
    }
  }
  if left.pre.length() == 0 {
    return if right.pre.length() == 0 { 0 } else { 1 }
  }
  if right.pre.length() == 0 {
    return -1
  }
  let length = if left.pre.length() < right.pre.length() {
    left.pre.length()
  } else {
    right.pre.length()
  }
  for index in 0..<length {
    let a = left.pre[index]
    let b = right.pre[index]
    if a == b {
      continue
    }
    match (bootstrap_contract_number(a), bootstrap_contract_number(b)) {
      (Some(x), Some(y)) => return if x < y { -1 } else { 1 }
      (Some(_), None) => return -1
      (None, Some(_)) => return 1
      (None, None) => return a.lexical_compare(b)
    }
  }
  if left.pre.length() < right.pre.length() {
    -1
  } else if left.pre.length() > right.pre.length() {
    1
  } else {
    0
  }
}

///|
fn bootstrap_contract_requirement_valid(value : String) -> Bool {
  let bytes = @utf8.encode(value)
  if bytes.length() == 0 || bytes.length() > 2048 {
    return false
  }
  if value == "*" {
    return true
  }
  if value.has_prefix("git+") {
    let mut hash = -1
    for index in 0..<bytes.length() {
      if bytes[index] == b'\x00' {
        return false
      }
      if hash < 0 && bytes[index] == b'#' {
        hash = index
      }
    }
    return hash > 4 && hash + 1 < bytes.length()
  }
  let version = if value.has_prefix("^") || value.has_prefix("~") {
    value[1:].to_owned()
  } else {
    value
  }
  bootstrap_contract_semver(version) is Some(_)
}

///|
fn bootstrap_contract_request_matches(
  request : String,
  lock : BootstrapLockedPackage,
) -> Bool {
  if request.has_prefix("git+") {
    return request == lock.source
  }
  let candidate = match bootstrap_contract_semver(lock.version) {
    Some(value) => value
    None => return false
  }
  if request == "*" {
    return candidate.pre.length() == 0
  }
  let range = request.has_prefix("^") || request.has_prefix("~")
  let base = match
    bootstrap_contract_semver(
      if range {
        request[1:].to_owned()
      } else {
        request
      },
    ) {
    Some(value) => value
    None => return false
  }
  let compare = bootstrap_contract_semver_compare(candidate, base)
  if !range {
    return compare == 0
  }
  if compare < 0 || (candidate.pre.length() > 0 && compare != 0) {
    return false
  }
  if request.has_prefix("~") {
    return candidate.core[0] == base.core[0] &&
      candidate.core[1] == base.core[1]
  }
  if base.core[0] > 0U {
    candidate.core[0] == base.core[0]
  } else if base.core[1] > 0U {
    candidate.core[0] == 0U && candidate.core[1] == base.core[1]
  } else {
    candidate.core == base.core
  }
}

///|
fn bootstrap_contract_hex(value : String, length : Int32) -> Bool {
  let bytes = @utf8.encode(value)
  if bytes.length() != length {
    return false
  }
  for byte in bytes {
    if !(byte >= b'0' && byte <= b'9') && !(byte >= b'a' && byte <= b'f') {
      return false
    }
  }
  true
}

///|
fn bootstrap_contract_source_valid(source : String) -> Bool {
  let bytes = @utf8.encode(source)
  if bytes.length() == 0 || bytes.length() > 2048 {
    return false
  }
  for byte in bytes {
    if byte == b'\x00' {
      return false
    }
  }
  !source.has_prefix("git+") || bootstrap_contract_requirement_valid(source)
}

///|
fn bootstrap_contract_identity(
  package_ : BootstrapPackage,
  lock : BootstrapLockedPackage,
) -> Unit {
  if package_.name != lock.name || package_.version != lock.version {
    bootstrap_fail(
      "locked package identity mismatch for \{lock.name}@\{lock.version}",
    )
  }
}

///|
fn bootstrap_contract_dependencies(
  dependencies : Array[BootstrapDependencyRequest],
) -> Unit {
  if dependencies.length() > 256 {
    bootstrap_fail("package dependencies exceed count bound")
  }
  let names : Set[String] = Set([])
  for dependency in dependencies {
    if !bootstrap_valid_package_name(dependency.name) {
      bootstrap_fail("invalid dependency name: \{dependency.name}")
    }
    if !bootstrap_contract_requirement_valid(dependency.requirement) {
      bootstrap_fail("invalid dependency requirement for \{dependency.name}")
    }
    if !names.add_and_check(dependency.name) {
      bootstrap_fail("duplicate dependency: \{dependency.name}")
    }
  }
}

///|
fn bootstrap_contract_lock(lock : BootstrapLockedPackage) -> Unit {
  if !bootstrap_valid_package_name(lock.name) {
    bootstrap_fail("invalid locked package name")
  }
  if bootstrap_contract_semver(lock.version) is None {
    bootstrap_fail("invalid locked package version")
  }
  if !bootstrap_contract_source_valid(lock.source) {
    bootstrap_fail("invalid locked package source")
  }
  if !lock.integrity.has_prefix("sha256-") ||
    !bootstrap_contract_hex(lock.integrity[7:].to_owned(), 64) {
    bootstrap_fail("invalid locked package integrity")
  }
  if !bootstrap_contract_hex(lock.interface_fingerprint, 64) {
    bootstrap_fail("invalid locked package interface")
  }
}

///|
/// Slash is ASCII 47. Compare paths byte by byte, not with locale ordering.
fn bootstrap_contract_path_compare(left : String, right : String) -> Int32 {
  let length = if left.length() < right.length() {
    left.length()
  } else {
    right.length()
  }
  for index in 0..<length {
    let a = left[index].to_int()
    let b = right[index].to_int()
    if a != b {
      // UTF-8 orders complete code points. Move high surrogates after BMP
      // units above DFFF; no temporary UTF-8 byte arrays are needed in sort.
      let x = if a >= 0xD800 && a <= 0xDBFF {
        a + 0x2000
      } else if a >= 0xE000 {
        a - 0x800
      } else {
        a
      }
      let y = if b >= 0xD800 && b <= 0xDBFF {
        b + 0x2000
      } else if b >= 0xE000 {
        b - 0x800
      } else {
        b
      }
      return x - y
    }
  }
  left.length() - right.length()
}
