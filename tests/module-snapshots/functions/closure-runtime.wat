(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (sub final 1 (struct (field funcref) (field i32))))
  (type (;3;) (sub final 1 (struct (field funcref) (field i32) (field i32))))
  (type (;4;) (sub final 1 (struct (field funcref))))
  (type (;5;) (func (param i32) (result i32)))
  (type (;6;) (func (param i32) (result eqref)))
  (type (;7;) (func (result i32)))
  (type (;8;) (func (param eqref i32) (result i32)))
  (type (;9;) (func (param eqref i32) (result eqref)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param i32 i32) (result eqref)))
  (type (;12;) (func (param eqref i32) (result i32)))
  (type (;13;) (func))
  (type (;14;) (func))
  (type (;15;) (array (mut v128)))
  (type (;16;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;18;) (struct (field (ref 15)) (field i32) (field i32)))
  (type (;19;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field (mut (ref 15))) (field (mut i32)) (field (mut i32))))
  (global (;0;) (mut eqref) ref.null eq)
  (export "main" (func 4))
  (export "__dew_init" (func 13))
  (elem (;0;) declare func 0 5 7 8)
  (func (;0;) (type 5) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 12) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    end
  )
  (func (;2;) (type 6) (param i32) (result eqref)
    ref.func 5
    local.get 0
    struct.new 2
  )
  (func (;3;) (type 6) (param i32) (result eqref)
    local.get 0
    i32.const 2
    call 6
  )
  (func (;4;) (type 13)
    (local eqref eqref eqref eqref eqref eqref eqref eqref)
    ref.func 8
    struct.new 4
    local.set 0
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      i32.const 42
      local.get 5
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 5
      i32.const 42
      local.get 5
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x2d6e6f6e 0x74706163 0x6e697275 0x616c2067
    v128.const i32x4 0x6164626d 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 20
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    call 2
    local.set 1
    local.get 1
    local.set 6
    local.get 6
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 6
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 6
      i32.const 41
      local.get 6
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x75746572 0x64656e72 0x6f6c6320 0x65727573
    array.new_fixed 15 1
    i32.const 0
    i32.const 16
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 41
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x736f6c63 0x20657275 0x61726170 0x6574656d
    v128.const i32x4 0x00000072 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 17
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 42
    call 1
    i32.const 42
    i32.eq
    v128.const i32x4 0x6e617274 0x72617073 0x20746e65 0x656d616e
    v128.const i32x4 0x61632064 0x61626c6c 0x00006b63 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 26
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    call 9
    i32.const 42
    i32.eq
    v128.const i32x4 0x6e617274 0x72617073 0x20746e65 0x626d616c
    v128.const i32x4 0x63206164 0x626c6c61 0x006b6361 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 27
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 39
    call 3
    local.set 2
    local.get 2
    local.set 7
    local.get 7
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      i32.const 1
      local.get 7
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 7
      i32.const 1
      local.get 7
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x7473656e 0x63206465 0x75736f6c 0x00006572
    array.new_fixed 15 1
    i32.const 0
    i32.const 14
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    struct.new 0
    local.set 3
    local.get 3
    call 10
    i32.const 42
    i32.eq
    v128.const i32x4 0x65666572 0x636e6572 0x61632065 0x72757470
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 17
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    global.get 0
    local.set 4
    local.get 4
    i32.const 40
    call 11
    i32.const 42
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x70616320 0x65727574
    array.new_fixed 15 1
    i32.const 0
    i32.const 16
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    call 12
    i32.const 42
    i32.eq
    v128.const i32x4 0x656d6d69 0x74616964 0x616c2065 0x6164626d
    v128.const i32x4 0x6c616320 0x0000006c 0x00000000 0x00000000
    array.new_fixed 15 2
    i32.const 0
    i32.const 21
    struct.new 16
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;5;) (type 8) (param eqref i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.add
  )
  (func (;6;) (type 11) (param i32 i32) (result eqref)
    ref.func 7
    local.get 0
    local.get 1
    struct.new 3
  )
  (func (;7;) (type 8) (param eqref i32) (result i32)
    local.get 0
    ref.cast (ref 3)
    struct.get 3 1
    local.get 0
    ref.cast (ref 3)
    struct.get 3 2
    i32.add
    local.get 1
    i32.add
  )
  (func (;8;) (type 8) (param eqref i32) (result i32)
    local.get 1
  )
  (func (;9;) (type 5) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;10;) (type 10) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 1
    i32.add
  )
  (func (;11;) (type 8) (param eqref i32) (result i32)
    (local eqref eqref)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 5)
    if (result i32) ;; label = @1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.test (ref 5)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 5)
        call_ref 5
      else
        local.get 2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 8)
        call_ref 8
      end
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 5)
      call_ref 5
    else
      local.get 3
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.test (ref 5)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 5)
        call_ref 5
      else
        local.get 2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 8)
        call_ref 8
      end
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 8)
      call_ref 8
    end
  )
  (func (;12;) (type 5) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;13;) (type 14)
    ref.func 0
    struct.new 1
    global.set 0
  )
)
