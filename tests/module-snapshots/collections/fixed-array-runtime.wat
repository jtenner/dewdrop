(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (struct (field eqref)))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (array (mut i32)))
  (type (;11;) (array (mut i64)))
  (type (;12;) (array (mut f32)))
  (type (;13;) (array (mut f64)))
  (type (;14;) (array (mut v128)))
  (type (;15;) (array (mut eqref)))
  (export "main" (func 0))
  (func (;0;) (type 3)
    (local eqref eqref i32 eqref eqref eqref eqref eqref eqref i32 eqref eqref eqref)
    i32.const 3
    local.set 9
    i32.const 7
    local.get 9
    array.new 10
    struct.new 2
    local.set 0
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    array.len
    i32.const 3
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x676e656c
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 18
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 0
    array.get 10
    i32.const 7
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x73726966
    v128.const i32x4 0x6e692074 0x61697469 0x6176206c 0x0065756c
    array.new_fixed 4 2
    i32.const 0
    i32.const 31
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 2
    array.get 10
    i32.const 7
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x616e6966
    v128.const i32x4 0x6e69206c 0x61697469 0x6176206c 0x0065756c
    array.new_fixed 4 2
    i32.const 0
    i32.const 31
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 1
    i32.const 9
    array.set 10
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 1
    array.get 10
    i32.const 9
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65646e69
    v128.const i32x4 0x20646578 0x00746573 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 23
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 0
    i32.const 11
    array.set 10
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 0
    array.get 10
    i32.const 11
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x6874656d
    v128.const i32x4 0x7320646f 0x00007465 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 22
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 2
    i32.const 13
    array.set 10
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 2
    array.get 10
    i32.const 13
    i32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x61696c61
    v128.const i32x4 0x20736573 0x72616873 0x756d2065 0x69746174
    v128.const i32x4 0x00006e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 3
    i32.const 0
    i32.const 34
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 8
    i32.const 1
    local.set 9
    local.get 9
    local.get 8
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 8
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 10)
      local.get 9
      array.get 10
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65666173
          v128.const i32x4 0x74656720 0x656e7520 0x63657078 0x6c646574
          v128.const i32x4 0x6d652079 0x00797470 0x00000000 0x00000000
          array.new_fixed 4 3
          i32.const 0
          i32.const 39
          struct.new 5
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 10
        ref.cast (ref 1)
        struct.get 1 1
        local.set 2
        local.get 2
        i32.const 9
        i32.eq
        v128.const i32x4 0x65786966 0x72612064 0x20796172 0x65666173
        v128.const i32x4 0x74656720 0x6c617620 0x00006575 0x00000000
        array.new_fixed 4 2
        i32.const 0
        i32.const 26
        struct.new 5
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
    local.set 8
    i32.const 3
    local.set 9
    local.get 9
    local.get 8
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 8
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 10)
      local.get 9
      array.get 10
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    local.set 11
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 11
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x65786966 0x72612064 0x20796172 0x2074756f
        v128.const i32x4 0x6220666f 0x646e756f 0x6e752073 0x65707865
        v128.const i32x4 0x64657463 0x7020796c 0x65736572 0x0000746e
        array.new_fixed 4 3
        i32.const 0
        i32.const 46
        struct.new 5
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
    local.set 9
    i32.const 0
    local.get 9
    array.new 10
    struct.new 2
    local.set 3
    local.get 3
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    array.len
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x69662079 0x20646578 0x61727261
    v128.const i32x4 0x656c2079 0x6874676e 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 24
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 8
    i32.const 0
    local.set 9
    local.get 9
    local.get 8
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    array.len
    i32.lt_u
    if (result eqref) ;; label = @1
      i32.const 1
      local.get 8
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 10)
      local.get 9
      array.get 10
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 1
    else
      i32.const 0
      struct.new 0
    end
    local.set 12
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 12
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x74706d65 0x69662079 0x20646578 0x61727261
        v128.const i32x4 0x6e752079 0x65707865 0x64657463 0x7020796c
        v128.const i32x4 0x65736572 0x0000746e 0x00000000 0x00000000
        array.new_fixed 4 3
        i32.const 0
        i32.const 38
        struct.new 5
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
    local.set 9
    i64.const 1
    local.get 9
    array.new 11
    struct.new 2
    local.set 4
    local.get 4
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 11)
    i32.const 1
    i64.const 9223372036854775807
    array.set 11
    local.get 4
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 11)
    i32.const 1
    array.get 11
    i64.const 9223372036854775807
    i64.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20343669
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 23
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 9
    f32.const 0x1.8p+0 (;=1.5;)
    local.get 9
    array.new 12
    struct.new 2
    local.set 5
    local.get 5
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 12)
    i32.const 1
    f32.const 0x1.4p+1 (;=2.5;)
    array.set 12
    local.get 5
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 12)
    i32.const 1
    array.get 12
    f32.const 0x1.4p+1 (;=2.5;)
    f32.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20323366
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 23
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 9
    f64.const 0x1.8p+0 (;=1.5;)
    local.get 9
    array.new 13
    struct.new 2
    local.set 6
    local.get 6
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 13)
    i32.const 1
    f64.const 0x1.4p+1 (;=2.5;)
    array.set 13
    local.get 6
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 13)
    i32.const 1
    array.get 13
    f64.const 0x1.4p+1 (;=2.5;)
    f64.eq
    v128.const i32x4 0x65786966 0x72612064 0x20796172 0x20343666
    v128.const i32x4 0x72726163 0x00726569 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 23
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 9
    v128.const i32x4 0x74696e69 0x006c6169 0x00000000 0x00000000
    array.new_fixed 4 1
    i32.const 0
    i32.const 7
    struct.new 5
    local.get 9
    array.new 15
    struct.new 2
    local.set 7
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 15)
    i32.const 1
    v128.const i32x4 0x6e616863 0x00646567 0x00000000 0x00000000
    array.new_fixed 4 1
    i32.const 0
    i32.const 7
    struct.new 5
    array.set 15
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 15)
    i32.const 0
    array.get 15
    drop
    local.get 7
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    drop
    local.get 0
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 10)
    i32.const 0
    i32.const 11
    array.set 10
  )
)
