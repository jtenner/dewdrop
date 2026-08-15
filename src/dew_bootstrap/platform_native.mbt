///|
#borrow(command)
extern "C" fn bootstrap_system_ffi(command : Bytes) -> Int = "dewdrop_bootstrap_system"

///|
extern "C" fn bootstrap_getpid_ffi() -> Int = "dewdrop_bootstrap_getpid"

///|
#borrow(path, content)
extern "C" fn bootstrap_atomic_write_ffi(
  path : Bytes,
  path_length : Int,
  content : Bytes,
) -> Int = "dewdrop_bootstrap_atomic_write"

///|
#borrow(source, destination)
extern "C" fn bootstrap_rename_ffi(source : Bytes, destination : Bytes) -> Int = "dewdrop_bootstrap_rename"

///|
#borrow(path)
extern "C" fn bootstrap_remove_tree_ffi(path : Bytes, path_length : Int) -> Int = "dewdrop_bootstrap_remove_tree"

///|
fn bootstrap_shell_quote(value : String) -> String {
  let bytes = @utf8.encode(value)
  let output = Buffer(size_hint=bytes.length() + 2)
  output.write_byte(b'\'')
  for byte in bytes {
    if byte == b'\'' {
      output.write_bytes(b"'\\''")
    } else {
      output.write_byte(byte)
    }
  }
  output.write_byte(b'\'')
  @utf8.decode(output.to_bytes()) catch {
    _ => "''"
  }
}

///|
fn bootstrap_run_process(arguments : Array[String]) -> Int {
  let command = Buffer()
  for index, argument in arguments {
    if index > 0 {
      command.write_byte(b' ')
    }
    command.write_string_utf8(bootstrap_shell_quote(argument))
  }
  let bytes = command.to_bytes()
  bootstrap_system_ffi(bytes)
}

///|
fn bootstrap_process_id() -> Int {
  bootstrap_getpid_ffi()
}

///|
fn bootstrap_platform_atomic_write(
  path : String,
  content : Bytes,
) -> Result[Unit, String] {
  let path_bytes = @utf8.encode(path)
  let result = bootstrap_atomic_write_ffi(
    path_bytes,
    path_bytes.length(),
    content,
  )
  if result == 0 {
    Ok(())
  } else {
    Err("cannot atomically write \{path}: errno \{-result}")
  }
}

///|
fn bootstrap_platform_remove_tree(path : String) -> Result[Bool, String] {
  let path_bytes = @utf8.encode(path)
  let result = bootstrap_remove_tree_ffi(path_bytes, path_bytes.length())
  if result >= 0 {
    Ok(result == 1)
  } else {
    Err("cannot remove \{path}: errno \{-result}")
  }
}

///|
fn bootstrap_rename(
  source : String,
  destination : String,
) -> Result[Unit, String] {
  let source_bytes = @utf8.encode(source + "\u0000")
  let destination_bytes = @utf8.encode(destination + "\u0000")
  let result = bootstrap_rename_ffi(source_bytes, destination_bytes)
  if result == 0 {
    Ok(())
  } else {
    Err("cannot rename \{source} to \{destination}: errno \{-result}")
  }
}
