(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct))
  (type (;5;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;6;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;8;) (func (result (ref 3))))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (array (mut eqref)))
  (type (;17;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 1))
  (func (;0;) (type 8) (result (ref 3))
    i32.const 16
    array.new_default 16
    i32.const 0
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;1;) (type 9)
    (local eqref eqref i32 eqref eqref eqref eqref i64 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 eqref i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 f64 i64 f64 i64 f64 i32 f32 i32 f32 i32 i32 i32 f32)
    call 0
    local.set 0
    local.get 0
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x616d2079 0x656c2070 0x6874676e
    array.new_fixed 10 1
    i32.const 0
    i32.const 16
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 9
    local.get 9
    i64.extend_i32_s
    local.set 7
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 9
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x74706d65 0x616d2079 0x696d2070 0x6e697373
    v128.const i32x4 0x656b2067 0x00000079 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 21
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 11
    local.get 11
    i64.extend_i32_s
    local.set 7
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    ref.null eq
    local.set 10
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 11
          i32.eq
          if ;; label = @4
            local.get 10
            ref.is_null
            if ;; label = @5
              local.get 6
              ref.cast (ref 16)
              local.get 7
              i32.wrap_i64
              local.get 6
              ref.cast (ref 16)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              array.set 16
            else
              local.get 10
              ref.cast (ref 17)
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              struct.set 17 0
            end
            local.get 5
            ref.cast (ref 3)
            local.get 5
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.sub
            struct.set 3 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        local.set 10
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x74706d65 0x616d2079 0x65722070 0x65766f6d
    v128.const i32x4 0x70657220 0x7374726f 0x73696d20 0x676e6973
    array.new_fixed 10 2
    i32.const 0
    i32.const 32
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 13
    i32.const 2
    local.set 14
    local.get 13
    i64.extend_i32_s
    local.set 7
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 13
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 14
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 13
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 14
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 1
    local.set 15
    local.get 15
    i64.extend_i32_s
    local.set 7
    local.get 0
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 15
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 2
    i32.eq
    v128.const i32x4 0x74706d65 0x616d2079 0x63612070 0x74706563
    v128.const i32x4 0x69662073 0x20747372 0x65736e69 0x6f697472
    v128.const i32x4 0x0000006e 0x00000000 0x00000000 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 33
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 17
    i32.const 10
    local.set 18
    local.get 17
    i64.extend_i32_s
    local.set 7
    i32.const 16
    array.new_default 16
    local.set 6
    ref.null eq
    local.get 7
    local.get 17
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 18
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 17
    local.set 8
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 8
    array.set 16
    local.get 6
    i32.const 1
    struct.new 3
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x676e6973 0x6f74656c 0x616d206e 0x656c2070
    v128.const i32x4 0x6874676e 0x00000000 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 20
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 19
    local.get 19
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 19
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x676e6973 0x6f74656c 0x656b206e 0x72702079
    v128.const i32x4 0x6e657365 0x00000074 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 21
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 20
    local.get 20
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 20
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x7373696d 0x20676e69 0x6c6c6f63 0x6e696469
    v128.const i32x4 0x656b2067 0x62612079 0x746e6573 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 28
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 21
    i32.const 20
    local.set 22
    local.get 21
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 21
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 22
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 21
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 22
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x6c6c6f63 0x6f697369 0x6e69206e 0x74726573
    v128.const i32x4 0x206e6f69 0x72636e69 0x6e656d65 0x6c207374
    v128.const i32x4 0x74676e65 0x00000068 0x00000000 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 37
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 23
    local.get 23
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 23
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 10
    i32.eq
    v128.const i32x4 0x73726966 0x6f632074 0x64696c6c 0x20676e69
    v128.const i32x4 0x2079656b 0x61746572 0x64656e69 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 28
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 25
    local.get 25
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 25
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 20
    i32.eq
    v128.const i32x4 0x6f636573 0x6320646e 0x696c6c6f 0x676e6964
    v128.const i32x4 0x79656b20 0x736e6920 0x65747265 0x00000064
    array.new_fixed 10 2
    i32.const 0
    i32.const 29
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 63
    i32.const 30
    local.set 64
    local.get 63
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 63
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 64
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 63
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 64
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 2
    i32.eq
    v128.const i32x4 0x6c706572 0x6d656361 0x20746e65 0x7065656b
    v128.const i32x4 0x656c2073 0x6874676e 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 24
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 27
    local.get 27
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 27
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 30
    i32.eq
    v128.const i32x4 0x61696c61 0x20646573 0x65646e69 0x20646578
    v128.const i32x4 0x6c706572 0x6d656361 0x20746e65 0x69736976
    v128.const i32x4 0x00656c62 0x00000000 0x00000000 0x00000000
    array.new_fixed 10 3
    i32.const 0
    i32.const 35
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 29
    local.get 29
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result eqref) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          struct.new 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 29
          i32.eq
          if ;; label = @4
            i32.const 1
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            struct.new 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    local.set 31
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 31
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 0
          v128.const i32x4 0x65666173 0x70616d20 0x74656720 0x656e7520
          v128.const i32x4 0x63657078 0x6c646574 0x696d2079 0x6e697373
          v128.const i32x4 0x00000067 0x00000000 0x00000000 0x00000000
          array.new_fixed 10 3
          i32.const 0
          i32.const 33
          struct.new 11
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        local.get 31
        ref.cast (ref 1)
        struct.get 1 1
        local.set 2
        local.get 2
        i32.const 30
        i32.eq
        v128.const i32x4 0x65666173 0x70616d20 0x74656720 0x74657220
        v128.const i32x4 0x736e7275 0x6c617620 0x00006575 0x00000000
        array.new_fixed 10 2
        i32.const 0
        i32.const 26
        struct.new 11
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 99
    local.set 32
    local.get 32
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result eqref) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          struct.new 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 32
          i32.eq
          if ;; label = @4
            i32.const 1
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            struct.new 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    local.set 34
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 34
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 1
          v128.const i32x4 0x65666173 0x70616d20 0x74656720 0x74657220
          v128.const i32x4 0x736e7275 0x6e6f6e20 0x00000065 0x00000000
          array.new_fixed 10 2
          i32.const 0
          i32.const 25
          struct.new 11
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x65666173 0x70616d20 0x74656720 0x656e7520
        v128.const i32x4 0x63657078 0x6c646574 0x6f662079 0x20646e75
        v128.const i32x4 0x7373696d 0x20676e69 0x0079656b 0x00000000
        array.new_fixed 10 3
        i32.const 0
        i32.const 43
        struct.new 11
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    i32.const 33
    local.set 35
    i32.const 40
    local.set 36
    local.get 35
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 35
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 36
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 35
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 36
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 49
    local.set 37
    i32.const 50
    local.set 38
    local.get 37
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 37
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 38
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 37
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 38
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 49
    local.set 39
    local.get 39
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    ref.null eq
    local.set 10
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 39
          i32.eq
          if ;; label = @4
            local.get 10
            ref.is_null
            if ;; label = @5
              local.get 6
              ref.cast (ref 16)
              local.get 7
              i32.wrap_i64
              local.get 6
              ref.cast (ref 16)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              array.set 16
            else
              local.get 10
              ref.cast (ref 17)
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              struct.set 17 0
            end
            local.get 5
            ref.cast (ref 3)
            local.get 5
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.sub
            struct.set 3 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        local.set 10
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x68206e69 0x00646165 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 27
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 49
    local.set 40
    local.get 40
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 40
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x2070616d 0x64616568
    v128.const i32x4 0x73626120 0x00746e65 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 23
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 41
    local.get 41
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    ref.null eq
    local.set 10
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 41
          i32.eq
          if ;; label = @4
            local.get 10
            ref.is_null
            if ;; label = @5
              local.get 6
              ref.cast (ref 16)
              local.get 7
              i32.wrap_i64
              local.get 6
              ref.cast (ref 16)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              array.set 16
            else
              local.get 10
              ref.cast (ref 17)
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              struct.set 17 0
            end
            local.get 5
            ref.cast (ref 3)
            local.get 5
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.sub
            struct.set 3 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        local.set 10
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x6d206e69 0x6c646469 0x00000065
    array.new_fixed 10 2
    i32.const 0
    i32.const 29
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 17
    local.set 42
    local.get 42
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 42
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x2070616d 0x6464696d
    v128.const i32x4 0x6120656c 0x6e657362 0x00000074 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 25
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 43
    local.get 43
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    ref.null eq
    local.set 10
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 43
          i32.eq
          if ;; label = @4
            local.get 10
            ref.is_null
            if ;; label = @5
              local.get 6
              ref.cast (ref 16)
              local.get 7
              i32.wrap_i64
              local.get 6
              ref.cast (ref 16)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              array.set 16
            else
              local.get 10
              ref.cast (ref 17)
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              struct.set 17 0
            end
            local.get 5
            ref.cast (ref 3)
            local.get 5
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.sub
            struct.set 3 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        local.set 10
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x74206e69 0x006c6961 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 27
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 44
    local.get 44
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 44
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x2070616d 0x6c696174
    v128.const i32x4 0x73626120 0x00746e65 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 23
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 33
    local.set 45
    local.get 45
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 45
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 40
    i32.eq
    v128.const i32x4 0x65726e75 0x65766f6d 0x616d2064 0x6f632070
    v128.const i32x4 0x73696c6c 0x206e6f69 0x61746572 0x64656e69
    array.new_fixed 10 2
    i32.const 0
    i32.const 32
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x2070616d 0x6f6d6572 0x736c6176 0x64707520
    v128.const i32x4 0x20657461 0x676e656c 0x00006874 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 26
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 99
    local.set 47
    local.get 47
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    ref.null eq
    local.set 10
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 47
          i32.eq
          if ;; label = @4
            local.get 10
            ref.is_null
            if ;; label = @5
              local.get 6
              ref.cast (ref 16)
              local.get 7
              i32.wrap_i64
              local.get 6
              ref.cast (ref 16)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              array.set 16
            else
              local.get 10
              ref.cast (ref 17)
              local.get 8
              ref.cast (ref 17)
              struct.get 17 0
              struct.set 17 0
            end
            local.get 5
            ref.cast (ref 3)
            local.get 5
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.sub
            struct.set 3 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        local.set 10
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x6d206576 0x69737369 0x6d20676e
    v128.const i32x4 0x6b207061 0x00007965 0x00000000 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 22
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    i32.const 16
    array.new_default 16
    struct.set 3 0
    local.get 5
    ref.cast (ref 3)
    i32.const 0
    struct.set 3 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x2070616d 0x61656c63 0x65722072 0x73746573
    v128.const i32x4 0x696c6120 0x64657361 0x6e656c20 0x00687467
    array.new_fixed 10 2
    i32.const 0
    i32.const 31
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 33
    local.set 48
    local.get 48
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 48
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x2070616d 0x61656c63 0x65722072 0x65766f6d
    v128.const i32x4 0x6e652073 0x65697274 0x00000073 0x00000000
    array.new_fixed 10 2
    i32.const 0
    i32.const 25
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 65
    local.set 49
    i32.const 60
    local.set 50
    local.get 49
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 49
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 50
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 49
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 50
            struct.set 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 65
    local.set 51
    local.get 51
    i64.extend_i32_s
    local.set 7
    local.get 1
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 51
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 8
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 60
    i32.eq
    v128.const i32x4 0x2070616d 0x65736e69 0x61207472 0x72657466
    v128.const i32x4 0x656c6320 0x76207261 0x62697369 0x0000656c
    array.new_fixed 10 2
    i32.const 0
    i32.const 30
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 1
    local.set 53
    f64.const 0x1.8p+0 (;=1.5;)
    local.set 54
    local.get 53
    local.set 7
    i32.const 16
    array.new_default 16
    local.set 6
    ref.null eq
    local.get 7
    i32.const 0
    local.get 53
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    local.get 54
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 17
    local.set 8
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 8
    array.set 16
    local.get 6
    i32.const 1
    struct.new 3
    local.set 3
    i64.const 2
    local.set 55
    f64.const 0x1.4p+1 (;=2.5;)
    local.set 56
    local.get 55
    local.set 7
    local.get 3
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          i32.const 0
          local.get 55
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          local.get 56
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 3
          local.get 55
          i64.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 56
            struct.set 17 11
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i64.const 2
    local.set 57
    local.get 57
    local.set 7
    local.get 3
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result f64) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 3
          local.get 57
          i64.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 11
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    f64.const 0x1.4p+1 (;=2.5;)
    f64.eq
    v128.const i32x4 0x20343669 0x2079656b 0x20646e61 0x20343666
    v128.const i32x4 0x756c6176 0x61632065 0x65697272 0x00007372
    array.new_fixed 10 2
    i32.const 0
    i32.const 30
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 59
    f32.const 0x1.8p+0 (;=1.5;)
    local.set 60
    local.get 59
    i64.extend_i32_u
    local.set 7
    i32.const 16
    array.new_default 16
    local.set 6
    ref.null eq
    local.get 7
    local.get 59
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    i64.const 0
    local.get 60
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 17
    local.set 8
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 8
    array.set 16
    local.get 6
    i32.const 1
    struct.new 3
    local.set 4
    i32.const 2
    local.set 65
    f32.const 0x1.4p+1 (;=2.5;)
    local.set 66
    local.get 65
    i64.extend_i32_u
    local.set 7
    local.get 4
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          local.get 6
          ref.cast (ref 16)
          array.len
          local.set 12
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          local.get 12
          i32.gt_u
          local.get 12
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 5
            ref.cast (ref 3)
            local.get 12
            i32.const 1
            i32.shl
            array.new_default 16
            struct.set 3 0
            i32.const 0
            local.set 12
            block ;; label = @5
              loop ;; label = @6
                local.get 12
                local.get 6
                ref.cast (ref 16)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 6
                ref.cast (ref 16)
                local.get 12
                array.get 16
                local.set 8
                block ;; label = @7
                  loop ;; label = @8
                    local.get 8
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 0
                    local.set 10
                    local.get 8
                    ref.cast (ref 17)
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 16
                    struct.set 17 0
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    local.get 8
                    ref.cast (ref 17)
                    struct.get 17 1
                    i32.wrap_i64
                    local.get 5
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 16)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 8
                    array.set 16
                    local.get 10
                    local.set 8
                    br 0 (;@8;)
                  end
                end
                local.get 12
                i32.const 1
                i32.add
                local.set 12
                br 0 (;@6;)
              end
            end
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 16)
            local.set 6
          end
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 16
          local.get 7
          local.get 65
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          local.get 66
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 17
          local.set 8
          local.get 6
          ref.cast (ref 16)
          local.get 7
          i32.wrap_i64
          local.get 6
          ref.cast (ref 16)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 8
          array.set 16
          local.get 5
          ref.cast (ref 3)
          local.get 5
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 65
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            local.get 66
            struct.set 17 10
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 2
    local.set 61
    local.get 61
    i64.extend_i32_u
    local.set 7
    local.get 4
    local.set 5
    local.get 5
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 16)
    local.set 6
    local.get 6
    ref.cast (ref 16)
    local.get 7
    i32.wrap_i64
    local.get 6
    ref.cast (ref 16)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 16
    local.set 8
    block (result f32) ;; label = @1
      loop ;; label = @2
        local.get 8
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 1
        local.get 7
        i64.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 17)
          struct.get 17 2
          local.get 61
          i32.eq
          if ;; label = @4
            local.get 8
            ref.cast (ref 17)
            struct.get 17 10
            br 3 (;@1;)
          end
        end
        local.get 8
        ref.cast (ref 17)
        struct.get 17 0
        local.set 8
        br 0 (;@2;)
      end
      unreachable
    end
    f32.const 0x1.4p+1 (;=2.5;)
    f32.eq
    v128.const i32x4 0x6b203875 0x61207965 0x6620646e 0x76203233
    v128.const i32x4 0x65756c61 0x72616320 0x72656972 0x00000073
    array.new_fixed 10 2
    i32.const 0
    i32.const 29
    struct.new 11
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
