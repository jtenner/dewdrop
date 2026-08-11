(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (param eqref i32 i32) (result eqref)))
  (type (;2;) (func (result eqref)))
  (type (;3;) (func (param eqref eqref)))
  (type (;4;) (func (param eqref eqref)))
  (type (;5;) (func (param eqref i32)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (param eqref eqref) (result i32)))
  (type (;8;) (func (param eqref i32 i32) (result eqref)))
  (type (;9;) (func (result eqref)))
  (type (;10;) (func (param eqref eqref)))
  (type (;11;) (func (param eqref eqref)))
  (type (;12;) (func (param eqref i32)))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param i64) (result i32)))
  (type (;18;) (func (param i32) (result i64)))
  (type (;19;) (func (param i32) (result i64)))
  (type (;20;) (func (param i32) (result i64)))
  (type (;21;) (func (param i32) (result i64)))
  (type (;22;) (func (param i32) (result i64)))
  (type (;23;) (func (param i32) (result i64)))
  (type (;24;) (func (param i64) (result i64)))
  (type (;25;) (func (param eqref i64)))
  (type (;26;) (func (param eqref i64)))
  (type (;27;) (func (param i32 eqref)))
  (type (;28;) (func (param i32 eqref)))
  (type (;29;) (func (param i32 eqref)))
  (type (;30;) (func (param i32 eqref)))
  (type (;31;) (func (param i64 eqref)))
  (type (;32;) (func (param i32 eqref)))
  (type (;33;) (func (param i32 eqref)))
  (type (;34;) (func (param i32 eqref)))
  (type (;35;) (func (param i64 eqref)))
  (type (;36;) (func (param eqref eqref)))
  (type (;37;) (func (param eqref eqref)))
  (type (;38;) (func (param eqref i32)))
  (type (;39;) (func (param eqref i64)))
  (type (;40;) (func (param i32) (result eqref)))
  (type (;41;) (func (param i32) (result eqref)))
  (type (;42;) (func (param i32) (result eqref)))
  (type (;43;) (func (param i32) (result eqref)))
  (type (;44;) (func (param i64) (result eqref)))
  (type (;45;) (func (param i32) (result eqref)))
  (type (;46;) (func (param i32) (result eqref)))
  (type (;47;) (func (param i32) (result eqref)))
  (type (;48;) (func (param i64) (result eqref)))
  (type (;49;) (func (param eqref) (result eqref)))
  (type (;50;) (func (param eqref) (result eqref)))
  (type (;51;) (func (param eqref) (result eqref)))
  (type (;52;) (struct (field i32) (field i64)))
  (type (;53;) (func (param (ref 52) eqref)))
  (type (;54;) (func (param eqref eqref)))
  (type (;55;) (func))
  (type (;56;) (func (param i32 eqref)))
  (type (;57;) (func (param i32 eqref)))
  (type (;58;) (func (param i32 eqref)))
  (type (;59;) (func (param i32 eqref)))
  (type (;60;) (func (param i64 eqref)))
  (type (;61;) (func (param i32 eqref)))
  (type (;62;) (func (param i32 eqref)))
  (type (;63;) (func (param i32 eqref)))
  (type (;64;) (func (param i64 eqref)))
  (type (;65;) (func (param eqref eqref)))
  (type (;66;) (func (param eqref eqref)))
  (type (;67;) (func (param eqref eqref)))
  (type (;68;) (array (mut v128)))
  (type (;69;) (struct (field (ref 68)) (field i32) (field i32)))
  (type (;70;) (struct (field (ref 68)) (field i32) (field i32)))
  (type (;71;) (struct (field (ref 68)) (field i32) (field i32)))
  (type (;72;) (struct (field (mut (ref 68))) (field (mut i32)) (field (mut i32))))
  (type (;73;) (struct (field (mut (ref 68))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 51))
  (func (;0;) (type 0) (param eqref eqref) (result i32)
    (local (ref 69) (ref 69) (ref 68) (ref 68) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 69)
    local.set 2
    local.get 1
    ref.cast (ref 69)
    local.set 3
    local.get 2
    struct.get 69 2
    local.tee 6
    local.get 3
    struct.get 69 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 69 0
    local.set 4
    local.get 3
    struct.get 69 0
    local.set 5
    local.get 2
    struct.get 69 1
    local.set 7
    local.get 3
    struct.get 69 1
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
          array.get 68
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 68
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
          array.get 68
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
          array.get 68
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 68
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
          array.get 68
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
      array.get 68
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
      array.get 68
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
  (func (;1;) (type 1) (param eqref i32 i32) (result eqref)
    (local (ref 69) (ref 68) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 69)
    local.set 3
    local.get 3
    struct.get 69 2
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
    struct.get 69 0
    local.set 4
    local.get 3
    struct.get 69 1
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
      array.get 68
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
      array.get 68
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
    struct.get 69 1
    local.get 1
    i32.add
    local.get 2
    struct.new 71
  )
  (func (;2;) (type 2) (result eqref)
    i32.const 4
    array.new_default 68
    i32.const 0
    i32.const 0
    struct.new 72
  )
  (func (;3;) (type 3) (param eqref eqref)
    (local (ref 72) (ref 69) (ref 68) (ref 68) i32 i32 i32 i32 i32 i32 (ref 68) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 72)
    local.set 2
    local.get 2
    struct.get 72 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 69)
    local.set 3
    local.get 2
    struct.get 72 0
    local.set 4
    local.get 3
    struct.get 69 0
    local.set 5
    local.get 2
    struct.get 72 1
    local.set 6
    local.get 3
    struct.get 69 1
    local.set 7
    local.get 3
    struct.get 69 2
    local.set 8
    local.get 6
    local.get 8
    i32.add
    local.tee 9
    local.get 6
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 9
    i32.const 4
    i32.shr_u
    local.get 9
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    local.set 10
    local.get 4
    array.len
    local.set 11
    local.get 10
    local.get 11
    i32.gt_u
    if ;; label = @1
      local.get 11
      i32.const 1
      i32.shl
      local.set 11
      local.get 11
      local.get 10
      i32.lt_u
      if ;; label = @2
        local.get 10
        local.set 11
      end
      local.get 11
      array.new_default 68
      local.set 12
      i32.const 0
      local.set 13
      block ;; label = @2
        loop ;; label = @3
          local.get 13
          local.get 6
          i32.const 4
          i32.shr_u
          local.get 6
          i32.const 15
          i32.and
          i32.const 0
          i32.ne
          i32.add
          i32.ge_u
          br_if 1 (;@2;)
          local.get 12
          local.get 13
          local.get 4
          local.get 13
          array.get 68
          array.set 68
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 72 0
      local.get 12
      local.set 4
    end
    i32.const 0
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        local.get 14
        local.get 8
        i32.ge_u
        br_if 1 (;@1;)
        local.get 7
        local.get 14
        i32.add
        local.set 15
        local.get 6
        local.get 14
        i32.add
        local.set 16
        local.get 14
        i32.const 16
        i32.add
        local.get 8
        i32.le_u
        if ;; label = @3
          local.get 15
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 68
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 68
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 68
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i32.const 16
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            v128.or
            local.set 18
          end
          local.get 16
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 18
            array.set 68
          else
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.lt_u
            local.set 19
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            array.get 68
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            local.get 19
            v128.bitselect
            array.set 68
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            i32.const 16
            local.get 16
            i32.const 15
            i32.and
            i32.sub
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 68
            local.get 19
            v128.bitselect
            array.set 68
          end
          local.get 14
          i32.const 16
          i32.add
          local.set 14
          br 1 (;@2;)
        end
        local.get 5
        local.get 15
        i32.const 4
        i32.shr_u
        array.get 68
        local.get 15
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 17
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        local.get 17
        i8x16.splat
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        array.get 68
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 68
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 72 1
  )
  (func (;4;) (type 4) (param eqref eqref)
    (local (ref 72) (ref 71) (ref 68) (ref 68) i32 i32 i32 i32 i32 i32 (ref 68) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 72)
    local.set 2
    local.get 2
    struct.get 72 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 71)
    local.set 3
    local.get 2
    struct.get 72 0
    local.set 4
    local.get 3
    struct.get 71 0
    local.set 5
    local.get 2
    struct.get 72 1
    local.set 6
    local.get 3
    struct.get 71 1
    local.set 7
    local.get 3
    struct.get 71 2
    local.set 8
    local.get 6
    local.get 8
    i32.add
    local.tee 9
    local.get 6
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 9
    i32.const 4
    i32.shr_u
    local.get 9
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    local.set 10
    local.get 4
    array.len
    local.set 11
    local.get 10
    local.get 11
    i32.gt_u
    if ;; label = @1
      local.get 11
      i32.const 1
      i32.shl
      local.set 11
      local.get 11
      local.get 10
      i32.lt_u
      if ;; label = @2
        local.get 10
        local.set 11
      end
      local.get 11
      array.new_default 68
      local.set 12
      i32.const 0
      local.set 13
      block ;; label = @2
        loop ;; label = @3
          local.get 13
          local.get 6
          i32.const 4
          i32.shr_u
          local.get 6
          i32.const 15
          i32.and
          i32.const 0
          i32.ne
          i32.add
          i32.ge_u
          br_if 1 (;@2;)
          local.get 12
          local.get 13
          local.get 4
          local.get 13
          array.get 68
          array.set 68
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 72 0
      local.get 12
      local.set 4
    end
    i32.const 0
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        local.get 14
        local.get 8
        i32.ge_u
        br_if 1 (;@1;)
        local.get 7
        local.get 14
        i32.add
        local.set 15
        local.get 6
        local.get 14
        i32.add
        local.set 16
        local.get 14
        i32.const 16
        i32.add
        local.get 8
        i32.le_u
        if ;; label = @3
          local.get 15
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 68
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 68
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 68
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 15
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.add
            i32.const 16
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            v128.or
            local.set 18
          end
          local.get 16
          i32.const 15
          i32.and
          i32.eqz
          if ;; label = @4
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 18
            array.set 68
          else
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.lt_u
            local.set 19
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            array.get 68
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            local.get 16
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.sub
            i8x16.swizzle
            local.get 19
            v128.bitselect
            array.set 68
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            local.get 18
            v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
            i32.const 16
            local.get 16
            i32.const 15
            i32.and
            i32.sub
            i8x16.splat
            i8x16.add
            i8x16.swizzle
            local.get 4
            local.get 16
            i32.const 4
            i32.shr_u
            i32.const 1
            i32.add
            array.get 68
            local.get 19
            v128.bitselect
            array.set 68
          end
          local.get 14
          i32.const 16
          i32.add
          local.set 14
          br 1 (;@2;)
        end
        local.get 5
        local.get 15
        i32.const 4
        i32.shr_u
        array.get 68
        local.get 15
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 17
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        local.get 17
        i8x16.splat
        local.get 4
        local.get 16
        i32.const 4
        i32.shr_u
        array.get 68
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 68
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 72 1
  )
  (func (;5;) (type 5) (param eqref i32)
    (local (ref 72) (ref 68) i32 i32 i32 (ref 68) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 72)
    local.set 2
    local.get 2
    struct.get 72 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 72 0
    local.set 3
    local.get 2
    struct.get 72 1
    local.tee 4
    i32.const 1
    i32.add
    local.tee 5
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 3
    array.len
    local.set 6
    local.get 5
    local.get 6
    i32.const 4
    i32.shl
    i32.gt_u
    if ;; label = @1
      local.get 6
      i32.const 1
      i32.shl
      local.set 6
      local.get 6
      i32.eqz
      if ;; label = @2
        i32.const 1
        local.set 6
      end
      local.get 6
      array.new_default 68
      local.set 7
      i32.const 0
      local.set 8
      block ;; label = @2
        loop ;; label = @3
          local.get 8
          local.get 4
          i32.const 4
          i32.shr_u
          local.get 4
          i32.const 15
          i32.and
          i32.const 0
          i32.ne
          i32.add
          i32.ge_u
          br_if 1 (;@2;)
          local.get 7
          local.get 8
          local.get 3
          local.get 8
          array.get 68
          array.set 68
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 72 0
      local.get 7
      local.set 3
    end
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    local.get 1
    i8x16.splat
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 68
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 68
    local.get 2
    local.get 5
    struct.set 72 1
  )
  (func (;6;) (type 6) (param eqref) (result eqref)
    (local (ref 72))
    local.get 0
    ref.cast (ref 72)
    local.set 1
    local.get 1
    struct.get 72 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 72 2
    local.get 1
    struct.get 72 0
    i32.const 0
    local.get 1
    struct.get 72 1
    struct.new 69
  )
  (func (;7;) (type 7) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;8;) (type 8) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 1
  )
  (func (;9;) (type 9) (result eqref)
    call 2
  )
  (func (;10;) (type 10) (param eqref eqref)
    local.get 0
    local.get 1
    call 3
  )
  (func (;11;) (type 11) (param eqref eqref)
    local.get 0
    local.get 1
    call 4
  )
  (func (;12;) (type 12) (param eqref i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;13;) (type 13) (param eqref) (result eqref)
    local.get 0
    call 6
  )
  (func (;14;) (type 16) (param eqref i32)
    local.get 0
    local.get 1
    call 12
  )
  (func (;15;) (type 17) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;16;) (type 18) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;17;) (type 19) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;18;) (type 20) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;19;) (type 21) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;20;) (type 22) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;21;) (type 23) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;22;) (type 24) (param i64) (result i64)
    local.get 0
  )
  (func (;23;) (type 25) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 23
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 15
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 12
  )
  (func (;24;) (type 26) (param eqref i64)
    (local i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 12
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 22
      i64.const 1
      i64.add
      local.set 2
      local.get 0
      local.get 2
      call 23
    else
      local.get 0
      local.get 1
      call 22
      call 23
    end
  )
  (func (;25;) (type 27) (param i32 eqref)
    local.get 0
    if ;; label = @1
      local.get 1
      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
      array.new_fixed 68 1
      i32.const 0
      i32.const 4
      struct.new 69
      call 10
    else
      local.get 1
      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
      array.new_fixed 68 1
      i32.const 0
      i32.const 5
      struct.new 69
      call 10
    end
  )
  (func (;26;) (type 28) (param i32 eqref)
    local.get 1
    local.get 0
    call 16
    call 24
  )
  (func (;27;) (type 29) (param i32 eqref)
    local.get 1
    local.get 0
    call 17
    call 24
  )
  (func (;28;) (type 30) (param i32 eqref)
    local.get 1
    local.get 0
    call 18
    call 24
  )
  (func (;29;) (type 31) (param i64 eqref)
    local.get 1
    local.get 0
    call 24
  )
  (func (;30;) (type 32) (param i32 eqref)
    local.get 1
    local.get 0
    call 19
    call 23
  )
  (func (;31;) (type 33) (param i32 eqref)
    local.get 1
    local.get 0
    call 20
    call 23
  )
  (func (;32;) (type 34) (param i32 eqref)
    local.get 1
    local.get 0
    call 21
    call 23
  )
  (func (;33;) (type 35) (param i64 eqref)
    local.get 1
    local.get 0
    call 23
  )
  (func (;34;) (type 36) (param eqref eqref)
    local.get 1
    local.get 0
    call 10
  )
  (func (;35;) (type 37) (param eqref eqref)
    local.get 1
    local.get 0
    call 11
  )
  (func (;36;) (type 38) (param eqref i32)
    local.get 1
    local.get 0
    call 28
  )
  (func (;37;) (type 39) (param eqref i64)
    local.get 1
    local.get 0
    call 33
  )
  (func (;38;) (type 40) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 25
    local.get 1
    call 13
  )
  (func (;39;) (type 41) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 26
    local.get 1
    call 13
  )
  (func (;40;) (type 42) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 27
    local.get 1
    call 13
  )
  (func (;41;) (type 43) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 28
    local.get 1
    call 13
  )
  (func (;42;) (type 44) (param i64) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 29
    local.get 1
    call 13
  )
  (func (;43;) (type 45) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 30
    local.get 1
    call 13
  )
  (func (;44;) (type 46) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 31
    local.get 1
    call 13
  )
  (func (;45;) (type 47) (param i32) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 32
    local.get 1
    call 13
  )
  (func (;46;) (type 48) (param i64) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 33
    local.get 1
    call 13
  )
  (func (;47;) (type 49) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 34
    local.get 1
    call 13
  )
  (func (;48;) (type 50) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    local.get 1
    call 35
    local.get 1
    call 13
  )
  (func (;49;) (type 51) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 0
    ref.cast (ref 52)
    local.get 1
    call 50
    local.get 1
    call 13
  )
  (func (;50;) (type 53) (param (ref 52) eqref)
    local.get 1
    i32.const 40
    call 14
    local.get 1
    local.get 0
    struct.get 52 0
    call 36
    local.get 1
    i32.const 44
    call 14
    local.get 1
    local.get 0
    struct.get 52 1
    call 37
    local.get 1
    i32.const 41
    call 14
  )
  (func (;51;) (type 55)
    i32.const 1
    v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 4
    struct.new 69
    call 52
    i32.const 0
    v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 5
    struct.new 69
    call 52
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    v128.const i32x4 0x3832312d 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 4
    struct.new 69
    call 53
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    v128.const i32x4 0x3732332d 0x00003836 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 6
    struct.new 69
    call 54
    i32.const 0
    i32.const -2147483648
    i32.sub
    v128.const i32x4 0x3431322d 0x33383437 0x00383436 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    call 55
    i64.const 0
    i64.const -9223372036854775808
    i64.sub
    v128.const i32x4 0x3232392d 0x32373333 0x38363330 0x37373435
    v128.const i32x4 0x38303835 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 2
    i32.const 0
    i32.const 20
    struct.new 69
    call 56
    i32.const 255
    v128.const i32x4 0x00353532 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 3
    struct.new 69
    call 57
    i32.const 65535
    v128.const i32x4 0x33353536 0x00000035 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 5
    struct.new 69
    call 58
    i32.const -1
    v128.const i32x4 0x34393234 0x32373639 0x00003539 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 10
    struct.new 69
    call 59
    i64.const -1
    v128.const i32x4 0x34343831 0x34343736 0x37333730 0x35353930
    v128.const i32x4 0x35313631 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 2
    i32.const 0
    i32.const 20
    struct.new 69
    call 60
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 3
    struct.new 69
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 3
    struct.new 69
    call 61
    v128.const i32x4 0x64636261 0x00006665 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 6
    struct.new 69
    i32.const 1
    i32.const 3
    call 8
    v128.const i32x4 0x00646362 0x00000000 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 3
    struct.new 69
    call 62
    i32.const 0
    i32.const 42
    i32.sub
    i64.const 99
    struct.new 52
    v128.const i32x4 0x32342d28 0x2939392c 0x00000000 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 8
    struct.new 69
    call 63
  )
  (func (;52;) (type 56) (param i32 eqref)
    local.get 0
    call 38
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;53;) (type 57) (param i32 eqref)
    local.get 0
    call 39
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;54;) (type 58) (param i32 eqref)
    local.get 0
    call 40
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;55;) (type 59) (param i32 eqref)
    local.get 0
    call 41
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;56;) (type 60) (param i64 eqref)
    local.get 0
    call 42
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;57;) (type 61) (param i32 eqref)
    local.get 0
    call 43
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;58;) (type 62) (param i32 eqref)
    local.get 0
    call 44
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;59;) (type 63) (param i32 eqref)
    local.get 0
    call 45
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;60;) (type 64) (param i64 eqref)
    local.get 0
    call 46
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;61;) (type 65) (param eqref eqref)
    local.get 0
    call 47
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;62;) (type 66) (param eqref eqref)
    local.get 0
    call 48
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;63;) (type 67) (param eqref eqref)
    local.get 0
    call 49
    local.get 1
    call 7
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 68 1
    i32.const 0
    i32.const 11
    struct.new 69
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
