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
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;10;) (func))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 0))
  (func (;0;) (type 10)
    (local eqref i32 eqref eqref eqref eqref eqref eqref i32 eqref eqref eqref)
    i32.const 3
    local.set 8
    i32.const 7
    local.get 8
    array.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    array.len
    i32.const 3
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 18
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x73726966
    v128.const i32x4 0x6e692074 0x61697469 0x6176206c 0x0065756c
    array.new_fixed 11 2
    i32.const 0
    i32.const 31
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    array.get 0
    i32.const 7
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x616e6966
    v128.const i32x4 0x6e69206c 0x61697469 0x6176206c 0x0065756c
    array.new_fixed 11 2
    i32.const 0
    i32.const 31
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const 9
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    array.get 0
    i32.const 9
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65646e69
    v128.const i32x4 0x20646578 0x00746573 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 23
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 11
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 11
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x6874656d
    v128.const i32x4 0x7320646f 0x00007465 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 22
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 13
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    array.get 0
    i32.const 13
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x61696c61
    v128.const i32x4 0x20736573 0x72616873 0x756d2065 0x69746174
    v128.const i32x4 0x00006e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 3
    i32.const 0
    i32.const 34
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 7
    i32.const 1
    local.set 8
    local.get 8
    local.get 7
    ref.cast (ref 0)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 7
      ref.cast (ref 0)
      local.get 8
      array.get 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    local.set 9
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 9
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65666173
          v128.const i32x4 0x74656720 0x656e7520 0x63657078 0x6c646574
          v128.const i32x4 0x6d652079 0x00797470 0x00000000 0x00000000
          array.new_fixed 11 3
          i32.const 0
          i32.const 39
          struct.new 12
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 9
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        i32.const 9
        i32.eq
        v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65666173
        v128.const i32x4 0x74656720 0x6c617620 0x00006575 0x00000000
        array.new_fixed 11 2
        i32.const 0
        i32.const 26
        struct.new 12
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
    local.set 7
    i32.const 3
    local.set 8
    local.get 8
    local.get 7
    ref.cast (ref 0)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 7
      ref.cast (ref 0)
      local.get 8
      array.get 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x65786966 0x72612064 0x20796172 0x2074756f
        v128.const i32x4 0x6220666f 0x646e756f 0x6e752073 0x65707865
        v128.const i32x4 0x64657463 0x7020796c 0x65736572 0x0000746e
        array.new_fixed 11 3
        i32.const 0
        i32.const 46
        struct.new 12
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
    local.set 8
    i32.const 0
    local.get 8
    array.new 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    array.len
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x69662079 0x20646578 0x61727261
    v128.const i32x4 0x656c2079 0x6874676e 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 24
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.set 7
    i32.const 0
    local.set 8
    local.get 8
    local.get 7
    ref.cast (ref 0)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 7
      ref.cast (ref 0)
      local.get 8
      array.get 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    else
      i32.const 0
      struct.new 8
    end
    local.set 11
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 11
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x69662079 0x20646578 0x61727261
        v128.const i32x4 0x6e752079 0x65707865 0x64657463 0x7020796c
        v128.const i32x4 0x65736572 0x0000746e 0x00000000 0x00000000
        array.new_fixed 11 3
        i32.const 0
        i32.const 38
        struct.new 12
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 2
    local.set 8
    i64.const 1
    local.get 8
    array.new 1
    local.set 3
    local.get 3
    ref.cast (ref 1)
    i32.const 1
    i64.const 9223372036854775807
    array.set 1
    local.get 3
    ref.cast (ref 1)
    i32.const 1
    array.get 1
    i64.const 9223372036854775807
    i64.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20343669
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 23
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 8
    f32.const 0x1.8p+0 (;=1.5;)
    local.get 8
    array.new 2
    local.set 4
    local.get 4
    ref.cast (ref 2)
    i32.const 1
    f32.const 0x1.4p+1 (;=2.5;)
    array.set 2
    local.get 4
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    f32.const 0x1.4p+1 (;=2.5;)
    f32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20323366
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 23
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 8
    f64.const 0x1.8p+0 (;=1.5;)
    local.get 8
    array.new 3
    local.set 5
    local.get 5
    ref.cast (ref 3)
    i32.const 1
    f64.const 0x1.4p+1 (;=2.5;)
    array.set 3
    local.get 5
    ref.cast (ref 3)
    i32.const 1
    array.get 3
    f64.const 0x1.4p+1 (;=2.5;)
    f64.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20343666
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 11 2
    i32.const 0
    i32.const 23
    struct.new 12
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 8
    v128.const i32x4 0x74696e69 0x006c6169 0x00000000 0x00000000
    array.new_fixed 11 1
    i32.const 0
    i32.const 7
    struct.new 12
    local.get 8
    array.new 5
    local.set 6
    local.get 6
    ref.cast (ref 5)
    i32.const 1
    v128.const i32x4 0x6e616863 0x00646567 0x00000000 0x00000000
    array.new_fixed 11 1
    i32.const 0
    i32.const 7
    struct.new 12
    array.set 5
    local.get 6
    ref.cast (ref 5)
    i32.const 0
    array.get 5
    drop
    local.get 6
    ref.cast (ref 5)
    i32.const 1
    array.get 5
    drop
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 11
    array.set 0
  )
)
