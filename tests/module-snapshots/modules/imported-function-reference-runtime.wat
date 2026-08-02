(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param (ref 0)) (result i32)))
  (type (;3;) (func (result (ref 0))))
  (type (;4;) (func (param (ref null 1) i32) (result i32)))
  (type (;5;) (func (param (ref null 2) (ref 0)) (result i32)))
  (type (;6;) (func))
  (type (;7;) (func))
  (type (;8;) (array (mut v128)))
  (type (;9;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;10;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 8)) (field i32) (field i32)))
  (type (;12;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (type (;13;) (struct (field (mut (ref 8))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut (ref null 1)) ref.null 1)
  (export "main" (func 5))
  (export "__dew_init" (func 7))
  (elem (;0;) declare func 0 1)
  (func (;0;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 2) (param (ref 0)) (result i32)
    local.get 0
    struct.get 0 0
  )
  (func (;2;) (type 3) (result (ref 0))
    i32.const 42
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;3;) (type 4) (param (ref null 1) i32) (result i32)
    local.get 1
    local.get 0
    call_ref 1
  )
  (func (;4;) (type 5) (param (ref null 2) (ref 0)) (result i32)
    local.get 1
    local.get 0
    call_ref 2
  )
  (func (;5;) (type 6)
    ref.func 0
    i32.const 41
    call 3
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x61637320 0x2072616c
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x00006563 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 3
    i32.const 0
    i32.const 34
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    global.get 0
    call_ref 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6e756620 0x6f697463
    v128.const i32x4 0x61762d6e 0x6465756c 0x646f6d20 0x20656c75
    v128.const i32x4 0x646e6962 0x00676e69 0x00000000 0x00000000
    array.new_fixed 8 3
    i32.const 0
    i32.const 39
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    ref.func 1
    call 2
    call 4
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6d6f6e20 0x6c616e69
    v128.const i32x4 0x6e756620 0x6f697463 0x6572206e 0x65726566
    v128.const i32x4 0x0065636e 0x00000000 0x00000000 0x00000000
    array.new_fixed 8 3
    i32.const 0
    i32.const 35
    struct.new 9
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;6;) (type 7)
    ref.func 0
    global.set 0
  )
  (func (;7;) (type 7)
    call 6
  )
)
