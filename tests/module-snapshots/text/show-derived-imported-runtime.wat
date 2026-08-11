(module
  (type (;0;) (func (param eqref eqref) (result i32)))
  (type (;1;) (func (result eqref)))
  (type (;2;) (func (param eqref eqref)))
  (type (;3;) (func (param eqref i32)))
  (type (;4;) (func (param eqref) (result eqref)))
  (type (;5;) (func (result eqref)))
  (type (;6;) (func (param eqref eqref)))
  (type (;7;) (func (param eqref i32)))
  (type (;8;) (func (param eqref) (result eqref)))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref eqref)))
  (type (;11;) (func (param eqref eqref)))
  (type (;12;) (func (param i64) (result i32)))
  (type (;13;) (func (param i32) (result i64)))
  (type (;14;) (func (param i64) (result i64)))
  (type (;15;) (func (param eqref i64)))
  (type (;16;) (func (param eqref i64)))
  (type (;17;) (func (param i32 eqref)))
  (type (;18;) (func (param eqref) (result eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (struct (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref)))
  (type (;21;) (func (param (ref 20) eqref)))
  (type (;22;) (func (param eqref) (result (ref 20))))
  (type (;23;) (func (param i32) (result (ref 20))))
  (type (;24;) (func (param (ref 20) eqref)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func))
  (type (;27;) (array (mut v128)))
  (type (;28;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;29;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;30;) (struct (field (ref 27)) (field i32) (field i32)))
  (type (;31;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (type (;32;) (struct (field (mut (ref 27))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 21))
  (func (;0;) (type 0) (param eqref eqref) (result i32)
    (local (ref 28) (ref 28) (ref 27) (ref 27) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 28)
    local.set 2
    local.get 1
    ref.cast (ref 28)
    local.set 3
    local.get 2
    struct.get 28 2
    local.tee 6
    local.get 3
    struct.get 28 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 28 0
    local.set 4
    local.get 3
    struct.get 28 0
    local.set 5
    local.get 2
    struct.get 28 1
    local.set 7
    local.get 3
    struct.get 28 1
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
          array.get 27
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 27
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
          array.get 27
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
          array.get 27
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 27
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
          array.get 27
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
      array.get 27
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
      array.get 27
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
    array.new_default 27
    i32.const 0
    i32.const 0
    struct.new 31
  )
  (func (;2;) (type 2) (param eqref eqref)
    (local (ref 31) (ref 28) (ref 27) (ref 27) i32 i32 i32 i32 i32 i32 (ref 27) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 31)
    local.set 2
    local.get 2
    struct.get 31 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 28)
    local.set 3
    local.get 2
    struct.get 31 0
    local.set 4
    local.get 3
    struct.get 28 0
    local.set 5
    local.get 2
    struct.get 31 1
    local.set 6
    local.get 3
    struct.get 28 1
    local.set 7
    local.get 3
    struct.get 28 2
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
      array.new_default 27
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
          array.get 27
          array.set 27
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 31 0
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
            array.get 27
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 27
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
            array.get 27
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
            array.set 27
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
            array.get 27
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
            array.set 27
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
            array.get 27
            local.get 19
            v128.bitselect
            array.set 27
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
        array.get 27
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
        array.get 27
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 27
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 31 1
  )
  (func (;3;) (type 3) (param eqref i32)
    (local (ref 31) (ref 27) i32 i32 i32 (ref 27) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 31)
    local.set 2
    local.get 2
    struct.get 31 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 31 0
    local.set 3
    local.get 2
    struct.get 31 1
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
      array.new_default 27
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
          array.get 27
          array.set 27
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 31 0
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
    array.get 27
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 27
    local.get 2
    local.get 5
    struct.set 31 1
  )
  (func (;4;) (type 4) (param eqref) (result eqref)
    (local (ref 31))
    local.get 0
    ref.cast (ref 31)
    local.set 1
    local.get 1
    struct.get 31 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 31 2
    local.get 1
    struct.get 31 0
    i32.const 0
    local.get 1
    struct.get 31 1
    struct.new 28
  )
  (func (;5;) (type 5) (result eqref)
    call 1
  )
  (func (;6;) (type 6) (param eqref eqref)
    local.get 0
    local.get 1
    call 2
  )
  (func (;7;) (type 7) (param eqref i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;8;) (type 8) (param eqref) (result eqref)
    local.get 0
    call 4
  )
  (func (;9;) (type 11) (param eqref eqref)
    local.get 0
    local.get 1
    call 6
  )
  (func (;10;) (type 12) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;11;) (type 13) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;12;) (type 14) (param i64) (result i64)
    local.get 0
  )
  (func (;13;) (type 15) (param eqref i64)
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
    call 10
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 7
  )
  (func (;14;) (type 16) (param eqref i64)
    (local i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 7
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 12
      i64.const 1
      i64.add
      local.set 2
      local.get 0
      local.get 2
      call 13
    else
      local.get 0
      local.get 1
      call 12
      call 13
    end
  )
  (func (;15;) (type 17) (param i32 eqref)
    local.get 1
    local.get 0
    call 11
    call 14
  )
  (func (;16;) (type 18) (param eqref) (result eqref)
    (local eqref)
    call 5
    local.set 1
    local.get 0
    ref.cast (ref 20)
    local.get 1
    call 19
    local.get 1
    call 8
  )
  (func (;17;) (type 19) (param eqref i32)
    local.get 1
    local.get 0
    call 15
  )
  (func (;18;) (type 23) (param i32) (result (ref 20))
    local.get 0
    i64.const 0
    f32.const 0x0p+0 (;=0;)
    f64.const 0x0p+0 (;=0;)
    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
    ref.null eq
    struct.new 20
    ref.cast (ref 20)
  )
  (func (;19;) (type 24) (param (ref 20) eqref)
    local.get 1
    v128.const i32x4 0x20786f42 0x0000207b 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 6
    struct.new 28
    call 9
    local.get 1
    v128.const i32x4 0x756c6176 0x00203a65 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 7
    struct.new 28
    call 9
    local.get 1
    local.get 0
    struct.get 20 0
    call 17
    local.get 1
    v128.const i32x4 0x00007d20 0x00000000 0x00000000 0x00000000
    array.new_fixed 27 1
    i32.const 0
    i32.const 2
    struct.new 28
    call 9
  )
  (func (;20;) (type 25) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;21;) (type 26)
    i32.const 7
    call 18
    call 16
    v128.const i32x4 0x20786f42 0x6176207b 0x3a65756c 0x7d203720
    array.new_fixed 27 1
    i32.const 0
    i32.const 16
    struct.new 28
    call 20
    v128.const i32x4 0x6f706d69 0x64657472 0x72656420 0x64657669
    v128.const i32x4 0x6f685320 0x00000077 0x00000000 0x00000000
    array.new_fixed 27 2
    i32.const 0
    i32.const 21
    struct.new 28
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
