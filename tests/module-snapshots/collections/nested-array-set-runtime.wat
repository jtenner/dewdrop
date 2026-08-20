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
  (type (;9;) (struct (field eqref) (field (mut i32))))
  (type (;10;) (sub (struct (field funcref))))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref i32) (result eqref)))
  (type (;13;) (func (param eqref) (result (ref 8))))
  (type (;14;) (func (param eqref eqref) (result eqref)))
  (type (;15;) (func (param eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref i32) (result i32)))
  (type (;19;) (func (param eqref eqref i32) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result (ref 8))))
  (type (;21;) (func (param eqref eqref eqref) (result eqref)))
  (type (;22;) (func (param eqref eqref)))
  (type (;23;) (func (param eqref eqref i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref eqref i32) (result i32)))
  (type (;26;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;27;) (func (param (ref 8)) (result i32)))
  (type (;28;) (func))
  (type (;29;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;30;) (struct))
  (type (;31;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;32;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;33;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;34;) (array (mut v128)))
  (type (;35;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;36;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;37;) (struct (field (ref 34)) (field i32) (field i32)))
  (type (;38;) (struct (field (mut (ref 34))) (field (mut i32)) (field (mut i32))))
  (type (;39;) (struct (field (mut (ref 34))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 1))
  (func (;0;) (type 27) (param (ref 8)) (result i32)
    (local eqref i32 eqref i32)
    local.get 0
    i32.const 9
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
  )
  (func (;1;) (type 28)
    (local eqref eqref eqref i32 eqref eqref i32 eqref i32 i32)
    i32.const 1
    array.new_default 0
    local.set 5
    i32.const 1
    local.set 6
    local.get 5
    ref.cast (ref 0)
    i32.const 0
    local.get 6
    array.set 0
    local.get 5
    i32.const 1
    i32.const 1
    struct.new 8
    local.set 0
    i32.const 1
    array.new_default 0
    local.set 7
    i32.const 0
    local.set 8
    local.get 7
    ref.cast (ref 0)
    i32.const 0
    local.get 8
    array.set 0
    local.get 7
    i32.const 1
    i32.const 1
    struct.new 8
    local.set 1
    local.get 1
    local.set 2
    local.get 2
    ref.cast (ref 8)
    i32.const 0
    struct.set 8 1
    i32.const 0
    local.set 3
    local.get 1
    ref.cast (ref 8)
    call 0
    local.set 9
    local.get 0
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 3
    local.get 9
    array.set 0
    i32.const 0
    local.set 3
    local.get 0
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 8)
    struct.get 8 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x7473656e 0x61206465 0x79617272 0x74657320
    v128.const i32x4 0x736f6c20 0x74692074 0x65722073 0x76696563
    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
    array.new_fixed 34 3
    i32.const 0
    i32.const 34
    struct.new 35
    drop
    local.get 2
    ref.cast (ref 8)
    struct.get 8 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.const 9
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x7473656e 0x76206465 0x65756c61 0x6c616320
    v128.const i32x4 0x6964206c 0x6f6e2064 0x75722074 0x0000006e
    array.new_fixed 34 2
    i32.const 0
    i32.const 29
    struct.new 35
    drop
    local.get 1
    ref.cast (ref 8)
    struct.get 8 1
    i32.const 1
    i32.eq
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
