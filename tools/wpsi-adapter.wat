(module
  (type $bytes (array (mut i8)))
  (type $i32_result (struct (field i32) (field i32)))
  (type $i64_result (struct (field i64) (field i32)))
  (type $stat_result (struct (field i32) (field i64) (field i32)))
  (type $env_result (struct (field i32) (field i32) (field i32)))

  (import "wpsi" "handle_close" (func $raw_handle_close (param i32) (result i32)))
  (import "wpsi" "fs_scratch" (func $raw_fs_scratch (result i32 i32)))
  (import "wpsi" "fs_preopen_get" (func $raw_fs_preopen_get (param i32) (result i32 i32 i32)))
  (import "wpsi" "fd_stat" (func $raw_fd_stat (param i32) (result i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)))
  (import "wpsi" "fd_read_array_i8" (func $raw_fd_read (param i32 (ref array) i64 i64) (result i64 i32)))
  (import "wpsi" "fd_write_array_i8" (func $raw_fd_write (param i32 (ref array) i64 i64) (result i64 i32)))
  (import "wpsi" "fd_sync" (func $raw_fd_sync (param i32) (result i32)))
  (import "wpsi" "path_open_array_i8" (func $raw_path_open (param i32 (ref array) i32 i32 i32 i32 i64) (result i32 i32)))
  (import "wpsi" "path_stat_array_i8" (func $raw_path_stat (param i32 (ref array) i32 i32 i32 i32) (result i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)))
  (import "wpsi" "path_create_dir_array_i8" (func $raw_path_create (param i32 (ref array) i32 i32 i32) (result i32)))
  (import "wpsi" "path_remove_array_i8" (func $raw_path_remove (param i32 (ref array) i32 i32 i32 i32) (result i32)))
  (import "wpsi" "path_rename_array_i8" (func $raw_path_rename (param i32 (ref array) i32 i32 i32 i32 (ref array) i32 i32 i32 i32) (result i32)))
  (import "wpsi" "args_count" (func $raw_args_count (result i32 i32)))
  (import "wpsi" "args_get" (func $raw_args_get (param i32) (result i32 i32)))
  (import "wpsi" "env_count" (func $raw_env_count (result i32 i32)))
  (import "wpsi" "env_get" (func $raw_env_get (param i32) (result i32 i32 i32)))
  (import "wpsi" "sysstr_len" (func $raw_sysstr_len (param i32 i32) (result i64 i32)))
  (import "wpsi" "sysstr_read_array_i8" (func $raw_sysstr_read (param i32 i32 (ref array) i32 i32) (result i64 i32)))
  (import "wpsi" "stdio_stdout" (func $raw_stdout (result i32 i32)))
  (import "wpsi" "stdio_stderr" (func $raw_stderr (result i32 i32)))
  (import "wpsi" "proc_exit" (func $raw_exit (param i32)))

  (func (export "i32_result_value") (param (ref $i32_result)) (result i32)
    local.get 0
    struct.get $i32_result 0)
  (func (export "i32_result_error") (param (ref $i32_result)) (result i32)
    local.get 0
    struct.get $i32_result 1)
  (func (export "i64_result_value") (param (ref $i64_result)) (result i64)
    local.get 0
    struct.get $i64_result 0)
  (func (export "i64_result_error") (param (ref $i64_result)) (result i32)
    local.get 0
    struct.get $i64_result 1)
  (func (export "stat_result_file_type") (param (ref $stat_result)) (result i32)
    local.get 0
    struct.get $stat_result 0)
  (func (export "stat_result_size") (param (ref $stat_result)) (result i64)
    local.get 0
    struct.get $stat_result 1)
  (func (export "stat_result_error") (param (ref $stat_result)) (result i32)
    local.get 0
    struct.get $stat_result 2)
  (func (export "env_result_name") (param (ref $env_result)) (result i32)
    local.get 0
    struct.get $env_result 0)
  (func (export "env_result_value") (param (ref $env_result)) (result i32)
    local.get 0
    struct.get $env_result 1)
  (func (export "env_result_error") (param (ref $env_result)) (result i32)
    local.get 0
    struct.get $env_result 2)

  (func (export "handle_close") (param i32) (result i32)
    local.get 0
    call $raw_handle_close)
  (func (export "fd_sync") (param i32) (result i32)
    local.get 0
    call $raw_fd_sync)
  (func (export "proc_exit") (param i32)
    local.get 0
    call $raw_exit)

  (func $wrap_i32_pair (param i32 i32) (result (ref $i32_result))
    local.get 0
    local.get 1
    struct.new $i32_result)
  (func $wrap_i64_pair (param i64 i32) (result (ref $i64_result))
    local.get 0
    local.get 1
    struct.new $i64_result)

  (func (export "fs_scratch") (result (ref $i32_result))
    (local i32 i32)
    call $raw_fs_scratch
    local.set 1
    local.set 0
    local.get 0
    local.get 1
    call $wrap_i32_pair)
  (func (export "fs_preopen_directory") (param i32) (result (ref $i32_result))
    (local i32 i32 i32)
    local.get 0
    call $raw_fs_preopen_get
    local.set 3
    local.set 2
    local.set 1
    local.get 2
    call $raw_handle_close
    drop
    local.get 1
    local.get 3
    call $wrap_i32_pair)

  (func (export "args_count") (result (ref $i32_result))
    (local i32 i32)
    call $raw_args_count
    local.set 1
    local.set 0
    local.get 0
    local.get 1
    call $wrap_i32_pair)
  (func (export "args_get") (param i32) (result (ref $i32_result))
    (local i32 i32)
    local.get 0
    call $raw_args_get
    local.set 2
    local.set 1
    local.get 1
    local.get 2
    call $wrap_i32_pair)
  (func (export "env_count") (result (ref $i32_result))
    (local i32 i32)
    call $raw_env_count
    local.set 1
    local.set 0
    local.get 0
    local.get 1
    call $wrap_i32_pair)
  (func (export "env_get") (param i32) (result (ref $env_result))
    (local i32 i32 i32)
    local.get 0
    call $raw_env_get
    local.set 3
    local.set 2
    local.set 1
    local.get 1
    local.get 2
    local.get 3
    struct.new $env_result)
  (func (export "stdio_stdout") (result (ref $i32_result))
    (local i32 i32)
    call $raw_stdout
    local.set 1
    local.set 0
    local.get 0
    local.get 1
    call $wrap_i32_pair)
  (func (export "stdio_stderr") (result (ref $i32_result))
    (local i32 i32)
    call $raw_stderr
    local.set 1
    local.set 0
    local.get 0
    local.get 1
    call $wrap_i32_pair)
  (func (export "sysstr_len_utf8") (param i32) (result (ref $i64_result))
    (local i64 i32)
    local.get 0
    i32.const 1
    call $raw_sysstr_len
    local.set 2
    local.set 1
    local.get 1
    local.get 2
    call $wrap_i64_pair)
  (func (export "sysstr_read_array_i8") (param i32 (ref $bytes) i32) (result (ref $i64_result))
    (local i64 i32)
    local.get 0
    i32.const 1
    local.get 1
    i32.const 0
    local.get 2
    call $raw_sysstr_read
    local.set 4
    local.set 3
    local.get 3
    local.get 4
    call $wrap_i64_pair)
  (func (export "fd_read_array_i8") (param i32 (ref $bytes) i64 i64) (result (ref $i64_result))
    (local i64 i32)
    local.get 0
    local.get 1
    local.get 2
    local.get 3
    call $raw_fd_read
    local.set 5
    local.set 4
    local.get 4
    local.get 5
    call $wrap_i64_pair)
  (func (export "fd_write_array_i8") (param i32 (ref $bytes) i64 i64) (result (ref $i64_result))
    (local i64 i32)
    local.get 0
    local.get 1
    local.get 2
    local.get 3
    call $raw_fd_write
    local.set 5
    local.set 4
    local.get 4
    local.get 5
    call $wrap_i64_pair)
  (func (export "path_open_array_i8") (param i32 (ref $bytes) i32 i32 i64) (result (ref $i32_result))
    (local i32 i32)
    local.get 0
    local.get 1
    i32.const 0
    local.get 2
    i32.const 1
    local.get 3
    local.get 4
    call $raw_path_open
    local.set 6
    local.set 5
    local.get 5
    local.get 6
    call $wrap_i32_pair)
  (func (export "path_create_dir_array_i8") (param i32 (ref $bytes) i32) (result i32)
    local.get 0
    local.get 1
    i32.const 0
    local.get 2
    i32.const 1
    call $raw_path_create)
  (func (export "path_remove_array_i8") (param i32 (ref $bytes) i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.const 0
    local.get 2
    i32.const 1
    local.get 3
    call $raw_path_remove)
  (func (export "path_rename_array_i8") (param i32 (ref $bytes) i32 (ref $bytes) i32) (result i32)
    local.get 0
    local.get 1
    i32.const 0
    local.get 2
    i32.const 1
    local.get 0
    local.get 3
    i32.const 0
    local.get 4
    i32.const 1
    i32.const 1
    call $raw_path_rename)

  (func $reduced_fd_stat (param i32) (result (ref $stat_result))
    (local i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)
    local.get 0
    call $raw_fd_stat
    local.set 10
    local.set 9
    local.set 8
    local.set 7
    local.set 6
    local.set 5
    local.set 4
    local.set 3
    local.set 2
    local.set 1
    local.get 1
    local.get 3
    local.get 10
    struct.new $stat_result)
  (func (export "fd_stat") (param i32) (result (ref $stat_result))
    local.get 0
    call $reduced_fd_stat)
  (func (export "path_stat_array_i8") (param i32 (ref $bytes) i32) (result (ref $stat_result))
    (local i32 i32 i64 i64 i32 i64 i32 i64 i32 i32)
    local.get 0
    local.get 1
    i32.const 0
    local.get 2
    i32.const 1
    i32.const 0
    call $raw_path_stat
    local.set 12
    local.set 11
    local.set 10
    local.set 9
    local.set 8
    local.set 7
    local.set 6
    local.set 5
    local.set 4
    local.set 3
    local.get 3
    local.get 5
    local.get 12
    struct.new $stat_result)
)
