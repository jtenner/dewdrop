(module
  (type $box (struct (field eqref)))
  (type $closure (sub (struct (field funcref))))
  (type $direct (func (param i32) (result i32)))
  (type $entry (func (param eqref i32) (result i32)))
  (type $adapter (func (param (ref $box) i32) (result (ref $box))))
  (type $run-type (func (result i32)))

  (import "dew" "identity_box$dew$i32" (func $adapt (type $adapter)))

  (elem declare func $increment)

  (func $increment (type $direct) (param $value i32) (result i32)
    local.get $value
    i32.const 1
    i32.add)

  (func (export "run") (type $run-type) (result i32)
    (local $callback eqref)

    ref.func $increment
    struct.new $closure
    struct.new $box
    i32.const 1
    call $adapt
    struct.get $box 0
    local.set $callback

    local.get $callback
    ref.cast (ref $closure)
    struct.get $closure 0
    ref.test (ref $direct)
    if (result i32)
      i32.const 41
      local.get $callback
      ref.cast (ref $closure)
      struct.get $closure 0
      ref.cast (ref $direct)
      call_ref $direct
    else
      local.get $callback
      i32.const 41
      local.get $callback
      ref.cast (ref $closure)
      struct.get $closure 0
      ref.cast (ref $entry)
      call_ref $entry
    end)
)
