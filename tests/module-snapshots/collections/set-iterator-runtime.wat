(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;5;) (func (result (ref 3))))
  (type (;6;) (func (param (ref 4) i32) (result i32)))
  (type (;7;) (func (param (ref 4)) (result i32)))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (array (mut eqref)))
  (type (;16;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 3))
  (func (;0;) (type 5) (result (ref 3))
    i32.const 16
    array.new_default 15
    i32.const 0
    struct.new 3
    ref.cast (ref 3)
  )
  (func (;1;) (type 6) (param (ref 4) i32) (result i32)
    (local i32 eqref eqref eqref i32 eqref i32 i32 i32)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 3
          ref.cast (ref 4)
          struct.get 4 1
          local.get 3
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 3
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          local.get 3
          ref.cast (ref 4)
          struct.get 4 1
          array.get 15
          local.set 5
          local.get 3
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 1
          local.get 5
          array.set 15
          local.get 5
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 3
          ref.cast (ref 4)
          local.get 3
          ref.cast (ref 4)
          struct.get 4 1
          i32.const 1
          i32.add
          struct.set 4 1
          br 0 (;@3;)
        end
      end
    end
    local.get 3
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    local.set 5
    local.get 5
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 15)
      i32.const 1
      local.get 5
      ref.cast (ref 16)
      struct.get 16 0
      array.set 15
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 15)
      i32.const 1
      array.get 15
      ref.is_null
      if ;; label = @2
        local.get 3
        ref.cast (ref 4)
        local.get 3
        ref.cast (ref 4)
        struct.get 4 1
        i32.const 1
        i32.add
        struct.set 4 1
      end
      i32.const 1
      local.set 9
      local.get 5
      ref.cast (ref 16)
      struct.get 16 2
      local.set 10
    else
      i32.const 0
      local.set 9
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 9
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          local.set 8
          br 2 (;@1;)
        end
        local.get 10
        local.set 2
        local.get 0
        ref.cast (ref 4)
        local.get 1
        local.get 2
        i32.add
        call 1
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
  )
  (func (;2;) (type 7) (param (ref 4)) (result i32)
    (local eqref eqref eqref i32 eqref i32 i32)
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 4)
          struct.get 4 1
          local.get 1
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          local.get 1
          ref.cast (ref 4)
          struct.get 4 1
          array.get 15
          local.set 3
          local.get 1
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 15)
          i32.const 1
          local.get 3
          array.set 15
          local.get 3
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 4)
          local.get 1
          ref.cast (ref 4)
          struct.get 4 1
          i32.const 1
          i32.add
          struct.set 4 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    local.set 3
    local.get 3
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 1
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 15)
      i32.const 1
      local.get 3
      ref.cast (ref 16)
      struct.get 16 0
      array.set 15
      local.get 1
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 15)
      i32.const 1
      array.get 15
      ref.is_null
      if ;; label = @2
        local.get 1
        ref.cast (ref 4)
        local.get 1
        ref.cast (ref 4)
        struct.get 4 1
        i32.const 1
        i32.add
        struct.set 4 1
      end
      i32.const 1
      local.set 7
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      drop
    else
      i32.const 0
      local.set 7
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 7
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          i32.const 1
          local.set 6
          br 2 (;@1;)
        end
        i32.const 0
        local.set 6
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 6
  )
  (func (;3;) (type 8)
    (local eqref eqref eqref i64 eqref i32 eqref i32 i32 i32 i32)
    i32.const 1
    local.set 5
    local.get 5
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 15
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
    struct.new 16
    local.set 4
    local.get 2
    ref.cast (ref 15)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 15)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 4
    array.set 15
    local.get 2
    i32.const 1
    struct.new 3
    local.set 0
    i32.const 17
    local.set 8
    local.get 8
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 15)
    local.set 2
    local.get 2
    ref.cast (ref 15)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 15)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 15
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 15)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
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
            ref.cast (ref 3)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 15
            struct.set 3 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 15)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 15)
                local.get 7
                array.get 15
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 16)
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 15
                    struct.set 16 0
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 15
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
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 15)
            local.set 2
          end
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 15
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
          struct.new 16
          local.set 4
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 15
          local.get 1
          ref.cast (ref 3)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 16)
          struct.get 16 2
          local.get 8
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 0
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
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 15)
    local.set 2
    local.get 2
    ref.cast (ref 15)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 15)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 15
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 15)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
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
            ref.cast (ref 3)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 15
            struct.set 3 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 15)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 15)
                local.get 7
                array.get 15
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 16)
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 15
                    struct.set 16 0
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 15
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
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 15)
            local.set 2
          end
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 15
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
          struct.new 16
          local.set 4
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 15
          local.get 1
          ref.cast (ref 3)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 16)
          struct.get 16 2
          local.get 9
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 0
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
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 15)
    local.set 2
    local.get 2
    ref.cast (ref 15)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 15)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 15
    local.set 4
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 15)
          array.len
          local.set 7
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
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
            ref.cast (ref 3)
            local.get 7
            i32.const 1
            i32.shl
            array.new_default 15
            struct.set 3 0
            i32.const 0
            local.set 7
            block ;; label = @5
              loop ;; label = @6
                local.get 7
                local.get 2
                ref.cast (ref 15)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 15)
                local.get 7
                array.get 15
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 0
                    local.set 6
                    local.get 4
                    ref.cast (ref 16)
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 15
                    struct.set 16 0
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    local.get 4
                    ref.cast (ref 16)
                    struct.get 16 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 3)
                    struct.get 3 0
                    ref.cast (ref 15)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 15
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
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 15)
            local.set 2
          end
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 15
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
          struct.new 16
          local.set 4
          local.get 2
          ref.cast (ref 15)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 15)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 15
          local.get 1
          ref.cast (ref 3)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 16)
          struct.get 16 2
          local.get 10
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 16)
        struct.get 16 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    drop
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 15
    local.set 2
    local.get 2
    ref.cast (ref 15)
    i32.const 0
    local.get 1
    array.set 15
    local.get 2
    i32.const 0
    struct.new 4
    i32.const 0
    call 1
    i32.const 53
    i32.eq
    v128.const i32x4 0x20746573 0x72657469 0x726f7461 0x73697620
    v128.const i32x4 0x20737469 0x72657665 0x656b2079 0x00000079
    array.new_fixed 9 2
    i32.const 0
    i32.const 29
    struct.new 10
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
    array.new_default 15
    local.set 2
    local.get 2
    ref.cast (ref 15)
    i32.const 0
    local.get 1
    array.set 15
    local.get 2
    i32.const 0
    struct.new 4
    call 2
    v128.const i32x4 0x74706d65 0x65732079 0x74692074 0x74617265
    v128.const i32x4 0x0000726f 0x00000000 0x00000000 0x00000000
    array.new_fixed 9 2
    i32.const 0
    i32.const 18
    struct.new 10
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
