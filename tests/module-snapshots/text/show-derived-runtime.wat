(module
  (type (;0;) (func (param eqref) (result i32)))
  (type (;1;) (func (param eqref eqref) (result i32)))
  (type (;2;) (func (result eqref)))
  (type (;3;) (func (param eqref) (result i32)))
  (type (;4;) (func (param eqref eqref)))
  (type (;5;) (func (param eqref i32)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (func (param eqref eqref) (result i32)))
  (type (;9;) (func (result eqref)))
  (type (;10;) (func (param eqref) (result i32)))
  (type (;11;) (func (param eqref eqref)))
  (type (;12;) (func (param eqref i32)))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (struct (field eqref) (field i32)))
  (type (;15;) (func (param (ref 14) i32)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param (ref 14))))
  (type (;18;) (func (param (ref 14) eqref)))
  (type (;19;) (func (param (ref 14) eqref)))
  (type (;20;) (func (param (ref 14) i32)))
  (type (;21;) (func (param i64) (result i32)))
  (type (;22;) (func (param i32) (result i64)))
  (type (;23;) (func (param i64) (result i64)))
  (type (;24;) (func (param (ref 14) i64)))
  (type (;25;) (func (param (ref 14) i64)))
  (type (;26;) (func (param i32 (ref 14))))
  (type (;27;) (func (param eqref (ref 14))))
  (type (;28;) (func (param (ref 14) i32)))
  (type (;29;) (func (param (ref 14) eqref)))
  (type (;30;) (func (param eqref) (result eqref)))
  (type (;31;) (func (param eqref) (result eqref)))
  (type (;32;) (func (param eqref) (result eqref)))
  (type (;33;) (func (param eqref) (result eqref)))
  (type (;34;) (func (param (ref 14) eqref)))
  (type (;35;) (func (param (ref 14) eqref)))
  (type (;36;) (func (param (ref 14) eqref)))
  (type (;37;) (func (param (ref 14) eqref)))
  (type (;38;) (struct))
  (type (;39;) (struct (field i32) (field eqref)))
  (type (;40;) (sub (struct (field i32))))
  (type (;41;) (sub final 40 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;42;) (sub final 40 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;43;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;44;) (func (param (ref 38) (ref 14))))
  (type (;45;) (func (param (ref 39) (ref 14))))
  (type (;46;) (func (param (ref 40) (ref 14))))
  (type (;47;) (func (param (ref 43) (ref 14))))
  (type (;48;) (func (result (ref 40))))
  (type (;49;) (func (result (ref 40))))
  (type (;50;) (func))
  (type (;51;) (func (param (ref 40) (ref 14))))
  (type (;52;) (func (param (ref 43) (ref 14))))
  (type (;53;) (array (mut v128)))
  (type (;54;) (struct (field (ref 53)) (field i32) (field i32)))
  (type (;55;) (struct (field (ref 53)) (field i32) (field i32)))
  (type (;56;) (struct (field (ref 53)) (field i32) (field i32)))
  (type (;57;) (struct (field (mut (ref 53))) (field (mut i32)) (field (mut i32))))
  (type (;58;) (struct (field (mut (ref 53))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 39))
  (func (;0;) (type 0) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 54)
    struct.get 54 2
  )
  (func (;1;) (type 1) (param eqref eqref) (result i32)
    (local (ref 54) (ref 54) (ref 53) (ref 53) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 54)
    local.set 2
    local.get 1
    ref.cast (ref 54)
    local.set 3
    local.get 2
    struct.get 54 2
    local.tee 6
    local.get 3
    struct.get 54 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 54 0
    local.set 4
    local.get 3
    struct.get 54 0
    local.set 5
    local.get 2
    struct.get 54 1
    local.set 7
    local.get 3
    struct.get 54 1
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
          array.get 53
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 53
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
          array.get 53
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
          array.get 53
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 53
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
          array.get 53
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
      array.get 53
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
      array.get 53
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
  (func (;2;) (type 2) (result eqref)
    i32.const 4
    array.new_default 53
    i32.const 0
    i32.const 0
    struct.new 57
  )
  (func (;3;) (type 3) (param eqref) (result i32)
    (local (ref 57))
    local.get 0
    ref.cast (ref 57)
    local.tee 1
    struct.get 57 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 57 1
  )
  (func (;4;) (type 4) (param eqref eqref)
    (local (ref 57) (ref 54) (ref 53) (ref 53) i32 i32 i32 i32 i32 i32 (ref 53) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 57)
    local.set 2
    local.get 2
    struct.get 57 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 54)
    local.set 3
    local.get 2
    struct.get 57 0
    local.set 4
    local.get 3
    struct.get 54 0
    local.set 5
    local.get 2
    struct.get 57 1
    local.set 6
    local.get 3
    struct.get 54 1
    local.set 7
    local.get 3
    struct.get 54 2
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
      array.new_default 53
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
          array.get 53
          array.set 53
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 57 0
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
            array.get 53
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 53
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
            array.get 53
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
            array.set 53
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
            array.get 53
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
            array.set 53
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
            array.get 53
            local.get 19
            v128.bitselect
            array.set 53
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
        array.get 53
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
        array.get 53
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 53
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 57 1
  )
  (func (;5;) (type 5) (param eqref i32)
    (local (ref 57) (ref 53) i32 i32 i32 (ref 53) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 57)
    local.set 2
    local.get 2
    struct.get 57 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 57 0
    local.set 3
    local.get 2
    struct.get 57 1
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
      array.new_default 53
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
          array.get 53
          array.set 53
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 57 0
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
    array.get 53
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 53
    local.get 2
    local.get 5
    struct.set 57 1
  )
  (func (;6;) (type 6) (param eqref) (result eqref)
    (local (ref 57))
    local.get 0
    ref.cast (ref 57)
    local.set 1
    local.get 1
    struct.get 57 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 57 2
    local.get 1
    struct.get 57 0
    i32.const 0
    local.get 1
    struct.get 57 1
    struct.new 54
  )
  (func (;7;) (type 7) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;8;) (type 8) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;9;) (type 9) (result eqref)
    call 2
  )
  (func (;10;) (type 10) (param eqref) (result i32)
    local.get 0
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
  (func (;14;) (type 15) (param (ref 14) i32)
    (local i32)
    local.get 0
    struct.get 14 0
    call 10
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
  (func (;15;) (type 17) (param (ref 14))
    local.get 0
    struct.get 14 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;16;) (type 19) (param (ref 14) eqref)
    local.get 0
    local.get 1
    call 7
    call 14
    local.get 0
    struct.get 14 0
    local.get 1
    call 11
  )
  (func (;17;) (type 20) (param (ref 14) i32)
    local.get 0
    i32.const 1
    call 14
    local.get 0
    struct.get 14 0
    local.get 1
    call 12
  )
  (func (;18;) (type 21) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;19;) (type 22) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;20;) (type 23) (param i64) (result i64)
    local.get 0
  )
  (func (;21;) (type 24) (param (ref 14) i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 21
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 18
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 17
  )
  (func (;22;) (type 25) (param (ref 14) i64)
    (local i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 17
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 20
      i64.const 1
      i64.add
      local.set 2
      local.get 0
      local.get 2
      call 21
    else
      local.get 0
      local.get 1
      call 20
      call 21
    end
  )
  (func (;23;) (type 26) (param i32 (ref 14))
    local.get 1
    local.get 0
    call 19
    call 22
  )
  (func (;24;) (type 27) (param eqref (ref 14))
    local.get 1
    local.get 0
    call 16
  )
  (func (;25;) (type 28) (param (ref 14) i32)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 23
  )
  (func (;26;) (type 29) (param (ref 14) eqref)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 24
  )
  (func (;27;) (type 30) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 1
    i32.const 0
    struct.new 14
    local.get 0
    call 31
    local.get 1
    call 13
  )
  (func (;28;) (type 31) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 1
    i32.const 0
    struct.new 14
    local.get 0
    call 32
    local.get 1
    call 13
  )
  (func (;29;) (type 32) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 1
    i32.const 0
    struct.new 14
    local.get 0
    call 33
    local.get 1
    call 13
  )
  (func (;30;) (type 33) (param eqref) (result eqref)
    (local eqref)
    call 9
    local.set 1
    local.get 1
    i32.const 0
    struct.new 14
    local.get 0
    call 34
    local.get 1
    call 13
  )
  (func (;31;) (type 34) (param (ref 14) eqref)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    ref.cast (ref 38)
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 35
  )
  (func (;32;) (type 35) (param (ref 14) eqref)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    ref.cast (ref 39)
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 36
  )
  (func (;33;) (type 36) (param (ref 14) eqref)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    ref.cast (ref 40)
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 40
  )
  (func (;34;) (type 37) (param (ref 14) eqref)
    local.get 0
    ref.cast (ref 14)
    call 15
    local.get 1
    ref.cast (ref 43)
    local.get 0
    struct.get 14 0
    local.get 0
    struct.get 14 1
    i32.const 1
    i32.add
    struct.new 14
    call 41
  )
  (func (;35;) (type 44) (param (ref 38) (ref 14))
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 8
    struct.new 54
    call 16
  )
  (func (;36;) (type 45) (param (ref 39) (ref 14))
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x6e696f50 0x207b2074 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 8
    struct.new 54
    call 16
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x00203a78 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 3
    struct.new 54
    call 16
    local.get 1
    ref.cast (ref 14)
    local.get 0
    struct.get 39 0
    call 25
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x616c202c 0x3a6c6562 0x00000020 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 9
    struct.new 54
    call 16
    local.get 1
    ref.cast (ref 14)
    local.get 0
    struct.get 39 1
    call 26
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 2
    struct.new 54
    call 16
  )
  (func (;37;) (type 48) (result (ref 40))
    i32.const 0
    struct.new 40
    ref.cast (ref 40)
  )
  (func (;38;) (type 49) (result (ref 40))
    i32.const 2
    struct.new 40
    ref.cast (ref 40)
  )
  (func (;39;) (type 50)
    struct.new 38
    call 27
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 8
    struct.new 54
    call 8
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 12
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const -7
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 3
    struct.new 54
    struct.new 39
    call 28
    v128.const i32x4 0x6e696f50 0x207b2074 0x2d203a78 0x6c202c37
    v128.const i32x4 0x6c656261 0x6564203a 0x007d2077 0x00000000
    array.new_fixed 53 2
    i32.const 0
    i32.const 27
    struct.new 54
    call 8
    v128.const i32x4 0x75727473 0x73207463 0x00776f68 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 11
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 37
    call 29
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 12
    struct.new 54
    call 8
    v128.const i32x4 0x74696e75 0x72617620 0x746e6169 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 12
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 5
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 41
    call 29
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00293528
    array.new_fixed 53 1
    i32.const 0
    i32.const 15
    struct.new 54
    call 8
    v128.const i32x4 0x6c707574 0x61762065 0x6e616972 0x00000074
    array.new_fixed 53 1
    i32.const 0
    i32.const 13
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 38
    call 29
    v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
    v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
    array.new_fixed 53 2
    i32.const 0
    i32.const 22
    struct.new 54
    call 8
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x72617620
    v128.const i32x4 0x746e6169 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 2
    i32.const 0
    i32.const 20
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    i32.const 1
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    i32.const 2
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 42
    call 29
    v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x6c207b20
    v128.const i32x4 0x3a746665 0x202c3120 0x68676972 0x32203a74
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 3
    i32.const 0
    i32.const 34
    struct.new 54
    call 8
    v128.const i32x4 0x75727473 0x76207463 0x61697261 0x0000746e
    array.new_fixed 53 1
    i32.const 0
    i32.const 14
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    i32.const 3
    v128.const i32x4 0x7473656e 0x00006465 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 6
    struct.new 54
    struct.new 39
    struct.new 43
    call 30
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x3a65756c
    v128.const i32x4 0x696f5020 0x7b20746e 0x203a7820 0x6c202c33
    v128.const i32x4 0x6c656261 0x656e203a 0x64657473 0x7d207d20
    array.new_fixed 53 3
    i32.const 0
    i32.const 48
    struct.new 54
    call 8
    v128.const i32x4 0x656e6567 0x20636972 0x7473656e 0x00006465
    array.new_fixed 53 1
    i32.const 0
    i32.const 14
    struct.new 54
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;40;) (type 51) (param (ref 40) (ref 14))
    (local i32 i32 i32 eqref)
    local.get 0
    local.set 5
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 5
                ref.cast (ref 40)
                struct.get 40 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              local.get 1
              ref.cast (ref 14)
              v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
              array.new_fixed 53 1
              i32.const 0
              i32.const 12
              struct.new 54
              call 16
              br 4 (;@1;)
            end
            local.get 5
            ref.cast (ref 41)
            struct.get 41 1
            local.set 2
            local.get 1
            ref.cast (ref 14)
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00000028
            array.new_fixed 53 1
            i32.const 0
            i32.const 13
            struct.new 54
            call 16
            local.get 1
            ref.cast (ref 14)
            local.get 2
            call 25
            local.get 1
            ref.cast (ref 14)
            v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
            array.new_fixed 53 1
            i32.const 0
            i32.const 1
            struct.new 54
            call 16
            br 3 (;@1;)
          end
          local.get 1
          ref.cast (ref 14)
          v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
          v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
          array.new_fixed 53 2
          i32.const 0
          i32.const 22
          struct.new 54
          call 16
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 42)
        struct.get 42 1
        local.set 3
        local.get 5
        ref.cast (ref 42)
        struct.get 42 7
        local.set 4
        local.get 1
        ref.cast (ref 14)
        v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x00207b20
        array.new_fixed 53 1
        i32.const 0
        i32.const 15
        struct.new 54
        call 16
        local.get 1
        ref.cast (ref 14)
        v128.const i32x4 0x7466656c 0x0000203a 0x00000000 0x00000000
        array.new_fixed 53 1
        i32.const 0
        i32.const 6
        struct.new 54
        call 16
        local.get 1
        ref.cast (ref 14)
        local.get 3
        call 25
        local.get 1
        ref.cast (ref 14)
        v128.const i32x4 0x6972202c 0x3a746867 0x00000020 0x00000000
        array.new_fixed 53 1
        i32.const 0
        i32.const 9
        struct.new 54
        call 16
        local.get 1
        ref.cast (ref 14)
        local.get 4
        call 25
        local.get 1
        ref.cast (ref 14)
        v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
        array.new_fixed 53 1
        i32.const 0
        i32.const 2
        struct.new 54
        call 16
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;41;) (type 52) (param (ref 43) (ref 14))
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x70617257 0x20726570 0x0000207b 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 10
    struct.new 54
    call 16
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 7
    struct.new 54
    call 16
    local.get 1
    ref.cast (ref 14)
    local.get 0
    struct.get 43 5
    call 32
    local.get 1
    ref.cast (ref 14)
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 53 1
    i32.const 0
    i32.const 2
    struct.new 54
    call 16
  )
)
