(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;2;) (func (result (ref 0))))
  (type (;3;) (func (param (ref 1) i32) (result i32)))
  (type (;4;) (func))
  (type (;5;) (array (mut v128)))
  (type (;6;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 5)) (field i32) (field i32)))
  (type (;9;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (struct (field (mut (ref 5))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (array (mut eqref)))
  (type (;12;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 2))
  (func (;0;) (type 2) (result (ref 0))
    i32.const 16
    array.new_default 11
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;1;) (type 3) (param (ref 1) i32) (result i32)
    (local eqref eqref eqref i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 11)
    i32.const 1
    array.get 11
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 1)
          struct.get 1 1
          local.get 2
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 0
          array.get 11
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 11)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 0
          array.get 11
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 11)
          local.get 2
          ref.cast (ref 1)
          struct.get 1 1
          array.get 11
          local.set 4
          local.get 2
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 1
          local.get 4
          array.set 11
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 1)
          local.get 2
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 11)
    i32.const 1
    array.get 11
    ref.is_null
    i32.eqz
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 1)
      local.get 1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      i32.const 1
      array.get 11
      ref.is_null
      if ;; label = @2
        block ;; label = @3
          loop ;; label = @4
            local.get 2
            ref.cast (ref 1)
            struct.get 1 1
            local.get 2
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 11)
            i32.const 0
            array.get 11
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 11)
            array.len
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 11)
            i32.const 0
            array.get 11
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 11)
            local.get 2
            ref.cast (ref 1)
            struct.get 1 1
            array.get 11
            local.set 4
            local.get 2
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 11)
            i32.const 1
            local.get 4
            array.set 11
            local.get 4
            ref.is_null
            i32.eqz
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 1)
            local.get 2
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.add
            struct.set 1 1
            br 0 (;@4;)
          end
        end
      end
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      i32.const 1
      array.get 11
      local.set 4
      local.get 4
      ref.is_null
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      i32.const 1
      local.get 4
      ref.cast (ref 12)
      struct.get 12 0
      array.set 11
      local.get 2
      ref.cast (ref 1)
      struct.get 1 0
      ref.cast (ref 11)
      i32.const 1
      array.get 11
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 1)
        local.get 2
        ref.cast (ref 1)
        struct.get 1 1
        i32.const 1
        i32.add
        struct.set 1 1
      end
      local.get 4
      ref.cast (ref 12)
      struct.get 12 2
      i32.add
      call 1
    else
      local.get 1
    end
  )
  (func (;2;) (type 4)
    (local eqref eqref eqref i64 eqref i32 eqref i32 i32 i32 i32)
    i32.const 1
    local.set 5
    local.get 5
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 11
    local.set 2
    ref.null eq
    local.get 3
    local.get 5
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
    struct.new 12
    local.set 4
    local.get 2
    ref.cast (ref 11)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 11)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 4
    array.set 11
    local.get 2
    i32.const 1
    struct.new 0
    local.set 0
    i32.const 17
    local.set 8
    local.get 8
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 11)
    local.set 2
    local.get 2
    ref.cast (ref 11)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 11)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 11
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 11)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 7
          i32.gt_u
          local.get 7
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 1
            ref.cast (ref 0)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 11
            struct.set 0 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 11)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 11)
                local.get 7
                array.get 11
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 12)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 11
                    struct.set 12 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 11
                    local.get 6
                    local.set 4
                    br 0 (;@8;)
                  end
                end
                local.get 7
                i32.const 1
                i32.add
                local.set 7
                br 0 (;@6;)
              end
            end
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 11)
            local.set 2
          end
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 11
          local.get 3
          local.get 8
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
          struct.new 12
          local.set 4
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 11
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 12)
          struct.get 12 2
          local.get 8
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    drop
    i32.const 33
    local.set 9
    local.get 9
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 11)
    local.set 2
    local.get 2
    ref.cast (ref 11)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 11)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 11
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 11)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 7
          i32.gt_u
          local.get 7
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 1
            ref.cast (ref 0)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 11
            struct.set 0 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 11)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 11)
                local.get 7
                array.get 11
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 12)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 11
                    struct.set 12 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 11
                    local.get 6
                    local.set 4
                    br 0 (;@8;)
                  end
                end
                local.get 7
                i32.const 1
                i32.add
                local.set 7
                br 0 (;@6;)
              end
            end
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 11)
            local.set 2
          end
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 11
          local.get 3
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
          struct.new 12
          local.set 4
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 11
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 12)
          struct.get 12 2
          local.get 9
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    drop
    i32.const 2
    local.set 10
    local.get 10
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 11)
    local.set 2
    local.get 2
    ref.cast (ref 11)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 11)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 11
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 11)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 7
          i32.gt_u
          local.get 7
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 1
            ref.cast (ref 0)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 11
            struct.set 0 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 11)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 11)
                local.get 7
                array.get 11
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 12)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 11
                    struct.set 12 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 12)
                    struct.get 12 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 11)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 11
                    local.get 6
                    local.set 4
                    br 0 (;@8;)
                  end
                end
                local.get 7
                i32.const 1
                i32.add
                local.set 7
                br 0 (;@6;)
              end
            end
            local.get 1
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 11)
            local.set 2
          end
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 11
          local.get 3
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
          struct.new 12
          local.set 4
          local.get 2
          ref.cast (ref 11)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 11)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 11
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 12)
          struct.get 12 2
          local.get 10
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 12)
        struct.get 12 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    drop
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 11
    local.set 2
    local.get 2
    ref.cast (ref 11)
    i32.const 0
    local.get 1
    array.set 11
    local.get 2
    i32.const 0
    struct.new 1
    i32.const 0
    call 1
    i32.const 53
    i32.eq
    v128.const i32x4 0x20746573 0x72657469 0x726f7461 0x73697620
    v128.const i32x4 0x20737469 0x72657665 0x656b2079 0x00000079
    array.new_fixed 5 2
    i32.const 0
    i32.const 29
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 0
    local.set 0
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 11
    local.set 2
    local.get 2
    ref.cast (ref 11)
    i32.const 0
    local.get 1
    array.set 11
    local.get 2
    i32.const 0
    struct.new 1
    local.set 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 11)
    i32.const 1
    array.get 11
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 1)
          struct.get 1 1
          local.get 1
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 0
          array.get 11
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 11)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 0
          array.get 11
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 11)
          local.get 1
          ref.cast (ref 1)
          struct.get 1 1
          array.get 11
          local.set 4
          local.get 1
          ref.cast (ref 1)
          struct.get 1 0
          ref.cast (ref 11)
          i32.const 1
          local.get 4
          array.set 11
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 1)
          local.get 1
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 11)
    i32.const 1
    array.get 11
    ref.is_null
    i32.eqz
    i32.eqz
    v128.const i32x4 0x74706d65 0x65732079 0x74692074 0x74617265
    v128.const i32x4 0x0000726f 0x00000000 0x00000000 0x00000000
    array.new_fixed 5 2
    i32.const 0
    i32.const 18
    struct.new 6
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
