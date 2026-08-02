(module
  (type (;0;) (func (param i32) (result i32)))
  (type (;1;) (func (param (ref null 0) i32) (result i32)))
  (type (;2;) (func))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut (ref null 0)) ref.null 0)
  (export "main" (func 2))
  (export "__dew_init" (func 4))
  (elem (;0;) declare func 0)
  (func (;0;) (type 0) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 1) (param (ref null 0) i32) (result i32)
    local.get 1
    local.get 0
    call_ref 0
  )
  (func (;2;) (type 2)
    (local (ref null 0) i32 i32)
    ref.func 0
    local.set 0
    i32.const 20
    local.get 0
    call_ref 0
    local.set 1
    ref.func 0
    i32.const 21
    call 1
    local.set 2
    local.get 1
    i32.const 21
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x73206563 0x65726f74 0x6e692064 0x6c206120
    v128.const i32x4 0x6c61636f 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 3
    i32.const 0
    i32.const 36
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    i32.const 22
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x70206563 0x65737361 0x73612064 0x206e6120
    v128.const i32x4 0x75677261 0x746e656d 0x00000000 0x00000000
    array.new_fixed 4 3
    i32.const 0
    i32.const 40
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    global.get 0
    call_ref 0
    i32.const 42
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x73206563 0x65726f74 0x6e692064 0x6d206120
    v128.const i32x4 0x6c75646f 0x61762065 0x0065756c 0x00000000
    array.new_fixed 4 3
    i32.const 0
    i32.const 43
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 3)
    ref.func 0
    global.set 0
  )
  (func (;4;) (type 3)
    call 3
  )
)
