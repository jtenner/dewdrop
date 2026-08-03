(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i64) (result i64)))
  (type (;3;) (func (param eqref) (result eqref)))
  (type (;4;) (func (param eqref i32) (result i32)))
  (type (;5;) (func (param eqref i64) (result i64)))
  (type (;6;) (func (param eqref eqref) (result eqref)))
  (type (;7;) (func (result eqref)))
  (type (;8;) (func (result eqref)))
  (type (;9;) (func))
  (type (;10;) (func (param i32) (result i32)))
  (type (;11;) (func (param i64) (result i64)))
  (type (;12;) (func))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (global (;1;) (mut eqref) ref.null eq)
  (export "main" (func 2))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 3 4)
  (func (;0;) (type 7) (result eqref)
    global.get 0
  )
  (func (;1;) (type 8) (result eqref)
    global.get 1
  )
  (func (;2;) (type 9)
    (local eqref eqref eqref eqref)
    call 0
    local.set 0
    call 1
    local.set 1
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      i32.const 42
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x61637365 0x676e6970 0x6e656720 0x63697265
    v128.const i32x4 0x32336920 0x66657220 0x6e657265 0x00006563
    array.new_fixed 13 2
    i32.const 0
    i32.const 30
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result i64) ;; label = @1
      i64.const 42
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 3
      i64.const 42
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 5)
      call_ref 5
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x61637365 0x676e6970 0x6e656720 0x63697265
    v128.const i32x4 0x34366920 0x66657220 0x6e657265 0x00006563
    array.new_fixed 13 2
    i32.const 0
    i32.const 30
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 10) (param i32) (result i32)
    local.get 0
  )
  (func (;4;) (type 11) (param i64) (result i64)
    local.get 0
  )
  (func (;5;) (type 12)
    ref.func 3
    struct.new 0
    global.set 0
    ref.func 4
    struct.new 0
    global.set 1
  )
)
