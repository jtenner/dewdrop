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
  (type (;9;) (func (param eqref eqref) (result i32)))
  (type (;10;) (func (result eqref)))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (param eqref eqref)))
  (type (;13;) (func (param eqref i32)))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref) (result i32)))
  (type (;16;) (func (param eqref eqref) (result i32)))
  (type (;17;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;18;) (struct (field eqref) (field (mut i32))))
  (type (;19;) (sub (struct (field funcref))))
  (type (;20;) (func (param eqref) (result eqref)))
  (type (;21;) (func (param eqref i32) (result eqref)))
  (type (;22;) (func (param eqref) (result (ref 17))))
  (type (;23;) (func (param eqref eqref) (result eqref)))
  (type (;24;) (func (param eqref)))
  (type (;25;) (func (param eqref i32)))
  (type (;26;) (func (param eqref) (result i32)))
  (type (;27;) (func (param eqref i32) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result eqref)))
  (type (;29;) (func (param eqref eqref) (result (ref 17))))
  (type (;30;) (func (param eqref eqref eqref) (result eqref)))
  (type (;31;) (func (param eqref eqref)))
  (type (;32;) (func (param eqref eqref i32)))
  (type (;33;) (func (param eqref eqref) (result i32)))
  (type (;34;) (func (param eqref eqref i32) (result i32)))
  (type (;35;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;36;) (func (param i64) (result i32)))
  (type (;37;) (func (param i64) (result i64)))
  (type (;38;) (func (param eqref i64)))
  (type (;39;) (func (param eqref i64)))
  (type (;40;) (func (result eqref)))
  (type (;41;) (func (param eqref) (result i32)))
  (type (;42;) (func (param eqref eqref)))
  (type (;43;) (func (param eqref i64)))
  (type (;44;) (func (param eqref) (result eqref)))
  (type (;45;) (struct (field eqref) (field i32)))
  (type (;46;) (func (param (ref 45) i32)))
  (type (;47;) (func (param eqref) (result eqref)))
  (type (;48;) (func (param (ref 45))))
  (type (;49;) (func (param (ref 45) eqref)))
  (type (;50;) (func (param (ref 45) eqref)))
  (type (;51;) (func (param i32) (result i64)))
  (type (;52;) (func (param i64) (result i64)))
  (type (;53;) (func (param i64) (result i32)))
  (type (;54;) (func (param i64) (result i32)))
  (type (;55;) (func (param (ref 45) i64)))
  (type (;56;) (func (param i32 (ref 45))))
  (type (;57;) (func (param eqref (ref 45))))
  (type (;58;) (func (param (ref 45) i32)))
  (type (;59;) (func (param (ref 45) eqref)))
  (type (;60;) (func (param eqref) (result eqref)))
  (type (;61;) (func (param eqref) (result eqref)))
  (type (;62;) (func (param eqref) (result eqref)))
  (type (;63;) (func (param eqref) (result eqref)))
  (type (;64;) (func (param (ref 45) eqref)))
  (type (;65;) (func (param (ref 45) eqref)))
  (type (;66;) (func (param (ref 45) eqref)))
  (type (;67;) (func (param (ref 45) eqref)))
  (type (;68;) (struct))
  (type (;69;) (struct (field i32) (field eqref)))
  (type (;70;) (sub (struct (field i32))))
  (type (;71;) (sub final 70 (struct (field i32) (field i32))))
  (type (;72;) (sub final 70 (struct (field i32) (field eqref))))
  (type (;73;) (sub final 70 (struct (field i32) (field i32) (field i32))))
  (type (;74;) (sub final 70 (struct (field i32) (field eqref) (field eqref))))
  (type (;75;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;76;) (func (param (ref 68) (ref 45))))
  (type (;77;) (func (param (ref 69) (ref 45))))
  (type (;78;) (func (param (ref 70) (ref 45))))
  (type (;79;) (func (param (ref 75) (ref 45))))
  (type (;80;) (func (result (ref 70))))
  (type (;81;) (func (result (ref 70))))
  (type (;82;) (func))
  (type (;83;) (func (param (ref 70) (ref 45))))
  (type (;84;) (func (param (ref 75) (ref 45))))
  (type (;85;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;86;) (struct))
  (type (;87;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;88;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;89;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;90;) (array (mut v128)))
  (type (;91;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;92;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;93;) (struct (field (ref 90)) (field i32) (field i32)))
  (type (;94;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (type (;95;) (struct (field (mut (ref 90))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 42))
  (func (;0;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 91)
    struct.get 91 2
  )
  (func (;1;) (type 9) (param eqref eqref) (result i32)
    (local (ref 91) (ref 91) (ref 90) (ref 90) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 91)
    local.set 2
    local.get 1
    ref.cast (ref 91)
    local.set 3
    local.get 2
    struct.get 91 2
    local.tee 6
    local.get 3
    struct.get 91 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 91 0
    local.set 4
    local.get 3
    struct.get 91 0
    local.set 5
    local.get 2
    struct.get 91 1
    local.set 7
    local.get 3
    struct.get 91 1
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
          array.get 90
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 90
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
          array.get 90
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
          array.get 90
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 90
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
          array.get 90
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
      array.get 90
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
      array.get 90
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
  (func (;2;) (type 10) (result eqref)
    i32.const 4
    array.new_default 90
    i32.const 0
    i32.const 0
    struct.new 94
  )
  (func (;3;) (type 11) (param eqref) (result i32)
    (local (ref 94))
    local.get 0
    ref.cast (ref 94)
    local.tee 1
    struct.get 94 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 94 1
  )
  (func (;4;) (type 12) (param eqref eqref)
    (local (ref 94) (ref 91) (ref 90) (ref 90) i32 i32 i32 i32 i32 i32 (ref 90) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 94)
    local.set 2
    local.get 2
    struct.get 94 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 91)
    local.set 3
    local.get 2
    struct.get 94 0
    local.set 4
    local.get 3
    struct.get 91 0
    local.set 5
    local.get 2
    struct.get 94 1
    local.set 6
    local.get 3
    struct.get 91 1
    local.set 7
    local.get 3
    struct.get 91 2
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
      array.new_default 90
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
          array.get 90
          array.set 90
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 94 0
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
            array.get 90
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 90
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
            array.get 90
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
            array.set 90
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
            array.get 90
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
            array.set 90
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
            array.get 90
            local.get 19
            v128.bitselect
            array.set 90
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
        array.get 90
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
        array.get 90
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 90
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 94 1
  )
  (func (;5;) (type 13) (param eqref i32)
    (local (ref 94) (ref 90) i32 i32 i32 (ref 90) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 94)
    local.set 2
    local.get 2
    struct.get 94 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 94 0
    local.set 3
    local.get 2
    struct.get 94 1
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
      array.new_default 90
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
          array.get 90
          array.set 90
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 94 0
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
    array.get 90
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 90
    local.get 2
    local.get 5
    struct.set 94 1
  )
  (func (;6;) (type 14) (param eqref) (result eqref)
    (local (ref 94))
    local.get 0
    ref.cast (ref 94)
    local.set 1
    local.get 1
    struct.get 94 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 94 2
    local.get 1
    struct.get 94 0
    i32.const 0
    local.get 1
    struct.get 94 1
    struct.new 91
  )
  (func (;7;) (type 15) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;8;) (type 16) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;9;) (type 36) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;10;) (type 37) (param i64) (result i64)
    local.get 0
  )
  (func (;11;) (type 38) (param eqref i64)
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
  (func (;12;) (type 39) (param eqref i64)
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
  (func (;13;) (type 40) (result eqref)
    call 2
  )
  (func (;14;) (type 41) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;15;) (type 42) (param eqref eqref)
    local.get 0
    local.get 1
    call 4
  )
  (func (;16;) (type 43) (param eqref i64)
    local.get 0
    local.get 1
    call 12
  )
  (func (;17;) (type 44) (param eqref) (result eqref)
    local.get 0
    call 6
  )
  (func (;18;) (type 46) (param (ref 45) i32)
    (local i32)
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
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
  (func (;19;) (type 48) (param (ref 45))
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;20;) (type 50) (param (ref 45) eqref)
    local.get 0
    local.get 1
    call 7
    call 18
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 1
    call 15
  )
  (func (;21;) (type 51) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;22;) (type 52) (param i64) (result i64)
    local.get 0
  )
  (func (;23;) (type 53) (param i64) (result i32)
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
  (func (;24;) (type 54) (param i64) (result i32)
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
  (func (;25;) (type 55) (param (ref 45) i64)
    local.get 0
    local.get 1
    call 24
    call 18
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 1
    call 16
  )
  (func (;26;) (type 56) (param i32 (ref 45))
    local.get 1
    local.get 0
    call 21
    call 25
  )
  (func (;27;) (type 57) (param eqref (ref 45))
    local.get 1
    local.get 0
    call 20
  )
  (func (;28;) (type 58) (param (ref 45) i32)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 26
  )
  (func (;29;) (type 59) (param (ref 45) eqref)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 27
  )
  (func (;30;) (type 60) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 45
    local.get 0
    call 34
    local.get 1
    call 17
  )
  (func (;31;) (type 61) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 45
    local.get 0
    call 35
    local.get 1
    call 17
  )
  (func (;32;) (type 62) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 45
    local.get 0
    call 36
    local.get 1
    call 17
  )
  (func (;33;) (type 63) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 45
    local.get 0
    call 37
    local.get 1
    call 17
  )
  (func (;34;) (type 64) (param (ref 45) eqref)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    ref.cast (ref 68)
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 38
  )
  (func (;35;) (type 65) (param (ref 45) eqref)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    ref.cast (ref 69)
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 39
  )
  (func (;36;) (type 66) (param (ref 45) eqref)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    ref.cast (ref 70)
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 43
  )
  (func (;37;) (type 67) (param (ref 45) eqref)
    local.get 0
    ref.cast (ref 45)
    call 19
    local.get 1
    ref.cast (ref 75)
    local.get 0
    ref.cast (ref 45)
    struct.get 45 0
    local.get 0
    ref.cast (ref 45)
    struct.get 45 1
    i32.const 1
    i32.add
    struct.new 45
    call 44
  )
  (func (;38;) (type 76) (param (ref 68) (ref 45))
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 8
    struct.new 91
    call 20
  )
  (func (;39;) (type 77) (param (ref 69) (ref 45))
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x6e696f50 0x207b2074 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 8
    struct.new 91
    call 20
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x00203a78 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 3
    struct.new 91
    call 20
    local.get 1
    ref.cast (ref 45)
    local.get 0
    ref.cast (ref 69)
    struct.get 69 0
    call 28
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x616c202c 0x3a6c6562 0x00000020 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 9
    struct.new 91
    call 20
    local.get 1
    ref.cast (ref 45)
    local.get 0
    ref.cast (ref 69)
    struct.get 69 1
    call 29
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 2
    struct.new 91
    call 20
  )
  (func (;40;) (type 80) (result (ref 70))
    i32.const 0
    struct.new 70
    ref.cast (ref 70)
  )
  (func (;41;) (type 81) (result (ref 70))
    i32.const 2
    struct.new 70
    ref.cast (ref 70)
  )
  (func (;42;) (type 82)
    struct.new 68
    call 30
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 8
    struct.new 91
    call 8
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const -7
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 3
    struct.new 91
    struct.new 69
    call 31
    v128.const i32x4 0x6e696f50 0x207b2074 0x2d203a78 0x6c202c37
    v128.const i32x4 0x6c656261 0x6564203a 0x007d2077 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 27
    struct.new 91
    call 8
    v128.const i32x4 0x75727473 0x73207463 0x00776f68 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 11
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 40
    call 32
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    call 8
    v128.const i32x4 0x74696e75 0x72617620 0x746e6169 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 12
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 1
    i32.const 5
    struct.new 71
    call 32
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00293528
    array.new_fixed 90 1
    i32.const 0
    i32.const 15
    struct.new 91
    call 8
    v128.const i32x4 0x6c707574 0x61762065 0x6e616972 0x00000074
    array.new_fixed 90 1
    i32.const 0
    i32.const 13
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 41
    call 32
    v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
    v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 22
    struct.new 91
    call 8
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x72617620
    v128.const i32x4 0x746e6169 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 2
    i32.const 0
    i32.const 20
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 3
    i32.const 1
    i32.const 2
    struct.new 73
    call 32
    v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x6c207b20
    v128.const i32x4 0x3a746665 0x202c3120 0x68676972 0x32203a74
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 3
    i32.const 0
    i32.const 34
    struct.new 91
    call 8
    v128.const i32x4 0x75727473 0x76207463 0x61697261 0x0000746e
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
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
    array.new_fixed 90 1
    i32.const 0
    i32.const 6
    struct.new 91
    struct.new 69
    struct.new 75
    call 33
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x3a65756c
    v128.const i32x4 0x696f5020 0x7b20746e 0x203a7820 0x6c202c33
    v128.const i32x4 0x6c656261 0x656e203a 0x64657473 0x7d207d20
    array.new_fixed 90 3
    i32.const 0
    i32.const 48
    struct.new 91
    call 8
    v128.const i32x4 0x656e6567 0x20636972 0x7473656e 0x00006465
    array.new_fixed 90 1
    i32.const 0
    i32.const 14
    struct.new 91
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;43;) (type 83) (param (ref 70) (ref 45))
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
                ref.cast (ref 70)
                struct.get 70 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              local.get 1
              ref.cast (ref 45)
              v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
              array.new_fixed 90 1
              i32.const 0
              i32.const 12
              struct.new 91
              call 20
              br 4 (;@1;)
            end
            local.get 5
            ref.cast (ref 71)
            struct.get 71 1
            local.set 2
            local.get 1
            ref.cast (ref 45)
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00000028
            array.new_fixed 90 1
            i32.const 0
            i32.const 13
            struct.new 91
            call 20
            local.get 1
            ref.cast (ref 45)
            local.get 2
            call 28
            local.get 1
            ref.cast (ref 45)
            v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
            array.new_fixed 90 1
            i32.const 0
            i32.const 1
            struct.new 91
            call 20
            br 3 (;@1;)
          end
          local.get 1
          ref.cast (ref 45)
          v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
          v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
          array.new_fixed 90 2
          i32.const 0
          i32.const 22
          struct.new 91
          call 20
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 73)
        struct.get 73 1
        local.set 3
        local.get 5
        ref.cast (ref 73)
        struct.get 73 2
        local.set 4
        local.get 1
        ref.cast (ref 45)
        v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x00207b20
        array.new_fixed 90 1
        i32.const 0
        i32.const 15
        struct.new 91
        call 20
        local.get 1
        ref.cast (ref 45)
        v128.const i32x4 0x7466656c 0x0000203a 0x00000000 0x00000000
        array.new_fixed 90 1
        i32.const 0
        i32.const 6
        struct.new 91
        call 20
        local.get 1
        ref.cast (ref 45)
        local.get 3
        call 28
        local.get 1
        ref.cast (ref 45)
        v128.const i32x4 0x6972202c 0x3a746867 0x00000020 0x00000000
        array.new_fixed 90 1
        i32.const 0
        i32.const 9
        struct.new 91
        call 20
        local.get 1
        ref.cast (ref 45)
        local.get 4
        call 28
        local.get 1
        ref.cast (ref 45)
        v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
        array.new_fixed 90 1
        i32.const 0
        i32.const 2
        struct.new 91
        call 20
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;44;) (type 84) (param (ref 75) (ref 45))
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x70617257 0x20726570 0x0000207b 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 10
    struct.new 91
    call 20
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 7
    struct.new 91
    call 20
    local.get 1
    ref.cast (ref 45)
    local.get 0
    ref.cast (ref 75)
    struct.get 75 5
    call 35
    local.get 1
    ref.cast (ref 45)
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 90 1
    i32.const 0
    i32.const 2
    struct.new 91
    call 20
  )
)
