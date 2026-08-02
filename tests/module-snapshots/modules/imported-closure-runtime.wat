(module
  (type (;0;) (sub (struct (field funcref))))
  (type (;1;) (sub final 0 (struct (field funcref) (field i32))))
  (type (;2;) (func (param i32) (result i32)))
  (type (;3;) (func (param eqref i32) (result i32)))
  (type (;4;) (func (param i32) (result eqref)))
  (type (;5;) (sub (struct (field funcref))))
  (type (;6;) (func (param eqref i32) (result i32)))
  (type (;7;) (func))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null none)
  (export "main" (func 3))
  (export "__dew_init" (func 5))
  (elem (;0;) declare func 1)
  (func (;0;) (type 4) (param i32) (result eqref)
    ref.func 1
    local.get 0
    struct.new 1
  )
  (func (;1;) (type 3) (param eqref i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    i32.add
  )
  (func (;2;) (type 6) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.test (ref 2)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 3)
      call_ref 3
    end
  )
  (func (;3;) (type 7)
    (local eqref eqref eqref eqref)
    i32.const 2
    call 0
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 5)
    struct.get 5 0
    ref.test (ref 2)
    if (result i32) ;; label = @1
      i32.const 40
      local.get 1
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 1
      i32.const 40
      local.get 1
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 3)
      call_ref 3
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x74657220 0x656e7275
    v128.const i32x4 0x6c632064 0x7275736f 0x00000065 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 25
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 40
    call 2
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6f6c6320 0x65727573
    v128.const i32x4 0x72617020 0x74656d61 0x00007265 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 26
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 0
    local.set 2
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.test (ref 2)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 2
      i32.const 41
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 3)
      call_ref 3
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x6f706d69 0x64657472 0x6f747320 0x20646572
    v128.const i32x4 0x736f6c63 0x00657275 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 23
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    call 0
    local.set 3
    local.get 3
    ref.cast (ref 5)
    struct.get 5 0
    ref.test (ref 2)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 3
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 2)
      call_ref 2
    else
      local.get 3
      i32.const 41
      local.get 3
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 3)
      call_ref 3
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x656d6d69 0x74616964 0x6d692065 0x74726f70
    v128.const i32x4 0x72206465 0x72757465 0x2064656e 0x736f6c63
    v128.const i32x4 0x00657275 0x00000000 0x00000000 0x00000000
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
    i32.const 1
    call 0
    global.set 0
  )
  (func (;5;) (type 8)
    call 4
  )
)
