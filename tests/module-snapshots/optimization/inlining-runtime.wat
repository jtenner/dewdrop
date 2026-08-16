(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;9;) (sub (struct (field funcref))))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref i32) (result eqref)))
  (type (;12;) (func (param eqref) (result (ref 8))))
  (type (;13;) (func (param eqref eqref) (result eqref)))
  (type (;14;) (func (param eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref i32) (result i32)))
  (type (;18;) (func (param eqref eqref i32) (result eqref)))
  (type (;19;) (func (param eqref eqref) (result (ref 8))))
  (type (;20;) (func (param eqref eqref eqref) (result eqref)))
  (type (;21;) (func (param eqref eqref)))
  (type (;22;) (func (param eqref eqref i32)))
  (type (;23;) (func (param eqref eqref) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result i32)))
  (type (;25;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;26;) (func (param (ref 8) i32 i32) (result i32)))
  (type (;27;) (func (param i32 i32) (result i32)))
  (type (;28;) (func (param i32 i32) (result i32)))
  (type (;29;) (func (result i32)))
  (type (;30;) (func))
  (type (;31;) (array (mut v128)))
  (type (;32;) (struct (field (ref 31)) (field i32) (field i32)))
  (type (;33;) (struct (field (ref 31)) (field i32) (field i32)))
  (type (;34;) (struct (field (ref 31)) (field i32) (field i32)))
  (type (;35;) (struct (field (mut (ref 31))) (field (mut i32)) (field (mut i32))))
  (type (;36;) (struct (field (mut (ref 31))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 4))
  (func (;0;) (type 26) (param (ref 8) i32 i32) (result i32)
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
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.const 10
    i32.mul
    local.get 1
    i32.add
    local.set 6
    local.set 3
    local.get 4
    local.get 3
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 4
    local.get 6
    array.set 0
    local.get 2
  )
  (func (;1;) (type 27) (param i32 i32) (result i32)
    local.get 1
  )
  (func (;2;) (type 28) (param i32 i32) (result i32)
    local.get 0
    drop
    local.get 1
  )
  (func (;3;) (type 29) (result i32)
    i32.const 42
  )
  (func (;4;) (type 30)
    (local eqref eqref i32 eqref i32)
    i32.const 1
    local.set 2
    local.get 2
    array.new_default 0
    i32.const 0
    local.get 2
    struct.new 8
    local.set 0
    local.get 0
    i32.const 0
    local.set 4
    local.set 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 1
    ref.cast (ref 8)
    struct.get 8 2
    i32.eq
    if ;; label = @1
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 1
        ref.cast (ref 8)
        struct.get 8 2
        i32.const 2
        i32.mul
      end
      local.set 2
      local.get 2
      local.get 1
      ref.cast (ref 8)
      struct.get 8 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      array.new_default 0
      local.set 3
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 0
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      ref.cast (ref 8)
      struct.get 8 1
      array.copy 0 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      struct.set 8 0
      local.get 1
      ref.cast (ref 8)
      local.get 3
      ref.cast (ref 0)
      array.len
      struct.set 8 2
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    local.get 4
    array.set 0
    local.get 1
    ref.cast (ref 8)
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.add
    struct.set 8 1
    local.get 0
    ref.cast (ref 8)
    i32.const 1
    i32.const 10
    call 0
    drop
    local.get 0
    ref.cast (ref 8)
    i32.const 2
    i32.const 20
    call 0
    i32.const 20
    i32.eq
    v128.const i32x4 0x656c6573 0x726f7463 0x00000000 0x00000000
    array.new_fixed 31 1
    i32.const 0
    i32.const 8
    struct.new 32
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
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.const 12
    i32.eq
    v128.const i32x4 0x75677261 0x746e656d 0x64726f20 0x00007265
    array.new_fixed 31 1
    i32.const 0
    i32.const 14
    struct.new 32
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 42
    i32.const 42
    i32.eq
    v128.const i32x4 0x736e6f63 0x746e6174 0x00000000 0x00000000
    array.new_fixed 31 1
    i32.const 0
    i32.const 8
    struct.new 32
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
