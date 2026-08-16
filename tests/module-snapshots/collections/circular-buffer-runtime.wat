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
  (type (;10;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;11;) (sub (struct (field funcref))))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref i32) (result eqref)))
  (type (;14;) (func (param eqref) (result (ref 10))))
  (type (;15;) (func (param eqref eqref) (result eqref)))
  (type (;16;) (func (param eqref)))
  (type (;17;) (func (param eqref i32)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref i32) (result i32)))
  (type (;20;) (func (param eqref eqref i32) (result eqref)))
  (type (;21;) (func (param eqref eqref) (result (ref 10))))
  (type (;22;) (func (param eqref eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref eqref)))
  (type (;24;) (func (param eqref eqref i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;28;) (func (result (ref 10))))
  (type (;29;) (func (result (ref 10))))
  (type (;30;) (func (param (ref 10)) (result i32)))
  (type (;31;) (func))
  (type (;32;) (array (mut v128)))
  (type (;33;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;35;) (struct (field (ref 32)) (field i32) (field i32)))
  (type (;36;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (type (;37;) (struct (field (mut (ref 32))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 28) (result (ref 10))
    (local eqref i32 eqref)
    i32.const 3
    local.set 1
    local.get 1
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;1;) (type 29) (result (ref 10))
    (local eqref i32 eqref)
    i32.const 2
    local.set 1
    local.get 1
    array.new_default 0
    i32.const 0
    i32.const -2147483648
    struct.new 10
    ref.cast (ref 10)
  )
  (func (;2;) (type 30) (param (ref 10)) (result i32)
    (local i32 eqref i32 eqref i32 eqref i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    i32.eqz
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 8
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      array.get 0
      local.set 5
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.sub
      struct.set 10 1
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      i32.const 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      i32.or
      struct.set 10 2
      i32.const 1
      local.get 5
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 9
    end
    local.set 6
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 6
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1000
          local.set 7
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 9)
        struct.get 9 1
        local.set 1
        local.get 1
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;3;) (type 31)
    (local eqref eqref eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    call 0
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.const 3
    i32.eq
    v128.const i32x4 0x6e756f62 0x20646564 0x61706163 0x79746963
    array.new_fixed 32 1
    i32.const 0
    i32.const 16
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.eqz
    v128.const i32x4 0x6e756f62 0x20646564 0x74706d65 0x00000079
    array.new_fixed 32 1
    i32.const 0
    i32.const 13
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 1
    local.set 5
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 5
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 5
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x65786966 0x6e6f2064 0x00000065 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 9
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 2
    local.set 6
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 6
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 6
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x65786966 0x77742064 0x0000006f 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 9
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 3
    local.set 7
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 7
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 7
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x65786966 0x68742064 0x00656572 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    v128.const i32x4 0x65786966 0x75662064 0x00006c6c 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 8
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 8
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 8
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    i32.eqz
    v128.const i32x4 0x65786966 0x65722064 0x7463656a 0x75662073
    v128.const i32x4 0x00006c6c 0x00000000 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 18
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 2
    i32.const 1
    i32.eq
    v128.const i32x4 0x65786966 0x6f702064 0x6e6f2070 0x00000065
    array.new_fixed 32 1
    i32.const 0
    i32.const 13
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 4
    local.set 9
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 9
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 9
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x65786966 0x72772064 0x00737061 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 2
    i32.const 2
    i32.eq
    v128.const i32x4 0x65786966 0x6f702064 0x77742070 0x0000006f
    array.new_fixed 32 1
    i32.const 0
    i32.const 13
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 2
    i32.const 3
    i32.eq
    v128.const i32x4 0x65786966 0x6f702064 0x68742070 0x00656572
    array.new_fixed 32 1
    i32.const 0
    i32.const 15
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 2
    i32.const 4
    i32.eq
    v128.const i32x4 0x65786966 0x6f702064 0x6f662070 0x00007275
    array.new_fixed 32 1
    i32.const 0
    i32.const 14
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 1
    local.set 0
    local.get 0
    i32.const 10
    local.set 10
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 10
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 10
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x776f7267 0x656e6f20 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 8
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 20
    local.set 11
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 11
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 11
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x776f7267 0x6f777420 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 8
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 10)
    call 2
    i32.const 10
    i32.eq
    v128.const i32x4 0x776f7267 0x706f7020 0x00000000 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 8
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 30
    local.set 12
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 12
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 12
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x776f7267 0x61727720 0x00007370 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 40
    local.set 13
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        local.set 4
        local.get 4
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 4
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 3
        local.get 2
        ref.cast (ref 10)
        local.get 3
        array.new_default 0
        struct.set 10 0
        i32.const 0
        local.set 3
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            local.get 2
            ref.cast (ref 10)
            struct.get 10 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 0
            ref.cast (ref 0)
            local.get 3
            local.get 4
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 10)
            struct.get 10 2
            i32.const 2147483647
            i32.and
            local.get 3
            i32.add
            local.get 4
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 3
            i32.const 1
            i32.add
            local.set 3
            br 0 (;@4;)
          end
        end
        local.get 2
        ref.cast (ref 10)
        i32.const -2147483648
        struct.set 10 2
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 2
        i32.const 2147483647
        i32.and
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.add
        local.get 2
        ref.cast (ref 10)
        struct.get 10 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 13
        array.set 0
        local.get 2
        ref.cast (ref 10)
        local.get 2
        ref.cast (ref 10)
        struct.get 10 1
        i32.const 1
        i32.add
        struct.set 10 1
        i32.const 1
      end
    else
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.add
      local.get 2
      ref.cast (ref 10)
      struct.get 10 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 13
      array.set 0
      local.get 2
      ref.cast (ref 10)
      local.get 2
      ref.cast (ref 10)
      struct.get 10 1
      i32.const 1
      i32.add
      struct.set 10 1
      i32.const 1
    end
    v128.const i32x4 0x776f7267 0x61657220 0x636f6c6c 0x73657461
    array.new_fixed 32 1
    i32.const 0
    i32.const 16
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.const 4
    i32.eq
    v128.const i32x4 0x776f7267 0x64206874 0x6c62756f 0x00007365
    array.new_fixed 32 1
    i32.const 0
    i32.const 14
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    i32.const 0
    struct.new 10
    local.set 1
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.set 3
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 2
    i32.const 2147483647
    i32.and
    local.get 3
    i32.add
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    local.get 2
    ref.cast (ref 10)
    local.get 3
    i32.const 1
    i32.add
    struct.set 10 1
    i32.const 20
    i32.eq
    v128.const i32x4 0x72657469 0x72696620 0x00007473 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.set 3
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 2
    i32.const 2147483647
    i32.and
    local.get 3
    i32.add
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    local.get 2
    ref.cast (ref 10)
    local.get 3
    i32.const 1
    i32.add
    struct.set 10 1
    i32.const 30
    i32.eq
    v128.const i32x4 0x72657469 0x63657320 0x00646e6f 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.set 3
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 2
    i32.const 2147483647
    i32.and
    local.get 3
    i32.add
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    local.get 2
    ref.cast (ref 10)
    local.get 3
    i32.const 1
    i32.add
    struct.set 10 1
    i32.const 40
    i32.eq
    v128.const i32x4 0x72657469 0x69687420 0x00006472 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 10
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 1
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.lt_u
    i32.eqz
    v128.const i32x4 0x72657469 0x68786520 0x74737561 0x00006465
    array.new_fixed 32 1
    i32.const 0
    i32.const 14
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    i32.const 0
    struct.set 10 1
    local.get 2
    ref.cast (ref 10)
    local.get 2
    ref.cast (ref 10)
    struct.get 10 2
    i32.const -2147483648
    i32.and
    struct.set 10 2
    local.get 0
    ref.cast (ref 10)
    struct.get 10 1
    i32.eqz
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 32 1
    i32.const 0
    i32.const 11
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 10)
    struct.get 10 0
    ref.cast (ref 0)
    array.len
    i32.const 4
    i32.eq
    v128.const i32x4 0x61656c63 0x72702072 0x72657365 0x20736576
    v128.const i32x4 0x61706163 0x79746963 0x00000000 0x00000000
    array.new_fixed 32 2
    i32.const 0
    i32.const 24
    struct.new 33
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
