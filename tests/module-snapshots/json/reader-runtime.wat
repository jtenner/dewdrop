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
  (type (;12;) (func (result eqref)))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param eqref eqref)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result eqref)))
  (type (;18;) (func (result eqref)))
  (type (;19;) (func (param i32) (result eqref)))
  (type (;20;) (func (param eqref eqref)))
  (type (;21;) (func (param eqref) (result eqref)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param eqref i32 i32) (result eqref)))
  (type (;28;) (func (result eqref)))
  (type (;29;) (func (param i32) (result eqref)))
  (type (;30;) (func (param eqref eqref)))
  (type (;31;) (func (param eqref) (result eqref)))
  (type (;32;) (func (param eqref) (result i32)))
  (type (;33;) (func (param eqref) (result i32)))
  (type (;34;) (func (param eqref) (result eqref)))
  (type (;35;) (func (param eqref eqref) (result i32)))
  (type (;36;) (func (param eqref i32) (result i32)))
  (type (;37;) (func (param eqref i32 i32) (result eqref)))
  (type (;38;) (sub (struct (field i32))))
  (type (;39;) (sub final 38 (struct (field i32) (field i32))))
  (type (;40;) (struct (field eqref) (field (ref 7))))
  (type (;41;) (struct (field eqref) (field (ref 7))))
  (type (;42;) (func (param eqref eqref) (result (ref 3))))
  (type (;43;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;44;) (func (param eqref) (result (ref 40))))
  (type (;45;) (func (param (ref 40) i32) (result (ref 3))))
  (type (;46;) (func (result (ref 41))))
  (type (;47;) (func (param i32) (result (ref 41))))
  (type (;48;) (func (param (ref 41)) (result i32)))
  (type (;49;) (func (param (ref 41)) (result i32)))
  (type (;50;) (func (param (ref 41)) (result (ref 3))))
  (type (;51;) (func (param (ref 41) eqref) (result (ref 3))))
  (type (;52;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;53;) (func (param eqref eqref) (result (ref 3))))
  (type (;54;) (func (param i64) (result i64)))
  (type (;55;) (func (param i64 i64) (result i64)))
  (type (;56;) (func (param i64 i64) (result i32)))
  (type (;57;) (func (param eqref) (result i64)))
  (type (;58;) (func (param eqref) (result i32)))
  (type (;59;) (func (param eqref) (result eqref)))
  (type (;60;) (func (param eqref eqref) (result i32)))
  (type (;61;) (func (result eqref)))
  (type (;62;) (func (param eqref) (result i32)))
  (type (;63;) (func (param eqref eqref)))
  (type (;64;) (func (param eqref i32)))
  (type (;65;) (func (param eqref i32)))
  (type (;66;) (func (param eqref eqref)))
  (type (;67;) (func (param eqref) (result eqref)))
  (type (;68;) (func (param eqref i32) (result v128)))
  (type (;69;) (sub (struct (field i32))))
  (type (;70;) (sub final 69 (struct (field i32) (field i32))))
  (type (;71;) (sub final 69 (struct (field i32) (field eqref))))
  (type (;72;) (sub final 69 (struct (field i32) (field (ref 6)))))
  (type (;73;) (sub final 69 (struct (field i32) (field (ref 6)))))
  (type (;74;) (struct (field eqref) (field (ref 69))))
  (type (;75;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;76;) (sub (struct (field i32))))
  (type (;77;) (sub final 76 (struct (field i32) (field i32))))
  (type (;78;) (sub final 76 (struct (field i32) (field i32) (field i8))))
  (type (;79;) (sub final 76 (struct (field i32) (field i32) (field eqref))))
  (type (;80;) (sub (struct (field i32))))
  (type (;81;) (sub final 80 (struct (field i32) (field eqref))))
  (type (;82;) (sub (struct (field i32))))
  (type (;83;) (sub final 82 (struct (field i32) (field (ref 38)))))
  (type (;84;) (sub final 82 (struct (field i32) (field (ref 76)))))
  (type (;85;) (sub (struct (field i32))))
  (type (;86;) (sub final 85 (struct (field i32) (field (ref 38)))))
  (type (;87;) (sub final 85 (struct (field i32) (field (ref 80)))))
  (type (;88;) (struct (field eqref) (field (ref 6)) (field (ref 6)) (field (ref 75))))
  (type (;89;) (struct (field eqref) (field i32) (field i32) (field (ref 6)) (field (ref 6)) (field (ref 6))))
  (type (;90;) (func))
  (type (;91;) (func (result (ref 75))))
  (type (;92;) (func (param (ref 88)) (result i32)))
  (type (;93;) (func (param (ref 88) i32)))
  (type (;94;) (func (param (ref 88)) (result i32)))
  (type (;95;) (func (param (ref 88) i32)))
  (type (;96;) (func (param i32) (result i32)))
  (type (;97;) (func (param i32) (result i32)))
  (type (;98;) (func (param eqref i32) (result i32)))
  (type (;99;) (func (param eqref i32) (result i32)))
  (type (;100;) (func (param i32) (result i32)))
  (type (;101;) (func (param eqref i32) (result i32)))
  (type (;102;) (func (param (ref 88))))
  (type (;103;) (func (param i32) (result i32)))
  (type (;104;) (func (param i32) (result i32)))
  (type (;105;) (func (param eqref i32 i32) (result i32)))
  (type (;106;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;107;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;108;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;109;) (func (param eqref i32 i32) (result i32)))
  (type (;110;) (func (param i32) (result i32)))
  (type (;111;) (func (param eqref i32) (result (ref 1))))
  (type (;112;) (func (param (ref 88) eqref i32 i32) (result i32)))
  (type (;113;) (func (param (ref 88)) (result (ref 3))))
  (type (;114;) (func (param (ref 88) eqref (ref 69)) (result (ref 3))))
  (type (;115;) (func (param (ref 88)) (result (ref 3))))
  (type (;116;) (func (param (ref 88) i32) (result (ref 3))))
  (type (;117;) (func (param eqref eqref) (result i32)))
  (type (;118;) (func (param eqref) (result i64)))
  (type (;119;) (func (param (ref 6) eqref) (result i32)))
  (type (;120;) (func (param i64) (result i32)))
  (type (;121;) (func (param i64) (result i32)))
  (type (;122;) (func (param i64 i64 i64 i64 i32 i64) (result i32)))
  (type (;123;) (func (param (ref 6) eqref) (result i32)))
  (type (;124;) (func (param (ref 88) i32) (result (ref 3))))
  (type (;125;) (func (param (ref 88) i32) (result (ref 3))))
  (type (;126;) (func (param eqref (ref 75)) (result (ref 3))))
  (type (;127;) (func (param eqref i32 (ref 75)) (result (ref 3))))
  (type (;128;) (func (param eqref i32) (result (ref 3))))
  (type (;129;) (func (param (ref 89) i32)))
  (type (;130;) (func (param (ref 89) i32)))
  (type (;131;) (func (param (ref 89) eqref)))
  (type (;132;) (func (param (ref 89) eqref)))
  (type (;133;) (func (param i32) (result i32)))
  (type (;134;) (func (param (ref 89) eqref)))
  (type (;135;) (func (param (ref 89) (ref 69) i32)))
  (type (;136;) (func (param (ref 69) i32 i32) (result (ref 3))))
  (type (;137;) (func (param eqref (ref 69) i32 i32) (result (ref 3))))
  (type (;138;) (func (param eqref (ref 69)) (result (ref 3))))
  (type (;139;) (func (param eqref i32) (result (ref 3))))
  (type (;140;) (func (param eqref (ref 69)) (result (ref 3))))
  (type (;141;) (func (param eqref i32 (ref 75)) (result (ref 3))))
  (type (;142;) (func (param eqref (ref 69) i32 i32) (result (ref 3))))
  (type (;143;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;144;) (func (param i32 eqref) (result i32)))
  (type (;145;) (func (result i32)))
  (type (;146;) (array (mut v128)))
  (type (;147;) (struct (field (ref 146)) (field i32) (field i32)))
  (type (;148;) (struct (field (ref 146)) (field i32) (field i32)))
  (type (;149;) (struct (field (ref 146)) (field i32) (field i32)))
  (type (;150;) (struct (field (mut (ref 146))) (field (mut i32)) (field (mut i32))))
  (type (;151;) (struct (field (mut (ref 146))) (field (mut i32)) (field (mut i32))))
  (type (;152;) (array (mut i32)))
  (type (;153;) (array (mut i64)))
  (type (;154;) (array (mut f32)))
  (type (;155;) (array (mut f64)))
  (type (;156;) (array (mut v128)))
  (type (;157;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 143)))
  (memory (;0;) 1)
  (export "main" (func 107))
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
    ref.cast (ref 147)
    struct.get 147 2
  )
  (func (;3;) (type 9) (param eqref) (result eqref)
    (local (ref 147))
    local.get 0
    ref.cast (ref 147)
    local.tee 1
    struct.get 147 0
    local.get 1
    struct.get 147 1
    local.get 1
    struct.get 147 2
    struct.new 148
  )
  (func (;4;) (type 10) (param eqref eqref) (result i32)
    (local (ref 147) (ref 147) (ref 146) (ref 146) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 147)
    local.set 2
    local.get 1
    ref.cast (ref 147)
    local.set 3
    local.get 2
    struct.get 147 2
    local.tee 6
    local.get 3
    struct.get 147 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 147 0
    local.set 4
    local.get 3
    struct.get 147 0
    local.set 5
    local.get 2
    struct.get 147 1
    local.set 7
    local.get 3
    struct.get 147 1
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
          array.get 146
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 146
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
          array.get 146
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
          array.get 146
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 146
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
          array.get 146
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
      array.get 146
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
      array.get 146
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
    (local (ref 147) (ref 146) i32 i32 i32 i64)
    local.get 0
    ref.cast (ref 147)
    local.set 1
    local.get 1
    struct.get 147 0
    local.set 2
    local.get 1
    struct.get 147 1
    local.set 3
    local.get 1
    struct.get 147 2
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
      array.get 146
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
  (func (;6;) (type 12) (result eqref)
    i32.const 4
    array.new_default 146
    i32.const 0
    i32.const 0
    struct.new 150
  )
  (func (;7;) (type 13) (param eqref) (result i32)
    (local (ref 150))
    local.get 0
    ref.cast (ref 150)
    local.tee 1
    struct.get 150 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 150 1
  )
  (func (;8;) (type 14) (param eqref eqref)
    (local (ref 150) (ref 147) (ref 146) (ref 146) i32 i32 i32 i32 i32 i32 (ref 146) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 150)
    local.set 2
    local.get 2
    struct.get 150 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 147)
    local.set 3
    local.get 2
    struct.get 150 0
    local.set 4
    local.get 3
    struct.get 147 0
    local.set 5
    local.get 2
    struct.get 150 1
    local.set 6
    local.get 3
    struct.get 147 1
    local.set 7
    local.get 3
    struct.get 147 2
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
      array.new_default 146
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
          array.get 146
          array.set 146
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 150 0
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
            array.get 146
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 146
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
            array.get 146
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
            array.set 146
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
            array.get 146
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
            array.set 146
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
            array.get 146
            local.get 19
            v128.bitselect
            array.set 146
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
        array.get 146
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
        array.get 146
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 146
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 150 1
  )
  (func (;9;) (type 15) (param eqref i32)
    (local (ref 150) (ref 146) i32 i32 i32 (ref 146) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 150)
    local.set 2
    local.get 2
    struct.get 150 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 150 0
    local.set 3
    local.get 2
    struct.get 150 1
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
      array.new_default 146
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
          array.get 146
          array.set 146
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 150 0
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
    array.get 146
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 146
    local.get 2
    local.get 5
    struct.set 150 1
  )
  (func (;10;) (type 16) (param eqref i32)
    (local (ref 150) (ref 146) i32 i32 i32 i32 i32 (ref 146) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 150)
    local.set 2
    local.get 2
    struct.get 150 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 150 0
    local.set 3
    local.get 2
    struct.get 150 1
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
      array.new_default 146
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
          array.get 146
          array.set 146
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 150 0
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
    array.get 146
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 146
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
      array.get 146
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 146
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
      array.get 146
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 146
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
      array.get 146
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 146
    end
    local.get 2
    local.get 6
    struct.set 150 1
  )
  (func (;11;) (type 17) (param eqref) (result eqref)
    (local (ref 150))
    local.get 0
    ref.cast (ref 150)
    local.set 1
    local.get 1
    struct.get 150 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 150 2
    local.get 1
    struct.get 150 0
    i32.const 0
    local.get 1
    struct.get 150 1
    struct.new 147
  )
  (func (;12;) (type 18) (result eqref)
    i32.const 4
    array.new_default 146
    i32.const 0
    i32.const 0
    struct.new 151
  )
  (func (;13;) (type 19) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 146
    i32.const 0
    i32.const 0
    struct.new 151
  )
  (func (;14;) (type 20) (param eqref eqref)
    (local (ref 151) (ref 148) (ref 146) (ref 146) i32 i32 i32 i32 i32 i32 (ref 146) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 151)
    local.set 2
    local.get 2
    struct.get 151 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 148)
    local.set 3
    local.get 2
    struct.get 151 0
    local.set 4
    local.get 3
    struct.get 148 0
    local.set 5
    local.get 2
    struct.get 151 1
    local.set 6
    local.get 3
    struct.get 148 1
    local.set 7
    local.get 3
    struct.get 148 2
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
      array.new_default 146
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
          array.get 146
          array.set 146
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 151 0
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
            array.get 146
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 146
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
            array.get 146
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
            array.set 146
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
            array.get 146
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
            array.set 146
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
            array.get 146
            local.get 19
            v128.bitselect
            array.set 146
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
        array.get 146
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
        array.get 146
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 146
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 151 1
  )
  (func (;15;) (type 21) (param eqref) (result eqref)
    (local (ref 151))
    local.get 0
    ref.cast (ref 151)
    local.set 1
    local.get 1
    struct.get 151 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 151 2
    local.get 1
    struct.get 151 0
    i32.const 0
    local.get 1
    struct.get 151 1
    struct.new 148
  )
  (func (;16;) (type 22) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 148)
    struct.get 148 2
  )
  (func (;17;) (type 23) (param eqref) (result i32)
    (local (ref 148) (ref 146) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 148)
    local.set 1
    local.get 1
    struct.get 148 0
    local.set 2
    local.get 1
    struct.get 148 1
    local.set 4
    local.get 1
    struct.get 148 2
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
        array.get 146
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
      array.get 146
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
        array.get 146
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
        array.get 146
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
        array.get 146
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
        array.get 146
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
        array.get 146
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
        array.get 146
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
  (func (;18;) (type 24) (param eqref) (result eqref)
    (local (ref 148))
    local.get 0
    call 17
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 148)
    local.tee 1
    struct.get 148 0
    local.get 1
    struct.get 148 1
    local.get 1
    struct.get 148 2
    struct.new 147
  )
  (func (;19;) (type 25) (param eqref eqref) (result i32)
    (local (ref 148) (ref 148) (ref 146) (ref 146) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 148)
    local.set 2
    local.get 1
    ref.cast (ref 148)
    local.set 3
    local.get 2
    struct.get 148 2
    local.tee 6
    local.get 3
    struct.get 148 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 148 0
    local.set 4
    local.get 3
    struct.get 148 0
    local.set 5
    local.get 2
    struct.get 148 1
    local.set 7
    local.get 3
    struct.get 148 1
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
          array.get 146
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 146
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
          array.get 146
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
          array.get 146
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 146
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
          array.get 146
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
      array.get 146
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
      array.get 146
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
    (local (ref 148) (ref 146) i32)
    local.get 0
    ref.cast (ref 148)
    local.set 2
    local.get 1
    local.get 2
    struct.get 148 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 148 0
    local.set 3
    local.get 2
    struct.get 148 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 146
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;21;) (type 27) (param eqref i32 i32) (result eqref)
    (local (ref 148) i32)
    local.get 0
    ref.cast (ref 148)
    local.set 3
    local.get 3
    struct.get 148 2
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
    struct.get 148 0
    local.get 3
    struct.get 148 1
    local.get 1
    i32.add
    local.get 2
    struct.new 148
  )
  (func (;22;) (type 28) (result eqref)
    call 12
  )
  (func (;23;) (type 29) (param i32) (result eqref)
    local.get 0
    call 13
  )
  (func (;24;) (type 30) (param eqref eqref)
    local.get 0
    local.get 1
    call 14
  )
  (func (;25;) (type 31) (param eqref) (result eqref)
    local.get 0
    call 15
  )
  (func (;26;) (type 32) (param eqref) (result i32)
    local.get 0
    call 16
  )
  (func (;27;) (type 33) (param eqref) (result i32)
    local.get 0
    call 17
  )
  (func (;28;) (type 34) (param eqref) (result eqref)
    local.get 0
    call 18
  )
  (func (;29;) (type 35) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 19
  )
  (func (;30;) (type 36) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 20
  )
  (func (;31;) (type 37) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 21
  )
  (func (;32;) (type 44) (param eqref) (result (ref 40))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 152
    struct.new 7
    ref.cast (ref 7)
    struct.new 40
    ref.cast (ref 40)
  )
  (func (;33;) (type 45) (param (ref 40) i32) (result (ref 3))
    (local i32 i32 i32 i32)
    local.get 0
    struct.get 40 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 152)
    i32.const 0
    array.get 152
    local.set 2
    local.get 0
    struct.get 40 0
    call 26
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
      struct.new 38
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
        array.new_fixed 146 0
        i32.const 0
        i32.const 0
        struct.new 148
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
        struct.get 40 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 152)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 152
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        struct.get 40 0
        local.get 2
        local.get 5
        call 31
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;34;) (type 46) (result (ref 41))
    i32.const 0
    call 35
    ref.cast (ref 41)
  )
  (func (;35;) (type 47) (param i32) (result (ref 41))
    (local eqref i32)
    local.get 0
    call 23
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 152
    struct.new 7
    ref.cast (ref 7)
    struct.new 41
    ref.cast (ref 41)
  )
  (func (;36;) (type 48) (param (ref 41)) (result i32)
    local.get 0
    struct.get 41 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 152)
    i32.const 1
    array.get 152
  )
  (func (;37;) (type 49) (param (ref 41)) (result i32)
    local.get 0
    struct.get 41 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 152)
    i32.const 0
    array.get 152
    i32.const 0
    i32.ne
  )
  (func (;38;) (type 50) (param (ref 41)) (result (ref 3))
    local.get 0
    call 37
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 38
      struct.new 5
    else
      local.get 0
      struct.get 41 1
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 152)
      i32.const 0
      i32.const 1
      array.set 152
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      struct.get 41 0
      call 25
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;39;) (type 51) (param (ref 41) eqref) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 37
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 38
      struct.new 5
    else
      local.get 1
      call 26
      local.set 2
      local.get 0
      call 36
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
        struct.new 38
        struct.new 5
      else
        local.get 0
        struct.get 41 0
        local.get 1
        call 24
        local.get 0
        struct.get 41 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 152)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 152
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
  (func (;40;) (type 52) (param eqref i32 i32) (result (ref 3))
    (local eqref i32 eqref i32 (ref 38) eqref i32 eqref)
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
      struct.new 38
      struct.new 5
    else
      call 22
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
              ref.cast (ref 40)
              local.get 1
              call 33
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
                    call 26
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
                      call 25
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
                        struct.new 38
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
                          struct.new 38
                          struct.new 5
                          local.set 10
                          br 9 (;@2;)
                        else
                          local.get 3
                          local.get 5
                          call 24
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
                  ref.cast (ref 38)
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
  (func (;41;) (type 53) (param eqref eqref) (result (ref 3))
    (local i32 i32 eqref i32 (ref 38) eqref i32 eqref)
    local.get 1
    call 26
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
              call 31
              local.set 4
              local.get 0
              ref.cast (ref 41)
              local.get 4
              call 39
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
                      struct.new 38
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
                        struct.new 38
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
                  ref.cast (ref 38)
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
  (func (;42;) (type 54) (param i64) (result i64)
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
  (func (;43;) (type 55) (param i64 i64) (result i64)
    local.get 0
    local.get 1
    call 42
    i64.or
  )
  (func (;44;) (type 56) (param i64 i64) (result i32)
    (local i64)
    local.get 1
    call 42
    local.set 2
    local.get 0
    local.get 2
    i64.and
    local.get 2
    i64.eq
  )
  (func (;45;) (type 57) (param eqref) (result i64)
    local.get 0
    call 5
  )
  (func (;46;) (type 58) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;47;) (type 59) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;48;) (type 60) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;49;) (type 61) (result eqref)
    call 6
  )
  (func (;50;) (type 62) (param eqref) (result i32)
    local.get 0
    call 7
  )
  (func (;51;) (type 63) (param eqref eqref)
    local.get 0
    local.get 1
    call 8
  )
  (func (;52;) (type 64) (param eqref i32)
    local.get 0
    local.get 1
    call 9
  )
  (func (;53;) (type 65) (param eqref i32)
    local.get 0
    local.get 1
    call 10
  )
  (func (;54;) (type 66) (param eqref eqref)
    local.get 0
    local.get 1
    call 18
    call 8
  )
  (func (;55;) (type 67) (param eqref) (result eqref)
    local.get 0
    call 11
  )
  (func (;56;) (type 68) (param eqref i32) (result v128)
    (local (ref 148) (ref 146) i32 v128)
    local.get 0
    ref.cast (ref 148)
    local.set 2
    local.get 1
    local.get 2
    struct.get 148 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 148 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 148 0
    local.set 3
    local.get 2
    struct.get 148 1
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
      array.get 146
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 146
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
      array.get 146
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
  (func (;57;) (type 90))
  (func (;58;) (type 91) (result (ref 75))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 75
    ref.cast (ref 75)
  )
  (func (;59;) (type 92) (param (ref 88)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 88 1
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
    ref.cast (ref 152)
    local.get 2
    array.get 152
  )
  (func (;60;) (type 93) (param (ref 88) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 88 1
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
    ref.cast (ref 152)
    local.get 3
    local.get 5
    array.set 152
  )
  (func (;61;) (type 94) (param (ref 88)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 88 2
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
    ref.cast (ref 152)
    local.get 2
    array.get 152
  )
  (func (;62;) (type 95) (param (ref 88) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 88 2
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
    ref.cast (ref 152)
    local.get 3
    local.get 5
    array.set 152
  )
  (func (;63;) (type 96) (param i32) (result i32)
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
  (func (;64;) (type 97) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;65;) (type 98) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 26
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
              call 56
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
                call 64
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
              call 30
              call 63
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
  (func (;66;) (type 99) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 26
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
              call 56
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
                call 64
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
              call 30
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
  (func (;67;) (type 100) (param i32) (result i32)
    local.get 0
    call 63
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
  (func (;68;) (type 101) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 26
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
              call 56
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
                call 64
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
              call 30
              call 67
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
  (func (;69;) (type 102) (param (ref 88))
    local.get 0
    local.get 0
    struct.get 88 0
    local.get 0
    call 59
    call 65
    call 60
  )
  (func (;70;) (type 103) (param i32) (result i32)
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
  (func (;71;) (type 104) (param i32) (result i32)
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
  (func (;72;) (type 105) (param eqref i32 i32) (result i32)
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
              call 30
              call 70
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
  (func (;73;) (type 106) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 30
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
          call 30
          call 70
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
        call 30
        call 71
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 72
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
  (func (;74;) (type 107) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 30
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
        call 30
        call 70
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
        call 72
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
  (func (;75;) (type 108) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 30
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 30
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
        call 30
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 30
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
        call 30
        call 70
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
        call 72
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
  (func (;76;) (type 109) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 30
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
      call 73
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
          call 74
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
              call 75
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
  (func (;77;) (type 110) (param i32) (result i32)
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
  (func (;78;) (type 111) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 26
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 26
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
      call 30
      call 77
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 30
      call 77
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 30
      call 77
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 30
      call 77
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
  (func (;79;) (type 112) (param (ref 88) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 50
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 88 3
      struct.get 75 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 88 3
      struct.get 75 3
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
        struct.get 88 0
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 31
        call 54
      else
      end
      i32.const 1
    end
  )
  (func (;80;) (type 113) (param (ref 88)) (result (ref 3))
    (local i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 59
    local.set 1
    local.get 0
    struct.get 88 0
    call 26
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
      struct.new 77
      struct.new 5
    else
      local.get 0
      struct.get 88 0
      local.get 1
      call 30
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
        struct.get 88 0
        local.get 1
        call 30
        struct.new 78
        struct.new 5
      else
        call 49
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
                struct.get 88 0
                local.get 5
                call 66
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
                  struct.new 77
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                local.get 3
                local.get 4
                local.get 6
                call 79
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
                  struct.new 77
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                struct.get 88 0
                local.get 6
                call 30
                local.set 7
                local.get 7
                i32.const 34
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 6
                  i32.const 1
                  i32.add
                  call 60
                  i32.const 0
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  call 55
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
                    struct.new 77
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
                      struct.new 78
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
                        struct.new 77
                        struct.new 5
                        local.set 15
                        br 7 (;@3;)
                      else
                        local.get 0
                        struct.get 88 0
                        local.get 6
                        i32.const 1
                        i32.add
                        call 30
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
                          call 52
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
                            call 52
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
                              call 52
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
                                call 52
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
                                  call 52
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
                                    call 52
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
                                      struct.get 88 0
                                      local.get 6
                                      i32.const 2
                                      i32.add
                                      call 78
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
                                            struct.new 77
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
                                              struct.get 88 0
                                              local.get 10
                                              call 30
                                              i32.const 92
                                              i32.ne
                                            end
                                            if (result i32) ;; label = @21
                                              i32.const 1
                                            else
                                              local.get 0
                                              struct.get 88 0
                                              local.get 10
                                              i32.const 1
                                              i32.add
                                              call 30
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
                                              struct.new 77
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                            end
                                            local.get 0
                                            struct.get 88 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 78
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
                                                  call 53
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
                                                struct.new 77
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
                                              struct.new 77
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                              local.get 3
                                              local.get 9
                                              call 53
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
                                      struct.new 77
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
                        call 50
                        local.get 0
                        struct.get 88 3
                        struct.get 75 3
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
                          struct.new 77
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
  (func (;81;) (type 114) (param (ref 88) eqref (ref 69)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 59
    local.set 3
    local.get 0
    struct.get 88 0
    call 26
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 26
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
      struct.new 77
      struct.new 5
    else
      local.get 0
      struct.get 88 0
      local.get 3
      local.get 1
      call 26
      call 31
      local.get 1
      call 29
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
        struct.new 77
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 26
        i32.add
        call 60
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
  (func (;82;) (type 115) (param (ref 88)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 59
    local.set 1
    local.get 0
    struct.get 88 0
    local.get 1
    call 68
    local.set 2
    local.get 0
    struct.get 88 0
    local.get 1
    local.get 2
    call 76
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
      struct.new 77
      struct.new 5
    else
      local.get 0
      local.get 2
      call 60
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      local.get 0
      struct.get 88 0
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 31
      call 28
      struct.new 71
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;83;) (type 116) (param (ref 88) i32) (result (ref 3))
    (local eqref (ref 76) (ref 69) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 157
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 59
    i32.const 1
    i32.add
    call 60
    local.get 0
    call 69
    local.get 0
    call 59
    local.get 0
    struct.get 88 0
    call 26
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 88 0
      local.get 0
      call 59
      call 30
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 59
      i32.const 1
      i32.add
      call 60
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 4
      local.get 2
      ref.cast (ref 6)
      struct.new 72
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
              call 92
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
                    ref.cast (ref 69)
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
                      array.new_default 157
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
                          ref.cast (ref 157)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 157)
                          local.get 8
                          array.get 157
                          array.set 157
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
                      ref.cast (ref 157)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 157)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 157
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
                  ref.cast (ref 76)
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
              call 69
              local.get 0
              call 59
              local.set 5
              local.get 5
              local.get 0
              struct.get 88 0
              call 26
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
                struct.new 77
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 88 0
              local.get 5
              call 30
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 60
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 4
                local.get 2
                ref.cast (ref 6)
                struct.new 72
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
                  call 60
                  local.get 0
                  call 69
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
                  struct.new 78
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
  (func (;84;) (type 117) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 48
  )
  (func (;85;) (type 118) (param eqref) (result i64)
    local.get 0
    call 45
  )
  (func (;86;) (type 119) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 157)
              local.get 4
              array.get 157
              ref.cast (ref 74)
              struct.get 74 0
              local.get 1
              call 84
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
  (func (;87;) (type 120) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;88;) (type 121) (param i64) (result i32)
    local.get 0
    i64.const 43
    i64.shr_u
    i64.const 3
    i64.and
    call 87
  )
  (func (;89;) (type 122) (param i64 i64 i64 i64 i32 i64) (result i32)
    local.get 4
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      local.get 0
      local.get 5
      call 44
    else
      local.get 4
      i32.const 1
      i32.eq
      if (result i32) ;; label = @2
        local.get 1
        local.get 5
        call 44
      else
        local.get 4
        i32.const 2
        i32.eq
        if (result i32) ;; label = @3
          local.get 2
          local.get 5
          call 44
        else
          local.get 3
          local.get 5
          call 44
        end
      end
    end
  )
  (func (;90;) (type 123) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 157)
              local.get 4
              array.get 157
              local.get 1
              call 84
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
  (func (;91;) (type 124) (param (ref 88) i32) (result (ref 3))
    (local eqref i64 i64 i64 i64 i32 eqref (ref 76) eqref i32 i32 i64 i32 (ref 74) i64 i32 i32 i32 i32 (ref 69) (ref 76) (ref 69) i32 i32 eqref eqref eqref i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 157
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
    call 59
    i32.const 1
    i32.add
    call 60
    local.get 0
    call 69
    local.get 0
    call 59
    local.get 0
    struct.get 88 0
    call 26
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 88 0
      local.get 0
      call 59
      call 30
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 59
      i32.const 1
      i32.add
      call 60
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 6)
      struct.new 73
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
              call 59
              local.set 7
              local.get 7
              local.get 0
              struct.get 88 0
              call 26
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
                struct.new 77
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 88 0
              local.get 7
              call 30
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
                struct.get 88 0
                local.get 7
                call 30
                struct.new 78
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              call 80
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
                  ref.cast (ref 76)
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
                call 45
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
                          ref.cast (ref 157)
                          local.get 29
                          array.get 157
                          ref.cast (ref 74)
                          ref.cast (ref 74)
                          local.set 15
                          local.get 15
                          ref.cast (ref 74)
                          struct.get 74 0
                          call 85
                          local.set 16
                          local.get 16
                          call 88
                          local.set 17
                          local.get 17
                          i32.const 0
                          i32.eq
                          if ;; label = @12
                            local.get 3
                            local.get 16
                            call 43
                            local.set 3
                          else
                            local.get 17
                            i32.const 1
                            i32.eq
                            if ;; label = @13
                              local.get 4
                              local.get 16
                              call 43
                              local.set 4
                            else
                              local.get 17
                              i32.const 2
                              i32.eq
                              if ;; label = @14
                                local.get 5
                                local.get 16
                                call 43
                                local.set 5
                              else
                                local.get 6
                                local.get 16
                                call 43
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
                        call 57
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
                call 88
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
                call 89
                if (result i32) ;; label = @7
                  local.get 2
                  ref.cast (ref 6)
                  local.get 10
                  call 86
                else
                  i32.const 0
                end
              else
                local.get 2
                ref.cast (ref 6)
                local.get 10
                call 86
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
                struct.new 79
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
                  call 43
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
                    call 43
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
                      call 43
                      local.set 5
                    else
                      local.get 12
                      if ;; label = @10
                        local.get 6
                        local.get 13
                        call 43
                        local.set 6
                      else
                      end
                    end
                  end
                end
              end
              local.get 0
              call 69
              local.get 0
              call 59
              local.set 20
              local.get 20
              local.get 0
              struct.get 88 0
              call 26
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
                struct.new 77
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 88 0
              local.get 20
              call 30
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
                struct.get 88 0
                local.get 20
                call 30
                struct.new 78
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 20
              i32.const 1
              i32.add
              call 60
              local.get 0
              call 69
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 92
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
                    ref.cast (ref 69)
                    local.set 21
                    local.get 21
                    local.set 33
                    br 2 (;@6;)
                  end
                  local.get 32
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 76)
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
              ref.cast (ref 69)
              local.set 23
              local.get 2
              local.get 10
              local.get 23
              ref.cast (ref 69)
              struct.new 74
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
                array.new_default 157
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
                    ref.cast (ref 157)
                    local.get 29
                    local.get 28
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 157)
                    local.get 29
                    array.get 157
                    array.set 157
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
                ref.cast (ref 157)
                array.len
                struct.set 6 2
              end
              local.get 28
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 157)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              local.get 34
              array.set 157
              local.get 28
              ref.cast (ref 6)
              local.get 28
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 69
              local.get 0
              call 59
              local.set 24
              local.get 24
              local.get 0
              struct.get 88 0
              call 26
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
                struct.new 77
                struct.new 5
                local.set 36
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 88 0
              local.get 24
              call 30
              local.set 25
              local.get 25
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 24
                i32.const 1
                i32.add
                call 60
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 6)
                struct.new 73
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
                  call 60
                  local.get 0
                  call 69
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
                  struct.new 78
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
  (func (;92;) (type 125) (param (ref 88) i32) (result (ref 3))
    (local i32 i32 eqref (ref 76) eqref eqref)
    local.get 1
    local.get 0
    struct.get 88 3
    struct.get 75 1
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
      struct.new 77
      struct.new 5
    else
      local.get 0
      call 61
      local.get 0
      struct.get 88 3
      struct.get 75 2
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
        call 59
        struct.new 77
        struct.new 5
      else
        local.get 0
        local.get 0
        call 61
        i32.const 1
        i32.add
        call 62
        local.get 0
        call 69
        local.get 0
        call 59
        local.set 2
        local.get 2
        local.get 0
        struct.get 88 0
        call 26
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
          struct.new 77
          struct.new 5
        else
          local.get 0
          struct.get 88 0
          local.get 2
          call 30
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 146 1
            i32.const 0
            i32.const 4
            struct.new 148
            i32.const 0
            struct.new 69
            call 81
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 146 1
              i32.const 0
              i32.const 4
              struct.new 148
              i32.const 1
              i32.const 1
              struct.new 70
              call 81
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 146 1
                i32.const 0
                i32.const 5
                struct.new 148
                i32.const 1
                i32.const 0
                struct.new 70
                call 81
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 80
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
                        struct.new 71
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 76)
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
                    call 83
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 91
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 70
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 82
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
                        struct.new 78
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
  (func (;93;) (type 126) (param eqref (ref 75)) (result (ref 3))
    (local i32 eqref eqref (ref 88) (ref 76) (ref 69) eqref i32 eqref i32 i32 eqref eqref)
    local.get 0
    call 26
    local.set 2
    local.get 2
    local.get 1
    struct.get 75 0
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
      struct.new 77
      struct.new 5
    else
      local.get 0
      call 27
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
        struct.new 76
        struct.new 5
      else
        i32.const 1
        local.set 9
        local.get 9
        array.new_default 152
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
          array.new_default 152
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
              ref.cast (ref 152)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 152)
              local.get 9
              array.get 152
              array.set 152
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
          ref.cast (ref 152)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 152)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 11
        array.set 152
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
        array.new_default 152
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
          array.new_default 152
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
              ref.cast (ref 152)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 152)
              local.get 9
              array.get 152
              array.set 152
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
          ref.cast (ref 152)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 152)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 12
        array.set 152
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
        ref.cast (ref 75)
        struct.new 88
        local.set 5
        local.get 5
        i32.const 0
        call 92
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
              ref.cast (ref 69)
              local.set 7
              local.get 5
              call 69
              local.get 5
              call 59
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
                call 59
                struct.new 77
                struct.new 5
              end
              local.set 14
              br 2 (;@3;)
            end
            local.get 13
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 76)
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
  (func (;94;) (type 129) (param (ref 89) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 89 3
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
    ref.cast (ref 152)
    local.get 3
    array.get 152
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 89 3
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
      ref.cast (ref 152)
      local.get 3
      local.get 5
      array.set 152
    else
    end
  )
  (func (;95;) (type 130) (param (ref 89) i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 89 3
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
    ref.cast (ref 152)
    local.get 3
    array.get 152
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 89 0
      call 50
      local.get 0
      struct.get 89 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 94
      else
        local.get 0
        struct.get 89 0
        local.get 1
        call 52
      end
    end
  )
  (func (;96;) (type 131) (param (ref 89) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 89 0
    call 50
    local.set 2
    local.get 1
    call 46
    local.set 3
    local.get 0
    struct.get 89 3
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
    ref.cast (ref 152)
    local.get 5
    array.get 152
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 89 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 89 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 94
      else
        local.get 0
        struct.get 89 0
        local.get 1
        call 51
      end
    end
  )
  (func (;97;) (type 132) (param (ref 89) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 89 0
    call 50
    local.set 2
    local.get 1
    call 26
    local.set 3
    local.get 0
    struct.get 89 3
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
    ref.cast (ref 152)
    local.get 5
    array.get 152
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 89 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 89 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 94
      else
        local.get 0
        struct.get 89 0
        local.get 1
        call 54
      end
    end
  )
  (func (;98;) (type 133) (param i32) (result i32)
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
  (func (;99;) (type 134) (param (ref 89) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    i32.const 34
    call 95
    local.get 1
    call 47
    local.set 2
    local.get 2
    call 26
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
              struct.get 89 3
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
              ref.cast (ref 152)
              local.get 10
              array.get 152
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 66
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
                call 31
                call 97
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
                call 30
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
                  call 95
                  local.get 0
                  local.get 7
                  call 95
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
                    call 95
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
                    call 95
                  else
                    local.get 0
                    i32.const 92
                    call 95
                    local.get 0
                    i32.const 117
                    call 95
                    local.get 0
                    i32.const 48
                    call 95
                    local.get 0
                    i32.const 48
                    call 95
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 98
                    call 95
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 98
                    call 95
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
    call 95
  )
  (func (;100;) (type 135) (param (ref 89) (ref 69) i32)
    (local i32 eqref eqref eqref eqref i32 eqref eqref eqref i64 i64 i64 i64 i32 i32 eqref (ref 74) i64 i32 i32 eqref i32 eqref eqref i32 eqref eqref i32 eqref)
    local.get 0
    struct.get 89 3
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
    ref.cast (ref 152)
    local.get 24
    array.get 152
    i32.const 0
    i32.ne
    if ;; label = @1
      call 57
    else
      local.get 2
      local.get 0
      struct.get 89 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 94
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
                        ref.cast (ref 69)
                        struct.get 69 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;) 4 (;@6;) 5 (;@5;) 6 (;@4;)
                      end
                      local.get 0
                      v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                      array.new_fixed 146 1
                      i32.const 0
                      i32.const 4
                      struct.new 147
                      call 96
                      br 6 (;@3;)
                    end
                    local.get 31
                    ref.cast (ref 70)
                    struct.get 70 1
                    local.set 3
                    local.get 3
                    if ;; label = @9
                      local.get 0
                      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                      array.new_fixed 146 1
                      i32.const 0
                      i32.const 4
                      struct.new 147
                      call 96
                    else
                      local.get 0
                      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                      array.new_fixed 146 1
                      i32.const 0
                      i32.const 5
                      struct.new 147
                      call 96
                    end
                    br 5 (;@3;)
                  end
                  local.get 31
                  ref.cast (ref 71)
                  struct.get 71 1
                  local.set 4
                  local.get 4
                  call 47
                  local.set 5
                  local.get 5
                  i32.const 0
                  local.get 5
                  call 26
                  call 76
                  if ;; label = @8
                    local.get 0
                    local.get 4
                    call 96
                  else
                    local.get 0
                    struct.get 89 4
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
                      array.new_default 157
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
                          ref.cast (ref 157)
                          local.get 24
                          local.get 23
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 157)
                          local.get 24
                          array.get 157
                          array.set 157
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
                      ref.cast (ref 157)
                      array.len
                      struct.set 6 2
                    end
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 157)
                    local.get 23
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 26
                    array.set 157
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
                    call 94
                  end
                  br 4 (;@3;)
                end
                local.get 31
                ref.cast (ref 71)
                struct.get 71 1
                local.set 6
                local.get 0
                local.get 6
                call 99
                br 3 (;@3;)
              end
              local.get 31
              ref.cast (ref 72)
              struct.get 72 1
              local.set 7
              local.get 0
              i32.const 91
              call 95
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
                        struct.get 89 3
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
                        ref.cast (ref 152)
                        local.get 24
                        array.get 152
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
                          call 95
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
                        ref.cast (ref 157)
                        local.get 24
                        array.get 157
                        local.get 23
                        ref.cast (ref 6)
                        local.get 24
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        ref.cast (ref 69)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 100
                        i32.const 1
                        local.set 27
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 57
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
              call 95
              br 2 (;@3;)
            end
            local.get 31
            ref.cast (ref 73)
            struct.get 73 1
            local.set 10
            local.get 0
            i32.const 123
            call 95
            i32.const 0
            array.new_default 157
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
                      struct.get 89 3
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
                      ref.cast (ref 152)
                      local.get 24
                      array.get 152
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
                      ref.cast (ref 157)
                      local.get 24
                      array.get 157
                      local.get 23
                      ref.cast (ref 6)
                      local.get 24
                      i32.const 1
                      i32.add
                      struct.set 6 1
                      ref.cast (ref 74)
                      ref.cast (ref 74)
                      local.set 19
                      local.get 16
                      if (result i64) ;; label = @10
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 0
                        call 85
                      else
                        i64.const 0
                      end
                      local.set 20
                      local.get 16
                      if (result i32) ;; label = @10
                        local.get 20
                        call 88
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
                        call 89
                        if (result i32) ;; label = @11
                          local.get 11
                          ref.cast (ref 6)
                          local.get 19
                          ref.cast (ref 74)
                          struct.get 74 0
                          call 90
                        else
                          i32.const 0
                        end
                      else
                        local.get 11
                        ref.cast (ref 6)
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 0
                        call 90
                      end
                      local.set 22
                      local.get 22
                      if ;; label = @10
                        local.get 0
                        struct.get 89 5
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 0
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
                          array.new_default 157
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
                              ref.cast (ref 157)
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 157)
                              local.get 24
                              array.get 157
                              array.set 157
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
                          ref.cast (ref 157)
                          array.len
                          struct.set 6 2
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 157)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 28
                        array.set 157
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
                        call 94
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
                          call 43
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
                            call 43
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
                              call 43
                              local.set 14
                            else
                              local.get 16
                              if ;; label = @14
                                local.get 15
                                local.get 20
                                call 43
                                local.set 15
                              else
                              end
                            end
                          end
                        end
                        local.get 11
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 0
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
                          array.new_default 157
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
                              ref.cast (ref 157)
                              local.get 24
                              local.get 23
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 157)
                              local.get 24
                              array.get 157
                              array.set 157
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
                          ref.cast (ref 157)
                          array.len
                          struct.set 6 2
                        end
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 157)
                        local.get 23
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 29
                        array.set 157
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
                          call 95
                        end
                        local.get 0
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 0
                        call 99
                        local.get 0
                        i32.const 58
                        call 95
                        local.get 0
                        local.get 19
                        ref.cast (ref 74)
                        struct.get 74 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 100
                      end
                      i32.const 1
                      local.set 30
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 57
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
            call 95
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;101;) (type 136) (param (ref 69) i32 i32) (result (ref 3))
    (local eqref (ref 89) eqref i32 eqref i32)
    i32.const 1
    local.set 6
    local.get 6
    array.new_default 152
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
      array.new_default 152
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
          ref.cast (ref 152)
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 152)
          local.get 6
          array.get 152
          array.set 152
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
      ref.cast (ref 152)
      array.len
      struct.set 6 2
    end
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 152)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    local.get 8
    array.set 152
    local.get 5
    ref.cast (ref 6)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    i32.const 1
    i32.add
    struct.set 6 1
    call 49
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 6)
    i32.const 0
    array.new_default 157
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    i32.const 0
    array.new_default 157
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    struct.new 89
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 100
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
    ref.cast (ref 152)
    local.get 6
    array.get 152
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
      struct.new 80
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
      ref.cast (ref 152)
      local.get 6
      array.get 152
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
        ref.cast (ref 89)
        struct.get 89 4
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
        ref.cast (ref 157)
        local.get 6
        array.get 157
        struct.new 81
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
        ref.cast (ref 152)
        local.get 6
        array.get 152
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
          struct.new 80
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
          ref.cast (ref 152)
          local.get 6
          array.get 152
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
            ref.cast (ref 89)
            struct.get 89 5
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
            ref.cast (ref 157)
            local.get 6
            array.get 157
            struct.new 81
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 89)
            struct.get 89 0
            call 55
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;102;) (type 139) (param eqref i32) (result (ref 3))
    local.get 0
    local.get 1
    call 58
    call 104
    ref.cast (ref 3)
  )
  (func (;103;) (type 140) (param eqref (ref 69)) (result (ref 3))
    local.get 0
    local.get 1
    ref.cast (ref 69)
    i32.const 128
    i32.const 16777216
    call 105
    ref.cast (ref 3)
  )
  (func (;104;) (type 141) (param eqref i32 (ref 75)) (result (ref 3))
    (local eqref eqref (ref 76) (ref 69) eqref eqref eqref eqref)
    local.get 0
    local.get 1
    local.get 2
    struct.get 75 0
    call 40
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
          ref.cast (ref 75)
          call 93
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
                ref.cast (ref 69)
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
              ref.cast (ref 76)
              local.set 5
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 1
              local.get 5
              ref.cast (ref 76)
              struct.new 84
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
        ref.cast (ref 38)
        struct.new 83
        struct.new 5
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 3)
  )
  (func (;105;) (type 142) (param eqref (ref 69) i32 i32) (result (ref 3))
    (local (ref 80) eqref eqref i32 eqref eqref eqref eqref)
    local.get 1
    ref.cast (ref 69)
    local.get 2
    local.get 3
    call 101
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
          call 47
          call 41
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
              ref.cast (ref 38)
              struct.new 86
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
        ref.cast (ref 80)
        local.set 4
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 1
        local.get 4
        ref.cast (ref 80)
        struct.new 87
        struct.new 5
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 3)
  )
  (func (;106;) (type 144) (param i32 eqref) (result i32)
    (local (ref 148) (ref 146) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 148)
    local.set 2
    local.get 2
    struct.get 148 0
    local.set 3
    local.get 2
    struct.get 148 1
    local.set 4
    local.get 2
    struct.get 148 2
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
              array.get 146
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
              array.get 146
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
              array.get 146
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
              array.get 146
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
                array.get 146
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 146
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
                array.get 146
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
            array.get 146
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
  (func (;107;) (type 145) (result i32)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
    array.new_fixed 146 1
    i32.const 0
    i32.const 11
    struct.new 148
    call 32
    i32.const 3
    call 102
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
        ref.cast (ref 69)
        struct.get 69 0
        i32.const 4
        i32.eq
        if (result i32) ;; label = @3
          local.get 7
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 72)
          struct.get 72 1
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
          call 34
          local.set 1
          local.get 1
          i32.const 4
          local.get 0
          ref.cast (ref 6)
          struct.new 72
          call 103
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
              ref.cast (ref 41)
              call 38
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
                  array.new_fixed 146 1
                  i32.const 0
                  i32.const 11
                  struct.new 148
                  call 29
                  if ;; label = @8
                    i32.const 1
                    v128.const i32x4 0x6e6f736a 0x6165723a 0x2d726564 0x74697277
                    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
                    array.new_fixed 146 2
                    i32.const 0
                    i32.const 18
                    struct.new 148
                    call 106
                    local.set 4
                    br 2 (;@6;)
                  end
                end
                i32.const 1
                if ;; label = @7
                  i32.const 1
                  v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
                  array.new_fixed 146 1
                  i32.const 0
                  i32.const 4
                  struct.new 148
                  call 106
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
              array.new_fixed 146 1
              i32.const 0
              i32.const 4
              struct.new 148
              call 106
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
        array.new_fixed 146 1
        i32.const 0
        i32.const 4
        struct.new 148
        call 106
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
  )
)
