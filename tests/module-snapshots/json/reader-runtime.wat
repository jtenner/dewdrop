(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param i32 i32) (result i32)))
  (type (;9;) (sub (struct (field i32))))
  (type (;10;) (sub final 9 (struct (field i32) (field i32))))
  (type (;11;) (sub final 9 (struct (field i32) (field eqref))))
  (type (;12;) (sub (struct (field i32))))
  (type (;13;) (sub final 12 (struct (field i32) (field eqref))))
  (type (;14;) (sub final 12 (struct (field i32) (field i32))))
  (type (;15;) (sub final 12 (struct (field i32))))
  (type (;16;) (sub final 12 (struct (field i32) (field eqref))))
  (type (;17;) (sub final 12 (struct (field i32) (field eqref))))
  (type (;18;) (sub final 12 (struct (field i32) (field eqref))))
  (type (;19;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;20;) (struct (field eqref) (field (mut i32))))
  (type (;21;) (sub (struct (field funcref))))
  (type (;22;) (func (param eqref) (result eqref)))
  (type (;23;) (func (param eqref i32) (result eqref)))
  (type (;24;) (func (param eqref) (result (ref 19))))
  (type (;25;) (func (param eqref eqref) (result eqref)))
  (type (;26;) (func (param eqref)))
  (type (;27;) (func (param eqref i32)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref i32) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result eqref)))
  (type (;31;) (func (param eqref eqref) (result (ref 19))))
  (type (;32;) (func (param eqref eqref eqref) (result eqref)))
  (type (;33;) (func (param eqref eqref)))
  (type (;34;) (func (param eqref eqref i32)))
  (type (;35;) (func (param eqref eqref) (result i32)))
  (type (;36;) (func (param eqref eqref i32) (result i32)))
  (type (;37;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;38;) (func (param eqref i32) (result v128)))
  (type (;39;) (func (param eqref i32) (result v128)))
  (type (;40;) (func (param eqref) (result i32)))
  (type (;41;) (func (param eqref) (result eqref)))
  (type (;42;) (func (param eqref eqref) (result i32)))
  (type (;43;) (func (param eqref) (result i64)))
  (type (;44;) (func (param eqref i32) (result i32)))
  (type (;45;) (func (param eqref i32 i32) (result eqref)))
  (type (;46;) (func (param eqref) (result i32)))
  (type (;47;) (func (param eqref) (result eqref)))
  (type (;48;) (func (result eqref)))
  (type (;49;) (func (param i32) (result eqref)))
  (type (;50;) (func (param eqref) (result i32)))
  (type (;51;) (func (param eqref eqref)))
  (type (;52;) (func (param eqref eqref)))
  (type (;53;) (func (param eqref i32)))
  (type (;54;) (func (param eqref i32)))
  (type (;55;) (func (param eqref) (result eqref)))
  (type (;56;) (func (result eqref)))
  (type (;57;) (func (param i32) (result eqref)))
  (type (;58;) (func (param eqref eqref)))
  (type (;59;) (func (param eqref) (result eqref)))
  (type (;60;) (func (param eqref) (result i32)))
  (type (;61;) (func (param eqref) (result i32)))
  (type (;62;) (func (param eqref eqref) (result i32)))
  (type (;63;) (func (param eqref i32) (result i32)))
  (type (;64;) (func (param eqref i32 i32) (result eqref)))
  (type (;65;) (func (result eqref)))
  (type (;66;) (func (param i32) (result eqref)))
  (type (;67;) (func (param eqref eqref)))
  (type (;68;) (func (param eqref) (result eqref)))
  (type (;69;) (func (param eqref) (result i32)))
  (type (;70;) (func (param eqref) (result i32)))
  (type (;71;) (func (param eqref eqref) (result i32)))
  (type (;72;) (func (param eqref i32) (result i32)))
  (type (;73;) (func (param eqref i32 i32) (result eqref)))
  (type (;74;) (sub (struct (field i32))))
  (type (;75;) (sub final 74 (struct (field i32) (field i32))))
  (type (;76;) (struct (field eqref) (field (ref 0))))
  (type (;77;) (struct (field eqref) (field (ref 0))))
  (type (;78;) (func (param eqref eqref) (result (ref 12))))
  (type (;79;) (func (param eqref i32 i32) (result (ref 12))))
  (type (;80;) (func (param eqref) (result (ref 76))))
  (type (;81;) (func (param (ref 76) i32) (result (ref 12))))
  (type (;82;) (func (result (ref 77))))
  (type (;83;) (func (param i32) (result (ref 77))))
  (type (;84;) (func (param (ref 77)) (result i32)))
  (type (;85;) (func (param (ref 77)) (result i32)))
  (type (;86;) (func (param (ref 77)) (result (ref 12))))
  (type (;87;) (func (param (ref 77) eqref) (result (ref 12))))
  (type (;88;) (func (param eqref i32 i32) (result (ref 12))))
  (type (;89;) (func (param eqref eqref) (result (ref 12))))
  (type (;90;) (func (param i64) (result i64)))
  (type (;91;) (func (param i64 i64) (result i64)))
  (type (;92;) (func (param i64 i64) (result i32)))
  (type (;93;) (func (param eqref) (result i64)))
  (type (;94;) (func (param eqref) (result i32)))
  (type (;95;) (func (param eqref) (result eqref)))
  (type (;96;) (func (param eqref eqref) (result i32)))
  (type (;97;) (func (param eqref i32) (result i32)))
  (type (;98;) (func (param eqref i32 i32) (result eqref)))
  (type (;99;) (func (param eqref) (result i32)))
  (type (;100;) (func (param eqref) (result eqref)))
  (type (;101;) (func (param eqref) (result eqref)))
  (type (;102;) (func (result eqref)))
  (type (;103;) (func (param eqref) (result i32)))
  (type (;104;) (func (param eqref eqref)))
  (type (;105;) (func (param eqref eqref)))
  (type (;106;) (func (param eqref i32)))
  (type (;107;) (func (param eqref i32)))
  (type (;108;) (func (param eqref) (result eqref)))
  (type (;109;) (sub (struct (field i32))))
  (type (;110;) (sub final 109 (struct (field i32) (field i32))))
  (type (;111;) (sub final 109 (struct (field i32) (field eqref))))
  (type (;112;) (struct (field eqref)))
  (type (;113;) (sub final 109 (struct (field i32) (field (ref 112)))))
  (type (;114;) (struct (field eqref) (field i32)))
  (type (;115;) (sub final 109 (struct (field i32) (field (ref 114)))))
  (type (;116;) (sub final 109 (struct (field i32) (field (ref 19)))))
  (type (;117;) (sub final 109 (struct (field i32) (field (ref 19)))))
  (type (;118;) (struct (field eqref) (field (ref 109))))
  (type (;119;) (struct (field eqref) (field i32)))
  (type (;120;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;121;) (sub (struct (field i32))))
  (type (;122;) (sub final 121 (struct (field i32) (field i32))))
  (type (;123;) (sub final 121 (struct (field i32) (field i32) (field i8))))
  (type (;124;) (sub final 121 (struct (field i32) (field i32) (field eqref))))
  (type (;125;) (sub (struct (field i32))))
  (type (;126;) (sub final 125 (struct (field i32) (field eqref))))
  (type (;127;) (sub (struct (field i32))))
  (type (;128;) (sub final 127 (struct (field i32) (field (ref 74)))))
  (type (;129;) (sub final 127 (struct (field i32) (field (ref 121)))))
  (type (;130;) (sub (struct (field i32))))
  (type (;131;) (sub final 130 (struct (field i32) (field (ref 74)))))
  (type (;132;) (sub final 130 (struct (field i32) (field (ref 125)))))
  (type (;133;) (struct (field eqref) (field eqref) (field (ref 0)) (field (ref 120)) (field i32) (field i32) (field i32)))
  (type (;134;) (struct (field eqref) (field i32) (field i32) (field (ref 0)) (field (ref 5))))
  (type (;135;) (func (param eqref) (result eqref)))
  (type (;136;) (func))
  (type (;137;) (func (result (ref 120))))
  (type (;138;) (func (param (ref 133)) (result i32)))
  (type (;139;) (func (param (ref 133) i32)))
  (type (;140;) (func (param (ref 133)) (result i32)))
  (type (;141;) (func (param (ref 133) i32)))
  (type (;142;) (func (param i32) (result i32)))
  (type (;143;) (func (param i32) (result i32)))
  (type (;144;) (func (param eqref i32) (result i32)))
  (type (;145;) (func (param eqref i32) (result i32)))
  (type (;146;) (func (param eqref i32) (result i32)))
  (type (;147;) (func (param i32) (result i32)))
  (type (;148;) (func (param eqref i32) (result i32)))
  (type (;149;) (func (param (ref 133))))
  (type (;150;) (func (param i32) (result i32)))
  (type (;151;) (func (param i32) (result i32)))
  (type (;152;) (func (param eqref i32 i32) (result i32)))
  (type (;153;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;154;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;155;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;156;) (func (param eqref i32 i32) (result i32)))
  (type (;157;) (func (param i32) (result i32)))
  (type (;158;) (func (param eqref i32) (result (ref 9))))
  (type (;159;) (func (param (ref 133) eqref i32 i32) (result i32)))
  (type (;160;) (func (param (ref 133)) (result (ref 12))))
  (type (;161;) (func (param (ref 133)) (result (ref 12))))
  (type (;162;) (func (param (ref 133) eqref (ref 109)) (result (ref 12))))
  (type (;163;) (func (param (ref 133)) (result (ref 12))))
  (type (;164;) (func (param (ref 133)) (result (ref 12))))
  (type (;165;) (func (param (ref 133) i32) (result (ref 12))))
  (type (;166;) (func (param eqref eqref) (result i32)))
  (type (;167;) (func (param eqref) (result i64)))
  (type (;168;) (func (param (ref 19) i32 eqref) (result i32)))
  (type (;169;) (func (param (ref 19) eqref) (result i32)))
  (type (;170;) (func (param i64) (result i32)))
  (type (;171;) (func (param i64) (result i32)))
  (type (;172;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;173;) (func (param (ref 133) i32) (result (ref 12))))
  (type (;174;) (func (param (ref 133) i32) (result (ref 12))))
  (type (;175;) (func (param eqref (ref 120) i32 i32 i32) (result (ref 12))))
  (type (;176;) (func (param eqref (ref 120)) (result (ref 12))))
  (type (;177;) (func (param eqref i32 (ref 120)) (result (ref 12))))
  (type (;178;) (func (param eqref i32) (result (ref 12))))
  (type (;179;) (func (param (ref 134) i32)))
  (type (;180;) (func (param (ref 134) i32 eqref)))
  (type (;181;) (func (param (ref 134) i32)))
  (type (;182;) (func (param (ref 134) eqref)))
  (type (;183;) (func (param (ref 134) eqref)))
  (type (;184;) (func (param i32) (result i32)))
  (type (;185;) (func (param (ref 134) eqref)))
  (type (;186;) (func (param (ref 134) (ref 114))))
  (type (;187;) (func (param (ref 134) (ref 109) i32)))
  (type (;188;) (func (param (ref 109) i32 i32) (result (ref 12))))
  (type (;189;) (func (param eqref (ref 109) i32 i32) (result (ref 12))))
  (type (;190;) (func (param eqref (ref 109)) (result (ref 12))))
  (type (;191;) (func (param eqref i32) (result (ref 12))))
  (type (;192;) (func (param eqref (ref 109)) (result (ref 12))))
  (type (;193;) (func (param eqref i32 (ref 120)) (result (ref 12))))
  (type (;194;) (func (param eqref (ref 109) i32 i32) (result (ref 12))))
  (type (;195;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;196;) (func (param i32 eqref) (result i32)))
  (type (;197;) (func (result i32)))
  (type (;198;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;199;) (struct))
  (type (;200;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;201;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;202;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;203;) (array (mut v128)))
  (type (;204;) (struct (field (ref 203)) (field i32) (field i32)))
  (type (;205;) (struct (field (ref 203)) (field i32) (field i32)))
  (type (;206;) (struct (field (ref 203)) (field i32) (field i32)))
  (type (;207;) (struct (field (mut (ref 203))) (field (mut i32)) (field (mut i32))))
  (type (;208;) (struct (field (mut (ref 203))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 195)))
  (memory (;0;) 1)
  (export "main" (func 124))
  (export "memory" (memory 0))
  (func (;1;) (type 8) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;2;) (type 38) (param eqref i32) (result v128)
    (local (ref 205) (ref 203) i32 v128)
    local.get 0
    ref.cast (ref 205)
    local.set 2
    local.get 1
    local.get 2
    struct.get 205 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 205 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 205 0
    local.set 3
    local.get 2
    struct.get 205 1
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
      array.get 203
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 203
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
      array.get 203
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
  (func (;3;) (type 39) (param eqref i32) (result v128)
    (local (ref 204) (ref 203) i32 v128)
    local.get 0
    ref.cast (ref 204)
    local.set 2
    local.get 1
    local.get 2
    struct.get 204 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 204 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 204 0
    local.set 3
    local.get 2
    struct.get 204 1
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
      array.get 203
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 203
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
      array.get 203
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
  (func (;4;) (type 40) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 204)
    struct.get 204 2
  )
  (func (;5;) (type 41) (param eqref) (result eqref)
    (local (ref 204))
    local.get 0
    ref.cast (ref 204)
    local.tee 1
    struct.get 204 0
    local.get 1
    struct.get 204 1
    local.get 1
    struct.get 204 2
    struct.new 205
  )
  (func (;6;) (type 42) (param eqref eqref) (result i32)
    (local (ref 204) (ref 204) (ref 203) (ref 203) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 204)
    local.set 2
    local.get 1
    ref.cast (ref 204)
    local.set 3
    local.get 2
    struct.get 204 2
    local.tee 6
    local.get 3
    struct.get 204 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 204 0
    local.set 4
    local.get 3
    struct.get 204 0
    local.set 5
    local.get 2
    struct.get 204 1
    local.set 7
    local.get 3
    struct.get 204 1
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
          array.get 203
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 203
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
          array.get 203
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
          array.get 203
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 203
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
          array.get 203
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
      array.get 203
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
      array.get 203
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
  (func (;7;) (type 43) (param eqref) (result i64)
    (local (ref 204) (ref 203) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 204)
    local.set 1
    local.get 1
    struct.get 204 0
    local.set 2
    local.get 1
    struct.get 204 1
    local.set 3
    local.get 1
    struct.get 204 2
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
      array.get 203
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
  (func (;8;) (type 44) (param eqref i32) (result i32)
    (local (ref 204) (ref 203) i32)
    local.get 0
    ref.cast (ref 204)
    local.set 2
    local.get 1
    local.get 2
    struct.get 204 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 204 0
    local.set 3
    local.get 2
    struct.get 204 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 203
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;9;) (type 45) (param eqref i32 i32) (result eqref)
    (local (ref 204) (ref 203) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 204)
    local.set 3
    local.get 3
    struct.get 204 2
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
    struct.get 204 0
    local.set 4
    local.get 3
    struct.get 204 1
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
      array.get 203
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
      array.get 203
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
    struct.get 204 1
    local.get 1
    i32.add
    local.get 2
    struct.new 206
  )
  (func (;10;) (type 46) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 206)
    struct.get 206 2
  )
  (func (;11;) (type 47) (param eqref) (result eqref)
    (local (ref 206))
    local.get 0
    ref.cast (ref 206)
    local.tee 1
    struct.get 206 0
    local.get 1
    struct.get 206 1
    local.get 1
    struct.get 206 2
    struct.new 204
  )
  (func (;12;) (type 48) (result eqref)
    i32.const 4
    array.new_default 203
    i32.const 0
    i32.const 0
    struct.new 207
  )
  (func (;13;) (type 49) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 203
    i32.const 0
    i32.const 0
    struct.new 207
  )
  (func (;14;) (type 50) (param eqref) (result i32)
    (local (ref 207))
    local.get 0
    ref.cast (ref 207)
    local.tee 1
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 207 1
  )
  (func (;15;) (type 51) (param eqref eqref)
    (local (ref 207) (ref 204) (ref 203) (ref 203) i32 i32 i32 i32 i32 i32 (ref 203) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 207)
    local.set 2
    local.get 2
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 204)
    local.set 3
    local.get 2
    struct.get 207 0
    local.set 4
    local.get 3
    struct.get 204 0
    local.set 5
    local.get 2
    struct.get 207 1
    local.set 6
    local.get 3
    struct.get 204 1
    local.set 7
    local.get 3
    struct.get 204 2
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
      array.new_default 203
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
          array.get 203
          array.set 203
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 207 0
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
            array.get 203
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
            local.get 19
            v128.bitselect
            array.set 203
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
        array.get 203
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
        array.get 203
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 203
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 207 1
  )
  (func (;16;) (type 52) (param eqref eqref)
    (local (ref 207) (ref 206) (ref 203) (ref 203) i32 i32 i32 i32 i32 i32 (ref 203) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 207)
    local.set 2
    local.get 2
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 206)
    local.set 3
    local.get 2
    struct.get 207 0
    local.set 4
    local.get 3
    struct.get 206 0
    local.set 5
    local.get 2
    struct.get 207 1
    local.set 6
    local.get 3
    struct.get 206 1
    local.set 7
    local.get 3
    struct.get 206 2
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
      array.new_default 203
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
          array.get 203
          array.set 203
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 207 0
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
            array.get 203
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
            local.get 19
            v128.bitselect
            array.set 203
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
        array.get 203
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
        array.get 203
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 203
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 207 1
  )
  (func (;17;) (type 53) (param eqref i32)
    (local (ref 207) (ref 203) i32 i32 i32 (ref 203) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 207)
    local.set 2
    local.get 2
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 207 0
    local.set 3
    local.get 2
    struct.get 207 1
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
      array.new_default 203
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
          array.get 203
          array.set 203
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 207 0
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
    array.get 203
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 203
    local.get 2
    local.get 5
    struct.set 207 1
  )
  (func (;18;) (type 54) (param eqref i32)
    (local (ref 207) (ref 203) i32 i32 i32 i32 i32 (ref 203) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 207)
    local.set 2
    local.get 2
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 207 0
    local.set 3
    local.get 2
    struct.get 207 1
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
      array.new_default 203
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
          array.get 203
          array.set 203
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 207 0
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
    array.get 203
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 203
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
      array.get 203
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 203
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
      array.get 203
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 203
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
      array.get 203
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 203
    end
    local.get 2
    local.get 6
    struct.set 207 1
  )
  (func (;19;) (type 55) (param eqref) (result eqref)
    (local (ref 207))
    local.get 0
    ref.cast (ref 207)
    local.set 1
    local.get 1
    struct.get 207 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 207 2
    local.get 1
    struct.get 207 0
    i32.const 0
    local.get 1
    struct.get 207 1
    struct.new 204
  )
  (func (;20;) (type 56) (result eqref)
    i32.const 4
    array.new_default 203
    i32.const 0
    i32.const 0
    struct.new 208
  )
  (func (;21;) (type 57) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 203
    i32.const 0
    i32.const 0
    struct.new 208
  )
  (func (;22;) (type 58) (param eqref eqref)
    (local (ref 208) (ref 205) (ref 203) (ref 203) i32 i32 i32 i32 i32 i32 (ref 203) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 208)
    local.set 2
    local.get 2
    struct.get 208 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 205)
    local.set 3
    local.get 2
    struct.get 208 0
    local.set 4
    local.get 3
    struct.get 205 0
    local.set 5
    local.get 2
    struct.get 208 1
    local.set 6
    local.get 3
    struct.get 205 1
    local.set 7
    local.get 3
    struct.get 205 2
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
      array.new_default 203
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
          array.get 203
          array.set 203
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 208 0
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
            array.get 203
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
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
            array.set 203
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
            array.get 203
            local.get 19
            v128.bitselect
            array.set 203
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
        array.get 203
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
        array.get 203
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 203
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 208 1
  )
  (func (;23;) (type 59) (param eqref) (result eqref)
    (local (ref 208))
    local.get 0
    ref.cast (ref 208)
    local.set 1
    local.get 1
    struct.get 208 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 208 2
    local.get 1
    struct.get 208 0
    i32.const 0
    local.get 1
    struct.get 208 1
    struct.new 205
  )
  (func (;24;) (type 60) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 205)
    struct.get 205 2
  )
  (func (;25;) (type 61) (param eqref) (result i32)
    (local (ref 205) (ref 203) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 205)
    local.set 1
    local.get 1
    struct.get 205 0
    local.set 2
    local.get 1
    struct.get 205 1
    local.set 4
    local.get 1
    struct.get 205 2
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
        array.get 203
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
      array.get 203
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
        array.get 203
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
        array.get 203
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
        array.get 203
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
        array.get 203
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
        array.get 203
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
        array.get 203
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
  (func (;26;) (type 62) (param eqref eqref) (result i32)
    (local (ref 205) (ref 205) (ref 203) (ref 203) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 205)
    local.set 2
    local.get 1
    ref.cast (ref 205)
    local.set 3
    local.get 2
    struct.get 205 2
    local.tee 6
    local.get 3
    struct.get 205 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 205 0
    local.set 4
    local.get 3
    struct.get 205 0
    local.set 5
    local.get 2
    struct.get 205 1
    local.set 7
    local.get 3
    struct.get 205 1
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
          array.get 203
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 203
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
          array.get 203
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
          array.get 203
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 203
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
          array.get 203
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
      array.get 203
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
      array.get 203
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
  (func (;27;) (type 63) (param eqref i32) (result i32)
    (local (ref 205) (ref 203) i32)
    local.get 0
    ref.cast (ref 205)
    local.set 2
    local.get 1
    local.get 2
    struct.get 205 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 205 0
    local.set 3
    local.get 2
    struct.get 205 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 203
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;28;) (type 64) (param eqref i32 i32) (result eqref)
    (local (ref 205) i32)
    local.get 0
    ref.cast (ref 205)
    local.set 3
    local.get 3
    struct.get 205 2
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
    struct.get 205 0
    local.get 3
    struct.get 205 1
    local.get 1
    i32.add
    local.get 2
    struct.new 205
  )
  (func (;29;) (type 65) (result eqref)
    call 20
  )
  (func (;30;) (type 66) (param i32) (result eqref)
    local.get 0
    call 21
  )
  (func (;31;) (type 67) (param eqref eqref)
    local.get 0
    local.get 1
    call 22
  )
  (func (;32;) (type 68) (param eqref) (result eqref)
    local.get 0
    call 23
  )
  (func (;33;) (type 69) (param eqref) (result i32)
    local.get 0
    call 24
  )
  (func (;34;) (type 70) (param eqref) (result i32)
    local.get 0
    call 25
  )
  (func (;35;) (type 71) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 26
  )
  (func (;36;) (type 72) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 27
  )
  (func (;37;) (type 73) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 28
  )
  (func (;38;) (type 80) (param eqref) (result (ref 76))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 76
    ref.cast (ref 76)
  )
  (func (;39;) (type 81) (param (ref 76) i32) (result (ref 12))
    (local i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 76)
    struct.get 76 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.set 2
    local.get 0
    ref.cast (ref 76)
    struct.get 76 0
    call 33
    local.set 3
    local.get 2
    local.get 3
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 2
      struct.new 74
      struct.new 16
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
        array.new_fixed 203 0
        i32.const 0
        i32.const 0
        struct.new 205
        struct.new 13
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
        ref.cast (ref 76)
        struct.get 76 1
        ref.cast (ref 0)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 0
        i32.const 0
        local.get 0
        ref.cast (ref 76)
        struct.get 76 0
        local.get 2
        local.get 5
        call 37
        struct.new 13
      end
    end
    ref.cast (ref 12)
  )
  (func (;40;) (type 82) (result (ref 77))
    i32.const 0
    call 41
    ref.cast (ref 77)
  )
  (func (;41;) (type 83) (param i32) (result (ref 77))
    (local eqref i32)
    local.get 0
    call 30
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    ref.cast (ref 0)
    struct.new 77
    ref.cast (ref 77)
  )
  (func (;42;) (type 84) (param (ref 77)) (result i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 1
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
  (func (;43;) (type 85) (param (ref 77)) (result i32)
    local.get 0
    ref.cast (ref 77)
    struct.get 77 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
  )
  (func (;44;) (type 86) (param (ref 77)) (result (ref 12))
    local.get 0
    call 43
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 3
      struct.new 74
      struct.new 16
    else
      local.get 0
      ref.cast (ref 77)
      struct.get 77 1
      ref.cast (ref 0)
      i32.const 0
      i32.const 1
      array.set 0
      i32.const 0
      local.get 0
      ref.cast (ref 77)
      struct.get 77 0
      call 32
      struct.new 13
    end
    ref.cast (ref 12)
  )
  (func (;45;) (type 87) (param (ref 77) eqref) (result (ref 12))
    (local i32 i32)
    local.get 0
    call 43
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 3
      struct.new 74
      struct.new 16
    else
      local.get 1
      call 33
      local.set 2
      local.get 0
      call 42
      local.set 3
      local.get 2
      i32.const -1
      local.get 3
      i32.sub
      i32.gt_u
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 4
        struct.new 74
        struct.new 16
      else
        local.get 0
        ref.cast (ref 77)
        struct.get 77 0
        local.get 1
        call 31
        local.get 0
        ref.cast (ref 77)
        struct.get 77 1
        ref.cast (ref 0)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 0
        i32.const 0
        local.get 2
        struct.new 14
      end
    end
    ref.cast (ref 12)
  )
  (func (;46;) (type 88) (param eqref i32 i32) (result (ref 12))
    (local eqref i32 eqref i32 (ref 74) eqref i32 eqref)
    local.get 1
    i32.const 0
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 1
      struct.new 74
      struct.new 16
    else
      call 29
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
              ref.cast (ref 76)
              local.get 1
              call 39
              local.set 8
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 8
                      ref.cast (ref 12)
                      struct.get 12 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 8
                    ref.cast (ref 13)
                    struct.get 13 1
                    local.set 5
                    local.get 5
                    call 33
                    local.set 6
                    local.get 6
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 0
                      local.get 3
                      call 32
                      struct.new 13
                      local.set 10
                      br 7 (;@2;)
                    else
                      local.get 6
                      local.get 1
                      i32.gt_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 2
                        struct.new 74
                        struct.new 16
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
                          i32.const 4
                          struct.new 74
                          struct.new 16
                          local.set 10
                          br 9 (;@2;)
                        else
                          local.get 3
                          local.get 5
                          call 31
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
                  ref.cast (ref 16)
                  struct.get 16 1
                  ref.cast (ref 74)
                  local.set 7
                  i32.const 1
                  local.get 7
                  struct.new 16
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
    ref.cast (ref 12)
  )
  (func (;47;) (type 89) (param eqref eqref) (result (ref 12))
    (local i32 i32 eqref i32 (ref 74) eqref i32 eqref)
    local.get 1
    call 33
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
              call 37
              local.set 4
              local.get 0
              ref.cast (ref 77)
              local.get 4
              call 45
              local.set 7
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 7
                      ref.cast (ref 12)
                      struct.get 12 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 1
                    local.set 5
                    local.get 5
                    i32.const 0
                    i32.eq
                    if ;; label = @9
                      i32.const 1
                      i32.const 1
                      struct.new 74
                      struct.new 16
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
                        i32.const 2
                        struct.new 74
                        struct.new 16
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
                  ref.cast (ref 16)
                  struct.get 16 1
                  ref.cast (ref 74)
                  local.set 6
                  i32.const 1
                  local.get 6
                  struct.new 16
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
            struct.new 14
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
    ref.cast (ref 12)
  )
  (func (;48;) (type 90) (param i64) (result i64)
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
  (func (;49;) (type 91) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 48
    i64.or
  )
  (func (;50;) (type 92) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 48
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;51;) (type 93) (param eqref) (result i64)
    local.get 0
    call 7
  )
  (func (;52;) (type 94) (param eqref) (result i32)
    local.get 0
    call 4
  )
  (func (;53;) (type 95) (param eqref) (result eqref)
    local.get 0
    call 5
  )
  (func (;54;) (type 96) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 6
  )
  (func (;55;) (type 97) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;56;) (type 98) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 9
  )
  (func (;57;) (type 99) (param eqref) (result i32)
    local.get 0
    call 10
  )
  (func (;58;) (type 100) (param eqref) (result eqref)
    local.get 0
    call 11
  )
  (func (;59;) (type 101) (param eqref) (result eqref)
    (local eqref)
    local.get 0
    call 57
    call 13
    local.set 1
    local.get 1
    local.get 0
    call 16
    local.get 1
    call 19
  )
  (func (;60;) (type 102) (result eqref)
    call 12
  )
  (func (;61;) (type 103) (param eqref) (result i32)
    local.get 0
    call 14
  )
  (func (;62;) (type 104) (param eqref eqref)
    local.get 0
    local.get 1
    call 15
  )
  (func (;63;) (type 105) (param eqref eqref)
    local.get 0
    local.get 1
    call 16
  )
  (func (;64;) (type 106) (param eqref i32)
    local.get 0
    local.get 1
    call 17
  )
  (func (;65;) (type 107) (param eqref i32)
    local.get 0
    local.get 1
    call 18
  )
  (func (;66;) (type 108) (param eqref) (result eqref)
    local.get 0
    call 19
  )
  (func (;67;) (type 135) (param eqref) (result eqref)
    (local (ref 205))
    local.get 0
    ref.cast (ref 205)
    local.tee 1
    struct.get 205 0
    local.get 1
    struct.get 205 1
    local.get 1
    struct.get 205 2
    struct.new 204
  )
  (func (;68;) (type 136))
  (func (;69;) (type 137) (result (ref 120))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 120
    ref.cast (ref 120)
  )
  (func (;70;) (type 138) (param (ref 133)) (result i32)
    local.get 0
    ref.cast (ref 133)
    struct.get 133 2
    ref.cast (ref 0)
    i32.const 0
    array.get 0
  )
  (func (;71;) (type 139) (param (ref 133) i32)
    local.get 0
    ref.cast (ref 133)
    struct.get 133 2
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    array.set 0
  )
  (func (;72;) (type 140) (param (ref 133)) (result i32)
    local.get 0
    ref.cast (ref 133)
    struct.get 133 2
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
  (func (;73;) (type 141) (param (ref 133) i32)
    local.get 0
    ref.cast (ref 133)
    struct.get 133 2
    ref.cast (ref 0)
    i32.const 1
    local.get 1
    array.set 0
  )
  (func (;74;) (type 142) (param i32) (result i32)
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
  (func (;75;) (type 143) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;76;) (type 144) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 33
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
              call 2
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
              call 36
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
  (func (;77;) (type 145) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 52
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
              call 3
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
              call 55
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
  (func (;78;) (type 146) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 33
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
              call 2
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
              call 36
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
  (func (;79;) (type 147) (param i32) (result i32)
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
  (func (;80;) (type 148) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 33
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
              call 2
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
              call 36
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
  (func (;81;) (type 149) (param (ref 133))
    local.get 0
    local.get 0
    ref.cast (ref 133)
    struct.get 133 0
    local.get 0
    call 70
    call 76
    call 71
  )
  (func (;82;) (type 150) (param i32) (result i32)
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
  (func (;83;) (type 151) (param i32) (result i32)
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
  (func (;84;) (type 152) (param eqref i32 i32) (result i32)
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
              call 36
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
  (func (;85;) (type 153) (param eqref i32 i32) (result (ref 9))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 9
    else
      local.get 0
      local.get 1
      call 36
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
          call 36
          call 82
        else
          i32.const 0
        end
        if (result eqref) ;; label = @3
          i32.const 0
          struct.new 9
        else
          i32.const 1
          local.get 1
          i32.const 1
          i32.add
          struct.new 10
        end
      else
        local.get 0
        local.get 1
        call 36
        call 83
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 84
          struct.new 10
        else
          i32.const 0
          struct.new 9
        end
      end
    end
    ref.cast (ref 9)
  )
  (func (;86;) (type 154) (param eqref i32 i32) (result (ref 9))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 36
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
        call 36
        call 82
        i32.const 0
        call 1
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 9
      else
        i32.const 1
        local.get 0
        local.get 3
        i32.const 1
        i32.add
        local.get 2
        call 84
        struct.new 10
      end
    else
      i32.const 1
      local.get 1
      struct.new 10
    end
    ref.cast (ref 9)
  )
  (func (;87;) (type 155) (param eqref i32 i32) (result (ref 9))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 36
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 36
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
        call 36
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 36
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
        call 36
        call 82
        i32.const 0
        call 1
      end
      if (result eqref) ;; label = @2
        i32.const 0
        struct.new 9
      else
        i32.const 1
        local.get 0
        local.get 4
        i32.const 1
        i32.add
        local.get 2
        call 84
        struct.new 10
      end
    else
      i32.const 1
      local.get 1
      struct.new 10
    end
    ref.cast (ref 9)
  )
  (func (;88;) (type 156) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 36
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
              ref.cast (ref 9)
              struct.get 9 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            i32.const 0
            local.set 12
            br 2 (;@2;)
          end
          local.get 11
          ref.cast (ref 10)
          struct.get 10 1
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
                  ref.cast (ref 9)
                  struct.get 9 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                i32.const 0
                local.set 10
                br 2 (;@4;)
              end
              local.get 9
              ref.cast (ref 10)
              struct.get 10 1
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
                      ref.cast (ref 9)
                      struct.get 9 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    i32.const 0
                    local.set 8
                    br 2 (;@6;)
                  end
                  local.get 7
                  ref.cast (ref 10)
                  struct.get 10 1
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
  (func (;89;) (type 157) (param i32) (result i32)
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
  (func (;90;) (type 158) (param eqref i32) (result (ref 9))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 33
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 33
      local.get 1
      i32.sub
      i32.const 4
      i32.lt_u
    end
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 9
    else
      local.get 0
      local.get 1
      call 36
      call 89
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 36
      call 89
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 36
      call 89
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 36
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
        struct.new 9
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
        struct.new 10
      end
    end
    ref.cast (ref 9)
  )
  (func (;91;) (type 159) (param (ref 133) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 61
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      ref.cast (ref 133)
      struct.get 133 3
      struct.get 120 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      ref.cast (ref 133)
      struct.get 133 3
      struct.get 120 3
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
        ref.cast (ref 133)
        struct.get 133 1
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 56
        call 63
      else
      end
      i32.const 1
    end
  )
  (func (;92;) (type 160) (param (ref 133)) (result (ref 12))
    (local i32 i32 i32 i32 i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 70
    local.set 1
    local.get 0
    ref.cast (ref 133)
    struct.get 133 0
    call 33
    local.set 2
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 5
      local.get 1
      struct.new 122
      struct.new 16
    else
      local.get 0
      ref.cast (ref 133)
      struct.get 133 0
      local.get 1
      call 36
      i32.const 34
      i32.ne
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 6
        local.get 1
        local.get 0
        ref.cast (ref 133)
        struct.get 133 0
        local.get 1
        call 36
        struct.new 123
        struct.new 16
      else
        local.get 1
        i32.const 1
        i32.add
        local.set 3
        local.get 0
        ref.cast (ref 133)
        struct.get 133 1
        local.get 3
        call 77
        local.set 4
        local.get 4
        local.get 2
        i32.ge_u
        if (result eqref) ;; label = @3
          i32.const 1
          i32.const 5
          local.get 2
          struct.new 122
          struct.new 16
        else
          local.get 0
          ref.cast (ref 133)
          struct.get 133 0
          local.get 4
          call 36
          i32.const 34
          i32.eq
          if (result eqref) ;; label = @4
            local.get 4
            local.get 3
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            ref.cast (ref 133)
            struct.get 133 3
            struct.get 120 3
            i32.gt_u
            if (result eqref) ;; label = @5
              i32.const 1
              i32.const 3
              local.get 4
              struct.new 122
              struct.new 16
            else
              local.get 0
              local.get 4
              i32.const 1
              i32.add
              call 71
              local.get 0
              ref.cast (ref 133)
              struct.get 133 1
              local.get 3
              local.get 5
              call 56
              local.set 6
              local.get 0
              ref.cast (ref 133)
              struct.get 133 4
              if (result eqref) ;; label = @6
                i32.const 0
                local.get 6
                call 59
                i32.const 0
                struct.new 119
                struct.new 13
              else
                i32.const 0
                local.get 6
                call 58
                i32.const 0
                struct.new 119
                struct.new 13
              end
            end
          else
            local.get 0
            ref.cast (ref 133)
            struct.get 133 0
            local.get 4
            call 36
            i32.const 32
            i32.lt_u
            if (result eqref) ;; label = @5
              i32.const 1
              i32.const 9
              local.get 4
              struct.new 122
              struct.new 16
            else
              call 60
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
                      ref.cast (ref 133)
                      struct.get 133 1
                      local.get 9
                      call 77
                      local.set 10
                      local.get 10
                      local.get 2
                      i32.ge_u
                      if ;; label = @10
                        i32.const 1
                        i32.const 5
                        local.get 2
                        struct.new 122
                        struct.new 16
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
                        i32.const 3
                        local.get 10
                        struct.new 122
                        struct.new 16
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      ref.cast (ref 133)
                      struct.get 133 0
                      local.get 10
                      call 36
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
                        local.get 7
                        call 66
                        i32.const 1
                        struct.new 119
                        struct.new 13
                        local.set 19
                        br 4 (;@6;)
                      else
                        local.get 11
                        i32.const 32
                        i32.lt_u
                        if ;; label = @11
                          i32.const 1
                          i32.const 9
                          local.get 10
                          struct.new 122
                          struct.new 16
                          local.set 19
                          br 5 (;@6;)
                        else
                          local.get 11
                          i32.const 92
                          i32.ne
                          if ;; label = @12
                            i32.const 1
                            i32.const 6
                            local.get 10
                            local.get 11
                            struct.new 123
                            struct.new 16
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
                              i32.const 5
                              local.get 2
                              struct.new 122
                              struct.new 16
                              local.set 19
                              br 7 (;@6;)
                            else
                              local.get 0
                              ref.cast (ref 133)
                              struct.get 133 0
                              local.get 10
                              i32.const 1
                              i32.add
                              call 36
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
                                call 64
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
                                  call 64
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
                                    call 64
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
                                      call 64
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
                                        call 64
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
                                          call 64
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
                                            ref.cast (ref 133)
                                            struct.get 133 0
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
                                                    ref.cast (ref 9)
                                                    struct.get 9 0
                                                    br_table 0 (;@24;) 1 (;@23;) 2 (;@22;)
                                                  end
                                                  i32.const 1
                                                  i32.const 10
                                                  local.get 10
                                                  struct.new 122
                                                  struct.new 16
                                                  local.set 19
                                                  br 17 (;@6;)
                                                  br 2 (;@21;)
                                                end
                                                local.get 17
                                                ref.cast (ref 10)
                                                struct.get 10 1
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
                                                    ref.cast (ref 133)
                                                    struct.get 133 0
                                                    local.get 14
                                                    call 36
                                                    i32.const 92
                                                    i32.ne
                                                  end
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    ref.cast (ref 133)
                                                    struct.get 133 0
                                                    local.get 14
                                                    i32.const 1
                                                    i32.add
                                                    call 36
                                                    i32.const 117
                                                    i32.ne
                                                  end
                                                  if ;; label = @24
                                                    i32.const 1
                                                    i32.const 10
                                                    local.get 10
                                                    struct.new 122
                                                    struct.new 16
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                  end
                                                  local.get 0
                                                  ref.cast (ref 133)
                                                  struct.get 133 0
                                                  local.get 14
                                                  i32.const 2
                                                  i32.add
                                                  call 90
                                                  local.set 16
                                                  block ;; label = @24
                                                    local.get 16
                                                    ref.cast (ref 9)
                                                    struct.get 9 0
                                                    i32.const 1
                                                    i32.eq
                                                    if ;; label = @25
                                                      local.get 16
                                                      ref.cast (ref 10)
                                                      struct.get 10 1
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
                                                        call 65
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
                                                      i32.const 10
                                                      local.get 10
                                                      struct.new 122
                                                      struct.new 16
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
                                                    i32.const 10
                                                    local.get 10
                                                    struct.new 122
                                                    struct.new 16
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                    local.get 7
                                                    local.get 13
                                                    call 65
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
                                            i32.const 9
                                            local.get 10
                                            struct.new 122
                                            struct.new 16
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
                              call 61
                              local.get 0
                              ref.cast (ref 133)
                              struct.get 133 3
                              struct.get 120 3
                              i32.gt_u
                              if ;; label = @14
                                i32.const 1
                                i32.const 3
                                local.get 10
                                struct.new 122
                                struct.new 16
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
    ref.cast (ref 12)
  )
  (func (;93;) (type 161) (param (ref 133)) (result (ref 12))
    (local (ref 119) (ref 121) eqref eqref)
    local.get 0
    call 92
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 12)
            struct.get 12 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 13)
          struct.get 13 1
          ref.cast (ref 119)
          local.set 1
          i32.const 0
          local.get 1
          ref.cast (ref 119)
          struct.get 119 0
          struct.new 13
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 16)
        struct.get 16 1
        ref.cast (ref 121)
        local.set 2
        i32.const 1
        local.get 2
        struct.new 16
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
  )
  (func (;94;) (type 162) (param (ref 133) eqref (ref 109)) (result (ref 12))
    (local i32 i32)
    local.get 0
    call 70
    local.set 3
    local.get 0
    ref.cast (ref 133)
    struct.get 133 0
    call 33
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 33
      local.get 4
      local.get 3
      i32.sub
      i32.gt_u
    end
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 5
      local.get 4
      struct.new 122
      struct.new 16
    else
      local.get 0
      ref.cast (ref 133)
      struct.get 133 0
      local.get 3
      local.get 1
      call 33
      call 37
      local.get 1
      call 35
      i32.const 0
      call 1
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 7
        local.get 3
        struct.new 122
        struct.new 16
      else
        local.get 0
        local.get 3
        local.get 1
        call 33
        i32.add
        call 71
        i32.const 0
        local.get 2
        struct.new 13
      end
    end
    ref.cast (ref 12)
  )
  (func (;95;) (type 163) (param (ref 133)) (result (ref 12))
    (local i32 i32 eqref)
    local.get 0
    call 70
    local.set 1
    local.get 0
    ref.cast (ref 133)
    struct.get 133 0
    local.get 1
    call 80
    local.set 2
    local.get 0
    ref.cast (ref 133)
    struct.get 133 0
    local.get 1
    local.get 2
    call 88
    i32.const 0
    call 1
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 8
      local.get 1
      struct.new 122
      struct.new 16
    else
      local.get 0
      local.get 2
      call 71
      local.get 0
      ref.cast (ref 133)
      struct.get 133 1
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 56
      local.set 3
      local.get 0
      ref.cast (ref 133)
      struct.get 133 4
      if (result eqref) ;; label = @2
        i32.const 0
        local.get 3
        call 59
        struct.new 13
      else
        i32.const 0
        local.get 3
        call 58
        struct.new 13
      end
    end
    ref.cast (ref 12)
  )
  (func (;96;) (type 164) (param (ref 133)) (result (ref 12))
    (local eqref (ref 121) eqref eqref)
    local.get 0
    call 95
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 12)
            struct.get 12 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 13)
          struct.get 13 1
          local.set 1
          local.get 0
          ref.cast (ref 133)
          struct.get 133 5
          if (result eqref) ;; label = @4
            i32.const 0
            i32.const 3
            local.get 1
            struct.new 112
            ref.cast (ref 112)
            struct.new 113
            struct.new 13
          else
            i32.const 0
            i32.const 2
            local.get 1
            struct.new 111
            struct.new 13
          end
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 16)
        struct.get 16 1
        ref.cast (ref 121)
        local.set 2
        i32.const 1
        local.get 2
        struct.new 16
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 12)
  )
  (func (;97;) (type 165) (param (ref 133) i32) (result (ref 12))
    (local eqref (ref 121) (ref 109) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 19
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
    ref.cast (ref 133)
    struct.get 133 0
    call 33
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 133)
      struct.get 133 0
      local.get 0
      call 70
      call 36
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
      i32.const 6
      local.get 2
      ref.cast (ref 19)
      struct.new 116
      struct.new 13
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
              call 106
              local.set 11
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 11
                      ref.cast (ref 12)
                      struct.get 12 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 11
                    ref.cast (ref 13)
                    struct.get 13 1
                    ref.cast (ref 109)
                    local.set 4
                    local.get 2
                    local.get 4
                    local.set 10
                    local.set 7
                    local.get 7
                    ref.cast (ref 19)
                    struct.get 19 1
                    local.get 7
                    ref.cast (ref 19)
                    struct.get 19 2
                    i32.eq
                    if ;; label = @9
                      local.get 7
                      ref.cast (ref 19)
                      struct.get 19 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 7
                        ref.cast (ref 19)
                        struct.get 19 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 8
                      local.get 8
                      local.get 7
                      ref.cast (ref 19)
                      struct.get 19 2
                      i32.le_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 8
                      array.new_default 5
                      local.set 9
                      local.get 9
                      ref.cast (ref 5)
                      i32.const 0
                      local.get 7
                      ref.cast (ref 19)
                      struct.get 19 0
                      ref.cast (ref 5)
                      i32.const 0
                      local.get 7
                      ref.cast (ref 19)
                      struct.get 19 1
                      array.copy 5 5
                      local.get 7
                      ref.cast (ref 19)
                      local.get 9
                      struct.set 19 0
                      local.get 7
                      ref.cast (ref 19)
                      local.get 9
                      ref.cast (ref 5)
                      array.len
                      struct.set 19 2
                    end
                    local.get 7
                    ref.cast (ref 19)
                    struct.get 19 0
                    ref.cast (ref 5)
                    local.get 7
                    ref.cast (ref 19)
                    struct.get 19 1
                    local.get 10
                    array.set 5
                    local.get 7
                    ref.cast (ref 19)
                    local.get 7
                    ref.cast (ref 19)
                    struct.get 19 1
                    i32.const 1
                    i32.add
                    struct.set 19 1
                    br 2 (;@6;)
                  end
                  local.get 11
                  ref.cast (ref 16)
                  struct.get 16 1
                  ref.cast (ref 121)
                  local.set 3
                  i32.const 1
                  local.get 3
                  struct.new 16
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
              ref.cast (ref 133)
              struct.get 133 0
              call 33
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 5
                local.get 5
                struct.new 122
                struct.new 16
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              ref.cast (ref 133)
              struct.get 133 0
              local.get 5
              call 36
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
                i32.const 6
                local.get 2
                ref.cast (ref 19)
                struct.new 116
                struct.new 13
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
                  i32.const 6
                  local.get 5
                  local.get 6
                  struct.new 123
                  struct.new 16
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
    ref.cast (ref 12)
  )
  (func (;98;) (type 166) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 54
  )
  (func (;99;) (type 167) (param eqref) (result i64)
    local.get 0
    call 51
  )
  (func (;100;) (type 168) (param (ref 19) i32 eqref) (result i32)
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
              ref.cast (ref 19)
              struct.get 19 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 19)
              struct.get 19 0
              ref.cast (ref 5)
              local.get 5
              array.get 5
              ref.cast (ref 118)
              struct.get 118 0
              local.get 2
              call 98
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
  (func (;101;) (type 169) (param (ref 19) eqref) (result i32)
    local.get 0
    ref.cast (ref 19)
    local.get 0
    ref.cast (ref 19)
    struct.get 19 1
    local.get 1
    call 100
  )
  (func (;102;) (type 170) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;103;) (type 171) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 102
  )
  (func (;104;) (type 172) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 50
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 50
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 50
        else
          local.get 3
          local.get 5
          call 50
        end
      end
    end
  )
  (func (;105;) (type 173) (param (ref 133) i32) (result (ref 12))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 121) eqref i32 i32 i64 i32 (ref 118) i64 i32 i32 i32 i32 (ref 109) (ref 121) (ref 109) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 19
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
    ref.cast (ref 133)
    struct.get 133 0
    call 33
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      ref.cast (ref 133)
      struct.get 133 0
      local.get 0
      call 70
      call 36
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
      i32.const 7
      local.get 2
      ref.cast (ref 19)
      struct.new 117
      struct.new 13
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
              ref.cast (ref 133)
              struct.get 133 0
              call 33
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 5
                local.get 7
                struct.new 122
                struct.new 16
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              ref.cast (ref 133)
              struct.get 133 0
              local.get 7
              call 36
              i32.const 34
              i32.ne
              if ;; label = @6
                i32.const 1
                i32.const 6
                local.get 7
                local.get 0
                ref.cast (ref 133)
                struct.get 133 0
                local.get 7
                call 36
                struct.new 123
                struct.new 16
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 93
              local.set 26
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 26
                      ref.cast (ref 12)
                      struct.get 12 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 26
                    ref.cast (ref 13)
                    struct.get 13 1
                    local.set 8
                    local.get 8
                    local.set 27
                    br 2 (;@6;)
                  end
                  local.get 26
                  ref.cast (ref 16)
                  struct.get 16 1
                  ref.cast (ref 121)
                  local.set 9
                  i32.const 1
                  local.get 9
                  struct.new 16
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
              ref.cast (ref 19)
              struct.get 19 1
              local.set 11
              local.get 11
              i32.const 16
              i32.ge_u
              local.set 12
              local.get 12
              if (result i64) ;; label = @6
                local.get 10
                call 51
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
                          ref.cast (ref 19)
                          struct.get 19 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 28
                          ref.cast (ref 19)
                          struct.get 19 0
                          ref.cast (ref 5)
                          local.get 29
                          array.get 5
                          ref.cast (ref 118)
                          ref.cast (ref 118)
                          local.set 15
                          local.get 15
                          ref.cast (ref 118)
                          struct.get 118 0
                          call 99
                          local.set 16
                          local.get 16
                          call 103
                          local.set 17
                          local.get 17
                          i32.const 0
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            local.get 16
                            call 49
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 49
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 49
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 49
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
                call 103
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
                call 104
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 19)
                  local.get 10
                  call 101
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 19)
                local.get 10
                call 101
              end
              local.set 19
              local.get 19
              if ;; label = @6
                i32.const 1
                i32.const 11
                local.get 7
                local.get 10
                struct.new 124
                struct.new 16
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
                  call 49
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
                    call 49
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
                      call 49
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 49
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
              ref.cast (ref 133)
              struct.get 133 0
              call 33
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 5
                local.get 20
                struct.new 122
                struct.new 16
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              ref.cast (ref 133)
              struct.get 133 0
              local.get 20
              call 36
              i32.const 58
              i32.ne
              if ;; label = @6
                i32.const 1
                i32.const 6
                local.get 20
                local.get 0
                ref.cast (ref 133)
                struct.get 133 0
                local.get 20
                call 36
                struct.new 123
                struct.new 16
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
              call 106
              local.set 32
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 32
                      ref.cast (ref 12)
                      struct.get 12 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 32
                    ref.cast (ref 13)
                    struct.get 13 1
                    ref.cast (ref 109)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 16)
                  struct.get 16 1
                  ref.cast (ref 121)
                  local.set 22
                  i32.const 1
                  local.get 22
                  struct.new 16
                  local.set 36
                  br 5 (;@2;)
                  local.set 33
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 33
              ref.cast (ref 109)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 109)
              struct.new 118
              local.set 34
              local.set 28
              local.get 28
              ref.cast (ref 19)
              struct.get 19 1
              local.get 28
              ref.cast (ref 19)
              struct.get 19 2
              i32.eq
              if ;; label = @6
                local.get 28
                ref.cast (ref 19)
                struct.get 19 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 28
                  ref.cast (ref 19)
                  struct.get 19 2
                  i32.const 2
                  i32.mul
                end
                local.set 29
                local.get 29
                local.get 28
                ref.cast (ref 19)
                struct.get 19 2
                i32.le_u
                if ;; label = @7
                  unreachable
                end
                local.get 29
                array.new_default 5
                local.set 30
                local.get 30
                ref.cast (ref 5)
                i32.const 0
                local.get 28
                ref.cast (ref 19)
                struct.get 19 0
                ref.cast (ref 5)
                i32.const 0
                local.get 28
                ref.cast (ref 19)
                struct.get 19 1
                array.copy 5 5
                local.get 28
                ref.cast (ref 19)
                local.get 30
                struct.set 19 0
                local.get 28
                ref.cast (ref 19)
                local.get 30
                ref.cast (ref 5)
                array.len
                struct.set 19 2
              end
              local.get 28
              ref.cast (ref 19)
              struct.get 19 0
              ref.cast (ref 5)
              local.get 28
              ref.cast (ref 19)
              struct.get 19 1
              local.get 34
              array.set 5
              local.get 28
              ref.cast (ref 19)
              local.get 28
              ref.cast (ref 19)
              struct.get 19 1
              i32.const 1
              i32.add
              struct.set 19 1
              local.get 0
              call 81
              local.get 0
              call 70
              local.set 24
              local.get 24
              local.get 0
              ref.cast (ref 133)
              struct.get 133 0
              call 33
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 5
                local.get 24
                struct.new 122
                struct.new 16
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              ref.cast (ref 133)
              struct.get 133 0
              local.get 24
              call 36
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
                i32.const 7
                local.get 2
                ref.cast (ref 19)
                struct.new 117
                struct.new 13
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
                  i32.const 6
                  local.get 24
                  local.get 25
                  struct.new 123
                  struct.new 16
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
    ref.cast (ref 12)
  )
  (func (;106;) (type 174) (param (ref 133) i32) (result (ref 12))
    (local i32 i32 (ref 119) (ref 121) eqref eqref)
    local.get 1
    local.get 0
    ref.cast (ref 133)
    struct.get 133 3
    struct.get 120 1
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 1
      local.get 1
      struct.new 122
      struct.new 16
    else
      local.get 0
      call 72
      local.get 0
      ref.cast (ref 133)
      struct.get 133 3
      struct.get 120 2
      i32.ge_u
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 2
        local.get 0
        call 70
        struct.new 122
        struct.new 16
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
        ref.cast (ref 133)
        struct.get 133 0
        call 33
        i32.ge_u
        if (result eqref) ;; label = @3
          i32.const 1
          i32.const 5
          local.get 2
          struct.new 122
          struct.new 16
        else
          local.get 0
          ref.cast (ref 133)
          struct.get 133 0
          local.get 2
          call 36
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 203 1
            i32.const 0
            i32.const 4
            struct.new 205
            i32.const 0
            struct.new 109
            call 94
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 203 1
              i32.const 0
              i32.const 4
              struct.new 205
              i32.const 1
              i32.const 1
              struct.new 110
              call 94
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 203 1
                i32.const 0
                i32.const 5
                struct.new 205
                i32.const 1
                i32.const 0
                struct.new 110
                call 94
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
                          ref.cast (ref 12)
                          struct.get 12 0
                          br_table 0 (;@11;) 1 (;@10;) 2 (;@9;)
                        end
                        local.get 6
                        ref.cast (ref 13)
                        struct.get 13 1
                        ref.cast (ref 119)
                        local.set 4
                        local.get 0
                        ref.cast (ref 133)
                        struct.get 133 6
                        if (result eqref) ;; label = @11
                          i32.const 0
                          i32.const 5
                          local.get 4
                          ref.cast (ref 119)
                          struct.get 119 0
                          local.get 4
                          ref.cast (ref 119)
                          struct.get 119 1
                          struct.new 114
                          ref.cast (ref 114)
                          struct.new 115
                          struct.new 13
                        else
                          i32.const 0
                          i32.const 4
                          local.get 4
                          ref.cast (ref 119)
                          struct.get 119 0
                          struct.new 111
                          struct.new 13
                        end
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 16)
                      struct.get 16 1
                      ref.cast (ref 121)
                      local.set 5
                      i32.const 1
                      local.get 5
                      struct.new 16
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
                    call 97
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 105
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
                        call 96
                      else
                        i32.const 1
                        i32.const 6
                        local.get 2
                        local.get 3
                        struct.new 123
                        struct.new 16
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
    ref.cast (ref 12)
  )
  (func (;107;) (type 175) (param eqref (ref 120) i32 i32 i32) (result (ref 12))
    (local i32 (ref 133) (ref 121) (ref 109) eqref i32 eqref eqref)
    local.get 0
    call 52
    local.set 5
    local.get 5
    local.get 1
    ref.cast (ref 120)
    struct.get 120 0
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      local.get 5
      struct.new 122
      struct.new 16
    else
      local.get 0
      call 53
      local.get 0
      i32.const 2
      local.set 10
      i32.const 0
      local.get 10
      array.new 0
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 120)
      local.get 2
      local.get 3
      local.get 4
      struct.new 133
      local.set 6
      local.get 6
      i32.const 0
      call 106
      local.set 11
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 11
              ref.cast (ref 12)
              struct.get 12 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            local.get 11
            ref.cast (ref 13)
            struct.get 13 1
            ref.cast (ref 109)
            local.set 8
            local.get 6
            call 81
            local.get 6
            call 70
            local.get 5
            i32.eq
            if (result eqref) ;; label = @5
              i32.const 0
              local.get 8
              struct.new 13
            else
              i32.const 1
              i32.const 12
              local.get 6
              call 70
              struct.new 122
              struct.new 16
            end
            local.set 12
            br 2 (;@2;)
          end
          local.get 11
          ref.cast (ref 16)
          struct.get 16 1
          ref.cast (ref 121)
          local.set 7
          i32.const 1
          local.get 7
          struct.new 16
          local.set 12
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 12
    end
    ref.cast (ref 12)
  )
  (func (;108;) (type 176) (param eqref (ref 120)) (result (ref 12))
    (local i32)
    local.get 0
    call 33
    local.set 2
    local.get 2
    local.get 1
    ref.cast (ref 120)
    struct.get 120 0
    i32.gt_u
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      local.get 2
      struct.new 122
      struct.new 16
    else
      local.get 0
      call 34
      i32.const 0
      call 1
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 4
        struct.new 121
        struct.new 16
      else
        local.get 0
        call 67
        local.get 1
        i32.const 1
        i32.const 0
        i32.const 0
        call 107
      end
    end
    ref.cast (ref 12)
  )
  (func (;109;) (type 179) (param (ref 134) i32)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      ref.cast (ref 134)
      struct.get 134 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      array.set 0
    else
    end
  )
  (func (;110;) (type 180) (param (ref 134) i32 eqref)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      ref.cast (ref 134)
      struct.get 134 4
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      array.set 5
      local.get 0
      ref.cast (ref 134)
      struct.get 134 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      array.set 0
    else
    end
  )
  (func (;111;) (type 181) (param (ref 134) i32)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      ref.cast (ref 134)
      struct.get 134 0
      call 61
      local.get 0
      ref.cast (ref 134)
      struct.get 134 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 109
      else
        local.get 0
        ref.cast (ref 134)
        struct.get 134 0
        local.get 1
        call 64
      end
    end
  )
  (func (;112;) (type 182) (param (ref 134) eqref)
    (local i32 i32)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 0
    call 61
    local.set 2
    local.get 1
    call 52
    local.set 3
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      ref.cast (ref 134)
      struct.get 134 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        ref.cast (ref 134)
        struct.get 134 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 109
      else
        local.get 0
        ref.cast (ref 134)
        struct.get 134 0
        local.get 1
        call 62
      end
    end
  )
  (func (;113;) (type 183) (param (ref 134) eqref)
    (local i32 i32)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 0
    call 61
    local.set 2
    local.get 1
    call 57
    local.set 3
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      ref.cast (ref 134)
      struct.get 134 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        ref.cast (ref 134)
        struct.get 134 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 109
      else
        local.get 0
        ref.cast (ref 134)
        struct.get 134 0
        local.get 1
        call 63
      end
    end
  )
  (func (;114;) (type 184) (param i32) (result i32)
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
  (func (;115;) (type 185) (param (ref 134) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 34
    call 111
    local.get 1
    call 53
    local.set 2
    local.get 2
    call 33
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
              ref.cast (ref 134)
              struct.get 134 3
              ref.cast (ref 0)
              i32.const 0
              array.get 0
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
                call 56
                call 113
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
                call 36
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
                  call 111
                  local.get 0
                  local.get 7
                  call 111
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
                    call 111
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
                    call 111
                  else
                    local.get 0
                    i32.const 92
                    call 111
                    local.get 0
                    i32.const 117
                    call 111
                    local.get 0
                    i32.const 48
                    call 111
                    local.get 0
                    i32.const 48
                    call 111
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 114
                    call 111
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 114
                    call 111
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
    call 111
  )
  (func (;116;) (type 186) (param (ref 134) (ref 114))
    local.get 1
    ref.cast (ref 114)
    struct.get 114 1
    if ;; label = @1
      local.get 0
      local.get 1
      ref.cast (ref 114)
      struct.get 114 0
      call 115
    else
      local.get 0
      i32.const 34
      call 111
      local.get 0
      local.get 1
      ref.cast (ref 114)
      struct.get 114 0
      call 112
      local.get 0
      i32.const 34
      call 111
    end
  )
  (func (;117;) (type 187) (param (ref 134) (ref 109) i32)
    (local i32 eqref eqref (ref 112) eqref (ref 114) eqref i32 i32 eqref i64 i64 i64 i64 i32 i32 i32 (ref 118) i64 i32 i32 eqref i32 eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 134)
    struct.get 134 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
      call 68
    else
      local.get 2
      local.get 0
      ref.cast (ref 134)
      struct.get 134 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 109
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
                            ref.cast (ref 109)
                            struct.get 109 0
                            br_table 0 (;@12;) 1 (;@11;) 2 (;@10;) 3 (;@9;) 4 (;@8;) 5 (;@7;) 6 (;@6;) 7 (;@5;) 8 (;@4;)
                          end
                          local.get 0
                          v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                          array.new_fixed 203 1
                          i32.const 0
                          i32.const 4
                          struct.new 204
                          call 112
                          br 8 (;@3;)
                        end
                        local.get 29
                        ref.cast (ref 110)
                        struct.get 110 1
                        local.set 3
                        local.get 3
                        if ;; label = @11
                          local.get 0
                          v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                          array.new_fixed 203 1
                          i32.const 0
                          i32.const 4
                          struct.new 204
                          call 112
                        else
                          local.get 0
                          v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                          array.new_fixed 203 1
                          i32.const 0
                          i32.const 5
                          struct.new 204
                          call 112
                        end
                        br 7 (;@3;)
                      end
                      local.get 29
                      ref.cast (ref 111)
                      struct.get 111 1
                      local.set 4
                      local.get 4
                      call 53
                      local.set 5
                      local.get 5
                      i32.const 0
                      local.get 5
                      call 33
                      call 88
                      if ;; label = @10
                        local.get 0
                        local.get 4
                        call 112
                      else
                        local.get 0
                        i32.const 2
                        local.get 4
                        call 110
                      end
                      br 6 (;@3;)
                    end
                    local.get 29
                    ref.cast (ref 113)
                    struct.get 113 1
                    ref.cast (ref 112)
                    local.set 6
                    local.get 0
                    local.get 6
                    ref.cast (ref 112)
                    struct.get 112 0
                    call 112
                    br 5 (;@3;)
                  end
                  local.get 29
                  ref.cast (ref 111)
                  struct.get 111 1
                  local.set 7
                  local.get 0
                  local.get 7
                  call 115
                  br 4 (;@3;)
                end
                local.get 29
                ref.cast (ref 115)
                struct.get 115 1
                ref.cast (ref 114)
                local.set 8
                local.get 0
                local.get 8
                call 116
                br 3 (;@3;)
              end
              local.get 29
              ref.cast (ref 116)
              struct.get 116 1
              local.set 9
              local.get 0
              i32.const 91
              call 111
              local.get 9
              ref.cast (ref 19)
              struct.get 19 1
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
                        ref.cast (ref 134)
                        struct.get 134 3
                        ref.cast (ref 0)
                        i32.const 0
                        array.get 0
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
                          call 111
                        else
                        end
                        local.get 0
                        local.get 9
                        local.get 11
                        local.set 25
                        local.set 24
                        local.get 25
                        local.get 24
                        ref.cast (ref 19)
                        struct.get 19 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 24
                        ref.cast (ref 19)
                        struct.get 19 0
                        ref.cast (ref 5)
                        local.get 25
                        array.get 5
                        ref.cast (ref 109)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 117
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
              call 111
              br 2 (;@3;)
            end
            local.get 29
            ref.cast (ref 117)
            struct.get 117 1
            local.set 12
            local.get 0
            i32.const 123
            call 111
            i64.const 0
            local.set 13
            i64.const 0
            local.set 14
            i64.const 0
            local.set 15
            i64.const 0
            local.set 16
            local.get 12
            ref.cast (ref 19)
            struct.get 19 1
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
                      ref.cast (ref 134)
                      struct.get 134 3
                      ref.cast (ref 0)
                      i32.const 0
                      array.get 0
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
                      ref.cast (ref 19)
                      struct.get 19 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 24
                      ref.cast (ref 19)
                      struct.get 19 0
                      ref.cast (ref 5)
                      local.get 25
                      array.get 5
                      ref.cast (ref 118)
                      ref.cast (ref 118)
                      local.set 20
                      local.get 18
                      if (result i64) ;; label = @10
                        local.get 20
                        ref.cast (ref 118)
                        struct.get 118 0
                        call 99
                      else
                        i64.const 0
                      end
                      local.set 21
                      local.get 18
                      if (result i32) ;; label = @10
                        local.get 21
                        call 103
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
                        call 104
                        if (result i32) ;; label = @11
                          local.get 12
                          ref.cast (ref 19)
                          local.get 19
                          local.get 20
                          ref.cast (ref 118)
                          struct.get 118 0
                          call 100
                        else
                          i32.const 0
                        end
                      else
                        local.get 12
                        ref.cast (ref 19)
                        local.get 19
                        local.get 20
                        ref.cast (ref 118)
                        struct.get 118 0
                        call 100
                      end
                      local.set 23
                      local.get 23
                      if ;; label = @10
                        local.get 0
                        i32.const 4
                        local.get 20
                        ref.cast (ref 118)
                        struct.get 118 0
                        call 110
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
                          call 49
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
                            call 49
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
                              call 49
                              local.set 15
                            else
                              local.get 18
                              if ;; label = @14
                                local.get 16
                                local.get 21
                                call 49
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
                          call 111
                        else
                        end
                        local.get 0
                        local.get 20
                        ref.cast (ref 118)
                        struct.get 118 0
                        call 115
                        local.get 0
                        i32.const 58
                        call 111
                        local.get 0
                        local.get 20
                        ref.cast (ref 118)
                        struct.get 118 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 117
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
            call 111
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;118;) (type 188) (param (ref 109) i32 i32) (result (ref 12))
    (local eqref (ref 134) eqref i32)
    i32.const 1
    local.set 6
    i32.const 0
    local.get 6
    array.new 0
    local.set 3
    call 60
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 0)
    i32.const 1
    local.set 6
    array.new_fixed 203 0
    i32.const 0
    i32.const 0
    struct.new 204
    local.get 6
    array.new 5
    ref.cast (ref 5)
    struct.new 134
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 117
    local.get 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      struct.new 125
      struct.new 16
    else
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      array.get 0
      i32.const 2
      i32.eq
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 2
        local.get 4
        ref.cast (ref 134)
        struct.get 134 4
        ref.cast (ref 5)
        i32.const 0
        array.get 5
        struct.new 126
        struct.new 16
      else
        local.get 3
        ref.cast (ref 0)
        i32.const 0
        array.get 0
        i32.const 3
        i32.eq
        if (result eqref) ;; label = @3
          i32.const 1
          i32.const 1
          struct.new 125
          struct.new 16
        else
          local.get 3
          ref.cast (ref 0)
          i32.const 0
          array.get 0
          i32.const 4
          i32.eq
          if (result eqref) ;; label = @4
            i32.const 1
            i32.const 3
            local.get 4
            ref.cast (ref 134)
            struct.get 134 4
            ref.cast (ref 5)
            i32.const 0
            array.get 5
            struct.new 126
            struct.new 16
          else
            i32.const 0
            local.get 4
            ref.cast (ref 134)
            struct.get 134 0
            call 66
            struct.new 13
          end
        end
      end
    end
    ref.cast (ref 12)
  )
  (func (;119;) (type 191) (param eqref i32) (result (ref 12))
    local.get 0
    local.get 1
    call 69
    call 121
    ref.cast (ref 12)
  )
  (func (;120;) (type 192) (param eqref (ref 109)) (result (ref 12))
    local.get 0
    local.get 1
    ref.cast (ref 109)
    i32.const 128
    i32.const 16777216
    call 122
    ref.cast (ref 12)
  )
  (func (;121;) (type 193) (param eqref i32 (ref 120)) (result (ref 12))
    (local eqref eqref (ref 121) (ref 109) eqref eqref eqref eqref)
    local.get 0
    local.get 1
    local.get 2
    ref.cast (ref 120)
    struct.get 120 0
    call 46
    local.set 9
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 9
            ref.cast (ref 12)
            struct.get 12 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 9
          ref.cast (ref 13)
          struct.get 13 1
          local.set 4
          local.get 4
          local.get 2
          ref.cast (ref 120)
          call 108
          local.set 7
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 7
                  ref.cast (ref 12)
                  struct.get 12 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                local.get 7
                ref.cast (ref 13)
                struct.get 13 1
                ref.cast (ref 109)
                local.set 6
                i32.const 0
                local.get 6
                struct.new 13
                local.set 8
                br 2 (;@4;)
              end
              local.get 7
              ref.cast (ref 16)
              struct.get 16 1
              ref.cast (ref 121)
              local.set 5
              i32.const 1
              i32.const 1
              local.get 5
              ref.cast (ref 121)
              struct.new 129
              struct.new 16
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
        ref.cast (ref 16)
        struct.get 16 1
        local.set 3
        i32.const 1
        i32.const 0
        local.get 3
        ref.cast (ref 74)
        struct.new 128
        struct.new 16
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 12)
  )
  (func (;122;) (type 194) (param eqref (ref 109) i32 i32) (result (ref 12))
    (local (ref 125) eqref eqref i32 eqref eqref eqref eqref)
    local.get 1
    ref.cast (ref 109)
    local.get 2
    local.get 3
    call 118
    local.set 10
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 10
            ref.cast (ref 12)
            struct.get 12 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 10
          ref.cast (ref 13)
          struct.get 13 1
          local.set 5
          local.get 0
          local.get 5
          call 53
          call 47
          local.set 8
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  local.get 8
                  ref.cast (ref 12)
                  struct.get 12 0
                  br_table 0 (;@7;) 1 (;@6;) 2 (;@5;)
                end
                local.get 8
                ref.cast (ref 14)
                struct.get 14 1
                local.set 7
                i32.const 0
                local.get 7
                struct.new 14
                local.set 9
                br 2 (;@4;)
              end
              local.get 8
              ref.cast (ref 16)
              struct.get 16 1
              local.set 6
              i32.const 1
              i32.const 0
              local.get 6
              ref.cast (ref 74)
              struct.new 131
              struct.new 16
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
        ref.cast (ref 16)
        struct.get 16 1
        ref.cast (ref 125)
        local.set 4
        i32.const 1
        i32.const 1
        local.get 4
        ref.cast (ref 125)
        struct.new 132
        struct.new 16
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 12)
  )
  (func (;123;) (type 196) (param i32 eqref) (result i32)
    (local (ref 205) (ref 203) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 205)
    local.set 2
    local.get 2
    struct.get 205 0
    local.set 3
    local.get 2
    struct.get 205 1
    local.set 4
    local.get 2
    struct.get 205 2
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
              array.get 203
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
              array.get 203
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
              array.get 203
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
              array.get 203
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
                array.get 203
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 203
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
                array.get 203
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
            array.get 203
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
  (func (;124;) (type 197) (result i32)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
    array.new_fixed 203 1
    i32.const 0
    i32.const 11
    struct.new 205
    call 38
    i32.const 3
    call 119
    local.set 7
    block ;; label = @1
      local.get 7
      ref.cast (ref 12)
      struct.get 12 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 7
        ref.cast (ref 13)
        struct.get 13 1
        ref.cast (ref 109)
        struct.get 109 0
        i32.const 6
        i32.eq
        if (result i32) ;; label = @3
          local.get 7
          ref.cast (ref 13)
          struct.get 13 1
          ref.cast (ref 116)
          struct.get 116 1
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
        ref.cast (ref 19)
        struct.get 19 1
        i32.const 2
        i32.eq
        if ;; label = @3
          call 40
          local.set 1
          local.get 1
          i32.const 6
          local.get 0
          ref.cast (ref 19)
          struct.new 116
          call 120
          local.set 5
          block ;; label = @4
            local.get 5
            ref.cast (ref 12)
            struct.get 12 0
            i32.const 0
            i32.eq
            if (result i32) ;; label = @5
              local.get 5
              ref.cast (ref 14)
              struct.get 14 1
              i32.const 11
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 1
              ref.cast (ref 77)
              call 44
              local.set 3
              block ;; label = @6
                local.get 3
                ref.cast (ref 12)
                struct.get 12 0
                i32.const 0
                i32.eq
                if ;; label = @7
                  local.get 3
                  ref.cast (ref 13)
                  struct.get 13 1
                  local.set 2
                  local.get 2
                  v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
                  array.new_fixed 203 1
                  i32.const 0
                  i32.const 11
                  struct.new 205
                  call 35
                  if ;; label = @8
                    i32.const 1
                    v128.const i32x4 0x6e6f736a 0x6165723a 0x2d726564 0x74697277
                    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
                    array.new_fixed 203 2
                    i32.const 0
                    i32.const 18
                    struct.new 205
                    call 123
                    local.set 4
                    br 2 (;@6;)
                  end
                end
                i32.const 1
                if ;; label = @7
                  i32.const 1
                  v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
                  array.new_fixed 203 1
                  i32.const 0
                  i32.const 4
                  struct.new 205
                  call 123
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
              array.new_fixed 203 1
              i32.const 0
              i32.const 4
              struct.new 205
              call 123
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
        array.new_fixed 203 1
        i32.const 0
        i32.const 4
        struct.new 205
        call 123
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
  )
)
