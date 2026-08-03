(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param i64) (result i64)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func (param eqref i64) (result i64)))
  (type (;5;) (func (param eqref) (result eqref)))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func (param eqref i64) (result i64)))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 3)
      call_ref 3
    end
  )
  (func (;1;) (type 7) (param eqref i64) (result i64)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 2)
    if (result i64) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 4)
      call_ref 4
    end
  )
  (func (;2;) (type 8)
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20323369 0x6c6c6163
    v128.const i32x4 0x6b636162 0x66657220 0x6e657265 0x00006563
    array.new_fixed 9 2
    i32.const 0
    i32.const 30
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 42
    i64.const 42
    i64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x20343669 0x6c6c6163
    v128.const i32x4 0x6b636162 0x66657220 0x6e657265 0x00006563
    array.new_fixed 9 2
    i32.const 0
    i32.const 30
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
