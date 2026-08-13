(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;6;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;7;) (func (param eqref) (result i32)))
  (type (;8;) (func (param eqref) (result eqref)))
  (type (;9;) (func (param eqref eqref) (result i32)))
  (type (;10;) (func (param eqref) (result i64)))
  (type (;11;) (func (result eqref)))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (param eqref eqref)))
  (type (;14;) (func (param eqref i32)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref) (result eqref)))
  (type (;20;) (func (param eqref eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref i32 i32) (result eqref)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref) (result i32)))
  (type (;25;) (func (param eqref) (result eqref)))
  (type (;26;) (func (param eqref eqref) (result i32)))
  (type (;27;) (func (param eqref i32) (result i32)))
  (type (;28;) (func (param eqref i32 i32) (result eqref)))
  (type (;29;) (func (param i64) (result i64)))
  (type (;30;) (func (param i64 i64) (result i64)))
  (type (;31;) (func (param i64 i64) (result i32)))
  (type (;32;) (func (param eqref) (result i64)))
  (type (;33;) (func (param eqref) (result i32)))
  (type (;34;) (func (param eqref) (result eqref)))
  (type (;35;) (func (param eqref eqref) (result i32)))
  (type (;36;) (func (result eqref)))
  (type (;37;) (func (param eqref) (result i32)))
  (type (;38;) (func (param eqref eqref)))
  (type (;39;) (func (param eqref i32)))
  (type (;40;) (func (param eqref i32)))
  (type (;41;) (func (param eqref eqref)))
  (type (;42;) (func (param eqref) (result eqref)))
  (type (;43;) (func (param eqref i32) (result v128)))
  (type (;44;) (sub (struct (field i32))))
  (type (;45;) (sub final 44 (struct (field i32) (field i32))))
  (type (;46;) (sub final 44 (struct (field i32) (field eqref))))
  (type (;47;) (sub final 44 (struct (field i32) (field (ref 6)))))
  (type (;48;) (sub final 44 (struct (field i32) (field (ref 6)))))
  (type (;49;) (struct (field eqref) (field (ref 44))))
  (type (;50;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;51;) (sub (struct (field i32))))
  (type (;52;) (sub final 51 (struct (field i32) (field i32))))
  (type (;53;) (sub final 51 (struct (field i32) (field i32) (field i8))))
  (type (;54;) (sub final 51 (struct (field i32) (field i32) (field eqref))))
  (type (;55;) (sub (struct (field i32))))
  (type (;56;) (sub final 55 (struct (field i32) (field eqref))))
  (type (;57;) (struct (field eqref) (field (ref 6)) (field (ref 6)) (field (ref 50))))
  (type (;58;) (struct (field eqref) (field i32) (field i32) (field (ref 6)) (field (ref 6)) (field (ref 6))))
  (type (;59;) (func))
  (type (;60;) (func (result (ref 50))))
  (type (;61;) (func (param (ref 57)) (result i32)))
  (type (;62;) (func (param (ref 57) i32)))
  (type (;63;) (func (param (ref 57)) (result i32)))
  (type (;64;) (func (param (ref 57) i32)))
  (type (;65;) (func (param i32) (result i32)))
  (type (;66;) (func (param i32) (result i32)))
  (type (;67;) (func (param eqref i32) (result i32)))
  (type (;68;) (func (param eqref i32) (result i32)))
  (type (;69;) (func (param i32) (result i32)))
  (type (;70;) (func (param eqref i32) (result i32)))
  (type (;71;) (func (param (ref 57))))
  (type (;72;) (func (param i32) (result i32)))
  (type (;73;) (func (param i32) (result i32)))
  (type (;74;) (func (param eqref i32 i32) (result i32)))
  (type (;75;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;76;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;77;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;78;) (func (param eqref i32 i32) (result i32)))
  (type (;79;) (func (param i32) (result i32)))
  (type (;80;) (func (param eqref i32) (result (ref 1))))
  (type (;81;) (func (param (ref 57) eqref i32 i32) (result i32)))
  (type (;82;) (func (param (ref 57)) (result (ref 3))))
  (type (;83;) (func (param (ref 57) eqref (ref 44)) (result (ref 3))))
  (type (;84;) (func (param (ref 57)) (result (ref 3))))
  (type (;85;) (func (param (ref 57) i32) (result (ref 3))))
  (type (;86;) (func (param eqref eqref) (result i32)))
  (type (;87;) (func (param eqref) (result i64)))
  (type (;88;) (func (param (ref 6) eqref) (result i32)))
  (type (;89;) (func (param i64) (result i32)))
  (type (;90;) (func (param i64) (result i32)))
  (type (;91;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;92;) (func (param (ref 6) eqref) (result i32)))
  (type (;93;) (func (param (ref 57) i32) (result (ref 3))))
  (type (;94;) (func (param (ref 57) i32) (result (ref 3))))
  (type (;95;) (func (param eqref (ref 50)) (result (ref 3))))
  (type (;96;) (func (param eqref) (result (ref 3))))
  (type (;97;) (func (param eqref) (result (ref 3))))
  (type (;98;) (func (param (ref 58) i32)))
  (type (;99;) (func (param (ref 58) i32)))
  (type (;100;) (func (param (ref 58) eqref)))
  (type (;101;) (func (param (ref 58) eqref)))
  (type (;102;) (func (param i32) (result i32)))
  (type (;103;) (func (param (ref 58) eqref)))
  (type (;104;) (func (param (ref 58) (ref 44) i32)))
  (type (;105;) (func (param (ref 44) i32 i32) (result (ref 3))))
  (type (;106;) (func (param (ref 44)) (result (ref 3))))
  (type (;107;) (func (param (ref 6) eqref) (result (ref 1))))
  (type (;108;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;109;) (func (param i32 eqref) (result i32)))
  (type (;110;) (func (result i32)))
  (type (;111;) (array (mut v128)))
  (type (;112;) (struct (field (ref 111)) (field i32) (field i32)))
  (type (;113;) (struct (field (ref 111)) (field i32) (field i32)))
  (type (;114;) (struct (field (ref 111)) (field i32) (field i32)))
  (type (;115;) (struct (field (mut (ref 111))) (field (mut i32)) (field (mut i32))))
  (type (;116;) (struct (field (mut (ref 111))) (field (mut i32)) (field (mut i32))))
  (type (;117;) (array (mut i32)))
  (type (;118;) (array (mut i64)))
  (type (;119;) (array (mut f32)))
  (type (;120;) (array (mut f64)))
  (type (;121;) (array (mut v128)))
  (type (;122;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 108)))
  (memory (;0;) 1)
  (export "main" (func 89))
  (export "memory" (memory 0))
  (func (;1;) (type 0) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;2;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 112)
    struct.get 112 2
  )
  (func (;3;) (type 8) (param eqref) (result eqref)
    (local (ref 112))
    local.get 0
    ref.cast (ref 112)
    local.tee 1
    struct.get 112 0
    local.get 1
    struct.get 112 1
    local.get 1
    struct.get 112 2
    struct.new 113
  )
  (func (;4;) (type 9) (param eqref eqref) (result i32)
    (local (ref 112) (ref 112) (ref 111) (ref 111) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 112)
    local.set 2
    local.get 1
    ref.cast (ref 112)
    local.set 3
    local.get 2
    struct.get 112 2
    local.tee 6
    local.get 3
    struct.get 112 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 112 0
    local.set 4
    local.get 3
    struct.get 112 0
    local.set 5
    local.get 2
    struct.get 112 1
    local.set 7
    local.get 3
    struct.get 112 1
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
          array.get 111
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 111
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
          array.get 111
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
          array.get 111
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 111
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
          array.get 111
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
      array.get 111
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
      array.get 111
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
  (func (;5;) (type 10) (param eqref) (result i64)
    (local (ref 112) (ref 111) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 112)
    local.set 1
    local.get 1
    struct.get 112 0
    local.set 2
    local.get 1
    struct.get 112 1
    local.set 3
    local.get 1
    struct.get 112 2
    local.set 4
    i32.const 0
    local.set 5
    i64.const -3750763034362895579
    local.set 6
    loop ;; label = @1
      local.get 5
      local.get 4
      i32.ge_u
      if ;; label = @2
        local.get 6
        return
      end
      local.get 6
      local.get 2
      local.get 3
      i32.const 4
      i32.shr_u
      array.get 111
      local.get 3
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      i64.extend_i32_u
      i64.xor
      i64.const 1099511628211
      i64.mul
      local.set 6
      local.get 3
      i32.const 1
      i32.add
      local.set 3
      local.get 5
      i32.const 1
      i32.add
      local.set 5
      br 0 (;@1;)
    end
    local.get 6
  )
  (func (;6;) (type 11) (result eqref)
    i32.const 4
    array.new_default 111
    i32.const 0
    i32.const 0
    struct.new 115
  )
  (func (;7;) (type 12) (param eqref) (result i32)
    (local (ref 115))
    local.get 0
    ref.cast (ref 115)
    local.tee 1
    struct.get 115 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 115 1
  )
  (func (;8;) (type 13) (param eqref eqref)
    (local (ref 115) (ref 112) (ref 111) (ref 111) i32 i32 i32 i32 i32 i32 (ref 111) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 115)
    local.set 2
    local.get 2
    struct.get 115 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 112)
    local.set 3
    local.get 2
    struct.get 115 0
    local.set 4
    local.get 3
    struct.get 112 0
    local.set 5
    local.get 2
    struct.get 115 1
    local.set 6
    local.get 3
    struct.get 112 1
    local.set 7
    local.get 3
    struct.get 112 2
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
      array.new_default 111
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
          array.get 111
          array.set 111
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 115 0
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
            array.get 111
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 111
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
            array.get 111
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
            array.set 111
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
            array.get 111
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
            array.set 111
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
            array.get 111
            local.get 19
            v128.bitselect
            array.set 111
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
        array.get 111
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
        array.get 111
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 111
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 115 1
  )
  (func (;9;) (type 14) (param eqref i32)
    (local (ref 115) (ref 111) i32 i32 i32 (ref 111) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 115)
    local.set 2
    local.get 2
    struct.get 115 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 115 0
    local.set 3
    local.get 2
    struct.get 115 1
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
      array.new_default 111
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
          array.get 111
          array.set 111
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 115 0
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
    array.get 111
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 111
    local.get 2
    local.get 5
    struct.set 115 1
  )
  (func (;10;) (type 15) (param eqref i32)
    (local (ref 115) (ref 111) i32 i32 i32 i32 i32 (ref 111) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 115)
    local.set 2
    local.get 2
    struct.get 115 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 115 0
    local.set 3
    local.get 2
    struct.get 115 1
    local.set 4
    local.get 1
    i32.const 127
    i32.le_u
    if ;; label = @1
      i32.const 1
      local.set 5
      local.get 1
      local.set 11
    else
      local.get 1
      i32.const 2047
      i32.le_u
      if ;; label = @2
        i32.const 2
        local.set 5
        local.get 1
        i32.const 6
        i32.shr_u
        i32.const 192
        i32.or
        local.set 11
        local.get 1
        i32.const 63
        i32.and
        i32.const 128
        i32.or
        local.set 12
      else
        local.get 1
        i32.const 55296
        i32.ge_u
        local.get 1
        i32.const 57343
        i32.le_u
        i32.and
        if ;; label = @3
          unreachable
        end
        i32.const 3
        local.set 5
        local.get 1
        i32.const 12
        i32.shr_u
        i32.const 224
        i32.or
        local.set 11
        local.get 1
        i32.const 6
        i32.shr_u
        i32.const 63
        i32.and
        i32.const 128
        i32.or
        local.set 12
        local.get 1
        i32.const 63
        i32.and
        i32.const 128
        i32.or
        local.set 13
        local.get 1
        i32.const 65535
        i32.le_u
        if ;; label = @3
        else
          local.get 1
          i32.const 1114111
          i32.gt_u
          if ;; label = @4
            unreachable
          end
          i32.const 4
          local.set 5
          local.get 1
          i32.const 18
          i32.shr_u
          i32.const 240
          i32.or
          local.set 11
          local.get 1
          i32.const 12
          i32.shr_u
          i32.const 63
          i32.and
          i32.const 128
          i32.or
          local.set 12
          local.get 1
          i32.const 6
          i32.shr_u
          i32.const 63
          i32.and
          i32.const 128
          i32.or
          local.set 13
          local.get 1
          i32.const 63
          i32.and
          i32.const 128
          i32.or
          local.set 14
        end
      end
    end
    local.get 4
    local.get 5
    i32.add
    local.tee 6
    local.get 4
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 6
    i32.const 4
    i32.shr_u
    local.get 6
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    local.set 7
    local.get 3
    array.len
    local.set 8
    local.get 7
    local.get 8
    i32.gt_u
    if ;; label = @1
      local.get 8
      i32.const 1
      i32.shl
      local.set 8
      local.get 8
      local.get 7
      i32.lt_u
      if ;; label = @2
        local.get 7
        local.set 8
      end
      local.get 8
      array.new_default 111
      local.set 9
      i32.const 0
      local.set 10
      block ;; label = @2
        loop ;; label = @3
          local.get 10
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
          local.get 9
          local.get 10
          local.get 3
          local.get 10
          array.get 111
          array.set 111
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 115 0
      local.get 9
      local.set 3
    end
    local.get 4
    local.set 15
    local.get 3
    local.get 15
    i32.const 4
    i32.shr_u
    local.get 11
    i8x16.splat
    local.get 3
    local.get 15
    i32.const 4
    i32.shr_u
    array.get 111
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 111
    local.get 5
    i32.const 1
    i32.gt_u
    if ;; label = @1
      local.get 15
      i32.const 1
      i32.add
      local.set 15
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      local.get 12
      i8x16.splat
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      array.get 111
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 111
    end
    local.get 5
    i32.const 2
    i32.gt_u
    if ;; label = @1
      local.get 15
      i32.const 1
      i32.add
      local.set 15
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      local.get 13
      i8x16.splat
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      array.get 111
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 111
    end
    local.get 5
    i32.const 3
    i32.gt_u
    if ;; label = @1
      local.get 15
      i32.const 1
      i32.add
      local.set 15
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      local.get 14
      i8x16.splat
      local.get 3
      local.get 15
      i32.const 4
      i32.shr_u
      array.get 111
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 111
    end
    local.get 2
    local.get 6
    struct.set 115 1
  )
  (func (;11;) (type 16) (param eqref) (result eqref)
    (local (ref 115))
    local.get 0
    ref.cast (ref 115)
    local.set 1
    local.get 1
    struct.get 115 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 115 2
    local.get 1
    struct.get 115 0
    i32.const 0
    local.get 1
    struct.get 115 1
    struct.new 112
  )
  (func (;12;) (type 17) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 113)
    struct.get 113 2
  )
  (func (;13;) (type 18) (param eqref) (result i32)
    (local (ref 113) (ref 111) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 113)
    local.set 1
    local.get 1
    struct.get 113 0
    local.set 2
    local.get 1
    struct.get 113 1
    local.set 4
    local.get 1
    struct.get 113 2
    local.get 4
    i32.add
    local.set 3
    loop ;; label = @1
      local.get 4
      local.get 3
      i32.ge_u
      if ;; label = @2
        i32.const 1
        return
      end
      local.get 4
      i32.const 15
      i32.and
      i32.eqz
      local.get 4
      i32.const 16
      i32.add
      local.get 3
      i32.le_u
      i32.and
      if ;; label = @2
        local.get 2
        local.get 4
        i32.const 4
        i32.shr_u
        array.get 111
        i8x16.bitmask
        i32.eqz
        if ;; label = @3
          local.get 4
          i32.const 16
          i32.add
          local.set 4
          br 2 (;@1;)
        end
      end
      local.get 2
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 111
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 5
      local.get 5
      i32.const 128
      i32.lt_u
      if ;; label = @2
        local.get 4
        i32.const 1
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      local.get 5
      i32.const 194
      i32.lt_u
      if ;; label = @2
        i32.const 0
        return
      end
      local.get 5
      i32.const 224
      i32.lt_u
      if ;; label = @2
        local.get 4
        i32.const 2
        i32.add
        local.get 3
        i32.gt_u
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 2
        local.get 4
        i32.const 1
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 1
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 6
        local.get 6
        i32.const 192
        i32.and
        i32.const 128
        i32.ne
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 4
        i32.const 2
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      local.get 5
      i32.const 240
      i32.lt_u
      if ;; label = @2
        local.get 4
        i32.const 3
        i32.add
        local.get 3
        i32.gt_u
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 2
        local.get 4
        i32.const 1
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 1
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 6
        local.get 2
        local.get 4
        i32.const 2
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 2
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 7
        local.get 5
        i32.const 224
        i32.eq
        if ;; label = @3
          local.get 6
          i32.const 160
          i32.lt_u
          if ;; label = @4
            i32.const 0
            return
          end
          local.get 6
          i32.const 191
          i32.gt_u
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 5
        i32.const 237
        i32.eq
        if ;; label = @3
          local.get 6
          i32.const 128
          i32.lt_u
          if ;; label = @4
            i32.const 0
            return
          end
          local.get 6
          i32.const 159
          i32.gt_u
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 5
        i32.const 224
        i32.ne
        local.get 5
        i32.const 237
        i32.ne
        i32.and
        if ;; label = @3
          local.get 6
          i32.const 192
          i32.and
          i32.const 128
          i32.ne
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 7
        i32.const 192
        i32.and
        i32.const 128
        i32.ne
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 4
        i32.const 3
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      local.get 5
      i32.const 244
      i32.le_u
      if ;; label = @2
        local.get 4
        i32.const 4
        i32.add
        local.get 3
        i32.gt_u
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 2
        local.get 4
        i32.const 1
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 1
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 6
        local.get 2
        local.get 4
        i32.const 2
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 2
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 7
        local.get 2
        local.get 4
        i32.const 3
        i32.add
        i32.const 4
        i32.shr_u
        array.get 111
        local.get 4
        i32.const 3
        i32.add
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.swizzle
        i8x16.extract_lane_u 0
        local.set 8
        local.get 5
        i32.const 240
        i32.eq
        if ;; label = @3
          local.get 6
          i32.const 144
          i32.lt_u
          if ;; label = @4
            i32.const 0
            return
          end
          local.get 6
          i32.const 191
          i32.gt_u
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 5
        i32.const 244
        i32.eq
        if ;; label = @3
          local.get 6
          i32.const 128
          i32.lt_u
          if ;; label = @4
            i32.const 0
            return
          end
          local.get 6
          i32.const 143
          i32.gt_u
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 5
        i32.const 240
        i32.ne
        local.get 5
        i32.const 244
        i32.ne
        i32.and
        if ;; label = @3
          local.get 6
          i32.const 192
          i32.and
          i32.const 128
          i32.ne
          if ;; label = @4
            i32.const 0
            return
          end
        end
        local.get 7
        i32.const 192
        i32.and
        i32.const 128
        i32.ne
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 8
        i32.const 192
        i32.and
        i32.const 128
        i32.ne
        if ;; label = @3
          i32.const 0
          return
        end
        local.get 4
        i32.const 4
        i32.add
        local.set 4
        br 1 (;@1;)
      end
      i32.const 0
      return
      br 0 (;@1;)
    end
    i32.const 1
  )
  (func (;14;) (type 19) (param eqref) (result eqref)
    (local (ref 113))
    local.get 0
    call 13
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 113)
    local.tee 1
    struct.get 113 0
    local.get 1
    struct.get 113 1
    local.get 1
    struct.get 113 2
    struct.new 112
  )
  (func (;15;) (type 20) (param eqref eqref) (result i32)
    (local (ref 113) (ref 113) (ref 111) (ref 111) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 113)
    local.set 2
    local.get 1
    ref.cast (ref 113)
    local.set 3
    local.get 2
    struct.get 113 2
    local.tee 6
    local.get 3
    struct.get 113 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 113 0
    local.set 4
    local.get 3
    struct.get 113 0
    local.set 5
    local.get 2
    struct.get 113 1
    local.set 7
    local.get 3
    struct.get 113 1
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
          array.get 111
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 111
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
          array.get 111
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
          array.get 111
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 111
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
          array.get 111
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
      array.get 111
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
      array.get 111
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
  (func (;16;) (type 21) (param eqref i32) (result i32)
    (local (ref 113) (ref 111) i32)
    local.get 0
    ref.cast (ref 113)
    local.set 2
    local.get 1
    local.get 2
    struct.get 113 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 113 0
    local.set 3
    local.get 2
    struct.get 113 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 111
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;17;) (type 22) (param eqref i32 i32) (result eqref)
    (local (ref 113) i32)
    local.get 0
    ref.cast (ref 113)
    local.set 3
    local.get 3
    struct.get 113 2
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
    struct.get 113 0
    local.get 3
    struct.get 113 1
    local.get 1
    i32.add
    local.get 2
    struct.new 113
  )
  (func (;18;) (type 23) (param eqref) (result i32)
    local.get 0
    call 12
  )
  (func (;19;) (type 24) (param eqref) (result i32)
    local.get 0
    call 13
  )
  (func (;20;) (type 25) (param eqref) (result eqref)
    local.get 0
    call 14
  )
  (func (;21;) (type 26) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 15
  )
  (func (;22;) (type 27) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 16
  )
  (func (;23;) (type 28) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 17
  )
  (func (;24;) (type 29) (param i64) (result i64)
    i64.const 1
    local.get 0
    i64.const 63
    i64.and
    i64.shl
    i64.const 1
    local.get 0
    i64.const 32
    i64.shr_u
    i64.const 63
    i64.and
    i64.shl
    i64.or
  )
  (func (;25;) (type 30) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 24
    i64.or
  )
  (func (;26;) (type 31) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 24
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;27;) (type 32) (param eqref) (result i64)
    local.get 0
    call 5
  )
  (func (;28;) (type 33) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;29;) (type 34) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;30;) (type 35) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;31;) (type 36) (result eqref)
    call 6
  )
  (func (;32;) (type 37) (param eqref) (result i32)
    local.get 0
    call 7
  )
  (func (;33;) (type 38) (param eqref eqref)
    local.get 0
    local.get 1
    call 8
  )
  (func (;34;) (type 39) (param eqref i32)
    local.get 0
    local.get 1
    call 9
  )
  (func (;35;) (type 40) (param eqref i32)
    local.get 0
    local.get 1
    call 10
  )
  (func (;36;) (type 41) (param eqref eqref)
    local.get 0
    local.get 1
    call 14
    call 8
  )
  (func (;37;) (type 42) (param eqref) (result eqref)
    local.get 0
    call 11
  )
  (func (;38;) (type 43) (param eqref i32) (result v128)
    (local (ref 113) (ref 111) i32 v128)
    local.get 0
    ref.cast (ref 113)
    local.set 2
    local.get 1
    local.get 2
    struct.get 113 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 113 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 113 0
    local.set 3
    local.get 2
    struct.get 113 1
    local.get 1
    i32.add
    local.set 4
    local.get 4
    i32.const 15
    i32.and
    i32.eqz
    if ;; label = @1
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 111
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 111
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.add
      i8x16.swizzle
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      i32.const 1
      i32.add
      array.get 111
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 4
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.add
      i32.const 16
      i8x16.splat
      i8x16.sub
      i8x16.swizzle
      v128.or
      local.set 5
    end
    local.get 5
  )
  (func (;39;) (type 59))
  (func (;40;) (type 60) (result (ref 50))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 50
    ref.cast (ref 50)
  )
  (func (;41;) (type 61) (param (ref 57)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 57 1
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 2
    array.get 117
  )
  (func (;42;) (type 62) (param (ref 57) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 57 1
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 3
    local.get 5
    array.set 117
  )
  (func (;43;) (type 63) (param (ref 57)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 57 2
    i32.const 0
    local.set 2
    local.set 1
    local.get 2
    local.get 1
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 2
    array.get 117
  )
  (func (;44;) (type 64) (param (ref 57) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 57 2
    i32.const 0
    local.set 3
    local.get 1
    local.set 5
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 3
    local.get 5
    array.set 117
  )
  (func (;45;) (type 65) (param i32) (result i32)
    local.get 0
    i32.const 32
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 9
      i32.eq
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 10
      i32.eq
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 13
      i32.eq
    end
  )
  (func (;46;) (type 66) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;47;) (type 67) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 18
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 4
            local.get 4
            i32.const 16
            i32.add
            local.get 2
            i32.le_u
            if ;; label = @5
              local.get 0
              local.get 4
              call 38
              local.set 5
              local.get 5
              i32.const 32
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 9
              i8x16.splat
              i8x16.eq
              v128.or
              local.get 5
              i32.const 10
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 13
              i8x16.splat
              i8x16.eq
              v128.or
              v128.or
              local.set 6
              local.get 6
              i8x16.bitmask
              i32.const 65535
              i32.xor
              local.set 7
              local.get 7
              i32.const 0
              i32.eq
              if ;; label = @6
                local.get 4
                i32.const 16
                i32.add
                local.set 9
                br 4 (;@2;)
              else
                local.get 4
                local.get 7
                call 46
                i32.add
                local.set 10
                br 5 (;@1;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 8
            local.get 8
            local.get 2
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 0
              local.get 8
              call 22
              call 45
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 8
              i32.const 1
              i32.add
              local.set 9
              br 3 (;@2;)
            else
              local.get 8
              local.set 10
              br 4 (;@1;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
  )
  (func (;48;) (type 68) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 18
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 4
            local.get 4
            i32.const 16
            i32.add
            local.get 2
            i32.le_u
            if ;; label = @5
              local.get 0
              local.get 4
              call 38
              local.set 5
              local.get 5
              i32.const 32
              i8x16.splat
              i8x16.lt_u
              local.get 5
              i32.const 34
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 92
              i8x16.splat
              i8x16.eq
              v128.or
              v128.or
              local.set 6
              local.get 6
              i8x16.bitmask
              local.set 7
              local.get 7
              i32.const 0
              i32.eq
              if ;; label = @6
                local.get 4
                i32.const 16
                i32.add
                local.set 10
                br 4 (;@2;)
              else
                local.get 4
                local.get 7
                call 46
                i32.add
                local.set 11
                br 5 (;@1;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 8
            local.get 8
            local.get 2
            i32.ge_u
            if ;; label = @5
              local.get 8
              local.set 11
              br 4 (;@1;)
            else
              local.get 0
              local.get 8
              call 22
              local.set 9
              local.get 9
              i32.const 32
              i32.lt_u
              if (result i32) ;; label = @6
                i32.const 1
              else
                local.get 9
                i32.const 34
                i32.eq
              end
              if (result i32) ;; label = @6
                i32.const 1
              else
                local.get 9
                i32.const 92
                i32.eq
              end
              if ;; label = @6
                local.get 8
                local.set 11
                br 5 (;@1;)
              else
                local.get 8
                i32.const 1
                i32.add
                local.set 10
                br 4 (;@2;)
              end
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
  )
  (func (;49;) (type 69) (param i32) (result i32)
    local.get 0
    call 45
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 44
      i32.eq
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 93
      i32.eq
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      i32.const 125
      i32.eq
    end
  )
  (func (;50;) (type 70) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 18
    local.set 2
    local.get 1
    local.set 3
    local.get 3
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 4
            local.get 4
            i32.const 16
            i32.add
            local.get 2
            i32.le_u
            if ;; label = @5
              local.get 0
              local.get 4
              call 38
              local.set 5
              local.get 5
              i32.const 32
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 9
              i8x16.splat
              i8x16.eq
              v128.or
              local.get 5
              i32.const 10
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 13
              i8x16.splat
              i8x16.eq
              v128.or
              local.get 5
              i32.const 44
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 93
              i8x16.splat
              i8x16.eq
              local.get 5
              i32.const 125
              i8x16.splat
              i8x16.eq
              v128.or
              v128.or
              v128.or
              v128.or
              local.set 6
              local.get 6
              i8x16.bitmask
              local.set 7
              local.get 7
              i32.const 0
              i32.eq
              if ;; label = @6
                local.get 4
                i32.const 16
                i32.add
                local.set 9
                br 4 (;@2;)
              else
                local.get 4
                local.get 7
                call 46
                i32.add
                local.set 10
                br 5 (;@1;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 8
            local.get 8
            local.get 2
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 0
              local.get 8
              call 22
              call 49
              i32.const 0
              call 1
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 8
              i32.const 1
              i32.add
              local.set 9
              br 3 (;@2;)
            else
              local.get 8
              local.set 10
              br 4 (;@1;)
            end
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
  )
  (func (;51;) (type 71) (param (ref 57))
    local.get 0
    local.get 0
    struct.get 57 0
    local.get 0
    call 41
    call 47
    call 42
  )
  (func (;52;) (type 72) (param i32) (result i32)
    local.get 0
    i32.const 48
    i32.ge_u
    if (result i32) ;; label = @1
      local.get 0
      i32.const 57
      i32.le_u
    else
      i32.const 0
    end
  )
  (func (;53;) (type 73) (param i32) (result i32)
    local.get 0
    i32.const 49
    i32.ge_u
    if (result i32) ;; label = @1
      local.get 0
      i32.const 57
      i32.le_u
    else
      i32.const 0
    end
  )
  (func (;54;) (type 74) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32)
    local.get 1
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 5
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 0
              local.get 3
              call 22
              call 52
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 3
              i32.const 1
              i32.add
              local.set 5
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 5
            local.set 4
            local.get 4
            local.set 6
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 6
  )
  (func (;55;) (type 75) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 22
      i32.const 48
      i32.eq
      if (result eqref) ;; label = @2
        local.get 1
        i32.const 1
        i32.add
        local.get 2
        i32.lt_u
        if (result i32) ;; label = @3
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          call 22
          call 52
        else
          i32.const 0
        end
        if (result eqref) ;; label = @3
          i32.const 0
          struct.new 1
        else
          i32.const 1
          local.get 1
          i32.const 1
          i32.add
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 2
        end
      else
        local.get 0
        local.get 1
        call 22
        call 53
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 54
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 2
        else
          i32.const 0
          struct.new 1
        end
      end
    end
    ref.cast (ref 1)
  )
  (func (;56;) (type 76) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 22
      i32.const 46
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 1
      i32.const 1
      i32.add
      local.set 3
      local.get 3
      local.get 2
      i32.ge_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 3
        call 22
        call 52
        i32.const 0
        call 1
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 1
      else
        i32.const 1
        local.get 0
        local.get 3
        i32.const 1
        i32.add
        local.get 2
        call 54
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 2
      end
    else
      i32.const 1
      local.get 1
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 2
    end
    ref.cast (ref 1)
  )
  (func (;57;) (type 77) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 22
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 22
        i32.const 69
        i32.eq
      end
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 1
      i32.const 1
      i32.add
      local.set 3
      local.get 3
      local.get 2
      i32.lt_u
      if (result i32) ;; label = @2
        local.get 0
        local.get 3
        call 22
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 22
          i32.const 45
          i32.eq
        end
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        local.get 3
        i32.const 1
        i32.add
      else
        local.get 3
      end
      local.set 4
      local.get 4
      local.get 2
      i32.ge_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 4
        call 22
        call 52
        i32.const 0
        call 1
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 1
      else
        i32.const 1
        local.get 0
        local.get 4
        i32.const 1
        i32.add
        local.get 2
        call 54
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 2
      end
    else
      i32.const 1
      local.get 1
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 2
    end
    ref.cast (ref 1)
  )
  (func (;58;) (type 78) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 22
      i32.const 45
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        i32.const 1
        i32.add
      else
        local.get 1
      end
      local.set 3
      local.get 0
      local.get 3
      local.get 2
      call 55
      local.set 11
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 11
              ref.cast (ref 1)
              struct.get 1 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            i32.const 0
            local.set 12
            br 2 (;@2;)
          end
          local.get 11
          ref.cast (ref 2)
          struct.get 2 1
          local.set 4
          local.get 0
          local.get 4
          local.get 2
          call 56
          local.set 9
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 9
                  ref.cast (ref 1)
                  struct.get 1 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                i32.const 0
                local.set 10
                br 2 (;@4;)
              end
              local.get 9
              ref.cast (ref 2)
              struct.get 2 1
              local.set 5
              local.get 0
              local.get 5
              local.get 2
              call 57
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 1)
                      struct.get 1 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    i32.const 0
                    local.set 8
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 2)
                  struct.get 2 1
                  local.set 6
                  local.get 6
                  local.get 2
                  i32.eq
                  local.set 8
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 8
              local.set 10
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 10
          local.set 12
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 12
    end
  )
  (func (;59;) (type 79) (param i32) (result i32)
    local.get 0
    i32.const 48
    i32.ge_u
    if (result i32) ;; label = @1
      local.get 0
      i32.const 57
      i32.le_u
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 0
      i32.const 48
      i32.sub
      i32.const 255
      i32.and
    else
      local.get 0
      i32.const 65
      i32.ge_u
      if (result i32) ;; label = @2
        local.get 0
        i32.const 70
        i32.le_u
      else
        i32.const 0
      end
      if (result i32) ;; label = @2
        local.get 0
        i32.const 55
        i32.sub
        i32.const 255
        i32.and
      else
        local.get 0
        i32.const 97
        i32.ge_u
        if (result i32) ;; label = @3
          local.get 0
          i32.const 102
          i32.le_u
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          local.get 0
          i32.const 87
          i32.sub
          i32.const 255
          i32.and
        else
          i32.const -1
        end
      end
    end
  )
  (func (;60;) (type 80) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 18
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 18
      local.get 1
      i32.sub
      i32.const 4
      i32.lt_u
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 22
      call 59
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 22
      call 59
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 22
      call 59
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 22
      call 59
      local.set 5
      local.get 2
      i32.const -1
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        i32.const -1
        i32.eq
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 4
        i32.const -1
        i32.eq
      end
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 5
        i32.const -1
        i32.eq
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 1
      else
        i32.const 1
        local.get 2
        i32.const 12
        i32.shl
        local.get 3
        i32.const 8
        i32.shl
        i32.or
        local.get 4
        i32.const 4
        i32.shl
        i32.or
        local.get 5
        i32.or
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 2
      end
    end
    ref.cast (ref 1)
  )
  (func (;61;) (type 81) (param (ref 57) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 32
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 57 3
      struct.get 50 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 57 3
      struct.get 50 3
      local.get 4
      i32.sub
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 3
      local.get 2
      i32.gt_u
      if ;; label = @2
        local.get 1
        local.get 0
        struct.get 57 0
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 23
        call 36
      else
      end
      i32.const 1
    end
  )
  (func (;62;) (type 82) (param (ref 57)) (result (ref 3))
    (local i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 41
    local.set 1
    local.get 0
    struct.get 57 0
    call 18
    local.set 2
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 1
      struct.new 52
      struct.new 5
    else
      local.get 0
      struct.get 57 0
      local.get 1
      call 22
      i32.const 34
      i32.ne
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 6
        local.get 1
        local.get 0
        struct.get 57 0
        local.get 1
        call 22
        struct.new 53
        struct.new 5
      else
        call 31
        local.set 3
        local.get 1
        i32.const 1
        i32.add
        local.set 4
        local.get 4
        local.set 5
        i32.const 1
        local.set 14
        block ;; label = @3
          loop ;; label = @4
            block ;; label = @5
              local.get 14
              i32.const 1
              i32.eq
              if ;; label = @6
                local.get 0
                struct.get 57 0
                local.get 5
                call 48
                local.set 6
                local.get 6
                local.get 2
                i32.ge_u
                if ;; label = @7
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  i32.const 5
                  local.get 2
                  struct.new 52
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                local.get 3
                local.get 4
                local.get 6
                call 61
                i32.const 0
                call 1
                if ;; label = @7
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  i32.const 3
                  local.get 6
                  struct.new 52
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                struct.get 57 0
                local.get 6
                call 22
                local.set 7
                local.get 7
                i32.const 34
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 6
                  i32.const 1
                  i32.add
                  call 42
                  i32.const 0
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  call 37
                  struct.new 4
                  local.set 15
                  br 4 (;@3;)
                else
                  local.get 7
                  i32.const 32
                  i32.lt_u
                  if ;; label = @8
                    i32.const 1
                    i32.const 0
                    i64.const 0
                    f32.const 0x0p+0 (;=0;)
                    f64.const 0x0p+0 (;=0;)
                    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                    i32.const 9
                    local.get 6
                    struct.new 52
                    struct.new 5
                    local.set 15
                    br 5 (;@3;)
                  else
                    local.get 7
                    i32.const 92
                    i32.ne
                    if ;; label = @9
                      i32.const 1
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      i32.const 6
                      local.get 6
                      local.get 7
                      struct.new 53
                      struct.new 5
                      local.set 15
                      br 6 (;@3;)
                    else
                      local.get 6
                      i32.const 1
                      i32.add
                      local.get 2
                      i32.ge_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 5
                        local.get 2
                        struct.new 52
                        struct.new 5
                        local.set 15
                        br 7 (;@3;)
                      else
                        local.get 0
                        struct.get 57 0
                        local.get 6
                        i32.const 1
                        i32.add
                        call 22
                        local.set 8
                        local.get 8
                        i32.const 34
                        i32.eq
                        if (result i32) ;; label = @11
                          i32.const 1
                        else
                          local.get 8
                          i32.const 92
                          i32.eq
                        end
                        if (result i32) ;; label = @11
                          i32.const 1
                        else
                          local.get 8
                          i32.const 47
                          i32.eq
                        end
                        if ;; label = @11
                          local.get 3
                          local.get 8
                          call 34
                          local.get 6
                          i32.const 2
                          i32.add
                          local.set 5
                          local.get 5
                          local.set 4
                        else
                          local.get 8
                          i32.const 98
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            i32.const 8
                            call 34
                            local.get 6
                            i32.const 2
                            i32.add
                            local.set 5
                            local.get 5
                            local.set 4
                          else
                            local.get 8
                            i32.const 102
                            i32.eq
                            if ;; label = @13
                              local.get 3
                              i32.const 12
                              call 34
                              local.get 6
                              i32.const 2
                              i32.add
                              local.set 5
                              local.get 5
                              local.set 4
                            else
                              local.get 8
                              i32.const 110
                              i32.eq
                              if ;; label = @14
                                local.get 3
                                i32.const 10
                                call 34
                                local.get 6
                                i32.const 2
                                i32.add
                                local.set 5
                                local.get 5
                                local.set 4
                              else
                                local.get 8
                                i32.const 114
                                i32.eq
                                if ;; label = @15
                                  local.get 3
                                  i32.const 13
                                  call 34
                                  local.get 6
                                  i32.const 2
                                  i32.add
                                  local.set 5
                                  local.get 5
                                  local.set 4
                                else
                                  local.get 8
                                  i32.const 116
                                  i32.eq
                                  if ;; label = @16
                                    local.get 3
                                    i32.const 9
                                    call 34
                                    local.get 6
                                    i32.const 2
                                    i32.add
                                    local.set 5
                                    local.get 5
                                    local.set 4
                                  else
                                    local.get 8
                                    i32.const 117
                                    i32.eq
                                    if ;; label = @17
                                      local.get 0
                                      struct.get 57 0
                                      local.get 6
                                      i32.const 2
                                      i32.add
                                      call 60
                                      local.set 13
                                      block ;; label = @18
                                        block ;; label = @19
                                          block ;; label = @20
                                            block ;; label = @21
                                              local.get 13
                                              ref.cast (ref 1)
                                              struct.get 1 0
                                              br_table 0 (;@21;) 1 (;@20;) 2 (;@19;)
                                            end
                                            i32.const 1
                                            i32.const 0
                                            i64.const 0
                                            f32.const 0x0p+0 (;=0;)
                                            f64.const 0x0p+0 (;=0;)
                                            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                            i32.const 10
                                            local.get 6
                                            struct.new 52
                                            struct.new 5
                                            local.set 15
                                            br 17 (;@3;)
                                            br 2 (;@18;)
                                          end
                                          local.get 13
                                          ref.cast (ref 2)
                                          struct.get 2 1
                                          local.set 9
                                          local.get 9
                                          i32.const 55296
                                          i32.ge_u
                                          if (result i32) ;; label = @20
                                            local.get 9
                                            i32.const 56319
                                            i32.le_u
                                          else
                                            i32.const 0
                                          end
                                          if ;; label = @20
                                            local.get 6
                                            i32.const 6
                                            i32.add
                                            local.set 10
                                            local.get 10
                                            i32.const 5
                                            i32.add
                                            local.get 2
                                            i32.ge_u
                                            if (result i32) ;; label = @21
                                              i32.const 1
                                            else
                                              local.get 0
                                              struct.get 57 0
                                              local.get 10
                                              call 22
                                              i32.const 92
                                              i32.ne
                                            end
                                            if (result i32) ;; label = @21
                                              i32.const 1
                                            else
                                              local.get 0
                                              struct.get 57 0
                                              local.get 10
                                              i32.const 1
                                              i32.add
                                              call 22
                                              i32.const 117
                                              i32.ne
                                            end
                                            if ;; label = @21
                                              i32.const 1
                                              i32.const 0
                                              i64.const 0
                                              f32.const 0x0p+0 (;=0;)
                                              f64.const 0x0p+0 (;=0;)
                                              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                              i32.const 10
                                              local.get 6
                                              struct.new 52
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                            end
                                            local.get 0
                                            struct.get 57 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 60
                                            local.set 12
                                            block ;; label = @21
                                              local.get 12
                                              ref.cast (ref 1)
                                              struct.get 1 0
                                              i32.const 1
                                              i32.eq
                                              if ;; label = @22
                                                local.get 12
                                                ref.cast (ref 2)
                                                struct.get 2 1
                                                local.set 11
                                                local.get 11
                                                i32.const 56320
                                                i32.ge_u
                                                if (result i32) ;; label = @23
                                                  local.get 11
                                                  i32.const 57343
                                                  i32.le_u
                                                else
                                                  i32.const 0
                                                end
                                                if ;; label = @23
                                                  local.get 3
                                                  i32.const 65536
                                                  local.get 9
                                                  i32.const 55296
                                                  i32.sub
                                                  i32.const 10
                                                  i32.shl
                                                  i32.add
                                                  local.get 11
                                                  i32.const 56320
                                                  i32.sub
                                                  i32.add
                                                  call 35
                                                  local.get 10
                                                  i32.const 6
                                                  i32.add
                                                  local.set 5
                                                  local.get 5
                                                  local.set 4
                                                  br 2 (;@21;)
                                                end
                                              end
                                              i32.const 1
                                              if ;; label = @22
                                                i32.const 1
                                                i32.const 0
                                                i64.const 0
                                                f32.const 0x0p+0 (;=0;)
                                                f64.const 0x0p+0 (;=0;)
                                                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                                i32.const 10
                                                local.get 6
                                                struct.new 52
                                                struct.new 5
                                                local.set 15
                                                br 19 (;@3;)
                                                br 1 (;@21;)
                                              end
                                              unreachable
                                            end
                                          else
                                            local.get 9
                                            i32.const 56320
                                            i32.ge_u
                                            if (result i32) ;; label = @21
                                              local.get 9
                                              i32.const 57343
                                              i32.le_u
                                            else
                                              i32.const 0
                                            end
                                            if ;; label = @21
                                              i32.const 1
                                              i32.const 0
                                              i64.const 0
                                              f32.const 0x0p+0 (;=0;)
                                              f64.const 0x0p+0 (;=0;)
                                              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                              i32.const 10
                                              local.get 6
                                              struct.new 52
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                              local.get 3
                                              local.get 9
                                              call 35
                                              local.get 6
                                              i32.const 6
                                              i32.add
                                              local.set 5
                                              local.get 5
                                              local.set 4
                                            end
                                          end
                                          br 1 (;@18;)
                                        end
                                        unreachable
                                      end
                                    else
                                      i32.const 1
                                      i32.const 0
                                      i64.const 0
                                      f32.const 0x0p+0 (;=0;)
                                      f64.const 0x0p+0 (;=0;)
                                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                      i32.const 9
                                      local.get 6
                                      struct.new 52
                                      struct.new 5
                                      local.set 15
                                      br 14 (;@3;)
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                        local.get 3
                        call 32
                        local.get 0
                        struct.get 57 3
                        struct.get 50 3
                        i32.gt_u
                        if ;; label = @11
                          i32.const 1
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 3
                          local.get 6
                          struct.new 52
                          struct.new 5
                          local.set 15
                          br 8 (;@3;)
                        else
                          i32.const 1
                          local.set 14
                          br 7 (;@4;)
                        end
                      end
                    end
                  end
                end
                br 1 (;@5;)
              end
              unreachable
            end
            unreachable
          end
          unreachable
        end
        local.get 15
      end
    end
    ref.cast (ref 3)
  )
  (func (;63;) (type 83) (param (ref 57) eqref (ref 44)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 41
    local.set 3
    local.get 0
    struct.get 57 0
    call 18
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 18
      local.get 4
      local.get 3
      i32.sub
      i32.gt_u
    end
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 4
      struct.new 52
      struct.new 5
    else
      local.get 0
      struct.get 57 0
      local.get 3
      local.get 1
      call 18
      call 23
      local.get 1
      call 21
      i32.const 0
      call 1
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 7
        local.get 3
        struct.new 52
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 18
        i32.add
        call 42
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;64;) (type 84) (param (ref 57)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 41
    local.set 1
    local.get 0
    struct.get 57 0
    local.get 1
    call 50
    local.set 2
    local.get 0
    struct.get 57 0
    local.get 1
    local.get 2
    call 58
    i32.const 0
    call 1
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 8
      local.get 1
      struct.new 52
      struct.new 5
    else
      local.get 0
      local.get 2
      call 42
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      local.get 0
      struct.get 57 0
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 23
      call 20
      struct.new 46
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;65;) (type 85) (param (ref 57) i32) (result (ref 3))
    (local eqref (ref 51) (ref 44) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 122
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 41
    i32.const 1
    i32.add
    call 42
    local.get 0
    call 51
    local.get 0
    call 41
    local.get 0
    struct.get 57 0
    call 18
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 57 0
      local.get 0
      call 41
      call 22
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 41
      i32.const 1
      i32.add
      call 42
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 4
      local.get 2
      ref.cast (ref 6)
      struct.new 47
      struct.new 4
    else
      i32.const 1
      local.set 12
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 12
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 74
              local.set 11
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 11
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 11
                    ref.cast (ref 4)
                    struct.get 4 6
                    ref.cast (ref 44)
                    local.set 4
                    local.get 2
                    local.get 4
                    local.set 10
                    local.set 7
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 2
                    i32.eq
                    if ;; label = @9
                      local.get 7
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 7
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 8
                      local.get 8
                      local.get 7
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.le_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 8
                      array.new_default 122
                      local.set 9
                      i32.const 0
                      local.set 8
                      block ;; label = @10
                        loop ;; label = @11
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 1
                          i32.ge_u
                          br_if 1 (;@10;)
                          local.get 9
                          ref.cast (ref 122)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 122)
                          local.get 8
                          array.get 122
                          array.set 122
                          local.get 8
                          i32.const 1
                          i32.add
                          local.set 8
                          br 0 (;@11;)
                        end
                      end
                      local.get 7
                      ref.cast (ref 6)
                      local.get 9
                      struct.set 6 0
                      local.get 7
                      ref.cast (ref 6)
                      local.get 9
                      ref.cast (ref 122)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 122)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 122
                    local.get 7
                    ref.cast (ref 6)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.const 1
                    i32.add
                    struct.set 6 1
                    br 2 (;@6;)
                  end
                  local.get 11
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 51)
                  local.set 3
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  struct.new 5
                  local.set 13
                  br 5 (;@2;)
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 0
              call 51
              local.get 0
              call 41
              local.set 5
              local.get 5
              local.get 0
              struct.get 57 0
              call 18
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 5
                struct.new 52
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 57 0
              local.get 5
              call 22
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 42
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 4
                local.get 2
                ref.cast (ref 6)
                struct.new 47
                struct.new 4
                local.set 13
                br 4 (;@2;)
              else
                local.get 6
                i32.const 44
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 5
                  i32.const 1
                  i32.add
                  call 42
                  local.get 0
                  call 51
                else
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  i32.const 6
                  local.get 5
                  local.get 6
                  struct.new 53
                  struct.new 5
                  local.set 13
                  br 5 (;@2;)
                end
              end
              i32.const 1
              local.set 12
              br 2 (;@3;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 13
    end
    ref.cast (ref 3)
  )
  (func (;66;) (type 86) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 30
  )
  (func (;67;) (type 87) (param eqref) (result i64)
    local.get 0
    call 27
  )
  (func (;68;) (type 88) (param (ref 6) eqref) (result i32)
    (local i32 eqref i32 eqref i32 i32)
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 2
            local.get 2
            local.get 0
            ref.cast (ref 6)
            struct.get 6 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 2
              local.set 4
              local.set 3
              local.get 4
              local.get 3
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 3
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 122)
              local.get 4
              array.get 122
              ref.cast (ref 49)
              struct.get 49 0
              local.get 1
              call 66
              if ;; label = @6
                i32.const 1
                local.set 7
                br 5 (;@1;)
              else
                local.get 2
                i32.const 1
                i32.add
                local.set 6
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 7
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 7
  )
  (func (;69;) (type 89) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;70;) (type 90) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 69
  )
  (func (;71;) (type 91) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 26
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 26
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 26
        else
          local.get 3
          local.get 5
          call 26
        end
      end
    end
  )
  (func (;72;) (type 92) (param (ref 6) eqref) (result i32)
    (local i32 eqref i32 eqref i32 i32)
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 2
            local.get 2
            local.get 0
            ref.cast (ref 6)
            struct.get 6 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 2
              local.set 4
              local.set 3
              local.get 4
              local.get 3
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 3
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 122)
              local.get 4
              array.get 122
              local.get 1
              call 66
              if ;; label = @6
                i32.const 1
                local.set 7
                br 5 (;@1;)
              else
                local.get 2
                i32.const 1
                i32.add
                local.set 6
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 7
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 7
  )
  (func (;73;) (type 93) (param (ref 57) i32) (result (ref 3))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 51) eqref i32 i32 i64 i32 (ref 49) i64 i32 i32 i32 i32 (ref 44) (ref 51) (ref 44) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 122
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    i64.const 0
    local.set 3
    i64.const 0
    local.set 4
    i64.const 0
    local.set 5
    i64.const 0
    local.set 6
    local.get 0
    local.get 0
    call 41
    i32.const 1
    i32.add
    call 42
    local.get 0
    call 51
    local.get 0
    call 41
    local.get 0
    struct.get 57 0
    call 18
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 57 0
      local.get 0
      call 41
      call 22
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 41
      i32.const 1
      i32.add
      call 42
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 6)
      struct.new 48
      struct.new 4
    else
      i32.const 1
      local.set 35
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 35
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 0
              call 41
              local.set 7
              local.get 7
              local.get 0
              struct.get 57 0
              call 18
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 7
                struct.new 52
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 57 0
              local.get 7
              call 22
              i32.const 34
              i32.ne
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 6
                local.get 7
                local.get 0
                struct.get 57 0
                local.get 7
                call 22
                struct.new 53
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 62
              local.set 26
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 26
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 26
                    ref.cast (ref 4)
                    struct.get 4 6
                    local.set 8
                    local.get 8
                    local.set 27
                    br 2 (;@6;)
                  end
                  local.get 26
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 51)
                  local.set 9
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 9
                  struct.new 5
                  local.set 36
                  br 5 (;@2;)
                  local.set 27
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 27
              local.set 10
              local.get 2
              ref.cast (ref 6)
              struct.get 6 1
              local.set 11
              local.get 11
              i32.const 16
              i32.ge_u
              local.set 12
              local.get 12
              if (result i64) ;; label = @6
                local.get 10
                call 27
              else
                i64.const 0
              end
              local.set 13
              local.get 11
              i32.const 16
              i32.eq
              if ;; label = @6
                i32.const 0
                local.set 31
                block ;; label = @7
                  loop ;; label = @8
                    block ;; label = @9
                      i32.const 1
                      if ;; label = @10
                        local.get 31
                        local.set 14
                        local.get 14
                        local.get 11
                        i32.lt_u
                        if ;; label = @11
                          local.get 2
                          local.get 14
                          local.set 29
                          local.set 28
                          local.get 29
                          local.get 28
                          ref.cast (ref 6)
                          struct.get 6 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 28
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 122)
                          local.get 29
                          array.get 122
                          ref.cast (ref 49)
                          ref.cast (ref 49)
                          local.set 15
                          local.get 15
                          ref.cast (ref 49)
                          struct.get 49 0
                          call 67
                          local.set 16
                          local.get 16
                          call 70
                          local.set 17
                          local.get 17
                          i32.const 0
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            local.get 16
                            call 25
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 25
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 25
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 25
                                local.set 6
                              end
                            end
                          end
                          local.get 14
                          i32.const 1
                          i32.add
                          local.set 31
                          br 3 (;@8;)
                          br 2 (;@9;)
                        end
                      end
                      i32.const 1
                      if ;; label = @10
                        call 39
                        br 3 (;@7;)
                        br 1 (;@9;)
                      end
                      unreachable
                    end
                    unreachable
                  end
                  unreachable
                end
              else
              end
              local.get 12
              if (result i32) ;; label = @6
                local.get 13
                call 70
              else
                i32.const 0
              end
              local.set 18
              local.get 12
              if (result i32) ;; label = @6
                local.get 3
                local.get 4
                local.get 5
                local.get 6
                local.get 18
                local.get 13
                call 71
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 6)
                  local.get 10
                  call 68
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 6)
                local.get 10
                call 68
              end
              local.set 19
              local.get 19
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 11
                local.get 7
                local.get 10
                struct.new 54
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
                local.get 18
                i32.const 0
                i32.eq
                if (result i32) ;; label = @7
                  local.get 12
                else
                  i32.const 0
                end
                if ;; label = @7
                  local.get 3
                  local.get 13
                  call 25
                  local.set 3
                else
                  local.get 18
                  i32.const 1
                  i32.eq
                  if (result i32) ;; label = @8
                    local.get 12
                  else
                    i32.const 0
                  end
                  if ;; label = @8
                    local.get 4
                    local.get 13
                    call 25
                    local.set 4
                  else
                    local.get 18
                    i32.const 2
                    i32.eq
                    if (result i32) ;; label = @9
                      local.get 12
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 5
                      local.get 13
                      call 25
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 25
                        local.set 6
                      else
                      end
                    end
                  end
                end
              end
              local.get 0
              call 51
              local.get 0
              call 41
              local.set 20
              local.get 20
              local.get 0
              struct.get 57 0
              call 18
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 20
                struct.new 52
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 57 0
              local.get 20
              call 22
              i32.const 58
              i32.ne
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 6
                local.get 20
                local.get 0
                struct.get 57 0
                local.get 20
                call 22
                struct.new 53
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 20
              i32.const 1
              i32.add
              call 42
              local.get 0
              call 51
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 74
              local.set 32
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 32
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 32
                    ref.cast (ref 4)
                    struct.get 4 6
                    ref.cast (ref 44)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 51)
                  local.set 22
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 22
                  struct.new 5
                  local.set 36
                  br 5 (;@2;)
                  local.set 33
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 33
              ref.cast (ref 44)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 44)
              struct.new 49
              local.set 34
              local.set 28
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              local.get 28
              ref.cast (ref 6)
              struct.get 6 2
              i32.eq
              if ;; label = @6
                local.get 28
                ref.cast (ref 6)
                struct.get 6 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 28
                  ref.cast (ref 6)
                  struct.get 6 2
                  i32.const 2
                  i32.mul
                end
                local.set 29
                local.get 29
                local.get 28
                ref.cast (ref 6)
                struct.get 6 2
                i32.le_u
                if ;; label = @7
                  unreachable
                end
                local.get 29
                array.new_default 122
                local.set 30
                i32.const 0
                local.set 29
                block ;; label = @7
                  loop ;; label = @8
                    local.get 29
                    local.get 28
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.ge_u
                    br_if 1 (;@7;)
                    local.get 30
                    ref.cast (ref 122)
                    local.get 29
                    local.get 28
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 122)
                    local.get 29
                    array.get 122
                    array.set 122
                    local.get 29
                    i32.const 1
                    i32.add
                    local.set 29
                    br 0 (;@8;)
                  end
                end
                local.get 28
                ref.cast (ref 6)
                local.get 30
                struct.set 6 0
                local.get 28
                ref.cast (ref 6)
                local.get 30
                ref.cast (ref 122)
                array.len
                struct.set 6 2
              end
              local.get 28
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 122)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              local.get 34
              array.set 122
              local.get 28
              ref.cast (ref 6)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 51
              local.get 0
              call 41
              local.set 24
              local.get 24
              local.get 0
              struct.get 57 0
              call 18
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 24
                struct.new 52
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 57 0
              local.get 24
              call 22
              local.set 25
              local.get 25
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 24
                i32.const 1
                i32.add
                call 42
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 6)
                struct.new 48
                struct.new 4
                local.set 36
                br 4 (;@2;)
              else
                local.get 25
                i32.const 44
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 24
                  i32.const 1
                  i32.add
                  call 42
                  local.get 0
                  call 51
                else
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  i32.const 6
                  local.get 24
                  local.get 25
                  struct.new 53
                  struct.new 5
                  local.set 36
                  br 5 (;@2;)
                end
              end
              i32.const 1
              local.set 35
              br 2 (;@3;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 36
    end
    ref.cast (ref 3)
  )
  (func (;74;) (type 94) (param (ref 57) i32) (result (ref 3))
    (local i32 i32 eqref (ref 51) eqref eqref)
    local.get 1
    local.get 0
    struct.get 57 3
    struct.get 50 1
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 1
      local.get 1
      struct.new 52
      struct.new 5
    else
      local.get 0
      call 43
      local.get 0
      struct.get 57 3
      struct.get 50 2
      i32.ge_u
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 2
        local.get 0
        call 41
        struct.new 52
        struct.new 5
      else
        local.get 0
        local.get 0
        call 43
        i32.const 1
        i32.add
        call 44
        local.get 0
        call 51
        local.get 0
        call 41
        local.set 2
        local.get 2
        local.get 0
        struct.get 57 0
        call 18
        i32.ge_u
        if (result eqref) ;; label = @3
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          i32.const 5
          local.get 2
          struct.new 52
          struct.new 5
        else
          local.get 0
          struct.get 57 0
          local.get 2
          call 22
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 111 1
            i32.const 0
            i32.const 4
            struct.new 113
            i32.const 0
            struct.new 44
            call 63
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 111 1
              i32.const 0
              i32.const 4
              struct.new 113
              i32.const 1
              i32.const 1
              struct.new 45
              call 63
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 111 1
                i32.const 0
                i32.const 5
                struct.new 113
                i32.const 1
                i32.const 0
                struct.new 45
                call 63
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 62
                  local.set 6
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        block ;; label = @11
                          local.get 6
                          ref.cast (ref 3)
                          struct.get 3 0
                          br_table 0 (;@11;) 1 (;@10;) 2 (;@9;)
                        end
                        local.get 6
                        ref.cast (ref 4)
                        struct.get 4 6
                        local.set 4
                        i32.const 0
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 3
                        local.get 4
                        struct.new 46
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 51)
                      local.set 5
                      i32.const 1
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      local.get 5
                      struct.new 5
                      local.set 7
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  local.get 7
                else
                  local.get 3
                  i32.const 91
                  i32.eq
                  if (result eqref) ;; label = @8
                    local.get 0
                    local.get 1
                    call 65
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 73
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 52
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 64
                      else
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 6
                        local.get 2
                        local.get 3
                        struct.new 53
                        struct.new 5
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;75;) (type 95) (param eqref (ref 50)) (result (ref 3))
    (local i32 eqref eqref (ref 57) (ref 51) (ref 44) eqref i32 eqref i32 i32 eqref eqref)
    local.get 0
    call 18
    local.set 2
    local.get 2
    local.get 1
    struct.get 50 0
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 0
      local.get 2
      struct.new 52
      struct.new 5
    else
      local.get 0
      call 19
      i32.const 0
      call 1
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 4
        struct.new 51
        struct.new 5
      else
        i32.const 1
        local.set 9
        local.get 9
        array.new_default 117
        i32.const 0
        local.get 9
        struct.new 6
        local.set 3
        local.get 3
        i32.const 0
        local.set 11
        local.set 8
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 8
        ref.cast (ref 6)
        struct.get 6 2
        i32.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 6)
          struct.get 6 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 8
            ref.cast (ref 6)
            struct.get 6 2
            i32.const 2
            i32.mul
          end
          local.set 9
          local.get 9
          local.get 8
          ref.cast (ref 6)
          struct.get 6 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 9
          array.new_default 117
          local.set 10
          i32.const 0
          local.set 9
          block ;; label = @4
            loop ;; label = @5
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              br_if 1 (;@4;)
              local.get 10
              ref.cast (ref 117)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 117)
              local.get 9
              array.get 117
              array.set 117
              local.get 9
              i32.const 1
              i32.add
              local.set 9
              br 0 (;@5;)
            end
          end
          local.get 8
          ref.cast (ref 6)
          local.get 10
          struct.set 6 0
          local.get 8
          ref.cast (ref 6)
          local.get 10
          ref.cast (ref 117)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 117)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 11
        array.set 117
        local.get 8
        ref.cast (ref 6)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        i32.const 1
        i32.add
        struct.set 6 1
        i32.const 1
        local.set 9
        local.get 9
        array.new_default 117
        i32.const 0
        local.get 9
        struct.new 6
        local.set 4
        local.get 4
        i32.const 0
        local.set 12
        local.set 8
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 8
        ref.cast (ref 6)
        struct.get 6 2
        i32.eq
        if ;; label = @3
          local.get 8
          ref.cast (ref 6)
          struct.get 6 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 8
            ref.cast (ref 6)
            struct.get 6 2
            i32.const 2
            i32.mul
          end
          local.set 9
          local.get 9
          local.get 8
          ref.cast (ref 6)
          struct.get 6 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 9
          array.new_default 117
          local.set 10
          i32.const 0
          local.set 9
          block ;; label = @4
            loop ;; label = @5
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              br_if 1 (;@4;)
              local.get 10
              ref.cast (ref 117)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 117)
              local.get 9
              array.get 117
              array.set 117
              local.get 9
              i32.const 1
              i32.add
              local.set 9
              br 0 (;@5;)
            end
          end
          local.get 8
          ref.cast (ref 6)
          local.get 10
          struct.set 6 0
          local.get 8
          ref.cast (ref 6)
          local.get 10
          ref.cast (ref 117)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 117)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 12
        array.set 117
        local.get 8
        ref.cast (ref 6)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        i32.const 1
        i32.add
        struct.set 6 1
        local.get 0
        local.get 3
        ref.cast (ref 6)
        local.get 4
        ref.cast (ref 6)
        local.get 1
        ref.cast (ref 50)
        struct.new 57
        local.set 5
        local.get 5
        i32.const 0
        call 74
        local.set 13
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 13
                ref.cast (ref 3)
                struct.get 3 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;)
              end
              local.get 13
              ref.cast (ref 4)
              struct.get 4 6
              ref.cast (ref 44)
              local.set 7
              local.get 5
              call 51
              local.get 5
              call 41
              local.get 2
              i32.eq
              if (result eqref) ;; label = @6
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 7
                struct.new 4
              else
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 12
                local.get 5
                call 41
                struct.new 52
                struct.new 5
              end
              local.set 14
              br 2 (;@3;)
            end
            local.get 13
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 51)
            local.set 6
            i32.const 1
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 6
            struct.new 5
            local.set 14
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 14
      end
    end
    ref.cast (ref 3)
  )
  (func (;76;) (type 96) (param eqref) (result (ref 3))
    local.get 0
    call 40
    call 75
    ref.cast (ref 3)
  )
  (func (;77;) (type 97) (param eqref) (result (ref 3))
    local.get 0
    call 29
    call 76
    ref.cast (ref 3)
  )
  (func (;78;) (type 98) (param (ref 58) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 58 3
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 3
    array.get 117
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 58 3
      i32.const 0
      local.set 3
      local.get 1
      local.set 5
      local.set 2
      local.get 3
      local.get 2
      ref.cast (ref 6)
      struct.get 6 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 2
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 117)
      local.get 3
      local.get 5
      array.set 117
    else
    end
  )
  (func (;79;) (type 99) (param (ref 58) i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 58 3
    i32.const 0
    local.set 3
    local.set 2
    local.get 3
    local.get 2
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 3
    array.get 117
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 58 0
      call 32
      local.get 0
      struct.get 58 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 78
      else
        local.get 0
        struct.get 58 0
        local.get 1
        call 34
      end
    end
  )
  (func (;80;) (type 100) (param (ref 58) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 58 0
    call 32
    local.set 2
    local.get 1
    call 28
    local.set 3
    local.get 0
    struct.get 58 3
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 5
    array.get 117
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 58 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 58 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 78
      else
        local.get 0
        struct.get 58 0
        local.get 1
        call 33
      end
    end
  )
  (func (;81;) (type 101) (param (ref 58) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 58 0
    call 32
    local.set 2
    local.get 1
    call 18
    local.set 3
    local.get 0
    struct.get 58 3
    i32.const 0
    local.set 5
    local.set 4
    local.get 5
    local.get 4
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 4
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 5
    array.get 117
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 58 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 58 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 78
      else
        local.get 0
        struct.get 58 0
        local.get 1
        call 36
      end
    end
  )
  (func (;82;) (type 102) (param i32) (result i32)
    local.get 0
    i32.const 10
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      i32.const 48
      i32.add
      i32.const 255
      i32.and
    else
      local.get 0
      i32.const 87
      i32.add
      i32.const 255
      i32.and
    end
  )
  (func (;83;) (type 103) (param (ref 58) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    i32.const 34
    call 79
    local.get 1
    call 29
    local.set 2
    local.get 2
    call 18
    local.set 3
    i32.const 0
    local.set 4
    local.get 4
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 12
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 0
              struct.get 58 3
              i32.const 0
              local.set 10
              local.set 9
              local.get 10
              local.get 9
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 9
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 117)
              local.get 10
              array.get 117
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 48
              local.set 6
              local.get 6
              local.get 5
              i32.gt_u
              if ;; label = @6
                local.get 0
                local.get 2
                local.get 5
                local.get 6
                local.get 5
                i32.sub
                call 23
                call 81
              else
              end
              local.get 6
              local.get 3
              i32.ge_u
              if ;; label = @6
                local.get 3
                local.set 13
                br 5 (;@1;)
              else
                local.get 2
                local.get 6
                call 22
                local.set 7
                local.get 7
                i32.const 34
                i32.eq
                if (result i32) ;; label = @7
                  i32.const 1
                else
                  local.get 7
                  i32.const 92
                  i32.eq
                end
                if ;; label = @7
                  local.get 0
                  i32.const 92
                  call 79
                  local.get 0
                  local.get 7
                  call 79
                else
                  local.get 7
                  i32.const 8
                  i32.eq
                  if (result i32) ;; label = @8
                    i32.const 1
                  else
                    local.get 7
                    i32.const 12
                    i32.eq
                  end
                  if (result i32) ;; label = @8
                    i32.const 1
                  else
                    local.get 7
                    i32.const 10
                    i32.eq
                  end
                  if (result i32) ;; label = @8
                    i32.const 1
                  else
                    local.get 7
                    i32.const 13
                    i32.eq
                  end
                  if (result i32) ;; label = @8
                    i32.const 1
                  else
                    local.get 7
                    i32.const 9
                    i32.eq
                  end
                  if ;; label = @8
                    local.get 0
                    i32.const 92
                    call 79
                    local.get 0
                    local.get 7
                    i32.const 8
                    i32.eq
                    if (result i32) ;; label = @9
                      i32.const 98
                    else
                      local.get 7
                      i32.const 12
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 102
                      else
                        local.get 7
                        i32.const 10
                        i32.eq
                        if (result i32) ;; label = @11
                          i32.const 110
                        else
                          local.get 7
                          i32.const 13
                          i32.eq
                          if (result i32) ;; label = @12
                            i32.const 114
                          else
                            i32.const 116
                          end
                        end
                      end
                    end
                    call 79
                  else
                    local.get 0
                    i32.const 92
                    call 79
                    local.get 0
                    i32.const 117
                    call 79
                    local.get 0
                    i32.const 48
                    call 79
                    local.get 0
                    i32.const 48
                    call 79
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 82
                    call 79
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 82
                    call 79
                  end
                end
                local.get 6
                i32.const 1
                i32.add
                local.set 12
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 12
            local.set 8
            local.get 8
            local.set 13
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 13
    drop
    local.get 0
    i32.const 34
    call 79
  )
  (func (;84;) (type 104) (param (ref 58) (ref 44) i32)
    (local i32 eqref eqref eqref eqref i32 eqref eqref eqref i64 i64 i64 i64 i32 i32 eqref (ref 49) i64 i32 i32 eqref i32 eqref eqref i32 eqref eqref i32 eqref)
    local.get 0
    struct.get 58 3
    i32.const 0
    local.set 24
    local.set 23
    local.get 24
    local.get 23
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 23
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 24
    array.get 117
    i32.const 0
    i32.ne
    if ;; label = @1
      call 39
    else
      local.get 2
      local.get 0
      struct.get 58 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 78
      else
        local.get 1
        local.set 31
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 31
                        ref.cast (ref 44)
                        struct.get 44 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;) 4 (;@6;) 5 (;@5;) 6 (;@4;)
                      end
                      local.get 0
                      v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                      array.new_fixed 111 1
                      i32.const 0
                      i32.const 4
                      struct.new 112
                      call 80
                      br 6 (;@3;)
                    end
                    local.get 31
                    ref.cast (ref 45)
                    struct.get 45 1
                    local.set 3
                    local.get 3
                    if ;; label = @9
                      local.get 0
                      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                      array.new_fixed 111 1
                      i32.const 0
                      i32.const 4
                      struct.new 112
                      call 80
                    else
                      local.get 0
                      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                      array.new_fixed 111 1
                      i32.const 0
                      i32.const 5
                      struct.new 112
                      call 80
                    end
                    br 5 (;@3;)
                  end
                  local.get 31
                  ref.cast (ref 46)
                  struct.get 46 1
                  local.set 4
                  local.get 4
                  call 29
                  local.set 5
                  local.get 5
                  i32.const 0
                  local.get 5
                  call 18
                  call 58
                  if ;; label = @8
                    local.get 0
                    local.get 4
                    call 80
                  else
                    local.get 0
                    struct.get 58 4
                    local.get 4
                    local.set 26
                    local.set 23
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 2
                    i32.eq
                    if ;; label = @9
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 24
                      local.get 24
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.le_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 24
                      array.new_default 122
                      local.set 25
                      i32.const 0
                      local.set 24
                      block ;; label = @10
                        loop ;; label = @11
                          local.get 24
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 1
                          i32.ge_u
                          br_if 1 (;@10;)
                          local.get 25
                          ref.cast (ref 122)
                          local.get 24
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 122)
                          local.get 24
                          array.get 122
                          array.set 122
                          local.get 24
                          i32.const 1
                          i32.add
                          local.set 24
                          br 0 (;@11;)
                        end
                      end
                      local.get 23
                      ref.cast (ref 6)
                      local.get 25
                      struct.set 6 0
                      local.get 23
                      ref.cast (ref 6)
                      local.get 25
                      ref.cast (ref 122)
                      array.len
                      struct.set 6 2
                    end
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 122)
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 26
                    array.set 122
                    local.get 23
                    ref.cast (ref 6)
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.const 1
                    i32.add
                    struct.set 6 1
                    local.get 0
                    i32.const 2
                    call 78
                  end
                  br 4 (;@3;)
                end
                local.get 31
                ref.cast (ref 46)
                struct.get 46 1
                local.set 6
                local.get 0
                local.get 6
                call 83
                br 3 (;@3;)
              end
              local.get 31
              ref.cast (ref 47)
              struct.get 47 1
              local.set 7
              local.get 0
              i32.const 91
              call 79
              i32.const 1
              local.set 8
              local.get 7
              i32.const 0
              i32.const 0
              struct.new 6
              local.set 9
              i32.const 1
              local.set 27
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 27
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 9
                      local.set 23
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 0
                        struct.get 58 3
                        i32.const 0
                        local.set 24
                        local.set 23
                        local.get 24
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 117)
                        local.get 24
                        array.get 117
                        i32.const 0
                        i32.eq
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 8
                        if ;; label = @11
                          i32.const 0
                          local.set 8
                        else
                          local.get 0
                          i32.const 44
                          call 79
                        end
                        local.get 0
                        local.get 9
                        local.set 23
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.lt_u
                        if ;; label = @11
                        else
                          unreachable
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.set 24
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 122)
                        local.get 24
                        array.get 122
                        local.get 23
                        ref.cast (ref 6)
                        local.get 24
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        ref.cast (ref 44)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 84
                        i32.const 1
                        local.set 27
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 39
                      br 3 (;@6;)
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 0
              i32.const 93
              call 79
              br 2 (;@3;)
            end
            local.get 31
            ref.cast (ref 48)
            struct.get 48 1
            local.set 10
            local.get 0
            i32.const 123
            call 79
            i32.const 0
            array.new_default 122
            i32.const 0
            i32.const 0
            struct.new 6
            local.set 11
            i64.const 0
            local.set 12
            i64.const 0
            local.set 13
            i64.const 0
            local.set 14
            i64.const 0
            local.set 15
            local.get 10
            ref.cast (ref 6)
            struct.get 6 1
            i32.const 16
            i32.ge_u
            local.set 16
            i32.const 1
            local.set 17
            local.get 10
            i32.const 0
            i32.const 0
            struct.new 6
            local.set 18
            i32.const 1
            local.set 30
            block ;; label = @5
              loop ;; label = @6
                block ;; label = @7
                  local.get 30
                  i32.const 1
                  i32.eq
                  if ;; label = @8
                    local.get 18
                    local.set 23
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.lt_u
                    if (result i32) ;; label = @9
                      local.get 0
                      struct.get 58 3
                      i32.const 0
                      local.set 24
                      local.set 23
                      local.get 24
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 117)
                      local.get 24
                      array.get 117
                      i32.const 0
                      i32.eq
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 18
                      local.set 23
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.lt_u
                      if ;; label = @10
                      else
                        unreachable
                      end
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.set 24
                      local.get 23
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 122)
                      local.get 24
                      array.get 122
                      local.get 23
                      ref.cast (ref 6)
                      local.get 24
                      i32.const 1
                      i32.add
                      struct.set 6 1
                      ref.cast (ref 49)
                      ref.cast (ref 49)
                      local.set 19
                      local.get 16
                      if (result i64) ;; label = @10
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 0
                        call 67
                      else
                        i64.const 0
                      end
                      local.set 20
                      local.get 16
                      if (result i32) ;; label = @10
                        local.get 20
                        call 70
                      else
                        i32.const 0
                      end
                      local.set 21
                      local.get 16
                      if (result i32) ;; label = @10
                        local.get 12
                        local.get 13
                        local.get 14
                        local.get 15
                        local.get 21
                        local.get 20
                        call 71
                        if (result i32) ;; label = @11
                          local.get 11
                          ref.cast (ref 6)
                          local.get 19
                          ref.cast (ref 49)
                          struct.get 49 0
                          call 72
                        else
                          i32.const 0
                        end
                      else
                        local.get 11
                        ref.cast (ref 6)
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 0
                        call 72
                      end
                      local.set 22
                      local.get 22
                      if ;; label = @10
                        local.get 0
                        struct.get 58 5
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 0
                        local.set 28
                        local.set 23
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.eq
                        if ;; label = @11
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.eqz
                          if (result i32) ;; label = @12
                            i32.const 4
                          else
                            local.get 23
                            ref.cast (ref 6)
                            struct.get 6 2
                            i32.const 2
                            i32.mul
                          end
                          local.set 24
                          local.get 24
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.le_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 24
                          array.new_default 122
                          local.set 25
                          i32.const 0
                          local.set 24
                          block ;; label = @12
                            loop ;; label = @13
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 1
                              i32.ge_u
                              br_if 1 (;@12;)
                              local.get 25
                              ref.cast (ref 122)
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 122)
                              local.get 24
                              array.get 122
                              array.set 122
                              local.get 24
                              i32.const 1
                              i32.add
                              local.set 24
                              br 0 (;@13;)
                            end
                          end
                          local.get 23
                          ref.cast (ref 6)
                          local.get 25
                          struct.set 6 0
                          local.get 23
                          ref.cast (ref 6)
                          local.get 25
                          ref.cast (ref 122)
                          array.len
                          struct.set 6 2
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 122)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 28
                        array.set 122
                        local.get 23
                        ref.cast (ref 6)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        local.get 0
                        i32.const 4
                        call 78
                      else
                        local.get 21
                        i32.const 0
                        i32.eq
                        if (result i32) ;; label = @11
                          local.get 16
                        else
                          i32.const 0
                        end
                        if ;; label = @11
                          local.get 12
                          local.get 20
                          call 25
                          local.set 12
                        else
                          local.get 21
                          i32.const 1
                          i32.eq
                          if (result i32) ;; label = @12
                            local.get 16
                          else
                            i32.const 0
                          end
                          if ;; label = @12
                            local.get 13
                            local.get 20
                            call 25
                            local.set 13
                          else
                            local.get 21
                            i32.const 2
                            i32.eq
                            if (result i32) ;; label = @13
                              local.get 16
                            else
                              i32.const 0
                            end
                            if ;; label = @13
                              local.get 14
                              local.get 20
                              call 25
                              local.set 14
                            else
                              local.get 16
                              if ;; label = @14
                                local.get 15
                                local.get 20
                                call 25
                                local.set 15
                              else
                              end
                            end
                          end
                        end
                        local.get 11
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 0
                        local.set 29
                        local.set 23
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.eq
                        if ;; label = @11
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.eqz
                          if (result i32) ;; label = @12
                            i32.const 4
                          else
                            local.get 23
                            ref.cast (ref 6)
                            struct.get 6 2
                            i32.const 2
                            i32.mul
                          end
                          local.set 24
                          local.get 24
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.le_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 24
                          array.new_default 122
                          local.set 25
                          i32.const 0
                          local.set 24
                          block ;; label = @12
                            loop ;; label = @13
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 1
                              i32.ge_u
                              br_if 1 (;@12;)
                              local.get 25
                              ref.cast (ref 122)
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 122)
                              local.get 24
                              array.get 122
                              array.set 122
                              local.get 24
                              i32.const 1
                              i32.add
                              local.set 24
                              br 0 (;@13;)
                            end
                          end
                          local.get 23
                          ref.cast (ref 6)
                          local.get 25
                          struct.set 6 0
                          local.get 23
                          ref.cast (ref 6)
                          local.get 25
                          ref.cast (ref 122)
                          array.len
                          struct.set 6 2
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 122)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 29
                        array.set 122
                        local.get 23
                        ref.cast (ref 6)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        local.get 17
                        if ;; label = @11
                          i32.const 0
                          local.set 17
                        else
                          local.get 0
                          i32.const 44
                          call 79
                        end
                        local.get 0
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 0
                        call 83
                        local.get 0
                        i32.const 58
                        call 79
                        local.get 0
                        local.get 19
                        ref.cast (ref 49)
                        struct.get 49 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 84
                      end
                      i32.const 1
                      local.set 30
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 39
                    br 3 (;@5;)
                    br 1 (;@7;)
                  end
                  unreachable
                end
                unreachable
              end
              unreachable
            end
            local.get 0
            i32.const 125
            call 79
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;85;) (type 105) (param (ref 44) i32 i32) (result (ref 3))
    (local eqref (ref 58) eqref i32 eqref i32)
    i32.const 1
    local.set 6
    local.get 6
    array.new_default 117
    i32.const 0
    local.get 6
    struct.new 6
    local.set 3
    local.get 3
    i32.const 0
    local.set 8
    local.set 5
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    local.get 5
    ref.cast (ref 6)
    struct.get 6 2
    i32.eq
    if ;; label = @1
      local.get 5
      ref.cast (ref 6)
      struct.get 6 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 5
        ref.cast (ref 6)
        struct.get 6 2
        i32.const 2
        i32.mul
      end
      local.set 6
      local.get 6
      local.get 5
      ref.cast (ref 6)
      struct.get 6 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 6
      array.new_default 117
      local.set 7
      i32.const 0
      local.set 6
      block ;; label = @2
        loop ;; label = @3
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 1
          i32.ge_u
          br_if 1 (;@2;)
          local.get 7
          ref.cast (ref 117)
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 117)
          local.get 6
          array.get 117
          array.set 117
          local.get 6
          i32.const 1
          i32.add
          local.set 6
          br 0 (;@3;)
        end
      end
      local.get 5
      ref.cast (ref 6)
      local.get 7
      struct.set 6 0
      local.get 5
      ref.cast (ref 6)
      local.get 7
      ref.cast (ref 117)
      array.len
      struct.set 6 2
    end
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    local.get 8
    array.set 117
    local.get 5
    ref.cast (ref 6)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    i32.const 1
    i32.add
    struct.set 6 1
    call 31
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 6)
    i32.const 0
    array.new_default 122
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    i32.const 0
    array.new_default 122
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    struct.new 58
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 84
    local.get 3
    i32.const 0
    local.set 6
    local.set 5
    local.get 6
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 117)
    local.get 6
    array.get 117
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 0
      struct.new 55
      struct.new 5
    else
      local.get 3
      i32.const 0
      local.set 6
      local.set 5
      local.get 6
      local.get 5
      ref.cast (ref 6)
      struct.get 6 1
      i32.ge_u
      if ;; label = @2
        unreachable
      end
      local.get 5
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 117)
      local.get 6
      array.get 117
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 2
        local.get 4
        ref.cast (ref 58)
        struct.get 58 4
        i32.const 0
        local.set 6
        local.set 5
        local.get 6
        local.get 5
        ref.cast (ref 6)
        struct.get 6 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 5
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 122)
        local.get 6
        array.get 122
        struct.new 56
        struct.new 5
      else
        local.get 3
        i32.const 0
        local.set 6
        local.set 5
        local.get 6
        local.get 5
        ref.cast (ref 6)
        struct.get 6 1
        i32.ge_u
        if ;; label = @3
          unreachable
        end
        local.get 5
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 117)
        local.get 6
        array.get 117
        i32.const 3
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          i32.const 1
          struct.new 55
          struct.new 5
        else
          local.get 3
          i32.const 0
          local.set 6
          local.set 5
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 1
          i32.ge_u
          if ;; label = @4
            unreachable
          end
          local.get 5
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 117)
          local.get 6
          array.get 117
          i32.const 4
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 1
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            i32.const 3
            local.get 4
            ref.cast (ref 58)
            struct.get 58 5
            i32.const 0
            local.set 6
            local.set 5
            local.get 6
            local.get 5
            ref.cast (ref 6)
            struct.get 6 1
            i32.ge_u
            if ;; label = @5
              unreachable
            end
            local.get 5
            ref.cast (ref 6)
            struct.get 6 0
            ref.cast (ref 122)
            local.get 6
            array.get 122
            struct.new 56
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 58)
            struct.get 58 0
            call 37
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;86;) (type 106) (param (ref 44)) (result (ref 3))
    local.get 0
    i32.const 128
    i32.const 16777216
    call 85
    ref.cast (ref 3)
  )
  (func (;87;) (type 107) (param (ref 6) eqref) (result (ref 1))
    (local i32 (ref 49) eqref i32 eqref i32 eqref)
    i32.const 0
    local.set 7
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 7
            local.set 2
            local.get 2
            local.get 0
            ref.cast (ref 6)
            struct.get 6 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 2
              local.set 5
              local.set 4
              local.get 5
              local.get 4
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 122)
              local.get 5
              array.get 122
              ref.cast (ref 49)
              ref.cast (ref 49)
              local.set 3
              local.get 3
              ref.cast (ref 49)
              struct.get 49 0
              local.get 1
              call 66
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 3
                ref.cast (ref 49)
                struct.get 49 1
                struct.new 2
                local.set 8
                br 5 (;@1;)
              else
                local.get 2
                i32.const 1
                i32.add
                local.set 7
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            struct.new 1
            local.set 8
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 8
    ref.cast (ref 1)
  )
  (func (;88;) (type 109) (param i32 eqref) (result i32)
    (local (ref 113) (ref 111) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 113)
    local.set 2
    local.get 2
    struct.get 113 0
    local.set 3
    local.get 2
    struct.get 113 1
    local.set 4
    local.get 2
    struct.get 113 2
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
              array.get 111
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
              array.get 111
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
              array.get 111
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
              array.get 111
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
                array.get 111
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 111
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
                array.get 111
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
            array.get 111
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
  (func (;89;) (type 110) (result i32)
    (local eqref i32 eqref i32 eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x227b2020 0x7373656d 0x22656761 0x4953223a
    v128.const i32x4 0x3020444d 0x34333231 0x38373635 0x63626139
    v128.const i32x4 0x20666564 0x2c22bbce 0x6c617622 0x22736575
    v128.const i32x4 0x756e5b3a 0x742c6c6c 0x2c657572 0x2e32312d
    v128.const i32x4 0x5d326535 0x0020207d 0x00000000 0x00000000
    array.new_fixed 111 5
    i32.const 0
    i32.const 71
    struct.new 112
    call 77
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 8
        ref.cast (ref 4)
        struct.get 4 6
        ref.cast (ref 44)
        struct.get 44 0
        i32.const 5
        i32.eq
        if (result i32) ;; label = @3
          local.get 8
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 48)
          struct.get 48 1
          local.set 0
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 0
        ref.cast (ref 6)
        v128.const i32x4 0x7373656d 0x00656761 0x00000000 0x00000000
        array.new_fixed 111 1
        i32.const 0
        i32.const 7
        struct.new 112
        call 87
        local.set 4
        block ;; label = @3
          local.get 4
          ref.cast (ref 1)
          struct.get 1 0
          i32.const 1
          i32.eq
          if (result i32) ;; label = @4
            local.get 4
            ref.cast (ref 2)
            struct.get 2 6
            ref.cast (ref 44)
            struct.get 44 0
            i32.const 3
            i32.eq
            if (result i32) ;; label = @5
              local.get 4
              ref.cast (ref 2)
              struct.get 2 6
              ref.cast (ref 46)
              struct.get 46 1
              v128.const i32x4 0x444d4953 0x32313020 0x36353433 0x61393837
              v128.const i32x4 0x65646362 0xbbce2066 0x00000000 0x00000000
              array.new_fixed 111 2
              i32.const 0
              i32.const 24
              struct.new 112
              call 4
            else
              i32.const 0
            end
          else
            i32.const 0
          end
          if ;; label = @4
            i32.const 1
            local.set 5
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 5
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 5
        local.set 1
        i32.const 5
        local.get 0
        ref.cast (ref 6)
        struct.new 48
        call 86
        local.set 6
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                local.get 6
                ref.cast (ref 3)
                struct.get 3 0
                br_table 0 (;@6;) 1 (;@5;) 2 (;@4;)
              end
              local.get 6
              ref.cast (ref 4)
              struct.get 4 6
              local.set 2
              local.get 2
              v128.const i32x4 0x656d227b 0x67617373 0x223a2265 0x444d4953
              v128.const i32x4 0x32313020 0x36353433 0x61393837 0x65646362
              v128.const i32x4 0xbbce2066 0x76222c22 0x65756c61 0x5b3a2273
              v128.const i32x4 0x6c6c756e 0x7572742c 0x312d2c65 0x65352e32
              v128.const i32x4 0x007d5d32 0x00000000 0x00000000 0x00000000
              array.new_fixed 111 5
              i32.const 0
              i32.const 67
              struct.new 112
              call 30
              local.set 7
              br 2 (;@3;)
            end
            i32.const 0
            local.set 7
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 7
        local.set 3
        local.get 1
        if (result i32) ;; label = @3
          local.get 3
        else
          i32.const 0
        end
        if (result i32) ;; label = @3
          i32.const 1
          v128.const i32x4 0x6e6f736a 0x7274733a 0x2d746369 0x646d6973
          array.new_fixed 111 1
          i32.const 0
          i32.const 16
          struct.new 113
          call 88
        else
          i32.const 1
          v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
          array.new_fixed 111 1
          i32.const 0
          i32.const 4
          struct.new 113
          call 88
        end
        local.set 9
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 1
        v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
        array.new_fixed 111 1
        i32.const 0
        i32.const 4
        struct.new 113
        call 88
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
  )
)
