(module
  (type (;0;) (func (param i64) (result i64)))
  (type (;1;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;2;) (func (result (ref 1))))
  (type (;3;) (func))
  (type (;4;) (array (mut v128)))
  (type (;5;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;6;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;7;) (struct (field (ref 4)) (field i32) (field i32)))
  (type (;8;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;9;) (struct (field (mut (ref 4))) (field (mut i32)) (field (mut i32))))
  (type (;10;) (array (mut eqref)))
  (type (;11;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 2))
  (func (;0;) (type 0) (param i64) (result i64)
    local.get 0
  )
  (func (;1;) (type 2) (result (ref 1))
    i32.const 16
    array.new_default 10
    i32.const 0
    struct.new 1
    ref.cast (ref 1)
  )
  (func (;2;) (type 3)
    (local eqref eqref eqref eqref eqref eqref i64 eqref i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i32 i64 i64 i64 i64 i64 i64)
    call 1
    local.set 0
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    i32.eqz
    v128.const i32x4 0x2077656e 0x20746573 0x65207369 0x7974706d
    array.new_fixed 4 1
    i32.const 0
    i32.const 16
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x74706d65 0x65732079 0x656c2074 0x6874676e
    array.new_fixed 4 1
    i32.const 0
    i32.const 16
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 8
    local.get 8
    i64.extend_i32_s
    local.set 6
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 8
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x74706d65 0x65732079 0x6f632074 0x6961746e
    v128.const i32x4 0x6e20736e 0x6968746f 0x0000676e 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 26
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 10
    local.get 10
    i64.extend_i32_s
    local.set 6
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 10
          i32.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x6d206576 0x69737369 0x6620676e
    v128.const i32x4 0x206d6f72 0x74706d65 0x65732079 0x00000074
    array.new_fixed 4 2
    i32.const 0
    i32.const 29
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 12
    local.get 12
    i64.extend_i32_s
    local.set 6
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 12
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x73726966 0x6e692074 0x74726573 0x206e6f69
    v128.const i32x4 0x6f706572 0x20737472 0x0077656e 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 27
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 13
    local.get 13
    i64.extend_i32_s
    local.set 6
    local.get 0
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 13
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6c707564 0x74616369 0x6e692065 0x74726573
    v128.const i32x4 0x206e6f69 0x6f706572 0x20737472 0x73697865
    v128.const i32x4 0x676e6974 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 3
    i32.const 0
    i32.const 36
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 1)
    struct.get 1 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x6c707564 0x74616369 0x6e692065 0x74726573
    v128.const i32x4 0x206e6f69 0x7065656b 0x656c2073 0x6874676e
    array.new_fixed 4 2
    i32.const 0
    i32.const 32
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 14
    local.get 14
    i64.extend_i32_s
    local.set 6
    i32.const 16
    array.new_default 10
    local.set 5
    ref.null eq
    local.get 6
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
    struct.new 11
    local.set 7
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 7
    array.set 10
    local.get 5
    i32.const 1
    struct.new 1
    local.set 1
    i32.const 16
    local.set 15
    local.get 15
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 15
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6c6c6f63 0x6f697369 0x6e69206e 0x74726573
    v128.const i32x4 0x656e6f20 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 20
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 32
    local.set 16
    local.get 16
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 16
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6c6c6f63 0x6f697369 0x6e69206e 0x74726573
    v128.const i32x4 0x6f777420 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 20
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 48
    local.set 17
    local.get 17
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 17
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6c6c6f63 0x6f697369 0x6e69206e 0x74726573
    v128.const i32x4 0x72687420 0x00006565 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 22
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 1)
    struct.get 1 1
    i32.const 4
    i32.eq
    v128.const i32x4 0x6c6c6f63 0x6f697369 0x6573206e 0x656c2074
    v128.const i32x4 0x6874676e 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 20
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 48
    local.set 18
    local.get 18
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 18
          i32.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x68206e69 0x00646165 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 27
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 48
    local.set 19
    local.get 19
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 19
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x64616568 0x73626120
    v128.const i32x4 0x00746e65 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 19
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 16
    local.set 20
    local.get 20
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 20
          i32.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x6d206e69 0x6c646469 0x00000065
    array.new_fixed 4 2
    i32.const 0
    i32.const 29
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 16
    local.set 21
    local.get 21
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 21
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x6464696d 0x6120656c
    v128.const i32x4 0x6e657362 0x00000074 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 21
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 22
    local.get 22
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 22
          i32.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x63206576 0x696c6c6f 0x6e6f6973
    v128.const i32x4 0x6168632d 0x74206e69 0x006c6961 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 27
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    local.set 23
    local.get 23
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 23
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x20646576 0x6c696174 0x73626120
    v128.const i32x4 0x00746e65 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 19
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 32
    local.set 24
    local.get 24
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 24
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x65726e75 0x65766f6d 0x6f632064 0x73696c6c
    v128.const i32x4 0x206e6f69 0x2079656b 0x61746572 0x64656e69
    array.new_fixed 4 2
    i32.const 0
    i32.const 32
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 1)
    struct.get 1 1
    i32.const 1
    i32.eq
    v128.const i32x4 0x6f6d6572 0x736c6176 0x64707520 0x20657461
    v128.const i32x4 0x676e656c 0x00006874 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 22
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 99
    local.set 25
    local.get 25
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 25
          i32.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x6f6d6572 0x6d206576 0x69737369 0x6320676e
    v128.const i32x4 0x696c6c6f 0x6e6f6973 0x79656b20 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 28
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    i32.const 16
    array.new_default 10
    struct.set 1 0
    local.get 4
    ref.cast (ref 1)
    i32.const 0
    struct.set 1 1
    local.get 1
    ref.cast (ref 1)
    struct.get 1 1
    i32.eqz
    v128.const i32x4 0x61656c63 0x69762072 0x6c626973 0x68742065
    v128.const i32x4 0x67756f72 0x6c612068 0x65736169 0x00000073
    array.new_fixed 4 2
    i32.const 0
    i32.const 29
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 1)
    struct.get 1 1
    i32.const 0
    i32.eq
    v128.const i32x4 0x61656c63 0x65722072 0x73746573 0x6e656c20
    v128.const i32x4 0x00687467 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 19
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 32
    local.set 26
    local.get 26
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 26
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    i32.eqz
    v128.const i32x4 0x61656c63 0x65722072 0x65766f6d 0x6c6f2073
    v128.const i32x4 0x6e652064 0x65697274 0x00000073 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 25
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    local.set 27
    local.get 27
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 27
          i32.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x65736e69 0x61207472 0x72657466 0x656c6320
    v128.const i32x4 0x00007261 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 18
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 4
    local.set 28
    local.get 28
    i64.extend_i32_s
    local.set 6
    local.get 1
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 2
          local.get 28
          i32.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x74736f70 0x656c632d 0x69207261 0x7265736e
    v128.const i32x4 0x6e6f6974 0x73697620 0x656c6269 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 28
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const -1
    local.set 29
    local.get 29
    local.set 6
    i32.const 16
    array.new_default 10
    local.set 5
    ref.null eq
    local.get 6
    i32.const 0
    local.get 29
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
    struct.new 11
    local.set 7
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 7
    array.set 10
    local.get 5
    i32.const 1
    struct.new 1
    local.set 2
    i64.const -1
    local.set 30
    local.get 30
    local.set 6
    local.get 2
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 3
          local.get 30
          i64.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6167656e 0x65766974 0x67697320 0x2064656e
    v128.const i32x4 0x0079656b 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 19
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const 9223372036854775807
    local.set 31
    local.get 31
    local.set 6
    local.get 2
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          local.get 5
          ref.cast (ref 10)
          array.len
          local.set 11
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          local.get 11
          i32.gt_u
          local.get 11
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 4
            ref.cast (ref 1)
            local.get 11
            i32.const 1
            i32.shl
            array.new_default 10
            struct.set 1 0
            i32.const 0
            local.set 11
            block ;; label = @5
              loop ;; label = @6
                local.get 11
                local.get 5
                ref.cast (ref 10)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 5
                ref.cast (ref 10)
                local.get 11
                array.get 10
                local.set 7
                block ;; label = @7
                  loop ;; label = @8
                    local.get 7
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 0
                    local.set 9
                    local.get 7
                    ref.cast (ref 11)
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 10
                    struct.set 11 0
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    local.get 7
                    ref.cast (ref 11)
                    struct.get 11 1
                    i32.wrap_i64
                    local.get 4
                    ref.cast (ref 1)
                    struct.get 1 0
                    ref.cast (ref 10)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 7
                    array.set 10
                    local.get 9
                    local.set 7
                    br 0 (;@8;)
                  end
                end
                local.get 11
                i32.const 1
                i32.add
                local.set 11
                br 0 (;@6;)
              end
            end
            local.get 4
            ref.cast (ref 1)
            struct.get 1 0
            ref.cast (ref 10)
            local.set 5
          end
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 10
          local.get 6
          i32.const 0
          local.get 31
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
          struct.new 11
          local.set 7
          local.get 5
          ref.cast (ref 10)
          local.get 6
          i32.wrap_i64
          local.get 5
          ref.cast (ref 10)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 7
          array.set 10
          local.get 4
          ref.cast (ref 1)
          local.get 4
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 1
          i32.add
          struct.set 1 1
          i32.const 1
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 3
          local.get 31
          i64.eq
          if ;; label = @4
            i32.const 0
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6e676973 0x6d206465 0x6d697861 0x6b206d75
    v128.const i32x4 0x00007965 0x00000000 0x00000000 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 18
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const -1
    local.set 32
    local.get 32
    local.set 6
    local.get 2
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    ref.null eq
    local.set 9
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 3
          local.get 32
          i64.eq
          if ;; label = @4
            local.get 9
            ref.is_null
            if ;; label = @5
              local.get 5
              ref.cast (ref 10)
              local.get 6
              i32.wrap_i64
              local.get 5
              ref.cast (ref 10)
              array.len
              i32.const 1
              i32.sub
              i32.and
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              array.set 10
            else
              local.get 9
              ref.cast (ref 11)
              local.get 7
              ref.cast (ref 11)
              struct.get 11 0
              struct.set 11 0
            end
            local.get 4
            ref.cast (ref 1)
            local.get 4
            ref.cast (ref 1)
            struct.get 1 1
            i32.const 1
            i32.sub
            struct.set 1 1
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        local.set 9
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x6f6d6572 0x6e206576 0x74616765 0x20657669
    v128.const i32x4 0x6e676973 0x6b206465 0x00007965 0x00000000
    array.new_fixed 4 2
    i32.const 0
    i32.const 26
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i64.const -1
    local.set 33
    local.get 33
    call 0
    local.set 6
    i32.const 16
    array.new_default 10
    local.set 5
    ref.null eq
    local.get 6
    i32.const 0
    local.get 33
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
    struct.new 11
    local.set 7
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 7
    array.set 10
    local.get 5
    i32.const 1
    struct.new 1
    local.set 3
    i64.const -1
    local.set 34
    local.get 34
    call 0
    local.set 6
    local.get 3
    local.set 4
    local.get 4
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 10)
    local.set 5
    local.get 5
    ref.cast (ref 10)
    local.get 6
    i32.wrap_i64
    local.get 5
    ref.cast (ref 10)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 10
    local.set 7
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 7
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 1
        local.get 6
        i64.eq
        if ;; label = @3
          local.get 7
          ref.cast (ref 11)
          struct.get 11 3
          local.get 34
          i64.eq
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 7
        ref.cast (ref 11)
        struct.get 11 0
        local.set 7
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x20343675 0x6978616d 0x206d756d 0x0079656b
    array.new_fixed 4 1
    i32.const 0
    i32.const 15
    struct.new 5
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
