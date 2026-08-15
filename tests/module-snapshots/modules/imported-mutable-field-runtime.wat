(module
  (type (;0;) (struct (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (type (;1;) (func (param i32) (result (ref 0))))
  (type (;2;) (func))
  (type (;3;) (array (mut v128)))
  (type (;4;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 3)) (field i32) (field i32)))
  (type (;7;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (struct (field (mut (ref 3))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 1) (param i32) (result (ref 0))
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 2)
    (local eqref i32)
    i32.const 1
    call 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    local.set 1
    local.get 0
    ref.cast (ref 0)
    i32.const 42
    struct.set 0 0
    local.get 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x74756d20 0x656c6261
    v128.const i32x4 0x65696620 0x6220646c 0x726f6665 0x72772065
    v128.const i32x4 0x00657469 0x00000000 0x00000000 0x00000000
    array.new_fixed 3 3
    i32.const 0
    i32.const 35
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x74756d20 0x656c6261
    v128.const i32x4 0x65696620 0x6120646c 0x7361696c 0x00007365
    array.new_fixed 3 2
    i32.const 0
    i32.const 30
    struct.new 4
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
