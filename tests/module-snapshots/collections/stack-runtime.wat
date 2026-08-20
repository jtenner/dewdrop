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
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (result (ref 11))))
  (type (;31;) (func))
  (type (;32;) (array (mut v128)))
  (type (;33;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;36;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (type (;37;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 30) (result (ref 11))
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;1;) (type 31)
    (local eqref eqref i32 eqref i32 i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32)
    call 0
    local.set 0
    local.get 0
    local.set 1
    v128.const i32x4 0x2077656e 0x63617473 0x7369206b 0x706d6520
    v128.const i32x4 0x00007974 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 18
    struct.new 33
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 25
    else
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 10
      array.get 0
      local.set 12
      local.get 9
      ref.cast (ref 11)
      local.get 10
      struct.set 11 1
      i32.const 1
      local.set 25
      local.get 12
      drop
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 25
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x6f702079 0x00000070 0x00000000
        array.new_fixed 32 1
        i32.const 0
        i32.const 9
        struct.new 33
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
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 26
    else
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 10
      array.get 0
      local.set 14
      i32.const 1
      local.set 26
      local.get 14
      drop
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 26
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x65702079 0x00006b65 0x00000000
        array.new_fixed 32 1
        i32.const 0
        i32.const 10
        struct.new 33
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 11
    local.set 16
    local.get 0
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 9
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 9
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 10
      local.get 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 10
      array.new_default 0
      local.set 11
      local.get 11
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      struct.set 11 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 9
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 16
    array.set 0
    local.get 9
    ref.cast (ref 11)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 22
    local.set 17
    local.get 1
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 9
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 9
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 10
      local.get 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 10
      array.new_default 0
      local.set 11
      local.get 11
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      struct.set 11 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 9
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 17
    array.set 0
    local.get 9
    ref.cast (ref 11)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    i32.const 33
    local.set 18
    local.get 0
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 9
    ref.cast (ref 11)
    struct.get 11 2
    i32.eq
    if ;; label = @1
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 9
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2
        i32.mul
      end
      local.set 10
      local.get 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 10
      array.new_default 0
      local.set 11
      local.get 11
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      i32.const 0
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      array.copy 0 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      struct.set 11 0
      local.get 9
      ref.cast (ref 11)
      local.get 11
      ref.cast (ref 0)
      array.len
      struct.set 11 2
    end
    local.get 9
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    local.get 18
    array.set 0
    local.get 9
    ref.cast (ref 11)
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 1
    i32.add
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x61696c61 0x69762d73 0x6c626973 0x75702065
    v128.const i32x4 0x73656873 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 20
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 27
    else
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 10
      array.get 0
      local.set 19
      i32.const 1
      local.set 27
      local.get 19
      local.set 28
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 27
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x6b656570 0x656e7520 0x63657078 0x6c646574
          v128.const i32x4 0x6d652079 0x00797470 0x00000000 0x00000000
          array.new_fixed 32 2
          i32.const 0
          i32.const 23
          struct.new 33
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 28
        local.set 2
        local.get 2
        i32.const 33
        i32.eq
        v128.const i32x4 0x6b656570 0x61657220 0x74207364 0x0000706f
        array.new_fixed 32 1
        i32.const 0
        i32.const 14
        struct.new 33
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
    ref.cast (ref 11)
    struct.get 11 1
    i32.const 3
    i32.eq
    v128.const i32x4 0x6b656570 0x65727020 0x76726573 0x6c207365
    v128.const i32x4 0x74676e65 0x00000068 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 21
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    struct.new 12
    local.set 3
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    v128.const i32x4 0x72657469 0x726f7461 0x72696620 0x69207473
    v128.const i32x4 0x006d6574 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 19
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.set 10
    local.get 9
    ref.cast (ref 12)
    local.get 10
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    array.get 0
    local.set 4
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    v128.const i32x4 0x72657469 0x726f7461 0x63657320 0x20646e6f
    v128.const i32x4 0x6d657469 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 20
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.set 10
    local.get 9
    ref.cast (ref 12)
    local.get 10
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    array.get 0
    local.set 5
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    v128.const i32x4 0x72657469 0x726f7461 0x69687420 0x69206472
    v128.const i32x4 0x006d6574 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 19
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.set 10
    local.get 9
    ref.cast (ref 12)
    local.get 10
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 10
    array.get 0
    local.set 6
    local.get 3
    local.set 9
    local.get 9
    ref.cast (ref 12)
    struct.get 12 1
    local.get 9
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    i32.eqz
    v128.const i32x4 0x72657469 0x726f7461 0x68786520 0x74737561
    v128.const i32x4 0x00006465 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 18
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 4
    local.get 5
    i32.add
    local.get 6
    i32.add
    i32.const 66
    i32.eq
    v128.const i32x4 0x72657469 0x726f7461 0x73697620 0x20737469
    v128.const i32x4 0x65736e69 0x6f697472 0x726f206e 0x00726564
    array.new_fixed 32 2
    i32.const 0
    i32.const 31
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 29
    else
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 10
      array.get 0
      local.set 21
      local.get 9
      ref.cast (ref 11)
      local.get 10
      struct.set 11 1
      i32.const 1
      local.set 29
      local.get 21
      local.set 30
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 29
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x73726966 0x6f702074 0x6e752070 0x65707865
          v128.const i32x4 0x64657463 0x6520796c 0x7974706d 0x00000000
          array.new_fixed 32 2
          i32.const 0
          i32.const 28
          struct.new 33
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 30
        local.set 7
        local.get 7
        i32.const 33
        i32.eq
        v128.const i32x4 0x73726966 0x6f702074 0x73692070 0x46494c20
        v128.const i32x4 0x0000004f 0x00000000 0x00000000 0x00000000
        array.new_fixed 32 2
        i32.const 0
        i32.const 17
        struct.new 33
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
    local.set 9
    local.get 9
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 31
    else
      local.get 9
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      local.set 10
      local.get 9
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 10
      array.get 0
      local.set 23
      local.get 9
      ref.cast (ref 11)
      local.get 10
      struct.set 11 1
      i32.const 1
      local.set 31
      local.get 23
      local.set 32
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 31
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x6f636573 0x7020646e 0x7520706f 0x7078656e
          v128.const i32x4 0x65746365 0x20796c64 0x74706d65 0x00000079
          array.new_fixed 32 2
          i32.const 0
          i32.const 29
          struct.new 33
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 32
        local.set 8
        local.get 8
        i32.const 22
        i32.eq
        v128.const i32x4 0x6f636573 0x7020646e 0x6920706f 0x494c2073
        v128.const i32x4 0x00004f46 0x00000000 0x00000000 0x00000000
        array.new_fixed 32 2
        i32.const 0
        i32.const 18
        struct.new 33
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
    local.set 9
    local.get 9
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    v128.const i32x4 0x61656c63 0x6d652072 0x65697470 0x74732073
    v128.const i32x4 0x006b6361 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 19
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
