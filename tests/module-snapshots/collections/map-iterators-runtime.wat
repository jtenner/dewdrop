(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (struct))
  (type (;2;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;5;) (func (param eqref) (result i32)))
  (type (;6;) (func (param eqref) (result i32)))
  (type (;7;) (func (result (ref 0))))
  (type (;8;) (func (param (ref 2) i32) (result i32)))
  (type (;9;) (func (param (ref 3) i32) (result i32)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param (ref 4) i32) (result i32)))
  (type (;12;) (func (param (ref 3) i32) (result i32)))
  (type (;13;) (func))
  (type (;14;) (array (mut v128)))
  (type (;15;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;16;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;17;) (struct (field (ref 14)) (field i32) (field i32)))
  (type (;18;) (struct (field (mut (ref 14))) (field (mut i32)) (field (mut i32))))
  (type (;19;) (struct (field (mut (ref 14))) (field (mut i32)) (field (mut i32))))
  (type (;20;) (array (mut eqref)))
  (type (;21;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 8))
  (func (;0;) (type 5) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 15)
    struct.get 15 2
  )
  (func (;1;) (type 6) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;2;) (type 7) (result (ref 0))
    i32.const 16
    array.new_default 20
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;3;) (type 8) (param (ref 2) i32) (result i32)
    (local eqref eqref eqref i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 2)
          struct.get 2 1
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 2
          ref.cast (ref 2)
          struct.get 2 1
          array.get 20
          local.set 4
          local.get 2
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 2)
          local.get 2
          ref.cast (ref 2)
          struct.get 2 1
          i32.const 1
          i32.add
          struct.set 2 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 2)
      local.get 1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        block ;; label = @3
          loop ;; label = @4
            local.get 2
            ref.cast (ref 2)
            struct.get 2 1
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            array.len
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            local.get 2
            ref.cast (ref 2)
            struct.get 2 1
            array.get 20
            local.set 4
            local.get 2
            ref.cast (ref 2)
            struct.get 2 0
            ref.cast (ref 20)
            i32.const 1
            local.get 4
            array.set 20
            local.get 4
            ref.is_null
            i32.eqz
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 2)
            local.get 2
            ref.cast (ref 2)
            struct.get 2 1
            i32.const 1
            i32.add
            struct.set 2 1
            br 0 (;@4;)
          end
        end
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      local.set 4
      local.get 4
      ref.is_null
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 20)
      i32.const 1
      local.get 4
      ref.cast (ref 21)
      struct.get 21 0
      array.set 20
      local.get 2
      ref.cast (ref 2)
      struct.get 2 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 2)
        local.get 2
        ref.cast (ref 2)
        struct.get 2 1
        i32.const 1
        i32.add
        struct.set 2 1
      end
      local.get 4
      ref.cast (ref 21)
      struct.get 21 2
      i32.add
      call 3
    else
      local.get 1
    end
  )
  (func (;4;) (type 9) (param (ref 3) i32) (result i32)
    (local eqref eqref eqref i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          array.get 20
          local.set 4
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 3)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 3)
      local.get 1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        block ;; label = @3
          loop ;; label = @4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            array.len
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            array.get 20
            local.set 4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 1
            local.get 4
            array.set 20
            local.get 4
            ref.is_null
            i32.eqz
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 3)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.add
            struct.set 3 1
            br 0 (;@4;)
          end
        end
      end
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      local.set 4
      local.get 4
      ref.is_null
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      local.get 4
      ref.cast (ref 21)
      struct.get 21 0
      array.set 20
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 3)
        local.get 2
        ref.cast (ref 3)
        struct.get 3 1
        i32.const 1
        i32.add
        struct.set 3 1
      end
      local.get 4
      ref.cast (ref 21)
      struct.get 21 8
      i32.add
      call 4
    else
      local.get 1
    end
  )
  (func (;5;) (type 10) (param eqref) (result i32)
    (local eqref eqref eqref i32)
    local.get 0
    ref.cast (ref 21)
    struct.get 21 2
    local.get 0
    ref.cast (ref 21)
    struct.get 21 8
    i32.add
  )
  (func (;6;) (type 11) (param (ref 4) i32) (result i32)
    (local eqref eqref eqref eqref i32)
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
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
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 3
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 3
          ref.cast (ref 4)
          struct.get 4 1
          array.get 20
          local.set 5
          local.get 3
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 20)
          i32.const 1
          local.get 5
          array.set 20
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
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    if (result i32) ;; label = @1
      local.get 0
      local.set 3
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        block ;; label = @3
          loop ;; label = @4
            local.get 3
            ref.cast (ref 4)
            struct.get 4 1
            local.get 3
            ref.cast (ref 4)
            struct.get 4 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            array.len
            i32.ge_u
            br_if 1 (;@3;)
            local.get 3
            ref.cast (ref 4)
            struct.get 4 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            local.get 3
            ref.cast (ref 4)
            struct.get 4 1
            array.get 20
            local.set 5
            local.get 3
            ref.cast (ref 4)
            struct.get 4 0
            ref.cast (ref 20)
            i32.const 1
            local.get 5
            array.set 20
            local.get 5
            ref.is_null
            i32.eqz
            br_if 1 (;@3;)
            local.get 3
            ref.cast (ref 4)
            local.get 3
            ref.cast (ref 4)
            struct.get 4 1
            i32.const 1
            i32.add
            struct.set 4 1
            br 0 (;@4;)
          end
        end
      end
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      local.set 5
      local.get 5
      ref.is_null
      if ;; label = @2
        unreachable
      end
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 20)
      i32.const 1
      local.get 5
      ref.cast (ref 21)
      struct.get 21 0
      array.set 20
      local.get 3
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
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
      local.get 5
      local.set 2
      local.get 0
      ref.cast (ref 4)
      local.get 1
      local.get 2
      call 5
      i32.add
      call 6
    else
      local.get 1
    end
  )
  (func (;7;) (type 12) (param (ref 3) i32) (result i32)
    (local eqref eqref eqref i32)
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          array.get 20
          local.set 4
          local.get 2
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 3)
          local.get 2
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 3)
      local.get 1
      local.get 0
      local.set 2
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        block ;; label = @3
          loop ;; label = @4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            array.len
            i32.ge_u
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 0
            array.get 20
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 20)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            array.get 20
            local.set 4
            local.get 2
            ref.cast (ref 3)
            struct.get 3 0
            ref.cast (ref 20)
            i32.const 1
            local.get 4
            array.set 20
            local.get 4
            ref.is_null
            i32.eqz
            br_if 1 (;@3;)
            local.get 2
            ref.cast (ref 3)
            local.get 2
            ref.cast (ref 3)
            struct.get 3 1
            i32.const 1
            i32.add
            struct.set 3 1
            br 0 (;@4;)
          end
        end
      end
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      local.set 4
      local.get 4
      ref.is_null
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      local.get 4
      ref.cast (ref 21)
      struct.get 21 0
      array.set 20
      local.get 2
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 20)
      i32.const 1
      array.get 20
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 3)
        local.get 2
        ref.cast (ref 3)
        struct.get 3 1
        i32.const 1
        i32.add
        struct.set 3 1
      end
      local.get 4
      ref.cast (ref 21)
      struct.get 21 13
      call 1
      i32.add
      call 7
    else
      local.get 1
    end
  )
  (func (;8;) (type 13)
    (local eqref eqref eqref i64 eqref i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref i32 eqref)
    i32.const 1
    local.set 5
    i32.const 10
    local.set 6
    local.get 5
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 20
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
    struct.new 21
    local.set 4
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 4
    array.set 20
    local.get 2
    i32.const 1
    struct.new 0
    local.set 0
    i32.const 17
    local.set 9
    i32.const 20
    local.set 10
    local.get 9
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 20)
    local.set 2
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 20
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 20)
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
            array.new_default 20
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 2
                ref.cast (ref 20)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 20)
                local.get 8
                array.get 20
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 0
                    local.set 7
                    local.get 4
                    ref.cast (ref 21)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 20
                    struct.set 21 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 20
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
            ref.cast (ref 20)
            local.set 2
          end
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 20
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
          struct.new 21
          local.set 4
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 20
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
        ref.cast (ref 21)
        struct.get 21 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 21)
          struct.get 21 2
          local.get 9
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 21)
            local.get 10
            struct.set 21 8
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 21)
        struct.get 21 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 33
    local.set 11
    i32.const 30
    local.set 12
    local.get 11
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 20)
    local.set 2
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 20
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 20)
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
            array.new_default 20
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 2
                ref.cast (ref 20)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 20)
                local.get 8
                array.get 20
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 0
                    local.set 7
                    local.get 4
                    ref.cast (ref 21)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 20
                    struct.set 21 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 20
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
            ref.cast (ref 20)
            local.set 2
          end
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 20
          local.get 3
          local.get 11
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          local.get 12
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 21
          local.set 4
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 20
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
        ref.cast (ref 21)
        struct.get 21 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 21)
          struct.get 21 2
          local.get 11
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 21)
            local.get 12
            struct.set 21 8
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 21)
        struct.get 21 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 2
    local.set 13
    i32.const 40
    local.set 14
    local.get 13
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 20)
    local.set 2
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 20
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 20)
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
            array.new_default 20
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 2
                ref.cast (ref 20)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 20)
                local.get 8
                array.get 20
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 0
                    local.set 7
                    local.get 4
                    ref.cast (ref 21)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 20
                    struct.set 21 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 20
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
            ref.cast (ref 20)
            local.set 2
          end
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 20
          local.get 3
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
          struct.new 21
          local.set 4
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 20
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
        ref.cast (ref 21)
        struct.get 21 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 21)
          struct.get 21 2
          local.get 13
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 21)
            local.get 14
            struct.set 21 8
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 21)
        struct.get 21 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 2
    i32.const 0
    call 3
    i32.const 53
    i32.eq
    v128.const i32x4 0x2070616d 0x2079656b 0x72657469 0x726f7461
    v128.const i32x4 0x73697620 0x20737469 0x72657665 0x656b2079
    v128.const i32x4 0x00000079 0x00000000 0x00000000 0x00000000
    array.new_fixed 14 3
    i32.const 0
    i32.const 33
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 3
    i32.const 0
    call 4
    i32.const 100
    i32.eq
    v128.const i32x4 0x2070616d 0x756c6176 0x74692065 0x74617265
    v128.const i32x4 0x7620726f 0x74697369 0x76652073 0x20797265
    v128.const i32x4 0x756c6176 0x00000065 0x00000000 0x00000000
    array.new_fixed 14 3
    i32.const 0
    i32.const 37
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 4
    i32.const 0
    call 6
    i32.const 153
    i32.eq
    v128.const i32x4 0x2070616d 0x72746e65 0x74692079 0x74617265
    v128.const i32x4 0x7020726f 0x65736572 0x73657672 0x79656b20
    v128.const i32x4 0x6c61762f 0x70206575 0x69726961 0x0000676e
    array.new_fixed 14 3
    i32.const 0
    i32.const 46
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 2
    local.set 0
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 2
    local.set 1
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 2)
          struct.get 2 1
          local.get 1
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 1
          ref.cast (ref 2)
          struct.get 2 1
          array.get 20
          local.set 4
          local.get 1
          ref.cast (ref 2)
          struct.get 2 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 2)
          local.get 1
          ref.cast (ref 2)
          struct.get 2 1
          i32.const 1
          i32.add
          struct.set 2 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 2)
    struct.get 2 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    i32.eqz
    v128.const i32x4 0x74706d65 0x616d2079 0x656b2070 0x74692079
    v128.const i32x4 0x74617265 0x0000726f 0x00000000 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 22
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 3
    local.set 1
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          local.get 1
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          array.get 20
          local.set 4
          local.get 1
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 3)
          local.get 1
          ref.cast (ref 3)
          struct.get 3 1
          i32.const 1
          i32.add
          struct.set 3 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    i32.eqz
    v128.const i32x4 0x74706d65 0x616d2079 0x61762070 0x2065756c
    v128.const i32x4 0x72657469 0x726f7461 0x00000000 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 24
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 4
    local.set 1
    local.get 1
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 20)
    i32.const 1
    array.get 20
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
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 20)
          i32.const 0
          array.get 20
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 20)
          local.get 1
          ref.cast (ref 4)
          struct.get 4 1
          array.get 20
          local.set 4
          local.get 1
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 20)
          i32.const 1
          local.get 4
          array.set 20
          local.get 4
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
    ref.cast (ref 20)
    i32.const 1
    array.get 20
    ref.is_null
    i32.eqz
    i32.eqz
    v128.const i32x4 0x74706d65 0x616d2079 0x6e652070 0x20797274
    v128.const i32x4 0x72657469 0x726f7461 0x00000000 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 24
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    local.set 15
    v128.const i32x4 0x00656e6f 0x00000000 0x00000000 0x00000000
    array.new_fixed 14 1
    i32.const 0
    i32.const 3
    struct.new 15
    local.set 16
    local.get 15
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 20
    local.set 2
    ref.null eq
    local.get 3
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
    local.get 16
    struct.new 21
    local.set 4
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 4
    array.set 20
    local.get 2
    i32.const 1
    struct.new 0
    local.set 0
    i32.const 2
    local.set 17
    v128.const i32x4 0x65726874 0x00000065 0x00000000 0x00000000
    array.new_fixed 14 1
    i32.const 0
    i32.const 5
    struct.new 15
    local.set 18
    local.get 17
    i64.extend_i32_s
    local.set 3
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 20)
    local.set 2
    local.get 2
    ref.cast (ref 20)
    local.get 3
    i32.wrap_i64
    local.get 2
    ref.cast (ref 20)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 20
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        local.get 4
        ref.is_null
        if ;; label = @3
          local.get 2
          ref.cast (ref 20)
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
            array.new_default 20
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 2
                ref.cast (ref 20)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 2
                ref.cast (ref 20)
                local.get 8
                array.get 20
                local.set 4
                block ;; label = @7
                  loop ;; label = @8
                    local.get 4
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 0
                    local.set 7
                    local.get 4
                    ref.cast (ref 21)
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 20
                    struct.set 21 0
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    local.get 4
                    ref.cast (ref 21)
                    struct.get 21 1
                    i32.wrap_i64
                    local.get 1
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 20)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 4
                    array.set 20
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
            ref.cast (ref 20)
            local.set 2
          end
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 20
          local.get 3
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
          local.get 18
          struct.new 21
          local.set 4
          local.get 2
          ref.cast (ref 20)
          local.get 3
          i32.wrap_i64
          local.get 2
          ref.cast (ref 20)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 4
          array.set 20
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
        ref.cast (ref 21)
        struct.get 21 1
        local.get 3
        i64.eq
        if ;; label = @3
          local.get 4
          ref.cast (ref 21)
          struct.get 21 2
          local.get 17
          i32.eq
          if ;; label = @4
            local.get 4
            ref.cast (ref 21)
            local.get 18
            struct.set 21 13
            br 3 (;@1;)
          end
        end
        local.get 4
        ref.cast (ref 21)
        struct.get 21 0
        local.set 4
        br 0 (;@2;)
      end
      unreachable
    end
    local.get 0
    local.set 1
    i32.const 2
    array.new_default 20
    local.set 2
    local.get 2
    ref.cast (ref 20)
    i32.const 0
    local.get 1
    array.set 20
    local.get 2
    i32.const 0
    struct.new 3
    i32.const 0
    call 7
    i32.const 8
    i32.eq
    v128.const i32x4 0x2070616d 0x65666572 0x636e6572 0x61762065
    v128.const i32x4 0x2065756c 0x72657469 0x726f7461 0x00000000
    array.new_fixed 14 2
    i32.const 0
    i32.const 28
    struct.new 15
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
