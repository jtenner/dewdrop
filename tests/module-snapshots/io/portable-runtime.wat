(module
  (type (;0;) (sub (struct (field i32))))
  (type (;1;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;2;) (sub final 0 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;3;) (struct (field eqref)))
  (type (;4;) (func (param i32) (result eqref)))
  (type (;5;) (func (param eqref eqref)))
  (type (;6;) (func (param eqref) (result eqref)))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (func (param eqref eqref) (result i32)))
  (type (;9;) (func (param eqref i32 i32) (result eqref)))
  (type (;10;) (func (param i32) (result eqref)))
  (type (;11;) (func (param eqref eqref)))
  (type (;12;) (func (param eqref) (result eqref)))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param eqref eqref) (result i32)))
  (type (;15;) (func (param eqref i32 i32) (result eqref)))
  (type (;16;) (sub (struct (field i32))))
  (type (;17;) (sub final 16 (struct (field i32) (field i32))))
  (type (;18;) (struct (field eqref) (field (ref 3))))
  (type (;19;) (struct (field eqref) (field (ref 3))))
  (type (;20;) (func (param eqref i32) (result (ref 0))))
  (type (;21;) (func (param eqref eqref) (result (ref 0))))
  (type (;22;) (func (param eqref) (result (ref 18))))
  (type (;23;) (func (param (ref 18) i32) (result (ref 0))))
  (type (;24;) (func (param i32) (result (ref 19))))
  (type (;25;) (func (param (ref 19)) (result i32)))
  (type (;26;) (func (param (ref 19)) (result i32)))
  (type (;27;) (func (param (ref 19)) (result (ref 0))))
  (type (;28;) (func (param (ref 19) eqref) (result (ref 0))))
  (type (;29;) (func (param eqref i32) (result (ref 0))))
  (type (;30;) (func (param eqref eqref) (result (ref 0))))
  (type (;31;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;32;) (func (param i32 eqref) (result i32)))
  (type (;33;) (func (param (ref 0)) (result eqref)))
  (type (;34;) (func (result i32)))
  (type (;35;) (array (mut v128)))
  (type (;36;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;37;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;38;) (struct (field (ref 35)) (field i32) (field i32)))
  (type (;39;) (struct (field (mut (ref 35))) (field (mut i32)) (field (mut i32))))
  (type (;40;) (struct (field (mut (ref 35))) (field (mut i32)) (field (mut i32))))
  (type (;41;) (array (mut i32)))
  (type (;42;) (array (mut i64)))
  (type (;43;) (array (mut f32)))
  (type (;44;) (array (mut f64)))
  (type (;45;) (array (mut v128)))
  (type (;46;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 31)))
  (memory (;0;) 1)
  (export "main" (func 24))
  (export "memory" (memory 0))
  (func (;1;) (type 4) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 35
    i32.const 0
    i32.const 0
    struct.new 40
  )
  (func (;2;) (type 5) (param eqref eqref)
    (local (ref 40) (ref 37) (ref 35) (ref 35) i32 i32 i32 i32 i32 i32 (ref 35) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 40)
    local.set 2
    local.get 2
    struct.get 40 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 37)
    local.set 3
    local.get 2
    struct.get 40 0
    local.set 4
    local.get 3
    struct.get 37 0
    local.set 5
    local.get 2
    struct.get 40 1
    local.set 6
    local.get 3
    struct.get 37 1
    local.set 7
    local.get 3
    struct.get 37 2
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
      array.new_default 35
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
          array.get 35
          array.set 35
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 40 0
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
            array.get 35
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 35
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
            array.get 35
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
            array.set 35
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
            array.get 35
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
            array.set 35
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
            array.get 35
            local.get 19
            v128.bitselect
            array.set 35
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
        array.get 35
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
        array.get 35
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 35
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 40 1
  )
  (func (;3;) (type 6) (param eqref) (result eqref)
    (local (ref 40))
    local.get 0
    ref.cast (ref 40)
    local.set 1
    local.get 1
    struct.get 40 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 40 2
    local.get 1
    struct.get 40 0
    i32.const 0
    local.get 1
    struct.get 40 1
    struct.new 37
  )
  (func (;4;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 37)
    struct.get 37 2
  )
  (func (;5;) (type 8) (param eqref eqref) (result i32)
    (local (ref 37) (ref 37) (ref 35) (ref 35) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 37)
    local.set 2
    local.get 1
    ref.cast (ref 37)
    local.set 3
    local.get 2
    struct.get 37 2
    local.tee 6
    local.get 3
    struct.get 37 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 37 0
    local.set 4
    local.get 3
    struct.get 37 0
    local.set 5
    local.get 2
    struct.get 37 1
    local.set 7
    local.get 3
    struct.get 37 1
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
  (func (;6;) (type 9) (param eqref i32 i32) (result eqref)
    (local (ref 37) i32)
    local.get 0
    ref.cast (ref 37)
    local.set 3
    local.get 3
    struct.get 37 2
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
    struct.get 37 0
    local.get 3
    struct.get 37 1
    local.get 1
    i32.add
    local.get 2
    struct.new 37
  )
  (func (;7;) (type 10) (param i32) (result eqref)
    local.get 0
    call 1
  )
  (func (;8;) (type 11) (param eqref eqref)
    local.get 0
    local.get 1
    call 2
  )
  (func (;9;) (type 12) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;10;) (type 13) (param eqref) (result i32)
    local.get 0
    call 4
  )
  (func (;11;) (type 14) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;12;) (type 15) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 6
  )
  (func (;13;) (type 22) (param eqref) (result (ref 18))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 41
    struct.new 3
    ref.cast (ref 3)
    struct.new 18
    ref.cast (ref 18)
  )
  (func (;14;) (type 23) (param (ref 18) i32) (result (ref 0))
    (local i32 i32 i32 i32)
    local.get 0
    struct.get 18 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 41)
    i32.const 0
    array.get 41
    local.set 2
    local.get 0
    struct.get 18 0
    call 10
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
      struct.new 16
      struct.new 2
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
        array.new_fixed 35 0
        i32.const 0
        i32.const 0
        struct.new 37
        struct.new 1
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
        struct.get 18 1
        ref.cast (ref 3)
        struct.get 3 0
        ref.cast (ref 41)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 41
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        struct.get 18 0
        local.get 2
        local.get 5
        call 12
        struct.new 1
      end
    end
    ref.cast (ref 0)
  )
  (func (;15;) (type 24) (param i32) (result (ref 19))
    (local eqref i32)
    local.get 0
    call 7
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 41
    struct.new 3
    ref.cast (ref 3)
    struct.new 19
    ref.cast (ref 19)
  )
  (func (;16;) (type 25) (param (ref 19)) (result i32)
    local.get 0
    struct.get 19 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 41)
    i32.const 1
    array.get 41
  )
  (func (;17;) (type 26) (param (ref 19)) (result i32)
    local.get 0
    struct.get 19 1
    ref.cast (ref 3)
    struct.get 3 0
    ref.cast (ref 41)
    i32.const 0
    array.get 41
    i32.const 0
    i32.ne
  )
  (func (;18;) (type 27) (param (ref 19)) (result (ref 0))
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
      struct.new 16
      struct.new 2
    else
      local.get 0
      struct.get 19 1
      ref.cast (ref 3)
      struct.get 3 0
      ref.cast (ref 41)
      i32.const 0
      i32.const 1
      array.set 41
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      struct.get 19 0
      call 9
      struct.new 1
    end
    ref.cast (ref 0)
  )
  (func (;19;) (type 28) (param (ref 19) eqref) (result (ref 0))
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
      struct.new 16
      struct.new 2
    else
      local.get 1
      call 10
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
        struct.new 16
        struct.new 2
      else
        local.get 0
        struct.get 19 0
        local.get 1
        call 8
        local.get 0
        struct.get 19 1
        ref.cast (ref 3)
        struct.get 3 0
        ref.cast (ref 41)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 41
        i32.const 0
        local.get 2
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 1
      end
    end
    ref.cast (ref 0)
  )
  (func (;20;) (type 29) (param eqref i32) (result (ref 0))
    (local eqref i32 eqref i32 (ref 16) eqref i32 eqref)
    local.get 1
    call 7
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
              ref.cast (ref 18)
              local.get 1
              local.get 3
              i32.sub
              call 14
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 0)
                      struct.get 0 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 1)
                    struct.get 1 6
                    local.set 4
                    local.get 4
                    call 10
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
                      struct.new 16
                      struct.new 2
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
                        struct.new 16
                        struct.new 2
                        local.set 9
                        br 9 (;@1;)
                      else
                        local.get 2
                        local.get 4
                        call 8
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
                  ref.cast (ref 2)
                  struct.get 2 6
                  ref.cast (ref 16)
                  local.set 6
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 6
                  struct.new 2
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
            call 9
            struct.new 1
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
    ref.cast (ref 0)
  )
  (func (;21;) (type 30) (param eqref eqref) (result (ref 0))
    (local i32 i32 eqref i32 (ref 16) eqref i32 eqref)
    local.get 1
    call 10
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
              call 12
              local.set 4
              local.get 0
              ref.cast (ref 19)
              local.get 4
              call 19
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 0)
                      struct.get 0 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 1)
                    struct.get 1 1
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
                      struct.new 16
                      struct.new 2
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
                        struct.new 16
                        struct.new 2
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
                  ref.cast (ref 2)
                  struct.get 2 6
                  ref.cast (ref 16)
                  local.set 6
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 6
                  struct.new 2
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
            struct.new 1
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
    ref.cast (ref 0)
  )
  (func (;22;) (type 32) (param i32 eqref) (result i32)
    (local (ref 37) (ref 35) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 37)
    local.set 2
    local.get 2
    struct.get 37 0
    local.set 3
    local.get 2
    struct.get 37 1
    local.set 4
    local.get 2
    struct.get 37 2
    local.set 5
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        local.get 6
        local.get 5
        i32.ge_u
        br_if 1 (;@1;)
        local.get 5
        local.get 6
        i32.sub
        local.tee 7
        i32.const 65520
        i32.gt_u
        if ;; label = @3
          i32.const 65520
          local.set 7
        end
        i32.const 0
        local.set 8
        block ;; label = @3
          loop ;; label = @4
            local.get 8
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            local.get 4
            local.get 6
            i32.add
            local.get 8
            i32.add
            local.set 9
            local.get 9
            i32.const 15
            i32.and
            i32.eqz
            local.get 8
            i32.const 64
            i32.add
            local.get 7
            i32.le_u
            i32.and
            if ;; label = @5
              i32.const 16
              local.get 8
              i32.add
              local.get 3
              local.get 9
              i32.const 4
              i32.shr_u
              array.get 35
              v128.store
              i32.const 16
              local.get 8
              i32.const 16
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 16
              i32.add
              i32.const 4
              i32.shr_u
              array.get 35
              v128.store
              i32.const 16
              local.get 8
              i32.const 32
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 32
              i32.add
              i32.const 4
              i32.shr_u
              array.get 35
              v128.store
              i32.const 16
              local.get 8
              i32.const 48
              i32.add
              i32.add
              local.get 3
              local.get 9
              i32.const 48
              i32.add
              i32.const 4
              i32.shr_u
              array.get 35
              v128.store
              local.get 8
              i32.const 64
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 8
            i32.const 16
            i32.add
            local.get 7
            i32.le_u
            if ;; label = @5
              local.get 9
              i32.const 15
              i32.and
              i32.eqz
              if ;; label = @6
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 35
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 35
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
                i32.const 15
                i32.and
                i8x16.splat
                i8x16.add
                i8x16.swizzle
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                i32.const 1
                i32.add
                array.get 35
                v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
                local.get 9
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
              i32.const 16
              local.get 8
              i32.add
              local.get 11
              v128.store
              local.get 8
              i32.const 16
              i32.add
              local.set 8
              br 1 (;@4;)
            end
            local.get 3
            local.get 9
            i32.const 4
            i32.shr_u
            array.get 35
            local.get 9
            i32.const 15
            i32.and
            i8x16.splat
            i8x16.swizzle
            i8x16.extract_lane_u 0
            local.set 10
            i32.const 16
            local.get 8
            i32.add
            local.get 10
            i32.store8
            local.get 8
            i32.const 1
            i32.add
            local.set 8
            br 0 (;@4;)
          end
        end
        i32.const 0
        local.set 13
        block ;; label = @3
          loop ;; label = @4
            local.get 13
            local.get 7
            i32.ge_u
            br_if 1 (;@3;)
            i32.const 0
            i32.const 16
            local.get 13
            i32.add
            i32.store
            i32.const 4
            local.get 7
            local.get 13
            i32.sub
            i32.store
            local.get 0
            i32.const 0
            i32.const 1
            i32.const 8
            call 0
            i32.const 0
            i32.ne
            if ;; label = @5
              unreachable
            end
            i32.const 8
            i32.load
            local.tee 12
            i32.eqz
            local.get 12
            local.get 7
            local.get 13
            i32.sub
            i32.gt_u
            i32.or
            if ;; label = @5
              unreachable
            end
            local.get 13
            local.get 12
            i32.add
            local.set 13
            br 0 (;@4;)
          end
        end
        local.get 6
        local.get 7
        i32.add
        local.set 6
        br 0 (;@2;)
      end
    end
    local.get 6
  )
  (func (;23;) (type 33) (param (ref 0)) (result eqref)
    (local eqref eqref eqref)
    local.get 0
    local.set 2
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 2
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 2
          ref.cast (ref 1)
          struct.get 1 6
          local.set 1
          local.get 1
          local.set 3
          br 2 (;@1;)
        end
        array.new_fixed 35 0
        i32.const 0
        i32.const 0
        struct.new 37
        local.set 3
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 3
  )
  (func (;24;) (type 34) (result i32)
    (local eqref eqref eqref eqref eqref eqref eqref eqref i32 i32 eqref i32 eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x74726f70 0x656c6261 0x706e6920 0x00007475
    array.new_fixed 35 1
    i32.const 0
    i32.const 14
    struct.new 37
    call 13
    local.set 0
    local.get 0
    i32.const 8
    call 20
    call 23
    local.set 1
    local.get 0
    i32.const 6
    call 20
    call 23
    local.set 2
    i32.const 14
    call 15
    local.set 3
    local.get 3
    local.get 1
    call 21
    local.set 4
    local.get 3
    local.get 2
    call 21
    local.set 5
    local.get 3
    ref.cast (ref 19)
    call 18
    local.set 6
    local.get 6
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 0)
            struct.get 0 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 10
          ref.cast (ref 1)
          struct.get 1 6
          local.set 7
          local.get 7
          v128.const i32x4 0x74726f70 0x656c6261 0x706e6920 0x00007475
          array.new_fixed 35 1
          i32.const 0
          i32.const 14
          struct.new 37
          call 11
          local.set 11
          br 2 (;@1;)
        end
        i32.const 0
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    local.set 8
    local.get 4
    local.set 12
    block ;; label = @1
      local.get 12
      ref.cast (ref 0)
      struct.get 0 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 12
        ref.cast (ref 1)
        struct.get 1 1
        i32.const 8
        i32.eq
      else
        i32.const 0
      end
      if ;; label = @2
        i32.const 1
        local.set 13
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 13
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 13
    if (result i32) ;; label = @1
      local.get 5
      local.set 14
      block ;; label = @2
        local.get 14
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 14
          ref.cast (ref 1)
          struct.get 1 1
          i32.const 6
          i32.eq
        else
          i32.const 0
        end
        if ;; label = @3
          i32.const 1
          local.set 15
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 15
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 15
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 8
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      i32.const 1
      call 20
      local.set 16
      block ;; label = @2
        local.get 16
        ref.cast (ref 0)
        struct.get 0 0
        i32.const 1
        i32.eq
        if (result i32) ;; label = @3
          local.get 16
          ref.cast (ref 2)
          struct.get 2 6
          ref.cast (ref 16)
          struct.get 16 0
          i32.const 0
          i32.eq
          if (result i32) ;; label = @4
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
        if ;; label = @3
          i32.const 1
          local.set 17
          br 1 (;@2;)
        end
        i32.const 1
        if ;; label = @3
          i32.const 0
          local.set 17
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 17
    else
      i32.const 0
    end
    local.set 9
    local.get 9
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x703a6f69 0x6174726f 0x00656c62 0x00000000
      array.new_fixed 35 1
      i32.const 0
      i32.const 11
      struct.new 37
      call 22
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 35 1
      i32.const 0
      i32.const 4
      struct.new 37
      call 22
    end
  )
)
