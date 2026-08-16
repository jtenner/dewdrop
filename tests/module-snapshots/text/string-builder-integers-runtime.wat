(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref eqref) (result i32)))
  (type (;9;) (func (result eqref)))
  (type (;10;) (func (param eqref i32)))
  (type (;11;) (func (param eqref) (result eqref)))
  (type (;12;) (func (param eqref eqref) (result i32)))
  (type (;13;) (func (param i64) (result i32)))
  (type (;14;) (func (param i32) (result i64)))
  (type (;15;) (func (param i32) (result i64)))
  (type (;16;) (func (param i32) (result i64)))
  (type (;17;) (func (param i32) (result i64)))
  (type (;18;) (func (param i32) (result i64)))
  (type (;19;) (func (param i32) (result i64)))
  (type (;20;) (func (param i64) (result i64)))
  (type (;21;) (func (param eqref i64)))
  (type (;22;) (func (param eqref i64)))
  (type (;23;) (func (result eqref)))
  (type (;24;) (func (param eqref i32)))
  (type (;25;) (func (param eqref i32)))
  (type (;26;) (func (param eqref i32)))
  (type (;27;) (func (param eqref i32)))
  (type (;28;) (func (param eqref i64)))
  (type (;29;) (func (param eqref i32)))
  (type (;30;) (func (param eqref i32)))
  (type (;31;) (func (param eqref i32)))
  (type (;32;) (func (param eqref i64)))
  (type (;33;) (func (param eqref) (result eqref)))
  (type (;34;) (func))
  (type (;35;) (array (mut v128)))
  (type (;36;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;37;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;38;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;39;) (struct (field (mut (ref 35))) (field (mut i32)) (field (mut i32))))
  (type (;40;) (struct (field (mut (ref 35))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 26))
  (func (;0;) (type 8) (param eqref eqref) (result i32)
    (local (ref 36) (ref 36) (ref 35) (ref 35) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 36)
    local.set 2
    local.get 1
    ref.cast (ref 36)
    local.set 3
    local.get 2
    struct.get 36 2
    local.tee 6
    local.get 3
    struct.get 36 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 36 0
    local.set 4
    local.get 3
    struct.get 36 0
    local.set 5
    local.get 2
    struct.get 36 1
    local.set 7
    local.get 3
    struct.get 36 1
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
          array.get 35
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 35
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
          array.get 35
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
          array.get 35
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 35
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
          array.get 35
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
      array.get 35
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
      array.get 35
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
  (func (;1;) (type 9) (result eqref)
    i32.const 4
    array.new_default 35
    i32.const 0
    i32.const 0
    struct.new 39
  )
  (func (;2;) (type 10) (param eqref i32)
    (local (ref 39) (ref 35) i32 i32 i32 (ref 35) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 39)
    local.set 2
    local.get 2
    struct.get 39 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 39 0
    local.set 3
    local.get 2
    struct.get 39 1
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
      array.new_default 35
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
          array.get 35
          array.set 35
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 39 0
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
    array.get 35
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 35
    local.get 2
    local.get 5
    struct.set 39 1
  )
  (func (;3;) (type 11) (param eqref) (result eqref)
    (local (ref 39))
    local.get 0
    ref.cast (ref 39)
    local.set 1
    local.get 1
    struct.get 39 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 39 2
    local.get 1
    struct.get 39 0
    i32.const 0
    local.get 1
    struct.get 39 1
    struct.new 36
  )
  (func (;4;) (type 12) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;5;) (type 13) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;6;) (type 14) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;7;) (type 15) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;8;) (type 16) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;9;) (type 17) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;10;) (type 18) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;11;) (type 19) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;12;) (type 20) (param i64) (result i64)
    local.get 0
  )
  (func (;13;) (type 21) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 13
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 5
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 2
  )
  (func (;14;) (type 22) (param eqref i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 2
      local.get 0
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 12
      i64.const 1
      i64.add
      call 13
    else
      local.get 0
      local.get 1
      call 12
      call 13
    end
  )
  (func (;15;) (type 23) (result eqref)
    call 1
  )
  (func (;16;) (type 24) (param eqref i32)
    local.get 0
    local.get 1
    call 2
  )
  (func (;17;) (type 25) (param eqref i32)
    local.get 0
    local.get 1
    call 6
    call 14
  )
  (func (;18;) (type 26) (param eqref i32)
    local.get 0
    local.get 1
    call 7
    call 14
  )
  (func (;19;) (type 27) (param eqref i32)
    local.get 0
    local.get 1
    call 8
    call 14
  )
  (func (;20;) (type 28) (param eqref i64)
    local.get 0
    local.get 1
    call 14
  )
  (func (;21;) (type 29) (param eqref i32)
    local.get 0
    local.get 1
    call 9
    call 13
  )
  (func (;22;) (type 30) (param eqref i32)
    local.get 0
    local.get 1
    call 10
    call 13
  )
  (func (;23;) (type 31) (param eqref i32)
    local.get 0
    local.get 1
    call 11
    call 13
  )
  (func (;24;) (type 32) (param eqref i64)
    local.get 0
    local.get 1
    call 13
  )
  (func (;25;) (type 33) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;26;) (type 34)
    (local eqref)
    call 15
    local.set 0
    local.get 0
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    call 17
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    call 18
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i32.const -2147483648
    call 19
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i64.const -9223372036854775808
    call 20
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i32.const 255
    call 21
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i32.const 65535
    call 22
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i32.const -1
    call 23
    local.get 0
    i32.const 44
    call 16
    local.get 0
    i64.const -1
    call 24
    local.get 0
    call 25
    v128.const i32x4 0x3832312d 0x32332d2c 0x2c383637 0x3431322d
    v128.const i32x4 0x33383437 0x2c383436 0x3232392d 0x32373333
    v128.const i32x4 0x38363330 0x37373435 0x38303835 0x3535322c
    v128.const i32x4 0x3535362c 0x342c3533 0x39343932 0x39323736
    v128.const i32x4 0x38312c35 0x37363434 0x37303434 0x39303733
    v128.const i32x4 0x36313535 0x00003531 0x00000000 0x00000000
    array.new_fixed 35 6
    i32.const 0
    i32.const 86
    struct.new 36
    call 4
    v128.const i32x4 0x65726964 0x69207463 0x6765746e 0x61207265
    v128.const i32x4 0x6e657070 0x68632064 0x65676e61 0x65642064
    v128.const i32x4 0x616d6963 0x6574206c 0x00007478 0x00000000
    array.new_fixed 35 3
    i32.const 0
    i32.const 42
    struct.new 36
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
