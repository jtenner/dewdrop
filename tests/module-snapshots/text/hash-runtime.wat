(module
  (type (;0;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;1;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;2;) (func (param eqref eqref) (result i32)))
  (type (;3;) (func (param eqref) (result i64)))
  (type (;4;) (func (param eqref i32 i32) (result eqref)))
  (type (;5;) (func (param eqref eqref) (result i32)))
  (type (;6;) (func (param eqref) (result i64)))
  (type (;7;) (func (param eqref eqref) (result i32)))
  (type (;8;) (func (param eqref) (result i64)))
  (type (;9;) (func (param eqref) (result i64)))
  (type (;10;) (func (param eqref eqref) (result i32)))
  (type (;11;) (func (param eqref) (result i64)))
  (type (;12;) (func (param eqref eqref) (result i32)))
  (type (;13;) (func (param eqref i32 i32) (result eqref)))
  (type (;14;) (func (param eqref) (result i64)))
  (type (;15;) (func (param eqref eqref) (result i32)))
  (type (;16;) (func (result (ref 0))))
  (type (;17;) (func (result (ref 0))))
  (type (;18;) (func (result (ref 0))))
  (type (;19;) (func))
  (type (;20;) (array (mut v128)))
  (type (;21;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;22;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;23;) (struct (field (ref 20)) (field i32) (field i32)))
  (type (;24;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (type (;25;) (struct (field (mut (ref 20))) (field (mut i32)) (field (mut i32))))
  (type (;26;) (array (mut eqref)))
  (type (;27;) (struct (field (mut eqref)) (field (mut i64)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref)) (field (mut i32)) (field (mut i64)) (field (mut f32)) (field (mut f64)) (field (mut v128)) (field (mut eqref))))
  (export "main" (func 17))
  (func (;0;) (type 2) (param eqref eqref) (result i32)
    (local (ref 21) (ref 21) (ref 20) (ref 20) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 21)
    local.set 2
    local.get 1
    ref.cast (ref 21)
    local.set 3
    local.get 2
    struct.get 21 2
    local.tee 6
    local.get 3
    struct.get 21 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 21 0
    local.set 4
    local.get 3
    struct.get 21 0
    local.set 5
    local.get 2
    struct.get 21 1
    local.set 7
    local.get 3
    struct.get 21 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 11
        end
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;1;) (type 3) (param eqref) (result i64)
    (local (ref 21) (ref 20) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 21)
    local.set 1
    local.get 1
    struct.get 21 0
    local.set 2
    local.get 1
    struct.get 21 1
    local.set 3
    local.get 1
    struct.get 21 2
    local.set 4
    i32.const 0
    local.set 5
    i64.const -3750763034362895579
    local.set 6
    loop ;; label = @1
      local.get 5
      local.get 4
      i32.ge_u
      if ;; label = @2
        local.get 6
        return
      end
      local.get 6
      local.get 2
      local.get 3
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 3
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i64.extend_i32_u
      i64.xor
      i64.const 1099511628211
      i64.mul
      local.set 6
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      local.get 5
      i32.const 1
      i32.add
      local.set 5
      br 0 (;@1;)
    end
    local.get 6
  )
  (func (;2;) (type 4) (param eqref i32 i32) (result eqref)
    (local (ref 21) (ref 20) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 21)
    local.set 3
    local.get 3
    struct.get 21 2
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
    struct.get 21 0
    local.set 4
    local.get 3
    struct.get 21 1
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
      array.get 20
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
      array.get 20
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
    struct.get 21 1
    local.get 1
    i32.add
    local.get 2
    struct.new 23
  )
  (func (;3;) (type 5) (param eqref eqref) (result i32)
    (local (ref 23) (ref 23) (ref 20) (ref 20) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 23)
    local.set 2
    local.get 1
    ref.cast (ref 23)
    local.set 3
    local.get 2
    struct.get 23 2
    local.tee 6
    local.get 3
    struct.get 23 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 23 0
    local.set 4
    local.get 3
    struct.get 23 0
    local.set 5
    local.get 2
    struct.get 23 1
    local.set 7
    local.get 3
    struct.get 23 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 11
        end
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;4;) (type 6) (param eqref) (result i64)
    (local (ref 23) (ref 20) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 23)
    local.set 1
    local.get 1
    struct.get 23 0
    local.set 2
    local.get 1
    struct.get 23 1
    local.set 3
    local.get 1
    struct.get 23 2
    local.set 4
    i32.const 0
    local.set 5
    i64.const -3750763034362895579
    local.set 6
    loop ;; label = @1
      local.get 5
      local.get 4
      i32.ge_u
      if ;; label = @2
        local.get 6
        return
      end
      local.get 6
      local.get 2
      local.get 3
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 3
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i64.extend_i32_u
      i64.xor
      i64.const 1099511628211
      i64.mul
      local.set 6
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      local.get 5
      i32.const 1
      i32.add
      local.set 5
      br 0 (;@1;)
    end
    local.get 6
  )
  (func (;5;) (type 7) (param eqref eqref) (result i32)
    (local (ref 22) (ref 22) (ref 20) (ref 20) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 22)
    local.set 2
    local.get 1
    ref.cast (ref 22)
    local.set 3
    local.get 2
    struct.get 22 2
    local.tee 6
    local.get 3
    struct.get 22 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 22 0
    local.set 4
    local.get 3
    struct.get 22 0
    local.set 5
    local.get 2
    struct.get 22 1
    local.set 7
    local.get 3
    struct.get 22 1
    local.set 8
    i32.const 0
    local.set 9
    loop ;; label = @1
      local.get 9
      local.get 6
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 9
      i32.const 16
      i32.add
      local.get 6
      i32.le_u
      if ;; label = @2
        local.get 7
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 7
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 10
        end
        local.get 8
        i32.const 15
        i32.and
        i32.eqz
        if ;; label = @3
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i8x16.swizzle
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          i32.const 1
          i32.add
          array.get 20
          v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
          local.get 8
          i32.const 15
          i32.and
          i8x16.splat
          i8x16.add
          i32.const 16
          i8x16.splat
          i8x16.sub
          i8x16.swizzle
          v128.or
          local.set 11
        end
        local.get 10
        local.get 11
        v128.xor
        v128.any_true
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 7
        i32.const 16
        i32.add
        local.set 7
        local.get 8
        i32.const 16
        i32.add
        local.set 8
        local.get 9
        i32.const 16
        i32.add
        local.set 9
        br 1 (;@1;)
      end
      local.get 4
      local.get 7
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 7
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.get 5
      local.get 8
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 8
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i32.ne
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 7
      i32.const 1
      i32.add
      local.set 7
      local.get 8
      i32.const 1
      i32.add
      local.set 8
      local.get 9
      i32.const 1
      i32.add
      local.set 9
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;6;) (type 8) (param eqref) (result i64)
    (local (ref 22) (ref 20) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 22)
    local.set 1
    local.get 1
    struct.get 22 0
    local.set 2
    local.get 1
    struct.get 22 1
    local.set 3
    local.get 1
    struct.get 22 2
    local.set 4
    i32.const 0
    local.set 5
    i64.const -3750763034362895579
    local.set 6
    loop ;; label = @1
      local.get 5
      local.get 4
      i32.ge_u
      if ;; label = @2
        local.get 6
        return
      end
      local.get 6
      local.get 2
      local.get 3
      i32.const 4
      i32.shr_u
      array.get 20
      local.get 3
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i64.extend_i32_u
      i64.xor
      i64.const 1099511628211
      i64.mul
      local.set 6
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      local.get 5
      i32.const 1
      i32.add
      local.set 5
      br 0 (;@1;)
    end
    local.get 6
  )
  (func (;7;) (type 9) (param eqref) (result i64)
    local.get 0
    call 1
  )
  (func (;8;) (type 10) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;9;) (type 11) (param eqref) (result i64)
    local.get 0
    call 4
  )
  (func (;10;) (type 12) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;11;) (type 13) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 2
  )
  (func (;12;) (type 14) (param eqref) (result i64)
    local.get 0
    call 6
  )
  (func (;13;) (type 15) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;14;) (type 16) (result (ref 0))
    i32.const 16
    array.new_default 26
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;15;) (type 17) (result (ref 0))
    i32.const 16
    array.new_default 26
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;16;) (type 18) (result (ref 0))
    i32.const 16
    array.new_default 26
    i32.const 0
    struct.new 0
    ref.cast (ref 0)
  )
  (func (;17;) (type 19)
    (local eqref eqref eqref eqref eqref i64 eqref eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref eqref)
    array.new_fixed 20 0
    i32.const 0
    i32.const 0
    struct.new 21
    call 7
    i64.const -3750763034362895579
    i64.eq
    v128.const i32x4 0x74706d65 0x4e462079 0x666f2056 0x74657366
    array.new_fixed 20 1
    i32.const 0
    i32.const 16
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    call 7
    i64.const -3847715545455394385
    i64.eq
    v128.const i32x4 0x49435341 0x4e462049 0x00000056 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 9
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x0000bbce 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 2
    struct.new 21
    call 7
    i64.const 780254166137709982
    i64.eq
    v128.const i32x4 0x2d465455 0x79622038 0x46206574 0x0000564e
    array.new_fixed 20 1
    i32.const 0
    i32.const 14
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x0001ff00 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    call 12
    i64.const -2971257445883071021
    i64.eq
    v128.const i32x4 0x69627261 0x72617274 0x79622079 0x20736574
    v128.const i32x4 0x00564e46 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 19
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x77656478 0x00000021 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 5
    struct.new 21
    local.set 0
    local.get 0
    i32.const 1
    i32.const 3
    call 11
    local.set 0
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    i32.const 0
    i32.const 3
    call 11
    local.set 1
    local.get 0
    call 9
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    call 7
    i64.eq
    v128.const i32x4 0x77656976 0x646e6120 0x72745320 0x20676e69
    v128.const i32x4 0x65747962 0x72617020 0x00797469 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 27
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    call 9
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    call 12
    i64.eq
    v128.const i32x4 0x74786574 0x646e6120 0x74794220 0x62207365
    v128.const i32x4 0x20657479 0x69726170 0x00007974 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 26
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    local.get 1
    call 10
    v128.const i32x4 0x77656976 0x73616820 0x71652068 0x696c6175
    v128.const i32x4 0x00007974 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 18
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    v128.const i32x4 0x00766564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    i32.const 0
    i32.const 3
    call 11
    call 10
    i32.eqz
    v128.const i32x4 0x77656976 0x73616820 0x6e692068 0x61757165
    v128.const i32x4 0x7974696c 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 20
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 14
    local.set 2
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    local.set 9
    i32.const 7
    local.set 10
    local.get 9
    call 7
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          local.get 4
          ref.cast (ref 26)
          array.len
          local.set 8
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 3
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 26
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 4
                ref.cast (ref 26)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 4
                ref.cast (ref 26)
                local.get 8
                array.get 26
                local.set 6
                block ;; label = @7
                  loop ;; label = @8
                    local.get 6
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 0
                    local.set 7
                    local.get 6
                    ref.cast (ref 27)
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 26
                    struct.set 27 0
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 6
                    array.set 26
                    local.get 7
                    local.set 6
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 26)
            local.set 4
          end
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 26
          local.get 5
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 9
          local.get 10
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 27
          local.set 6
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 6
          array.set 26
          local.get 3
          ref.cast (ref 0)
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 9
          call 8
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            local.get 10
            struct.set 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x0000bbce 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 2
    struct.new 21
    local.set 11
    i32.const 8
    local.set 12
    local.get 11
    call 7
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          local.get 4
          ref.cast (ref 26)
          array.len
          local.set 8
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 3
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 26
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 4
                ref.cast (ref 26)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 4
                ref.cast (ref 26)
                local.get 8
                array.get 26
                local.set 6
                block ;; label = @7
                  loop ;; label = @8
                    local.get 6
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 0
                    local.set 7
                    local.get 6
                    ref.cast (ref 27)
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 26
                    struct.set 27 0
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 6
                    array.set 26
                    local.get 7
                    local.set 6
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 26)
            local.set 4
          end
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 26
          local.get 5
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 11
          local.get 12
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 27
          local.set 6
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 6
          array.set 26
          local.get 3
          ref.cast (ref 0)
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 11
          call 8
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            local.get 12
            struct.set 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 21
    local.set 13
    local.get 13
    call 7
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 13
          call 8
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            struct.get 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 7
    i32.eq
    v128.const i32x4 0x69727453 0x6d20676e 0x6c207061 0x756b6f6f
    v128.const i32x4 0x00000070 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 17
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x0000bbce 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 2
    struct.new 21
    local.set 15
    local.get 15
    call 7
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 15
          call 8
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            struct.get 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 8
    i32.eq
    v128.const i32x4 0x63696e55 0x2065646f 0x69727453 0x6d20676e
    v128.const i32x4 0x6c207061 0x756b6f6f 0x00000070 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 25
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 15
    local.set 2
    local.get 0
    local.set 17
    i32.const 9
    local.set 18
    local.get 17
    call 9
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          local.get 4
          ref.cast (ref 26)
          array.len
          local.set 8
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 3
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 26
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 4
                ref.cast (ref 26)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 4
                ref.cast (ref 26)
                local.get 8
                array.get 26
                local.set 6
                block ;; label = @7
                  loop ;; label = @8
                    local.get 6
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 0
                    local.set 7
                    local.get 6
                    ref.cast (ref 27)
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 26
                    struct.set 27 0
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 6
                    array.set 26
                    local.get 7
                    local.set 6
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 26)
            local.set 4
          end
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 26
          local.get 5
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 17
          local.get 18
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 27
          local.set 6
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 6
          array.set 26
          local.get 3
          ref.cast (ref 0)
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 17
          call 10
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            local.get 18
            struct.set 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    local.get 1
    local.set 19
    local.get 19
    call 9
    local.set 5
    local.get 2
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 19
          call 10
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            struct.get 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 9
    i32.eq
    v128.const i32x4 0x69727453 0x6956676e 0x6d207765 0x6c207061
    v128.const i32x4 0x756b6f6f 0x79622070 0x75716520 0x72206c61
    v128.const i32x4 0x65676e61 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 3
    i32.const 0
    i32.const 36
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 16
    local.set 0
    v128.const i32x4 0x0001ff00 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    local.set 21
    i32.const 10
    local.set 22
    local.get 21
    call 12
    local.set 5
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          local.get 4
          ref.cast (ref 26)
          array.len
          local.set 8
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          local.get 8
          i32.gt_u
          local.get 8
          i32.const 1073741824
          i32.lt_u
          i32.and
          if ;; label = @4
            local.get 3
            ref.cast (ref 0)
            local.get 8
            i32.const 1
            i32.shl
            array.new_default 26
            struct.set 0 0
            i32.const 0
            local.set 8
            block ;; label = @5
              loop ;; label = @6
                local.get 8
                local.get 4
                ref.cast (ref 26)
                array.len
                i32.ge_u
                br_if 1 (;@5;)
                local.get 4
                ref.cast (ref 26)
                local.get 8
                array.get 26
                local.set 6
                block ;; label = @7
                  loop ;; label = @8
                    local.get 6
                    ref.is_null
                    br_if 1 (;@7;)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 0
                    local.set 7
                    local.get 6
                    ref.cast (ref 27)
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    array.get 26
                    struct.set 27 0
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    local.get 6
                    ref.cast (ref 27)
                    struct.get 27 1
                    i32.wrap_i64
                    local.get 3
                    ref.cast (ref 0)
                    struct.get 0 0
                    ref.cast (ref 26)
                    array.len
                    i32.const 1
                    i32.sub
                    i32.and
                    local.get 6
                    array.set 26
                    local.get 7
                    local.set 6
                    br 0 (;@8;)
                  end
                end
                local.get 8
                i32.const 1
                i32.add
                local.set 8
                br 0 (;@6;)
              end
            end
            local.get 3
            ref.cast (ref 0)
            struct.get 0 0
            ref.cast (ref 26)
            local.set 4
          end
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          array.get 26
          local.get 5
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 21
          local.get 22
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 27
          local.set 6
          local.get 4
          ref.cast (ref 26)
          local.get 5
          i32.wrap_i64
          local.get 4
          ref.cast (ref 26)
          array.len
          i32.const 1
          i32.sub
          i32.and
          local.get 6
          array.set 26
          local.get 3
          ref.cast (ref 0)
          local.get 3
          ref.cast (ref 0)
          struct.get 0 1
          i32.const 1
          i32.add
          struct.set 0 1
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 21
          call 13
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            local.get 22
            struct.set 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x0001ff00 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    local.set 23
    local.get 23
    call 12
    local.set 5
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 0)
    struct.get 0 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          unreachable
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 23
          call 13
          if ;; label = @4
            local.get 6
            ref.cast (ref 27)
            struct.get 27 8
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    i32.const 10
    i32.eq
    v128.const i32x4 0x65747942 0x616d2073 0x6f6c2070 0x70756b6f
    array.new_fixed 20 1
    i32.const 0
    i32.const 16
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    local.set 25
    local.get 25
    call 12
    local.set 5
    i32.const 16
    array.new_default 26
    local.set 4
    ref.null eq
    local.get 5
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    local.get 25
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 27
    local.set 6
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    local.get 6
    array.set 26
    local.get 4
    i32.const 1
    struct.new 1
    local.set 0
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 1
    i32.const 0
    i32.const 3
    struct.new 22
    local.set 26
    local.get 26
    call 12
    local.set 5
    local.get 0
    local.set 3
    local.get 3
    ref.cast (ref 1)
    struct.get 1 0
    ref.cast (ref 26)
    local.set 4
    local.get 4
    ref.cast (ref 26)
    local.get 5
    i32.wrap_i64
    local.get 4
    ref.cast (ref 26)
    array.len
    i32.const 1
    i32.sub
    i32.and
    array.get 26
    local.set 6
    block (result i32) ;; label = @1
      loop ;; label = @2
        local.get 6
        ref.is_null
        if ;; label = @3
          i32.const 0
          br 2 (;@1;)
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 1
        local.get 5
        i64.eq
        if ;; label = @3
          local.get 6
          ref.cast (ref 27)
          struct.get 27 7
          local.get 26
          call 13
          if ;; label = @4
            i32.const 1
            br 3 (;@1;)
          end
        end
        local.get 6
        ref.cast (ref 27)
        struct.get 27 0
        local.set 6
        br 0 (;@2;)
      end
      unreachable
    end
    v128.const i32x4 0x65747942 0x65732073 0x656d2074 0x7265626d
    v128.const i32x4 0x70696873 0x00000000 0x00000000 0x00000000
    array.new_fixed 20 2
    i32.const 0
    i32.const 20
    struct.new 21
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
