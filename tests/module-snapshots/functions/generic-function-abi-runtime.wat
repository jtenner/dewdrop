(module
  (type (;0;) (func (param i32 eqref eqref) (result eqref)))
  (type (;1;) (func (param i32 eqref eqref) (result eqref)))
  (type (;2;) (func (param eqref i32 eqref eqref) (result eqref)))
  (type (;3;) (func))
  (type (;4;) (func (param i32 i32 i32) (result i32)))
  (type (;5;) (func (param i32 i64 i64) (result i64)))
  (type (;6;) (func (param i32 i32 f64 f64) (result f64)))
  (type (;7;) (func (param i32 i32 i32) (result i32)))
  (type (;8;) (func (param i32 i64 i64) (result i64)))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (func (;0;) (type 3)
    i32.const 1
    i32.const 42
    i32.const 7
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x7473656e 0x67206465 0x72656e65 0x69206369
    v128.const i32x4 0x00003233 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 18
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i64.const 7
    i64.const 42
    call 2
    i64.const 42
    i64.eq
    v128.const i32x4 0x7473656e 0x67206465 0x72656e65 0x69206369
    v128.const i32x4 0x00003436 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 18
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 0
    f64.const 0x1.cp+2 (;=7;)
    f64.const 0x1.54p+5 (;=42.5;)
    call 3
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x6f636573 0x6720646e 0x72656e65 0x70206369
    v128.const i32x4 0x6d617261 0x72657465 0x72616320 0x72656972
    array.new_fixed 9 2
    i32.const 0
    i32.const 32
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 4) (param i32 i32 i32) (result i32)
    local.get 0
    local.get 1
    local.get 2
    call 4
  )
  (func (;2;) (type 5) (param i32 i64 i64) (result i64)
    local.get 0
    local.get 1
    local.get 2
    call 5
  )
  (func (;3;) (type 6) (param i32 i32 f64 f64) (result f64)
    (local f64)
    local.get 1
    if (result f64) ;; label = @1
      local.get 2
    else
      local.get 3
    end
    local.set 4
    local.get 4
  )
  (func (;4;) (type 7) (param i32 i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;5;) (type 8) (param i32 i64 i64) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
)
