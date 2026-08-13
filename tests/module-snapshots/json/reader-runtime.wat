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
  (type (;24;) (func (result eqref)))
  (type (;25;) (func (param i32) (result eqref)))
  (type (;26;) (func (param eqref eqref)))
  (type (;27;) (func (param eqref) (result eqref)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref) (result i32)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param eqref i32) (result i32)))
  (type (;32;) (func (param eqref i32 i32) (result eqref)))
  (type (;33;) (func (result eqref)))
  (type (;34;) (func (param i32) (result eqref)))
  (type (;35;) (func (param eqref eqref)))
  (type (;36;) (func (param eqref) (result eqref)))
  (type (;37;) (func (param eqref) (result i32)))
  (type (;38;) (func (param eqref) (result i32)))
  (type (;39;) (func (param eqref eqref) (result i32)))
  (type (;40;) (func (param eqref i32) (result i32)))
  (type (;41;) (func (param eqref i32 i32) (result eqref)))
  (type (;42;) (sub (struct (field i32))))
  (type (;43;) (sub final 42 (struct (field i32) (field i32))))
  (type (;44;) (struct (field eqref) (field (ref 7))))
  (type (;45;) (struct (field eqref) (field (ref 7))))
  (type (;46;) (func (param eqref eqref) (result (ref 3))))
  (type (;47;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;48;) (func (param eqref) (result (ref 44))))
  (type (;49;) (func (param (ref 44) i32) (result (ref 3))))
  (type (;50;) (func (result (ref 45))))
  (type (;51;) (func (param i32) (result (ref 45))))
  (type (;52;) (func (param (ref 45)) (result i32)))
  (type (;53;) (func (param (ref 45)) (result i32)))
  (type (;54;) (func (param (ref 45)) (result (ref 3))))
  (type (;55;) (func (param (ref 45) eqref) (result (ref 3))))
  (type (;56;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;57;) (func (param eqref eqref) (result (ref 3))))
  (type (;58;) (func (param i64) (result i64)))
  (type (;59;) (func (param i64 i64) (result i64)))
  (type (;60;) (func (param i64 i64) (result i32)))
  (type (;61;) (func (param eqref) (result i64)))
  (type (;62;) (func (param eqref) (result i32)))
  (type (;63;) (func (param eqref) (result eqref)))
  (type (;64;) (func (param eqref eqref) (result i32)))
  (type (;65;) (func (param eqref i32) (result i32)))
  (type (;66;) (func (param eqref i32 i32) (result eqref)))
  (type (;67;) (func (param eqref) (result i32)))
  (type (;68;) (func (param eqref) (result eqref)))
  (type (;69;) (func (param eqref) (result eqref)))
  (type (;70;) (func (result eqref)))
  (type (;71;) (func (param eqref) (result i32)))
  (type (;72;) (func (param eqref eqref)))
  (type (;73;) (func (param eqref eqref)))
  (type (;74;) (func (param eqref i32)))
  (type (;75;) (func (param eqref i32)))
  (type (;76;) (func (param eqref) (result eqref)))
  (type (;77;) (func (param eqref i32) (result v128)))
  (type (;78;) (func (param eqref i32) (result v128)))
  (type (;79;) (sub (struct (field i32))))
  (type (;80;) (sub final 79 (struct (field i32) (field i32))))
  (type (;81;) (sub final 79 (struct (field i32) (field eqref))))
  (type (;82;) (struct (field eqref)))
  (type (;83;) (sub final 79 (struct (field i32) (field (ref 82)))))
  (type (;84;) (sub final 79 (struct (field i32) (field (ref 6)))))
  (type (;85;) (sub final 79 (struct (field i32) (field (ref 6)))))
  (type (;86;) (struct (field eqref) (field (ref 79))))
  (type (;87;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;88;) (sub (struct (field i32))))
  (type (;89;) (sub final 88 (struct (field i32) (field i32))))
  (type (;90;) (sub final 88 (struct (field i32) (field i32) (field i8))))
  (type (;91;) (sub final 88 (struct (field i32) (field i32) (field eqref))))
  (type (;92;) (sub (struct (field i32))))
  (type (;93;) (sub final 92 (struct (field i32) (field eqref))))
  (type (;94;) (sub (struct (field i32))))
  (type (;95;) (sub final 94 (struct (field i32) (field (ref 42)))))
  (type (;96;) (sub final 94 (struct (field i32) (field (ref 88)))))
  (type (;97;) (sub (struct (field i32))))
  (type (;98;) (sub final 97 (struct (field i32) (field (ref 42)))))
  (type (;99;) (sub final 97 (struct (field i32) (field (ref 92)))))
  (type (;100;) (struct (field eqref) (field eqref) (field (ref 7)) (field (ref 87)) (field i32)))
  (type (;101;) (struct (field eqref) (field i32) (field i32) (field (ref 7)) (field (ref 7))))
  (type (;102;) (func (param eqref) (result eqref)))
  (type (;103;) (func))
  (type (;104;) (func (result (ref 87))))
  (type (;105;) (func (param (ref 100)) (result i32)))
  (type (;106;) (func (param (ref 100) i32)))
  (type (;107;) (func (param (ref 100)) (result i32)))
  (type (;108;) (func (param (ref 100) i32)))
  (type (;109;) (func (param i32) (result i32)))
  (type (;110;) (func (param i32) (result i32)))
  (type (;111;) (func (param eqref i32) (result i32)))
  (type (;112;) (func (param eqref i32) (result i32)))
  (type (;113;) (func (param eqref i32) (result i32)))
  (type (;114;) (func (param i32) (result i32)))
  (type (;115;) (func (param eqref i32) (result i32)))
  (type (;116;) (func (param (ref 100))))
  (type (;117;) (func (param i32) (result i32)))
  (type (;118;) (func (param i32) (result i32)))
  (type (;119;) (func (param eqref i32 i32) (result i32)))
  (type (;120;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;121;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;122;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;123;) (func (param eqref i32 i32) (result i32)))
  (type (;124;) (func (param i32) (result i32)))
  (type (;125;) (func (param eqref i32) (result (ref 1))))
  (type (;126;) (func (param (ref 100) eqref i32 i32) (result i32)))
  (type (;127;) (func (param (ref 100)) (result (ref 3))))
  (type (;128;) (func (param (ref 100) eqref (ref 79)) (result (ref 3))))
  (type (;129;) (func (param (ref 100)) (result (ref 3))))
  (type (;130;) (func (param (ref 100)) (result (ref 3))))
  (type (;131;) (func (param (ref 100) i32) (result (ref 3))))
  (type (;132;) (func (param eqref eqref) (result i32)))
  (type (;133;) (func (param eqref) (result i64)))
  (type (;134;) (func (param (ref 6) i32 eqref) (result i32)))
  (type (;135;) (func (param (ref 6) eqref) (result i32)))
  (type (;136;) (func (param i64) (result i32)))
  (type (;137;) (func (param i64) (result i32)))
  (type (;138;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;139;) (func (param (ref 100) i32) (result (ref 3))))
  (type (;140;) (func (param (ref 100) i32) (result (ref 3))))
  (type (;141;) (func (param eqref (ref 87) i32) (result (ref 3))))
  (type (;142;) (func (param eqref (ref 87)) (result (ref 3))))
  (type (;143;) (func (param eqref i32 (ref 87)) (result (ref 3))))
  (type (;144;) (func (param eqref i32) (result (ref 3))))
  (type (;145;) (func (param (ref 101) i32)))
  (type (;146;) (func (param (ref 101) i32 eqref)))
  (type (;147;) (func (param (ref 101) i32)))
  (type (;148;) (func (param (ref 101) eqref)))
  (type (;149;) (func (param (ref 101) eqref)))
  (type (;150;) (func (param i32) (result i32)))
  (type (;151;) (func (param (ref 101) eqref)))
  (type (;152;) (func (param (ref 101) (ref 79) i32)))
  (type (;153;) (func (param (ref 79) i32 i32) (result (ref 3))))
  (type (;154;) (func (param eqref (ref 79) i32 i32) (result (ref 3))))
  (type (;155;) (func (param eqref (ref 79)) (result (ref 3))))
  (type (;156;) (func (param eqref i32) (result (ref 3))))
  (type (;157;) (func (param eqref (ref 79)) (result (ref 3))))
  (type (;158;) (func (param eqref i32 (ref 87)) (result (ref 3))))
  (type (;159;) (func (param eqref (ref 79) i32 i32) (result (ref 3))))
  (type (;160;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;161;) (func (param i32 eqref) (result i32)))
  (type (;162;) (func (result i32)))
  (type (;163;) (array (mut v128)))
  (type (;164;) (struct (field (ref 163)) (field i32) (field i32)))
  (type (;165;) (struct (field (ref 163)) (field i32) (field i32)))
  (type (;166;) (struct (field (ref 163)) (field i32) (field i32)))
  (type (;167;) (struct (field (mut (ref 163))) (field (mut i32)) (field (mut i32))))
  (type (;168;) (struct (field (mut (ref 163))) (field (mut i32)) (field (mut i32))))
  (type (;169;) (array (mut i32)))
  (type (;170;) (array (mut i64)))
  (type (;171;) (array (mut f32)))
  (type (;172;) (array (mut f64)))
  (type (;173;) (array (mut v128)))
  (type (;174;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 160)))
  (memory (;0;) 1)
  (export "main" (func 122))
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
    ref.cast (ref 164)
    struct.get 164 2
  )
  (func (;3;) (type 9) (param eqref) (result eqref)
    (local (ref 164))
    local.get 0
    ref.cast (ref 164)
    local.tee 1
    struct.get 164 0
    local.get 1
    struct.get 164 1
    local.get 1
    struct.get 164 2
    struct.new 165
  )
  (func (;4;) (type 10) (param eqref eqref) (result i32)
    (local (ref 164) (ref 164) (ref 163) (ref 163) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 164)
    local.set 2
    local.get 1
    ref.cast (ref 164)
    local.set 3
    local.get 2
    struct.get 164 2
    local.tee 6
    local.get 3
    struct.get 164 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 164 0
    local.set 4
    local.get 3
    struct.get 164 0
    local.set 5
    local.get 2
    struct.get 164 1
    local.set 7
    local.get 3
    struct.get 164 1
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
          array.get 163
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 163
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
          array.get 163
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
          array.get 163
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 163
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
          array.get 163
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
      array.get 163
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
      array.get 163
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
    (local (ref 164) (ref 163) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 164)
    local.set 1
    local.get 1
    struct.get 164 0
    local.set 2
    local.get 1
    struct.get 164 1
    local.set 3
    local.get 1
    struct.get 164 2
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
      array.get 163
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
    (local (ref 164) (ref 163) i32)
    local.get 0
    ref.cast (ref 164)
    local.set 2
    local.get 1
    local.get 2
    struct.get 164 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 164 0
    local.set 3
    local.get 2
    struct.get 164 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 163
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;7;) (type 13) (param eqref i32 i32) (result eqref)
    (local (ref 164) (ref 163) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 164)
    local.set 3
    local.get 3
    struct.get 164 2
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
    struct.get 164 0
    local.set 4
    local.get 3
    struct.get 164 1
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
      array.get 163
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
      array.get 163
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
    struct.get 164 1
    local.get 1
    i32.add
    local.get 2
    struct.new 166
  )
  (func (;8;) (type 14) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 166)
    struct.get 166 2
  )
  (func (;9;) (type 15) (param eqref) (result eqref)
    (local (ref 166))
    local.get 0
    ref.cast (ref 166)
    local.tee 1
    struct.get 166 0
    local.get 1
    struct.get 166 1
    local.get 1
    struct.get 166 2
    struct.new 164
  )
  (func (;10;) (type 16) (result eqref)
    i32.const 4
    array.new_default 163
    i32.const 0
    i32.const 0
    struct.new 167
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
    array.new_default 163
    i32.const 0
    i32.const 0
    struct.new 167
  )
  (func (;12;) (type 18) (param eqref) (result i32)
    (local (ref 167))
    local.get 0
    ref.cast (ref 167)
    local.tee 1
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 167 1
  )
  (func (;13;) (type 19) (param eqref eqref)
    (local (ref 167) (ref 164) (ref 163) (ref 163) i32 i32 i32 i32 i32 i32 (ref 163) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 167)
    local.set 2
    local.get 2
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 164)
    local.set 3
    local.get 2
    struct.get 167 0
    local.set 4
    local.get 3
    struct.get 164 0
    local.set 5
    local.get 2
    struct.get 167 1
    local.set 6
    local.get 3
    struct.get 164 1
    local.set 7
    local.get 3
    struct.get 164 2
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
      array.new_default 163
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
          array.get 163
          array.set 163
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 167 0
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
            array.get 163
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
            local.get 19
            v128.bitselect
            array.set 163
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
        array.get 163
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
        array.get 163
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 163
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 167 1
  )
  (func (;14;) (type 20) (param eqref eqref)
    (local (ref 167) (ref 166) (ref 163) (ref 163) i32 i32 i32 i32 i32 i32 (ref 163) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 167)
    local.set 2
    local.get 2
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 166)
    local.set 3
    local.get 2
    struct.get 167 0
    local.set 4
    local.get 3
    struct.get 166 0
    local.set 5
    local.get 2
    struct.get 167 1
    local.set 6
    local.get 3
    struct.get 166 1
    local.set 7
    local.get 3
    struct.get 166 2
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
      array.new_default 163
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
          array.get 163
          array.set 163
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 167 0
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
            array.get 163
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
            local.get 19
            v128.bitselect
            array.set 163
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
        array.get 163
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
        array.get 163
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 163
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 167 1
  )
  (func (;15;) (type 21) (param eqref i32)
    (local (ref 167) (ref 163) i32 i32 i32 (ref 163) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 167)
    local.set 2
    local.get 2
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 167 0
    local.set 3
    local.get 2
    struct.get 167 1
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
      array.new_default 163
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
          array.get 163
          array.set 163
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 167 0
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
    array.get 163
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 163
    local.get 2
    local.get 5
    struct.set 167 1
  )
  (func (;16;) (type 22) (param eqref i32)
    (local (ref 167) (ref 163) i32 i32 i32 i32 i32 (ref 163) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 167)
    local.set 2
    local.get 2
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 167 0
    local.set 3
    local.get 2
    struct.get 167 1
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
      array.new_default 163
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
          array.get 163
          array.set 163
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 167 0
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
    array.get 163
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 163
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
      array.get 163
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 163
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
      array.get 163
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 163
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
      array.get 163
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 163
    end
    local.get 2
    local.get 6
    struct.set 167 1
  )
  (func (;17;) (type 23) (param eqref) (result eqref)
    (local (ref 167))
    local.get 0
    ref.cast (ref 167)
    local.set 1
    local.get 1
    struct.get 167 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 167 2
    local.get 1
    struct.get 167 0
    i32.const 0
    local.get 1
    struct.get 167 1
    struct.new 164
  )
  (func (;18;) (type 24) (result eqref)
    i32.const 4
    array.new_default 163
    i32.const 0
    i32.const 0
    struct.new 168
  )
  (func (;19;) (type 25) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 163
    i32.const 0
    i32.const 0
    struct.new 168
  )
  (func (;20;) (type 26) (param eqref eqref)
    (local (ref 168) (ref 165) (ref 163) (ref 163) i32 i32 i32 i32 i32 i32 (ref 163) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 168)
    local.set 2
    local.get 2
    struct.get 168 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 165)
    local.set 3
    local.get 2
    struct.get 168 0
    local.set 4
    local.get 3
    struct.get 165 0
    local.set 5
    local.get 2
    struct.get 168 1
    local.set 6
    local.get 3
    struct.get 165 1
    local.set 7
    local.get 3
    struct.get 165 2
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
      array.new_default 163
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
          array.get 163
          array.set 163
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 168 0
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
            array.get 163
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
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
            array.set 163
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
            array.get 163
            local.get 19
            v128.bitselect
            array.set 163
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
        array.get 163
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
        array.get 163
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 163
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 168 1
  )
  (func (;21;) (type 27) (param eqref) (result eqref)
    (local (ref 168))
    local.get 0
    ref.cast (ref 168)
    local.set 1
    local.get 1
    struct.get 168 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 168 2
    local.get 1
    struct.get 168 0
    i32.const 0
    local.get 1
    struct.get 168 1
    struct.new 165
  )
  (func (;22;) (type 28) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 165)
    struct.get 165 2
  )
  (func (;23;) (type 29) (param eqref) (result i32)
    (local (ref 165) (ref 163) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 165)
    local.set 1
    local.get 1
    struct.get 165 0
    local.set 2
    local.get 1
    struct.get 165 1
    local.set 4
    local.get 1
    struct.get 165 2
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
        array.get 163
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
      array.get 163
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
        array.get 163
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
        array.get 163
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
        array.get 163
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
        array.get 163
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
        array.get 163
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
        array.get 163
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
  (func (;24;) (type 30) (param eqref eqref) (result i32)
    (local (ref 165) (ref 165) (ref 163) (ref 163) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 165)
    local.set 2
    local.get 1
    ref.cast (ref 165)
    local.set 3
    local.get 2
    struct.get 165 2
    local.tee 6
    local.get 3
    struct.get 165 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 165 0
    local.set 4
    local.get 3
    struct.get 165 0
    local.set 5
    local.get 2
    struct.get 165 1
    local.set 7
    local.get 3
    struct.get 165 1
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
          array.get 163
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 163
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
          array.get 163
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
          array.get 163
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 163
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
          array.get 163
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
      array.get 163
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
      array.get 163
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
  (func (;25;) (type 31) (param eqref i32) (result i32)
    (local (ref 165) (ref 163) i32)
    local.get 0
    ref.cast (ref 165)
    local.set 2
    local.get 1
    local.get 2
    struct.get 165 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 165 0
    local.set 3
    local.get 2
    struct.get 165 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 163
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;26;) (type 32) (param eqref i32 i32) (result eqref)
    (local (ref 165) i32)
    local.get 0
    ref.cast (ref 165)
    local.set 3
    local.get 3
    struct.get 165 2
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
    struct.get 165 0
    local.get 3
    struct.get 165 1
    local.get 1
    i32.add
    local.get 2
    struct.new 165
  )
  (func (;27;) (type 33) (result eqref)
    call 18
  )
  (func (;28;) (type 34) (param i32) (result eqref)
    local.get 0
    call 19
  )
  (func (;29;) (type 35) (param eqref eqref)
    local.get 0
    local.get 1
    call 20
  )
  (func (;30;) (type 36) (param eqref) (result eqref)
    local.get 0
    call 21
  )
  (func (;31;) (type 37) (param eqref) (result i32)
    local.get 0
    call 22
  )
  (func (;32;) (type 38) (param eqref) (result i32)
    local.get 0
    call 23
  )
  (func (;33;) (type 39) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 24
  )
  (func (;34;) (type 40) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 25
  )
  (func (;35;) (type 41) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 26
  )
  (func (;36;) (type 48) (param eqref) (result (ref 44))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 169
    struct.new 7
    ref.cast (ref 7)
    struct.new 44
    ref.cast (ref 44)
  )
  (func (;37;) (type 49) (param (ref 44) i32) (result (ref 3))
    (local i32 i32 i32 i32)
    local.get 0
    struct.get 44 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    local.set 2
    local.get 0
    struct.get 44 0
    call 31
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
      struct.new 42
      struct.new 5
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
        array.new_fixed 163 0
        i32.const 0
        i32.const 0
        struct.new 165
        struct.new 4
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
        struct.get 44 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 169)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 169
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        struct.get 44 0
        local.get 2
        local.get 5
        call 35
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;38;) (type 50) (result (ref 45))
    i32.const 0
    call 39
    ref.cast (ref 45)
  )
  (func (;39;) (type 51) (param i32) (result (ref 45))
    (local eqref i32)
    local.get 0
    call 28
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 169
    struct.new 7
    ref.cast (ref 7)
    struct.new 45
    ref.cast (ref 45)
  )
  (func (;40;) (type 52) (param (ref 45)) (result i32)
    local.get 0
    struct.get 45 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 1
    array.get 169
  )
  (func (;41;) (type 53) (param (ref 45)) (result i32)
    local.get 0
    struct.get 45 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.ne
  )
  (func (;42;) (type 54) (param (ref 45)) (result (ref 3))
    local.get 0
    call 41
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 42
      struct.new 5
    else
      local.get 0
      struct.get 45 1
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 169)
      i32.const 0
      i32.const 1
      array.set 169
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      struct.get 45 0
      call 30
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;43;) (type 55) (param (ref 45) eqref) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 41
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 42
      struct.new 5
    else
      local.get 1
      call 31
      local.set 2
      local.get 0
      call 40
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
        struct.new 42
        struct.new 5
      else
        local.get 0
        struct.get 45 0
        local.get 1
        call 29
        local.get 0
        struct.get 45 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 169)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 169
        i32.const 0
        local.get 2
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;44;) (type 56) (param eqref i32 i32) (result (ref 3))
    (local eqref i32 eqref i32 (ref 42) eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 1
      struct.new 42
      struct.new 5
    else
      call 27
      local.set 3
      i32.const 0
      local.set 9
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 9
              local.set 4
              local.get 0
              ref.cast (ref 44)
              local.get 1
              call 37
              local.set 8
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 8
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 8
                    ref.cast (ref 4)
                    struct.get 4 6
                    local.set 5
                    local.get 5
                    call 31
                    local.set 6
                    local.get 6
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 0
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      local.get 3
                      call 30
                      struct.new 4
                      local.set 10
                      br 7 (;@2;)
                    else
                      local.get 6
                      local.get 1
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        i32.const 2
                        struct.new 42
                        struct.new 5
                        local.set 10
                        br 8 (;@2;)
                      else
                        local.get 4
                        local.get 2
                        i32.gt_u
                        if (result i32) ;; label = @11
                          i32.const 1
                        else
                          local.get 6
                          local.get 2
                          local.get 4
                          i32.sub
                          i32.gt_u
                        end
                        if ;; label = @11
                          i32.const 1
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 4
                          struct.new 42
                          struct.new 5
                          local.set 10
                          br 9 (;@2;)
                        else
                          local.get 3
                          local.get 5
                          call 29
                          local.get 4
                          local.get 6
                          i32.add
                          local.set 9
                          br 8 (;@3;)
                        end
                      end
                    end
                    br 2 (;@6;)
                  end
                  local.get 8
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 42)
                  local.set 7
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 7
                  struct.new 5
                  local.set 10
                  br 5 (;@2;)
                  br 1 (;@6;)
                end
                unreachable
              end
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 10
    end
    ref.cast (ref 3)
  )
  (func (;45;) (type 57) (param eqref eqref) (result (ref 3))
    (local i32 i32 eqref i32 (ref 42) eqref i32 eqref)
    local.get 1
    call 31
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
              call 35
              local.set 4
              local.get 0
              ref.cast (ref 45)
              local.get 4
              call 43
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 4)
                    struct.get 4 1
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
                      struct.new 42
                      struct.new 5
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
                        struct.new 42
                        struct.new 5
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
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 42)
                  local.set 6
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 6
                  struct.new 5
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
            struct.new 4
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
    ref.cast (ref 3)
  )
  (func (;46;) (type 58) (param i64) (result i64)
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
  (func (;47;) (type 59) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 46
    i64.or
  )
  (func (;48;) (type 60) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 46
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;49;) (type 61) (param eqref) (result i64)
    local.get 0
    call 5
  )
  (func (;50;) (type 62) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;51;) (type 63) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;52;) (type 64) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;53;) (type 65) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 6
  )
  (func (;54;) (type 66) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 7
  )
  (func (;55;) (type 67) (param eqref) (result i32)
    local.get 0
    call 8
  )
  (func (;56;) (type 68) (param eqref) (result eqref)
    local.get 0
    call 9
  )
  (func (;57;) (type 69) (param eqref) (result eqref)
    (local eqref)
    local.get 0
    call 55
    call 11
    local.set 1
    local.get 1
    local.get 0
    call 14
    local.get 1
    call 17
  )
  (func (;58;) (type 70) (result eqref)
    call 10
  )
  (func (;59;) (type 71) (param eqref) (result i32)
    local.get 0
    call 12
  )
  (func (;60;) (type 72) (param eqref eqref)
    local.get 0
    local.get 1
    call 13
  )
  (func (;61;) (type 73) (param eqref eqref)
    local.get 0
    local.get 1
    call 14
  )
  (func (;62;) (type 74) (param eqref i32)
    local.get 0
    local.get 1
    call 15
  )
  (func (;63;) (type 75) (param eqref i32)
    local.get 0
    local.get 1
    call 16
  )
  (func (;64;) (type 76) (param eqref) (result eqref)
    local.get 0
    call 17
  )
  (func (;65;) (type 77) (param eqref i32) (result v128)
    (local (ref 165) (ref 163) i32 v128)
    local.get 0
    ref.cast (ref 165)
    local.set 2
    local.get 1
    local.get 2
    struct.get 165 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 165 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 165 0
    local.set 3
    local.get 2
    struct.get 165 1
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
      array.get 163
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 163
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
      array.get 163
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
  (func (;66;) (type 78) (param eqref i32) (result v128)
    (local (ref 164) (ref 163) i32 v128)
    local.get 0
    ref.cast (ref 164)
    local.set 2
    local.get 1
    local.get 2
    struct.get 164 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 164 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 164 0
    local.set 3
    local.get 2
    struct.get 164 1
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
      array.get 163
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 163
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
      array.get 163
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
  (func (;67;) (type 102) (param eqref) (result eqref)
    (local (ref 165))
    local.get 0
    ref.cast (ref 165)
    local.tee 1
    struct.get 165 0
    local.get 1
    struct.get 165 1
    local.get 1
    struct.get 165 2
    struct.new 164
  )
  (func (;68;) (type 103))
  (func (;69;) (type 104) (result (ref 87))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 87
    ref.cast (ref 87)
  )
  (func (;70;) (type 105) (param (ref 100)) (result i32)
    local.get 0
    struct.get 100 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
  )
  (func (;71;) (type 106) (param (ref 100) i32)
    local.get 0
    struct.get 100 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    local.get 1
    array.set 169
  )
  (func (;72;) (type 107) (param (ref 100)) (result i32)
    local.get 0
    struct.get 100 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 1
    array.get 169
  )
  (func (;73;) (type 108) (param (ref 100) i32)
    local.get 0
    struct.get 100 2
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 1
    local.get 1
    array.set 169
  )
  (func (;74;) (type 109) (param i32) (result i32)
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
  (func (;75;) (type 110) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;76;) (type 111) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 31
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
              call 65
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
                call 75
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
              call 34
              call 74
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
  (func (;77;) (type 112) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 50
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
              call 66
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
                call 75
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
              call 53
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
  (func (;78;) (type 113) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 31
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
              call 65
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
                call 75
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
              call 34
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
  (func (;79;) (type 114) (param i32) (result i32)
    local.get 0
    call 74
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
  (func (;80;) (type 115) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 31
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
              call 65
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
                call 75
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
              call 34
              call 79
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
  (func (;81;) (type 116) (param (ref 100))
    local.get 0
    local.get 0
    struct.get 100 0
    local.get 0
    call 70
    call 76
    call 71
  )
  (func (;82;) (type 117) (param i32) (result i32)
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
  (func (;83;) (type 118) (param i32) (result i32)
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
  (func (;84;) (type 119) (param eqref i32 i32) (result i32)
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
              call 34
              call 82
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
  (func (;85;) (type 120) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 34
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
          call 34
          call 82
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
        call 34
        call 83
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 84
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
  (func (;86;) (type 121) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 34
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
        call 34
        call 82
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
        call 84
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
  (func (;87;) (type 122) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 34
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 34
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
        call 34
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 34
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
        call 34
        call 82
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
        call 84
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
  (func (;88;) (type 123) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 34
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
      call 85
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
          call 86
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
              call 87
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
  (func (;89;) (type 124) (param i32) (result i32)
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
  (func (;90;) (type 125) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 31
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 31
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
      call 34
      call 89
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 34
      call 89
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 34
      call 89
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 34
      call 89
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
  (func (;91;) (type 126) (param (ref 100) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 59
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 100 3
      struct.get 87 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 100 3
      struct.get 87 3
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
        struct.get 100 1
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 54
        call 61
      else
      end
      i32.const 1
    end
  )
  (func (;92;) (type 127) (param (ref 100)) (result (ref 3))
    (local i32 i32 i32 i32 i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 70
    local.set 1
    local.get 0
    struct.get 100 0
    call 31
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
      struct.new 89
      struct.new 5
    else
      local.get 0
      struct.get 100 0
      local.get 1
      call 34
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
        struct.get 100 0
        local.get 1
        call 34
        struct.new 90
        struct.new 5
      else
        local.get 1
        i32.const 1
        i32.add
        local.set 3
        local.get 0
        struct.get 100 1
        local.get 3
        call 77
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
          struct.new 89
          struct.new 5
        else
          local.get 0
          struct.get 100 0
          local.get 4
          call 34
          i32.const 34
          i32.eq
          if (result eqref) ;; label = @4
            local.get 4
            local.get 3
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            struct.get 100 3
            struct.get 87 3
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
              struct.new 89
              struct.new 5
            else
              local.get 0
              local.get 4
              i32.const 1
              i32.add
              call 71
              local.get 0
              struct.get 100 1
              local.get 3
              local.get 5
              call 54
              local.set 6
              local.get 0
              struct.get 100 4
              if (result eqref) ;; label = @6
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 57
                struct.new 4
              else
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 56
                struct.new 4
              end
            end
          else
            local.get 0
            struct.get 100 0
            local.get 4
            call 34
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
              struct.new 89
              struct.new 5
            else
              call 58
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
                      struct.get 100 1
                      local.get 9
                      call 77
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
                        struct.new 89
                        struct.new 5
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      local.get 7
                      local.get 8
                      local.get 10
                      call 91
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
                        struct.new 89
                        struct.new 5
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      struct.get 100 0
                      local.get 10
                      call 34
                      local.set 11
                      local.get 11
                      i32.const 34
                      i32.eq
                      if ;; label = @10
                        local.get 0
                        local.get 10
                        i32.const 1
                        i32.add
                        call 71
                        i32.const 0
                        i32.const 0
                        i64.const 0
                        f32.const 0x0p+0 (;=0;)
                        f64.const 0x0p+0 (;=0;)
                        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                        local.get 7
                        call 64
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
                          struct.new 89
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
                            struct.new 90
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
                              struct.new 89
                              struct.new 5
                              local.set 19
                              br 7 (;@6;)
                            else
                              local.get 0
                              struct.get 100 0
                              local.get 10
                              i32.const 1
                              i32.add
                              call 34
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
                                call 62
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
                                  call 62
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
                                    call 62
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
                                      call 62
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
                                        call 62
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
                                          call 62
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
                                            struct.get 100 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 90
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
                                                  struct.new 89
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
                                                    struct.get 100 0
                                                    local.get 14
                                                    call 34
                                                    i32.const 92
                                                    i32.ne
                                                  end
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 100 0
                                                    local.get 14
                                                    i32.const 1
                                                    i32.add
                                                    call 34
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
                                                    struct.new 89
                                                    struct.new 5
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                  end
                                                  local.get 0
                                                  struct.get 100 0
                                                  local.get 14
                                                  i32.const 2
                                                  i32.add
                                                  call 90
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
                                                        call 63
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
                                                      struct.new 89
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
                                                    struct.new 89
                                                    struct.new 5
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                    local.get 7
                                                    local.get 13
                                                    call 63
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
                                            struct.new 89
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
                              call 59
                              local.get 0
                              struct.get 100 3
                              struct.get 87 3
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
                                struct.new 89
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
  (func (;93;) (type 128) (param (ref 100) eqref (ref 79)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 70
    local.set 3
    local.get 0
    struct.get 100 0
    call 31
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 31
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
      struct.new 89
      struct.new 5
    else
      local.get 0
      struct.get 100 0
      local.get 3
      local.get 1
      call 31
      call 35
      local.get 1
      call 33
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
        struct.new 89
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 31
        i32.add
        call 71
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
  (func (;94;) (type 129) (param (ref 100)) (result (ref 3))
    (local i32 i32 eqref)
    local.get 0
    call 70
    local.set 1
    local.get 0
    struct.get 100 0
    local.get 1
    call 80
    local.set 2
    local.get 0
    struct.get 100 0
    local.get 1
    local.get 2
    call 88
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
      struct.new 89
      struct.new 5
    else
      local.get 0
      local.get 2
      call 71
      local.get 0
      struct.get 100 1
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 54
      local.set 3
      local.get 0
      struct.get 100 4
      if (result eqref) ;; label = @2
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 57
        struct.new 4
      else
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 56
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;95;) (type 130) (param (ref 100)) (result (ref 3))
    (local eqref (ref 88) eqref eqref)
    local.get 0
    call 94
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
          i32.const 0
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          i32.const 2
          local.get 1
          struct.new 81
          struct.new 4
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 5)
        struct.get 5 6
        ref.cast (ref 88)
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
  (func (;96;) (type 131) (param (ref 100) i32) (result (ref 3))
    (local eqref (ref 88) (ref 79) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 174
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 70
    i32.const 1
    i32.add
    call 71
    local.get 0
    call 81
    local.get 0
    call 70
    local.get 0
    struct.get 100 0
    call 31
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 100 0
      local.get 0
      call 70
      call 34
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 70
      i32.const 1
      i32.add
      call 71
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 6)
      struct.new 84
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
              call 105
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
                    ref.cast (ref 79)
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
                      array.new_default 174
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
                          ref.cast (ref 174)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 174)
                          local.get 8
                          array.get 174
                          array.set 174
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
                      ref.cast (ref 174)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 174)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 174
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
                  ref.cast (ref 88)
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
              call 81
              local.get 0
              call 70
              local.set 5
              local.get 5
              local.get 0
              struct.get 100 0
              call 31
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
                struct.new 89
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 100 0
              local.get 5
              call 34
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 71
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 6)
                struct.new 84
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
                  call 71
                  local.get 0
                  call 81
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
                  struct.new 90
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
  (func (;97;) (type 132) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 52
  )
  (func (;98;) (type 133) (param eqref) (result i64)
    local.get 0
    call 49
  )
  (func (;99;) (type 134) (param (ref 6) i32 eqref) (result i32)
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
              ref.cast (ref 174)
              local.get 5
              array.get 174
              ref.cast (ref 86)
              struct.get 86 0
              local.get 2
              call 97
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
  (func (;100;) (type 135) (param (ref 6) eqref) (result i32)
    local.get 0
    ref.cast (ref 6)
    local.get 0
    ref.cast (ref 6)
    struct.get 6 1
    local.get 1
    call 99
  )
  (func (;101;) (type 136) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;102;) (type 137) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 101
  )
  (func (;103;) (type 138) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 48
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 48
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 48
        else
          local.get 3
          local.get 5
          call 48
        end
      end
    end
  )
  (func (;104;) (type 139) (param (ref 100) i32) (result (ref 3))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 88) eqref i32 i32 i64 i32 (ref 86) i64 i32 i32 i32 i32 (ref 79) (ref 88) (ref 79) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 174
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
    call 70
    i32.const 1
    i32.add
    call 71
    local.get 0
    call 81
    local.get 0
    call 70
    local.get 0
    struct.get 100 0
    call 31
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 100 0
      local.get 0
      call 70
      call 34
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 70
      i32.const 1
      i32.add
      call 71
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 6
      local.get 2
      ref.cast (ref 6)
      struct.new 85
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
              call 70
              local.set 7
              local.get 7
              local.get 0
              struct.get 100 0
              call 31
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
                struct.new 89
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 100 0
              local.get 7
              call 34
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
                struct.get 100 0
                local.get 7
                call 34
                struct.new 90
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 92
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
                  ref.cast (ref 88)
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
                call 49
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
                          ref.cast (ref 174)
                          local.get 29
                          array.get 174
                          ref.cast (ref 86)
                          ref.cast (ref 86)
                          local.set 15
                          local.get 15
                          ref.cast (ref 86)
                          struct.get 86 0
                          call 98
                          local.set 16
                          local.get 16
                          call 102
                          local.set 17
                          local.get 17
                          i32.const 0
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            local.get 16
                            call 47
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 47
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 47
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 47
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
                        call 68
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
                call 102
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
                call 103
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 6)
                  local.get 10
                  call 100
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 6)
                local.get 10
                call 100
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
                struct.new 91
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
                  call 47
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
                    call 47
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
                      call 47
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 47
                        local.set 6
                      else
                      end
                    end
                  end
                end
              end
              local.get 0
              call 81
              local.get 0
              call 70
              local.set 20
              local.get 20
              local.get 0
              struct.get 100 0
              call 31
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
                struct.new 89
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 100 0
              local.get 20
              call 34
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
                struct.get 100 0
                local.get 20
                call 34
                struct.new 90
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 20
              i32.const 1
              i32.add
              call 71
              local.get 0
              call 81
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 105
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
                    ref.cast (ref 79)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 88)
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
              ref.cast (ref 79)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 79)
              struct.new 86
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
                array.new_default 174
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
                    ref.cast (ref 174)
                    local.get 29
                    local.get 28
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 174)
                    local.get 29
                    array.get 174
                    array.set 174
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
                ref.cast (ref 174)
                array.len
                struct.set 6 2
              end
              local.get 28
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 174)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              local.get 34
              array.set 174
              local.get 28
              ref.cast (ref 6)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 81
              local.get 0
              call 70
              local.set 24
              local.get 24
              local.get 0
              struct.get 100 0
              call 31
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
                struct.new 89
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 100 0
              local.get 24
              call 34
              local.set 25
              local.get 25
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 24
                i32.const 1
                i32.add
                call 71
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 6
                local.get 2
                ref.cast (ref 6)
                struct.new 85
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
                  call 71
                  local.get 0
                  call 81
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
                  struct.new 90
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
  (func (;105;) (type 140) (param (ref 100) i32) (result (ref 3))
    (local i32 i32 eqref (ref 88) eqref eqref)
    local.get 1
    local.get 0
    struct.get 100 3
    struct.get 87 1
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
      struct.new 89
      struct.new 5
    else
      local.get 0
      call 72
      local.get 0
      struct.get 100 3
      struct.get 87 2
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
        call 70
        struct.new 89
        struct.new 5
      else
        local.get 0
        local.get 0
        call 72
        i32.const 1
        i32.add
        call 73
        local.get 0
        call 81
        local.get 0
        call 70
        local.set 2
        local.get 2
        local.get 0
        struct.get 100 0
        call 31
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
          struct.new 89
          struct.new 5
        else
          local.get 0
          struct.get 100 0
          local.get 2
          call 34
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 163 1
            i32.const 0
            i32.const 4
            struct.new 165
            i32.const 0
            struct.new 79
            call 93
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 163 1
              i32.const 0
              i32.const 4
              struct.new 165
              i32.const 1
              i32.const 1
              struct.new 80
              call 93
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 163 1
                i32.const 0
                i32.const 5
                struct.new 165
                i32.const 1
                i32.const 0
                struct.new 80
                call 93
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 92
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
                        i32.const 4
                        local.get 4
                        struct.new 81
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 88)
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
                    call 96
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 104
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 82
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 95
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
                        struct.new 90
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
  (func (;106;) (type 141) (param eqref (ref 87) i32) (result (ref 3))
    (local i32 (ref 100) (ref 88) (ref 79) eqref i32 eqref eqref)
    local.get 0
    call 50
    local.set 3
    local.get 3
    local.get 1
    struct.get 87 0
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 0
      local.get 3
      struct.new 89
      struct.new 5
    else
      local.get 0
      call 51
      local.get 0
      i32.const 2
      local.set 8
      i32.const 0
      local.get 8
      array.new 169
      struct.new 7
      ref.cast (ref 7)
      local.get 1
      ref.cast (ref 87)
      local.get 2
      struct.new 100
      local.set 4
      local.get 4
      i32.const 0
      call 105
      local.set 9
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 9
              ref.cast (ref 3)
              struct.get 3 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            local.get 9
            ref.cast (ref 4)
            struct.get 4 6
            ref.cast (ref 79)
            local.set 6
            local.get 4
            call 81
            local.get 4
            call 70
            local.get 3
            i32.eq
            if (result eqref) ;; label = @5
              i32.const 0
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              local.get 6
              struct.new 4
            else
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 12
              local.get 4
              call 70
              struct.new 89
              struct.new 5
            end
            local.set 10
            br 2 (;@2;)
          end
          local.get 9
          ref.cast (ref 5)
          struct.get 5 6
          ref.cast (ref 88)
          local.set 5
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 5
          struct.new 5
          local.set 10
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 10
    end
    ref.cast (ref 3)
  )
  (func (;107;) (type 142) (param eqref (ref 87)) (result (ref 3))
    (local i32)
    local.get 0
    call 31
    local.set 2
    local.get 2
    local.get 1
    struct.get 87 0
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
      struct.new 89
      struct.new 5
    else
      local.get 0
      call 32
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
        struct.new 88
        struct.new 5
      else
        local.get 0
        call 67
        local.get 1
        i32.const 1
        call 106
      end
    end
    ref.cast (ref 3)
  )
  (func (;108;) (type 145) (param (ref 101) i32)
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 101 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 169)
      i32.const 0
      local.get 1
      array.set 169
    else
    end
  )
  (func (;109;) (type 146) (param (ref 101) i32 eqref)
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 101 4
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 174)
      i32.const 0
      local.get 2
      array.set 174
      local.get 0
      struct.get 101 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 169)
      i32.const 0
      local.get 1
      array.set 169
    else
    end
  )
  (func (;110;) (type 147) (param (ref 101) i32)
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 101 0
      call 59
      local.get 0
      struct.get 101 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 108
      else
        local.get 0
        struct.get 101 0
        local.get 1
        call 62
      end
    end
  )
  (func (;111;) (type 148) (param (ref 101) eqref)
    (local i32 i32)
    local.get 0
    struct.get 101 0
    call 59
    local.set 2
    local.get 1
    call 50
    local.set 3
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 101 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 101 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 108
      else
        local.get 0
        struct.get 101 0
        local.get 1
        call 60
      end
    end
  )
  (func (;112;) (type 149) (param (ref 101) eqref)
    (local i32 i32)
    local.get 0
    struct.get 101 0
    call 59
    local.set 2
    local.get 1
    call 55
    local.set 3
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 101 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 101 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 108
      else
        local.get 0
        struct.get 101 0
        local.get 1
        call 61
      end
    end
  )
  (func (;113;) (type 150) (param i32) (result i32)
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
  (func (;114;) (type 151) (param (ref 101) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 34
    call 110
    local.get 1
    call 51
    local.set 2
    local.get 2
    call 31
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
              struct.get 101 3
              ref.cast (ref 7)
              struct.get 7 0
              ref.cast (ref 169)
              i32.const 0
              array.get 169
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 78
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
                call 54
                call 112
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
                call 34
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
                  call 110
                  local.get 0
                  local.get 7
                  call 110
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
                    call 110
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
                    call 110
                  else
                    local.get 0
                    i32.const 92
                    call 110
                    local.get 0
                    i32.const 117
                    call 110
                    local.get 0
                    i32.const 48
                    call 110
                    local.get 0
                    i32.const 48
                    call 110
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 113
                    call 110
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 113
                    call 110
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
    call 110
  )
  (func (;115;) (type 152) (param (ref 101) (ref 79) i32)
    (local i32 eqref eqref (ref 82) eqref eqref i32 i32 eqref i64 i64 i64 i64 i32 i32 i32 (ref 86) i64 i32 i32 eqref i32 eqref i32 i32 eqref)
    local.get 0
    struct.get 101 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
    i32.const 0
    i32.ne
    if ;; label = @1
      call 68
    else
      local.get 2
      local.get 0
      struct.get 101 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 108
      else
        local.get 1
        local.set 28
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        block ;; label = @11
                          local.get 28
                          ref.cast (ref 79)
                          struct.get 79 0
                          br_table 0 (;@11;) 1 (;@10;) 2 (;@9;) 3 (;@8;) 4 (;@7;) 5 (;@6;) 6 (;@5;) 7 (;@4;)
                        end
                        local.get 0
                        v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                        array.new_fixed 163 1
                        i32.const 0
                        i32.const 4
                        struct.new 164
                        call 111
                        br 7 (;@3;)
                      end
                      local.get 28
                      ref.cast (ref 80)
                      struct.get 80 1
                      local.set 3
                      local.get 3
                      if ;; label = @10
                        local.get 0
                        v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                        array.new_fixed 163 1
                        i32.const 0
                        i32.const 4
                        struct.new 164
                        call 111
                      else
                        local.get 0
                        v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                        array.new_fixed 163 1
                        i32.const 0
                        i32.const 5
                        struct.new 164
                        call 111
                      end
                      br 6 (;@3;)
                    end
                    local.get 28
                    ref.cast (ref 81)
                    struct.get 81 1
                    local.set 4
                    local.get 4
                    call 51
                    local.set 5
                    local.get 5
                    i32.const 0
                    local.get 5
                    call 31
                    call 88
                    if ;; label = @9
                      local.get 0
                      local.get 4
                      call 111
                    else
                      local.get 0
                      i32.const 2
                      local.get 4
                      call 109
                    end
                    br 5 (;@3;)
                  end
                  local.get 28
                  ref.cast (ref 83)
                  struct.get 83 1
                  ref.cast (ref 82)
                  local.set 6
                  local.get 0
                  local.get 6
                  ref.cast (ref 82)
                  struct.get 82 0
                  call 111
                  br 4 (;@3;)
                end
                local.get 28
                ref.cast (ref 81)
                struct.get 81 1
                local.set 7
                local.get 0
                local.get 7
                call 114
                br 3 (;@3;)
              end
              local.get 28
              ref.cast (ref 84)
              struct.get 84 1
              local.set 8
              local.get 0
              i32.const 91
              call 110
              local.get 8
              ref.cast (ref 6)
              struct.get 6 1
              local.set 9
              i32.const 0
              local.set 26
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    i32.const 1
                    if ;; label = @9
                      local.get 26
                      local.set 10
                      local.get 10
                      local.get 9
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 0
                        struct.get 101 3
                        ref.cast (ref 7)
                        struct.get 7 0
                        ref.cast (ref 169)
                        i32.const 0
                        array.get 169
                        i32.const 0
                        i32.eq
                      else
                        i32.const 0
                      end
                      if ;; label = @10
                        local.get 10
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 110
                        else
                        end
                        local.get 0
                        local.get 8
                        local.get 10
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
                        ref.cast (ref 174)
                        local.get 24
                        array.get 174
                        ref.cast (ref 79)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 115
                        local.get 10
                        i32.const 1
                        i32.add
                        local.set 26
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 68
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
              call 110
              br 2 (;@3;)
            end
            local.get 28
            ref.cast (ref 85)
            struct.get 85 1
            local.set 11
            local.get 0
            i32.const 123
            call 110
            i64.const 0
            local.set 12
            i64.const 0
            local.set 13
            i64.const 0
            local.set 14
            i64.const 0
            local.set 15
            local.get 11
            ref.cast (ref 6)
            struct.get 6 1
            local.set 16
            local.get 16
            i32.const 16
            i32.ge_u
            local.set 17
            i32.const 0
            local.set 27
            block ;; label = @5
              loop ;; label = @6
                block ;; label = @7
                  i32.const 1
                  if ;; label = @8
                    local.get 27
                    local.set 18
                    local.get 18
                    local.get 16
                    i32.lt_u
                    if (result i32) ;; label = @9
                      local.get 0
                      struct.get 101 3
                      ref.cast (ref 7)
                      struct.get 7 0
                      ref.cast (ref 169)
                      i32.const 0
                      array.get 169
                      i32.const 0
                      i32.eq
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 11
                      local.get 18
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
                      ref.cast (ref 174)
                      local.get 24
                      array.get 174
                      ref.cast (ref 86)
                      ref.cast (ref 86)
                      local.set 19
                      local.get 17
                      if (result i64) ;; label = @10
                        local.get 19
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 98
                      else
                        i64.const 0
                      end
                      local.set 20
                      local.get 17
                      if (result i32) ;; label = @10
                        local.get 20
                        call 102
                      else
                        i32.const 0
                      end
                      local.set 21
                      local.get 17
                      if (result i32) ;; label = @10
                        local.get 12
                        local.get 13
                        local.get 14
                        local.get 15
                        local.get 21
                        local.get 20
                        call 103
                        if (result i32) ;; label = @11
                          local.get 11
                          ref.cast (ref 6)
                          local.get 18
                          local.get 19
                          ref.cast (ref 86)
                          struct.get 86 0
                          call 99
                        else
                          i32.const 0
                        end
                      else
                        local.get 11
                        ref.cast (ref 6)
                        local.get 18
                        local.get 19
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 99
                      end
                      local.set 22
                      local.get 22
                      if ;; label = @10
                        local.get 0
                        i32.const 4
                        local.get 19
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 109
                      else
                        local.get 21
                        i32.const 0
                        i32.eq
                        if (result i32) ;; label = @11
                          local.get 17
                        else
                          i32.const 0
                        end
                        if ;; label = @11
                          local.get 12
                          local.get 20
                          call 47
                          local.set 12
                        else
                          local.get 21
                          i32.const 1
                          i32.eq
                          if (result i32) ;; label = @12
                            local.get 17
                          else
                            i32.const 0
                          end
                          if ;; label = @12
                            local.get 13
                            local.get 20
                            call 47
                            local.set 13
                          else
                            local.get 21
                            i32.const 2
                            i32.eq
                            if (result i32) ;; label = @13
                              local.get 17
                            else
                              i32.const 0
                            end
                            if ;; label = @13
                              local.get 14
                              local.get 20
                              call 47
                              local.set 14
                            else
                              local.get 17
                              if ;; label = @14
                                local.get 15
                                local.get 20
                                call 47
                                local.set 15
                              else
                              end
                            end
                          end
                        end
                        local.get 18
                        i32.const 0
                        i32.gt_u
                        if ;; label = @11
                          local.get 0
                          i32.const 44
                          call 110
                        else
                        end
                        local.get 0
                        local.get 19
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 114
                        local.get 0
                        i32.const 58
                        call 110
                        local.get 0
                        local.get 19
                        ref.cast (ref 86)
                        struct.get 86 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 115
                      end
                      local.get 18
                      i32.const 1
                      i32.add
                      local.set 27
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 68
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
            call 110
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;116;) (type 153) (param (ref 79) i32 i32) (result (ref 3))
    (local eqref (ref 101) eqref i32)
    i32.const 1
    local.set 6
    i32.const 0
    local.get 6
    array.new 169
    struct.new 7
    local.set 3
    call 58
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 7)
    i32.const 1
    local.set 6
    array.new_fixed 163 0
    i32.const 0
    i32.const 0
    struct.new 164
    local.get 6
    array.new 174
    struct.new 7
    ref.cast (ref 7)
    struct.new 101
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 115
    local.get 3
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 169)
    i32.const 0
    array.get 169
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
      struct.new 92
      struct.new 5
    else
      local.get 3
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 169)
      i32.const 0
      array.get 169
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
        ref.cast (ref 101)
        struct.get 101 4
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 174)
        i32.const 0
        array.get 174
        struct.new 93
        struct.new 5
      else
        local.get 3
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 169)
        i32.const 0
        array.get 169
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
          struct.new 92
          struct.new 5
        else
          local.get 3
          ref.cast (ref 7)
          struct.get 7 0
          ref.cast (ref 169)
          i32.const 0
          array.get 169
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
            ref.cast (ref 101)
            struct.get 101 4
            ref.cast (ref 7)
            struct.get 7 0
            ref.cast (ref 174)
            i32.const 0
            array.get 174
            struct.new 93
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 101)
            struct.get 101 0
            call 64
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;117;) (type 156) (param eqref i32) (result (ref 3))
    local.get 0
    local.get 1
    call 69
    call 119
    ref.cast (ref 3)
  )
  (func (;118;) (type 157) (param eqref (ref 79)) (result (ref 3))
    local.get 0
    local.get 1
    ref.cast (ref 79)
    i32.const 128
    i32.const 16777216
    call 120
    ref.cast (ref 3)
  )
  (func (;119;) (type 158) (param eqref i32 (ref 87)) (result (ref 3))
    (local eqref eqref (ref 88) (ref 79) eqref eqref eqref eqref)
    local.get 0
    local.get 1
    local.get 2
    struct.get 87 0
    call 44
    local.set 9
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 9
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 9
          ref.cast (ref 4)
          struct.get 4 6
          local.set 4
          local.get 4
          local.get 2
          ref.cast (ref 87)
          call 107
          local.set 7
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 7
                  ref.cast (ref 3)
                  struct.get 3 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                local.get 7
                ref.cast (ref 4)
                struct.get 4 6
                ref.cast (ref 79)
                local.set 6
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                struct.new 4
                local.set 8
                br 2 (;@4;)
              end
              local.get 7
              ref.cast (ref 5)
              struct.get 5 6
              ref.cast (ref 88)
              local.set 5
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 1
              local.get 5
              ref.cast (ref 88)
              struct.new 96
              struct.new 5
              local.set 8
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 8
          local.set 10
          br 2 (;@1;)
        end
        local.get 9
        ref.cast (ref 5)
        struct.get 5 6
        local.set 3
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 0
        local.get 3
        ref.cast (ref 42)
        struct.new 95
        struct.new 5
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 3)
  )
  (func (;120;) (type 159) (param eqref (ref 79) i32 i32) (result (ref 3))
    (local (ref 92) eqref eqref i32 eqref eqref eqref eqref)
    local.get 1
    ref.cast (ref 79)
    local.get 2
    local.get 3
    call 116
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 3)
            struct.get 3 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 10
          ref.cast (ref 4)
          struct.get 4 6
          local.set 5
          local.get 0
          local.get 5
          call 51
          call 45
          local.set 8
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 8
                  ref.cast (ref 3)
                  struct.get 3 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                local.get 8
                ref.cast (ref 4)
                struct.get 4 1
                local.set 7
                i32.const 0
                local.get 7
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                ref.null eq
                struct.new 4
                local.set 9
                br 2 (;@4;)
              end
              local.get 8
              ref.cast (ref 5)
              struct.get 5 6
              local.set 6
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 0
              local.get 6
              ref.cast (ref 42)
              struct.new 98
              struct.new 5
              local.set 9
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 9
          local.set 11
          br 2 (;@1;)
        end
        local.get 10
        ref.cast (ref 5)
        struct.get 5 6
        ref.cast (ref 92)
        local.set 4
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 1
        local.get 4
        ref.cast (ref 92)
        struct.new 99
        struct.new 5
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 3)
  )
  (func (;121;) (type 161) (param i32 eqref) (result i32)
    (local (ref 165) (ref 163) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 165)
    local.set 2
    local.get 2
    struct.get 165 0
    local.set 3
    local.get 2
    struct.get 165 1
    local.set 4
    local.get 2
    struct.get 165 2
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
              array.get 163
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
              array.get 163
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
              array.get 163
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
              array.get 163
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
                array.get 163
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 163
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
                array.get 163
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
            array.get 163
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
  (func (;122;) (type 162) (result i32)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
    array.new_fixed 163 1
    i32.const 0
    i32.const 11
    struct.new 165
    call 36
    i32.const 3
    call 117
    local.set 7
    block ;; label = @1
      local.get 7
      ref.cast (ref 3)
      struct.get 3 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 7
        ref.cast (ref 4)
        struct.get 4 6
        ref.cast (ref 79)
        struct.get 79 0
        i32.const 5
        i32.eq
        if (result i32) ;; label = @3
          local.get 7
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 84)
          struct.get 84 1
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
        struct.get 6 1
        i32.const 2
        i32.eq
        if ;; label = @3
          call 38
          local.set 1
          local.get 1
          i32.const 5
          local.get 0
          ref.cast (ref 6)
          struct.new 84
          call 118
          local.set 5
          block ;; label = @4
            local.get 5
            ref.cast (ref 3)
            struct.get 3 0
            i32.const 0
            i32.eq
            if (result i32) ;; label = @5
              local.get 5
              ref.cast (ref 4)
              struct.get 4 1
              i32.const 11
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 1
              ref.cast (ref 45)
              call 42
              local.set 3
              block ;; label = @6
                local.get 3
                ref.cast (ref 3)
                struct.get 3 0
                i32.const 0
                i32.eq
                if ;; label = @7
                  local.get 3
                  ref.cast (ref 4)
                  struct.get 4 6
                  local.set 2
                  local.get 2
                  v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
                  array.new_fixed 163 1
                  i32.const 0
                  i32.const 11
                  struct.new 165
                  call 33
                  if ;; label = @8
                    i32.const 1
                    v128.const i32x4 0x6e6f736a 0x6165723a 0x2d726564 0x74697277
                    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
                    array.new_fixed 163 2
                    i32.const 0
                    i32.const 18
                    struct.new 165
                    call 121
                    local.set 4
                    br 2 (;@6;)
                  end
                end
                i32.const 1
                if ;; label = @7
                  i32.const 1
                  v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
                  array.new_fixed 163 1
                  i32.const 0
                  i32.const 4
                  struct.new 165
                  call 121
                  local.set 4
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 4
              local.set 6
              br 1 (;@4;)
            end
            i32.const 1
            if ;; label = @5
              i32.const 1
              v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
              array.new_fixed 163 1
              i32.const 0
              i32.const 4
              struct.new 165
              call 121
              local.set 6
              br 1 (;@4;)
            end
            unreachable
          end
          local.get 6
          local.set 8
          br 2 (;@1;)
        end
      end
      i32.const 1
      if ;; label = @2
        i32.const 1
        v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
        array.new_fixed 163 1
        i32.const 0
        i32.const 4
        struct.new 165
        call 121
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
  )
)
