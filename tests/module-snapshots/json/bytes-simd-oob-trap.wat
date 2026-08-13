(module
  (type (;0;) (func (param eqref i32) (result v128)))
  (type (;1;) (func))
  (type (;2;) (array (mut v128)))
  (type (;3;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;4;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;5;) (struct (field (ref 2)) (field i32) (field i32)))
  (type (;6;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field (mut (ref 2))) (field (mut i32)) (field (mut i32))))
  (memory (;0;) 1)
  (export "main" (func 1))
  (func (;0;) (type 0) (param eqref i32) (result v128)
    (local (ref 4) (ref 2) i32 v128)
    local.get 0
    ref.cast (ref 4)
    local.set 2
    local.get 1
    local.get 2
    struct.get 4 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 4 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 4 0
    local.set 3
    local.get 2
    struct.get 4 1
    local.get 1
    i32.add
    local.set 4
    local.get 4
    i32.const 15
    i32.and
    i32.eqz
    if ;; label = @1
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 2
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 2
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.add
      i8x16.swizzle
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      i32.const 1
      i32.add
      array.get 2
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.add
      i32.const 16
      i8x16.splat
      i8x16.sub
      i8x16.swizzle
      v128.or
      local.set 5
    end
    local.get 5
  )
  (func (;1;) (type 1)
    (local v128)
    v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
    array.new_fixed 2 1
    i32.const 0
    i32.const 16
    struct.new 4
    i32.const 1
    call 0
    local.set 0
    local.get 0
    i8x16.extract_lane_u 0
    i32.const 0
    i32.eq
    if ;; label = @1
    else
    end
  )
)
