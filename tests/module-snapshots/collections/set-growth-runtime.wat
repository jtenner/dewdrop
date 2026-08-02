(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;8;) (array (mut eqref)))
  (type (;9;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 0))
  (func (;0;) (type 1)
    (local eqref eqref eqref eqref i64 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32)
    i32.const 0
    local.set 6
    local.get 6
    i64.extend_i32_u
    local.set 4
    i32.const 16
    array.new_default 8
    local.set 3
    ref.null eq
    local.get 4
    local.get 6
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 9
    local.set 5
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 5
    array.set 8
    local.get 3
    i32.const 1
    struct.new 0
    local.set 0
    local.get 0
    local.set 1
    i32.const 128
    local.set 9
    local.get 9
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 9
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 9
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 256
    local.set 10
    local.get 10
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 10
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 10
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 384
    local.set 11
    local.get 11
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 11
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 11
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 512
    local.set 12
    local.get 12
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 12
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 12
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 640
    local.set 13
    local.get 13
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 13
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 13
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 768
    local.set 14
    local.get 14
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 14
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 14
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 896
    local.set 15
    local.get 15
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 15
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 15
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003720 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1024
    local.set 16
    local.get 16
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 16
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 16
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003820 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1152
    local.set 17
    local.get 17
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 17
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 17
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00003920 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1280
    local.set 18
    local.get 18
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 18
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 18
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1408
    local.set 19
    local.get 19
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 19
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 19
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1536
    local.set 20
    local.get 20
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 20
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 20
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1664
    local.set 21
    local.get 21
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 21
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 21
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1792
    local.set 22
    local.get 22
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 22
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 22
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 15
    i32.eq
    v128.const i32x4 0x20746553 0x6f666562 0x66206572 0x74737269
    v128.const i32x4 0x6f726720 0x20687477 0x676e656c 0x31206874
    v128.const i32x4 0x00000035 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 33
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1920
    local.set 23
    local.get 23
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 23
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 23
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 16
    i32.eq
    v128.const i32x4 0x20746553 0x66207461 0x74737269 0x72687420
    v128.const i32x4 0x6f687365 0x6c20646c 0x74676e65 0x36312068
    array.new_fixed 2 2
    i32.const 0
    i32.const 32
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 24
    local.get 24
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 24
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 24
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x20746553 0x6c707564 0x74616369 0x74612065
    v128.const i32x4 0x72687420 0x6f687365 0x7220646c 0x69616d65
    v128.const i32x4 0x6920736e 0x706d6564 0x6e65746f 0x00000074
    array.new_fixed 2 3
    i32.const 0
    i32.const 45
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 16
    i32.eq
    v128.const i32x4 0x20746553 0x6c707564 0x74616369 0x74612065
    v128.const i32x4 0x72687420 0x6f687365 0x6b20646c 0x73706565
    v128.const i32x4 0x6e656c20 0x00687467 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 39
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2048
    local.set 25
    local.get 25
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 25
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 25
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00363120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 17
    i32.eq
    v128.const i32x4 0x20746553 0x65746661 0x69662072 0x20747372
    v128.const i32x4 0x65726874 0x6c6f6873 0x656c2064 0x6874676e
    v128.const i32x4 0x00373120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2176
    local.set 26
    local.get 26
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 26
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 26
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00373120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2304
    local.set 27
    local.get 27
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 27
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 27
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00383120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2432
    local.set 28
    local.get 28
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 28
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 28
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00393120 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2560
    local.set 29
    local.get 29
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 29
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 29
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2688
    local.set 30
    local.get 30
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 30
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 30
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2816
    local.set 31
    local.get 31
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 31
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 31
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2944
    local.set 32
    local.get 32
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 32
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 32
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3072
    local.set 33
    local.get 33
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 33
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 33
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3200
    local.set 34
    local.get 34
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 34
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 34
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3328
    local.set 35
    local.get 35
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 35
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 35
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00363220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3456
    local.set 36
    local.get 36
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 36
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 36
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00373220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3584
    local.set 37
    local.get 37
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 37
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 37
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00383220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3712
    local.set 38
    local.get 38
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 38
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 38
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00393220 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3840
    local.set 39
    local.get 39
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 39
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 39
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 31
    i32.eq
    v128.const i32x4 0x20746553 0x6f666562 0x73206572 0x6e6f6365
    v128.const i32x4 0x72672064 0x6874776f 0x6e656c20 0x20687467
    v128.const i32x4 0x00003133 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3968
    local.set 40
    local.get 40
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 40
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 40
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 32
    i32.eq
    v128.const i32x4 0x20746553 0x73207461 0x6e6f6365 0x68742064
    v128.const i32x4 0x68736572 0x20646c6f 0x676e656c 0x33206874
    v128.const i32x4 0x00000032 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 33
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4096
    local.set 41
    local.get 41
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 41
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 41
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 33
    i32.eq
    v128.const i32x4 0x20746553 0x65746661 0x65732072 0x646e6f63
    v128.const i32x4 0x72687420 0x6f687365 0x6c20646c 0x74676e65
    v128.const i32x4 0x33332068 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 36
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4224
    local.set 42
    local.get 42
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 42
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 42
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4352
    local.set 43
    local.get 43
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 43
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 43
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4480
    local.set 44
    local.get 44
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 44
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 44
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4608
    local.set 45
    local.get 45
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 45
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 45
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00363320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4736
    local.set 46
    local.get 46
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 46
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 46
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00373320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4864
    local.set 47
    local.get 47
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 47
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 47
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00383320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4992
    local.set 48
    local.get 48
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 48
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 48
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00393320 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5120
    local.set 49
    local.get 49
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 49
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 49
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5248
    local.set 50
    local.get 50
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 50
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 50
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5376
    local.set 51
    local.get 51
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 51
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 51
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5504
    local.set 52
    local.get 52
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 52
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 52
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5632
    local.set 53
    local.get 53
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 53
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 53
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5760
    local.set 54
    local.get 54
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 54
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 54
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 5888
    local.set 55
    local.get 55
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 55
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 55
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00363420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6016
    local.set 56
    local.get 56
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 56
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 56
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00373420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6144
    local.set 57
    local.get 57
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 57
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 57
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00383420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6272
    local.set 58
    local.get 58
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 58
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 58
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00393420 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6400
    local.set 59
    local.get 59
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 59
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 59
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6528
    local.set 60
    local.get 60
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 60
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 60
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6656
    local.set 61
    local.get 61
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 61
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 61
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6784
    local.set 62
    local.get 62
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 62
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 62
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 6912
    local.set 63
    local.get 63
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 63
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 63
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7040
    local.set 64
    local.get 64
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 64
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 64
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7168
    local.set 65
    local.get 65
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 65
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 65
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00363520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7296
    local.set 66
    local.get 66
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 66
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 66
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00373520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7424
    local.set 67
    local.get 67
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 67
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 67
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00383520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7552
    local.set 68
    local.get 68
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 68
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 68
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00393520 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7680
    local.set 69
    local.get 69
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 69
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 69
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00303620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7808
    local.set 70
    local.get 70
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 70
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 70
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00313620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7936
    local.set 71
    local.get 71
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 71
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 71
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00323620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 63
    i32.eq
    v128.const i32x4 0x20746553 0x6f666562 0x74206572 0x64726968
    v128.const i32x4 0x6f726720 0x20687477 0x676e656c 0x36206874
    v128.const i32x4 0x00000033 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 33
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8064
    local.set 72
    local.get 72
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 72
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 72
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00333620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 64
    i32.eq
    v128.const i32x4 0x20746553 0x74207461 0x64726968 0x72687420
    v128.const i32x4 0x6f687365 0x6c20646c 0x74676e65 0x34362068
    array.new_fixed 2 2
    i32.const 0
    i32.const 32
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8192
    local.set 73
    local.get 73
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 73
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 73
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00343620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 65
    i32.eq
    v128.const i32x4 0x20746553 0x65746661 0x68742072 0x20647269
    v128.const i32x4 0x65726874 0x6c6f6873 0x656c2064 0x6874676e
    v128.const i32x4 0x00353620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8320
    local.set 74
    local.get 74
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 74
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 74
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72672067 0x6874776f 0x79656b20
    v128.const i32x4 0x00353620 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 66
    i32.eq
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x656c2067
    v128.const i32x4 0x6874676e 0x74666120 0x74207265 0x65657268
    v128.const i32x4 0x6f726720 0x20687477 0x6e756f62 0x69726164
    v128.const i32x4 0x00007365 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 4
    i32.const 0
    i32.const 50
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 75
    local.get 75
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 75
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x72702067
    v128.const i32x4 0x72672d65 0x6874776f 0x79656b20 0x72757320
    v128.const i32x4 0x65766976 0x00000073 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 37
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1920
    local.set 76
    local.get 76
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 76
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x69662067
    v128.const i32x4 0x20747372 0x65726874 0x6c6f6873 0x656b2064
    v128.const i32x4 0x75732079 0x76697672 0x00007365 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 42
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2048
    local.set 77
    local.get 77
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 77
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x69662067
    v128.const i32x4 0x20747372 0x74736f70 0x6f72672d 0x20687477
    v128.const i32x4 0x2079656b 0x76727573 0x73657669 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 44
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3968
    local.set 78
    local.get 78
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 78
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x65732067
    v128.const i32x4 0x646e6f63 0x72687420 0x6f687365 0x6b20646c
    v128.const i32x4 0x73207965 0x69767275 0x00736576 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 43
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4096
    local.set 79
    local.get 79
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 79
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x65732067
    v128.const i32x4 0x646e6f63 0x736f7020 0x72672d74 0x6874776f
    v128.const i32x4 0x79656b20 0x72757320 0x65766976 0x00000073
    array.new_fixed 2 3
    i32.const 0
    i32.const 45
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8064
    local.set 80
    local.get 80
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 80
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x68742067
    v128.const i32x4 0x20647269 0x65726874 0x6c6f6873 0x656b2064
    v128.const i32x4 0x75732079 0x76697672 0x00007365 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 42
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8192
    local.set 81
    local.get 81
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 81
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x68742067
    v128.const i32x4 0x20647269 0x74736f70 0x6f72672d 0x20687477
    v128.const i32x4 0x2079656b 0x76727573 0x73657669 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 44
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8320
    local.set 82
    local.get 82
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 82
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x616c2067
    v128.const i32x4 0x74736574 0x79656b20 0x72757320 0x65766976
    v128.const i32x4 0x00000073 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 33
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 83
    local.get 83
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    ref.null eq
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 83
          i32.eq
          if ;; label = @4
            local.get 7
            ref.is_null
            if ;; label = @5
              local.get 3
              ref.cast (ref 8)
              local.get 4
              i32.wrap_i64
              local.get 3
              ref.cast (ref 8)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              array.set 8
            else
              local.get 7
              ref.cast (ref 9)
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              struct.set 9 0
            end
            local.get 2
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 0)
            struct.get 0 1
            i32.const 1
            i32.sub
            struct.set 0 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        local.set 7
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6f6d6572 0x20736576 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x72702067 0x72672d65 0x6874776f
    v128.const i32x4 0x79656b20 0x74666120 0x67207265 0x74776f72
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 4
    i32.const 0
    i32.const 49
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4096
    local.set 84
    local.get 84
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    ref.null eq
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 84
          i32.eq
          if ;; label = @4
            local.get 7
            ref.is_null
            if ;; label = @5
              local.get 3
              ref.cast (ref 8)
              local.get 4
              i32.wrap_i64
              local.get 3
              ref.cast (ref 8)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              array.set 8
            else
              local.get 7
              ref.cast (ref 9)
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              struct.set 9 0
            end
            local.get 2
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 0)
            struct.get 0 1
            i32.const 1
            i32.sub
            struct.set 0 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        local.set 7
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6f6d6572 0x20736576 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x696d2067 0x656c6464 0x6f726720
    v128.const i32x4 0x20687477 0x0079656b 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 39
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8320
    local.set 85
    local.get 85
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    ref.null eq
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 85
          i32.eq
          if ;; label = @4
            local.get 7
            ref.is_null
            if ;; label = @5
              local.get 3
              ref.cast (ref 8)
              local.get 4
              i32.wrap_i64
              local.get 3
              ref.cast (ref 8)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              array.set 8
            else
              local.get 7
              ref.cast (ref 9)
              local.get 5
              ref.cast (ref 9)
              struct.get 9 0
              struct.set 9 0
            end
            local.get 2
            ref.cast (ref 0)
            local.get 2
            ref.cast (ref 0)
            struct.get 0 1
            i32.const 1
            i32.sub
            struct.set 0 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        local.set 7
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x6f6d6572 0x20736576 0x6c6c6f63
    v128.const i32x4 0x6e696469 0x616c2067 0x74736574 0x6f726720
    v128.const i32x4 0x20687477 0x0079656b 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 39
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 63
    i32.eq
    v128.const i32x4 0x20746553 0x6c6c6f63 0x6e696469 0x65722067
    v128.const i32x4 0x61766f6d 0x6661206c 0x20726574 0x776f7267
    v128.const i32x4 0x75206874 0x74616470 0x6c207365 0x74676e65
    v128.const i32x4 0x00000068 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 4
    i32.const 0
    i32.const 49
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 86
    local.get 86
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 86
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x20746553 0x6f6d6572 0x20646576 0x2d657270
    v128.const i32x4 0x776f7267 0x6b206874 0x73207965 0x73796174
    v128.const i32x4 0x73626120 0x00746e65 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 39
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4096
    local.set 87
    local.get 87
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 87
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x20746553 0x6f6d6572 0x20646576 0x6464696d
    v128.const i32x4 0x6b20656c 0x73207965 0x73796174 0x73626120
    v128.const i32x4 0x00746e65 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 8320
    local.set 88
    local.get 88
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 88
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x20746553 0x6f6d6572 0x20646576 0x6574616c
    v128.const i32x4 0x6b207473 0x73207965 0x73796174 0x73626120
    v128.const i32x4 0x00746e65 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 35
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    i32.const 16
    array.new_default 8
    struct.set 0 0
    local.get 2
    ref.cast (ref 0)
    i32.const 0
    struct.set 0 1
    local.get 0
    ref.cast (ref 0)
    struct.get 0 1
    i32.eqz
    v128.const i32x4 0x20746553 0x61656c63 0x66612072 0x20726574
    v128.const i32x4 0x776f7267 0x69206874 0x6c612073 0x20736169
    v128.const i32x4 0x69736976 0x00656c62 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 39
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    local.set 89
    local.get 89
    i64.extend_i32_u
    local.set 4
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          local.get 3
          ref.cast (ref 8)
          array.len
          local.set 8
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 2
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 8
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 3
                ref.cast (ref 8)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 3
                ref.cast (ref 8)
                local.get 8
                array.get 8
                local.set 5
                block ;; label = @7
                  loop ;; label = @8
                    local.get 5
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 0
                    local.set 7
                    local.get 5
                    ref.cast (ref 9)
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 8
                    struct.set 9 0
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    local.get 5
                    ref.cast (ref 9)
                    struct.get 9 1
                    i32.wrap_i64
                    local.get 2
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 8)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 5
                    array.set 8
                    local.get 7
                    local.set 5
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 8)
            local.set 3
          end
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 8
          local.get 4
          local.get 89
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 9
          local.set 5
          local.get 3
          ref.cast (ref 8)
          local.get 4
          i32.wrap_i64
          local.get 3
          ref.cast (ref 8)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 5
          array.set 8
          local.get 2
          ref.cast (ref 0)
          local.get 2
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 89
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x65736e69 0x20737472 0x65746661
    v128.const i32x4 0x6c632072 0x20726165 0x20646e61 0x776f7267
    v128.const i32x4 0x00006874 0x00000000 0x00000000 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 34
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 7
    local.set 90
    local.get 90
    i64.extend_i32_u
    local.set 4
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 8)
    local.set 3
    local.get 3
    ref.cast (ref 8)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 8)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 8
    local.set 5
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 5
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 1
        local.get 4
        i64.eq
        if ;; label = @3
          local.get 5
          ref.cast (ref 9)
          struct.get 9 2
          local.get 90
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 5
        ref.cast (ref 9)
        struct.get 9 0
        local.set 5
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20746553 0x74736f70 0x656c632d 0x69207261
    v128.const i32x4 0x7265736e 0x6e6f6974 0x20736920 0x61696c61
    v128.const i32x4 0x69762073 0x6c626973 0x00000065 0x00000000
    array.new_fixed 2 3
    i32.const 0
    i32.const 41
    struct.new 3
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
