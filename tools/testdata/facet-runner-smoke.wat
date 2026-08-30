(module
  (import "facet" "handle_close" (func $handle_close (param i32) (result i32)))
  (import "facet" "args_count" (func $args_count (result i32 i32)))
  (import "facet" "fs_preopen_get" (func $fs_preopen_get (param i32) (result i32 i32)))
  (import "facet" "fd_write_mem32" (func $fd_write_mem32 (param i32 i32 i32 i32) (result i64 i32)))
  (import "facet" "fd_sync" (func $fd_sync (param i32) (result i32)))
  (import "facet" "path_open_mem32_i8" (func $path_open_mem32_i8
    (param i32 i32 i32 i32 i32 i32 i64)
    (result i32 i32)))

  (memory (export "memory") 1)
  (data (i32.const 0) "runner-output.bin")
  (data (i32.const 64) "hello")

  (func (export "main") (result i32)
    (local $directory i32)
    (local $handle i32)
    (local $written i64)
    (local $error i32)

    call $args_count
    local.set $error
    i32.const 2
    i32.ne
    if
      i32.const 1
      return
    end
    local.get $error
    if
      i32.const 2
      return
    end

    i32.const 0
    call $fs_preopen_get
    local.set $error
    local.set $directory
    local.get $error
    if
      i32.const 3
      return
    end

    local.get $directory
    i32.const 0
    i32.const 0
    i32.const 17
    i32.const 0
    i32.const 5
    i64.const 66
    call $path_open_mem32_i8
    local.set $error
    local.set $handle
    local.get $error
    if
      i32.const 4
      return
    end

    local.get $handle
    i32.const 0
    i32.const 64
    i32.const 5
    call $fd_write_mem32
    local.set $error
    local.set $written
    local.get $error
    if
      i32.const 5
      return
    end
    local.get $written
    i64.const 5
    i64.ne
    if
      i32.const 6
      return
    end

    local.get $handle
    call $fd_sync
    if
      i32.const 7
      return
    end

    local.get $handle
    call $handle_close
    if
      i32.const 8
      return
    end

    i32.const 0))
