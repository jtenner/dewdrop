(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field i32) (field i32)))
  (type (;4;) (struct (field (mut i32))))
  (type (;5;) (func (result (ref 0))))
  (type (;6;) (func (param eqref) (result (ref 0))))
  (type (;7;) (func (param i32) (result (ref 0))))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 7) (param i32) (result (ref 0))
    local.get 0
    i32.const 42
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 0
      i32.const 1
      i32.add
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    ref.cast (ref 0)
  )
  (func (;1;) (type 8)
    (local (ref 3) i32 i32 i32 i32 eqref i32 i32 i32 i32 i32 i32 eqref i32 eqref eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref eqref)
    i32.const 42
    local.set 8
    block ;; label = @1
      local.get 8
      i32.const 42
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 9
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    v128.const i32x4 0x6574696c 0x206c6172 0x74746170 0x206e7265
    v128.const i32x4 0x6374616d 0x00736568 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 23
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    local.set 10
    block ;; label = @1
      local.get 10
      i32.const 41
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 11
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    i32.eqz
    v128.const i32x4 0x6574696c 0x206c6172 0x74746170 0x206e7265
    v128.const i32x4 0x656a6572 0x20737463 0x6d73696d 0x68637461
    array.new_fixed 9 2
    i32.const 0
    i32.const 32
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    i32.const 4
    struct.new 3
    local.set 0
    local.get 0
    local.set 12
    block ;; label = @1
      local.get 12
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 3
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 13
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 13
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 13
    v128.const i32x4 0x6e617473 0x6f6c6164 0x7320656e 0x63757274
    v128.const i32x4 0x61702074 0x72657474 0x0000006e 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 25
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    call 0
    local.set 14
    block ;; label = @1
      local.get 14
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 14
        ref.cast (ref 1)
        struct.get 1 1
        local.set 1
        local.get 1
        i32.const 43
        i32.eq
        v128.const i32x4 0x74746170 0x206e7265 0x646e6962 0x20676e69
        v128.const i32x4 0x65746e65 0x74207372 0x20657572 0x6e617262
        v128.const i32x4 0x00006863 0x00000000 0x00000000 0x00000000
        array.new_fixed 9 3
        i32.const 0
        i32.const 34
        struct.new 10
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        v128.const i32x4 0x656d6f73 0x6c617620 0x73206575 0x6c756f68
        v128.const i32x4 0x616d2064 0x00686374 0x00000000 0x00000000
        array.new_fixed 9 2
        i32.const 0
        i32.const 23
        struct.new 10
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 42
    call 0
    local.set 15
    block ;; label = @1
      local.get 15
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 15
        ref.cast (ref 1)
        struct.get 1 1
        local.set 2
        local.get 2
        i32.const 0
        i32.gt_s
        if (result i32) ;; label = @3
          local.get 2
          i32.const 43
          i32.eq
        else
          i32.const 0
        end
        if ;; label = @3
          local.get 2
          i32.const 43
          i32.eq
          v128.const i32x4 0x646e6962 0x20676e69 0x65746e65 0x63207372
          v128.const i32x4 0x756a6e6f 0x6974636e 0x67206e6f 0x64726175
          v128.const i32x4 0x61686320 0x00006e69 0x00000000 0x00000000
          array.new_fixed 9 3
          i32.const 0
          i32.const 38
          struct.new 10
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        v128.const i32x4 0x72617567 0x20646564 0x74746170 0x206e7265
        v128.const i32x4 0x756f6873 0x6d20646c 0x68637461 0x00000000
        array.new_fixed 9 2
        i32.const 0
        i32.const 28
        struct.new 10
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 0
    call 0
    local.set 16
    block ;; label = @1
      local.get 16
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 16
        ref.cast (ref 1)
        struct.get 1 1
        local.set 3
        local.get 3
        local.set 17
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const -1
        local.set 17
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 17
    local.set 4
    local.get 4
    i32.const -1
    i32.eq
    v128.const i32x4 0x65736c65 0x61726220 0x2068636e 0x646e6168
    v128.const i32x4 0x2073656c 0x6d73696d 0x68637461 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 28
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    call 0
    local.set 18
    block ;; label = @1
      local.get 18
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 19
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 19
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 19
    v128.const i32x4 0x69207369 0x20612073 0x6c6f6f62 0x206e6165
    v128.const i32x4 0x72707865 0x69737365 0x00006e6f 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 26
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 0
    local.set 20
    block ;; label = @1
      local.get 20
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 21
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 21
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 21
    v128.const i32x4 0x74696e75 0x72617620 0x746e6169 0x74617020
    v128.const i32x4 0x6e726574 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 20
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    call 0
    local.set 22
    block ;; label = @1
      local.get 22
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        i32.const 1
        local.set 23
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 23
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 23
    i32.eqz
    v128.const i32x4 0x756f7267 0x20646570 0x73207369 0x6f707075
    v128.const i32x4 0x20737472 0x66657270 0x6f207869 0x61726570
    v128.const i32x4 0x73726f74 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 3
    i32.const 0
    i32.const 36
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    struct.new 4
    local.set 5
    local.get 5
    call 2
    local.set 24
    block ;; label = @1
      local.get 24
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 1
      i32.eq
      if ;; label = @2
        local.get 24
        ref.cast (ref 1)
        struct.get 1 1
        local.set 6
        local.get 6
        i32.const 1
        i32.eq
        v128.const i32x4 0x676e6973 0x6520656c 0x756c6176 0x6f697461
        v128.const i32x4 0x7270206e 0x72657365 0x20736576 0x6e756f62
        v128.const i32x4 0x61762064 0x0065756c 0x00000000 0x00000000
        array.new_fixed 9 3
        i32.const 0
        i32.const 39
        struct.new 10
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
    ref.cast (ref 4)
    struct.get 4 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x73207369 0x74757263 0x65656e69 0x61766520
    v128.const i32x4 0x7461756c 0x65207365 0x74636178 0x6f20796c
    v128.const i32x4 0x0065636e 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 3
    i32.const 0
    i32.const 35
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 25
    block ;; label = @1
      local.get 25
      ref.cast (ref 3)
      struct.get 3 1
      local.set 7
      i32.const 1
      if ;; label = @2
        local.get 7
        i32.const 4
        i32.eq
        v128.const i32x4 0x756f7267 0x20646570 0x75727473 0x63207463
        v128.const i32x4 0x69646e6f 0x6e6f6974 0x6e696220 0x00007364
        array.new_fixed 9 2
        i32.const 0
        i32.const 30
        struct.new 10
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;2;) (type 6) (param eqref) (result (ref 0))
    local.get 0
    ref.cast (ref 4)
    local.get 0
    ref.cast (ref 4)
    struct.get 4 0
    i32.const 1
    i32.add
    struct.set 4 0
    i32.const 1
    local.get 0
    ref.cast (ref 4)
    struct.get 4 0
    struct.new 1
  )
)
