(module
  (type (;0;) (func (param i32 i32) (result i32)))
  (type (;1;) (sub (struct (field i32))))
  (type (;2;) (sub final 1 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;3;) (sub (struct (field i32))))
  (type (;4;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;5;) (sub final 3 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;6;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;7;) (struct (field eqref)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref) (result eqref)))
  (type (;10;) (func (param eqref eqref) (result i32)))
  (type (;11;) (func (param eqref) (result i64)))
  (type (;12;) (func (param eqref i32) (result i32)))
  (type (;13;) (func (param eqref i32 i32) (result eqref)))
  (type (;14;) (func (param eqref) (result i32)))
  (type (;15;) (func (param eqref) (result eqref)))
  (type (;16;) (func (result eqref)))
  (type (;17;) (func (param i32) (result eqref)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref eqref)))
  (type (;20;) (func (param eqref eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref i32)))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (param eqref) (result i32)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param eqref i32 i32) (result eqref)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref i32) (result i32)))
  (type (;31;) (func (param eqref i32 i32) (result eqref)))
  (type (;32;) (func (param i64) (result i64)))
  (type (;33;) (func (param i64 i64) (result i64)))
  (type (;34;) (func (param i64 i64) (result i32)))
  (type (;35;) (func (param eqref) (result i64)))
  (type (;36;) (func (param eqref) (result i32)))
  (type (;37;) (func (param eqref) (result eqref)))
  (type (;38;) (func (param eqref eqref) (result i32)))
  (type (;39;) (func (param eqref i32) (result i32)))
  (type (;40;) (func (param eqref i32 i32) (result eqref)))
  (type (;41;) (func (param eqref) (result i32)))
  (type (;42;) (func (param eqref) (result eqref)))
  (type (;43;) (func (param eqref) (result eqref)))
  (type (;44;) (func (result eqref)))
  (type (;45;) (func (param eqref) (result i32)))
  (type (;46;) (func (param eqref eqref)))
  (type (;47;) (func (param eqref eqref)))
  (type (;48;) (func (param eqref i32)))
  (type (;49;) (func (param eqref i32)))
  (type (;50;) (func (param eqref) (result eqref)))
  (type (;51;) (func (param eqref i32) (result v128)))
  (type (;52;) (func (param eqref i32) (result v128)))
  (type (;53;) (sub (struct (field i32))))
  (type (;54;) (sub final 53 (struct (field i32) (field i32))))
  (type (;55;) (sub final 53 (struct (field i32) (field eqref))))
  (type (;56;) (struct (field eqref)))
  (type (;57;) (sub final 53 (struct (field i32) (field (ref 56)))))
  (type (;58;) (struct (field eqref) (field i32)))
  (type (;59;) (sub final 53 (struct (field i32) (field (ref 58)))))
  (type (;60;) (sub final 53 (struct (field i32) (field (ref 6)))))
  (type (;61;) (sub final 53 (struct (field i32) (field (ref 6)))))
  (type (;62;) (struct (field eqref) (field (ref 53))))
  (type (;63;) (struct (field eqref) (field i32)))
  (type (;64;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;65;) (sub (struct (field i32))))
  (type (;66;) (sub final 65 (struct (field i32) (field i32))))
  (type (;67;) (sub final 65 (struct (field i32) (field i32) (field i8))))
  (type (;68;) (sub final 65 (struct (field i32) (field i32) (field eqref))))
  (type (;69;) (sub (struct (field i32))))
  (type (;70;) (sub final 69 (struct (field i32) (field eqref))))
  (type (;71;) (struct (field eqref) (field eqref) (field (ref 7)) (field (ref 64)) (field i32) (field i32) (field i32)))
  (type (;72;) (struct (field eqref) (field i32) (field i32) (field (ref 7)) (field (ref 7))))
  (type (;73;) (func))
  (type (;74;) (func (result (ref 64))))
  (type (;75;) (func (param (ref 71)) (result i32)))
  (type (;76;) (func (param (ref 71) i32)))
  (type (;77;) (func (param (ref 71)) (result i32)))
  (type (;78;) (func (param (ref 71) i32)))
  (type (;79;) (func (param i32) (result i32)))
  (type (;80;) (func (param i32) (result i32)))
  (type (;81;) (func (param eqref i32) (result i32)))
  (type (;82;) (func (param eqref i32) (result i32)))
  (type (;83;) (func (param eqref i32) (result i32)))
  (type (;84;) (func (param i32) (result i32)))
  (type (;85;) (func (param eqref i32) (result i32)))
  (type (;86;) (func (param (ref 71))))
  (type (;87;) (func (param i32) (result i32)))
  (type (;88;) (func (param i32) (result i32)))
  (type (;89;) (func (param eqref i32 i32) (result i32)))
  (type (;90;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;91;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;92;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;93;) (func (param eqref i32 i32) (result i32)))
  (type (;94;) (func (param i32) (result i32)))
  (type (;95;) (func (param eqref i32) (result (ref 1))))
  (type (;96;) (func (param (ref 71) eqref i32 i32) (result i32)))
  (type (;97;) (func (param (ref 71)) (result (ref 3))))
  (type (;98;) (func (param (ref 71)) (result (ref 3))))
  (type (;99;) (func (param (ref 71) eqref (ref 53)) (result (ref 3))))
  (type (;100;) (func (param (ref 71)) (result (ref 3))))
  (type (;101;) (func (param (ref 71)) (result (ref 3))))
  (type (;102;) (func (param (ref 71) i32) (result (ref 3))))
  (type (;103;) (func (param eqref eqref) (result i32)))
  (type (;104;) (func (param eqref) (result i64)))
  (type (;105;) (func (param (ref 6) i32 eqref) (result i32)))
  (type (;106;) (func (param (ref 6) eqref) (result i32)))
  (type (;107;) (func (param i64) (result i32)))
  (type (;108;) (func (param i64) (result i32)))
  (type (;109;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;110;) (func (param (ref 71) i32) (result (ref 3))))
  (type (;111;) (func (param (ref 71) i32) (result (ref 3))))
  (type (;112;) (func (param eqref (ref 64) i32 i32 i32) (result (ref 3))))
  (type (;113;) (func (param eqref (ref 64)) (result (ref 3))))
  (type (;114;) (func (param eqref) (result (ref 3))))
  (type (;115;) (func (param (ref 72) i32)))
  (type (;116;) (func (param (ref 72) i32 eqref)))
  (type (;117;) (func (param (ref 72) i32)))
  (type (;118;) (func (param (ref 72) eqref)))
  (type (;119;) (func (param (ref 72) eqref)))
  (type (;120;) (func (param i32) (result i32)))
  (type (;121;) (func (param (ref 72) eqref)))
  (type (;122;) (func (param (ref 72) (ref 58))))
  (type (;123;) (func (param (ref 72) (ref 53) i32)))
  (type (;124;) (func (param (ref 53) i32 i32) (result (ref 3))))
  (type (;125;) (func (param (ref 53)) (result (ref 3))))
  (type (;126;) (func (param eqref (ref 53)) (result (ref 62))))
  (type (;127;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;128;) (func (param i32 eqref) (result i32)))
  (type (;129;) (func (result i32)))
  (type (;130;) (array (mut v128)))
  (type (;131;) (struct (field (ref 130)) (field i32) (field i32)))
  (type (;132;) (struct (field (ref 130)) (field i32) (field i32)))
  (type (;133;) (struct (field (ref 130)) (field i32) (field i32)))
  (type (;134;) (struct (field (mut (ref 130))) (field (mut i32)) (field (mut i32))))
  (type (;135;) (struct (field (mut (ref 130))) (field (mut i32)) (field (mut i32))))
  (type (;136;) (array (mut i32)))
  (type (;137;) (array (mut i64)))
  (type (;138;) (array (mut f32)))
  (type (;139;) (array (mut f64)))
  (type (;140;) (array (mut v128)))
  (type (;141;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 127)))
  (memory (;0;) 1)
  (export "main" (func 102))
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
  (func (;2;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 131)
    struct.get 131 2
  )
  (func (;3;) (type 9) (param eqref) (result eqref)
    (local (ref 131))
    local.get 0
    ref.cast (ref 131)
    local.tee 1
    struct.get 131 0
    local.get 1
    struct.get 131 1
    local.get 1
    struct.get 131 2
    struct.new 132
  )
  (func (;4;) (type 10) (param eqref eqref) (result i32)
    (local (ref 131) (ref 131) (ref 130) (ref 130) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 131)
    local.set 2
    local.get 1
    ref.cast (ref 131)
    local.set 3
    local.get 2
    struct.get 131 2
    local.tee 6
    local.get 3
    struct.get 131 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 131 0
    local.set 4
    local.get 3
    struct.get 131 0
    local.set 5
    local.get 2
    struct.get 131 1
    local.set 7
    local.get 3
    struct.get 131 1
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
          array.get 130
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 130
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
          array.get 130
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
          array.get 130
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 130
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
          array.get 130
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
      array.get 130
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
      array.get 130
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
  (func (;5;) (type 11) (param eqref) (result i64)
    (local (ref 131) (ref 130) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 131)
    local.set 1
    local.get 1
    struct.get 131 0
    local.set 2
    local.get 1
    struct.get 131 1
    local.set 3
    local.get 1
    struct.get 131 2
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
      array.get 130
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
  (func (;6;) (type 12) (param eqref i32) (result i32)
    (local (ref 131) (ref 130) i32)
    local.get 0
    ref.cast (ref 131)
    local.set 2
    local.get 1
    local.get 2
    struct.get 131 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 131 0
    local.set 3
    local.get 2
    struct.get 131 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 130
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;7;) (type 13) (param eqref i32 i32) (result eqref)
    (local (ref 131) (ref 130) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 131)
    local.set 3
    local.get 3
    struct.get 131 2
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
    struct.get 131 0
    local.set 4
    local.get 3
    struct.get 131 1
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
      array.get 130
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
      array.get 130
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
    struct.get 131 1
    local.get 1
    i32.add
    local.get 2
    struct.new 133
  )
  (func (;8;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 133)
    struct.get 133 2
  )
  (func (;9;) (type 15) (param eqref) (result eqref)
    (local (ref 133))
    local.get 0
    ref.cast (ref 133)
    local.tee 1
    struct.get 133 0
    local.get 1
    struct.get 133 1
    local.get 1
    struct.get 133 2
    struct.new 131
  )
  (func (;10;) (type 16) (result eqref)
    i32.const 4
    array.new_default 130
    i32.const 0
    i32.const 0
    struct.new 134
  )
  (func (;11;) (type 17) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 130
    i32.const 0
    i32.const 0
    struct.new 134
  )
  (func (;12;) (type 18) (param eqref) (result i32)
    (local (ref 134))
    local.get 0
    ref.cast (ref 134)
    local.tee 1
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 134 1
  )
  (func (;13;) (type 19) (param eqref eqref)
    (local (ref 134) (ref 131) (ref 130) (ref 130) i32 i32 i32 i32 i32 i32 (ref 130) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 134)
    local.set 2
    local.get 2
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 131)
    local.set 3
    local.get 2
    struct.get 134 0
    local.set 4
    local.get 3
    struct.get 131 0
    local.set 5
    local.get 2
    struct.get 134 1
    local.set 6
    local.get 3
    struct.get 131 1
    local.set 7
    local.get 3
    struct.get 131 2
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
      array.new_default 130
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
          array.get 130
          array.set 130
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 134 0
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
            array.get 130
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 130
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
            array.get 130
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
            array.set 130
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
            array.get 130
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
            array.set 130
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
            array.get 130
            local.get 19
            v128.bitselect
            array.set 130
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
        array.get 130
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
        array.get 130
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 130
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 134 1
  )
  (func (;14;) (type 20) (param eqref eqref)
    (local (ref 134) (ref 133) (ref 130) (ref 130) i32 i32 i32 i32 i32 i32 (ref 130) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 134)
    local.set 2
    local.get 2
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 133)
    local.set 3
    local.get 2
    struct.get 134 0
    local.set 4
    local.get 3
    struct.get 133 0
    local.set 5
    local.get 2
    struct.get 134 1
    local.set 6
    local.get 3
    struct.get 133 1
    local.set 7
    local.get 3
    struct.get 133 2
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
      array.new_default 130
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
          array.get 130
          array.set 130
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 134 0
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
            array.get 130
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 130
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
            array.get 130
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
            array.set 130
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
            array.get 130
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
            array.set 130
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
            array.get 130
            local.get 19
            v128.bitselect
            array.set 130
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
        array.get 130
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
        array.get 130
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 130
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 134 1
  )
  (func (;15;) (type 21) (param eqref i32)
    (local (ref 134) (ref 130) i32 i32 i32 (ref 130) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 134)
    local.set 2
    local.get 2
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 134 0
    local.set 3
    local.get 2
    struct.get 134 1
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
      array.new_default 130
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
          array.get 130
          array.set 130
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 134 0
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
    array.get 130
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 130
    local.get 2
    local.get 5
    struct.set 134 1
  )
  (func (;16;) (type 22) (param eqref i32)
    (local (ref 134) (ref 130) i32 i32 i32 i32 i32 (ref 130) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 134)
    local.set 2
    local.get 2
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 134 0
    local.set 3
    local.get 2
    struct.get 134 1
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
      array.new_default 130
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
          array.get 130
          array.set 130
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 134 0
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
    array.get 130
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 130
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
      array.get 130
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 130
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
      array.get 130
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 130
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
      array.get 130
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 130
    end
    local.get 2
    local.get 6
    struct.set 134 1
  )
  (func (;17;) (type 23) (param eqref) (result eqref)
    (local (ref 134))
    local.get 0
    ref.cast (ref 134)
    local.set 1
    local.get 1
    struct.get 134 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 134 2
    local.get 1
    struct.get 134 0
    i32.const 0
    local.get 1
    struct.get 134 1
    struct.new 131
  )
  (func (;18;) (type 24) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 132)
    struct.get 132 2
  )
  (func (;19;) (type 25) (param eqref eqref) (result i32)
    (local (ref 132) (ref 132) (ref 130) (ref 130) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 132)
    local.set 2
    local.get 1
    ref.cast (ref 132)
    local.set 3
    local.get 2
    struct.get 132 2
    local.tee 6
    local.get 3
    struct.get 132 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 132 0
    local.set 4
    local.get 3
    struct.get 132 0
    local.set 5
    local.get 2
    struct.get 132 1
    local.set 7
    local.get 3
    struct.get 132 1
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
          array.get 130
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 130
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
          array.get 130
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
          array.get 130
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 130
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
          array.get 130
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
      array.get 130
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
      array.get 130
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
  (func (;20;) (type 26) (param eqref i32) (result i32)
    (local (ref 132) (ref 130) i32)
    local.get 0
    ref.cast (ref 132)
    local.set 2
    local.get 1
    local.get 2
    struct.get 132 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 132 0
    local.set 3
    local.get 2
    struct.get 132 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 130
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;21;) (type 27) (param eqref i32 i32) (result eqref)
    (local (ref 132) i32)
    local.get 0
    ref.cast (ref 132)
    local.set 3
    local.get 3
    struct.get 132 2
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
    struct.get 132 0
    local.get 3
    struct.get 132 1
    local.get 1
    i32.add
    local.get 2
    struct.new 132
  )
  (func (;22;) (type 28) (param eqref) (result i32)
    local.get 0
    call 18
  )
  (func (;23;) (type 29) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 19
  )
  (func (;24;) (type 30) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 20
  )
  (func (;25;) (type 31) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 21
  )
  (func (;26;) (type 32) (param i64) (result i64)
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
  (func (;27;) (type 33) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 26
    i64.or
  )
  (func (;28;) (type 34) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 26
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;29;) (type 35) (param eqref) (result i64)
    local.get 0
    call 5
  )
  (func (;30;) (type 36) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;31;) (type 37) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;32;) (type 38) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;33;) (type 39) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 6
  )
  (func (;34;) (type 40) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 7
  )
  (func (;35;) (type 41) (param eqref) (result i32)
    local.get 0
    call 8
  )
  (func (;36;) (type 42) (param eqref) (result eqref)
    local.get 0
    call 9
  )
  (func (;37;) (type 43) (param eqref) (result eqref)
    (local eqref)
    local.get 0
    call 35
    call 11
    local.set 1
    local.get 1
    local.get 0
    call 14
    local.get 1
    call 17
  )
  (func (;38;) (type 44) (result eqref)
    call 10
  )
  (func (;39;) (type 45) (param eqref) (result i32)
    local.get 0
    call 12
  )
  (func (;40;) (type 46) (param eqref eqref)
    local.get 0
    local.get 1
    call 13
  )
  (func (;41;) (type 47) (param eqref eqref)
    local.get 0
    local.get 1
    call 14
  )
  (func (;42;) (type 48) (param eqref i32)
    local.get 0
    local.get 1
    call 15
  )
  (func (;43;) (type 49) (param eqref i32)
    local.get 0
    local.get 1
    call 16
  )
  (func (;44;) (type 50) (param eqref) (result eqref)
    local.get 0
    call 17
  )
  (func (;45;) (type 51) (param eqref i32) (result v128)
    (local (ref 132) (ref 130) i32 v128)
    local.get 0
    ref.cast (ref 132)
    local.set 2
    local.get 1
    local.get 2
    struct.get 132 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 132 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 132 0
    local.set 3
    local.get 2
    struct.get 132 1
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
      array.get 130
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 130
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
      array.get 130
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
  (func (;46;) (type 52) (param eqref i32) (result v128)
    (local (ref 131) (ref 130) i32 v128)
    local.get 0
    ref.cast (ref 131)
    local.set 2
    local.get 1
    local.get 2
    struct.get 131 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 131 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 131 0
    local.set 3
    local.get 2
    struct.get 131 1
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
      array.get 130
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 130
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
      array.get 130
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
  (func (;47;) (type 73))
  (func (;48;) (type 74) (result (ref 64))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 64
    ref.cast (ref 64)
  )
  (func (;49;) (type 75) (param (ref 71)) (result i32)
    local.get 0
    struct.get 71 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
  )
  (func (;50;) (type 76) (param (ref 71) i32)
    local.get 0
    struct.get 71 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    local.get 1
    array.set 136
  )
  (func (;51;) (type 77) (param (ref 71)) (result i32)
    local.get 0
    struct.get 71 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 1
    array.get 136
  )
  (func (;52;) (type 78) (param (ref 71) i32)
    local.get 0
    struct.get 71 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 1
    local.get 1
    array.set 136
  )
  (func (;53;) (type 79) (param i32) (result i32)
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
  (func (;54;) (type 80) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;55;) (type 81) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 22
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
              call 45
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
                call 54
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
              call 24
              call 53
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
  (func (;56;) (type 82) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 30
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
              call 46
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
                call 54
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
              call 33
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
  (func (;57;) (type 83) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 22
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
              call 45
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
                call 54
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
              call 24
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
  (func (;58;) (type 84) (param i32) (result i32)
    local.get 0
    call 53
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
  (func (;59;) (type 85) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 22
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
              call 45
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
                call 54
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
              call 24
              call 58
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
  (func (;60;) (type 86) (param (ref 71))
    local.get 0
    local.get 0
    struct.get 71 0
    local.get 0
    call 49
    call 55
    call 50
  )
  (func (;61;) (type 87) (param i32) (result i32)
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
  (func (;62;) (type 88) (param i32) (result i32)
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
  (func (;63;) (type 89) (param eqref i32 i32) (result i32)
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
              call 24
              call 61
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
  (func (;64;) (type 90) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 24
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
          call 24
          call 61
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
        call 24
        call 62
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 63
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
  (func (;65;) (type 91) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 24
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
        call 24
        call 61
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
        call 63
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
  (func (;66;) (type 92) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 24
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 24
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
        call 24
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 24
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
        call 24
        call 61
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
        call 63
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
  (func (;67;) (type 93) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 24
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
      call 64
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
          call 65
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
              call 66
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
  (func (;68;) (type 94) (param i32) (result i32)
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
  (func (;69;) (type 95) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 22
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 22
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
      call 24
      call 68
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 24
      call 68
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 24
      call 68
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 24
      call 68
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
  (func (;70;) (type 96) (param (ref 71) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 39
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 71 3
      struct.get 64 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 71 3
      struct.get 64 3
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
        struct.get 71 1
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 34
        call 41
      else
      end
      i32.const 1
    end
  )
  (func (;71;) (type 97) (param (ref 71)) (result (ref 3))
    (local i32 i32 i32 i32 i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 49
    local.set 1
    local.get 0
    struct.get 71 0
    call 22
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
      struct.new 66
      struct.new 5
    else
      local.get 0
      struct.get 71 0
      local.get 1
      call 24
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
        struct.get 71 0
        local.get 1
        call 24
        struct.new 67
        struct.new 5
      else
        local.get 1
        i32.const 1
        i32.add
        local.set 3
        local.get 0
        struct.get 71 1
        local.get 3
        call 56
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
          struct.new 66
          struct.new 5
        else
          local.get 0
          struct.get 71 0
          local.get 4
          call 24
          i32.const 34
          i32.eq
          if (result eqref) ;; label = @4
            local.get 4
            local.get 3
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            struct.get 71 3
            struct.get 64 3
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
              struct.new 66
              struct.new 5
            else
              local.get 0
              local.get 4
              i32.const 1
              i32.add
              call 50
              local.get 0
              struct.get 71 1
              local.get 3
              local.get 5
              call 34
              local.set 6
              local.get 0
              struct.get 71 4
              if (result eqref) ;; label = @6
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 37
                i32.const 0
                struct.new 63
                struct.new 4
              else
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 36
                i32.const 0
                struct.new 63
                struct.new 4
              end
            end
          else
            local.get 0
            struct.get 71 0
            local.get 4
            call 24
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
              struct.new 66
              struct.new 5
            else
              call 38
              local.set 7
              local.get 3
              local.set 8
              local.get 4
              local.set 9
              i32.const 1
              local.set 18
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 18
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 0
                      struct.get 71 1
                      local.get 9
                      call 56
                      local.set 10
                      local.get 10
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
                        struct.new 66
                        struct.new 5
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      local.get 7
                      local.get 8
                      local.get 10
                      call 70
                      i32.const 0
                      call 1
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 3
                        local.get 10
                        struct.new 66
                        struct.new 5
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      struct.get 71 0
                      local.get 10
                      call 24
                      local.set 11
                      local.get 11
                      i32.const 34
                      i32.eq
                      if ;; label = @10
                        local.get 0
                        local.get 10
                        i32.const 1
                        i32.add
                        call 50
                        i32.const 0
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        local.get 7
                        call 44
                        i32.const 1
                        struct.new 63
                        struct.new 4
                        local.set 19
                        br 4 (;@6;)
                      else
                        local.get 11
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
                          local.get 10
                          struct.new 66
                          struct.new 5
                          local.set 19
                          br 5 (;@6;)
                        else
                          local.get 11
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
                            local.get 10
                            local.get 11
                            struct.new 67
                            struct.new 5
                            local.set 19
                            br 6 (;@6;)
                          else
                            local.get 10
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
                              struct.new 66
                              struct.new 5
                              local.set 19
                              br 7 (;@6;)
                            else
                              local.get 0
                              struct.get 71 0
                              local.get 10
                              i32.const 1
                              i32.add
                              call 24
                              local.set 12
                              local.get 12
                              i32.const 34
                              i32.eq
                              if (result i32) ;; label = @14
                                i32.const 1
                              else
                                local.get 12
                                i32.const 92
                                i32.eq
                              end
                              if (result i32) ;; label = @14
                                i32.const 1
                              else
                                local.get 12
                                i32.const 47
                                i32.eq
                              end
                              if ;; label = @14
                                local.get 7
                                local.get 12
                                call 42
                                local.get 10
                                i32.const 2
                                i32.add
                                local.set 9
                                local.get 9
                                local.set 8
                              else
                                local.get 12
                                i32.const 98
                                i32.eq
                                if ;; label = @15
                                  local.get 7
                                  i32.const 8
                                  call 42
                                  local.get 10
                                  i32.const 2
                                  i32.add
                                  local.set 9
                                  local.get 9
                                  local.set 8
                                else
                                  local.get 12
                                  i32.const 102
                                  i32.eq
                                  if ;; label = @16
                                    local.get 7
                                    i32.const 12
                                    call 42
                                    local.get 10
                                    i32.const 2
                                    i32.add
                                    local.set 9
                                    local.get 9
                                    local.set 8
                                  else
                                    local.get 12
                                    i32.const 110
                                    i32.eq
                                    if ;; label = @17
                                      local.get 7
                                      i32.const 10
                                      call 42
                                      local.get 10
                                      i32.const 2
                                      i32.add
                                      local.set 9
                                      local.get 9
                                      local.set 8
                                    else
                                      local.get 12
                                      i32.const 114
                                      i32.eq
                                      if ;; label = @18
                                        local.get 7
                                        i32.const 13
                                        call 42
                                        local.get 10
                                        i32.const 2
                                        i32.add
                                        local.set 9
                                        local.get 9
                                        local.set 8
                                      else
                                        local.get 12
                                        i32.const 116
                                        i32.eq
                                        if ;; label = @19
                                          local.get 7
                                          i32.const 9
                                          call 42
                                          local.get 10
                                          i32.const 2
                                          i32.add
                                          local.set 9
                                          local.get 9
                                          local.set 8
                                        else
                                          local.get 12
                                          i32.const 117
                                          i32.eq
                                          if ;; label = @20
                                            local.get 0
                                            struct.get 71 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 69
                                            local.set 17
                                            block ;; label = @21
                                              block ;; label = @22
                                                block ;; label = @23
                                                  block ;; label = @24
                                                    local.get 17
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
                                                  local.get 10
                                                  struct.new 66
                                                  struct.new 5
                                                  local.set 19
                                                  br 17 (;@6;)
                                                  br 2 (;@21;)
                                                end
                                                local.get 17
                                                ref.cast (ref 2)
                                                struct.get 2 1
                                                local.set 13
                                                local.get 13
                                                i32.const 55296
                                                i32.ge_u
                                                if (result i32) ;; label = @23
                                                  local.get 13
                                                  i32.const 56319
                                                  i32.le_u
                                                else
                                                  i32.const 0
                                                end
                                                if ;; label = @23
                                                  local.get 10
                                                  i32.const 6
                                                  i32.add
                                                  local.set 14
                                                  local.get 14
                                                  i32.const 5
                                                  i32.add
                                                  local.get 2
                                                  i32.ge_u
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 71 0
                                                    local.get 14
                                                    call 24
                                                    i32.const 92
                                                    i32.ne
                                                  end
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 71 0
                                                    local.get 14
                                                    i32.const 1
                                                    i32.add
                                                    call 24
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
                                                    local.get 10
                                                    struct.new 66
                                                    struct.new 5
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                  end
                                                  local.get 0
                                                  struct.get 71 0
                                                  local.get 14
                                                  i32.const 2
                                                  i32.add
                                                  call 69
                                                  local.set 16
                                                  block ;; label = @24
                                                    local.get 16
                                                    ref.cast (ref 1)
                                                    struct.get 1 0
                                                    i32.const 1
                                                    i32.eq
                                                    if ;; label = @25
                                                      local.get 16
                                                      ref.cast (ref 2)
                                                      struct.get 2 1
                                                      local.set 15
                                                      local.get 15
                                                      i32.const 56320
                                                      i32.ge_u
                                                      if (result i32) ;; label = @26
                                                        local.get 15
                                                        i32.const 57343
                                                        i32.le_u
                                                      else
                                                        i32.const 0
                                                      end
                                                      if ;; label = @26
                                                        local.get 7
                                                        i32.const 65536
                                                        local.get 13
                                                        i32.const 55296
                                                        i32.sub
                                                        i32.const 10
                                                        i32.shl
                                                        i32.add
                                                        local.get 15
                                                        i32.const 56320
                                                        i32.sub
                                                        i32.add
                                                        call 43
                                                        local.get 14
                                                        i32.const 6
                                                        i32.add
                                                        local.set 9
                                                        local.get 9
                                                        local.set 8
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
                                                      local.get 10
                                                      struct.new 66
                                                      struct.new 5
                                                      local.set 19
                                                      br 19 (;@6;)
                                                      br 1 (;@24;)
                                                    end
                                                    unreachable
                                                  end
                                                else
                                                  local.get 13
                                                  i32.const 56320
                                                  i32.ge_u
                                                  if (result i32) ;; label = @24
                                                    local.get 13
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
                                                    local.get 10
                                                    struct.new 66
                                                    struct.new 5
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                    local.get 7
                                                    local.get 13
                                                    call 43
                                                    local.get 10
                                                    i32.const 6
                                                    i32.add
                                                    local.set 9
                                                    local.get 9
                                                    local.set 8
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
                                            local.get 10
                                            struct.new 66
                                            struct.new 5
                                            local.set 19
                                            br 14 (;@6;)
                                          end
                                        end
                                      end
                                    end
                                  end
                                end
                              end
                              local.get 7
                              call 39
                              local.get 0
                              struct.get 71 3
                              struct.get 64 3
                              i32.gt_u
                              if ;; label = @14
                                i32.const 1
                                i32.const 0
                                i64.const 0
                                f32.const 0x0p+0 (;=0;)
                                f64.const 0x0p+0 (;=0;)
                                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                                i32.const 3
                                local.get 10
                                struct.new 66
                                struct.new 5
                                local.set 19
                                br 8 (;@6;)
                              else
                                i32.const 1
                                local.set 18
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
              local.get 19
            end
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;72;) (type 98) (param (ref 71)) (result (ref 3))
    (local (ref 63) (ref 65) eqref eqref)
    local.get 0
    call 71
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 63)
          local.set 1
          i32.const 0
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 1
          ref.cast (ref 63)
          struct.get 63 0
          struct.new 4
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 5)
        struct.get 5 6
        ref.cast (ref 65)
        local.set 2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 5
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 3)
  )
  (func (;73;) (type 99) (param (ref 71) eqref (ref 53)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 49
    local.set 3
    local.get 0
    struct.get 71 0
    call 22
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 22
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
      struct.new 66
      struct.new 5
    else
      local.get 0
      struct.get 71 0
      local.get 3
      local.get 1
      call 22
      call 25
      local.get 1
      call 23
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
        struct.new 66
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 22
        i32.add
        call 50
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
  (func (;74;) (type 100) (param (ref 71)) (result (ref 3))
    (local i32 i32 eqref)
    local.get 0
    call 49
    local.set 1
    local.get 0
    struct.get 71 0
    local.get 1
    call 59
    local.set 2
    local.get 0
    struct.get 71 0
    local.get 1
    local.get 2
    call 67
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
      struct.new 66
      struct.new 5
    else
      local.get 0
      local.get 2
      call 50
      local.get 0
      struct.get 71 1
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 34
      local.set 3
      local.get 0
      struct.get 71 4
      if (result eqref) ;; label = @2
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 37
        struct.new 4
      else
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 36
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;75;) (type 101) (param (ref 71)) (result (ref 3))
    (local eqref (ref 65) eqref eqref)
    local.get 0
    call 74
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 4)
          struct.get 4 6
          local.set 1
          local.get 0
          struct.get 71 5
          if (result eqref) ;; label = @4
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            i32.const 3
            local.get 1
            struct.new 56
            ref.cast (ref 56)
            struct.new 57
            struct.new 4
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            i32.const 2
            local.get 1
            struct.new 55
            struct.new 4
          end
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 5)
        struct.get 5 6
        ref.cast (ref 65)
        local.set 2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 5
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 3)
  )
  (func (;76;) (type 102) (param (ref 71) i32) (result (ref 3))
    (local eqref (ref 65) (ref 53) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 141
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 49
    i32.const 1
    i32.add
    call 50
    local.get 0
    call 60
    local.get 0
    call 49
    local.get 0
    struct.get 71 0
    call 22
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 71 0
      local.get 0
      call 49
      call 24
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 49
      i32.const 1
      i32.add
      call 50
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 6
      local.get 2
      ref.cast (ref 6)
      struct.new 60
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
              call 85
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
                    ref.cast (ref 53)
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
                      array.new_default 141
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
                          ref.cast (ref 141)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 141)
                          local.get 8
                          array.get 141
                          array.set 141
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
                      ref.cast (ref 141)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 141)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 141
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
                  ref.cast (ref 65)
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
              call 60
              local.get 0
              call 49
              local.set 5
              local.get 5
              local.get 0
              struct.get 71 0
              call 22
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
                struct.new 66
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 71 0
              local.get 5
              call 24
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 50
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 6
                local.get 2
                ref.cast (ref 6)
                struct.new 60
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
                  call 50
                  local.get 0
                  call 60
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
                  struct.new 67
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
  (func (;77;) (type 103) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 32
  )
  (func (;78;) (type 104) (param eqref) (result i64)
    local.get 0
    call 29
  )
  (func (;79;) (type 105) (param (ref 6) i32 eqref) (result i32)
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
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 141)
              local.get 5
              array.get 141
              ref.cast (ref 62)
              struct.get 62 0
              local.get 2
              call 77
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
  (func (;80;) (type 106) (param (ref 6) eqref) (result i32)
    local.get 0
    ref.cast (ref 6)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 1
    local.get 1
    call 79
  )
  (func (;81;) (type 107) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;82;) (type 108) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 81
  )
  (func (;83;) (type 109) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 28
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 28
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 28
        else
          local.get 3
          local.get 5
          call 28
        end
      end
    end
  )
  (func (;84;) (type 110) (param (ref 71) i32) (result (ref 3))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 65) eqref i32 i32 i64 i32 (ref 62) i64 i32 i32 i32 i32 (ref 53) (ref 65) (ref 53) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 141
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
    call 49
    i32.const 1
    i32.add
    call 50
    local.get 0
    call 60
    local.get 0
    call 49
    local.get 0
    struct.get 71 0
    call 22
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 71 0
      local.get 0
      call 49
      call 24
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 49
      i32.const 1
      i32.add
      call 50
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 7
      local.get 2
      ref.cast (ref 6)
      struct.new 61
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
              call 49
              local.set 7
              local.get 7
              local.get 0
              struct.get 71 0
              call 22
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
                struct.new 66
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 71 0
              local.get 7
              call 24
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
                struct.get 71 0
                local.get 7
                call 24
                struct.new 67
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 72
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
                  ref.cast (ref 65)
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
                call 29
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
                          ref.cast (ref 141)
                          local.get 29
                          array.get 141
                          ref.cast (ref 62)
                          ref.cast (ref 62)
                          local.set 15
                          local.get 15
                          ref.cast (ref 62)
                          struct.get 62 0
                          call 78
                          local.set 16
                          local.get 16
                          call 82
                          local.set 17
                          local.get 17
                          i32.const 0
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            local.get 16
                            call 27
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 27
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 27
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 27
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
                        call 47
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
                call 82
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
                call 83
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 6)
                  local.get 10
                  call 80
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 6)
                local.get 10
                call 80
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
                struct.new 68
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
                  call 27
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
                    call 27
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
                      call 27
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 27
                        local.set 6
                      else
                      end
                    end
                  end
                end
              end
              local.get 0
              call 60
              local.get 0
              call 49
              local.set 20
              local.get 20
              local.get 0
              struct.get 71 0
              call 22
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
                struct.new 66
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 71 0
              local.get 20
              call 24
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
                struct.get 71 0
                local.get 20
                call 24
                struct.new 67
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 20
              i32.const 1
              i32.add
              call 50
              local.get 0
              call 60
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 85
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
                    ref.cast (ref 53)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 65)
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
              ref.cast (ref 53)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 53)
              struct.new 62
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
                array.new_default 141
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
                    ref.cast (ref 141)
                    local.get 29
                    local.get 28
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 141)
                    local.get 29
                    array.get 141
                    array.set 141
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
                ref.cast (ref 141)
                array.len
                struct.set 6 2
              end
              local.get 28
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 141)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              local.get 34
              array.set 141
              local.get 28
              ref.cast (ref 6)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 60
              local.get 0
              call 49
              local.set 24
              local.get 24
              local.get 0
              struct.get 71 0
              call 22
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
                struct.new 66
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 71 0
              local.get 24
              call 24
              local.set 25
              local.get 25
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 24
                i32.const 1
                i32.add
                call 50
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 7
                local.get 2
                ref.cast (ref 6)
                struct.new 61
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
                  call 50
                  local.get 0
                  call 60
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
                  struct.new 67
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
  (func (;85;) (type 111) (param (ref 71) i32) (result (ref 3))
    (local i32 i32 (ref 63) (ref 65) eqref eqref)
    local.get 1
    local.get 0
    struct.get 71 3
    struct.get 64 1
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
      struct.new 66
      struct.new 5
    else
      local.get 0
      call 51
      local.get 0
      struct.get 71 3
      struct.get 64 2
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
        call 49
        struct.new 66
        struct.new 5
      else
        local.get 0
        local.get 0
        call 51
        i32.const 1
        i32.add
        call 52
        local.get 0
        call 60
        local.get 0
        call 49
        local.set 2
        local.get 2
        local.get 0
        struct.get 71 0
        call 22
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
          struct.new 66
          struct.new 5
        else
          local.get 0
          struct.get 71 0
          local.get 2
          call 24
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 130 1
            i32.const 0
            i32.const 4
            struct.new 132
            i32.const 0
            struct.new 53
            call 73
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 130 1
              i32.const 0
              i32.const 4
              struct.new 132
              i32.const 1
              i32.const 1
              struct.new 54
              call 73
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 130 1
                i32.const 0
                i32.const 5
                struct.new 132
                i32.const 1
                i32.const 0
                struct.new 54
                call 73
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 71
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
                        ref.cast (ref 63)
                        local.set 4
                        local.get 0
                        struct.get 71 6
                        if (result eqref) ;; label = @11
                          i32.const 0
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 5
                          local.get 4
                          ref.cast (ref 63)
                          struct.get 63 0
                          local.get 4
                          ref.cast (ref 63)
                          struct.get 63 1
                          struct.new 58
                          ref.cast (ref 58)
                          struct.new 59
                          struct.new 4
                        else
                          i32.const 0
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 4
                          local.get 4
                          ref.cast (ref 63)
                          struct.get 63 0
                          struct.new 55
                          struct.new 4
                        end
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 65)
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
                    call 76
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 84
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 61
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 75
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
                        struct.new 67
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
  (func (;86;) (type 112) (param eqref (ref 64) i32 i32 i32) (result (ref 3))
    (local i32 (ref 71) (ref 65) (ref 53) eqref i32 eqref eqref)
    local.get 0
    call 30
    local.set 5
    local.get 5
    local.get 1
    struct.get 64 0
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 0
      local.get 5
      struct.new 66
      struct.new 5
    else
      local.get 0
      call 31
      local.get 0
      i32.const 2
      local.set 10
      i32.const 0
      local.get 10
      array.new 136
      struct.new 7
      ref.cast (ref 7)
      local.get 1
      ref.cast (ref 64)
      local.get 2
      local.get 3
      local.get 4
      struct.new 71
      local.set 6
      local.get 6
      i32.const 0
      call 85
      local.set 11
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 11
              ref.cast (ref 3)
              struct.get 3 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            local.get 11
            ref.cast (ref 4)
            struct.get 4 6
            ref.cast (ref 53)
            local.set 8
            local.get 6
            call 60
            local.get 6
            call 49
            local.get 5
            i32.eq
            if (result eqref) ;; label = @5
              i32.const 0
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              local.get 8
              struct.new 4
            else
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 12
              local.get 6
              call 49
              struct.new 66
              struct.new 5
            end
            local.set 12
            br 2 (;@2;)
          end
          local.get 11
          ref.cast (ref 5)
          struct.get 5 6
          ref.cast (ref 65)
          local.set 7
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 7
          struct.new 5
          local.set 12
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 12
    end
    ref.cast (ref 3)
  )
  (func (;87;) (type 113) (param eqref (ref 64)) (result (ref 3))
    local.get 0
    local.get 1
    i32.const 1
    i32.const 0
    i32.const 0
    call 86
    ref.cast (ref 3)
  )
  (func (;88;) (type 114) (param eqref) (result (ref 3))
    local.get 0
    call 48
    call 87
    ref.cast (ref 3)
  )
  (func (;89;) (type 115) (param (ref 72) i32)
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 72 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 136)
      i32.const 0
      local.get 1
      array.set 136
    else
    end
  )
  (func (;90;) (type 116) (param (ref 72) i32 eqref)
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 72 4
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 141)
      i32.const 0
      local.get 2
      array.set 141
      local.get 0
      struct.get 72 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 136)
      i32.const 0
      local.get 1
      array.set 136
    else
    end
  )
  (func (;91;) (type 117) (param (ref 72) i32)
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 72 0
      call 39
      local.get 0
      struct.get 72 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 89
      else
        local.get 0
        struct.get 72 0
        local.get 1
        call 42
      end
    end
  )
  (func (;92;) (type 118) (param (ref 72) eqref)
    (local i32 i32)
    local.get 0
    struct.get 72 0
    call 39
    local.set 2
    local.get 1
    call 30
    local.set 3
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 72 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 72 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 89
      else
        local.get 0
        struct.get 72 0
        local.get 1
        call 40
      end
    end
  )
  (func (;93;) (type 119) (param (ref 72) eqref)
    (local i32 i32)
    local.get 0
    struct.get 72 0
    call 39
    local.set 2
    local.get 1
    call 35
    local.set 3
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 72 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 72 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 89
      else
        local.get 0
        struct.get 72 0
        local.get 1
        call 41
      end
    end
  )
  (func (;94;) (type 120) (param i32) (result i32)
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
  (func (;95;) (type 121) (param (ref 72) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 34
    call 91
    local.get 1
    call 31
    local.set 2
    local.get 2
    call 22
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
              struct.get 72 3
              ref.cast (ref 7)
              struct.get 7 0
              ref.cast (ref 136)
              i32.const 0
              array.get 136
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 57
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
                call 34
                call 93
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
                call 24
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
                  call 91
                  local.get 0
                  local.get 7
                  call 91
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
                    call 91
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
                    call 91
                  else
                    local.get 0
                    i32.const 92
                    call 91
                    local.get 0
                    i32.const 117
                    call 91
                    local.get 0
                    i32.const 48
                    call 91
                    local.get 0
                    i32.const 48
                    call 91
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 94
                    call 91
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 94
                    call 91
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
    call 91
  )
  (func (;96;) (type 122) (param (ref 72) (ref 58))
    local.get 1
    struct.get 58 1
    if ;; label = @1
      local.get 0
      local.get 1
      struct.get 58 0
      call 95
    else
      local.get 0
      i32.const 34
      call 91
      local.get 0
      local.get 1
      struct.get 58 0
      call 92
      local.get 0
      i32.const 34
      call 91
    end
  )
  (func (;97;) (type 123) (param (ref 72) (ref 53) i32)
    (local i32 eqref eqref (ref 56) eqref (ref 58) eqref i32 i32 eqref i64 i64 i64 i64 i32 i32 i32 (ref 62) i64 i32 i32 eqref i32 eqref i32 i32 eqref)
    local.get 0
    struct.get 72 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
    i32.const 0
    i32.ne
    if ;; label = @1
      call 47
    else
      local.get 2
      local.get 0
      struct.get 72 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 89
      else
        local.get 1
        local.set 29
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        block ;; label = @11
                          block ;; label = @12
                            local.get 29
                            ref.cast (ref 53)
                            struct.get 53 0
                            br_table 0 (;@12;) 1 (;@11;) 2 (;@10;) 3 (;@9;) 4 (;@8;) 5 (;@7;) 6 (;@6;) 7 (;@5;) 8 (;@4;)
                          end
                          local.get 0
                          v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                          array.new_fixed 130 1
                          i32.const 0
                          i32.const 4
                          struct.new 131
                          call 92
                          br 8 (;@3;)
                        end
                        local.get 29
                        ref.cast (ref 54)
                        struct.get 54 1
                        local.set 3
                        local.get 3
                        if ;; label = @11
                          local.get 0
                          v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                          array.new_fixed 130 1
                          i32.const 0
                          i32.const 4
                          struct.new 131
                          call 92
                        else
                          local.get 0
                          v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                          array.new_fixed 130 1
                          i32.const 0
                          i32.const 5
                          struct.new 131
                          call 92
                        end
                        br 7 (;@3;)
                      end
                      local.get 29
                      ref.cast (ref 55)
                      struct.get 55 1
                      local.set 4
                      local.get 4
                      call 31
                      local.set 5
                      local.get 5
                      i32.const 0
                      local.get 5
                      call 22
                      call 67
                      if ;; label = @10
                        local.get 0
                        local.get 4
                        call 92
                      else
                        local.get 0
                        i32.const 2
                        local.get 4
                        call 90
                      end
                      br 6 (;@3;)
                    end
                    local.get 29
                    ref.cast (ref 57)
                    struct.get 57 1
                    ref.cast (ref 56)
                    local.set 6
                    local.get 0
                    local.get 6
                    ref.cast (ref 56)
                    struct.get 56 0
                    call 92
                    br 5 (;@3;)
                  end
                  local.get 29
                  ref.cast (ref 55)
                  struct.get 55 1
                  local.set 7
                  local.get 0
                  local.get 7
                  call 95
                  br 4 (;@3;)
                end
                local.get 29
                ref.cast (ref 59)
                struct.get 59 1
                ref.cast (ref 58)
                local.set 8
                local.get 0
                local.get 8
                call 96
                br 3 (;@3;)
              end
              local.get 29
              ref.cast (ref 60)
              struct.get 60 1
              local.set 9
              local.get 0
              i32.const 91
              call 91
              local.get 9
              ref.cast (ref 6)
              struct.get 6 1
              local.set 10
              i32.const 0
              local.set 27
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 27
                      local.set 11
                      local.get 11
                      local.get 10
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 0
                        struct.get 72 3
                        ref.cast (ref 7)
                        struct.get 7 0
                        ref.cast (ref 136)
                        i32.const 0
                        array.get 136
                        i32.const 0
                        i32.eq
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 11
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 91
                        else
                        end
                        local.get 0
                        local.get 9
                        local.get 11
                        local.set 25
                        local.set 24
                        local.get 25
                        local.get 24
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 24
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 141)
                        local.get 25
                        array.get 141
                        ref.cast (ref 53)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 97
                        local.get 11
                        i32.const 1
                        i32.add
                        local.set 27
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 47
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
              call 91
              br 2 (;@3;)
            end
            local.get 29
            ref.cast (ref 61)
            struct.get 61 1
            local.set 12
            local.get 0
            i32.const 123
            call 91
            i64.const 0
            local.set 13
            i64.const 0
            local.set 14
            i64.const 0
            local.set 15
            i64.const 0
            local.set 16
            local.get 12
            ref.cast (ref 6)
            struct.get 6 1
            local.set 17
            local.get 17
            i32.const 16
            i32.ge_u
            local.set 18
            i32.const 0
            local.set 28
            block ;; label = @5
              loop ;; label = @6
                block ;; label = @7
                  i32.const 1
                  if ;; label = @8
                    local.get 28
                    local.set 19
                    local.get 19
                    local.get 17
                    i32.lt_u
                    if (result i32) ;; label = @9
                      local.get 0
                      struct.get 72 3
                      ref.cast (ref 7)
                      struct.get 7 0
                      ref.cast (ref 136)
                      i32.const 0
                      array.get 136
                      i32.const 0
                      i32.eq
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 12
                      local.get 19
                      local.set 25
                      local.set 24
                      local.get 25
                      local.get 24
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 24
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 141)
                      local.get 25
                      array.get 141
                      ref.cast (ref 62)
                      ref.cast (ref 62)
                      local.set 20
                      local.get 18
                      if (result i64) ;; label = @10
                        local.get 20
                        ref.cast (ref 62)
                        struct.get 62 0
                        call 78
                      else
                        i64.const 0
                      end
                      local.set 21
                      local.get 18
                      if (result i32) ;; label = @10
                        local.get 21
                        call 82
                      else
                        i32.const 0
                      end
                      local.set 22
                      local.get 18
                      if (result i32) ;; label = @10
                        local.get 13
                        local.get 14
                        local.get 15
                        local.get 16
                        local.get 22
                        local.get 21
                        call 83
                        if (result i32) ;; label = @11
                          local.get 12
                          ref.cast (ref 6)
                          local.get 19
                          local.get 20
                          ref.cast (ref 62)
                          struct.get 62 0
                          call 79
                        else
                          i32.const 0
                        end
                      else
                        local.get 12
                        ref.cast (ref 6)
                        local.get 19
                        local.get 20
                        ref.cast (ref 62)
                        struct.get 62 0
                        call 79
                      end
                      local.set 23
                      local.get 23
                      if ;; label = @10
                        local.get 0
                        i32.const 4
                        local.get 20
                        ref.cast (ref 62)
                        struct.get 62 0
                        call 90
                      else
                        local.get 22
                        i32.const 0
                        i32.eq
                        if (result i32) ;; label = @11
                          local.get 18
                        else
                          i32.const 0
                        end
                        if ;; label = @11
                          local.get 13
                          local.get 21
                          call 27
                          local.set 13
                        else
                          local.get 22
                          i32.const 1
                          i32.eq
                          if (result i32) ;; label = @12
                            local.get 18
                          else
                            i32.const 0
                          end
                          if ;; label = @12
                            local.get 14
                            local.get 21
                            call 27
                            local.set 14
                          else
                            local.get 22
                            i32.const 2
                            i32.eq
                            if (result i32) ;; label = @13
                              local.get 18
                            else
                              i32.const 0
                            end
                            if ;; label = @13
                              local.get 15
                              local.get 21
                              call 27
                              local.set 15
                            else
                              local.get 18
                              if ;; label = @14
                                local.get 16
                                local.get 21
                                call 27
                                local.set 16
                              else
                              end
                            end
                          end
                        end
                        local.get 19
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 91
                        else
                        end
                        local.get 0
                        local.get 20
                        ref.cast (ref 62)
                        struct.get 62 0
                        call 95
                        local.get 0
                        i32.const 58
                        call 91
                        local.get 0
                        local.get 20
                        ref.cast (ref 62)
                        struct.get 62 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 97
                      end
                      local.get 19
                      i32.const 1
                      i32.add
                      local.set 28
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 47
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
            call 91
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;98;) (type 124) (param (ref 53) i32 i32) (result (ref 3))
    (local eqref (ref 72) eqref i32)
    i32.const 1
    local.set 6
    i32.const 0
    local.get 6
    array.new 136
    struct.new 7
    local.set 3
    call 38
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 7)
    i32.const 1
    local.set 6
    array.new_fixed 130 0
    i32.const 0
    i32.const 0
    struct.new 131
    local.get 6
    array.new 141
    struct.new 7
    ref.cast (ref 7)
    struct.new 72
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 97
    local.get 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 136)
    i32.const 0
    array.get 136
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
      struct.new 69
      struct.new 5
    else
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 136)
      i32.const 0
      array.get 136
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
        ref.cast (ref 72)
        struct.get 72 4
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 141)
        i32.const 0
        array.get 141
        struct.new 70
        struct.new 5
      else
        local.get 3
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 136)
        i32.const 0
        array.get 136
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
          struct.new 69
          struct.new 5
        else
          local.get 3
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 136)
          i32.const 0
          array.get 136
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
            ref.cast (ref 72)
            struct.get 72 4
            ref.cast (ref 7)
            struct.get 7 0
            ref.cast (ref 141)
            i32.const 0
            array.get 141
            struct.new 70
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 72)
            struct.get 72 0
            call 44
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;99;) (type 125) (param (ref 53)) (result (ref 3))
    local.get 0
    i32.const 128
    i32.const 16777216
    call 98
    ref.cast (ref 3)
  )
  (func (;100;) (type 126) (param eqref (ref 53)) (result (ref 62))
    local.get 0
    local.get 1
    ref.cast (ref 53)
    struct.new 62
    ref.cast (ref 62)
  )
  (func (;101;) (type 128) (param i32 eqref) (result i32)
    (local (ref 132) (ref 130) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 132)
    local.set 2
    local.get 2
    struct.get 132 0
    local.set 3
    local.get 2
    struct.get 132 1
    local.set 4
    local.get 2
    struct.get 132 2
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
              array.get 130
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
              array.get 130
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
              array.get 130
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
              array.get 130
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
                array.get 130
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 130
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
                array.get 130
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
            array.get 130
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
  (func (;102;) (type 129) (result i32)
    (local i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref eqref eqref eqref i32 eqref i32 eqref eqref i32 eqref i32)
    v128.const i32x4 0x2261227b 0x222c303a 0x313a2262 0x2263222c
    v128.const i32x4 0x222c323a 0x333a2264 0x2265222c 0x222c343a
    v128.const i32x4 0x353a2266 0x2267222c 0x222c363a 0x373a2268
    v128.const i32x4 0x2269222c 0x222c383a 0x393a226a 0x226b222c
    v128.const i32x4 0x2c30313a 0x3a226c22 0x222c3131 0x313a226d
    v128.const i32x4 0x6e222c32 0x33313a22 0x226f222c 0x2c34313a
    v128.const i32x4 0x3a227122 0x222c3531 0x313a2270 0x30222c36
    v128.const i32x4 0x37313a22 0x0000007d 0x00000000 0x00000000
    array.new_fixed 130 8
    i32.const 0
    i32.const 117
    struct.new 131
    call 88
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 4)
        struct.get 4 6
        ref.cast (ref 53)
        struct.get 53 0
        i32.const 7
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        i32.const 1
        local.set 7
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 7
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 7
    local.set 0
    v128.const i32x4 0x2261227b 0x222c303a 0x313a2262 0x2263222c
    v128.const i32x4 0x222c323a 0x333a2264 0x2265222c 0x222c343a
    v128.const i32x4 0x353a2266 0x2267222c 0x222c363a 0x373a2268
    v128.const i32x4 0x2269222c 0x222c383a 0x393a226a 0x226b222c
    v128.const i32x4 0x2c30313a 0x3a226c22 0x222c3131 0x313a226d
    v128.const i32x4 0x6e222c32 0x33313a22 0x226f222c 0x2c34313a
    v128.const i32x4 0x3a227122 0x222c3531 0x313a2261 0x00007d36
    array.new_fixed 130 7
    i32.const 0
    i32.const 110
    struct.new 131
    call 88
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 8
        ref.cast (ref 5)
        struct.get 5 6
        ref.cast (ref 65)
        struct.get 65 0
        i32.const 11
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
          if (result i32) ;; label = @4
            local.get 8
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 68)
            struct.get 68 2
            v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
            array.new_fixed 130 1
            i32.const 0
            i32.const 1
            struct.new 131
            call 4
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
        i32.const 1
        local.set 9
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 9
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 9
    local.set 1
    v128.const i32x4 0x3031227b 0x6e3a2230 0x2c6c6c75 0x31303122
    v128.const i32x4 0x756e3a22 0x222c6c6c 0x22323031 0x6c756e3a
    v128.const i32x4 0x31222c6c 0x3a223330 0x6c6c756e 0x3031222c
    v128.const i32x4 0x6e3a2234 0x2c6c6c75 0x35303122 0x756e3a22
    v128.const i32x4 0x222c6c6c 0x22363031 0x6c756e3a 0x31222c6c
    v128.const i32x4 0x3a223730 0x6c6c756e 0x3031222c 0x6e3a2238
    v128.const i32x4 0x2c6c6c75 0x39303122 0x756e3a22 0x222c6c6c
    v128.const i32x4 0x22303131 0x6c756e3a 0x31222c6c 0x3a223131
    v128.const i32x4 0x6c6c756e 0x3131222c 0x6e3a2232 0x2c6c6c75
    v128.const i32x4 0x33313122 0x756e3a22 0x222c6c6c 0x22343131
    v128.const i32x4 0x6c756e3a 0x31222c6c 0x3a223531 0x6c6c756e
    v128.const i32x4 0x0000007d 0x00000000 0x00000000 0x00000000
    array.new_fixed 130 12
    i32.const 0
    i32.const 177
    struct.new 131
    call 88
    local.set 17
    block ;; label = @1
      local.get 17
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 17
        ref.cast (ref 4)
        struct.get 4 6
        ref.cast (ref 53)
        struct.get 53 0
        i32.const 7
        i32.eq
        if (result i32) ;; label = @3
          local.get 17
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 61)
          struct.get 61 1
          local.set 2
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 2
        v128.const i32x4 0x00000070 0x00000000 0x00000000 0x00000000
        array.new_fixed 130 1
        i32.const 0
        i32.const 1
        struct.new 131
        i32.const 0
        struct.new 53
        call 100
        local.set 13
        local.set 10
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 10
        ref.cast (ref 6)
        struct.get 6 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 6)
            struct.get 6 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 141
          local.set 12
          i32.const 0
          local.set 11
          block ;; label = @4
            loop ;; label = @5
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              br_if 1 (;@4;)
              local.get 12
              ref.cast (ref 141)
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 141)
              local.get 11
              array.get 141
              array.set 141
              local.get 11
              i32.const 1
              i32.add
              local.set 11
              br 0 (;@5;)
            end
          end
          local.get 10
          ref.cast (ref 6)
          local.get 12
          struct.set 6 0
          local.get 10
          ref.cast (ref 6)
          local.get 12
          ref.cast (ref 141)
          array.len
          struct.set 6 2
        end
        local.get 10
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 141)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 13
        array.set 141
        local.get 10
        ref.cast (ref 6)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        i32.const 1
        i32.add
        struct.set 6 1
        local.get 2
        v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
        array.new_fixed 130 1
        i32.const 0
        i32.const 1
        struct.new 131
        i32.const 0
        struct.new 53
        call 100
        local.set 14
        local.set 10
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 10
        ref.cast (ref 6)
        struct.get 6 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 6)
            struct.get 6 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 141
          local.set 12
          i32.const 0
          local.set 11
          block ;; label = @4
            loop ;; label = @5
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              br_if 1 (;@4;)
              local.get 12
              ref.cast (ref 141)
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 141)
              local.get 11
              array.get 141
              array.set 141
              local.get 11
              i32.const 1
              i32.add
              local.set 11
              br 0 (;@5;)
            end
          end
          local.get 10
          ref.cast (ref 6)
          local.get 12
          struct.set 6 0
          local.get 10
          ref.cast (ref 6)
          local.get 12
          ref.cast (ref 141)
          array.len
          struct.set 6 2
        end
        local.get 10
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 141)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 14
        array.set 141
        local.get 10
        ref.cast (ref 6)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        i32.const 1
        i32.add
        struct.set 6 1
        i32.const 7
        local.get 2
        ref.cast (ref 6)
        struct.new 61
        call 99
        local.set 15
        block ;; label = @3
          local.get 15
          ref.cast (ref 3)
          struct.get 3 0
          i32.const 0
          i32.eq
          if ;; label = @4
            i32.const 1
            local.set 16
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 16
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 16
        local.set 18
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 18
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 18
    local.set 3
    v128.const i32x4 0x2230227b 0x6c756e3a 0x31222c6c 0x756e3a22
    v128.const i32x4 0x222c6c6c 0x6e3a2232 0x2c6c6c75 0x3a223322
    v128.const i32x4 0x6c6c756e 0x2234222c 0x6c756e3a 0x35222c6c
    v128.const i32x4 0x756e3a22 0x222c6c6c 0x6e3a2236 0x2c6c6c75
    v128.const i32x4 0x3a223722 0x6c6c756e 0x2238222c 0x6c756e3a
    v128.const i32x4 0x39222c6c 0x756e3a22 0x222c6c6c 0x3a223031
    v128.const i32x4 0x6c6c756e 0x3131222c 0x756e3a22 0x222c6c6c
    v128.const i32x4 0x3a223231 0x6c6c756e 0x3331222c 0x756e3a22
    v128.const i32x4 0x222c6c6c 0x3a223431 0x6c6c756e 0x3531222c
    v128.const i32x4 0x756e3a22 0x007d6c6c 0x00000000 0x00000000
    array.new_fixed 130 10
    i32.const 0
    i32.const 151
    struct.new 131
    call 88
    local.set 22
    block ;; label = @1
      local.get 22
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 22
        ref.cast (ref 4)
        struct.get 4 6
        ref.cast (ref 53)
        struct.get 53 0
        i32.const 7
        i32.eq
        if (result i32) ;; label = @3
          local.get 22
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 61)
          struct.get 61 1
          local.set 4
          i32.const 1
        else
          i32.const 0
        end
      else
        i32.const 0
      end
      if ;; label = @2
        local.get 4
        v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
        array.new_fixed 130 1
        i32.const 0
        i32.const 1
        struct.new 131
        i32.const 0
        struct.new 53
        call 100
        local.set 19
        local.set 10
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 10
        ref.cast (ref 6)
        struct.get 6 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 6)
            struct.get 6 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 6)
          struct.get 6 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 141
          local.set 12
          i32.const 0
          local.set 11
          block ;; label = @4
            loop ;; label = @5
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 1
              i32.ge_u
              br_if 1 (;@4;)
              local.get 12
              ref.cast (ref 141)
              local.get 11
              local.get 10
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 141)
              local.get 11
              array.get 141
              array.set 141
              local.get 11
              i32.const 1
              i32.add
              local.set 11
              br 0 (;@5;)
            end
          end
          local.get 10
          ref.cast (ref 6)
          local.get 12
          struct.set 6 0
          local.get 10
          ref.cast (ref 6)
          local.get 12
          ref.cast (ref 141)
          array.len
          struct.set 6 2
        end
        local.get 10
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 141)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        local.get 19
        array.set 141
        local.get 10
        ref.cast (ref 6)
        local.get 10
        ref.cast (ref 6)
        struct.get 6 1
        i32.const 1
        i32.add
        struct.set 6 1
        i32.const 7
        local.get 4
        ref.cast (ref 6)
        struct.new 61
        call 99
        local.set 20
        block ;; label = @3
          local.get 20
          ref.cast (ref 3)
          struct.get 3 0
          i32.const 1
          i32.eq
          if (result i32) ;; label = @4
            local.get 20
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 69)
            struct.get 69 0
            i32.const 3
            i32.eq
            if (result i32) ;; label = @5
              local.get 20
              ref.cast (ref 5)
              struct.get 5 6
              ref.cast (ref 70)
              struct.get 70 1
              v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
              array.new_fixed 130 1
              i32.const 0
              i32.const 1
              struct.new 131
              call 4
            else
              i32.const 0
            end
          else
            i32.const 0
          end
          if ;; label = @4
            i32.const 1
            local.set 21
            br 1 (;@3;)
          end
          i32.const 1
          if ;; label = @4
            i32.const 0
            local.set 21
            br 1 (;@3;)
          end
          unreachable
        end
        local.get 21
        local.set 23
        br 1 (;@1;)
      end
      i32.const 1
      if ;; label = @2
        i32.const 0
        local.set 23
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 23
    local.set 5
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 3
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      local.get 5
    else
      i32.const 0
    end
    if (result i32) ;; label = @1
      i32.const 1
      v128.const i32x4 0x6e6f736a 0x6f6c623a 0x652d6d6f 0x74636178
      array.new_fixed 130 1
      i32.const 0
      i32.const 16
      struct.new 132
      call 101
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 130 1
      i32.const 0
      i32.const 4
      struct.new 132
      call 101
    end
  )
)
