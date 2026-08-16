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
  (type (;10;) (sub final 9 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (sub final 11 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;13;) (sub final 11 (struct (field i32) (field i32) (field i64) (field f32) (field f64) (field v128) (field eqref))))
  (type (;14;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;15;) (sub (struct (field funcref))))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (param eqref i32) (result eqref)))
  (type (;18;) (func (param eqref) (result (ref 14))))
  (type (;19;) (func (param eqref eqref) (result eqref)))
  (type (;20;) (func (param eqref)))
  (type (;21;) (func (param eqref i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref i32) (result i32)))
  (type (;24;) (func (param eqref eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result (ref 14))))
  (type (;26;) (func (param eqref eqref eqref) (result eqref)))
  (type (;27;) (func (param eqref eqref)))
  (type (;28;) (func (param eqref eqref i32)))
  (type (;29;) (func (param eqref eqref) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result i32)))
  (type (;31;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;32;) (func (param eqref i32) (result v128)))
  (type (;33;) (func (param eqref i32) (result v128)))
  (type (;34;) (func (param eqref) (result i32)))
  (type (;35;) (func (param eqref) (result eqref)))
  (type (;36;) (func (param eqref eqref) (result i32)))
  (type (;37;) (func (param eqref) (result i64)))
  (type (;38;) (func (param eqref i32) (result i32)))
  (type (;39;) (func (param eqref i32 i32) (result eqref)))
  (type (;40;) (func (param eqref) (result i32)))
  (type (;41;) (func (param eqref) (result eqref)))
  (type (;42;) (func (result eqref)))
  (type (;43;) (func (param i32) (result eqref)))
  (type (;44;) (func (param eqref) (result i32)))
  (type (;45;) (func (param eqref eqref)))
  (type (;46;) (func (param eqref eqref)))
  (type (;47;) (func (param eqref i32)))
  (type (;48;) (func (param eqref i32)))
  (type (;49;) (func (param eqref) (result eqref)))
  (type (;50;) (func (param eqref) (result i32)))
  (type (;51;) (func (param eqref eqref) (result i32)))
  (type (;52;) (func (param eqref i32) (result i32)))
  (type (;53;) (func (param eqref i32 i32) (result eqref)))
  (type (;54;) (func (param eqref) (result i32)))
  (type (;55;) (func (param eqref eqref) (result i32)))
  (type (;56;) (func (param eqref i32) (result i32)))
  (type (;57;) (func (param eqref i32 i32) (result eqref)))
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
  (type (;77;) (sub (struct (field i32))))
  (type (;78;) (sub final 77 (struct (field i32) (field i32))))
  (type (;79;) (sub final 77 (struct (field i32) (field eqref))))
  (type (;80;) (struct (field eqref)))
  (type (;81;) (sub final 77 (struct (field i32) (field (ref 80)))))
  (type (;82;) (struct (field eqref) (field i32)))
  (type (;83;) (sub final 77 (struct (field i32) (field (ref 82)))))
  (type (;84;) (sub final 77 (struct (field i32) (field (ref 14)))))
  (type (;85;) (sub final 77 (struct (field i32) (field (ref 14)))))
  (type (;86;) (struct (field eqref) (field (ref 77))))
  (type (;87;) (struct (field eqref) (field i32)))
  (type (;88;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;89;) (sub (struct (field i32))))
  (type (;90;) (sub final 89 (struct (field i32) (field i32))))
  (type (;91;) (sub final 89 (struct (field i32) (field i32) (field i8))))
  (type (;92;) (sub final 89 (struct (field i32) (field i32) (field eqref))))
  (type (;93;) (sub (struct (field i32))))
  (type (;94;) (sub final 93 (struct (field i32) (field eqref))))
  (type (;95;) (struct (field eqref) (field eqref) (field (ref 0)) (field (ref 88)) (field i32) (field i32) (field i32)))
  (type (;96;) (struct (field eqref) (field i32) (field i32) (field (ref 0)) (field (ref 5))))
  (type (;97;) (func))
  (type (;98;) (func (result (ref 88))))
  (type (;99;) (func (param (ref 95)) (result i32)))
  (type (;100;) (func (param (ref 95) i32)))
  (type (;101;) (func (param (ref 95)) (result i32)))
  (type (;102;) (func (param (ref 95) i32)))
  (type (;103;) (func (param i32) (result i32)))
  (type (;104;) (func (param i32) (result i32)))
  (type (;105;) (func (param eqref i32) (result i32)))
  (type (;106;) (func (param eqref i32) (result i32)))
  (type (;107;) (func (param eqref i32) (result i32)))
  (type (;108;) (func (param i32) (result i32)))
  (type (;109;) (func (param eqref i32) (result i32)))
  (type (;110;) (func (param (ref 95))))
  (type (;111;) (func (param i32) (result i32)))
  (type (;112;) (func (param i32) (result i32)))
  (type (;113;) (func (param eqref i32 i32) (result i32)))
  (type (;114;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;115;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;116;) (func (param eqref i32 i32) (result (ref 9))))
  (type (;117;) (func (param eqref i32 i32) (result i32)))
  (type (;118;) (func (param i32) (result i32)))
  (type (;119;) (func (param eqref i32) (result (ref 9))))
  (type (;120;) (func (param (ref 95) eqref i32 i32) (result i32)))
  (type (;121;) (func (param (ref 95)) (result (ref 11))))
  (type (;122;) (func (param (ref 95)) (result (ref 11))))
  (type (;123;) (func (param (ref 95) eqref (ref 77)) (result (ref 11))))
  (type (;124;) (func (param (ref 95)) (result (ref 11))))
  (type (;125;) (func (param (ref 95)) (result (ref 11))))
  (type (;126;) (func (param (ref 95) i32) (result (ref 11))))
  (type (;127;) (func (param eqref eqref) (result i32)))
  (type (;128;) (func (param eqref) (result i64)))
  (type (;129;) (func (param (ref 14) i32 eqref) (result i32)))
  (type (;130;) (func (param (ref 14) eqref) (result i32)))
  (type (;131;) (func (param i64) (result i32)))
  (type (;132;) (func (param i64) (result i32)))
  (type (;133;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;134;) (func (param (ref 95) i32) (result (ref 11))))
  (type (;135;) (func (param (ref 95) i32) (result (ref 11))))
  (type (;136;) (func (param eqref (ref 88) i32 i32 i32) (result (ref 11))))
  (type (;137;) (func (param eqref (ref 88)) (result (ref 11))))
  (type (;138;) (func (param eqref) (result (ref 11))))
  (type (;139;) (func (param (ref 96) i32)))
  (type (;140;) (func (param (ref 96) i32 eqref)))
  (type (;141;) (func (param (ref 96) i32)))
  (type (;142;) (func (param (ref 96) eqref)))
  (type (;143;) (func (param (ref 96) eqref)))
  (type (;144;) (func (param i32) (result i32)))
  (type (;145;) (func (param (ref 96) eqref)))
  (type (;146;) (func (param (ref 96) (ref 82))))
  (type (;147;) (func (param (ref 96) (ref 77) i32)))
  (type (;148;) (func (param (ref 77) i32 i32) (result (ref 11))))
  (type (;149;) (func (param (ref 77)) (result (ref 11))))
  (type (;150;) (func (param eqref (ref 77)) (result (ref 86))))
  (type (;151;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;152;) (func (param i32 eqref) (result i32)))
  (type (;153;) (func (result i32)))
  (type (;154;) (array (mut v128)))
  (type (;155;) (struct (field (ref 154)) (field i32) (field i32)))
  (type (;156;) (struct (field (ref 154)) (field i32) (field i32)))
  (type (;157;) (struct (field (ref 154)) (field i32) (field i32)))
  (type (;158;) (struct (field (mut (ref 154))) (field (mut i32)) (field (mut i32))))
  (type (;159;) (struct (field (mut (ref 154))) (field (mut i32)) (field (mut i32))))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 151)))
  (memory (;0;) 1)
  (export "main" (func 102))
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
  (func (;2;) (type 32) (param eqref i32) (result v128)
    (local (ref 156) (ref 154) i32 v128)
    local.get 0
    ref.cast (ref 156)
    local.set 2
    local.get 1
    local.get 2
    struct.get 156 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 156 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 156 0
    local.set 3
    local.get 2
    struct.get 156 1
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
      array.get 154
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 154
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
      array.get 154
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
  (func (;3;) (type 33) (param eqref i32) (result v128)
    (local (ref 155) (ref 154) i32 v128)
    local.get 0
    ref.cast (ref 155)
    local.set 2
    local.get 1
    local.get 2
    struct.get 155 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 155 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 155 0
    local.set 3
    local.get 2
    struct.get 155 1
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
      array.get 154
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 154
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
      array.get 154
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
  (func (;4;) (type 34) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 155)
    struct.get 155 2
  )
  (func (;5;) (type 35) (param eqref) (result eqref)
    (local (ref 155))
    local.get 0
    ref.cast (ref 155)
    local.tee 1
    struct.get 155 0
    local.get 1
    struct.get 155 1
    local.get 1
    struct.get 155 2
    struct.new 156
  )
  (func (;6;) (type 36) (param eqref eqref) (result i32)
    (local (ref 155) (ref 155) (ref 154) (ref 154) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 155)
    local.set 2
    local.get 1
    ref.cast (ref 155)
    local.set 3
    local.get 2
    struct.get 155 2
    local.tee 6
    local.get 3
    struct.get 155 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 155 0
    local.set 4
    local.get 3
    struct.get 155 0
    local.set 5
    local.get 2
    struct.get 155 1
    local.set 7
    local.get 3
    struct.get 155 1
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
          array.get 154
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 154
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
          array.get 154
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
          array.get 154
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 154
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
          array.get 154
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
      array.get 154
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
      array.get 154
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
  (func (;7;) (type 37) (param eqref) (result i64)
    (local (ref 155) (ref 154) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 155)
    local.set 1
    local.get 1
    struct.get 155 0
    local.set 2
    local.get 1
    struct.get 155 1
    local.set 3
    local.get 1
    struct.get 155 2
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
      array.get 154
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
  (func (;8;) (type 38) (param eqref i32) (result i32)
    (local (ref 155) (ref 154) i32)
    local.get 0
    ref.cast (ref 155)
    local.set 2
    local.get 1
    local.get 2
    struct.get 155 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 155 0
    local.set 3
    local.get 2
    struct.get 155 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 154
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;9;) (type 39) (param eqref i32 i32) (result eqref)
    (local (ref 155) (ref 154) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 155)
    local.set 3
    local.get 3
    struct.get 155 2
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
    struct.get 155 0
    local.set 4
    local.get 3
    struct.get 155 1
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
      array.get 154
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
      array.get 154
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
    struct.get 155 1
    local.get 1
    i32.add
    local.get 2
    struct.new 157
  )
  (func (;10;) (type 40) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 157)
    struct.get 157 2
  )
  (func (;11;) (type 41) (param eqref) (result eqref)
    (local (ref 157))
    local.get 0
    ref.cast (ref 157)
    local.tee 1
    struct.get 157 0
    local.get 1
    struct.get 157 1
    local.get 1
    struct.get 157 2
    struct.new 155
  )
  (func (;12;) (type 42) (result eqref)
    i32.const 4
    array.new_default 154
    i32.const 0
    i32.const 0
    struct.new 158
  )
  (func (;13;) (type 43) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 154
    i32.const 0
    i32.const 0
    struct.new 158
  )
  (func (;14;) (type 44) (param eqref) (result i32)
    (local (ref 158))
    local.get 0
    ref.cast (ref 158)
    local.tee 1
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 158 1
  )
  (func (;15;) (type 45) (param eqref eqref)
    (local (ref 158) (ref 155) (ref 154) (ref 154) i32 i32 i32 i32 i32 i32 (ref 154) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 158)
    local.set 2
    local.get 2
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 155)
    local.set 3
    local.get 2
    struct.get 158 0
    local.set 4
    local.get 3
    struct.get 155 0
    local.set 5
    local.get 2
    struct.get 158 1
    local.set 6
    local.get 3
    struct.get 155 1
    local.set 7
    local.get 3
    struct.get 155 2
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
      array.new_default 154
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
          array.get 154
          array.set 154
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 158 0
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
            array.get 154
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 154
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
            array.get 154
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
            array.set 154
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
            array.get 154
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
            array.set 154
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
            array.get 154
            local.get 19
            v128.bitselect
            array.set 154
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
        array.get 154
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
        array.get 154
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 154
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 158 1
  )
  (func (;16;) (type 46) (param eqref eqref)
    (local (ref 158) (ref 157) (ref 154) (ref 154) i32 i32 i32 i32 i32 i32 (ref 154) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 158)
    local.set 2
    local.get 2
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 157)
    local.set 3
    local.get 2
    struct.get 158 0
    local.set 4
    local.get 3
    struct.get 157 0
    local.set 5
    local.get 2
    struct.get 158 1
    local.set 6
    local.get 3
    struct.get 157 1
    local.set 7
    local.get 3
    struct.get 157 2
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
      array.new_default 154
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
          array.get 154
          array.set 154
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 158 0
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
            array.get 154
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 154
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
            array.get 154
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
            array.set 154
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
            array.get 154
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
            array.set 154
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
            array.get 154
            local.get 19
            v128.bitselect
            array.set 154
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
        array.get 154
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
        array.get 154
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 154
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 158 1
  )
  (func (;17;) (type 47) (param eqref i32)
    (local (ref 158) (ref 154) i32 i32 i32 (ref 154) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 158)
    local.set 2
    local.get 2
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 158 0
    local.set 3
    local.get 2
    struct.get 158 1
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
      array.new_default 154
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
          array.get 154
          array.set 154
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 158 0
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
    array.get 154
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 154
    local.get 2
    local.get 5
    struct.set 158 1
  )
  (func (;18;) (type 48) (param eqref i32)
    (local (ref 158) (ref 154) i32 i32 i32 i32 i32 (ref 154) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 158)
    local.set 2
    local.get 2
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 158 0
    local.set 3
    local.get 2
    struct.get 158 1
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
      array.new_default 154
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
          array.get 154
          array.set 154
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 158 0
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
    array.get 154
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 154
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
      array.get 154
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 154
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
      array.get 154
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 154
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
      array.get 154
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 154
    end
    local.get 2
    local.get 6
    struct.set 158 1
  )
  (func (;19;) (type 49) (param eqref) (result eqref)
    (local (ref 158))
    local.get 0
    ref.cast (ref 158)
    local.set 1
    local.get 1
    struct.get 158 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 158 2
    local.get 1
    struct.get 158 0
    i32.const 0
    local.get 1
    struct.get 158 1
    struct.new 155
  )
  (func (;20;) (type 50) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 156)
    struct.get 156 2
  )
  (func (;21;) (type 51) (param eqref eqref) (result i32)
    (local (ref 156) (ref 156) (ref 154) (ref 154) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 156)
    local.set 2
    local.get 1
    ref.cast (ref 156)
    local.set 3
    local.get 2
    struct.get 156 2
    local.tee 6
    local.get 3
    struct.get 156 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 156 0
    local.set 4
    local.get 3
    struct.get 156 0
    local.set 5
    local.get 2
    struct.get 156 1
    local.set 7
    local.get 3
    struct.get 156 1
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
          array.get 154
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 154
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
          array.get 154
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
          array.get 154
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 154
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
          array.get 154
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
      array.get 154
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
      array.get 154
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
  (func (;22;) (type 52) (param eqref i32) (result i32)
    (local (ref 156) (ref 154) i32)
    local.get 0
    ref.cast (ref 156)
    local.set 2
    local.get 1
    local.get 2
    struct.get 156 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 156 0
    local.set 3
    local.get 2
    struct.get 156 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 154
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;23;) (type 53) (param eqref i32 i32) (result eqref)
    (local (ref 156) i32)
    local.get 0
    ref.cast (ref 156)
    local.set 3
    local.get 3
    struct.get 156 2
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
    struct.get 156 0
    local.get 3
    struct.get 156 1
    local.get 1
    i32.add
    local.get 2
    struct.new 156
  )
  (func (;24;) (type 54) (param eqref) (result i32)
    local.get 0
    call 20
  )
  (func (;25;) (type 55) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 21
  )
  (func (;26;) (type 56) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 22
  )
  (func (;27;) (type 57) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 23
  )
  (func (;28;) (type 58) (param i64) (result i64)
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
  (func (;29;) (type 59) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 28
    i64.or
  )
  (func (;30;) (type 60) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 28
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;31;) (type 61) (param eqref) (result i64)
    local.get 0
    call 7
  )
  (func (;32;) (type 62) (param eqref) (result i32)
    local.get 0
    call 4
  )
  (func (;33;) (type 63) (param eqref) (result eqref)
    local.get 0
    call 5
  )
  (func (;34;) (type 64) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 6
  )
  (func (;35;) (type 65) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;36;) (type 66) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 9
  )
  (func (;37;) (type 67) (param eqref) (result i32)
    local.get 0
    call 10
  )
  (func (;38;) (type 68) (param eqref) (result eqref)
    local.get 0
    call 11
  )
  (func (;39;) (type 69) (param eqref) (result eqref)
    (local eqref)
    local.get 0
    call 37
    call 13
    local.set 1
    local.get 1
    local.get 0
    call 16
    local.get 1
    call 19
  )
  (func (;40;) (type 70) (result eqref)
    call 12
  )
  (func (;41;) (type 71) (param eqref) (result i32)
    local.get 0
    call 14
  )
  (func (;42;) (type 72) (param eqref eqref)
    local.get 0
    local.get 1
    call 15
  )
  (func (;43;) (type 73) (param eqref eqref)
    local.get 0
    local.get 1
    call 16
  )
  (func (;44;) (type 74) (param eqref i32)
    local.get 0
    local.get 1
    call 17
  )
  (func (;45;) (type 75) (param eqref i32)
    local.get 0
    local.get 1
    call 18
  )
  (func (;46;) (type 76) (param eqref) (result eqref)
    local.get 0
    call 19
  )
  (func (;47;) (type 97))
  (func (;48;) (type 98) (result (ref 88))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 88
    ref.cast (ref 88)
  )
  (func (;49;) (type 99) (param (ref 95)) (result i32)
    local.get 0
    struct.get 95 2
    ref.cast (ref 0)
    i32.const 0
    array.get 0
  )
  (func (;50;) (type 100) (param (ref 95) i32)
    local.get 0
    struct.get 95 2
    ref.cast (ref 0)
    i32.const 0
    local.get 1
    array.set 0
  )
  (func (;51;) (type 101) (param (ref 95)) (result i32)
    local.get 0
    struct.get 95 2
    ref.cast (ref 0)
    i32.const 1
    array.get 0
  )
  (func (;52;) (type 102) (param (ref 95) i32)
    local.get 0
    struct.get 95 2
    ref.cast (ref 0)
    i32.const 1
    local.get 1
    array.set 0
  )
  (func (;53;) (type 103) (param i32) (result i32)
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
  (func (;54;) (type 104) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;55;) (type 105) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 24
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
              call 26
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
  (func (;56;) (type 106) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 32
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
              call 35
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
  (func (;57;) (type 107) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 24
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
              call 26
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
  (func (;58;) (type 108) (param i32) (result i32)
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
  (func (;59;) (type 109) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 24
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
              call 26
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
  (func (;60;) (type 110) (param (ref 95))
    local.get 0
    local.get 0
    struct.get 95 0
    local.get 0
    call 49
    call 55
    call 50
  )
  (func (;61;) (type 111) (param i32) (result i32)
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
  (func (;62;) (type 112) (param i32) (result i32)
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
  (func (;63;) (type 113) (param eqref i32 i32) (result i32)
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
              call 26
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
  (func (;64;) (type 114) (param eqref i32 i32) (result (ref 9))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 9
    else
      local.get 0
      local.get 1
      call 26
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
          call 26
          call 61
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
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          ref.null eq
          struct.new 10
        end
      else
        local.get 0
        local.get 1
        call 26
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
          struct.new 10
        else
          i32.const 0
          struct.new 9
        end
      end
    end
    ref.cast (ref 9)
  )
  (func (;65;) (type 115) (param eqref i32 i32) (result (ref 9))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 26
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
        call 26
        call 61
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
        call 63
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 10
      end
    else
      i32.const 1
      local.get 1
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 10
    end
    ref.cast (ref 9)
  )
  (func (;66;) (type 116) (param eqref i32 i32) (result (ref 9))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 26
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 26
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
        call 26
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 26
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
        call 26
        call 61
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
        call 63
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 10
      end
    else
      i32.const 1
      local.get 1
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      ref.null eq
      struct.new 10
    end
    ref.cast (ref 9)
  )
  (func (;67;) (type 117) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 26
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
          call 65
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
              call 66
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
  (func (;68;) (type 118) (param i32) (result i32)
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
  (func (;69;) (type 119) (param eqref i32) (result (ref 9))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 24
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 24
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
      call 26
      call 68
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 26
      call 68
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 26
      call 68
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 26
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
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        ref.null eq
        struct.new 10
      end
    end
    ref.cast (ref 9)
  )
  (func (;70;) (type 120) (param (ref 95) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 41
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 95 3
      struct.get 88 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 95 3
      struct.get 88 3
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
        struct.get 95 1
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 36
        call 43
      else
      end
      i32.const 1
    end
  )
  (func (;71;) (type 121) (param (ref 95)) (result (ref 11))
    (local i32 i32 i32 i32 i32 eqref eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 49
    local.set 1
    local.get 0
    struct.get 95 0
    call 24
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
      struct.new 90
      struct.new 13
    else
      local.get 0
      struct.get 95 0
      local.get 1
      call 26
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
        struct.get 95 0
        local.get 1
        call 26
        struct.new 91
        struct.new 13
      else
        local.get 1
        i32.const 1
        i32.add
        local.set 3
        local.get 0
        struct.get 95 1
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
          struct.new 90
          struct.new 13
        else
          local.get 0
          struct.get 95 0
          local.get 4
          call 26
          i32.const 34
          i32.eq
          if (result eqref) ;; label = @4
            local.get 4
            local.get 3
            i32.sub
            local.set 5
            local.get 5
            local.get 0
            struct.get 95 3
            struct.get 88 3
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
              struct.new 90
              struct.new 13
            else
              local.get 0
              local.get 4
              i32.const 1
              i32.add
              call 50
              local.get 0
              struct.get 95 1
              local.get 3
              local.get 5
              call 36
              local.set 6
              local.get 0
              struct.get 95 4
              if (result eqref) ;; label = @6
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 39
                i32.const 0
                struct.new 87
                struct.new 12
              else
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                local.get 6
                call 38
                i32.const 0
                struct.new 87
                struct.new 12
              end
            end
          else
            local.get 0
            struct.get 95 0
            local.get 4
            call 26
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
              struct.new 90
              struct.new 13
            else
              call 40
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
                      struct.get 95 1
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
                        struct.new 90
                        struct.new 13
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
                        struct.new 90
                        struct.new 13
                        local.set 19
                        br 4 (;@6;)
                      else
                      end
                      local.get 0
                      struct.get 95 0
                      local.get 10
                      call 26
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
                        call 46
                        i32.const 1
                        struct.new 87
                        struct.new 12
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
                          struct.new 90
                          struct.new 13
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
                            struct.new 91
                            struct.new 13
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
                              struct.new 90
                              struct.new 13
                              local.set 19
                              br 7 (;@6;)
                            else
                              local.get 0
                              struct.get 95 0
                              local.get 10
                              i32.const 1
                              i32.add
                              call 26
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
                                call 44
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
                                  call 44
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
                                    call 44
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
                                      call 44
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
                                        call 44
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
                                          call 44
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
                                            struct.get 95 0
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
                                                    ref.cast (ref 9)
                                                    struct.get 9 0
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
                                                  struct.new 90
                                                  struct.new 13
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
                                                    struct.get 95 0
                                                    local.get 14
                                                    call 26
                                                    i32.const 92
                                                    i32.ne
                                                  end
                                                  if (result i32) ;; label = @24
                                                    i32.const 1
                                                  else
                                                    local.get 0
                                                    struct.get 95 0
                                                    local.get 14
                                                    i32.const 1
                                                    i32.add
                                                    call 26
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
                                                    struct.new 90
                                                    struct.new 13
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                  end
                                                  local.get 0
                                                  struct.get 95 0
                                                  local.get 14
                                                  i32.const 2
                                                  i32.add
                                                  call 69
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
                                                        call 45
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
                                                      struct.new 90
                                                      struct.new 13
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
                                                    struct.new 90
                                                    struct.new 13
                                                    local.set 19
                                                    br 18 (;@6;)
                                                  else
                                                    local.get 7
                                                    local.get 13
                                                    call 45
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
                                            struct.new 90
                                            struct.new 13
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
                              call 41
                              local.get 0
                              struct.get 95 3
                              struct.get 88 3
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
                                struct.new 90
                                struct.new 13
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
    ref.cast (ref 11)
  )
  (func (;72;) (type 122) (param (ref 95)) (result (ref 11))
    (local (ref 87) (ref 89) eqref eqref)
    local.get 0
    call 71
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 11)
            struct.get 11 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 12)
          struct.get 12 6
          ref.cast (ref 87)
          local.set 1
          i32.const 0
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 1
          ref.cast (ref 87)
          struct.get 87 0
          struct.new 12
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 13)
        struct.get 13 6
        ref.cast (ref 89)
        local.set 2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 13
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
  )
  (func (;73;) (type 123) (param (ref 95) eqref (ref 77)) (result (ref 11))
    (local i32 i32)
    local.get 0
    call 49
    local.set 3
    local.get 0
    struct.get 95 0
    call 24
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 24
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
      struct.new 90
      struct.new 13
    else
      local.get 0
      struct.get 95 0
      local.get 3
      local.get 1
      call 24
      call 27
      local.get 1
      call 25
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
        struct.new 90
        struct.new 13
      else
        local.get 0
        local.get 3
        local.get 1
        call 24
        i32.add
        call 50
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 12
      end
    end
    ref.cast (ref 11)
  )
  (func (;74;) (type 124) (param (ref 95)) (result (ref 11))
    (local i32 i32 eqref)
    local.get 0
    call 49
    local.set 1
    local.get 0
    struct.get 95 0
    local.get 1
    call 59
    local.set 2
    local.get 0
    struct.get 95 0
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
      struct.new 90
      struct.new 13
    else
      local.get 0
      local.get 2
      call 50
      local.get 0
      struct.get 95 1
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 36
      local.set 3
      local.get 0
      struct.get 95 4
      if (result eqref) ;; label = @2
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 39
        struct.new 12
      else
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 3
        call 38
        struct.new 12
      end
    end
    ref.cast (ref 11)
  )
  (func (;75;) (type 125) (param (ref 95)) (result (ref 11))
    (local eqref (ref 89) eqref eqref)
    local.get 0
    call 74
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 11)
            struct.get 11 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 3
          ref.cast (ref 12)
          struct.get 12 6
          local.set 1
          local.get 0
          struct.get 95 5
          if (result eqref) ;; label = @4
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            i32.const 3
            local.get 1
            struct.new 80
            ref.cast (ref 80)
            struct.new 81
            struct.new 12
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            i32.const 2
            local.get 1
            struct.new 79
            struct.new 12
          end
          local.set 4
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 13)
        struct.get 13 6
        ref.cast (ref 89)
        local.set 2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 2
        struct.new 13
        local.set 4
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 4
    ref.cast (ref 11)
  )
  (func (;76;) (type 126) (param (ref 95) i32) (result (ref 11))
    (local eqref (ref 89) (ref 77) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 14
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
    struct.get 95 0
    call 24
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 95 0
      local.get 0
      call 49
      call 26
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
      ref.cast (ref 14)
      struct.new 84
      struct.new 12
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
                      ref.cast (ref 11)
                      struct.get 11 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 11
                    ref.cast (ref 12)
                    struct.get 12 6
                    ref.cast (ref 77)
                    local.set 4
                    local.get 2
                    local.get 4
                    local.set 10
                    local.set 7
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 1
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 2
                    i32.eq
                    if ;; label = @9
                      local.get 7
                      ref.cast (ref 14)
                      struct.get 14 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 7
                        ref.cast (ref 14)
                        struct.get 14 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 8
                      local.get 8
                      local.get 7
                      ref.cast (ref 14)
                      struct.get 14 2
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
                      ref.cast (ref 14)
                      struct.get 14 0
                      ref.cast (ref 5)
                      i32.const 0
                      local.get 7
                      ref.cast (ref 14)
                      struct.get 14 1
                      array.copy 5 5
                      local.get 7
                      ref.cast (ref 14)
                      local.get 9
                      struct.set 14 0
                      local.get 7
                      ref.cast (ref 14)
                      local.get 9
                      ref.cast (ref 5)
                      array.len
                      struct.set 14 2
                    end
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 0
                    ref.cast (ref 5)
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 1
                    local.get 10
                    array.set 5
                    local.get 7
                    ref.cast (ref 14)
                    local.get 7
                    ref.cast (ref 14)
                    struct.get 14 1
                    i32.const 1
                    i32.add
                    struct.set 14 1
                    br 2 (;@6;)
                  end
                  local.get 11
                  ref.cast (ref 13)
                  struct.get 13 6
                  ref.cast (ref 89)
                  local.set 3
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  struct.new 13
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
              struct.get 95 0
              call 24
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
                struct.new 90
                struct.new 13
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 95 0
              local.get 5
              call 26
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
                ref.cast (ref 14)
                struct.new 84
                struct.new 12
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
                  struct.new 91
                  struct.new 13
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
    ref.cast (ref 11)
  )
  (func (;77;) (type 127) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 34
  )
  (func (;78;) (type 128) (param eqref) (result i64)
    local.get 0
    call 31
  )
  (func (;79;) (type 129) (param (ref 14) i32 eqref) (result i32)
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
              ref.cast (ref 14)
              struct.get 14 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 14)
              struct.get 14 0
              ref.cast (ref 5)
              local.get 5
              array.get 5
              ref.cast (ref 86)
              struct.get 86 0
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
  (func (;80;) (type 130) (param (ref 14) eqref) (result i32)
    local.get 0
    ref.cast (ref 14)
    local.get 0
    ref.cast (ref 14)
    struct.get 14 1
    local.get 1
    call 79
  )
  (func (;81;) (type 131) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;82;) (type 132) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 81
  )
  (func (;83;) (type 133) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 30
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 30
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 30
        else
          local.get 3
          local.get 5
          call 30
        end
      end
    end
  )
  (func (;84;) (type 134) (param (ref 95) i32) (result (ref 11))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 89) eqref i32 i32 i64 i32 (ref 86) i64 i32 i32 i32 i32 (ref 77) (ref 89) (ref 77) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 5
    i32.const 0
    i32.const 0
    struct.new 14
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
    struct.get 95 0
    call 24
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 95 0
      local.get 0
      call 49
      call 26
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
      ref.cast (ref 14)
      struct.new 85
      struct.new 12
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
              struct.get 95 0
              call 24
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
                struct.new 90
                struct.new 13
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 95 0
              local.get 7
              call 26
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
                struct.get 95 0
                local.get 7
                call 26
                struct.new 91
                struct.new 13
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
                      ref.cast (ref 11)
                      struct.get 11 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 26
                    ref.cast (ref 12)
                    struct.get 12 6
                    local.set 8
                    local.get 8
                    local.set 27
                    br 2 (;@6;)
                  end
                  local.get 26
                  ref.cast (ref 13)
                  struct.get 13 6
                  ref.cast (ref 89)
                  local.set 9
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 9
                  struct.new 13
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
              ref.cast (ref 14)
              struct.get 14 1
              local.set 11
              local.get 11
              i32.const 16
              i32.ge_u
              local.set 12
              local.get 12
              if (result i64) ;; label = @6
                local.get 10
                call 31
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
                          ref.cast (ref 14)
                          struct.get 14 1
                          i32.ge_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 28
                          ref.cast (ref 14)
                          struct.get 14 0
                          ref.cast (ref 5)
                          local.get 29
                          array.get 5
                          ref.cast (ref 86)
                          ref.cast (ref 86)
                          local.set 15
                          local.get 15
                          ref.cast (ref 86)
                          struct.get 86 0
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
                            call 29
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 29
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 29
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 29
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
                  ref.cast (ref 14)
                  local.get 10
                  call 80
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 14)
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
                struct.new 92
                struct.new 13
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
                  call 29
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
                    call 29
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
                      call 29
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 29
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
              struct.get 95 0
              call 24
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
                struct.new 90
                struct.new 13
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 95 0
              local.get 20
              call 26
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
                struct.get 95 0
                local.get 20
                call 26
                struct.new 91
                struct.new 13
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
                      ref.cast (ref 11)
                      struct.get 11 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 32
                    ref.cast (ref 12)
                    struct.get 12 6
                    ref.cast (ref 77)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 13)
                  struct.get 13 6
                  ref.cast (ref 89)
                  local.set 22
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 22
                  struct.new 13
                  local.set 36
                  br 5 (;@2;)
                  local.set 33
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 33
              ref.cast (ref 77)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 77)
              struct.new 86
              local.set 34
              local.set 28
              local.get 28
              ref.cast (ref 14)
              struct.get 14 1
              local.get 28
              ref.cast (ref 14)
              struct.get 14 2
              i32.eq
              if ;; label = @6
                local.get 28
                ref.cast (ref 14)
                struct.get 14 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 28
                  ref.cast (ref 14)
                  struct.get 14 2
                  i32.const 2
                  i32.mul
                end
                local.set 29
                local.get 29
                local.get 28
                ref.cast (ref 14)
                struct.get 14 2
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
                ref.cast (ref 14)
                struct.get 14 0
                ref.cast (ref 5)
                i32.const 0
                local.get 28
                ref.cast (ref 14)
                struct.get 14 1
                array.copy 5 5
                local.get 28
                ref.cast (ref 14)
                local.get 30
                struct.set 14 0
                local.get 28
                ref.cast (ref 14)
                local.get 30
                ref.cast (ref 5)
                array.len
                struct.set 14 2
              end
              local.get 28
              ref.cast (ref 14)
              struct.get 14 0
              ref.cast (ref 5)
              local.get 28
              ref.cast (ref 14)
              struct.get 14 1
              local.get 34
              array.set 5
              local.get 28
              ref.cast (ref 14)
              local.get 28
              ref.cast (ref 14)
              struct.get 14 1
              i32.const 1
              i32.add
              struct.set 14 1
              local.get 0
              call 60
              local.get 0
              call 49
              local.set 24
              local.get 24
              local.get 0
              struct.get 95 0
              call 24
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
                struct.new 90
                struct.new 13
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 95 0
              local.get 24
              call 26
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
                ref.cast (ref 14)
                struct.new 85
                struct.new 12
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
                  struct.new 91
                  struct.new 13
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
    ref.cast (ref 11)
  )
  (func (;85;) (type 135) (param (ref 95) i32) (result (ref 11))
    (local i32 i32 (ref 87) (ref 89) eqref eqref)
    local.get 1
    local.get 0
    struct.get 95 3
    struct.get 88 1
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
      struct.new 90
      struct.new 13
    else
      local.get 0
      call 51
      local.get 0
      struct.get 95 3
      struct.get 88 2
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
        struct.new 90
        struct.new 13
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
        struct.get 95 0
        call 24
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
          struct.new 90
          struct.new 13
        else
          local.get 0
          struct.get 95 0
          local.get 2
          call 26
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 154 1
            i32.const 0
            i32.const 4
            struct.new 156
            i32.const 0
            struct.new 77
            call 73
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 154 1
              i32.const 0
              i32.const 4
              struct.new 156
              i32.const 1
              i32.const 1
              struct.new 78
              call 73
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 154 1
                i32.const 0
                i32.const 5
                struct.new 156
                i32.const 1
                i32.const 0
                struct.new 78
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
                          ref.cast (ref 11)
                          struct.get 11 0
                          br_table 0 (;@11;) 1 (;@10;) 2 (;@9;)
                        end
                        local.get 6
                        ref.cast (ref 12)
                        struct.get 12 6
                        ref.cast (ref 87)
                        local.set 4
                        local.get 0
                        struct.get 95 6
                        if (result eqref) ;; label = @11
                          i32.const 0
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 5
                          local.get 4
                          ref.cast (ref 87)
                          struct.get 87 0
                          local.get 4
                          ref.cast (ref 87)
                          struct.get 87 1
                          struct.new 82
                          ref.cast (ref 82)
                          struct.new 83
                          struct.new 12
                        else
                          i32.const 0
                          i32.const 0
                          i64.const 0
                          f32.const 0x0p+0 (;=0;)
                          f64.const 0x0p+0 (;=0;)
                          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                          i32.const 4
                          local.get 4
                          ref.cast (ref 87)
                          struct.get 87 0
                          struct.new 79
                          struct.new 12
                        end
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 13)
                      struct.get 13 6
                      ref.cast (ref 89)
                      local.set 5
                      i32.const 1
                      i32.const 0
                      i64.const 0
                      f32.const 0x0p+0 (;=0;)
                      f64.const 0x0p+0 (;=0;)
                      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                      local.get 5
                      struct.new 13
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
                        struct.new 91
                        struct.new 13
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
    ref.cast (ref 11)
  )
  (func (;86;) (type 136) (param eqref (ref 88) i32 i32 i32) (result (ref 11))
    (local i32 (ref 95) (ref 89) (ref 77) eqref i32 eqref eqref)
    local.get 0
    call 32
    local.set 5
    local.get 5
    local.get 1
    struct.get 88 0
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
      struct.new 90
      struct.new 13
    else
      local.get 0
      call 33
      local.get 0
      i32.const 2
      local.set 10
      i32.const 0
      local.get 10
      array.new 0
      ref.cast (ref 0)
      local.get 1
      ref.cast (ref 88)
      local.get 2
      local.get 3
      local.get 4
      struct.new 95
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
              ref.cast (ref 11)
              struct.get 11 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            local.get 11
            ref.cast (ref 12)
            struct.get 12 6
            ref.cast (ref 77)
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
              struct.new 12
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
              struct.new 90
              struct.new 13
            end
            local.set 12
            br 2 (;@2;)
          end
          local.get 11
          ref.cast (ref 13)
          struct.get 13 6
          ref.cast (ref 89)
          local.set 7
          i32.const 1
          i32.const 0
          i64.const 0
          f32.const 0x0p+0 (;=0;)
          f64.const 0x0p+0 (;=0;)
          v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
          local.get 7
          struct.new 13
          local.set 12
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 12
    end
    ref.cast (ref 11)
  )
  (func (;87;) (type 137) (param eqref (ref 88)) (result (ref 11))
    local.get 0
    local.get 1
    i32.const 1
    i32.const 0
    i32.const 0
    call 86
    ref.cast (ref 11)
  )
  (func (;88;) (type 138) (param eqref) (result (ref 11))
    local.get 0
    call 48
    call 87
    ref.cast (ref 11)
  )
  (func (;89;) (type 139) (param (ref 96) i32)
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 96 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      array.set 0
    else
    end
  )
  (func (;90;) (type 140) (param (ref 96) i32 eqref)
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 96 4
      ref.cast (ref 5)
      i32.const 0
      local.get 2
      array.set 5
      local.get 0
      struct.get 96 3
      ref.cast (ref 0)
      i32.const 0
      local.get 1
      array.set 0
    else
    end
  )
  (func (;91;) (type 141) (param (ref 96) i32)
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 96 0
      call 41
      local.get 0
      struct.get 96 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 89
      else
        local.get 0
        struct.get 96 0
        local.get 1
        call 44
      end
    end
  )
  (func (;92;) (type 142) (param (ref 96) eqref)
    (local i32 i32)
    local.get 0
    struct.get 96 0
    call 41
    local.set 2
    local.get 1
    call 32
    local.set 3
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 96 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 96 2
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
        struct.get 96 0
        local.get 1
        call 42
      end
    end
  )
  (func (;93;) (type 143) (param (ref 96) eqref)
    (local i32 i32)
    local.get 0
    struct.get 96 0
    call 41
    local.set 2
    local.get 1
    call 37
    local.set 3
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 96 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 96 2
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
        struct.get 96 0
        local.get 1
        call 43
      end
    end
  )
  (func (;94;) (type 144) (param i32) (result i32)
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
  (func (;95;) (type 145) (param (ref 96) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 i32 i32)
    local.get 0
    i32.const 34
    call 91
    local.get 1
    call 33
    local.set 2
    local.get 2
    call 24
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
              struct.get 96 3
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
                call 36
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
                call 26
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
  (func (;96;) (type 146) (param (ref 96) (ref 82))
    local.get 1
    struct.get 82 1
    if ;; label = @1
      local.get 0
      local.get 1
      struct.get 82 0
      call 95
    else
      local.get 0
      i32.const 34
      call 91
      local.get 0
      local.get 1
      struct.get 82 0
      call 92
      local.get 0
      i32.const 34
      call 91
    end
  )
  (func (;97;) (type 147) (param (ref 96) (ref 77) i32)
    (local i32 eqref eqref (ref 80) eqref (ref 82) eqref i32 i32 eqref i64 i64 i64 i64 i32 i32 i32 (ref 86) i64 i32 i32 eqref i32 eqref i32 i32 eqref)
    local.get 0
    struct.get 96 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    i32.const 0
    i32.ne
    if ;; label = @1
      call 47
    else
      local.get 2
      local.get 0
      struct.get 96 1
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
                            ref.cast (ref 77)
                            struct.get 77 0
                            br_table 0 (;@12;) 1 (;@11;) 2 (;@10;) 3 (;@9;) 4 (;@8;) 5 (;@7;) 6 (;@6;) 7 (;@5;) 8 (;@4;)
                          end
                          local.get 0
                          v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                          array.new_fixed 154 1
                          i32.const 0
                          i32.const 4
                          struct.new 155
                          call 92
                          br 8 (;@3;)
                        end
                        local.get 29
                        ref.cast (ref 78)
                        struct.get 78 1
                        local.set 3
                        local.get 3
                        if ;; label = @11
                          local.get 0
                          v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                          array.new_fixed 154 1
                          i32.const 0
                          i32.const 4
                          struct.new 155
                          call 92
                        else
                          local.get 0
                          v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                          array.new_fixed 154 1
                          i32.const 0
                          i32.const 5
                          struct.new 155
                          call 92
                        end
                        br 7 (;@3;)
                      end
                      local.get 29
                      ref.cast (ref 79)
                      struct.get 79 1
                      local.set 4
                      local.get 4
                      call 33
                      local.set 5
                      local.get 5
                      i32.const 0
                      local.get 5
                      call 24
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
                    ref.cast (ref 81)
                    struct.get 81 1
                    ref.cast (ref 80)
                    local.set 6
                    local.get 0
                    local.get 6
                    ref.cast (ref 80)
                    struct.get 80 0
                    call 92
                    br 5 (;@3;)
                  end
                  local.get 29
                  ref.cast (ref 79)
                  struct.get 79 1
                  local.set 7
                  local.get 0
                  local.get 7
                  call 95
                  br 4 (;@3;)
                end
                local.get 29
                ref.cast (ref 83)
                struct.get 83 1
                ref.cast (ref 82)
                local.set 8
                local.get 0
                local.get 8
                call 96
                br 3 (;@3;)
              end
              local.get 29
              ref.cast (ref 84)
              struct.get 84 1
              local.set 9
              local.get 0
              i32.const 91
              call 91
              local.get 9
              ref.cast (ref 14)
              struct.get 14 1
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
                        struct.get 96 3
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
                        ref.cast (ref 14)
                        struct.get 14 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 24
                        ref.cast (ref 14)
                        struct.get 14 0
                        ref.cast (ref 5)
                        local.get 25
                        array.get 5
                        ref.cast (ref 77)
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
            ref.cast (ref 85)
            struct.get 85 1
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
            ref.cast (ref 14)
            struct.get 14 1
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
                      struct.get 96 3
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
                      ref.cast (ref 14)
                      struct.get 14 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 24
                      ref.cast (ref 14)
                      struct.get 14 0
                      ref.cast (ref 5)
                      local.get 25
                      array.get 5
                      ref.cast (ref 86)
                      ref.cast (ref 86)
                      local.set 20
                      local.get 18
                      if (result i64) ;; label = @10
                        local.get 20
                        ref.cast (ref 86)
                        struct.get 86 0
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
                          ref.cast (ref 14)
                          local.get 19
                          local.get 20
                          ref.cast (ref 86)
                          struct.get 86 0
                          call 79
                        else
                          i32.const 0
                        end
                      else
                        local.get 12
                        ref.cast (ref 14)
                        local.get 19
                        local.get 20
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 79
                      end
                      local.set 23
                      local.get 23
                      if ;; label = @10
                        local.get 0
                        i32.const 4
                        local.get 20
                        ref.cast (ref 86)
                        struct.get 86 0
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
                          call 29
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
                            call 29
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
                              call 29
                              local.set 15
                            else
                              local.get 18
                              if ;; label = @14
                                local.get 16
                                local.get 21
                                call 29
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
                        ref.cast (ref 86)
                        struct.get 86 0
                        call 95
                        local.get 0
                        i32.const 58
                        call 91
                        local.get 0
                        local.get 20
                        ref.cast (ref 86)
                        struct.get 86 1
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
  (func (;98;) (type 148) (param (ref 77) i32 i32) (result (ref 11))
    (local eqref (ref 96) eqref i32)
    i32.const 1
    local.set 6
    i32.const 0
    local.get 6
    array.new 0
    local.set 3
    call 40
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 0)
    i32.const 1
    local.set 6
    array.new_fixed 154 0
    i32.const 0
    i32.const 0
    struct.new 155
    local.get 6
    array.new 5
    ref.cast (ref 5)
    struct.new 96
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 97
    local.get 3
    ref.cast (ref 0)
    i32.const 0
    array.get 0
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
      struct.new 93
      struct.new 13
    else
      local.get 3
      ref.cast (ref 0)
      i32.const 0
      array.get 0
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
        ref.cast (ref 96)
        struct.get 96 4
        ref.cast (ref 5)
        i32.const 0
        array.get 5
        struct.new 94
        struct.new 13
      else
        local.get 3
        ref.cast (ref 0)
        i32.const 0
        array.get 0
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
          struct.new 93
          struct.new 13
        else
          local.get 3
          ref.cast (ref 0)
          i32.const 0
          array.get 0
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
            ref.cast (ref 96)
            struct.get 96 4
            ref.cast (ref 5)
            i32.const 0
            array.get 5
            struct.new 94
            struct.new 13
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 96)
            struct.get 96 0
            call 46
            struct.new 12
          end
        end
      end
    end
    ref.cast (ref 11)
  )
  (func (;99;) (type 149) (param (ref 77)) (result (ref 11))
    local.get 0
    i32.const 128
    i32.const 16777216
    call 98
    ref.cast (ref 11)
  )
  (func (;100;) (type 150) (param eqref (ref 77)) (result (ref 86))
    local.get 0
    local.get 1
    ref.cast (ref 77)
    struct.new 86
    ref.cast (ref 86)
  )
  (func (;101;) (type 152) (param i32 eqref) (result i32)
    (local (ref 156) (ref 154) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 156)
    local.set 2
    local.get 2
    struct.get 156 0
    local.set 3
    local.get 2
    struct.get 156 1
    local.set 4
    local.get 2
    struct.get 156 2
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
              array.get 154
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
              array.get 154
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
              array.get 154
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
              array.get 154
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
                array.get 154
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 154
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
                array.get 154
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
            array.get 154
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
  (func (;102;) (type 153) (result i32)
    (local i32 i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 eqref eqref eqref eqref i32 eqref i32 eqref eqref i32 eqref i32)
    v128.const i32x4 0x2261227b 0x222c303a 0x313a2262 0x2263222c
    v128.const i32x4 0x222c323a 0x333a2264 0x2265222c 0x222c343a
    v128.const i32x4 0x353a2266 0x2267222c 0x222c363a 0x373a2268
    v128.const i32x4 0x2269222c 0x222c383a 0x393a226a 0x226b222c
    v128.const i32x4 0x2c30313a 0x3a226c22 0x222c3131 0x313a226d
    v128.const i32x4 0x6e222c32 0x33313a22 0x226f222c 0x2c34313a
    v128.const i32x4 0x3a227122 0x222c3531 0x313a2270 0x30222c36
    v128.const i32x4 0x37313a22 0x0000007d 0x00000000 0x00000000
    array.new_fixed 154 8
    i32.const 0
    i32.const 117
    struct.new 155
    call 88
    local.set 6
    block ;; label = @1
      local.get 6
      ref.cast (ref 11)
      struct.get 11 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 6
        ref.cast (ref 12)
        struct.get 12 6
        ref.cast (ref 77)
        struct.get 77 0
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
    array.new_fixed 154 7
    i32.const 0
    i32.const 110
    struct.new 155
    call 88
    local.set 8
    block ;; label = @1
      local.get 8
      ref.cast (ref 11)
      struct.get 11 0
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 8
        ref.cast (ref 13)
        struct.get 13 6
        ref.cast (ref 89)
        struct.get 89 0
        i32.const 11
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
          if (result i32) ;; label = @4
            local.get 8
            ref.cast (ref 13)
            struct.get 13 6
            ref.cast (ref 92)
            struct.get 92 2
            v128.const i32x4 0x00000061 0x00000000 0x00000000 0x00000000
            array.new_fixed 154 1
            i32.const 0
            i32.const 1
            struct.new 155
            call 6
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
    array.new_fixed 154 12
    i32.const 0
    i32.const 177
    struct.new 155
    call 88
    local.set 17
    block ;; label = @1
      local.get 17
      ref.cast (ref 11)
      struct.get 11 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 17
        ref.cast (ref 12)
        struct.get 12 6
        ref.cast (ref 77)
        struct.get 77 0
        i32.const 7
        i32.eq
        if (result i32) ;; label = @3
          local.get 17
          ref.cast (ref 12)
          struct.get 12 6
          ref.cast (ref 85)
          struct.get 85 1
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
        array.new_fixed 154 1
        i32.const 0
        i32.const 1
        struct.new 155
        i32.const 0
        struct.new 77
        call 100
        local.set 13
        local.set 10
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 10
        ref.cast (ref 14)
        struct.get 14 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 14)
            struct.get 14 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 5
          local.set 12
          local.get 12
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 0
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 1
          array.copy 5 5
          local.get 10
          ref.cast (ref 14)
          local.get 12
          struct.set 14 0
          local.get 10
          ref.cast (ref 14)
          local.get 12
          ref.cast (ref 5)
          array.len
          struct.set 14 2
        end
        local.get 10
        ref.cast (ref 14)
        struct.get 14 0
        ref.cast (ref 5)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 13
        array.set 5
        local.get 10
        ref.cast (ref 14)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        i32.const 1
        i32.add
        struct.set 14 1
        local.get 2
        v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
        array.new_fixed 154 1
        i32.const 0
        i32.const 1
        struct.new 155
        i32.const 0
        struct.new 77
        call 100
        local.set 14
        local.set 10
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 10
        ref.cast (ref 14)
        struct.get 14 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 14)
            struct.get 14 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 5
          local.set 12
          local.get 12
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 0
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 1
          array.copy 5 5
          local.get 10
          ref.cast (ref 14)
          local.get 12
          struct.set 14 0
          local.get 10
          ref.cast (ref 14)
          local.get 12
          ref.cast (ref 5)
          array.len
          struct.set 14 2
        end
        local.get 10
        ref.cast (ref 14)
        struct.get 14 0
        ref.cast (ref 5)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 14
        array.set 5
        local.get 10
        ref.cast (ref 14)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        i32.const 1
        i32.add
        struct.set 14 1
        i32.const 7
        local.get 2
        ref.cast (ref 14)
        struct.new 85
        call 99
        local.set 15
        block ;; label = @3
          local.get 15
          ref.cast (ref 11)
          struct.get 11 0
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
    array.new_fixed 154 10
    i32.const 0
    i32.const 151
    struct.new 155
    call 88
    local.set 22
    block ;; label = @1
      local.get 22
      ref.cast (ref 11)
      struct.get 11 0
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        local.get 22
        ref.cast (ref 12)
        struct.get 12 6
        ref.cast (ref 77)
        struct.get 77 0
        i32.const 7
        i32.eq
        if (result i32) ;; label = @3
          local.get 22
          ref.cast (ref 12)
          struct.get 12 6
          ref.cast (ref 85)
          struct.get 85 1
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
        array.new_fixed 154 1
        i32.const 0
        i32.const 1
        struct.new 155
        i32.const 0
        struct.new 77
        call 100
        local.set 19
        local.set 10
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 10
        ref.cast (ref 14)
        struct.get 14 2
        i32.eq
        if ;; label = @3
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.eqz
          if (result i32) ;; label = @4
            i32.const 4
          else
            local.get 10
            ref.cast (ref 14)
            struct.get 14 2
            i32.const 2
            i32.mul
          end
          local.set 11
          local.get 11
          local.get 10
          ref.cast (ref 14)
          struct.get 14 2
          i32.le_u
          if ;; label = @4
            unreachable
          end
          local.get 11
          array.new_default 5
          local.set 12
          local.get 12
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 0
          ref.cast (ref 5)
          i32.const 0
          local.get 10
          ref.cast (ref 14)
          struct.get 14 1
          array.copy 5 5
          local.get 10
          ref.cast (ref 14)
          local.get 12
          struct.set 14 0
          local.get 10
          ref.cast (ref 14)
          local.get 12
          ref.cast (ref 5)
          array.len
          struct.set 14 2
        end
        local.get 10
        ref.cast (ref 14)
        struct.get 14 0
        ref.cast (ref 5)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        local.get 19
        array.set 5
        local.get 10
        ref.cast (ref 14)
        local.get 10
        ref.cast (ref 14)
        struct.get 14 1
        i32.const 1
        i32.add
        struct.set 14 1
        i32.const 7
        local.get 4
        ref.cast (ref 14)
        struct.new 85
        call 99
        local.set 20
        block ;; label = @3
          local.get 20
          ref.cast (ref 11)
          struct.get 11 0
          i32.const 1
          i32.eq
          if (result i32) ;; label = @4
            local.get 20
            ref.cast (ref 13)
            struct.get 13 6
            ref.cast (ref 93)
            struct.get 93 0
            i32.const 3
            i32.eq
            if (result i32) ;; label = @5
              local.get 20
              ref.cast (ref 13)
              struct.get 13 6
              ref.cast (ref 94)
              struct.get 94 1
              v128.const i32x4 0x00000030 0x00000000 0x00000000 0x00000000
              array.new_fixed 154 1
              i32.const 0
              i32.const 1
              struct.new 155
              call 6
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
      array.new_fixed 154 1
      i32.const 0
      i32.const 16
      struct.new 156
      call 101
    else
      i32.const 1
      v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
      array.new_fixed 154 1
      i32.const 0
      i32.const 4
      struct.new 156
      call 101
    end
  )
)
