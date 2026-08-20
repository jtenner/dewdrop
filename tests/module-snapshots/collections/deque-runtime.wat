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
  (type (;31;) (func (param (ref 11)) (result i32)))
  (type (;32;) (func (param (ref 11)) (result i32)))
  (type (;33;) (func))
  (type (;34;) (array (mut v128)))
  (type (;35;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;36;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;37;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;38;) (struct (field (mut (ref 34))) (field (mut i32)) (field (mut i32))))
  (type (;39;) (struct (field (mut (ref 34))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 3))
  (func (;0;) (type 30) (result (ref 11))
    (local eqref i32 eqref)
    i32.const 2
    local.set 1
    local.get 1
    array.new_default 0
    i32.const 0
    i32.const -2147483648
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;1;) (type 31) (param (ref 11)) (result i32)
    (local i32 eqref i32 eqref i32 eqref i32 i32 i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 8
    else
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      array.get 0
      local.set 5
      local.get 2
      ref.cast (ref 11)
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      struct.set 11 1
      local.get 2
      ref.cast (ref 11)
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      i32.const 1
      i32.add
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      i32.or
      struct.set 11 2
      i32.const 1
      local.set 8
      local.get 5
      local.set 9
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1
          local.set 7
          br 2 (;@1;)
        end
        local.get 9
        local.set 1
        local.get 1
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;2;) (type 32) (param (ref 11)) (result i32)
    (local i32 eqref i32 eqref i32 eqref i32 i32 i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 8
    else
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 2
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      i32.const 1
      i32.sub
      local.get 2
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      array.get 0
      local.set 5
      local.get 2
      ref.cast (ref 11)
      local.get 2
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.sub
      struct.set 11 1
      i32.const 1
      local.set 8
      local.get 5
      local.set 9
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const -1
          local.set 7
          br 2 (;@1;)
        end
        local.get 9
        local.set 1
        local.get 1
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
  )
  (func (;3;) (type 33)
    (local eqref i32 i32 eqref eqref i32 eqref i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    call 0
    local.set 0
    v128.const i32x4 0x2077656e 0x75716564 0x6d652065 0x00797470
    array.new_fixed 34 1
    i32.const 0
    i32.const 15
    struct.new 35
    drop
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x74706d65 0x72662079 0x00746e6f 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 11
    struct.new 35
    drop
    local.get 0
    ref.cast (ref 11)
    call 1
    i32.const -1
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x74706d65 0x61622079 0x00006b63 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 10
    struct.new 35
    drop
    local.get 0
    ref.cast (ref 11)
    call 2
    i32.const -1
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 7
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.add
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 7
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 7
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    i32.const 1
    local.set 8
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const -2147483648
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.add
        i32.const 1
        i32.sub
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        i32.or
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 8
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.add
      i32.const 1
      i32.sub
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      i32.or
      struct.set 11 2
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 8
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    i32.const 3
    local.set 9
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.add
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 9
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 9
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    i32.const 0
    local.set 10
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const -2147483648
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.add
        i32.const 1
        i32.sub
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        i32.or
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 10
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.add
      i32.const 1
      i32.sub
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      i32.or
      struct.set 11 2
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 10
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    local.get 0
    local.set 4
    v128.const i32x4 0x776f7267 0x64206874 0x6c62756f 0x00007365
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.const 4
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 21
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      array.get 0
      local.set 11
      i32.const 1
      local.set 21
      local.get 11
      local.set 22
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 21
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x7373696d 0x20676e69 0x6e6f7266 0x00000074
          array.new_fixed 34 1
          i32.const 0
          i32.const 13
          struct.new 35
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 22
        local.set 1
        local.get 1
        i32.const 0
        i32.eq
        v128.const i32x4 0x6b656570 0x6f726620 0x0000746e 0x00000000
        array.new_fixed 34 1
        i32.const 0
        i32.const 10
        struct.new 35
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
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    if ;; label = @1
      i32.const 0
      local.set 23
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      i32.const 1
      i32.sub
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      array.get 0
      local.set 13
      i32.const 1
      local.set 23
      local.get 13
      local.set 24
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 23
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x7373696d 0x20676e69 0x6b636162 0x00000000
          array.new_fixed 34 1
          i32.const 0
          i32.const 12
          struct.new 35
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 24
        local.set 2
        local.get 2
        i32.const 3
        i32.eq
        v128.const i32x4 0x6b656570 0x63616220 0x0000006b 0x00000000
        array.new_fixed 34 1
        i32.const 0
        i32.const 9
        struct.new 35
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
    i32.const 0
    struct.new 12
    local.set 3
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.set 5
    local.get 4
    ref.cast (ref 12)
    local.get 5
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 2147483647
    i32.and
    local.get 5
    i32.add
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    i32.const 0
    i32.eq
    v128.const i32x4 0x72657469 0x72657a20 0x0000006f 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 9
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.set 5
    local.get 4
    ref.cast (ref 12)
    local.get 5
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 2147483647
    i32.and
    local.get 5
    i32.add
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    i32.const 1
    i32.eq
    v128.const i32x4 0x72657469 0x656e6f20 0x00000000 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 8
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.set 5
    local.get 4
    ref.cast (ref 12)
    local.get 5
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 2147483647
    i32.and
    local.get 5
    i32.add
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    i32.const 2
    i32.eq
    v128.const i32x4 0x72657469 0x6f777420 0x00000000 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 8
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    if ;; label = @1
    else
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.set 5
    local.get 4
    ref.cast (ref 12)
    local.get 5
    i32.const 1
    i32.add
    struct.set 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 2
    i32.const 2147483647
    i32.and
    local.get 5
    i32.add
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.rem_u
    array.get 0
    i32.const 3
    i32.eq
    v128.const i32x4 0x72657469 0x72687420 0x00006565 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 10
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 12)
    struct.get 12 1
    local.get 4
    ref.cast (ref 12)
    struct.get 12 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.lt_u
    i32.eqz
    v128.const i32x4 0x72657469 0x68786520 0x74737561 0x00006465
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x20706f70 0x6e6f7266 0x657a2074 0x00006f72
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 2
    i32.const 3
    i32.eq
    v128.const i32x4 0x20706f70 0x6b636162 0x72687420 0x00006565
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 9
    local.set 19
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const -2147483648
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.add
        i32.const 1
        i32.sub
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        i32.or
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 19
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.add
      i32.const 1
      i32.sub
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      i32.or
      struct.set 11 2
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 19
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    i32.const 8
    local.set 20
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 1
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.eq
    if (result i32) ;; label = @1
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const -2147483648
      i32.and
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 0
      else
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        local.set 6
        local.get 6
        ref.cast (ref 0)
        array.len
        i32.eqz
        if (result i32) ;; label = @3
          i32.const 4
        else
          local.get 6
          ref.cast (ref 0)
          array.len
          i32.const 2
          i32.mul
        end
        local.set 5
        local.get 4
        ref.cast (ref 11)
        local.get 5
        array.new_default 0
        struct.set 11 0
        i32.const 0
        local.set 5
        block ;; label = @3
          loop ;; label = @4
            local.get 5
            local.get 4
            ref.cast (ref 11)
            struct.get 11 1
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            ref.cast (ref 0)
            local.get 5
            local.get 6
            ref.cast (ref 0)
            local.get 4
            ref.cast (ref 11)
            struct.get 11 2
            i32.const 2147483647
            i32.and
            local.get 5
            i32.add
            local.get 6
            ref.cast (ref 0)
            array.len
            i32.rem_u
            array.get 0
            array.set 0
            local.get 5
            i32.const 1
            i32.add
            local.set 5
            br 0 (;@4;)
          end
        end
        local.get 4
        ref.cast (ref 11)
        i32.const -2147483648
        struct.set 11 2
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 2
        i32.const 2147483647
        i32.and
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.add
        local.get 4
        ref.cast (ref 11)
        struct.get 11 0
        ref.cast (ref 0)
        array.len
        i32.rem_u
        local.get 20
        array.set 0
        local.get 4
        ref.cast (ref 11)
        local.get 4
        ref.cast (ref 11)
        struct.get 11 1
        i32.const 1
        i32.add
        struct.set 11 1
        i32.const 1
      end
    else
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 2
      i32.const 2147483647
      i32.and
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.add
      local.get 4
      ref.cast (ref 11)
      struct.get 11 0
      ref.cast (ref 0)
      array.len
      i32.rem_u
      local.get 20
      array.set 0
      local.get 4
      ref.cast (ref 11)
      local.get 4
      ref.cast (ref 11)
      struct.get 11 1
      i32.const 1
      i32.add
      struct.set 11 1
      i32.const 1
    end
    drop
    local.get 0
    ref.cast (ref 11)
    call 1
    i32.const 9
    i32.eq
    v128.const i32x4 0x70617277 0x20646570 0x6e6f7266 0x00000074
    array.new_fixed 34 1
    i32.const 0
    i32.const 13
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 2
    i32.const 8
    i32.eq
    v128.const i32x4 0x70617277 0x20646570 0x6b636162 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 12
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x616d6572 0x6e696e69 0x72662067 0x00746e6f
    array.new_fixed 34 1
    i32.const 0
    i32.const 15
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 11)
    call 2
    i32.const 2
    i32.eq
    v128.const i32x4 0x616d6572 0x6e696e69 0x61622067 0x00006b63
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    i32.const 0
    struct.set 11 1
    local.get 4
    ref.cast (ref 11)
    local.get 4
    ref.cast (ref 11)
    struct.get 11 2
    i32.const -2147483648
    i32.and
    struct.set 11 2
    local.get 0
    ref.cast (ref 11)
    struct.get 11 1
    i32.eqz
    v128.const i32x4 0x61656c63 0x6d652072 0x00797470 0x00000000
    array.new_fixed 34 1
    i32.const 0
    i32.const 11
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 11)
    struct.get 11 0
    ref.cast (ref 0)
    array.len
    i32.const 4
    i32.eq
    v128.const i32x4 0x61656c63 0x61632072 0x69636170 0x00007974
    array.new_fixed 34 1
    i32.const 0
    i32.const 14
    struct.new 35
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
