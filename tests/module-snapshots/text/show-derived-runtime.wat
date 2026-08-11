(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (result eqref)))
  (type (;2;) (func (param eqref eqref)))
  (type (;3;) (func (param eqref i32)))
  (type (;4;) (func (param eqref) (result eqref)))
  (type (;5;) (func (param eqref eqref) (result i32)))
  (type (;6;) (func (result eqref)))
  (type (;7;) (func (param eqref eqref)))
  (type (;8;) (func (param eqref i32)))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref) (result eqref)))
  (type (;11;) (func (param eqref eqref)))
  (type (;12;) (func (param eqref eqref)))
  (type (;13;) (func (param i64) (result i32)))
  (type (;14;) (func (param i32) (result i64)))
  (type (;15;) (func (param i64) (result i64)))
  (type (;16;) (func (param eqref i64)))
  (type (;17;) (func (param eqref i64)))
  (type (;18;) (func (param i32 eqref)))
  (type (;19;) (func (param eqref eqref)))
  (type (;20;) (func (param eqref i32)))
  (type (;21;) (func (param eqref eqref)))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (param eqref) (result eqref)))
  (type (;25;) (func (param eqref) (result eqref)))
  (type (;26;) (func (param eqref eqref)))
  (type (;27;) (struct))
  (type (;28;) (struct (field i32) (field eqref)))
  (type (;29;) (sub (struct (field i32))))
  (type (;30;) (sub final 29 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;31;) (sub final 29 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;32;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;33;) (func (param (ref 27) eqref)))
  (type (;34;) (func (param (ref 28) eqref)))
  (type (;35;) (func (param (ref 29) eqref)))
  (type (;36;) (func (param (ref 32) eqref)))
  (type (;37;) (func (result (ref 29))))
  (type (;38;) (func (result (ref 29))))
  (type (;39;) (func))
  (type (;40;) (func (param (ref 29) eqref)))
  (type (;41;) (func (param (ref 32) eqref)))
  (type (;42;) (array (mut v128)))
  (type (;43;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;44;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;45;) (struct (field (ref 42)) (field i32) (field i32)))
  (type (;46;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (type (;47;) (struct (field (mut (ref 42))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 29))
  (func (;0;) (type 0) (param eqref eqref) (result i32)
    (local (ref 43) (ref 43) (ref 42) (ref 42) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 43)
    local.set 2
    local.get 1
    ref.cast (ref 43)
    local.set 3
    local.get 2
    struct.get 43 2
    local.tee 6
    local.get 3
    struct.get 43 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 43 0
    local.set 4
    local.get 3
    struct.get 43 0
    local.set 5
    local.get 2
    struct.get 43 1
    local.set 7
    local.get 3
    struct.get 43 1
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
          array.get 42
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
          array.get 42
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 42
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
          array.get 42
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
      array.get 42
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
      array.get 42
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
  (func (;1;) (type 1) (result eqref)
    i32.const 4
    array.new_default 42
    i32.const 0
    i32.const 0
    struct.new 46
  )
  (func (;2;) (type 2) (param eqref eqref)
    (local (ref 46) (ref 43) (ref 42) (ref 42) i32 i32 i32 i32 i32 i32 (ref 42) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 46)
    local.set 2
    local.get 2
    struct.get 46 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 43)
    local.set 3
    local.get 2
    struct.get 46 0
    local.set 4
    local.get 3
    struct.get 43 0
    local.set 5
    local.get 2
    struct.get 46 1
    local.set 6
    local.get 3
    struct.get 43 1
    local.set 7
    local.get 3
    struct.get 43 2
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
      array.new_default 42
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
          array.get 42
          array.set 42
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 46 0
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
            array.get 42
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 42
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
            array.get 42
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
            array.set 42
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
            array.get 42
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
            array.set 42
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
            array.get 42
            local.get 19
            v128.bitselect
            array.set 42
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
        array.get 42
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
        array.get 42
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 42
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 46 1
  )
  (func (;3;) (type 3) (param eqref i32)
    (local (ref 46) (ref 42) i32 i32 i32 (ref 42) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 46)
    local.set 2
    local.get 2
    struct.get 46 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 46 0
    local.set 3
    local.get 2
    struct.get 46 1
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
      array.new_default 42
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
          array.get 42
          array.set 42
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 46 0
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
    array.get 42
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 42
    local.get 2
    local.get 5
    struct.set 46 1
  )
  (func (;4;) (type 4) (param eqref) (result eqref)
    (local (ref 46))
    local.get 0
    ref.cast (ref 46)
    local.set 1
    local.get 1
    struct.get 46 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 46 2
    local.get 1
    struct.get 46 0
    i32.const 0
    local.get 1
    struct.get 46 1
    struct.new 43
  )
  (func (;5;) (type 5) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;6;) (type 6) (result eqref)
    call 1
  )
  (func (;7;) (type 7) (param eqref eqref)
    local.get 0
    local.get 1
    call 2
  )
  (func (;8;) (type 8) (param eqref i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;9;) (type 9) (param eqref) (result eqref)
    local.get 0
    call 4
  )
  (func (;10;) (type 12) (param eqref eqref)
    local.get 0
    local.get 1
    call 7
  )
  (func (;11;) (type 13) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;12;) (type 14) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;13;) (type 15) (param i64) (result i64)
    local.get 0
  )
  (func (;14;) (type 16) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 14
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 11
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 8
  )
  (func (;15;) (type 17) (param eqref i64)
    (local i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 8
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 13
      i64.const 1
      i64.add
      local.set 2
      local.get 0
      local.get 2
      call 14
    else
      local.get 0
      local.get 1
      call 13
      call 14
    end
  )
  (func (;16;) (type 18) (param i32 eqref)
    local.get 1
    local.get 0
    call 12
    call 15
  )
  (func (;17;) (type 19) (param eqref eqref)
    local.get 1
    local.get 0
    call 7
  )
  (func (;18;) (type 20) (param eqref i32)
    local.get 1
    local.get 0
    call 16
  )
  (func (;19;) (type 21) (param eqref eqref)
    local.get 1
    local.get 0
    call 17
  )
  (func (;20;) (type 22) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 27)
    local.get 1
    call 25
    local.get 1
    call 9
  )
  (func (;21;) (type 23) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 28)
    local.get 1
    call 26
    local.get 1
    call 9
  )
  (func (;22;) (type 24) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 29)
    local.get 1
    call 30
    local.get 1
    call 9
  )
  (func (;23;) (type 25) (param eqref) (result eqref)
    (local eqref)
    call 6
    local.set 1
    local.get 0
    ref.cast (ref 32)
    local.get 1
    call 31
    local.get 1
    call 9
  )
  (func (;24;) (type 26) (param eqref eqref)
    local.get 1
    ref.cast (ref 28)
    local.get 0
    call 26
  )
  (func (;25;) (type 33) (param (ref 27) eqref)
    local.get 1
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 8
    struct.new 43
    call 10
  )
  (func (;26;) (type 34) (param (ref 28) eqref)
    local.get 1
    v128.const i32x4 0x6e696f50 0x207b2074 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 8
    struct.new 43
    call 10
    local.get 1
    v128.const i32x4 0x00203a78 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 3
    struct.new 43
    call 10
    local.get 1
    local.get 0
    struct.get 28 0
    call 18
    local.get 1
    v128.const i32x4 0x616c202c 0x3a6c6562 0x00000020 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 9
    struct.new 43
    call 10
    local.get 1
    local.get 0
    struct.get 28 1
    call 19
    local.get 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 2
    struct.new 43
    call 10
  )
  (func (;27;) (type 37) (result (ref 29))
    i32.const 0
    struct.new 29
    ref.cast (ref 29)
  )
  (func (;28;) (type 38) (result (ref 29))
    i32.const 2
    struct.new 29
    ref.cast (ref 29)
  )
  (func (;29;) (type 39)
    struct.new 27
    call 20
    v128.const i32x4 0x74706d45 0x7d7b2079 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 8
    struct.new 43
    call 5
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 12
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 0
    i32.const 7
    i32.sub
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 3
    struct.new 43
    struct.new 28
    call 21
    v128.const i32x4 0x6e696f50 0x207b2074 0x2d203a78 0x6c202c37
    v128.const i32x4 0x6c656261 0x6564203a 0x007d2077 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 27
    struct.new 43
    call 5
    v128.const i32x4 0x75727473 0x73207463 0x00776f68 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 11
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 27
    call 22
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 12
    struct.new 43
    call 5
    v128.const i32x4 0x74696e75 0x72617620 0x746e6169 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 12
    struct.new 43
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
    struct.new 30
    call 22
    v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00293528
    array.new_fixed 42 1
    i32.const 0
    i32.const 15
    struct.new 43
    call 5
    v128.const i32x4 0x6c707574 0x61762065 0x6e616972 0x00000074
    array.new_fixed 42 1
    i32.const 0
    i32.const 13
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 28
    call 22
    v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
    v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 22
    struct.new 43
    call 5
    v128.const i32x4 0x74706d65 0x74732079 0x74637572 0x72617620
    v128.const i32x4 0x746e6169 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 2
    i32.const 0
    i32.const 20
    struct.new 43
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
    struct.new 31
    call 22
    v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x6c207b20
    v128.const i32x4 0x3a746665 0x202c3120 0x68676972 0x32203a74
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 3
    i32.const 0
    i32.const 34
    struct.new 43
    call 5
    v128.const i32x4 0x75727473 0x76207463 0x61697261 0x0000746e
    array.new_fixed 42 1
    i32.const 0
    i32.const 14
    struct.new 43
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
    array.new_fixed 42 1
    i32.const 0
    i32.const 6
    struct.new 43
    struct.new 28
    struct.new 32
    call 23
    v128.const i32x4 0x70617257 0x20726570 0x6176207b 0x3a65756c
    v128.const i32x4 0x696f5020 0x7b20746e 0x203a7820 0x6c202c33
    v128.const i32x4 0x6c656261 0x656e203a 0x64657473 0x7d207d20
    array.new_fixed 42 3
    i32.const 0
    i32.const 48
    struct.new 43
    call 5
    v128.const i32x4 0x656e6567 0x20636972 0x7473656e 0x00006465
    array.new_fixed 42 1
    i32.const 0
    i32.const 14
    struct.new 43
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;30;) (type 40) (param (ref 29) eqref)
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
                ref.cast (ref 29)
                struct.get 29 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              local.get 1
              v128.const i32x4 0x696f6843 0x3a3a6563 0x656e6f4e 0x00000000
              array.new_fixed 42 1
              i32.const 0
              i32.const 12
              struct.new 43
              call 10
              br 4 (;@1;)
            end
            local.get 5
            ref.cast (ref 30)
            struct.get 30 1
            local.set 2
            local.get 1
            v128.const i32x4 0x696f6843 0x3a3a6563 0x656d6f53 0x00000028
            array.new_fixed 42 1
            i32.const 0
            i32.const 13
            struct.new 43
            call 10
            local.get 1
            local.get 2
            call 18
            local.get 1
            v128.const i32x4 0x00000029 0x00000000 0x00000000 0x00000000
            array.new_fixed 42 1
            i32.const 0
            i32.const 1
            struct.new 43
            call 10
            br 3 (;@1;)
          end
          local.get 1
          v128.const i32x4 0x696f6843 0x3a3a6563 0x74706d45 0x72745379
          v128.const i32x4 0x20746375 0x00007d7b 0x00000000 0x00000000
          array.new_fixed 42 2
          i32.const 0
          i32.const 22
          struct.new 43
          call 10
          br 2 (;@1;)
        end
        local.get 5
        ref.cast (ref 31)
        struct.get 31 1
        local.set 3
        local.get 5
        ref.cast (ref 31)
        struct.get 31 7
        local.set 4
        local.get 1
        v128.const i32x4 0x696f6843 0x3a3a6563 0x72696150 0x00207b20
        array.new_fixed 42 1
        i32.const 0
        i32.const 15
        struct.new 43
        call 10
        local.get 1
        v128.const i32x4 0x7466656c 0x0000203a 0x00000000 0x00000000
        array.new_fixed 42 1
        i32.const 0
        i32.const 6
        struct.new 43
        call 10
        local.get 1
        local.get 3
        call 18
        local.get 1
        v128.const i32x4 0x6972202c 0x3a746867 0x00000020 0x00000000
        array.new_fixed 42 1
        i32.const 0
        i32.const 9
        struct.new 43
        call 10
        local.get 1
        local.get 4
        call 18
        local.get 1
        v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
        array.new_fixed 42 1
        i32.const 0
        i32.const 2
        struct.new 43
        call 10
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;31;) (type 41) (param (ref 32) eqref)
    local.get 1
    v128.const i32x4 0x70617257 0x20726570 0x0000207b 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 10
    struct.new 43
    call 10
    local.get 1
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 7
    struct.new 43
    call 10
    local.get 1
    local.get 0
    struct.get 32 5
    call 24
    local.get 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 42 1
    i32.const 0
    i32.const 2
    struct.new 43
    call 10
  )
)
