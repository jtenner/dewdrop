(module
  (type (;0;) (func (param eqref) (result eqref)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param i64) (result i64)))
  (type (;4;) (func (param eqref i32) (result i32)))
  (type (;5;) (func (param eqref i64) (result i64)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (param eqref i64) (result i64)))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 0) (param eqref) (result eqref)
    local.get 0
  )
  (func (;1;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 2)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    end
  )
  (func (;2;) (type 7) (param eqref i64) (result i64)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 3)
    if (result i64) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 3)
      call_ref 3
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    end
  )
  (func (;3;) (type 8)
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x72696420 0x20746365 0x6c6c6163 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 28
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x32336920 0x6c616320 0x6361626c 0x0000006b
    array.new_fixed 9 2
    i32.const 0
    i32.const 29
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 42
    i64.const 42
    i64.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e656720 0x63697265
    v128.const i32x4 0x34366920 0x6c616320 0x6361626c 0x0000006b
    array.new_fixed 9 2
    i32.const 0
    i32.const 29
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
