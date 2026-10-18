(module
 (import "wasi_snapshot_preview1" "fd_read" (func $read (param i32 i32 i32 i32) (result i32)))
 (import "wasi_snapshot_preview1" "fd_write" (func $write (param i32 i32 i32 i32) (result i32)))
 (memory (export "memory") 2)
 (data (i32.const 0) "\40\00\00\00\00\00\01\00")
 (data (i32.const 8) "\24\00\00\00\04\00\00\00")
 (func (export "main")
  (block $done (loop $next
   (if (call $read (i32.const 0) (i32.const 0) (i32.const 1) (i32.const 32)) (then unreachable))
   (br_if $done (i32.eqz (i32.load (i32.const 32))))
   (i32.store (i32.const 36) (i32.add (i32.load (i32.const 36)) (i32.load (i32.const 32))))
   (br $next)))
  (drop (call $write (i32.const 1) (i32.const 8) (i32.const 1) (i32.const 40)))))