(module
  (type (;0;) (struct (field i32)))
  (type (;1;) (sub (struct (field funcref))))
  (type (;2;) (sub final 1 (struct (field funcref) (field i32))))
  (type (;3;) (sub final 1 (struct (field funcref) (field i32) (field i32))))
  (type (;4;) (func (param i32) (result i32)))
  (type (;5;) (func (param i32) (result eqref)))
  (type (;6;) (func (result i32)))
  (type (;7;) (func (param eqref i32) (result i32)))
  (type (;8;) (func (param eqref i32) (result eqref)))
  (type (;9;) (func (param eqref) (result i32)))
  (type (;10;) (func (param i32 i32) (result eqref)))
  (type (;11;) (func (param eqref i32) (result i32)))
  (type (;12;) (func))
  (type (;13;) (array (mut v128)))
  (type (;14;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;15;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 13)) (field i32) (field i32)))
  (type (;17;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field (mut (ref 13))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 4))
  (elem (;0;) declare func 0 5 7)
  (func (;0;) (type 4) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
  (func (;1;) (type 11) (param eqref i32) (result i32)
    (local eqref)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 4)
    if (result i32) ;; label = @1
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 2
      local.get 1
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 7)
      call_ref 7
    end
  )
  (func (;2;) (type 5) (param i32) (result eqref)
    ref.func 5
    local.get 0
    struct.new 2
  )
  (func (;3;) (type 5) (param i32) (result eqref)
    (local eqref)
    local.get 0
    i32.const 2
    call 6
  )
  (func (;4;) (type 12)
    (local eqref eqref eqref eqref eqref eqref eqref eqref eqref)
    i32.const 42
    call 8
    i32.const 42
    i32.eq
    v128.const i32x4 0x2d6e6f6e 0x74706163 0x6e697275 0x616c2067
    v128.const i32x4 0x6164626d 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 20
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    call 2
    local.set 1
    local.get 1
    local.set 7
    local.get 7
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 4)
    if (result i32) ;; label = @1
      i32.const 41
      local.get 7
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 7
      i32.const 41
      local.get 7
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 7)
      call_ref 7
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x75746572 0x64656e72 0x6f6c6320 0x65727573
    array.new_fixed 13 1
    i32.const 0
    i32.const 16
    struct.new 14
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
    array.new_fixed 13 2
    i32.const 0
    i32.const 17
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 39
    call 3
    local.set 2
    local.get 2
    local.set 8
    local.get 8
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 4)
    if (result i32) ;; label = @1
      i32.const 1
      local.get 8
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 8
      i32.const 1
      local.get 8
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 7)
      call_ref 7
    end
    i32.const 42
    i32.eq
    v128.const i32x4 0x7473656e 0x63206465 0x75736f6c 0x00006572
    array.new_fixed 13 1
    i32.const 0
    i32.const 14
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    struct.new 0
    local.set 3
    local.get 3
    call 9
    i32.const 42
    i32.eq
    v128.const i32x4 0x65666572 0x636e6572 0x61632065 0x72757470
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 17
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    ref.func 0
    struct.new 1
    local.set 5
    local.get 5
    i32.const 40
    call 10
    i32.const 42
    i32.eq
    v128.const i32x4 0x636e7566 0x6e6f6974 0x70616320 0x65727574
    array.new_fixed 13 1
    i32.const 0
    i32.const 16
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 41
    call 11
    i32.const 42
    i32.eq
    v128.const i32x4 0x656d6d69 0x74616964 0x616c2065 0x6164626d
    v128.const i32x4 0x6c616320 0x0000006c 0x00000000 0x00000000
    array.new_fixed 13 2
    i32.const 0
    i32.const 21
    struct.new 14
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;5;) (type 7) (param eqref i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 2)
    struct.get 2 1
    i32.add
  )
  (func (;6;) (type 10) (param i32 i32) (result eqref)
    ref.func 7
    local.get 0
    local.get 1
    struct.new 3
  )
  (func (;7;) (type 7) (param eqref i32) (result i32)
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
  (func (;8;) (type 4) (param i32) (result i32)
    local.get 0
  )
  (func (;9;) (type 9) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 0)
    struct.get 0 0
    i32.const 1
    i32.add
  )
  (func (;10;) (type 7) (param eqref i32) (result i32)
    (local eqref eqref)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 1)
    struct.get 1 0
    ref.test (ref 4)
    if (result i32) ;; label = @1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.test (ref 4)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 4)
        call_ref 4
      else
        local.get 2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 7)
        call_ref 7
      end
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 4)
      call_ref 4
    else
      local.get 3
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.test (ref 4)
      if (result i32) ;; label = @2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 4)
        call_ref 4
      else
        local.get 2
        local.get 1
        local.get 2
        ref.cast (ref 1)
        struct.get 1 0
        ref.cast (ref 7)
        call_ref 7
      end
      local.get 3
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 7)
      call_ref 7
    end
  )
  (func (;11;) (type 4) (param i32) (result i32)
    local.get 0
    i32.const 1
    i32.add
  )
)
