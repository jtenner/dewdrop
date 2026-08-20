(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32))))
  (type (;2;) (sub final 0 (struct (field i32) (field eqref))))
  (type (;3;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;4;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;5;) (func))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (array (mut eqref)))
  (type (;13;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 0))
  (func (;0;) (type 5)
    (local eqref i32 eqref eqref i64 eqref i32 i32 eqref eqref i32 i32 i32)
    i32.const 1
    local.set 6
    local.get 6
    i64.extend_i32_s
    local.set 4
    i32.const 16
    array.new_default 12
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
    struct.new 13
    local.set 5
    local.get 3
    ref.cast (ref 12)
    local.get 4
    i32.wrap_i64
    local.get 3
    ref.cast (ref 12)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 5
    array.set 12
    local.get 3
    i32.const 1
    struct.new 3
    local.set 2
    i32.const 2
    array.new_default 12
    local.set 3
    local.get 3
    ref.cast (ref 12)
    i32.const 0
    local.get 2
    array.set 12
    local.get 3
    i32.const 0
    struct.new 4
    local.set 0
    local.get 0
    local.set 2
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 12)
    i32.const 1
    array.get 12
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 0
          array.get 12
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 12)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 0
          array.get 12
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 12)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          array.get 12
          local.set 5
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 1
          local.get 5
          array.set 12
          local.get 5
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 4)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          i32.const 1
          i32.add
          struct.set 4 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 12)
    i32.const 1
    array.get 12
    local.set 5
    local.get 5
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 12)
      i32.const 1
      local.get 5
      ref.cast (ref 13)
      struct.get 13 0
      array.set 12
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 12)
      i32.const 1
      array.get 12
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 4)
        local.get 2
        ref.cast (ref 4)
        struct.get 4 1
        i32.const 1
        i32.add
        struct.set 4 1
      end
      i32.const 1
      local.set 10
      local.get 5
      ref.cast (ref 13)
      struct.get 13 2
      local.set 11
    else
      i32.const 0
      local.set 10
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          unreachable
          br 2 (;@1;)
        end
        local.get 11
        local.set 1
        local.get 1
        i32.const 1
        i32.eq
        v128.const i32x4 0x73726966 0x656b2074 0x00000079 0x00000000
        array.new_fixed 6 1
        i32.const 0
        i32.const 9
        struct.new 7
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
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 12)
    i32.const 1
    array.get 12
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 0
          array.get 12
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 12)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 0
          array.get 12
          ref.cast (ref 3)
          struct.get 3 0
          ref.cast (ref 12)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          array.get 12
          local.set 5
          local.get 2
          ref.cast (ref 4)
          struct.get 4 0
          ref.cast (ref 12)
          i32.const 1
          local.get 5
          array.set 12
          local.get 5
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 2
          ref.cast (ref 4)
          local.get 2
          ref.cast (ref 4)
          struct.get 4 1
          i32.const 1
          i32.add
          struct.set 4 1
          br 0 (;@3;)
        end
      end
    end
    local.get 2
    ref.cast (ref 4)
    struct.get 4 0
    ref.cast (ref 12)
    i32.const 1
    array.get 12
    local.set 5
    local.get 5
    ref.is_null
    i32.eqz
    if ;; label = @1
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 12)
      i32.const 1
      local.get 5
      ref.cast (ref 13)
      struct.get 13 0
      array.set 12
      local.get 2
      ref.cast (ref 4)
      struct.get 4 0
      ref.cast (ref 12)
      i32.const 1
      array.get 12
      ref.is_null
      if ;; label = @2
        local.get 2
        ref.cast (ref 4)
        local.get 2
        ref.cast (ref 4)
        struct.get 4 1
        i32.const 1
        i32.add
        struct.set 4 1
      end
      i32.const 1
      local.set 12
      local.get 5
      ref.cast (ref 13)
      struct.get 13 2
      drop
    else
      i32.const 0
      local.set 12
    end
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 12
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
