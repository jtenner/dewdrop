(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field funcref))))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref i32) (result eqref)))
  (type (;11;) (func (param eqref eqref) (result eqref)))
  (type (;12;) (func (param eqref)))
  (type (;13;) (func (param eqref i32)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref i32) (result i32)))
  (type (;16;) (func (param eqref eqref i32) (result eqref)))
  (type (;17;) (func (param eqref eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref eqref)))
  (type (;19;) (func (param eqref eqref i32)))
  (type (;20;) (func (param eqref eqref) (result i32)))
  (type (;21;) (func (param eqref eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (result eqref)))
  (type (;26;) (func (param eqref) (result i32)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref i32)))
  (type (;29;) (func (param eqref) (result eqref)))
  (type (;30;) (func (param eqref) (result i32)))
  (type (;31;) (func (param eqref eqref) (result i32)))
  (type (;32;) (func (param i64) (result i32)))
  (type (;33;) (func (param i64) (result i64)))
  (type (;34;) (func (param eqref i64)))
  (type (;35;) (func (param eqref i64)))
  (type (;36;) (func (result eqref)))
  (type (;37;) (func (param eqref) (result i32)))
  (type (;38;) (func (param eqref eqref)))
  (type (;39;) (func (param eqref i64)))
  (type (;40;) (func (param eqref) (result eqref)))
  (type (;41;) (struct (field eqref) (field i32)))
  (type (;42;) (func (param (ref 41) i32)))
  (type (;43;) (func (param eqref) (result eqref)))
  (type (;44;) (func (param (ref 41))))
  (type (;45;) (func (param (ref 41) eqref)))
  (type (;46;) (func (param (ref 41) eqref)))
  (type (;47;) (func (param i32) (result i64)))
  (type (;48;) (func (param i64) (result i64)))
  (type (;49;) (func (param i64) (result i32)))
  (type (;50;) (func (param i64) (result i32)))
  (type (;51;) (func (param (ref 41) i64)))
  (type (;52;) (func (param i32 (ref 41))))
  (type (;53;) (func (param eqref) (result eqref)))
  (type (;54;) (func (param (ref 41) eqref)))
  (type (;55;) (func (param (ref 41) i32)))
  (type (;56;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;57;) (func (param (ref 56) (ref 41))))
  (type (;58;) (func (param eqref) (result (ref 56))))
  (type (;59;) (func (param i32) (result (ref 56))))
  (type (;60;) (func (param (ref 56) (ref 41))))
  (type (;61;) (func))
  (type (;62;) (array (mut v128)))
  (type (;63;) (struct (field (ref 62)) (field i32) (field i32)))
  (type (;64;) (struct (field (ref 62)) (field i32) (field i32)))
  (type (;65;) (struct (field (ref 62)) (field i32) (field i32)))
  (type (;66;) (struct (field (mut (ref 62))) (field (mut i32)) (field (mut i32))))
  (type (;67;) (struct (field (mut (ref 62))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 32))
  (func (;0;) (type 23) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 63)
    struct.get 63 2
  )
  (func (;1;) (type 24) (param eqref eqref) (result i32)
    (local (ref 63) (ref 63) (ref 62) (ref 62) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 63)
    local.set 2
    local.get 1
    ref.cast (ref 63)
    local.set 3
    local.get 2
    struct.get 63 2
    local.tee 6
    local.get 3
    struct.get 63 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 63 0
    local.set 4
    local.get 3
    struct.get 63 0
    local.set 5
    local.get 2
    struct.get 63 1
    local.set 7
    local.get 3
    struct.get 63 1
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
          array.get 62
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 62
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
          array.get 62
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
          array.get 62
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 62
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
          array.get 62
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
      array.get 62
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
      array.get 62
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
  (func (;2;) (type 25) (result eqref)
    i32.const 4
    array.new_default 62
    i32.const 0
    i32.const 0
    struct.new 66
  )
  (func (;3;) (type 26) (param eqref) (result i32)
    (local (ref 66))
    local.get 0
    ref.cast (ref 66)
    local.tee 1
    struct.get 66 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 66 1
  )
  (func (;4;) (type 27) (param eqref eqref)
    (local (ref 66) (ref 63) (ref 62) (ref 62) i32 i32 i32 i32 i32 i32 (ref 62) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 66)
    local.set 2
    local.get 2
    struct.get 66 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 63)
    local.set 3
    local.get 2
    struct.get 66 0
    local.set 4
    local.get 3
    struct.get 63 0
    local.set 5
    local.get 2
    struct.get 66 1
    local.set 6
    local.get 3
    struct.get 63 1
    local.set 7
    local.get 3
    struct.get 63 2
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
      array.new_default 62
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
          array.get 62
          array.set 62
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 66 0
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
            array.get 62
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 62
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
            array.get 62
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
            array.set 62
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
            array.get 62
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
            array.set 62
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
            array.get 62
            local.get 19
            v128.bitselect
            array.set 62
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
        array.get 62
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
        array.get 62
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 62
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 66 1
  )
  (func (;5;) (type 28) (param eqref i32)
    (local (ref 66) (ref 62) i32 i32 i32 (ref 62) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 66)
    local.set 2
    local.get 2
    struct.get 66 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 66 0
    local.set 3
    local.get 2
    struct.get 66 1
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
      array.new_default 62
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
          array.get 62
          array.set 62
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 66 0
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
    array.get 62
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 62
    local.get 2
    local.get 5
    struct.set 66 1
  )
  (func (;6;) (type 29) (param eqref) (result eqref)
    (local (ref 66))
    local.get 0
    ref.cast (ref 66)
    local.set 1
    local.get 1
    struct.get 66 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 66 2
    local.get 1
    struct.get 66 0
    i32.const 0
    local.get 1
    struct.get 66 1
    struct.new 63
  )
  (func (;7;) (type 30) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;8;) (type 31) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;9;) (type 32) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;10;) (type 33) (param i64) (result i64)
    local.get 0
  )
  (func (;11;) (type 34) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 11
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 9
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 5
  )
  (func (;12;) (type 35) (param eqref i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 5
      local.get 0
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 10
      i64.const 1
      i64.add
      call 11
    else
      local.get 0
      local.get 1
      call 10
      call 11
    end
  )
  (func (;13;) (type 36) (result eqref)
    call 2
  )
  (func (;14;) (type 37) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;15;) (type 38) (param eqref eqref)
    local.get 0
    local.get 1
    call 4
  )
  (func (;16;) (type 39) (param eqref i64)
    local.get 0
    local.get 1
    call 12
  )
  (func (;17;) (type 40) (param eqref) (result eqref)
    local.get 0
    call 6
  )
  (func (;18;) (type 42) (param (ref 41) i32)
    (local i32)
    local.get 0
    struct.get 41 0
    call 14
    local.set 2
    local.get 2
    i32.const 1048576
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const 1048576
      local.get 2
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;19;) (type 44) (param (ref 41))
    local.get 0
    struct.get 41 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;20;) (type 46) (param (ref 41) eqref)
    local.get 0
    local.get 1
    call 7
    call 18
    local.get 0
    struct.get 41 0
    local.get 1
    call 15
  )
  (func (;21;) (type 47) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;22;) (type 48) (param i64) (result i64)
    local.get 0
  )
  (func (;23;) (type 49) (param i64) (result i32)
    local.get 0
    i64.const 10
    i64.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      i32.const 1
      local.get 0
      i64.const 10
      i64.div_u
      call 23
      i32.add
    end
  )
  (func (;24;) (type 50) (param i64) (result i32)
    local.get 0
    i64.const 0
    i64.lt_s
    if (result i32) ;; label = @1
      i32.const 1
      i64.const 0
      local.get 0
      i64.const 1
      i64.add
      i64.sub
      call 22
      i64.const 1
      i64.add
      call 23
      i32.add
    else
      local.get 0
      call 22
      call 23
    end
  )
  (func (;25;) (type 51) (param (ref 41) i64)
    local.get 0
    local.get 1
    call 24
    call 18
    local.get 0
    struct.get 41 0
    local.get 1
    call 16
  )
  (func (;26;) (type 52) (param i32 (ref 41))
    local.get 1
    local.get 0
    call 21
    call 25
  )
  (func (;27;) (type 53) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 41
    local.get 0
    call 28
    local.get 1
    call 17
  )
  (func (;28;) (type 54) (param (ref 41) eqref)
    local.get 0
    ref.cast (ref 41)
    call 19
    local.get 1
    ref.cast (ref 56)
    local.get 0
    struct.get 41 0
    local.get 0
    struct.get 41 1
    i32.const 1
    i32.add
    struct.new 41
    call 31
  )
  (func (;29;) (type 55) (param (ref 41) i32)
    local.get 0
    ref.cast (ref 41)
    call 19
    local.get 1
    local.get 0
    struct.get 41 0
    local.get 0
    struct.get 41 1
    i32.const 1
    i32.add
    struct.new 41
    call 26
  )
  (func (;30;) (type 59) (param i32) (result (ref 56))
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 56
    ref.cast (ref 56)
  )
  (func (;31;) (type 60) (param (ref 56) (ref 41))
    local.get 1
    ref.cast (ref 41)
    v128.const i32x4 0x20786f42 0x0000207b 0x00000000 0x00000000
    array.new_fixed 62 1
    i32.const 0
    i32.const 6
    struct.new 63
    call 20
    local.get 1
    ref.cast (ref 41)
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 62 1
    i32.const 0
    i32.const 7
    struct.new 63
    call 20
    local.get 1
    ref.cast (ref 41)
    local.get 0
    struct.get 56 0
    call 29
    local.get 1
    ref.cast (ref 41)
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 62 1
    i32.const 0
    i32.const 2
    struct.new 63
    call 20
  )
  (func (;32;) (type 61)
    i32.const 7
    call 30
    call 27
    v128.const i32x4 0x20786f42 0x6176207b 0x3a65756c 0x7d203720
    array.new_fixed 62 1
    i32.const 0
    i32.const 16
    struct.new 63
    call 8
    v128.const i32x4 0x6f706d69 0x64657472 0x72656420 0x64657669
    v128.const i32x4 0x6f685320 0x00000077 0x00000000 0x00000000
    array.new_fixed 62 2
    i32.const 0
    i32.const 21
    struct.new 63
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
