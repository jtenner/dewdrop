(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;2;) (func (param eqref eqref) (result (ref 1))))
  (type (;3;) (func (param (ref 1)) (result eqref)))
  (type (;4;) (func (param (ref 1)) (result eqref)))
  (type (;5;) (func))
  (type (;6;) (func (param i32 i64) (result (ref 1))))
  (type (;7;) (func (param (ref 1)) (result i32)))
  (type (;8;) (func (param (ref 1)) (result i64)))
  (type (;9;) (func (param f64 eqref) (result (ref 1))))
  (type (;10;) (func (param (ref 1)) (result f64)))
  (type (;11;) (func (param (ref 1)) (result eqref)))
  (type (;12;) (array (mut v128)))
  (type (;13;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 12)) (field i32) (field i32)))
  (type (;16;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field (mut (ref 12))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (func (;0;) (type 5)
    (local (ref 1))
    i32.const 42
    i64.const 7
    call 1
    local.set 0
    local.get 0
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x75727473 0x69207463
    v128.const i32x4 0x66203233 0x646c6569 0x00000000 0x00000000
    array.new_fixed 12 2
    i32.const 0
    i32.const 24
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    call 3
    i64.const 7
    i64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x75727473 0x69207463
    v128.const i32x4 0x66203436 0x646c6569 0x00000000 0x00000000
    array.new_fixed 12 2
    i32.const 0
    i32.const 24
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f64.const 0x1.54p+5 (;=42.5;)
    i32.const 7
    struct.new 0
    call 4
    local.set 0
    local.get 0
    call 5
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x75727473 0x66207463
    v128.const i32x4 0x66203436 0x646c6569 0x00000000 0x00000000
    array.new_fixed 12 2
    i32.const 0
    i32.const 24
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    call 6
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x75727473 0x72207463
    v128.const i32x4 0x72656665 0x65636e65 0x65696620 0x0000646c
    array.new_fixed 12 2
    i32.const 0
    i32.const 30
    struct.new 13
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 6) (param i32 i64) (result (ref 1))
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    local.get 1
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;2;) (type 7) (param (ref 1)) (result i32)
    local.get 0
    struct.get 1 0
  )
  (func (;3;) (type 8) (param (ref 1)) (result i64)
    local.get 0
    struct.get 1 7
  )
  (func (;4;) (type 9) (param f64 eqref) (result (ref 1))
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    local.get 0
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 1
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;5;) (type 10) (param (ref 1)) (result f64)
    local.get 0
    struct.get 1 3
  )
  (func (;6;) (type 11) (param (ref 1)) (result eqref)
    local.get 0
    struct.get 1 11
  )
)
