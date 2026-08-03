(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param i64) (result i64)))
  (type (;2;) (sub (struct (field funcref))))
  (type (;3;) (func (param i32) (result i32)))
  (type (;4;) (func (param eqref i32) (result i32)))
  (type (;5;) (func (param eqref i64) (result i64)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (result eqref)))
  (type (;8;) (func))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 4))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 1)
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 1) (param i64) (result i64)
    local.get 0
    i64.const 1
    i64.add
  )
  (func (;2;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.test (ref 3)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 3)
      call_ref 3
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 4)
      call_ref 4
    end
  )
  (func (;3;) (type 7) (result eqref)
    global.get 0
  )
  (func (;4;) (type 8)
    (local eqref eqref)
    i32.const 41
    call 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x65707865 0x64657463 0x70797420 0x65732065
    v128.const i32x4 0x7463656c 0x6d692073 0x74726f70 0x49206465
    v128.const i32x4 0x6f203233 0x6c726576 0x0064616f 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 43
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 3
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.test (ref 1)
    if (result i64) ;; label = @1
      i64.const 41
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 1
      i64.const 41
      local.get 1
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 5)
      call_ref 5
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x75746572 0x74206e72 0x20657079 0x656c6573
    v128.const i32x4 0x20737463 0x6f706d69 0x64657472 0x34364920
    v128.const i32x4 0x65766f20 0x616f6c72 0x00000064 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 41
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;5;) (type 9)
    ref.func 1
    struct.new 2
    global.set 0
  )
)
