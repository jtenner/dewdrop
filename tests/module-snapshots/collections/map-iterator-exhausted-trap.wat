(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (func (result i32)))
  (type (;2;) (array (mut eqref)))
  (type (;3;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 0))
  (func (;0;) (type 1) (result i32)
    (local eqref eqref eqref i64 eqref i32 i32 i32 i32 i32 i32 i32)
    i32.const 1
    local.set 5
    i32.const 10
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
    local.set 1
    i32.const 2
    array.new_default 2
    local.set 2
    local.get 2
    ref.cast (ref 2)
    i32.const 0
    local.get 1
    array.set 2
    local.get 2
    i32.const 0
    struct.new 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          array.get 2
          local.set 4
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 1
          local.get 4
          array.set 2
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    local.set 4
    local.get 4
    ref.is_null
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    local.get 4
    ref.cast (ref 3)
    struct.get 3 0
    array.set 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 1
      i32.add
      struct.set 0 1
    end
    local.get 4
    ref.cast (ref 3)
    struct.get 3 2
    drop
    i32.const 1
    local.set 8
    i32.const 10
    local.set 9
    local.get 8
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 2
    local.set 2
    ref.null eq
    local.get 3
    local.get 8
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 9
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
    local.set 1
    i32.const 2
    array.new_default 2
    local.set 2
    local.get 2
    ref.cast (ref 2)
    i32.const 0
    local.get 1
    array.set 2
    local.get 2
    i32.const 0
    struct.new 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          array.get 2
          local.set 4
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 1
          local.get 4
          array.set 2
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    local.set 4
    local.get 4
    ref.is_null
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    local.get 4
    ref.cast (ref 3)
    struct.get 3 0
    array.set 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 1
      i32.add
      struct.set 0 1
    end
    local.get 4
    ref.cast (ref 3)
    struct.get 3 2
    drop
    i32.const 1
    local.set 10
    i32.const 10
    local.set 11
    local.get 10
    i64.extend_i32_s
    local.set 3
    i32.const 16
    array.new_default 2
    local.set 2
    ref.null eq
    local.get 3
    local.get 10
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    local.get 11
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
    local.set 1
    i32.const 2
    array.new_default 2
    local.set 2
    local.get 2
    ref.cast (ref 2)
    i32.const 0
    local.get 1
    array.set 2
    local.get 2
    i32.const 0
    struct.new 0
    local.set 0
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          array.get 2
          local.set 4
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 1
          local.get 4
          array.set 2
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    local.set 4
    local.get 4
    ref.is_null
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    local.get 4
    ref.cast (ref 3)
    struct.get 3 0
    array.set 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 1
      i32.add
      struct.set 0 1
    end
    local.get 4
    ref.cast (ref 3)
    struct.get 3 2
    drop
    local.get 0
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      block ;; label = @2
        loop ;; label = @3
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          array.len
          i32.ge_u
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 0
          array.get 2
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          array.get 2
          local.set 4
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 2)
          i32.const 1
          local.get 4
          array.set 2
          local.get 4
          ref.is_null
          i32.eqz
          br_if 1 (;@2;)
          local.get 1
          ref.cast (ref 0)
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 0 (;@3;)
        end
      end
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    local.set 4
    local.get 4
    ref.is_null
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    local.get 4
    ref.cast (ref 3)
    struct.get 3 0
    array.set 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 2)
    i32.const 1
    array.get 2
    ref.is_null
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 0)
      struct.get 0 1
      i32.const 1
      i32.add
      struct.set 0 1
    end
    local.get 4
    ref.cast (ref 3)
    struct.get 3 2
  )
)
