(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref i32 i32) (result eqref)))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref i32 i32) (result eqref)))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (param eqref i32 i32) (result eqref)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32 i32) (result eqref)))
  (type (;16;) (func (result i32)))
  (type (;17;) (array (mut v128)))
  (type (;18;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;19;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;20;) (struct (field (ref 17)) (field i32) (field i32)))
  (type (;21;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (type (;22;) (struct (field (mut (ref 17))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 8))
  (func (;0;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 18)
    struct.get 18 2
  )
  (func (;1;) (type 9) (param eqref i32 i32) (result eqref)
    (local (ref 18) (ref 17) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 18)
    local.set 3
    local.get 3
    struct.get 18 2
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
    struct.get 18 0
    local.set 4
    local.get 3
    struct.get 18 1
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
      array.get 17
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
      array.get 17
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
    struct.get 18 1
    local.get 1
    i32.add
    local.get 2
    struct.new 20
  )
  (func (;2;) (type 10) (param eqref) (result eqref)
    (local (ref 20))
    local.get 0
    ref.cast (ref 20)
    local.tee 1
    struct.get 20 0
    local.get 1
    struct.get 20 1
    local.get 1
    struct.get 20 2
    struct.new 18
  )
  (func (;3;) (type 11) (param eqref i32 i32) (result eqref)
    (local (ref 20) (ref 17) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 20)
    local.set 3
    local.get 3
    struct.get 20 2
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
    struct.get 20 0
    local.set 4
    local.get 3
    struct.get 20 1
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
      array.get 17
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
      array.get 17
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
    struct.get 20 1
    local.get 1
    i32.add
    local.get 2
    struct.new 20
  )
  (func (;4;) (type 12) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;5;) (type 13) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 1
  )
  (func (;6;) (type 14) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;7;) (type 15) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    local.get 1
    i32.sub
    call 3
  )
  (func (;8;) (type 16) (result i32)
    (local eqref)
    v128.const i32x4 0xbbce7878 0xe796b8e4 0x79798c95 0x00000000
    array.new_fixed 17 1
    i32.const 0
    i32.const 12
    struct.new 18
    i32.const 2
    i32.const 8
    call 5
    local.set 0
    local.get 0
    i32.const 2
    i32.const 8
    call 7
    call 6
    call 4
  )
)
