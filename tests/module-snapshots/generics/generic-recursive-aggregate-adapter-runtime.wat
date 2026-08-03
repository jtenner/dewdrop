(module
  (type (;0;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;1;) (struct (field (ref 0))))
  (type (;2;) (func (param (ref 1)) (result (ref 1))))
  (type (;3;) (func))
  (type (;4;) (func (param (ref 1)) (result (ref 1))))
  (type (;5;) (func (param (ref 1)) (result (ref 1))))
  (type (;6;) (struct (field i32)))
  (type (;7;) (array (mut v128)))
  (type (;8;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 7)) (field i32) (field i32)))
  (type (;11;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field (mut (ref 7))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (export "echo_envelope" (func 1))
  (export "echo_envelope$dew$i32" (func 3))
  (func (;0;) (type 3)
    (local (ref 1))
    i32.const 42
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    struct.new 1
    call 2
    local.set 0
    local.get 0
    struct.get 1 0
    struct.get 0 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x75636572 0x76697372 0x67612065 0x67657267
    v128.const i32x4 0x20657461 0x63657073 0x696c6169 0x6974617a
    v128.const i32x4 0x00006e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 7 3
    i32.const 0
    i32.const 34
    struct.new 8
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 4) (param (ref 1)) (result (ref 1))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 0
    struct.get 1 0
    struct.get 0 5
    struct.new 0
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;2;) (type 5) (param (ref 1)) (result (ref 1))
    local.get 0
    struct.get 1 0
    struct.get 0 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;3;) (type 5) (param (ref 1)) (result (ref 1))
    (local eqref eqref eqref)
    local.get 0
    ref.cast (ref 1)
    struct.get 1 0
    local.set 1
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    struct.new 6
    struct.new 0
    struct.new 1
    call 1
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 5
    ref.cast (ref 6)
    struct.get 6 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    struct.new 1
  )
)
