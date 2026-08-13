(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;6;) (struct (field eqref)))
  (type (;7;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref eqref) (result i32)))
  (type (;11;) (func (param eqref) (result i64)))
  (type (;12;) (func (param eqref i32) (result i32)))
  (type (;13;) (func (param eqref i32 i32) (result eqref)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (result eqref)))
  (type (;16;) (func (param i32) (result eqref)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref eqref)))
  (type (;19;) (func (param eqref eqref)))
  (type (;20;) (func (param eqref i32)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref i32) (result i32)))
  (type (;26;) (func (param eqref i32 i32) (result eqref)))
  (type (;27;) (func (param eqref) (result i32)))
  (type (;28;) (func (param eqref eqref) (result i32)))
  (type (;29;) (func (param eqref i32) (result i32)))
  (type (;30;) (func (param eqref i32 i32) (result eqref)))
  (type (;31;) (func (param i64) (result i64)))
  (type (;32;) (func (param i64 i64) (result i64)))
  (type (;33;) (func (param i64 i64) (result i32)))
  (type (;34;) (func (param eqref) (result i64)))
  (type (;35;) (func (param eqref) (result i32)))
  (type (;36;) (func (param eqref) (result eqref)))
  (type (;37;) (func (param eqref eqref) (result i32)))
  (type (;38;) (func (param eqref i32) (result i32)))
  (type (;39;) (func (param eqref i32 i32) (result eqref)))
  (type (;40;) (func (param eqref) (result i32)))
  (type (;41;) (func (param eqref) (result eqref)))
  (type (;42;) (func (result eqref)))
  (type (;43;) (func (param eqref) (result i32)))
  (type (;44;) (func (param eqref eqref)))
  (type (;45;) (func (param eqref eqref)))
  (type (;46;) (func (param eqref i32)))
  (type (;47;) (func (param eqref i32)))
  (type (;48;) (func (param eqref) (result eqref)))
  (type (;49;) (func (param eqref i32) (result v128)))
  (type (;50;) (func (param eqref i32) (result v128)))
  (type (;51;) (sub (struct (field i32))))
  (type (;52;) (sub final 51 (struct (field i32) (field i32))))
  (type (;53;) (sub final 51 (struct (field i32) (field eqref))))
  (type (;54;) (sub final 51 (struct (field i32) (field (ref 7)))))
  (type (;55;) (sub final 51 (struct (field i32) (field (ref 7)))))
  (type (;56;) (struct (field eqref) (field (ref 51))))
  (type (;57;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;58;) (sub (struct (field i32))))
  (type (;59;) (sub final 58 (struct (field i32) (field i32))))
  (type (;60;) (sub final 58 (struct (field i32) (field i32) (field i8))))
  (type (;61;) (sub final 58 (struct (field i32) (field i32) (field eqref))))
  (type (;62;) (sub (struct (field i32))))
  (type (;63;) (sub final 62 (struct (field i32) (field eqref))))
  (type (;64;) (struct (field eqref) (field eqref) (field (ref 6)) (field (ref 57))))
  (type (;65;) (struct (field eqref) (field i32) (field i32) (field (ref 6)) (field (ref 6))))
  (type (;66;) (func))
  (type (;67;) (func (result (ref 57))))
  (type (;68;) (func (param (ref 64)) (result i32)))
  (type (;69;) (func (param (ref 64) i32)))
  (type (;70;) (func (param (ref 64)) (result i32)))
  (type (;71;) (func (param (ref 64) i32)))
  (type (;72;) (func (param i32) (result i32)))
  (type (;73;) (func (param i32) (result i32)))
  (type (;74;) (func (param eqref i32) (result i32)))
  (type (;75;) (func (param eqref i32) (result i32)))
  (type (;76;) (func (param eqref i32) (result i32)))
  (type (;77;) (func (param i32) (result i32)))
  (type (;78;) (func (param eqref i32) (result i32)))
  (type (;79;) (func (param (ref 64))))
  (type (;80;) (func (param i32) (result i32)))
  (type (;81;) (func (param i32) (result i32)))
  (type (;82;) (func (param eqref i32 i32) (result i32)))
  (type (;83;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;84;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;85;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;86;) (func (param eqref i32 i32) (result i32)))
  (type (;87;) (func (param i32) (result i32)))
  (type (;88;) (func (param eqref i32) (result (ref 1))))
  (type (;89;) (func (param (ref 64) eqref i32 i32) (result i32)))
  (type (;90;) (func (param (ref 64)) (result (ref 3))))
  (type (;91;) (func (param (ref 64) eqref (ref 51)) (result (ref 3))))
  (type (;92;) (func (param (ref 64)) (result (ref 3))))
  (type (;93;) (func (param (ref 64) i32) (result (ref 3))))
  (type (;94;) (func (param eqref eqref) (result i32)))
  (type (;95;) (func (param eqref) (result i64)))
  (type (;96;) (func (param (ref 7) i32 eqref) (result i32)))
  (type (;97;) (func (param (ref 7) eqref) (result i32)))
  (type (;98;) (func (param i64) (result i32)))
  (type (;99;) (func (param i64) (result i32)))
  (type (;100;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;101;) (func (param (ref 64) i32) (result (ref 3))))
  (type (;102;) (func (param (ref 64) i32) (result (ref 3))))
  (type (;103;) (func (param eqref (ref 57)) (result (ref 3))))
  (type (;104;) (func (param eqref) (result (ref 3))))
  (type (;105;) (func (param (ref 65) i32)))
  (type (;106;) (func (param (ref 65) i32 eqref)))
  (type (;107;) (func (param (ref 65) i32)))
  (type (;108;) (func (param (ref 65) eqref)))
  (type (;109;) (func (param (ref 65) eqref)))
  (type (;110;) (func (param i32) (result i32)))
  (type (;111;) (func (param (ref 65) eqref)))
  (type (;112;) (func (param (ref 65) (ref 51) i32)))
  (type (;113;) (func (param (ref 51) i32 i32) (result (ref 3))))
  (type (;114;) (func (param (ref 51)) (result (ref 3))))
  (type (;115;) (func (result i32)))
  (type (;116;) (array (mut v128)))
  (type (;117;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;118;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;119;) (struct (field (ref 116)) (field i32) (field i32)))
  (type (;120;) (struct (field (mut (ref 116))) (field (mut i32)) (field (mut i32))))
  (type (;121;) (struct (field (mut (ref 116))) (field (mut i32)) (field (mut i32))))
  (type (;122;) (array (mut i32)))
  (type (;123;) (array (mut i64)))
  (type (;124;) (array (mut f32)))
  (type (;125;) (array (mut f64)))
  (type (;126;) (array (mut v128)))
  (type (;127;) (array (mut eqref)))
  (memory (;0;) 1)
  (export "main" (func 93))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;1;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 117)
    struct.get 117 2
  )
  (func (;2;) (type 9) (param eqref) (result eqref)
    (local (ref 117))
    local.get 0
    ref.cast (ref 117)
    local.tee 1
    struct.get 117 0
    local.get 1
    struct.get 117 1
    local.get 1
    struct.get 117 2
    struct.new 118
  )
  (func (;3;) (type 10) (param eqref eqref) (result i32)
    (local (ref 117) (ref 117) (ref 116) (ref 116) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 117)
    local.set 2
    local.get 1
    ref.cast (ref 117)
    local.set 3
    local.get 2
    struct.get 117 2
    local.tee 6
    local.get 3
    struct.get 117 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 117 0
    local.set 4
    local.get 3
    struct.get 117 0
    local.set 5
    local.get 2
    struct.get 117 1
    local.set 7
    local.get 3
    struct.get 117 1
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
          array.get 116
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 116
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
          array.get 116
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
          array.get 116
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 116
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
          array.get 116
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
      array.get 116
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
      array.get 116
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
  (func (;4;) (type 11) (param eqref) (result i64)
    (local (ref 117) (ref 116) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 117)
    local.set 1
    local.get 1
    struct.get 117 0
    local.set 2
    local.get 1
    struct.get 117 1
    local.set 3
    local.get 1
    struct.get 117 2
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
      array.get 116
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
  (func (;5;) (type 12) (param eqref i32) (result i32)
    (local (ref 117) (ref 116) i32)
    local.get 0
    ref.cast (ref 117)
    local.set 2
    local.get 1
    local.get 2
    struct.get 117 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 117 0
    local.set 3
    local.get 2
    struct.get 117 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 116
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;6;) (type 13) (param eqref i32 i32) (result eqref)
    (local (ref 117) (ref 116) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 117)
    local.set 3
    local.get 3
    struct.get 117 2
    local.set 5
    local.get 1
    local.get 5
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    local.get 5
    local.get 1
    i32.sub
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 3
    struct.get 117 0
    local.set 4
    local.get 3
    struct.get 117 1
    local.get 1
    i32.add
    local.set 6
    local.get 1
    local.get 2
    i32.add
    local.set 7
    local.get 1
    i32.eqz
    i32.eqz
    if ;; label = @1
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 116
      local.get 6
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        unreachable
      end
    end
    local.get 7
    local.get 5
    i32.lt_u
    if ;; label = @1
      local.get 6
      local.get 2
      i32.add
      local.set 6
      local.get 4
      local.get 6
      i32.const 4
      i32.shr_u
      array.get 116
      local.get 6
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.swizzle
      i8x16.extract_lane_u 0
      local.set 8
      local.get 8
      i32.const 192
      i32.and
      i32.const 128
      i32.eq
      if ;; label = @2
        unreachable
      end
    end
    local.get 4
    local.get 3
    struct.get 117 1
    local.get 1
    i32.add
    local.get 2
    struct.new 119
  )
  (func (;7;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 119)
    struct.get 119 2
  )
  (func (;8;) (type 15) (result eqref)
    i32.const 4
    array.new_default 116
    i32.const 0
    i32.const 0
    struct.new 120
  )
  (func (;9;) (type 16) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 116
    i32.const 0
    i32.const 0
    struct.new 120
  )
  (func (;10;) (type 17) (param eqref) (result i32)
    (local (ref 120))
    local.get 0
    ref.cast (ref 120)
    local.tee 1
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 120 1
  )
  (func (;11;) (type 18) (param eqref eqref)
    (local (ref 120) (ref 117) (ref 116) (ref 116) i32 i32 i32 i32 i32 i32 (ref 116) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 120)
    local.set 2
    local.get 2
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 117)
    local.set 3
    local.get 2
    struct.get 120 0
    local.set 4
    local.get 3
    struct.get 117 0
    local.set 5
    local.get 2
    struct.get 120 1
    local.set 6
    local.get 3
    struct.get 117 1
    local.set 7
    local.get 3
    struct.get 117 2
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
      array.new_default 116
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
          array.get 116
          array.set 116
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 120 0
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
            array.get 116
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 116
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
            array.get 116
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
            array.set 116
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
            array.get 116
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
            array.set 116
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
            array.get 116
            local.get 19
            v128.bitselect
            array.set 116
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
        array.get 116
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
        array.get 116
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 116
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 120 1
  )
  (func (;12;) (type 19) (param eqref eqref)
    (local (ref 120) (ref 119) (ref 116) (ref 116) i32 i32 i32 i32 i32 i32 (ref 116) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 120)
    local.set 2
    local.get 2
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 119)
    local.set 3
    local.get 2
    struct.get 120 0
    local.set 4
    local.get 3
    struct.get 119 0
    local.set 5
    local.get 2
    struct.get 120 1
    local.set 6
    local.get 3
    struct.get 119 1
    local.set 7
    local.get 3
    struct.get 119 2
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
      array.new_default 116
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
          array.get 116
          array.set 116
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 120 0
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
            array.get 116
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 116
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
            array.get 116
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
            array.set 116
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
            array.get 116
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
            array.set 116
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
            array.get 116
            local.get 19
            v128.bitselect
            array.set 116
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
        array.get 116
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
        array.get 116
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 116
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 120 1
  )
  (func (;13;) (type 20) (param eqref i32)
    (local (ref 120) (ref 116) i32 i32 i32 (ref 116) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 120)
    local.set 2
    local.get 2
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 120 0
    local.set 3
    local.get 2
    struct.get 120 1
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
      array.new_default 116
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
          array.get 116
          array.set 116
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 120 0
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
    array.get 116
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 116
    local.get 2
    local.get 5
    struct.set 120 1
  )
  (func (;14;) (type 21) (param eqref i32)
    (local (ref 120) (ref 116) i32 i32 i32 i32 i32 (ref 116) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 120)
    local.set 2
    local.get 2
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 120 0
    local.set 3
    local.get 2
    struct.get 120 1
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
      array.new_default 116
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
          array.get 116
          array.set 116
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 120 0
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
    array.get 116
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 116
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
      array.get 116
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 116
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
      array.get 116
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 116
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
      array.get 116
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 116
    end
    local.get 2
    local.get 6
    struct.set 120 1
  )
  (func (;15;) (type 22) (param eqref) (result eqref)
    (local (ref 120))
    local.get 0
    ref.cast (ref 120)
    local.set 1
    local.get 1
    struct.get 120 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 120 2
    local.get 1
    struct.get 120 0
    i32.const 0
    local.get 1
    struct.get 120 1
    struct.new 117
  )
  (func (;16;) (type 23) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 118)
    struct.get 118 2
  )
  (func (;17;) (type 24) (param eqref eqref) (result i32)
    (local (ref 118) (ref 118) (ref 116) (ref 116) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 118)
    local.set 2
    local.get 1
    ref.cast (ref 118)
    local.set 3
    local.get 2
    struct.get 118 2
    local.tee 6
    local.get 3
    struct.get 118 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 118 0
    local.set 4
    local.get 3
    struct.get 118 0
    local.set 5
    local.get 2
    struct.get 118 1
    local.set 7
    local.get 3
    struct.get 118 1
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
          array.get 116
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 116
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
          array.get 116
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
          array.get 116
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 116
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
          array.get 116
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
      array.get 116
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
      array.get 116
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
  (func (;18;) (type 25) (param eqref i32) (result i32)
    (local (ref 118) (ref 116) i32)
    local.get 0
    ref.cast (ref 118)
    local.set 2
    local.get 1
    local.get 2
    struct.get 118 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 118 0
    local.set 3
    local.get 2
    struct.get 118 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 116
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;19;) (type 26) (param eqref i32 i32) (result eqref)
    (local (ref 118) i32)
    local.get 0
    ref.cast (ref 118)
    local.set 3
    local.get 3
    struct.get 118 2
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
    struct.get 118 0
    local.get 3
    struct.get 118 1
    local.get 1
    i32.add
    local.get 2
    struct.new 118
  )
  (func (;20;) (type 27) (param eqref) (result i32)
    local.get 0
    call 16
  )
  (func (;21;) (type 28) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 17
  )
  (func (;22;) (type 29) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 18
  )
  (func (;23;) (type 30) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 19
  )
  (func (;24;) (type 31) (param i64) (result i64)
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
  (func (;25;) (type 32) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 24
    i64.or
  )
  (func (;26;) (type 33) (param i64 i64) (result i32)
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
  (func (;27;) (type 34) (param eqref) (result i64)
    local.get 0
    call 4
  )
  (func (;28;) (type 35) (param eqref) (result i32)
    local.get 0
    call 1
  )
  (func (;29;) (type 36) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;30;) (type 37) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;31;) (type 38) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;32;) (type 39) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 6
  )
  (func (;33;) (type 40) (param eqref) (result i32)
    local.get 0
    call 7
  )
  (func (;34;) (type 41) (param eqref) (result eqref)
    (local eqref)
    local.get 0
    call 33
    call 9
    local.set 1
    local.get 1
    local.get 0
    call 12
    local.get 1
    call 15
  )
  (func (;35;) (type 42) (result eqref)
    call 8
  )
  (func (;36;) (type 43) (param eqref) (result i32)
    local.get 0
    call 10
  )
  (func (;37;) (type 44) (param eqref eqref)
    local.get 0
    local.get 1
    call 11
  )
  (func (;38;) (type 45) (param eqref eqref)
    local.get 0
    local.get 1
    call 12
  )
  (func (;39;) (type 46) (param eqref i32)
    local.get 0
    local.get 1
    call 13
  )
  (func (;40;) (type 47) (param eqref i32)
    local.get 0
    local.get 1
    call 14
  )
  (func (;41;) (type 48) (param eqref) (result eqref)
    local.get 0
    call 15
  )
  (func (;42;) (type 49) (param eqref i32) (result v128)
    (local (ref 118) (ref 116) i32 v128)
    local.get 0
    ref.cast (ref 118)
    local.set 2
    local.get 1
    local.get 2
    struct.get 118 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 118 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 118 0
    local.set 3
    local.get 2
    struct.get 118 1
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
      array.get 116
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 116
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
      array.get 116
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
  (func (;43;) (type 50) (param eqref i32) (result v128)
    (local (ref 117) (ref 116) i32 v128)
    local.get 0
    ref.cast (ref 117)
    local.set 2
    local.get 1
    local.get 2
    struct.get 117 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 117 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 117 0
    local.set 3
    local.get 2
    struct.get 117 1
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
      array.get 116
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 116
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
      array.get 116
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
  (func (;44;) (type 66))
  (func (;45;) (type 67) (result (ref 57))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 57
    ref.cast (ref 57)
  )
  (func (;46;) (type 68) (param (ref 64)) (result i32)
    local.get 0
    struct.get 64 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
  )
  (func (;47;) (type 69) (param (ref 64) i32)
    local.get 0
    struct.get 64 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    local.get 1
    array.set 122
  )
  (func (;48;) (type 70) (param (ref 64)) (result i32)
    local.get 0
    struct.get 64 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 1
    array.get 122
  )
  (func (;49;) (type 71) (param (ref 64) i32)
    local.get 0
    struct.get 64 2
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 1
    local.get 1
    array.set 122
  )
  (func (;50;) (type 72) (param i32) (result i32)
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
  (func (;51;) (type 73) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;52;) (type 74) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 20
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
              call 42
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
                call 51
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
              call 50
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
  (func (;53;) (type 75) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 28
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
              call 43
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
                call 51
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
              call 31
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
  (func (;54;) (type 76) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 20
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
              call 42
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
                call 51
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
  (func (;55;) (type 77) (param i32) (result i32)
    local.get 0
    call 50
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
  (func (;56;) (type 78) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 20
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
              call 42
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
                call 51
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
              call 55
              i32.const 0
              call 0
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
  (func (;57;) (type 79) (param (ref 64))
    local.get 0
    local.get 0
    struct.get 64 0
    local.get 0
    call 46
    call 52
    call 47
  )
  (func (;58;) (type 80) (param i32) (result i32)
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
  (func (;59;) (type 81) (param i32) (result i32)
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
  (func (;60;) (type 82) (param eqref i32 i32) (result i32)
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
              call 58
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
  (func (;61;) (type 83) (param eqref i32 i32) (result (ref 1))
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
          call 58
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
        call 59
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 60
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
  (func (;62;) (type 84) (param eqref i32 i32) (result (ref 1))
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
        call 58
        i32.const 0
        call 0
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
        call 60
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
  (func (;63;) (type 85) (param eqref i32 i32) (result (ref 1))
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
        call 58
        i32.const 0
        call 0
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
        call 60
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
  (func (;64;) (type 86) (param eqref i32 i32) (result i32)
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
      call 61
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
          call 62
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
              call 63
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
  (func (;65;) (type 87) (param i32) (result i32)
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
  (func (;66;) (type 88) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 20
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 20
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
      call 65
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 22
      call 65
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 22
      call 65
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 22
      call 65
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
  (func (;67;) (type 89) (param (ref 64) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 36
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 64 3
      struct.get 57 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 64 3
      struct.get 57 3
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
        struct.get 64 1
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 32
        call 38
      else
      end
      i32.const 1
    end
  )
  (func (;68;) (type 90) (param (ref 64)) (result (ref 3))
    (local i32 i32 i32 i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 46
    local.set 1
    local.get 0
    struct.get 64 0
    call 20
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
      struct.new 59
      struct.new 5
    else
      local.get 0
      struct.get 64 0
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
        struct.get 64 0
        local.get 1
        call 22
        struct.new 60
        struct.new 5
      else
        local.get 1
        i32.const 1
        i32.add
        local.set 3
        local.get 0
        struct.get 64 1
        local.get 3
        call 53
        local.set 4
        local.get 4
        local.get 2
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
          struct.new 59
          struct.new 5
        else
          local.get 0
          struct.get 64 0
          local.get 4
          call 22
          i32.const 34
          i32.eq
          if (result eqref) ;; label = @4
            local.get 4
            local.get 3
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            struct.get 64 3
            struct.get 57 3
            i32.gt_u
            if (result eqref) ;; label = @5
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 3
              local.get 4
              struct.new 59
              struct.new 5
            else
              local.get 0
              local.get 4
              i32.const 1
              i32.add
              call 47
              i32.const 0
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              local.get 0
              struct.get 64 1
              local.get 3
              local.get 5
              call 32
              call 34
              struct.new 4
            end
          else
            local.get 0
            struct.get 64 0
            local.get 4
            call 22
            i32.const 32
            i32.lt_u
            if (result eqref) ;; label = @5
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 9
              local.get 4
              struct.new 59
              struct.new 5
            else
              call 35
              local.set 6
              local.get 3
              local.set 7
              local.get 4
              local.set 8
              i32.const 1
              local.set 17
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 17
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 0
                      struct.get 64 1
                      local.get 8
                      call 53
                      local.set 9
                      local.get 9
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
                        struct.new 59
                        struct.new 5
                        local.set 18
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      local.get 6
                      local.get 7
                      local.get 9
                      call 67
                      i32.const 0
                      call 0
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 3
                        local.get 9
                        struct.new 59
                        struct.new 5
                        local.set 18
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      struct.get 64 0
                      local.get 9
                      call 22
                      local.set 10
                      local.get 10
                      i32.const 34
                      i32.eq
                      if ;; label = @10
                        local.get 0
                        local.get 9
                        i32.const 1
                        i32.add
                        call 47
                        i32.const 0
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        local.get 6
                        call 41
                        struct.new 4
                        local.set 18
                        br 4 (;@6;)
                      else
                        local.get 10
                        i32.const 32
                        i32.lt_u
                        if ;; label = @11
                          i32.const 1
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 9
                          local.get 9
                          struct.new 59
                          struct.new 5
                          local.set 18
                          br 5 (;@6;)
                        else
                          local.get 10
                          i32.const 92
                          i32.ne
                          if ;; label = @12
                            i32.const 1
                            i32.const 0
                            i64.const 0
                            f32.const 0x0p+0 (;=0;)
                            f64.const 0x0p+0 (;=0;)
                            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                            i32.const 6
                            local.get 9
                            local.get 10
                            struct.new 60
                            struct.new 5
                            local.set 18
                            br 6 (;@6;)
                          else
                            local.get 9
                            i32.const 1
                            i32.add
                            local.get 2
                            i32.ge_u
                            if ;; label = @13
                              i32.const 1
                              i32.const 0
                              i64.const 0
                              f32.const 0x0p+0 (;=0;)
                              f64.const 0x0p+0 (;=0;)
                              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                              i32.const 5
                              local.get 2
                              struct.new 59
                              struct.new 5
                              local.set 18
                              br 7 (;@6;)
                            else
                              local.get 0
                              struct.get 64 0
                              local.get 9
                              i32.const 1
                              i32.add
                              call 22
                              local.set 11
                              local.get 11
                              i32.const 34
                              i32.eq
                              if (result i32) ;; label = @14
                                i32.const 1
                              else
                                local.get 11
                                i32.const 92
                                i32.eq
                              end
                              if (result i32) ;; label = @14
                                i32.const 1
                              else
                                local.get 11
                                i32.const 47
                                i32.eq
                              end
                              if ;; label = @14
                                local.get 6
                                local.get 11
                                call 39
                                local.get 9
                                i32.const 2
                                i32.add
                                local.set 8
                                local.get 8
                                local.set 7
                              else
                                local.get 11
                                i32.const 98
                                i32.eq
                                if ;; label = @15
                                  local.get 6
                                  i32.const 8
                                  call 39
                                  local.get 9
                                  i32.const 2
                                  i32.add
                                  local.set 8
                                  local.get 8
                                  local.set 7
                                else
                                  local.get 11
                                  i32.const 102
                                  i32.eq
                                  if ;; label = @16
                                    local.get 6
                                    i32.const 12
                                    call 39
                                    local.get 9
                                    i32.const 2
                                    i32.add
                                    local.set 8
                                    local.get 8
                                    local.set 7
                                  else
                                    local.get 11
                                    i32.const 110
                                    i32.eq
                                    if ;; label = @17
                                      local.get 6
                                      i32.const 10
                                      call 39
                                      local.get 9
                                      i32.const 2
                                      i32.add
                                      local.set 8
                                      local.get 8
                                      local.set 7
                                    else
                                      local.get 11
                                      i32.const 114
                                      i32.eq
                                      if ;; label = @18
                                        local.get 6
                                        i32.const 13
                                        call 39
                                        local.get 9
                                        i32.const 2
                                        i32.add
                                        local.set 8
                                        local.get 8
                                        local.set 7
                                      else
                                        local.get 11
                                        i32.const 116
                                        i32.eq
                                        if ;; label = @19
                                          local.get 6
                                          i32.const 9
                                          call 39
                                          local.get 9
                                          i32.const 2
                                          i32.add
                                          local.set 8
                                          local.get 8
                                          local.set 7
                                        else
                                          local.get 11
                                          i32.const 117
                                          i32.eq
                                          if ;; label = @20
                                            local.get 0
                                            struct.get 64 0
                                            local.get 9
                                            i32.const 2
                                            i32.add
                                            call 66
                                            local.set 16
                                            block ;; label = @21
                                              block ;; label = @22
                                                block ;; label = @23
                                                  block ;; label = @24
                                                    local.get 16
                                                    ref.cast (ref 1)
                                                    struct.get 1 0
                                                    br_table 0 (;@24;) 1 (;@23;) 2 (;@22;)
                                                  end
                                                  i32.const 1
                                                  i32.const 0
                                                  i64.const 0
                                                  f32.const 0x0p+0 (;=0;)
                                                  f64.const 0x0p+0 (;=0;)
                                                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                                  i32.const 10
                                                  local.get 9
                                                  struct.new 59
                                                  struct.new 5
                                                  local.set 18
                                                  br 17 (;@6;)
                                                  br 2 (;@21;)
                                                end
                                                local.get 16
                                                ref.cast (ref 2)
                                                struct.get 2 1
                                                local.set 12
                                                local.get 12
                                                i32.const 55296
                                                i32.ge_u
                                                if (result i32) ;; label = @23
                                                  local.get 12
                                                  i32.const 56319
                                                  i32.le_u
                                                else
                                                  i32.const 0
                                                end
                                                if ;; label = @23
                                                  local.get 9
                                                  i32.const 6
                                                  i32.add
                                                  local.set 13
                                                  local.get 13
                                                  i32.const 5
                                                  i32.add
                                                  local.get 2
                                                  i32.ge_u
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 64 0
                                                    local.get 13
                                                    call 22
                                                    i32.const 92
                                                    i32.ne
                                                  end
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 64 0
                                                    local.get 13
                                                    i32.const 1
                                                    i32.add
                                                    call 22
                                                    i32.const 117
                                                    i32.ne
                                                  end
                                                  if ;; label = @24
                                                    i32.const 1
                                                    i32.const 0
                                                    i64.const 0
                                                    f32.const 0x0p+0 (;=0;)
                                                    f64.const 0x0p+0 (;=0;)
                                                    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                                    i32.const 10
                                                    local.get 9
                                                    struct.new 59
                                                    struct.new 5
                                                    local.set 18
                                                    br 18 (;@6;)
                                                  else
                                                  end
                                                  local.get 0
                                                  struct.get 64 0
                                                  local.get 13
                                                  i32.const 2
                                                  i32.add
                                                  call 66
                                                  local.set 15
                                                  block ;; label = @24
                                                    local.get 15
                                                    ref.cast (ref 1)
                                                    struct.get 1 0
                                                    i32.const 1
                                                    i32.eq
                                                    if ;; label = @25
                                                      local.get 15
                                                      ref.cast (ref 2)
                                                      struct.get 2 1
                                                      local.set 14
                                                      local.get 14
                                                      i32.const 56320
                                                      i32.ge_u
                                                      if (result i32) ;; label = @26
                                                        local.get 14
                                                        i32.const 57343
                                                        i32.le_u
                                                      else
                                                        i32.const 0
                                                      end
                                                      if ;; label = @26
                                                        local.get 6
                                                        i32.const 65536
                                                        local.get 12
                                                        i32.const 55296
                                                        i32.sub
                                                        i32.const 10
                                                        i32.shl
                                                        i32.add
                                                        local.get 14
                                                        i32.const 56320
                                                        i32.sub
                                                        i32.add
                                                        call 40
                                                        local.get 13
                                                        i32.const 6
                                                        i32.add
                                                        local.set 8
                                                        local.get 8
                                                        local.set 7
                                                        br 2 (;@24;)
                                                      end
                                                    end
                                                    i32.const 1
                                                    if ;; label = @25
                                                      i32.const 1
                                                      i32.const 0
                                                      i64.const 0
                                                      f32.const 0x0p+0 (;=0;)
                                                      f64.const 0x0p+0 (;=0;)
                                                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                                      i32.const 10
                                                      local.get 9
                                                      struct.new 59
                                                      struct.new 5
                                                      local.set 18
                                                      br 19 (;@6;)
                                                      br 1 (;@24;)
                                                    end
                                                    unreachable
                                                  end
                                                else
                                                  local.get 12
                                                  i32.const 56320
                                                  i32.ge_u
                                                  if (result i32) ;; label = @24
                                                    local.get 12
                                                    i32.const 57343
                                                    i32.le_u
                                                  else
                                                    i32.const 0
                                                  end
                                                  if ;; label = @24
                                                    i32.const 1
                                                    i32.const 0
                                                    i64.const 0
                                                    f32.const 0x0p+0 (;=0;)
                                                    f64.const 0x0p+0 (;=0;)
                                                    v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                                    i32.const 10
                                                    local.get 9
                                                    struct.new 59
                                                    struct.new 5
                                                    local.set 18
                                                    br 18 (;@6;)
                                                  else
                                                    local.get 6
                                                    local.get 12
                                                    call 40
                                                    local.get 9
                                                    i32.const 6
                                                    i32.add
                                                    local.set 8
                                                    local.get 8
                                                    local.set 7
                                                  end
                                                end
                                                br 1 (;@21;)
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
                                            local.get 9
                                            struct.new 59
                                            struct.new 5
                                            local.set 18
                                            br 14 (;@6;)
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                              local.get 6
                              call 36
                              local.get 0
                              struct.get 64 3
                              struct.get 57 3
                              i32.gt_u
                              if ;; label = @14
                                i32.const 1
                                i32.const 0
                                i64.const 0
                                f32.const 0x0p+0 (;=0;)
                                f64.const 0x0p+0 (;=0;)
                                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                i32.const 3
                                local.get 9
                                struct.new 59
                                struct.new 5
                                local.set 18
                                br 8 (;@6;)
                              else
                                i32.const 1
                                local.set 17
                                br 7 (;@7;)
                              end
                            end
                          end
                        end
                      end
                      br 1 (;@8;)
                    end
                    unreachable
                  end
                  unreachable
                end
                unreachable
              end
              local.get 18
            end
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;69;) (type 91) (param (ref 64) eqref (ref 51)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 46
    local.set 3
    local.get 0
    struct.get 64 0
    call 20
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 20
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
      struct.new 59
      struct.new 5
    else
      local.get 0
      struct.get 64 0
      local.get 3
      local.get 1
      call 20
      call 23
      local.get 1
      call 21
      i32.const 0
      call 0
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 7
        local.get 3
        struct.new 59
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 20
        i32.add
        call 47
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
  (func (;70;) (type 92) (param (ref 64)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 46
    local.set 1
    local.get 0
    struct.get 64 0
    local.get 1
    call 56
    local.set 2
    local.get 0
    struct.get 64 0
    local.get 1
    local.get 2
    call 64
    i32.const 0
    call 0
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 8
      local.get 1
      struct.new 59
      struct.new 5
    else
      local.get 0
      local.get 2
      call 47
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      local.get 0
      struct.get 64 1
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 32
      call 34
      struct.new 53
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;71;) (type 93) (param (ref 64) i32) (result (ref 3))
    (local eqref (ref 58) (ref 51) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 127
    i32.const 0
    i32.const 0
    struct.new 7
    local.set 2
    local.get 0
    local.get 0
    call 46
    i32.const 1
    i32.add
    call 47
    local.get 0
    call 57
    local.get 0
    call 46
    local.get 0
    struct.get 64 0
    call 20
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 64 0
      local.get 0
      call 46
      call 22
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 46
      i32.const 1
      i32.add
      call 47
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 4
      local.get 2
      ref.cast (ref 7)
      struct.new 54
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
              call 80
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
                    ref.cast (ref 51)
                    local.set 4
                    local.get 2
                    local.get 4
                    local.set 10
                    local.set 7
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 1
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 2
                    i32.eq
                    if ;; label = @9
                      local.get 7
                      ref.cast (ref 7)
                      struct.get 7 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 7
                        ref.cast (ref 7)
                        struct.get 7 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 8
                      local.get 8
                      local.get 7
                      ref.cast (ref 7)
                      struct.get 7 2
                      i32.le_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 8
                      array.new_default 127
                      local.set 9
                      i32.const 0
                      local.set 8
                      block ;; label = @10
                        loop ;; label = @11
                          local.get 8
                          local.get 7
                          ref.cast (ref 7)
                          struct.get 7 1
                          i32.ge_u
                          br_if 1 (;@10;)
                          local.get 9
                          ref.cast (ref 127)
                          local.get 8
                          local.get 7
                          ref.cast (ref 7)
                          struct.get 7 0
                          ref.cast (ref 127)
                          local.get 8
                          array.get 127
                          array.set 127
                          local.get 8
                          i32.const 1
                          i32.add
                          local.set 8
                          br 0 (;@11;)
                        end
                      end
                      local.get 7
                      ref.cast (ref 7)
                      local.get 9
                      struct.set 7 0
                      local.get 7
                      ref.cast (ref 7)
                      local.get 9
                      ref.cast (ref 127)
                      array.len
                      struct.set 7 2
                    end
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 0
                    ref.cast (ref 127)
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 1
                    local.get 10
                    array.set 127
                    local.get 7
                    ref.cast (ref 7)
                    local.get 7
                    ref.cast (ref 7)
                    struct.get 7 1
                    i32.const 1
                    i32.add
                    struct.set 7 1
                    br 2 (;@6;)
                  end
                  local.get 11
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 58)
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
              call 57
              local.get 0
              call 46
              local.set 5
              local.get 5
              local.get 0
              struct.get 64 0
              call 20
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
                struct.new 59
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 64 0
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
                call 47
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 4
                local.get 2
                ref.cast (ref 7)
                struct.new 54
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
                  call 47
                  local.get 0
                  call 57
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
                  struct.new 60
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
  (func (;72;) (type 94) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 30
  )
  (func (;73;) (type 95) (param eqref) (result i64)
    local.get 0
    call 27
  )
  (func (;74;) (type 96) (param (ref 7) i32 eqref) (result i32)
    (local i32 eqref i32 eqref i32 i32)
    i32.const 0
    local.set 7
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 7
            local.set 3
            local.get 3
            local.get 1
            i32.lt_u
            if ;; label = @5
              local.get 0
              local.get 3
              local.set 5
              local.set 4
              local.get 5
              local.get 4
              ref.cast (ref 7)
              struct.get 7 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 7)
              struct.get 7 0
              ref.cast (ref 127)
              local.get 5
              array.get 127
              ref.cast (ref 56)
              struct.get 56 0
              local.get 2
              call 72
              if ;; label = @6
                i32.const 1
                local.set 8
                br 5 (;@1;)
              else
                local.get 3
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
  )
  (func (;75;) (type 97) (param (ref 7) eqref) (result i32)
    local.get 0
    ref.cast (ref 7)
    local.get 0
    ref.cast (ref 7)
    struct.get 7 1
    local.get 1
    call 74
  )
  (func (;76;) (type 98) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;77;) (type 99) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 76
  )
  (func (;78;) (type 100) (param i64 i64 i64 i64 i32 i64) (result i32)
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
  (func (;79;) (type 101) (param (ref 64) i32) (result (ref 3))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 58) eqref i32 i32 i64 i32 (ref 56) i64 i32 i32 i32 i32 (ref 51) (ref 58) (ref 51) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 127
    i32.const 0
    i32.const 0
    struct.new 7
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
    call 46
    i32.const 1
    i32.add
    call 47
    local.get 0
    call 57
    local.get 0
    call 46
    local.get 0
    struct.get 64 0
    call 20
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 64 0
      local.get 0
      call 46
      call 22
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 46
      i32.const 1
      i32.add
      call 47
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 7)
      struct.new 55
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
              call 46
              local.set 7
              local.get 7
              local.get 0
              struct.get 64 0
              call 20
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
                struct.new 59
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 64 0
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
                struct.get 64 0
                local.get 7
                call 22
                struct.new 60
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 68
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
                  ref.cast (ref 58)
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
              ref.cast (ref 7)
              struct.get 7 1
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
                          ref.cast (ref 7)
                          struct.get 7 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 28
                          ref.cast (ref 7)
                          struct.get 7 0
                          ref.cast (ref 127)
                          local.get 29
                          array.get 127
                          ref.cast (ref 56)
                          ref.cast (ref 56)
                          local.set 15
                          local.get 15
                          ref.cast (ref 56)
                          struct.get 56 0
                          call 73
                          local.set 16
                          local.get 16
                          call 77
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
                        call 44
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
                call 77
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
                call 78
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 7)
                  local.get 10
                  call 75
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 7)
                local.get 10
                call 75
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
                struct.new 61
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
              call 57
              local.get 0
              call 46
              local.set 20
              local.get 20
              local.get 0
              struct.get 64 0
              call 20
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
                struct.new 59
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 64 0
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
                struct.get 64 0
                local.get 20
                call 22
                struct.new 60
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 20
              i32.const 1
              i32.add
              call 47
              local.get 0
              call 57
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 80
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
                    ref.cast (ref 51)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 58)
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
              ref.cast (ref 51)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 51)
              struct.new 56
              local.set 34
              local.set 28
              local.get 28
              ref.cast (ref 7)
              struct.get 7 1
              local.get 28
              ref.cast (ref 7)
              struct.get 7 2
              i32.eq
              if ;; label = @6
                local.get 28
                ref.cast (ref 7)
                struct.get 7 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 28
                  ref.cast (ref 7)
                  struct.get 7 2
                  i32.const 2
                  i32.mul
                end
                local.set 29
                local.get 29
                local.get 28
                ref.cast (ref 7)
                struct.get 7 2
                i32.le_u
                if ;; label = @7
                  unreachable
                end
                local.get 29
                array.new_default 127
                local.set 30
                i32.const 0
                local.set 29
                block ;; label = @7
                  loop ;; label = @8
                    local.get 29
                    local.get 28
                    ref.cast (ref 7)
                    struct.get 7 1
                    i32.ge_u
                    br_if 1 (;@7;)
                    local.get 30
                    ref.cast (ref 127)
                    local.get 29
                    local.get 28
                    ref.cast (ref 7)
                    struct.get 7 0
                    ref.cast (ref 127)
                    local.get 29
                    array.get 127
                    array.set 127
                    local.get 29
                    i32.const 1
                    i32.add
                    local.set 29
                    br 0 (;@8;)
                  end
                end
                local.get 28
                ref.cast (ref 7)
                local.get 30
                struct.set 7 0
                local.get 28
                ref.cast (ref 7)
                local.get 30
                ref.cast (ref 127)
                array.len
                struct.set 7 2
              end
              local.get 28
              ref.cast (ref 7)
              struct.get 7 0
              ref.cast (ref 127)
              local.get 28
              ref.cast (ref 7)
              struct.get 7 1
              local.get 34
              array.set 127
              local.get 28
              ref.cast (ref 7)
              local.get 28
              ref.cast (ref 7)
              struct.get 7 1
              i32.const 1
              i32.add
              struct.set 7 1
              local.get 0
              call 57
              local.get 0
              call 46
              local.set 24
              local.get 24
              local.get 0
              struct.get 64 0
              call 20
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
                struct.new 59
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 64 0
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
                call 47
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 7)
                struct.new 55
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
                  call 47
                  local.get 0
                  call 57
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
                  struct.new 60
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
  (func (;80;) (type 102) (param (ref 64) i32) (result (ref 3))
    (local i32 i32 eqref (ref 58) eqref eqref)
    local.get 1
    local.get 0
    struct.get 64 3
    struct.get 57 1
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
      struct.new 59
      struct.new 5
    else
      local.get 0
      call 48
      local.get 0
      struct.get 64 3
      struct.get 57 2
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
        call 46
        struct.new 59
        struct.new 5
      else
        local.get 0
        local.get 0
        call 48
        i32.const 1
        i32.add
        call 49
        local.get 0
        call 57
        local.get 0
        call 46
        local.set 2
        local.get 2
        local.get 0
        struct.get 64 0
        call 20
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
          struct.new 59
          struct.new 5
        else
          local.get 0
          struct.get 64 0
          local.get 2
          call 22
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 116 1
            i32.const 0
            i32.const 4
            struct.new 118
            i32.const 0
            struct.new 51
            call 69
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 116 1
              i32.const 0
              i32.const 4
              struct.new 118
              i32.const 1
              i32.const 1
              struct.new 52
              call 69
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 116 1
                i32.const 0
                i32.const 5
                struct.new 118
                i32.const 1
                i32.const 0
                struct.new 52
                call 69
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 68
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
                        struct.new 53
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 58)
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
                    call 71
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 79
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 58
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 70
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
                        struct.new 60
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
  (func (;81;) (type 103) (param eqref (ref 57)) (result (ref 3))
    (local i32 (ref 64) (ref 58) (ref 51) eqref i32 eqref eqref)
    local.get 0
    call 28
    local.set 2
    local.get 2
    local.get 1
    struct.get 57 0
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
      struct.new 59
      struct.new 5
    else
      local.get 0
      call 29
      local.get 0
      i32.const 2
      local.set 7
      i32.const 0
      local.get 7
      array.new 122
      struct.new 6
      ref.cast (ref 6)
      local.get 1
      ref.cast (ref 57)
      struct.new 64
      local.set 3
      local.get 3
      i32.const 0
      call 80
      local.set 8
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 8
              ref.cast (ref 3)
              struct.get 3 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            local.get 8
            ref.cast (ref 4)
            struct.get 4 6
            ref.cast (ref 51)
            local.set 5
            local.get 3
            call 57
            local.get 3
            call 46
            local.get 2
            i32.eq
            if (result eqref) ;; label = @5
              i32.const 0
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              local.get 5
              struct.new 4
            else
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 12
              local.get 3
              call 46
              struct.new 59
              struct.new 5
            end
            local.set 9
            br 2 (;@2;)
          end
          local.get 8
          ref.cast (ref 5)
          struct.get 5 6
          ref.cast (ref 58)
          local.set 4
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 4
          struct.new 5
          local.set 9
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 9
    end
    ref.cast (ref 3)
  )
  (func (;82;) (type 104) (param eqref) (result (ref 3))
    local.get 0
    call 45
    call 81
    ref.cast (ref 3)
  )
  (func (;83;) (type 105) (param (ref 65) i32)
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 65 3
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 122)
      i32.const 0
      local.get 1
      array.set 122
    else
    end
  )
  (func (;84;) (type 106) (param (ref 65) i32 eqref)
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 65 4
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 127)
      i32.const 0
      local.get 2
      array.set 127
      local.get 0
      struct.get 65 3
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 122)
      i32.const 0
      local.get 1
      array.set 122
    else
    end
  )
  (func (;85;) (type 107) (param (ref 65) i32)
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 65 0
      call 36
      local.get 0
      struct.get 65 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 83
      else
        local.get 0
        struct.get 65 0
        local.get 1
        call 39
      end
    end
  )
  (func (;86;) (type 108) (param (ref 65) eqref)
    (local i32 i32)
    local.get 0
    struct.get 65 0
    call 36
    local.set 2
    local.get 1
    call 28
    local.set 3
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 65 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 65 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 83
      else
        local.get 0
        struct.get 65 0
        local.get 1
        call 37
      end
    end
  )
  (func (;87;) (type 109) (param (ref 65) eqref)
    (local i32 i32)
    local.get 0
    struct.get 65 0
    call 36
    local.set 2
    local.get 1
    call 33
    local.set 3
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 65 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 65 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 83
      else
        local.get 0
        struct.get 65 0
        local.get 1
        call 38
      end
    end
  )
  (func (;88;) (type 110) (param i32) (result i32)
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
  (func (;89;) (type 111) (param (ref 65) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 34
    call 85
    local.get 1
    call 29
    local.set 2
    local.get 2
    call 20
    local.set 3
    i32.const 0
    local.set 4
    local.get 4
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 5
            local.get 5
            local.get 3
            i32.lt_u
            if (result i32) ;; label = @5
              local.get 0
              struct.get 65 3
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 122)
              i32.const 0
              array.get 122
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 54
              local.set 6
              local.get 6
              local.get 5
              i32.gt_u
              if ;; label = @6
                local.get 0
                local.get 1
                local.get 5
                local.get 6
                local.get 5
                i32.sub
                call 32
                call 87
              else
              end
              local.get 6
              local.get 3
              i32.ge_u
              if ;; label = @6
                local.get 3
                local.set 10
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
                  call 85
                  local.get 0
                  local.get 7
                  call 85
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
                    call 85
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
                    call 85
                  else
                    local.get 0
                    i32.const 92
                    call 85
                    local.get 0
                    i32.const 117
                    call 85
                    local.get 0
                    i32.const 48
                    call 85
                    local.get 0
                    i32.const 48
                    call 85
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 88
                    call 85
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 88
                    call 85
                  end
                end
                local.get 6
                i32.const 1
                i32.add
                local.set 9
                br 4 (;@2;)
              end
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 8
            local.get 8
            local.set 10
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 10
    drop
    local.get 0
    i32.const 34
    call 85
  )
  (func (;90;) (type 112) (param (ref 65) (ref 51) i32)
    (local i32 eqref eqref eqref eqref i32 i32 eqref i64 i64 i64 i64 i32 i32 i32 (ref 56) i64 i32 i32 eqref i32 eqref i32 i32 eqref)
    local.get 0
    struct.get 65 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
    i32.const 0
    i32.ne
    if ;; label = @1
      call 44
    else
      local.get 2
      local.get 0
      struct.get 65 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 83
      else
        local.get 1
        local.set 27
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 27
                        ref.cast (ref 51)
                        struct.get 51 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;) 4 (;@6;) 5 (;@5;) 6 (;@4;)
                      end
                      local.get 0
                      v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                      array.new_fixed 116 1
                      i32.const 0
                      i32.const 4
                      struct.new 117
                      call 86
                      br 6 (;@3;)
                    end
                    local.get 27
                    ref.cast (ref 52)
                    struct.get 52 1
                    local.set 3
                    local.get 3
                    if ;; label = @9
                      local.get 0
                      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                      array.new_fixed 116 1
                      i32.const 0
                      i32.const 4
                      struct.new 117
                      call 86
                    else
                      local.get 0
                      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                      array.new_fixed 116 1
                      i32.const 0
                      i32.const 5
                      struct.new 117
                      call 86
                    end
                    br 5 (;@3;)
                  end
                  local.get 27
                  ref.cast (ref 53)
                  struct.get 53 1
                  local.set 4
                  local.get 4
                  call 29
                  local.set 5
                  local.get 5
                  i32.const 0
                  local.get 5
                  call 20
                  call 64
                  if ;; label = @8
                    local.get 0
                    local.get 4
                    call 86
                  else
                    local.get 0
                    i32.const 2
                    local.get 4
                    call 84
                  end
                  br 4 (;@3;)
                end
                local.get 27
                ref.cast (ref 53)
                struct.get 53 1
                local.set 6
                local.get 0
                local.get 6
                call 89
                br 3 (;@3;)
              end
              local.get 27
              ref.cast (ref 54)
              struct.get 54 1
              local.set 7
              local.get 0
              i32.const 91
              call 85
              local.get 7
              ref.cast (ref 7)
              struct.get 7 1
              local.set 8
              i32.const 0
              local.set 25
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 25
                      local.set 9
                      local.get 9
                      local.get 8
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 0
                        struct.get 65 3
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 122)
                        i32.const 0
                        array.get 122
                        i32.const 0
                        i32.eq
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 9
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 85
                        else
                        end
                        local.get 0
                        local.get 7
                        local.get 9
                        local.set 23
                        local.set 22
                        local.get 23
                        local.get 22
                        ref.cast (ref 7)
                        struct.get 7 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 22
                        ref.cast (ref 7)
                        struct.get 7 0
                        ref.cast (ref 127)
                        local.get 23
                        array.get 127
                        ref.cast (ref 51)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 90
                        local.get 9
                        i32.const 1
                        i32.add
                        local.set 25
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 44
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
              call 85
              br 2 (;@3;)
            end
            local.get 27
            ref.cast (ref 55)
            struct.get 55 1
            local.set 10
            local.get 0
            i32.const 123
            call 85
            i64.const 0
            local.set 11
            i64.const 0
            local.set 12
            i64.const 0
            local.set 13
            i64.const 0
            local.set 14
            local.get 10
            ref.cast (ref 7)
            struct.get 7 1
            local.set 15
            local.get 15
            i32.const 16
            i32.ge_u
            local.set 16
            i32.const 0
            local.set 26
            block ;; label = @5
              loop ;; label = @6
                block ;; label = @7
                  i32.const 1
                  if ;; label = @8
                    local.get 26
                    local.set 17
                    local.get 17
                    local.get 15
                    i32.lt_u
                    if (result i32) ;; label = @9
                      local.get 0
                      struct.get 65 3
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 122)
                      i32.const 0
                      array.get 122
                      i32.const 0
                      i32.eq
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 10
                      local.get 17
                      local.set 23
                      local.set 22
                      local.get 23
                      local.get 22
                      ref.cast (ref 7)
                      struct.get 7 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 22
                      ref.cast (ref 7)
                      struct.get 7 0
                      ref.cast (ref 127)
                      local.get 23
                      array.get 127
                      ref.cast (ref 56)
                      ref.cast (ref 56)
                      local.set 18
                      local.get 16
                      if (result i64) ;; label = @10
                        local.get 18
                        ref.cast (ref 56)
                        struct.get 56 0
                        call 73
                      else
                        i64.const 0
                      end
                      local.set 19
                      local.get 16
                      if (result i32) ;; label = @10
                        local.get 19
                        call 77
                      else
                        i32.const 0
                      end
                      local.set 20
                      local.get 16
                      if (result i32) ;; label = @10
                        local.get 11
                        local.get 12
                        local.get 13
                        local.get 14
                        local.get 20
                        local.get 19
                        call 78
                        if (result i32) ;; label = @11
                          local.get 10
                          ref.cast (ref 7)
                          local.get 17
                          local.get 18
                          ref.cast (ref 56)
                          struct.get 56 0
                          call 74
                        else
                          i32.const 0
                        end
                      else
                        local.get 10
                        ref.cast (ref 7)
                        local.get 17
                        local.get 18
                        ref.cast (ref 56)
                        struct.get 56 0
                        call 74
                      end
                      local.set 21
                      local.get 21
                      if ;; label = @10
                        local.get 0
                        i32.const 4
                        local.get 18
                        ref.cast (ref 56)
                        struct.get 56 0
                        call 84
                      else
                        local.get 20
                        i32.const 0
                        i32.eq
                        if (result i32) ;; label = @11
                          local.get 16
                        else
                          i32.const 0
                        end
                        if ;; label = @11
                          local.get 11
                          local.get 19
                          call 25
                          local.set 11
                        else
                          local.get 20
                          i32.const 1
                          i32.eq
                          if (result i32) ;; label = @12
                            local.get 16
                          else
                            i32.const 0
                          end
                          if ;; label = @12
                            local.get 12
                            local.get 19
                            call 25
                            local.set 12
                          else
                            local.get 20
                            i32.const 2
                            i32.eq
                            if (result i32) ;; label = @13
                              local.get 16
                            else
                              i32.const 0
                            end
                            if ;; label = @13
                              local.get 13
                              local.get 19
                              call 25
                              local.set 13
                            else
                              local.get 16
                              if ;; label = @14
                                local.get 14
                                local.get 19
                                call 25
                                local.set 14
                              else
                              end
                            end
                          end
                        end
                        local.get 17
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 85
                        else
                        end
                        local.get 0
                        local.get 18
                        ref.cast (ref 56)
                        struct.get 56 0
                        call 89
                        local.get 0
                        i32.const 58
                        call 85
                        local.get 0
                        local.get 18
                        ref.cast (ref 56)
                        struct.get 56 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 90
                      end
                      local.get 17
                      i32.const 1
                      i32.add
                      local.set 26
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 44
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
            call 85
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;91;) (type 113) (param (ref 51) i32 i32) (result (ref 3))
    (local eqref (ref 65) eqref i32)
    i32.const 1
    local.set 6
    i32.const 0
    local.get 6
    array.new 122
    struct.new 6
    local.set 3
    call 35
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 6)
    i32.const 1
    local.set 6
    array.new_fixed 116 0
    i32.const 0
    i32.const 0
    struct.new 117
    local.get 6
    array.new 127
    struct.new 6
    ref.cast (ref 6)
    struct.new 65
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 90
    local.get 3
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 122)
    i32.const 0
    array.get 122
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
      struct.new 62
      struct.new 5
    else
      local.get 3
      ref.cast (ref 6)
      struct.get 6 0
      ref.cast (ref 122)
      i32.const 0
      array.get 122
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
        ref.cast (ref 65)
        struct.get 65 4
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 127)
        i32.const 0
        array.get 127
        struct.new 63
        struct.new 5
      else
        local.get 3
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 122)
        i32.const 0
        array.get 122
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
          struct.new 62
          struct.new 5
        else
          local.get 3
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 122)
          i32.const 0
          array.get 122
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
            ref.cast (ref 65)
            struct.get 65 4
            ref.cast (ref 6)
            struct.get 6 0
            ref.cast (ref 127)
            i32.const 0
            array.get 127
            struct.new 63
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 65)
            struct.get 65 0
            call 41
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;92;) (type 114) (param (ref 51)) (result (ref 3))
    local.get 0
    i32.const 128
    i32.const 16777216
    call 91
    ref.cast (ref 3)
  )
  (func (;93;) (type 115) (result i32)
    (local eqref eqref eqref i32 eqref i32)
    v128.const i32x4 0x61227b20 0x745b3a22 0x2c657572 0x6c6c756e
    v128.const i32x4 0x2e312d2c 0x32653532 0x62222c5d 0x30223a22
    v128.const i32x4 0x34333231 0x38373635 0x63626139 0x22666564
    v128.const i32x4 0x0000207d 0x00000000 0x00000000 0x00000000
    array.new_fixed 116 4
    i32.const 0
    i32.const 50
    struct.new 117
    call 82
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 4
          ref.cast (ref 4)
          struct.get 4 6
          local.set 0
          local.get 0
          ref.cast (ref 51)
          call 92
          local.set 2
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 2
                  ref.cast (ref 3)
                  struct.get 3 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                local.get 2
                ref.cast (ref 4)
                struct.get 4 6
                local.set 1
                local.get 1
                v128.const i32x4 0x2261227b 0x72745b3a 0x6e2c6575 0x2c6c6c75
                v128.const i32x4 0x322e312d 0x5d326535 0x2262222c 0x3130223a
                v128.const i32x4 0x35343332 0x39383736 0x64636261 0x7d226665
                array.new_fixed 116 3
                i32.const 0
                i32.const 48
                struct.new 117
                call 30
                local.set 3
                br 2 (;@4;)
              end
              i32.const 0
              local.set 3
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 3
          local.set 5
          br 2 (;@1;)
        end
        i32.const 0
        local.set 5
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 5
  )
)
