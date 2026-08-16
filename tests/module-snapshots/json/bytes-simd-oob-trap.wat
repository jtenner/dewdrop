(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref i32) (result v128)))
  (type (;9;) (func))
  (type (;10;) (array (mut v128)))
  (type (;11;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 10)) (field i32) (field i32)))
  (type (;14;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (type (;15;) (struct (field (mut (ref 10))) (field (mut i32)) (field (mut i32))))
  (memory (;0;) 1)
  (export "main" (func 1))
  (func (;0;) (type 8) (param eqref i32) (result v128)
    (local (ref 12) (ref 10) i32 v128)
    local.get 0
    ref.cast (ref 12)
    local.set 2
    local.get 1
    local.get 2
    struct.get 12 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 12 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 12 0
    local.set 3
    local.get 2
    struct.get 12 1
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
      array.get 10
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 10
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
      array.get 10
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
  (func (;1;) (type 9)
    (local v128)
    v128.const i32x4 0x33323130 0x37363534 0x62613938 0x66656463
    array.new_fixed 10 1
    i32.const 0
    i32.const 16
    struct.new 12
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
