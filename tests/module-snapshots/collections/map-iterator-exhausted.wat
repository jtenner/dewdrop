(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct))
  (type (;5;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;6;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;7;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;8;) (func))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (array (mut eqref)))
  (type (;16;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 0))
  (func (;0;) (type 8)
    (local eqref i32 eqref eqref i64 eqref i32 i32 i32 eqref eqref i32 i32 i32)
    i32.const 1
    local.set 6
    i32.const 10
    local.set 7
    local.get 6
    i64.extend_i32_s
    local.set 4
    i32.const 16
    array.new_default 15
    local.set 3
    ref.null eq
    local.get 4
    local.get 6
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 7
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 16
    local.set 5
    local.get 3
    ref.cast (ref 15)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 15)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 5
    array.set 15
    local.get 3
    i32.const 1
    struct.new 3
    local.set 2
    i32.const 2
    array.new_default 15
    local.set 3
    local.get 3
    ref.cast (ref 15)
    i32.const 0
    local.get 2
    array.set 15
    local.get 3
    i32.const 0
    struct.new 5
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          array.get 15
          local.set 5
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 1
          local.get 5
          array.set 15
          local.get 5
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 5)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          i32.const 1
          i32.add
          struct.set 5 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    local.set 5
    local.get 5
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 15)
      i32.const 1
      local.get 5
      ref.cast (ref 16)
      struct.get 16 0
      array.set 15
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 15)
      i32.const 1
      array.get 15
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 5)
        local.get 2
        ref.cast (ref 5)
        struct.get 5 1
        i32.const 1
        i32.add
        struct.set 5 1
      end
      i32.const 1
      local.set 11
      local.get 5
      ref.cast (ref 16)
      struct.get 16 2
      local.set 12
    else
      i32.const 0
      local.set 11
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 11
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          br 2 (;@1;)
        end
        local.get 12
        local.set 1
        local.get 1
        i32.const 1
        i32.eq
        v128.const i32x4 0x73726966 0x656b2074 0x00000079 0x00000000
        array.new_fixed 9 1
        i32.const 0
        i32.const 9
        struct.new 10
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
    local.set 2
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 0
          array.get 15
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 15)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          array.get 15
          local.set 5
          local.get 2
          ref.cast (ref 5)
          struct.get 5 0
          ref.cast (ref 15)
          i32.const 1
          local.get 5
          array.set 15
          local.get 5
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 5)
          local.get 2
          ref.cast (ref 5)
          struct.get 5 1
          i32.const 1
          i32.add
          struct.set 5 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 5)
    struct.get 5 0
    ref.cast (ref 15)
    i32.const 1
    array.get 15
    local.set 5
    local.get 5
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 15)
      i32.const 1
      local.get 5
      ref.cast (ref 16)
      struct.get 16 0
      array.set 15
      local.get 2
      ref.cast (ref 5)
      struct.get 5 0
      ref.cast (ref 15)
      i32.const 1
      array.get 15
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 5)
        local.get 2
        ref.cast (ref 5)
        struct.get 5 1
        i32.const 1
        i32.add
        struct.set 5 1
      end
      i32.const 1
      local.set 13
      local.get 5
      ref.cast (ref 16)
      struct.get 16 2
      drop
    else
      i32.const 0
      local.set 13
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 13
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          br 2 (;@1;)
        end
        unreachable
        br 1 (;@1;)
      end
      unreachable
    end
  )
)
