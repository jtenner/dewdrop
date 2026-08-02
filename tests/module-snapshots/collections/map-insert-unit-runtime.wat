(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (func))
  (type (;2;) (array (mut eqref)))
  (type (;3;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 0))
  (func (;0;) (type 1)
    (local eqref eqref eqref i64 eqref i32 i32 eqref i32 i32 i32)
    i32.const 1
    local.set 5
    i32.const 1
    local.set 6
    local.get 5
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 2
    local.set 2
    ref.null eq
    local.get 3
    local.get 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 6
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 3
    local.set 4
    local.get 2
    ref.cast (ref 2)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 2)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 4
    array.set 2
    local.get 2
    i32.const 1
    struct.new 0
    local.set 0
    i32.const 2
    local.set 9
    i32.const 2
    local.set 10
    local.get 9
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    local.set 2
    local.get 2
    ref.cast (ref 2)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 2)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 2
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 2)
          array.len
          local.set 8
          local.get 1
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
            local.get 1
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 2
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 2
                ref.cast (ref 2)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 2)
                local.get 8
                array.get 2
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 3)
                    struct.get 3 0
                    local.set 7
                    local.get 4
                    ref.cast (ref 3)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 2)
                    local.get 4
                    ref.cast (ref 3)
                    struct.get 3 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 2)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 2
                    struct.set 3 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 2)
                    local.get 4
                    ref.cast (ref 3)
                    struct.get 3 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 2)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 2
                    local.get 7
                    local.set 4
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
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 2)
            local.set 2
          end
          local.get 2
          ref.cast (ref 2)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 2)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 2
          local.get 3
          local.get 9
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 10
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 3
          local.set 4
          local.get 2
          ref.cast (ref 2)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 2)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 2
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 3)
        struct.get 3 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 3)
          struct.get 3 2
          local.get 9
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 3)
            local.get 10
            struct.set 3 8
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 3)
        struct.get 3 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
  )
)
