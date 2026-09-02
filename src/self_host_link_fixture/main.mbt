///|
fn self_host_link_io_error_message(error : @fs.IOError) -> String {
  match error {
    @fs.IOError(message) => message
  }
}

///|
fn main {
  let args = @sys.get_cli_args()
  if args.length() != 6 {
    println("usage: self_host_link_fixture CORE STARSHINE FACET TIME OUTPUT")
    @sys.exit(2)
  }
  let core = @fs.read_file_to_bytes(args[1]) catch {
    error => {
      println(
        "cannot read Core Wasm module: \{self_host_link_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  let starshine = @fs.read_file_to_bytes(args[2]) catch {
    error => {
      println(
        "cannot read Starshine provider: \{self_host_link_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  let facet = @fs.read_file_to_bytes(args[3]) catch {
    error => {
      println(
        "cannot read Facet provider: \{self_host_link_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  let time = @fs.read_file_to_bytes(args[4]) catch {
    error => {
      println(
        "cannot read MoonBit time provider: \{self_host_link_io_error_message(error)}",
      )
      @sys.exit(2)
      b""
    }
  }
  match
    @core_linker.link_core_wasm_gc_modules(
      core,
      [
        { provider: "starshine", bytes: starshine, },
        { provider: "facet", bytes: facet, },
        { provider: "__moonbit_time_unstable", bytes: time, },
      ],
      options={
        keep_guest_exports: false,
        validate_each_phase: true,
        run_cleanup: true,
        preserve_dew_memory_zero: true,
      },
    ) {
    Ok(linked) =>
      @fs.write_bytes_to_file(args[5], linked) catch {
        error => {
          println(
            "cannot write linked Wasm module: \{self_host_link_io_error_message(error)}",
          )
          @sys.exit(2)
        }
      }
    Err(error) => {
      println(@debug.to_string(error))
      @sys.exit(1)
    }
  }
}
