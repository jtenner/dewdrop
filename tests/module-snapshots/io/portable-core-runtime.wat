(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (sub (struct (field i32))))
  (type (;9;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;10;) (sub final 8 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;11;) (func (param i32) (result eqref)))
  (type (;12;) (func (param eqref eqref)))
  (type (;13;) (func (param eqref) (result eqref)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref eqref) (result i32)))
  (type (;16;) (func (param eqref i32 i32) (result eqref)))
  (type (;17;) (func (param i32) (result eqref)))
  (type (;18;) (func (param eqref eqref)))
  (type (;19;) (func (param eqref) (result eqref)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref eqref) (result i32)))
  (type (;22;) (func (param eqref i32 i32) (result eqref)))
  (type (;23;) (sub (struct (field i32))))
  (type (;24;) (sub final 23 (struct (field i32) (field i32))))
  (type (;25;) (struct (field eqref) (field (ref 0))))
  (type (;26;) (struct (field eqref) (field (ref 0))))
  (type (;27;) (func (param eqref i32) (result (ref 8))))
  (type (;28;) (func (param eqref eqref) (result (ref 8))))
  (type (;29;) (func (param eqref) (result (ref 25))))
  (type (;30;) (func (param (ref 25) i32) (result (ref 8))))
  (type (;31;) (func (result (ref 26))))
  (type (;32;) (func (param i32) (result (ref 26))))
  (type (;33;) (func (param (ref 26)) (result i32)))
  (type (;34;) (func (param (ref 26)) (result i32)))
  (type (;35;) (func (param (ref 26)) (result (ref 8))))
  (type (;36;) (func (param (ref 26) eqref) (result (ref 8))))
  (type (;37;) (func (param eqref i32) (result (ref 8))))
  (type (;38;) (func (param eqref eqref) (result (ref 8))))
  (type (;39;) (func (result i32)))
  (type (;40;) (array (mut v128)))
  (type (;41;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;42;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;43;) (struct (field (ref 40)) (field i32) (field i32)))
  (type (;44;) (struct (field (mut (ref 40))) (field (mut i32)) (field (mut i32))))
  (type (;45;) (struct (field (mut (ref 40))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 22))
  (func (;0;) (type 11) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 40
    i32.const 0
    i32.const 0
    struct.new 45
  )
  (func (;1;) (type 12) (param eqref eqref)
    (local (ref 45) (ref 42) (ref 40) (ref 40) i32 i32 i32 i32 i32 i32 (ref 40) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 45)
    local.set 2
    local.get 2
    struct.get 45 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 42)
    local.set 3
    local.get 2
    struct.get 45 0
    local.set 4
    local.get 3
    struct.get 42 0
    local.set 5
    local.get 2
    struct.get 45 1
    local.set 6
    local.get 3
    struct.get 42 1
    local.set 7
    local.get 3
    struct.get 42 2
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
      array.new_default 40
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
          array.get 40
          array.set 40
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 45 0
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
            array.get 40
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 40
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
            array.get 40
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
            array.set 40
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
            array.get 40
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
            array.set 40
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
            array.get 40
            local.get 19
            v128.bitselect
            array.set 40
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
        array.get 40
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
        array.get 40
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 40
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 45 1
  )
  (func (;2;) (type 13) (param eqref) (result eqref)
    (local (ref 45))
    local.get 0
    ref.cast (ref 45)
    local.set 1
    local.get 1
    struct.get 45 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 45 2
    local.get 1
    struct.get 45 0
    i32.const 0
    local.get 1
    struct.get 45 1
    struct.new 42
  )
  (func (;3;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 42)
    struct.get 42 2
  )
  (func (;4;) (type 15) (param eqref eqref) (result i32)
    (local (ref 42) (ref 42) (ref 40) (ref 40) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 42)
    local.set 2
    local.get 1
    ref.cast (ref 42)
    local.set 3
    local.get 2
    struct.get 42 2
    local.tee 6
    local.get 3
    struct.get 42 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 42 0
    local.set 4
    local.get 3
    struct.get 42 0
    local.set 5
    local.get 2
    struct.get 42 1
    local.set 7
    local.get 3
    struct.get 42 1
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
          array.get 40
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 40
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
          array.get 40
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
          array.get 40
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 40
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
          array.get 40
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
      array.get 40
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
      array.get 40
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
  (func (;5;) (type 16) (param eqref i32 i32) (result eqref)
    (local (ref 42) i32)
    local.get 0
    ref.cast (ref 42)
    local.set 3
    local.get 3
    struct.get 42 2
    local.set 4
    local.get 1
    local.get 4
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.get 4
    local.get 1
    i32.sub
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    struct.get 42 0
    local.get 3
    struct.get 42 1
    local.get 1
    i32.add
    local.get 2
    struct.new 42
  )
  (func (;6;) (type 17) (param i32) (result eqref)
    local.get 0
    call 0
  )
  (func (;7;) (type 18) (param eqref eqref)
    local.get 0
    local.get 1
    call 1
  )
  (func (;8;) (type 19) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;9;) (type 20) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;10;) (type 21) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;11;) (type 22) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 5
  )
  (func (;12;) (type 29) (param eqref) (result (ref 25))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 25
    ref.cast (ref 25)
  )
  (func (;13;) (type 30) (param (ref 25) i32) (result (ref 8))
    (local i32 i32 i32 i32)
    local.get 0
    struct.get 25 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 2
    local.get 0
    struct.get 25 0
    call 9
    local.set 3
    local.get 2
    local.get 3
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      struct.new 23
      struct.new 10
    else
      local.get 1
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 2
        local.get 3
        i32.eq
      end
      if (result eqref) ;; label = @2
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        array.new_fixed 40 0
        i32.const 0
        i32.const 0
        struct.new 42
        struct.new 9
      else
        local.get 3
        local.get 2
        i32.sub
        local.set 4
        local.get 1
        local.get 4
        i32.lt_u
        if (result i32) ;; label = @3
          local.get 1
        else
          local.get 4
        end
        local.set 5
        local.get 0
        struct.get 25 1
        ref.cast (ref 0)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 0
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        struct.get 25 0
        local.get 2
        local.get 5
        call 11
        struct.new 9
      end
    end
    ref.cast (ref 8)
  )
  (func (;14;) (type 31) (result (ref 26))
    i32.const 0
    call 15
    ref.cast (ref 26)
  )
  (func (;15;) (type 32) (param i32) (result (ref 26))
    (local eqref i32)
    local.get 0
    call 6
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 26
    ref.cast (ref 26)
  )
  (func (;16;) (type 33) (param (ref 26)) (result i32)
    local.get 0
    struct.get 26 1
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
  (func (;17;) (type 34) (param (ref 26)) (result i32)
    local.get 0
    struct.get 26 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
  )
  (func (;18;) (type 35) (param (ref 26)) (result (ref 8))
    local.get 0
    call 17
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 23
      struct.new 10
    else
      local.get 0
      struct.get 26 1
      ref.cast (ref 0)
      i32.const 0
      i32.const 1
      array.set 0
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      struct.get 26 0
      call 8
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;19;) (type 36) (param (ref 26) eqref) (result (ref 8))
    (local i32 i32)
    local.get 0
    call 17
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 23
      struct.new 10
    else
      local.get 1
      call 9
      local.set 2
      local.get 0
      call 16
      local.set 3
      local.get 2
      i32.const -1
      local.get 3
      i32.sub
      i32.gt_u
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 4
        struct.new 23
        struct.new 10
      else
        local.get 0
        struct.get 26 0
        local.get 1
        call 7
        local.get 0
        struct.get 26 1
        ref.cast (ref 0)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 0
        i32.const 0
        local.get 2
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 9
      end
    end
    ref.cast (ref 8)
  )
  (func (;20;) (type 37) (param eqref i32) (result (ref 8))
    (local eqref i32 eqref i32 (ref 23) eqref i32 eqref)
    local.get 1
    call 6
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              ref.cast (ref 25)
              local.get 1
              local.get 3
              i32.sub
              call 13
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 9)
                    struct.get 9 6
                    local.set 4
                    local.get 4
                    call 9
                    local.set 5
                    local.get 5
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 1
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      i32.const 0
                      struct.new 23
                      struct.new 10
                      local.set 9
                      br 8 (;@1;)
                    else
                      local.get 5
                      local.get 1
                      local.get 3
                      i32.sub
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 2
                        struct.new 23
                        struct.new 10
                        local.set 9
                        br 9 (;@1;)
                      else
                        local.get 2
                        local.get 4
                        call 7
                        local.get 3
                        local.get 5
                        i32.add
                        local.set 8
                        br 8 (;@2;)
                      end
                    end
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 10)
                  struct.get 10 6
                  ref.cast (ref 23)
                  local.set 6
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 6
                  struct.new 10
                  local.set 9
                  br 6 (;@1;)
                  br 1 (;@6;)
                end
                unreachable
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 2
            call 8
            struct.new 9
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 8)
  )
  (func (;21;) (type 38) (param eqref eqref) (result (ref 8))
    (local i32 i32 eqref i32 (ref 23) eqref i32 eqref)
    local.get 1
    call 9
    local.set 2
    i32.const 0
    local.set 8
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 1
              local.get 3
              local.get 2
              local.get 3
              i32.sub
              call 11
              local.set 4
              local.get 0
              ref.cast (ref 26)
              local.get 4
              call 19
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 9)
                    struct.get 9 1
                    local.set 5
                    local.get 5
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 1
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      i32.const 1
                      struct.new 23
                      struct.new 10
                      local.set 9
                      br 8 (;@1;)
                    else
                      local.get 5
                      local.get 2
                      local.get 3
                      i32.sub
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 2
                        struct.new 23
                        struct.new 10
                        local.set 9
                        br 9 (;@1;)
                      else
                        local.get 3
                        local.get 5
                        i32.add
                        local.set 8
                        br 8 (;@2;)
                      end
                    end
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 10)
                  struct.get 10 6
                  ref.cast (ref 23)
                  local.set 6
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 6
                  struct.new 10
                  local.set 9
                  br 6 (;@1;)
                  br 1 (;@6;)
                end
                unreachable
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.get 2
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            ref.null eq
            struct.new 9
            local.set 9
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 9
    ref.cast (ref 8)
  )
  (func (;22;) (type 39) (result i32)
    (local eqref eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x74726f70 0x656c6261 0x00000000 0x00000000
    array.new_fixed 40 1
    i32.const 0
    i32.const 8
    struct.new 42
    call 12
    local.set 0
    call 14
    local.set 1
    local.get 0
    i32.const 8
    call 20
    local.set 8
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 8
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 9)
          struct.get 9 6
          local.set 2
          local.get 1
          local.get 2
          call 21
          local.set 6
          block ;; label = @4
            local.get 6
            ref.cast (ref 8)
            struct.get 8 0
            i32.const 0
            i32.eq
            if (result i32) ;; label = @5
              local.get 6
              ref.cast (ref 9)
              struct.get 9 1
              i32.const 8
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 1
              ref.cast (ref 26)
              call 18
              local.set 4
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 4
                      ref.cast (ref 8)
                      struct.get 8 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 4
                    ref.cast (ref 9)
                    struct.get 9 6
                    local.set 3
                    local.get 3
                    v128.const i32x4 0x74726f70 0x656c6261 0x00000000 0x00000000
                    array.new_fixed 40 1
                    i32.const 0
                    i32.const 8
                    struct.new 42
                    call 10
                    local.set 5
                    br 2 (;@6;)
                  end
                  i32.const 0
                  local.set 5
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 5
              local.set 7
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 0
              local.set 7
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 7
          local.set 9
          br 2 (;@1;)
        end
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
  )
)
