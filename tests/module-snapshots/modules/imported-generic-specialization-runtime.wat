(module
  (type (;0;) (func (param i32 eqref eqref) (result eqref)))
  (type (;1;) (func (param i32 i64 i64) (result i64)))
  (type (;2;) (func (param i32 i32 i32) (result i32)))
  (type (;3;) (sub (struct (field funcref))))
  (type (;4;) (func (param i32 i64 i64) (result i64)))
  (type (;5;) (func (param eqref i32 i64 i64) (result i64)))
  (type (;6;) (func (result eqref)))
  (type (;7;) (func))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 3))
  (export "__dew_init" (func 4))
  (elem (;0;) declare func 0)
  (func (;0;) (type 1) (param i32 i64 i64) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;1;) (type 2) (param i32 i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;2;) (type 6) (result eqref)
    global.get 0
  )
  (func (;3;) (type 7)
    (local eqref eqref)
    i32.const 1
    i32.const 42
    i32.const 7
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x6e6f6320 0x69746964 0x6c616e6f 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 28
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 2
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.test (ref 4)
    if (result i64) ;; label = @1
      i32.const 0
      i64.const 7
      i64.const 42
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 1
      i32.const 0
      i64.const 7
      i64.const 42
      local.get 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 5)
      call_ref 5
    end
    i64.const 42
    i64.eq
    v128.const i32x4 0x61637365 0x676e6970 0x706d6920 0x6574726f
    v128.const i32x4 0x65672064 0x6972656e 0x65722063 0x65726566
    v128.const i32x4 0x0065636e 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 3
    i32.const 0
    i32.const 35
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;4;) (type 8)
    ref.func 0
    struct.new 3
    global.set 0
  )
)
