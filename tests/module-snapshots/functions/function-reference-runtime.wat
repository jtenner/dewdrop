(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (func (param i32) (result i32)))
  (type (;2;) (func (param eqref i32) (result i32)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func))
  (type (;5;) (func))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 2))
  (export "__dew_init" (func 4))
  (elem (;0;) declare func 0)
  (func (;0;) (type 1) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 3) (param eqref i32) (result i32)
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
      ref.cast (ref 2)
      call_ref 2
    end
  )
  (func (;2;) (type 4)
    (local eqref i32 i32 eqref eqref)
    ref.func 0
    struct.new 0
    local.set 0
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      i32.const 20
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 3
      i32.const 20
      local.get 3
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    end
    local.set 1
    ref.func 0
    struct.new 0
    i32.const 21
    call 1
    local.set 2
    local.get 1
    i32.const 21
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x73206563 0x65726f74 0x6e692064 0x6c206120
    v128.const i32x4 0x6c61636f 0x00000000 0x00000000 0x00000000
    array.new_fixed 6 3
    i32.const 0
    i32.const 36
    struct.new 7
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
    array.new_fixed 6 3
    i32.const 0
    i32.const 40
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 0
    local.set 4
    local.get 4
    ref.cast (ref 0)
    struct.get 0 0
    ref.test (ref 1)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 1)
      call_ref 1
    else
      local.get 4
      i32.const 41
      local.get 4
      ref.cast (ref 0)
      struct.get 0 0
      ref.cast (ref 2)
      call_ref 2
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x66657220 0x6e657265
    v128.const i32x4 0x73206563 0x65726f74 0x6e692064 0x6d206120
    v128.const i32x4 0x6c75646f 0x61762065 0x0065756c 0x00000000
    array.new_fixed 6 3
    i32.const 0
    i32.const 43
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;3;) (type 5)
    ref.func 0
    struct.new 0
    global.set 0
  )
  (func (;4;) (type 5)
    call 3
  )
)
