(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;1;) (func (param (ref 0) i32 i32) (result i32)))
  (type (;2;) (func (param i32 i32) (result i32)))
  (type (;3;) (func (param i32 i32) (result i32)))
  (type (;4;) (func (result i32)))
  (type (;5;) (func))
  (type (;6;) (array (mut v128)))
  (type (;7;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;8;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;9;) (struct (field (ref 6)) (field i32) (field i32)))
  (type (;10;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;11;) (struct (field (mut (ref 6))) (field (mut i32)) (field (mut i32))))
  (type (;12;) (array (mut i32)))
  (type (;13;) (array (mut i64)))
  (type (;14;) (array (mut f32)))
  (type (;15;) (array (mut f64)))
  (type (;16;) (array (mut v128)))
  (type (;17;) (array (mut eqref)))
  (export "main" (func 4))
  (func (;0;) (type 1) (param (ref 0) i32 i32) (result i32)
    (local eqref i32 eqref i32)
    local.get 0
    i32.const 0
    local.set 4
    local.get 0
    i32.const 0
    local.set 4
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 12)
    local.get 4
    array.get 12
    i32.const 10
    i32.mul
    local.get 1
    i32.add
    local.set 6
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 12)
    local.get 4
    local.get 6
    array.set 12
    local.get 2
  )
  (func (;1;) (type 2) (param i32 i32) (result i32)
    local.get 1
  )
  (func (;2;) (type 3) (param i32 i32) (result i32)
    local.get 0
    drop
    local.get 1
  )
  (func (;3;) (type 4) (result i32)
    i32.const 42
  )
  (func (;4;) (type 5)
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 2
    local.get 2
    array.new_default 12
    i32.const 0
    local.get 2
    struct.new 0
    local.set 0
    local.get 0
    i32.const 0
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 1
    ref.cast (ref 0)
    struct.get 0 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 0)
        struct.get 0 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 0)
      struct.get 0 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 12
      local.set 3
      i32.const 0
      local.set 2
      block ;; label = @2
        loop ;; label = @3
          local.get 2
          local.get 1
          ref.cast (ref 0)
          struct.get 0 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 3
          ref.cast (ref 12)
          local.get 2
          local.get 1
          ref.cast (ref 0)
          struct.get 0 0
          ref.cast (ref 12)
          local.get 2
          array.get 12
          array.set 12
          local.get 2
          i32.const 1
          i32.add
          local.set 2
          br 0 (;@3;)
        end
      end
      local.get 1
      ref.cast (ref 0)
      local.get 3
      struct.set 0 0
      local.get 1
      ref.cast (ref 0)
      local.get 3
      ref.cast (ref 12)
      array.len
      struct.set 0 2
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 12)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    local.get 4
    array.set 12
    local.get 1
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.const 1
    i32.add
    struct.set 0 1
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const 10
    call 0
    drop
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 20
    call 0
    i32.const 20
    i32.eq
    v128.const i32x4 0x656c6573 0x726f7463 0x00000000 0x00000000
    array.new_fixed 6 1
    i32.const 0
    i32.const 8
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 0)
    struct.get 0 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 12)
    local.get 2
    array.get 12
    i32.const 12
    i32.eq
    v128.const i32x4 0x75677261 0x746e656d 0x64726f20 0x00007265
    array.new_fixed 6 1
    i32.const 0
    i32.const 14
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x736e6f63 0x746e6174 0x00000000 0x00000000
    array.new_fixed 6 1
    i32.const 0
    i32.const 8
    struct.new 7
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
