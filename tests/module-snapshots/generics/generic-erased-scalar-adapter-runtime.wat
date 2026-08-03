(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i64) (result i64)))
  (type (;3;) (func (param f32) (result f32)))
  (type (;4;) (func (param f64) (result f64)))
  (type (;5;) (func (param v128) (result v128)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (param eqref i32) (result i32)))
  (type (;8;) (func (param eqref i64) (result i64)))
  (type (;9;) (func (param eqref f32) (result f32)))
  (type (;10;) (func (param eqref f64) (result f64)))
  (type (;11;) (func (param eqref v128) (result v128)))
  (type (;12;) (func (param eqref eqref) (result eqref)))
  (type (;13;) (func (param i32 eqref eqref) (result eqref)))
  (type (;14;) (func (result eqref)))
  (type (;15;) (func (result eqref)))
  (type (;16;) (func (result eqref)))
  (type (;17;) (func (result eqref)))
  (type (;18;) (func (result eqref)))
  (type (;19;) (func))
  (type (;20;) (func (param eqref) (result eqref)))
  (type (;21;) (func (param i32 eqref eqref) (result eqref)))
  (type (;22;) (func (param i32) (result i32)))
  (type (;23;) (func (param i64) (result i64)))
  (type (;24;) (func (param f32) (result f32)))
  (type (;25;) (func (param f64) (result f64)))
  (type (;26;) (func (param v128) (result v128)))
  (type (;27;) (struct (field i32)))
  (type (;28;) (struct (field i64)))
  (type (;29;) (struct (field f32)))
  (type (;30;) (struct (field f64)))
  (type (;31;) (struct (field v128)))
  (type (;32;) (func))
  (type (;33;) (array (mut v128)))
  (type (;34;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;36;) (struct (field (ref 33)) (field i32) (field i32)))
  (type (;37;) (struct (field (mut (ref 33))) (field (mut i32)) (field (mut i32))))
  (type (;38;) (struct (field (mut (ref 33))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (global (;2;) (mut eqref) ref.null eq)
  (global (;3;) (mut eqref) ref.null eq)
  (global (;4;) (mut eqref) ref.null eq)
  (export "main" (func 5))
  (export "identity" (func 6))
  (export "choose" (func 7))
  (export "identity$dew$i32" (func 13))
  (export "identity$dew$i64" (func 14))
  (export "identity$dew$f32" (func 15))
  (export "identity$dew$f64" (func 16))
  (export "identity$dew$v128" (func 17))
  (export "__dew_init" (func 18))
  (elem (;0;) declare func 8 9 10 11 12)
  (func (;0;) (type 14) (result eqref)
    global.get 0
  )
  (func (;1;) (type 15) (result eqref)
    global.get 1
  )
  (func (;2;) (type 16) (result eqref)
    global.get 2
  )
  (func (;3;) (type 17) (result eqref)
    global.get 3
  )
  (func (;4;) (type 18) (result eqref)
    global.get 4
  )
  (func (;5;) (type 19)
    (local eqref eqref eqref eqref eqref eqref eqref eqref)
    call 0
    local.set 0
    call 1
    local.set 1
    call 2
    local.set 2
    call 3
    local.set 3
    call 4
    local.set 4
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 5
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 5
      i32.const 42
      local.get 5
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 7)
      call_ref 7
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x63657073 0x696c6169 0x2064657a 0x20323369
    v128.const i32x4 0x6e656469 0x79746974 0x00000000 0x00000000
    array.new_fixed 33 2
    i32.const 0
    i32.const 24
    struct.new 34
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 6
    local.get 6
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result i64) ;; label = @1
      i64.const 42
      local.get 6
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 6
      i64.const 42
      local.get 6
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 8)
      call_ref 8
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x63657073 0x696c6169 0x2064657a 0x20343669
    v128.const i32x4 0x6e656469 0x79746974 0x00000000 0x00000000
    array.new_fixed 33 2
    i32.const 0
    i32.const 24
    struct.new 34
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 7
    local.get 7
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 4)
    if (result f64) ;; label = @1
      f64.const 0x1.54p+5 (;=42.5;)
      local.get 7
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 7
      f64.const 0x1.54p+5 (;=42.5;)
      local.get 7
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 10)
      call_ref 10
    end
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x63657073 0x696c6169 0x2064657a 0x20343666
    v128.const i32x4 0x6e656469 0x79746974 0x00000000 0x00000000
    array.new_fixed 33 2
    i32.const 0
    i32.const 24
    struct.new 34
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;6;) (type 20) (param eqref) (result eqref)
    local.get 0
  )
  (func (;7;) (type 21) (param i32 eqref eqref) (result eqref)
    local.get 0
    if (result eqref) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;8;) (type 22) (param i32) (result i32)
    local.get 0
  )
  (func (;9;) (type 23) (param i64) (result i64)
    local.get 0
  )
  (func (;10;) (type 24) (param f32) (result f32)
    local.get 0
  )
  (func (;11;) (type 25) (param f64) (result f64)
    local.get 0
  )
  (func (;12;) (type 26) (param v128) (result v128)
    local.get 0
  )
  (func (;13;) (type 22) (param i32) (result i32)
    local.get 0
    struct.new 27
    call 6
    ref.cast (ref 27)
    struct.get 27 0
  )
  (func (;14;) (type 23) (param i64) (result i64)
    local.get 0
    struct.new 28
    call 6
    ref.cast (ref 28)
    struct.get 28 0
  )
  (func (;15;) (type 24) (param f32) (result f32)
    local.get 0
    struct.new 29
    call 6
    ref.cast (ref 29)
    struct.get 29 0
  )
  (func (;16;) (type 25) (param f64) (result f64)
    local.get 0
    struct.new 30
    call 6
    ref.cast (ref 30)
    struct.get 30 0
  )
  (func (;17;) (type 26) (param v128) (result v128)
    local.get 0
    struct.new 31
    call 6
    ref.cast (ref 31)
    struct.get 31 0
  )
  (func (;18;) (type 32)
    ref.func 8
    struct.new 0
    global.set 0
    ref.func 9
    struct.new 0
    global.set 1
    ref.func 10
    struct.new 0
    global.set 2
    ref.func 11
    struct.new 0
    global.set 3
    ref.func 12
    struct.new 0
    global.set 4
  )
)
