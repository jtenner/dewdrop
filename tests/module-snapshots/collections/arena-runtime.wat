(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (struct (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11))))
  (type (;15;) (sub (struct (field funcref))))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 11))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 11))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param i32 i32 i32)))
  (type (;33;) (func (param i32 eqref) (result (ref 11))))
  (type (;34;) (func (param (ref 11) i32)))
  (type (;35;) (func (param (ref 11)) (result (ref 11))))
  (type (;36;) (func (param (ref 11) eqref i32 i32)))
  (type (;37;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;38;) (func (param i32) (result i32)))
  (type (;39;) (func (param i32) (result i32)))
  (type (;40;) (func (param (ref 13)) (result i32)))
  (type (;41;) (func (param (ref 13) i32) (result i32)))
  (type (;42;) (func (param i32 eqref) (result (ref 14))))
  (type (;43;) (func (param (ref 14)) (result i32)))
  (type (;44;) (func (param (ref 14) eqref) (result i32)))
  (type (;45;) (func (param (ref 14) i32) (result (ref 8))))
  (type (;46;) (func (param (ref 14) i32) (result eqref)))
  (type (;47;) (func (param (ref 14) i32 eqref) (result i32)))
  (type (;48;) (func (param (ref 14)) (result i32)))
  (type (;49;) (func (param (ref 14) i32)))
  (type (;50;) (func (param (ref 14) i32)))
  (type (;51;) (func (param (ref 14)) (result (ref 14))))
  (type (;52;) (func (param (ref 14) eqref i32 i32)))
  (type (;53;) (func (param (ref 14) i32 i32) (result (ref 13))))
  (type (;54;) (func (param (ref 14) (ref 13)) (result (ref 11))))
  (type (;55;) (func (param i32 i32) (result (ref 14))))
  (type (;56;) (func (param (ref 14) i32) (result (ref 8))))
  (type (;57;) (func (param (ref 14) i32) (result i32)))
  (type (;58;) (func (param (ref 14)) (result i32)))
  (type (;59;) (func (param (ref 14) i32) (result i32)))
  (type (;60;) (func (param (ref 14) i32 i32) (result i32)))
  (type (;61;) (func (param (ref 14)) (result i32)))
  (type (;62;) (func (param (ref 14) i32 i32) (result (ref 13))))
  (type (;63;) (func (param (ref 14) (ref 13)) (result (ref 11))))
  (type (;64;) (func (param (ref 14)) (result (ref 14))))
  (type (;65;) (func (param (ref 14) i32 i32 i32)))
  (type (;66;) (func (param (ref 14) i32)))
  (type (;67;) (func (param i32 i32) (result (ref 11))))
  (type (;68;) (func (param (ref 11) i32 i32) (result (ref 11))))
  (type (;69;) (func (param (ref 11)) (result (ref 11))))
  (type (;70;) (func (param (ref 11) i32 i32 i32)))
  (type (;71;) (func (param (ref 14) i32)))
  (type (;72;) (func (param (ref 11) i32)))
  (type (;73;) (func))
  (type (;74;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;75;) (struct))
  (type (;76;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;77;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;78;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;79;) (array (mut v128)))
  (type (;80;) (struct (field (ref 79)) (field i32) (field i32)))
  (type (;81;) (struct (field (ref 79)) (field i32) (field i32)))
  (type (;82;) (struct (field (ref 79)) (field i32) (field i32)))
  (type (;83;) (struct (field (mut (ref 79))) (field (mut i32)) (field (mut i32))))
  (type (;84;) (struct (field (mut (ref 79))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 23))
  (func (;0;) (type 32) (param i32 i32 i32)
    local.get 1
    local.get 2
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      local.get 0
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;1;) (type 38) (param i32) (result i32)
    local.get 0
    i32.const 2147483647
    i32.gt_u
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
    end
  )
  (func (;2;) (type 39) (param i32) (result i32)
    local.get 0
    i32.const 0
    i32.lt_s
    if (result i32) ;; label = @1
      unreachable
    else
      local.get 0
    end
  )
  (func (;3;) (type 40) (param (ref 13)) (result i32)
    local.get 0
    ref.cast (ref 13)
    struct.get 13 0
    local.get 0
    ref.cast (ref 13)
    struct.get 13 1
    i32.add
  )
  (func (;4;) (type 41) (param (ref 13) i32) (result i32)
    local.get 1
    local.get 0
    ref.cast (ref 13)
    struct.get 13 0
    i32.ge_s
    if (result i32) ;; label = @1
      local.get 1
      local.get 0
      call 3
      i32.lt_s
    else
      i32.const 0
    end
  )
  (func (;5;) (type 55) (param i32 i32) (result (ref 14))
    local.get 0
    call 2
    local.get 1
    call 17
    ref.cast (ref 11)
    struct.new 14
    ref.cast (ref 14)
  )
  (func (;6;) (type 56) (param (ref 14) i32) (result (ref 8))
    (local eqref i32 eqref)
    local.get 1
    i32.const -1
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 0
      ref.cast (ref 14)
      struct.get 14 0
      local.get 1
      call 2
      local.set 3
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      i32.lt_u
      if (result eqref) ;; label = @2
        i32.const 1
        local.get 2
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 3
        array.get 0
        struct.new 9
      else
        i32.const 0
        struct.new 8
      end
      ref.cast (ref 8)
    end
    ref.cast (ref 8)
  )
  (func (;7;) (type 57) (param (ref 14) i32) (result i32)
    (local i32 eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    call 1
    local.set 2
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    local.get 1
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 3
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      struct.set 11 0
      local.get 3
      ref.cast (ref 11)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 11)
    local.get 3
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 2
  )
  (func (;8;) (type 58) (param (ref 14)) (result i32)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    call 1
  )
  (func (;9;) (type 59) (param (ref 14) i32) (result i32)
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    local.get 1
    call 2
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
  )
  (func (;10;) (type 60) (param (ref 14) i32 i32) (result i32)
    (local eqref i32 eqref i32)
    local.get 1
    i32.const -1
    i32.eq
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      ref.cast (ref 14)
      struct.get 14 0
      local.get 1
      call 2
      local.set 4
      local.get 2
      local.set 6
      local.set 3
      local.get 4
      local.get 3
      ref.cast (ref 11)
      struct.get 11 1
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 3
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        local.get 6
        array.set 0
        i32.const 1
      else
        i32.const 0
      end
    end
  )
  (func (;11;) (type 61) (param (ref 14)) (result i32)
    local.get 0
    ref.cast (ref 14)
    call 8
  )
  (func (;12;) (type 62) (param (ref 14) i32 i32) (result (ref 13))
    (local i32 i32 i32)
    local.get 1
    call 2
    local.set 3
    local.get 2
    call 2
    local.set 4
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 5
    local.get 3
    local.get 5
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 5
      local.get 3
      i32.sub
      i32.gt_u
    end
    if (result eqref) ;; label = @1
      unreachable
    else
      local.get 1
      local.get 2
      struct.new 13
    end
    ref.cast (ref 13)
  )
  (func (;13;) (type 63) (param (ref 14) (ref 13)) (result (ref 11))
    (local i32 i32 i32)
    local.get 1
    ref.cast (ref 13)
    struct.get 13 0
    call 2
    local.set 2
    local.get 1
    ref.cast (ref 13)
    struct.get 13 1
    call 2
    local.set 3
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    struct.get 11 1
    local.set 4
    local.get 2
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 4
      local.get 2
      i32.sub
      i32.gt_u
    end
    if (result eqref) ;; label = @1
      unreachable
    else
      local.get 0
      ref.cast (ref 14)
      struct.get 14 0
      ref.cast (ref 11)
      local.get 2
      local.get 2
      local.get 3
      i32.add
      call 18
    end
    ref.cast (ref 11)
  )
  (func (;14;) (type 64) (param (ref 14)) (result (ref 14))
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    call 19
    ref.cast (ref 11)
    struct.new 14
    ref.cast (ref 14)
  )
  (func (;15;) (type 65) (param (ref 14) i32 i32 i32)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    local.get 1
    local.get 2
    call 2
    local.get 3
    call 2
    call 20
  )
  (func (;16;) (type 66) (param (ref 14) i32)
    local.get 0
    ref.cast (ref 14)
    local.get 1
    call 21
  )
  (func (;17;) (type 67) (param i32 i32) (result (ref 11))
    (local eqref i32 eqref i32)
    local.get 0
    local.set 3
    local.get 1
    local.get 3
    array.new 0
    local.get 3
    local.get 3
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;18;) (type 68) (param (ref 11) i32 i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 1
    local.get 2
    call 0
    local.get 0
    local.set 3
    local.get 2
    local.get 1
    i32.sub
    local.set 4
    local.get 4
    array.new_default 0
    local.set 5
    local.get 5
    ref.cast (ref 0)
    i32.const 0
    local.get 3
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 1
    local.get 4
    array.copy 0 0
    local.get 5
    local.get 4
    local.get 4
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;19;) (type 69) (param (ref 11)) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 11)
    struct.get 11 1
    local.set 2
    local.get 2
    array.new_default 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    i32.const 0
    local.get 2
    array.copy 0 0
    local.get 3
    local.get 2
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;20;) (type 70) (param (ref 11) i32 i32 i32)
    (local eqref i32 eqref i32)
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    local.get 2
    local.get 3
    call 0
    local.get 0
    local.set 4
    local.get 1
    local.set 7
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 2
    local.get 7
    local.get 3
    local.get 2
    i32.sub
    array.fill 0
  )
  (func (;21;) (type 71) (param (ref 14) i32)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 0
    ref.cast (ref 11)
    local.get 1
    call 2
    call 22
  )
  (func (;22;) (type 72) (param (ref 11) i32)
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 11)
    local.get 3
    struct.set 11 1
  )
  (func (;23;) (type 73)
    (local eqref i32 i32 i32 i32 i32 eqref eqref eqref eqref eqref i32 eqref eqref)
    i32.const 0
    i32.const 0
    call 5
    local.set 0
    i32.const -1
    i32.const -1
    i32.eq
    v128.const i32x4 0x6e6f7277 0x696d2067 0x6e697373 0x72612067
    v128.const i32x4 0x20616e65 0x00006469 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 22
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    i32.const -1
    call 6
    local.set 9
    block ;; label = @1
      local.get 9
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        v128.const i32x4 0x7373696d 0x20676e69 0x6d206469 0x20747375
        v128.const i32x4 0x75746572 0x4e206e72 0x00656e6f 0x00000000
        array.new_fixed 79 2
        i32.const 0
        i32.const 27
        struct.new 80
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    i32.const 10
    call 7
    local.set 1
    local.get 0
    ref.cast (ref 14)
    i32.const 20
    call 7
    local.set 2
    local.get 1
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      i32.const 1
      i32.eq
    else
      i32.const 0
    end
    v128.const i32x4 0x6e657261 0x64692061 0x72612073 0x6f6e2065
    v128.const i32x4 0x65642074 0x0065736e 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 23
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    call 8
    i32.const 2
    i32.eq
    v128.const i32x4 0x6e6f7277 0x72612067 0x20616e65 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 18
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    local.get 2
    call 9
    i32.const 20
    i32.eq
    v128.const i32x4 0x6e6f7277 0x72612067 0x20616e65 0x756c6176
    v128.const i32x4 0x00000065 0x00000000 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 17
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    local.get 1
    i32.const 11
    call 10
    v128.const i32x4 0x6e657261 0x65732061 0x65722074 0x7463656a
    v128.const i32x4 0x6c206465 0x20657669 0x00006469 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 26
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    i32.const -1
    i32.const 1
    call 10
    i32.eqz
    v128.const i32x4 0x6e657261 0x65732061 0x63612074 0x74706563
    v128.const i32x4 0x6d206465 0x69737369 0x6920676e 0x00000064
    array.new_fixed 79 2
    i32.const 0
    i32.const 29
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    call 11
    local.set 3
    local.get 0
    ref.cast (ref 14)
    i32.const 30
    call 7
    local.set 4
    local.get 0
    ref.cast (ref 14)
    i32.const 40
    call 7
    local.set 5
    local.get 0
    ref.cast (ref 14)
    local.get 4
    i32.const 2
    call 12
    local.set 6
    local.get 6
    ref.cast (ref 13)
    local.get 4
    call 4
    if (result i32) ;; label = @1
      local.get 6
      ref.cast (ref 13)
      call 3
      i32.const 4
      i32.eq
    else
      i32.const 0
    end
    v128.const i32x4 0x6e6f7277 0x72612067 0x20616e65 0x6e617073
    array.new_fixed 79 1
    i32.const 0
    i32.const 16
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 6
    ref.cast (ref 13)
    local.get 5
    call 4
    v128.const i32x4 0x6e657261 0x70732061 0x6d206e61 0x65737369
    v128.const i32x4 0x696c2064 0x69206576 0x00000064 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 25
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    local.get 6
    ref.cast (ref 13)
    call 13
    local.set 7
    local.get 7
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x6e6f7277 0x72612067 0x20616e65 0x63696c73
    v128.const i32x4 0x656c2065 0x6874676e 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 24
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 7
    i32.const 0
    local.set 11
    local.set 10
    local.get 11
    local.get 10
    ref.cast (ref 11)
    struct.get 11 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 10
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 11
    array.get 0
    i32.const 30
    i32.eq
    v128.const i32x4 0x6e6f7277 0x72612067 0x20616e65 0x63696c73
    v128.const i32x4 0x61762065 0x0065756c 0x00000000 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 23
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    call 14
    local.set 8
    local.get 8
    ref.cast (ref 14)
    i32.const 7
    i32.const 0
    i32.const 2
    call 15
    local.get 0
    ref.cast (ref 14)
    i32.const 0
    call 9
    i32.const 11
    i32.eq
    v128.const i32x4 0x6e657261 0x6f632061 0x61207970 0x7361696c
    v128.const i32x4 0x73206465 0x6372756f 0x00000065 0x00000000
    array.new_fixed 79 2
    i32.const 0
    i32.const 25
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    local.get 3
    call 16
    local.get 0
    ref.cast (ref 14)
    call 8
    i32.const 2
    i32.eq
    v128.const i32x4 0x6e657261 0x6f722061 0x61626c6c 0x63206b63
    v128.const i32x4 0x676e6168 0x63206465 0x6b636568 0x6e696f70
    v128.const i32x4 0x00000074 0x00000000 0x00000000 0x00000000
    array.new_fixed 79 3
    i32.const 0
    i32.const 33
    struct.new 80
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 14)
    local.get 4
    call 6
    local.set 13
    block ;; label = @1
      local.get 13
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 0
      i32.eq
      if ;; label = @2
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        v128.const i32x4 0x6e657261 0x6f722061 0x61626c6c 0x72206b63
        v128.const i32x4 0x69617465 0x2064656e 0x6f6d6572 0x20646576
        v128.const i32x4 0x00006469 0x00000000 0x00000000 0x00000000
        array.new_fixed 79 3
        i32.const 0
        i32.const 34
        struct.new 80
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
)
