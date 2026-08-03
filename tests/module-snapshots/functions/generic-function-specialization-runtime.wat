(module
  (type (;0;) (func (param i32 eqref eqref) (result eqref)))
  (type (;1;) (func (param eqref) (result eqref)))
  (type (;2;) (func))
  (type (;3;) (func (param i32 i32 i32) (result i32)))
  (type (;4;) (func (param i32 i64 i64) (result i64)))
  (type (;5;) (func (param f64) (result f64)))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (func (;0;) (type 2)
    i32.const 1
    i32.const 42
    i32.const 7
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x656e6567 0x20636972 0x646e6f63 0x6f697469
    v128.const i32x4 0x206c616e 0x00323369 0x00000000 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 23
    struct.new 7
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
    v128.const i32x4 0x656e6567 0x20636972 0x646e6f63 0x6f697469
    v128.const i32x4 0x206c616e 0x00343669 0x00000000 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 23
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    f64.const 0x1.54p+5 (;=42.5;)
    call 3
    f64.const 0x1.54p+5 (;=42.5;)
    f64.eq
    v128.const i32x4 0x656e6567 0x20636972 0x61636f6c 0x3666206c
    v128.const i32x4 0x00000034 0x00000000 0x00000000 0x00000000
    array.new_fixed 6 2
    i32.const 0
    i32.const 17
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;1;) (type 3) (param i32 i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;2;) (type 4) (param i32 i64 i64) (result i64)
    local.get 0
    if (result i64) ;; label = @1
      local.get 1
    else
      local.get 2
    end
  )
  (func (;3;) (type 5) (param f64) (result f64)
    (local f64)
    local.get 0
    local.set 1
    local.get 1
  )
)
