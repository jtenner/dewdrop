(module
  (type (;0;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;1;) (func (param (ref 0)) (result (ref 0))))
  (type (;2;) (func))
  (type (;3;) (func (param (ref 0)) (result (ref 0))))
  (type (;4;) (func (param (ref 0)) (result (ref 0))))
  (type (;5;) (struct (field i32)))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (export "echo_box" (func 1))
  (export "echo_box$dew$i32" (func 3))
  (func (;0;) (type 2)
    (local (ref 0))
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    call 2
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x7473656e 0x61206465 0x65726767 0x65746167
    v128.const i32x4 0x65707320 0x6c616963 0x74617a69 0x006e6f69
    array.new_fixed 6 2
    i32.const 0
    i32.const 31
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 3) (param (ref 0)) (result (ref 0))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    ref.cast (ref 0)
    struct.get 0 5
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;2;) (type 4) (param (ref 0)) (result (ref 0))
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;3;) (type 4) (param (ref 0)) (result (ref 0))
    (local eqref)
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    struct.new 5
    struct.new 0
    call 1
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 5
    ref.cast (ref 5)
    struct.get 5 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
  )
)
