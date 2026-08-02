(module
  (type (;0;) (func (param eqref) (result i32)))
  (type (;1;) (func (param eqref i32 i32) (result eqref)))
  (type (;2;) (func (param eqref) (result eqref)))
  (type (;3;) (func (param eqref i32 i32) (result eqref)))
  (type (;4;) (func (param eqref) (result i32)))
  (type (;5;) (func (param eqref i32 i32) (result eqref)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (param eqref i32 i32) (result eqref)))
  (type (;8;) (func (result i32)))
  (type (;9;) (array (mut v128)))
  (type (;10;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;11;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;12;) (struct (field (ref 9)) (field i32) (field i32)))
  (type (;13;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (type (;14;) (struct (field (mut (ref 9))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 8))
  (func (;0;) (type 0) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 10)
    struct.get 10 2
  )
  (func (;1;) (type 1) (param eqref i32 i32) (result eqref)
    (local (ref 10) (ref 9) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 10)
    local.set 3
    local.get 3
    struct.get 10 2
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
    struct.get 10 0
    local.set 4
    local.get 3
    struct.get 10 1
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
      array.get 9
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
      array.get 9
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
    struct.get 10 1
    local.get 1
    i32.add
    local.get 2
    struct.new 12
  )
  (func (;2;) (type 2) (param eqref) (result eqref)
    (local (ref 12))
    local.get 0
    ref.cast (ref 12)
    local.tee 1
    struct.get 12 0
    local.get 1
    struct.get 12 1
    local.get 1
    struct.get 12 2
    struct.new 10
  )
  (func (;3;) (type 3) (param eqref i32 i32) (result eqref)
    (local (ref 12) (ref 9) i32 i32 i32 i32)
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
      array.get 9
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
      array.get 9
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
    struct.new 12
  )
  (func (;4;) (type 4) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;5;) (type 5) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 1
  )
  (func (;6;) (type 6) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;7;) (type 7) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    local.get 1
    i32.sub
    call 3
  )
  (func (;8;) (type 8) (result i32)
    (local eqref)
    v128.const i32x4 0xbbce7878 0xe796b8e4 0x79798c95 0x00000000
    array.new_fixed 9 1
    i32.const 0
    i32.const 12
    struct.new 10
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
