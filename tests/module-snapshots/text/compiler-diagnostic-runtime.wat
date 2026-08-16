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
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (param eqref eqref) (result i32)))
  (type (;13;) (func (param i32) (result eqref)))
  (type (;14;) (func (param eqref eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref eqref) (result i32)))
  (type (;19;) (sub (struct (field funcref))))
  (type (;20;) (func (param eqref) (result eqref)))
  (type (;21;) (func (param eqref i32) (result eqref)))
  (type (;22;) (func (param eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref)))
  (type (;24;) (func (param eqref i32)))
  (type (;25;) (func (param eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref i32) (result eqref)))
  (type (;28;) (func (param eqref eqref eqref) (result eqref)))
  (type (;29;) (func (param eqref eqref)))
  (type (;30;) (func (param eqref eqref i32)))
  (type (;31;) (func (param eqref eqref) (result i32)))
  (type (;32;) (func (param eqref eqref i32) (result i32)))
  (type (;33;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;34;) (func (param i64) (result i32)))
  (type (;35;) (func (param i32) (result i64)))
  (type (;36;) (func (param eqref i64)))
  (type (;37;) (func (param i32) (result eqref)))
  (type (;38;) (func (param eqref eqref)))
  (type (;39;) (func (param eqref i32)))
  (type (;40;) (func (param eqref i32)))
  (type (;41;) (func (param eqref) (result eqref)))
  (type (;42;) (sub (struct (field i32))))
  (type (;43;) (struct (field eqref) (field i32) (field i32) (field i32) (field (ref 42)) (field eqref) (field eqref)))
  (type (;44;) (sub (struct (field i32))))
  (type (;45;) (sub final 44 (struct (field i32) (field i64) (field i32))))
  (type (;46;) (func (param i64) (result i32)))
  (type (;47;) (func (param i32) (result i64)))
  (type (;48;) (func (param (ref 42)) (result eqref)))
  (type (;49;) (func (param (ref 43) eqref) (result i64)))
  (type (;50;) (func (param (ref 43) i32) (result (ref 8))))
  (type (;51;) (func))
  (type (;52;) (array (mut v128)))
  (type (;53;) (struct (field (ref 52)) (field i32) (field i32)))
  (type (;54;) (struct (field (ref 52)) (field i32) (field i32)))
  (type (;55;) (struct (field (ref 52)) (field i32) (field i32)))
  (type (;56;) (struct (field (mut (ref 52))) (field (mut i32)) (field (mut i32))))
  (type (;57;) (struct (field (mut (ref 52))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 21))
  (func (;0;) (type 11) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 53)
    struct.get 53 2
  )
  (func (;1;) (type 12) (param eqref eqref) (result i32)
    (local (ref 53) (ref 53) (ref 52) (ref 52) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 53)
    local.set 2
    local.get 1
    ref.cast (ref 53)
    local.set 3
    local.get 2
    struct.get 53 2
    local.tee 6
    local.get 3
    struct.get 53 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 53 0
    local.set 4
    local.get 3
    struct.get 53 0
    local.set 5
    local.get 2
    struct.get 53 1
    local.set 7
    local.get 3
    struct.get 53 1
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
          array.get 52
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 52
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
          array.get 52
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
          array.get 52
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 52
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
          array.get 52
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
      array.get 52
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
      array.get 52
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
  (func (;2;) (type 13) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 52
    i32.const 0
    i32.const 0
    struct.new 56
  )
  (func (;3;) (type 14) (param eqref eqref)
    (local (ref 56) (ref 53) (ref 52) (ref 52) i32 i32 i32 i32 i32 i32 (ref 52) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 56)
    local.set 2
    local.get 2
    struct.get 56 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 53)
    local.set 3
    local.get 2
    struct.get 56 0
    local.set 4
    local.get 3
    struct.get 53 0
    local.set 5
    local.get 2
    struct.get 56 1
    local.set 6
    local.get 3
    struct.get 53 1
    local.set 7
    local.get 3
    struct.get 53 2
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
      array.new_default 52
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
          array.get 52
          array.set 52
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 56 0
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
            array.get 52
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 52
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
            array.get 52
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
            array.set 52
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
            array.get 52
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
            array.set 52
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
            array.get 52
            local.get 19
            v128.bitselect
            array.set 52
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
        array.get 52
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
        array.get 52
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 52
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 56 1
  )
  (func (;4;) (type 15) (param eqref i32)
    (local (ref 56) (ref 52) i32 i32 i32 (ref 52) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 56)
    local.set 2
    local.get 2
    struct.get 56 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 56 0
    local.set 3
    local.get 2
    struct.get 56 1
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
      array.new_default 52
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
          array.get 52
          array.set 52
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 56 0
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
    array.get 52
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 52
    local.get 2
    local.get 5
    struct.set 56 1
  )
  (func (;5;) (type 16) (param eqref) (result eqref)
    (local (ref 56))
    local.get 0
    ref.cast (ref 56)
    local.set 1
    local.get 1
    struct.get 56 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 56 2
    local.get 1
    struct.get 56 0
    i32.const 0
    local.get 1
    struct.get 56 1
    struct.new 53
  )
  (func (;6;) (type 17) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;7;) (type 18) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;8;) (type 34) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;9;) (type 35) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;10;) (type 36) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 10
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 8
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 4
  )
  (func (;11;) (type 37) (param i32) (result eqref)
    local.get 0
    call 2
  )
  (func (;12;) (type 38) (param eqref eqref)
    local.get 0
    local.get 1
    call 3
  )
  (func (;13;) (type 39) (param eqref i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;14;) (type 40) (param eqref i32)
    local.get 0
    local.get 1
    call 9
    call 10
  )
  (func (;15;) (type 41) (param eqref) (result eqref)
    local.get 0
    call 5
  )
  (func (;16;) (type 46) (param i64) (result i32)
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
      call 16
      i32.add
    end
  )
  (func (;17;) (type 47) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;18;) (type 48) (param (ref 42)) (result eqref)
    (local eqref eqref)
    local.get 0
    local.set 1
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 1
                ref.cast (ref 42)
                struct.get 42 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;) 3 (;@3;) 4 (;@2;)
              end
              v128.const i32x4 0x6f727265 0x00000072 0x00000000 0x00000000
              array.new_fixed 52 1
              i32.const 0
              i32.const 5
              struct.new 53
              local.set 2
              br 4 (;@1;)
            end
            v128.const i32x4 0x6e726177 0x00676e69 0x00000000 0x00000000
            array.new_fixed 52 1
            i32.const 0
            i32.const 7
            struct.new 53
            local.set 2
            br 3 (;@1;)
          end
          v128.const i32x4 0x6f666e69 0x00000000 0x00000000 0x00000000
          array.new_fixed 52 1
          i32.const 0
          i32.const 4
          struct.new 53
          local.set 2
          br 2 (;@1;)
        end
        v128.const i32x4 0x746e6968 0x00000000 0x00000000 0x00000000
        array.new_fixed 52 1
        i32.const 0
        i32.const 4
        struct.new 53
        local.set 2
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 2
  )
  (func (;19;) (type 49) (param (ref 43) eqref) (result i64)
    local.get 0
    struct.get 43 0
    call 6
    call 17
    local.get 0
    struct.get 43 1
    call 17
    call 16
    call 17
    i64.add
    local.get 0
    struct.get 43 2
    call 17
    call 16
    call 17
    i64.add
    local.get 1
    call 6
    call 17
    i64.add
    local.get 0
    struct.get 43 5
    call 6
    call 17
    i64.add
    local.get 0
    struct.get 43 6
    call 6
    call 17
    i64.add
    local.get 0
    struct.get 43 3
    call 17
    call 16
    call 17
    i64.add
    i64.const 16
    i64.add
  )
  (func (;20;) (type 50) (param (ref 43) i32) (result (ref 8))
    (local eqref i64 eqref)
    local.get 0
    struct.get 43 4
    call 18
    local.set 2
    local.get 0
    local.get 2
    call 19
    local.set 3
    local.get 3
    local.get 1
    call 17
    i64.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 0
      local.get 3
      local.get 1
      struct.new 45
      struct.new 10
    else
      local.get 3
      i32.wrap_i64
      call 11
      local.set 4
      local.get 4
      local.get 0
      struct.get 43 0
      call 12
      local.get 4
      i32.const 58
      call 13
      local.get 4
      local.get 0
      struct.get 43 1
      call 14
      local.get 4
      i32.const 58
      call 13
      local.get 4
      local.get 0
      struct.get 43 2
      call 14
      local.get 4
      v128.const i32x4 0x0000203a 0x00000000 0x00000000 0x00000000
      array.new_fixed 52 1
      i32.const 0
      i32.const 2
      struct.new 53
      call 12
      local.get 4
      local.get 2
      call 12
      local.get 4
      i32.const 91
      call 13
      local.get 4
      local.get 0
      struct.get 43 5
      call 12
      local.get 4
      v128.const i32x4 0x00203a5d 0x00000000 0x00000000 0x00000000
      array.new_fixed 52 1
      i32.const 0
      i32.const 3
      struct.new 53
      call 12
      local.get 4
      local.get 0
      struct.get 43 6
      call 12
      local.get 4
      v128.const i32x4 0x79622820 0x00206574 0x00000000 0x00000000
      array.new_fixed 52 1
      i32.const 0
      i32.const 7
      struct.new 53
      call 12
      local.get 4
      local.get 0
      struct.get 43 3
      call 14
      local.get 4
      i32.const 41
      call 13
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 4
      call 15
      struct.new 9
    end
    ref.cast (ref 8)
  )
  (func (;21;) (type 51)
    (local eqref eqref i64 i32 eqref eqref)
    v128.const i32x4 0x2f637273 0x6e69616d 0x7765642e 0x00000000
    array.new_fixed 52 1
    i32.const 0
    i32.const 12
    struct.new 53
    i32.const -1
    i32.const 17
    i32.const 99
    i32.const 0
    struct.new 42
    ref.cast (ref 42)
    v128.const i32x4 0x30303145 0x00000000 0x00000000 0x00000000
    array.new_fixed 52 1
    i32.const 0
    i32.const 4
    struct.new 53
    v128.const i32x4 0x20646162 0x756c6176 0x65730a65 0x646e6f63
    v128.const i32x4 0x6e696c20 0x00000065 0x00000000 0x00000000
    array.new_fixed 52 2
    i32.const 0
    i32.const 21
    struct.new 53
    struct.new 43
    local.set 0
    local.get 0
    ref.cast (ref 43)
    i32.const 256
    call 20
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 4
          ref.cast (ref 9)
          struct.get 9 6
          local.set 1
          local.get 1
          v128.const i32x4 0x2f637273 0x6e69616d 0x7765642e 0x3932343a
          v128.const i32x4 0x37363934 0x3a353932 0x203a3731 0x6f727265
          v128.const i32x4 0x31455b72 0x3a5d3030 0x64616220 0x6c617620
          v128.const i32x4 0x730a6575 0x6e6f6365 0x696c2064 0x2820656e
          v128.const i32x4 0x65747962 0x29393920 0x00000000 0x00000000
          array.new_fixed 52 5
          i32.const 0
          i32.const 72
          struct.new 53
          call 7
          v128.const i32x4 0x706d6f63 0x72656c69 0x61696420 0x736f6e67
          v128.const i32x4 0x20636974 0x74786574 0x61686320 0x6465676e
          array.new_fixed 52 2
          i32.const 0
          i32.const 32
          struct.new 53
          drop
          i32.eqz
          if ;; label = @4
            unreachable
          end
          br 2 (;@1;)
        end
        i32.const 0
        v128.const i32x4 0x706d6f63 0x72656c69 0x61696420 0x736f6e67
        v128.const i32x4 0x20636974 0x78656e75 0x74636570 0x796c6465
        v128.const i32x4 0x63786520 0x65646565 0x696c2064 0x0074696d
        array.new_fixed 52 3
        i32.const 0
        i32.const 47
        struct.new 53
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 0
    ref.cast (ref 43)
    i32.const 8
    call 20
    local.set 5
    block ;; label = @1
      local.get 5
      ref.cast (ref 8)
      struct.get 8 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 5
        ref.cast (ref 10)
        struct.get 10 6
        ref.cast (ref 44)
        struct.get 44 0
        i32.const 0
        i32.eq
        if (result i32) ;; label = @3
          local.get 5
          ref.cast (ref 10)
          struct.get 10 6
          ref.cast (ref 45)
          struct.get 45 1
          local.set 2
          i32.const 1
          if (result i32) ;; label = @4
            local.get 5
            ref.cast (ref 10)
            struct.get 10 6
            ref.cast (ref 45)
            struct.get 45 2
            local.set 3
            i32.const 1
          else
            i32.const 0
          end
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        i64.const 72
        i64.eq
        v128.const i32x4 0x6e6f7277 0x65722067 0x72697571 0x64206465
        v128.const i32x4 0x6e676169 0x6974736f 0x79622063 0x63206574
        v128.const i32x4 0x746e756f 0x00000000 0x00000000 0x00000000
        array.new_fixed 52 3
        i32.const 0
        i32.const 36
        struct.new 53
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        local.get 3
        i32.const 8
        i32.eq
        v128.const i32x4 0x6e6f7277 0x69642067 0x6f6e6761 0x63697473
        v128.const i32x4 0x6d696c20 0x00007469 0x00000000 0x00000000
        array.new_fixed 52 2
        i32.const 0
        i32.const 22
        struct.new 53
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        v128.const i32x4 0x6c616d73 0x6964206c 0x6f6e6761 0x63697473
        v128.const i32x4 0x6d696c20 0x64207469 0x6e206469 0x6620746f
        v128.const i32x4 0x006c6961 0x00000000 0x00000000 0x00000000
        array.new_fixed 52 3
        i32.const 0
        i32.const 35
        struct.new 53
        drop
        i32.eqz
        if ;; label = @3
          unreachable
        end
        br 1 (;@1;)
      end
      unreachable
    end
  )
)
