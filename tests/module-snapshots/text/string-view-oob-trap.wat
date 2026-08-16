(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref i32 i32) (result eqref)))
  (type (;9;) (func (param eqref i32 i32) (result eqref)))
  (type (;10;) (func))
  (type (;11;) (array (mut v128)))
  (type (;12;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;13;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;14;) (struct (field (ref 11)) (field i32) (field i32)))
  (type (;15;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (type (;16;) (struct (field (mut (ref 11))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 2))
  (func (;0;) (type 8) (param eqref i32 i32) (result eqref)
    (local (ref 12) (ref 11) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 12)
    local.set 3
    local.get 3
    struct.get 12 2
    local.set 5
    local.get 1
    local.get 5
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.get 5
    local.get 1
    i32.sub
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    struct.get 12 0
    local.set 4
    local.get 3
    struct.get 12 1
    local.get 1
    i32.add
    local.set 6
    local.get 1
    local.get 2
    i32.add
    local.set 7
    local.get 1
    i32.eqz
    i32.eqz
    if ;; label = @1
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 11
      local.get 6
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        unreachable
      end
    end
    local.get 7
    local.get 5
    i32.lt_u
    if ;; label = @1
      local.get 6
      local.get 2
      i32.add
      local.set 6
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 11
      local.get 6
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        unreachable
      end
    end
    local.get 4
    local.get 3
    struct.get 12 1
    local.get 1
    i32.add
    local.get 2
    struct.new 14
  )
  (func (;1;) (type 9) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 0
  )
  (func (;2;) (type 10)
    (local eqref eqref)
    v128.const i32x4 0x00636261 0x00000000 0x00000000 0x00000000
    array.new_fixed 11 1
    i32.const 0
    i32.const 3
    struct.new 12
    local.set 0
    local.get 0
    i32.const 4
    i32.const 1
    call 1
    local.set 1
  )
)
