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
  (type (;11;) (func (result eqref)))
  (type (;12;) (func (param eqref) (result i32)))
  (type (;13;) (func (param eqref eqref)))
  (type (;14;) (func (param eqref i32)))
  (type (;15;) (func (param eqref i32)))
  (type (;16;) (func (param eqref) (result eqref)))
  (type (;17;) (func (result eqref)))
  (type (;18;) (func (param i32) (result eqref)))
  (type (;19;) (func (param eqref eqref)))
  (type (;20;) (func (param eqref) (result eqref)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (param eqref eqref) (result i32)))
  (type (;25;) (func (param eqref i32) (result i32)))
  (type (;26;) (func (param eqref i32 i32) (result eqref)))
  (type (;27;) (func (result eqref)))
  (type (;28;) (func (param i32) (result eqref)))
  (type (;29;) (func (param eqref eqref)))
  (type (;30;) (func (param eqref) (result eqref)))
  (type (;31;) (func (param eqref) (result i32)))
  (type (;32;) (func (param eqref) (result i32)))
  (type (;33;) (func (param eqref) (result eqref)))
  (type (;34;) (func (param eqref eqref) (result i32)))
  (type (;35;) (func (param eqref i32) (result i32)))
  (type (;36;) (func (param eqref i32 i32) (result eqref)))
  (type (;37;) (sub (struct (field i32))))
  (type (;38;) (sub final 37 (struct (field i32) (field i32))))
  (type (;39;) (struct (field eqref) (field (ref 7))))
  (type (;40;) (struct (field eqref) (field (ref 7))))
  (type (;41;) (func (param eqref eqref) (result (ref 3))))
  (type (;42;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;43;) (func (param eqref) (result (ref 39))))
  (type (;44;) (func (param (ref 39) i32) (result (ref 3))))
  (type (;45;) (func (result (ref 40))))
  (type (;46;) (func (param i32) (result (ref 40))))
  (type (;47;) (func (param (ref 40)) (result i32)))
  (type (;48;) (func (param (ref 40)) (result i32)))
  (type (;49;) (func (param (ref 40)) (result (ref 3))))
  (type (;50;) (func (param (ref 40) eqref) (result (ref 3))))
  (type (;51;) (func (param eqref i32 i32) (result (ref 3))))
  (type (;52;) (func (param eqref eqref) (result (ref 3))))
  (type (;53;) (func (param eqref) (result i32)))
  (type (;54;) (func (param eqref) (result eqref)))
  (type (;55;) (func (param eqref eqref) (result i32)))
  (type (;56;) (func (result eqref)))
  (type (;57;) (func (param eqref) (result i32)))
  (type (;58;) (func (param eqref eqref)))
  (type (;59;) (func (param eqref i32)))
  (type (;60;) (func (param eqref i32)))
  (type (;61;) (func (param eqref eqref)))
  (type (;62;) (func (param eqref) (result eqref)))
  (type (;63;) (func (param eqref i32) (result v128)))
  (type (;64;) (sub (struct (field i32))))
  (type (;65;) (sub final 64 (struct (field i32) (field i32))))
  (type (;66;) (sub final 64 (struct (field i32) (field eqref))))
  (type (;67;) (sub final 64 (struct (field i32) (field (ref 6)))))
  (type (;68;) (sub final 64 (struct (field i32) (field (ref 6)))))
  (type (;69;) (struct (field eqref) (field (ref 64))))
  (type (;70;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;71;) (sub (struct (field i32))))
  (type (;72;) (sub final 71 (struct (field i32) (field i32))))
  (type (;73;) (sub final 71 (struct (field i32) (field i32) (field i8))))
  (type (;74;) (sub final 71 (struct (field i32) (field i32) (field eqref))))
  (type (;75;) (sub (struct (field i32))))
  (type (;76;) (sub final 75 (struct (field i32) (field eqref))))
  (type (;77;) (sub (struct (field i32))))
  (type (;78;) (sub final 77 (struct (field i32) (field (ref 37)))))
  (type (;79;) (sub final 77 (struct (field i32) (field (ref 71)))))
  (type (;80;) (sub (struct (field i32))))
  (type (;81;) (sub final 80 (struct (field i32) (field (ref 37)))))
  (type (;82;) (sub final 80 (struct (field i32) (field (ref 75)))))
  (type (;83;) (struct (field eqref) (field (ref 6)) (field (ref 6)) (field (ref 70))))
  (type (;84;) (struct (field eqref) (field i32) (field i32) (field (ref 6)) (field (ref 6)) (field (ref 6))))
  (type (;85;) (func))
  (type (;86;) (func (result (ref 70))))
  (type (;87;) (func (param (ref 83)) (result i32)))
  (type (;88;) (func (param (ref 83) i32)))
  (type (;89;) (func (param (ref 83)) (result i32)))
  (type (;90;) (func (param (ref 83) i32)))
  (type (;91;) (func (param i32) (result i32)))
  (type (;92;) (func (param i32) (result i32)))
  (type (;93;) (func (param eqref i32) (result i32)))
  (type (;94;) (func (param eqref i32) (result i32)))
  (type (;95;) (func (param i32) (result i32)))
  (type (;96;) (func (param eqref i32) (result i32)))
  (type (;97;) (func (param (ref 83))))
  (type (;98;) (func (param i32) (result i32)))
  (type (;99;) (func (param i32) (result i32)))
  (type (;100;) (func (param eqref i32 i32) (result i32)))
  (type (;101;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;102;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;103;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;104;) (func (param eqref i32 i32) (result i32)))
  (type (;105;) (func (param i32) (result i32)))
  (type (;106;) (func (param eqref i32) (result (ref 1))))
  (type (;107;) (func (param (ref 83) eqref i32 i32) (result i32)))
  (type (;108;) (func (param (ref 83)) (result (ref 3))))
  (type (;109;) (func (param (ref 83) eqref (ref 64)) (result (ref 3))))
  (type (;110;) (func (param (ref 83)) (result (ref 3))))
  (type (;111;) (func (param (ref 83) i32) (result (ref 3))))
  (type (;112;) (func (param eqref eqref) (result i32)))
  (type (;113;) (func (param (ref 6) eqref) (result i32)))
  (type (;114;) (func (param (ref 6) eqref) (result i32)))
  (type (;115;) (func (param (ref 83) i32) (result (ref 3))))
  (type (;116;) (func (param (ref 83) i32) (result (ref 3))))
  (type (;117;) (func (param eqref (ref 70)) (result (ref 3))))
  (type (;118;) (func (param eqref i32 (ref 70)) (result (ref 3))))
  (type (;119;) (func (param eqref i32) (result (ref 3))))
  (type (;120;) (func (param (ref 84) i32)))
  (type (;121;) (func (param (ref 84) i32)))
  (type (;122;) (func (param (ref 84) eqref)))
  (type (;123;) (func (param (ref 84) eqref)))
  (type (;124;) (func (param i32) (result i32)))
  (type (;125;) (func (param (ref 84) eqref)))
  (type (;126;) (func (param (ref 84) (ref 64) i32)))
  (type (;127;) (func (param (ref 64) i32 i32) (result (ref 3))))
  (type (;128;) (func (param eqref (ref 64) i32 i32) (result (ref 3))))
  (type (;129;) (func (param eqref (ref 64)) (result (ref 3))))
  (type (;130;) (func (param eqref i32) (result (ref 3))))
  (type (;131;) (func (param eqref (ref 64)) (result (ref 3))))
  (type (;132;) (func (param eqref i32 (ref 70)) (result (ref 3))))
  (type (;133;) (func (param eqref (ref 64) i32 i32) (result (ref 3))))
  (type (;134;) (func (param i32 i32 i32 i32) (result i32)))
  (type (;135;) (func (param i32 eqref) (result i32)))
  (type (;136;) (func (result i32)))
  (type (;137;) (array (mut v128)))
  (type (;138;) (struct (field (ref 137)) (field i32) (field i32)))
  (type (;139;) (struct (field (ref 137)) (field i32) (field i32)))
  (type (;140;) (struct (field (ref 137)) (field i32) (field i32)))
  (type (;141;) (struct (field (mut (ref 137))) (field (mut i32)) (field (mut i32))))
  (type (;142;) (struct (field (mut (ref 137))) (field (mut i32)) (field (mut i32))))
  (type (;143;) (array (mut i32)))
  (type (;144;) (array (mut i64)))
  (type (;145;) (array (mut f32)))
  (type (;146;) (array (mut f64)))
  (type (;147;) (array (mut v128)))
  (type (;148;) (array (mut eqref)))
  (import "wasi_snapshot_preview1" "fd_write" (func (;0;) (type 134)))
  (memory (;0;) 1)
  (export "main" (func 98))
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
    ref.cast (ref 138)
    struct.get 138 2
  )
  (func (;3;) (type 9) (param eqref) (result eqref)
    (local (ref 138))
    local.get 0
    ref.cast (ref 138)
    local.tee 1
    struct.get 138 0
    local.get 1
    struct.get 138 1
    local.get 1
    struct.get 138 2
    struct.new 139
  )
  (func (;4;) (type 10) (param eqref eqref) (result i32)
    (local (ref 138) (ref 138) (ref 137) (ref 137) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 138)
    local.set 2
    local.get 1
    ref.cast (ref 138)
    local.set 3
    local.get 2
    struct.get 138 2
    local.tee 6
    local.get 3
    struct.get 138 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 138 0
    local.set 4
    local.get 3
    struct.get 138 0
    local.set 5
    local.get 2
    struct.get 138 1
    local.set 7
    local.get 3
    struct.get 138 1
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
          array.get 137
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 137
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
          array.get 137
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
          array.get 137
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 137
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
          array.get 137
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
      array.get 137
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
      array.get 137
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
  (func (;5;) (type 11) (result eqref)
    i32.const 4
    array.new_default 137
    i32.const 0
    i32.const 0
    struct.new 141
  )
  (func (;6;) (type 12) (param eqref) (result i32)
    (local (ref 141))
    local.get 0
    ref.cast (ref 141)
    local.tee 1
    struct.get 141 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 141 1
  )
  (func (;7;) (type 13) (param eqref eqref)
    (local (ref 141) (ref 138) (ref 137) (ref 137) i32 i32 i32 i32 i32 i32 (ref 137) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 141)
    local.set 2
    local.get 2
    struct.get 141 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 138)
    local.set 3
    local.get 2
    struct.get 141 0
    local.set 4
    local.get 3
    struct.get 138 0
    local.set 5
    local.get 2
    struct.get 141 1
    local.set 6
    local.get 3
    struct.get 138 1
    local.set 7
    local.get 3
    struct.get 138 2
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
      array.new_default 137
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
          array.get 137
          array.set 137
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 141 0
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
            array.get 137
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 137
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
            array.get 137
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
            array.set 137
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
            array.get 137
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
            array.set 137
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
            array.get 137
            local.get 19
            v128.bitselect
            array.set 137
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
        array.get 137
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
        array.get 137
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 137
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 141 1
  )
  (func (;8;) (type 14) (param eqref i32)
    (local (ref 141) (ref 137) i32 i32 i32 (ref 137) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 141)
    local.set 2
    local.get 2
    struct.get 141 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 141 0
    local.set 3
    local.get 2
    struct.get 141 1
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
      array.new_default 137
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
          array.get 137
          array.set 137
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 141 0
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
    array.get 137
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 137
    local.get 2
    local.get 5
    struct.set 141 1
  )
  (func (;9;) (type 15) (param eqref i32)
    (local (ref 141) (ref 137) i32 i32 i32 i32 i32 (ref 137) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 141)
    local.set 2
    local.get 2
    struct.get 141 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 141 0
    local.set 3
    local.get 2
    struct.get 141 1
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
      array.new_default 137
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
          array.get 137
          array.set 137
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 141 0
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
    array.get 137
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 137
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
      array.get 137
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 137
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
      array.get 137
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 137
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
      array.get 137
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 137
    end
    local.get 2
    local.get 6
    struct.set 141 1
  )
  (func (;10;) (type 16) (param eqref) (result eqref)
    (local (ref 141))
    local.get 0
    ref.cast (ref 141)
    local.set 1
    local.get 1
    struct.get 141 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 141 2
    local.get 1
    struct.get 141 0
    i32.const 0
    local.get 1
    struct.get 141 1
    struct.new 138
  )
  (func (;11;) (type 17) (result eqref)
    i32.const 4
    array.new_default 137
    i32.const 0
    i32.const 0
    struct.new 142
  )
  (func (;12;) (type 18) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 137
    i32.const 0
    i32.const 0
    struct.new 142
  )
  (func (;13;) (type 19) (param eqref eqref)
    (local (ref 142) (ref 139) (ref 137) (ref 137) i32 i32 i32 i32 i32 i32 (ref 137) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 142)
    local.set 2
    local.get 2
    struct.get 142 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 139)
    local.set 3
    local.get 2
    struct.get 142 0
    local.set 4
    local.get 3
    struct.get 139 0
    local.set 5
    local.get 2
    struct.get 142 1
    local.set 6
    local.get 3
    struct.get 139 1
    local.set 7
    local.get 3
    struct.get 139 2
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
      array.new_default 137
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
          array.get 137
          array.set 137
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 142 0
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
            array.get 137
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 137
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
            array.get 137
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
            array.set 137
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
            array.get 137
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
            array.set 137
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
            array.get 137
            local.get 19
            v128.bitselect
            array.set 137
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
        array.get 137
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
        array.get 137
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 137
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 142 1
  )
  (func (;14;) (type 20) (param eqref) (result eqref)
    (local (ref 142))
    local.get 0
    ref.cast (ref 142)
    local.set 1
    local.get 1
    struct.get 142 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 142 2
    local.get 1
    struct.get 142 0
    i32.const 0
    local.get 1
    struct.get 142 1
    struct.new 139
  )
  (func (;15;) (type 21) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 139)
    struct.get 139 2
  )
  (func (;16;) (type 22) (param eqref) (result i32)
    (local (ref 139) (ref 137) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 139)
    local.set 1
    local.get 1
    struct.get 139 0
    local.set 2
    local.get 1
    struct.get 139 1
    local.set 4
    local.get 1
    struct.get 139 2
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
        array.get 137
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
      array.get 137
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
        array.get 137
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
        array.get 137
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
        array.get 137
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
        array.get 137
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
        array.get 137
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
        array.get 137
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
  (func (;17;) (type 23) (param eqref) (result eqref)
    (local (ref 139))
    local.get 0
    call 16
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 139)
    local.tee 1
    struct.get 139 0
    local.get 1
    struct.get 139 1
    local.get 1
    struct.get 139 2
    struct.new 138
  )
  (func (;18;) (type 24) (param eqref eqref) (result i32)
    (local (ref 139) (ref 139) (ref 137) (ref 137) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 139)
    local.set 2
    local.get 1
    ref.cast (ref 139)
    local.set 3
    local.get 2
    struct.get 139 2
    local.tee 6
    local.get 3
    struct.get 139 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 139 0
    local.set 4
    local.get 3
    struct.get 139 0
    local.set 5
    local.get 2
    struct.get 139 1
    local.set 7
    local.get 3
    struct.get 139 1
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
          array.get 137
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 137
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
          array.get 137
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
          array.get 137
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 137
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
          array.get 137
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
      array.get 137
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
      array.get 137
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
  (func (;19;) (type 25) (param eqref i32) (result i32)
    (local (ref 139) (ref 137) i32)
    local.get 0
    ref.cast (ref 139)
    local.set 2
    local.get 1
    local.get 2
    struct.get 139 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 139 0
    local.set 3
    local.get 2
    struct.get 139 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 137
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;20;) (type 26) (param eqref i32 i32) (result eqref)
    (local (ref 139) i32)
    local.get 0
    ref.cast (ref 139)
    local.set 3
    local.get 3
    struct.get 139 2
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
    struct.get 139 0
    local.get 3
    struct.get 139 1
    local.get 1
    i32.add
    local.get 2
    struct.new 139
  )
  (func (;21;) (type 27) (result eqref)
    call 11
  )
  (func (;22;) (type 28) (param i32) (result eqref)
    local.get 0
    call 12
  )
  (func (;23;) (type 29) (param eqref eqref)
    local.get 0
    local.get 1
    call 13
  )
  (func (;24;) (type 30) (param eqref) (result eqref)
    local.get 0
    call 14
  )
  (func (;25;) (type 31) (param eqref) (result i32)
    local.get 0
    call 15
  )
  (func (;26;) (type 32) (param eqref) (result i32)
    local.get 0
    call 16
  )
  (func (;27;) (type 33) (param eqref) (result eqref)
    local.get 0
    call 17
  )
  (func (;28;) (type 34) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 18
  )
  (func (;29;) (type 35) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 19
  )
  (func (;30;) (type 36) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 20
  )
  (func (;31;) (type 43) (param eqref) (result (ref 39))
    (local eqref i32)
    local.get 0
    i32.const 1
    local.set 2
    i32.const 0
    local.get 2
    array.new 143
    struct.new 7
    ref.cast (ref 7)
    struct.new 39
    ref.cast (ref 39)
  )
  (func (;32;) (type 44) (param (ref 39) i32) (result (ref 3))
    (local i32 i32 i32 i32)
    local.get 0
    struct.get 39 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 143)
    i32.const 0
    array.get 143
    local.set 2
    local.get 0
    struct.get 39 0
    call 25
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
      struct.new 37
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
        array.new_fixed 137 0
        i32.const 0
        i32.const 0
        struct.new 139
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
        struct.get 39 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 143)
        i32.const 0
        local.get 2
        local.get 5
        i32.add
        array.set 143
        i32.const 0
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        local.get 0
        struct.get 39 0
        local.get 2
        local.get 5
        call 30
        struct.new 4
      end
    end
    ref.cast (ref 3)
  )
  (func (;33;) (type 45) (result (ref 40))
    i32.const 0
    call 34
    ref.cast (ref 40)
  )
  (func (;34;) (type 46) (param i32) (result (ref 40))
    (local eqref i32)
    local.get 0
    call 22
    i32.const 2
    local.set 2
    i32.const 0
    local.get 2
    array.new 143
    struct.new 7
    ref.cast (ref 7)
    struct.new 40
    ref.cast (ref 40)
  )
  (func (;35;) (type 47) (param (ref 40)) (result i32)
    local.get 0
    struct.get 40 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 143)
    i32.const 1
    array.get 143
  )
  (func (;36;) (type 48) (param (ref 40)) (result i32)
    local.get 0
    struct.get 40 1
    ref.cast (ref 7)
    struct.get 7 0
    ref.cast (ref 143)
    i32.const 0
    array.get 143
    i32.const 0
    i32.ne
  )
  (func (;37;) (type 49) (param (ref 40)) (result (ref 3))
    local.get 0
    call 36
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 37
      struct.new 5
    else
      local.get 0
      struct.get 40 1
      ref.cast (ref 7)
      struct.get 7 0
      ref.cast (ref 143)
      i32.const 0
      i32.const 1
      array.set 143
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      local.get 0
      struct.get 40 0
      call 24
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;38;) (type 50) (param (ref 40) eqref) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 36
    if (result eqref) ;; label = @1
      i32.const 1
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 3
      struct.new 37
      struct.new 5
    else
      local.get 1
      call 25
      local.set 2
      local.get 0
      call 35
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
        struct.new 37
        struct.new 5
      else
        local.get 0
        struct.get 40 0
        local.get 1
        call 23
        local.get 0
        struct.get 40 1
        ref.cast (ref 7)
        struct.get 7 0
        ref.cast (ref 143)
        i32.const 1
        local.get 3
        local.get 2
        i32.add
        array.set 143
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
  (func (;39;) (type 51) (param eqref i32 i32) (result (ref 3))
    (local eqref i32 eqref i32 (ref 37) eqref i32 eqref)
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
      struct.new 37
      struct.new 5
    else
      call 21
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
              ref.cast (ref 39)
              local.get 1
              call 32
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
                    call 25
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
                      call 24
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
                        struct.new 37
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
                          struct.new 37
                          struct.new 5
                          local.set 10
                          br 9 (;@2;)
                        else
                          local.get 3
                          local.get 5
                          call 23
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
                  ref.cast (ref 37)
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
  (func (;40;) (type 52) (param eqref eqref) (result (ref 3))
    (local i32 i32 eqref i32 (ref 37) eqref i32 eqref)
    local.get 1
    call 25
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
              call 30
              local.set 4
              local.get 0
              ref.cast (ref 40)
              local.get 4
              call 38
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
                      struct.new 37
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
                        struct.new 37
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
                  ref.cast (ref 37)
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
  (func (;41;) (type 53) (param eqref) (result i32)
    local.get 0
    call 2
  )
  (func (;42;) (type 54) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;43;) (type 55) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 4
  )
  (func (;44;) (type 56) (result eqref)
    call 5
  )
  (func (;45;) (type 57) (param eqref) (result i32)
    local.get 0
    call 6
  )
  (func (;46;) (type 58) (param eqref eqref)
    local.get 0
    local.get 1
    call 7
  )
  (func (;47;) (type 59) (param eqref i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;48;) (type 60) (param eqref i32)
    local.get 0
    local.get 1
    call 9
  )
  (func (;49;) (type 61) (param eqref eqref)
    local.get 0
    local.get 1
    call 17
    call 7
  )
  (func (;50;) (type 62) (param eqref) (result eqref)
    local.get 0
    call 10
  )
  (func (;51;) (type 63) (param eqref i32) (result v128)
    (local (ref 139) (ref 137) i32 v128)
    local.get 0
    ref.cast (ref 139)
    local.set 2
    local.get 1
    local.get 2
    struct.get 139 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 139 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 139 0
    local.set 3
    local.get 2
    struct.get 139 1
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
      array.get 137
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 137
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
      array.get 137
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
  (func (;52;) (type 85))
  (func (;53;) (type 86) (result (ref 70))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 70
    ref.cast (ref 70)
  )
  (func (;54;) (type 87) (param (ref 83)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 83 1
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
    ref.cast (ref 143)
    local.get 2
    array.get 143
  )
  (func (;55;) (type 88) (param (ref 83) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 83 1
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
    ref.cast (ref 143)
    local.get 3
    local.get 5
    array.set 143
  )
  (func (;56;) (type 89) (param (ref 83)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 83 2
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
    ref.cast (ref 143)
    local.get 2
    array.get 143
  )
  (func (;57;) (type 90) (param (ref 83) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 83 2
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
    ref.cast (ref 143)
    local.get 3
    local.get 5
    array.set 143
  )
  (func (;58;) (type 91) (param i32) (result i32)
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
  (func (;59;) (type 92) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;60;) (type 93) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 25
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
              call 51
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
                call 59
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
              call 29
              call 58
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
  (func (;61;) (type 94) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 25
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
              call 51
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
                call 59
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
              call 29
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
  (func (;62;) (type 95) (param i32) (result i32)
    local.get 0
    call 58
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
  (func (;63;) (type 96) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 25
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
              call 51
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
                call 59
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
              call 29
              call 62
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
  (func (;64;) (type 97) (param (ref 83))
    local.get 0
    local.get 0
    struct.get 83 0
    local.get 0
    call 54
    call 60
    call 55
  )
  (func (;65;) (type 98) (param i32) (result i32)
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
  (func (;66;) (type 99) (param i32) (result i32)
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
  (func (;67;) (type 100) (param eqref i32 i32) (result i32)
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
              call 29
              call 65
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
  (func (;68;) (type 101) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 29
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
          call 29
          call 65
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
        call 29
        call 66
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 67
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
  (func (;69;) (type 102) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 29
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
        call 29
        call 65
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
        call 67
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
  (func (;70;) (type 103) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 29
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 29
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
        call 29
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 29
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
        call 29
        call 65
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
        call 67
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
  (func (;71;) (type 104) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 29
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
      call 68
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
          call 69
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
              call 70
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
  (func (;72;) (type 105) (param i32) (result i32)
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
  (func (;73;) (type 106) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 25
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 25
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
      call 29
      call 72
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 29
      call 72
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 29
      call 72
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 29
      call 72
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
  (func (;74;) (type 107) (param (ref 83) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 45
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 83 3
      struct.get 70 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 83 3
      struct.get 70 3
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
        struct.get 83 0
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 30
        call 49
      else
      end
      i32.const 1
    end
  )
  (func (;75;) (type 108) (param (ref 83)) (result (ref 3))
    (local i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 54
    local.set 1
    local.get 0
    struct.get 83 0
    call 25
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
      struct.new 72
      struct.new 5
    else
      local.get 0
      struct.get 83 0
      local.get 1
      call 29
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
        struct.get 83 0
        local.get 1
        call 29
        struct.new 73
        struct.new 5
      else
        call 44
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
                struct.get 83 0
                local.get 5
                call 61
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
                  struct.new 72
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                local.get 3
                local.get 4
                local.get 6
                call 74
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
                  struct.new 72
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                struct.get 83 0
                local.get 6
                call 29
                local.set 7
                local.get 7
                i32.const 34
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 6
                  i32.const 1
                  i32.add
                  call 55
                  i32.const 0
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  call 50
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
                    struct.new 72
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
                      struct.new 73
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
                        struct.new 72
                        struct.new 5
                        local.set 15
                        br 7 (;@3;)
                      else
                        local.get 0
                        struct.get 83 0
                        local.get 6
                        i32.const 1
                        i32.add
                        call 29
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
                          call 47
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
                            call 47
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
                              call 47
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
                                call 47
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
                                  call 47
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
                                    call 47
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
                                      struct.get 83 0
                                      local.get 6
                                      i32.const 2
                                      i32.add
                                      call 73
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
                                            struct.new 72
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
                                              struct.get 83 0
                                              local.get 10
                                              call 29
                                              i32.const 92
                                              i32.ne
                                            end
                                            if (result i32) ;; label = @21
                                              i32.const 1
                                            else
                                              local.get 0
                                              struct.get 83 0
                                              local.get 10
                                              i32.const 1
                                              i32.add
                                              call 29
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
                                              struct.new 72
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                            end
                                            local.get 0
                                            struct.get 83 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 73
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
                                                  call 48
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
                                                struct.new 72
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
                                              struct.new 72
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                              local.get 3
                                              local.get 9
                                              call 48
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
                                      struct.new 72
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
                        call 45
                        local.get 0
                        struct.get 83 3
                        struct.get 70 3
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
                          struct.new 72
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
  (func (;76;) (type 109) (param (ref 83) eqref (ref 64)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 54
    local.set 3
    local.get 0
    struct.get 83 0
    call 25
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 25
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
      struct.new 72
      struct.new 5
    else
      local.get 0
      struct.get 83 0
      local.get 3
      local.get 1
      call 25
      call 30
      local.get 1
      call 28
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
        struct.new 72
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 25
        i32.add
        call 55
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
  (func (;77;) (type 110) (param (ref 83)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 54
    local.set 1
    local.get 0
    struct.get 83 0
    local.get 1
    call 63
    local.set 2
    local.get 0
    struct.get 83 0
    local.get 1
    local.get 2
    call 71
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
      struct.new 72
      struct.new 5
    else
      local.get 0
      local.get 2
      call 55
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      local.get 0
      struct.get 83 0
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 30
      call 27
      struct.new 66
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;78;) (type 111) (param (ref 83) i32) (result (ref 3))
    (local eqref (ref 71) (ref 64) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 148
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 54
    i32.const 1
    i32.add
    call 55
    local.get 0
    call 64
    local.get 0
    call 54
    local.get 0
    struct.get 83 0
    call 25
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 83 0
      local.get 0
      call 54
      call 29
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 54
      i32.const 1
      i32.add
      call 55
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 4
      local.get 2
      ref.cast (ref 6)
      struct.new 67
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
              call 83
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
                    ref.cast (ref 64)
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
                      array.new_default 148
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
                          ref.cast (ref 148)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 148)
                          local.get 8
                          array.get 148
                          array.set 148
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
                      ref.cast (ref 148)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 148)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 148
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
                  ref.cast (ref 71)
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
              call 64
              local.get 0
              call 54
              local.set 5
              local.get 5
              local.get 0
              struct.get 83 0
              call 25
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
                struct.new 72
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 83 0
              local.get 5
              call 29
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 55
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 4
                local.get 2
                ref.cast (ref 6)
                struct.new 67
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
                  call 55
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
                  local.get 5
                  local.get 6
                  struct.new 73
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
  (func (;79;) (type 112) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 43
  )
  (func (;80;) (type 113) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 148)
              local.get 4
              array.get 148
              ref.cast (ref 69)
              struct.get 69 0
              local.get 1
              call 79
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
  (func (;81;) (type 114) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 148)
              local.get 4
              array.get 148
              local.get 1
              call 79
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
  (func (;82;) (type 115) (param (ref 83) i32) (result (ref 3))
    (local eqref i32 eqref (ref 71) eqref i32 (ref 64) (ref 71) (ref 64) i32 i32 eqref eqref eqref eqref eqref i32 eqref eqref i32 eqref)
    i32.const 0
    array.new_default 148
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 54
    i32.const 1
    i32.add
    call 55
    local.get 0
    call 64
    local.get 0
    call 54
    local.get 0
    struct.get 83 0
    call 25
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 83 0
      local.get 0
      call 54
      call 29
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 54
      i32.const 1
      i32.add
      call 55
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 6)
      struct.new 68
      struct.new 4
    else
      i32.const 1
      local.set 21
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            local.get 21
            i32.const 1
            i32.eq
            if ;; label = @5
              local.get 0
              call 54
              local.set 3
              local.get 3
              local.get 0
              struct.get 83 0
              call 25
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 3
                struct.new 72
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 83 0
              local.get 3
              call 29
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
                local.get 3
                local.get 0
                struct.get 83 0
                local.get 3
                call 29
                struct.new 73
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              call 75
              local.set 13
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 13
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 13
                    ref.cast (ref 4)
                    struct.get 4 6
                    local.set 4
                    local.get 4
                    local.set 14
                    br 2 (;@6;)
                  end
                  local.get 13
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 71)
                  local.set 5
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 5
                  struct.new 5
                  local.set 22
                  br 5 (;@2;)
                  local.set 14
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 14
              local.set 6
              local.get 2
              ref.cast (ref 6)
              local.get 6
              call 80
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 11
                local.get 3
                local.get 6
                struct.new 74
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              call 64
              local.get 0
              call 54
              local.set 7
              local.get 7
              local.get 0
              struct.get 83 0
              call 25
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
                struct.new 72
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 83 0
              local.get 7
              call 29
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
                local.get 7
                local.get 0
                struct.get 83 0
                local.get 7
                call 29
                struct.new 73
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 7
              i32.const 1
              i32.add
              call 55
              local.get 0
              call 64
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 83
              local.set 15
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      local.get 15
                      ref.cast (ref 3)
                      struct.get 3 0
                      br_table 0 (;@9;) 1 (;@8;) 2 (;@7;)
                    end
                    local.get 15
                    ref.cast (ref 4)
                    struct.get 4 6
                    ref.cast (ref 64)
                    local.set 8
                    local.get 8
                    local.set 16
                    br 2 (;@6;)
                  end
                  local.get 15
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 71)
                  local.set 9
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 9
                  struct.new 5
                  local.set 22
                  br 5 (;@2;)
                  local.set 16
                  br 1 (;@6;)
                end
                unreachable
              end
              local.get 16
              ref.cast (ref 64)
              local.set 10
              local.get 2
              local.get 6
              local.get 10
              ref.cast (ref 64)
              struct.new 69
              local.set 20
              local.set 17
              local.get 17
              ref.cast (ref 6)
              struct.get 6 1
              local.get 17
              ref.cast (ref 6)
              struct.get 6 2
              i32.eq
              if ;; label = @6
                local.get 17
                ref.cast (ref 6)
                struct.get 6 2
                i32.eqz
                if (result i32) ;; label = @7
                  i32.const 4
                else
                  local.get 17
                  ref.cast (ref 6)
                  struct.get 6 2
                  i32.const 2
                  i32.mul
                end
                local.set 18
                local.get 18
                local.get 17
                ref.cast (ref 6)
                struct.get 6 2
                i32.le_u
                if ;; label = @7
                  unreachable
                end
                local.get 18
                array.new_default 148
                local.set 19
                i32.const 0
                local.set 18
                block ;; label = @7
                  loop ;; label = @8
                    local.get 18
                    local.get 17
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.ge_u
                    br_if 1 (;@7;)
                    local.get 19
                    ref.cast (ref 148)
                    local.get 18
                    local.get 17
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 148)
                    local.get 18
                    array.get 148
                    array.set 148
                    local.get 18
                    i32.const 1
                    i32.add
                    local.set 18
                    br 0 (;@8;)
                  end
                end
                local.get 17
                ref.cast (ref 6)
                local.get 19
                struct.set 6 0
                local.get 17
                ref.cast (ref 6)
                local.get 19
                ref.cast (ref 148)
                array.len
                struct.set 6 2
              end
              local.get 17
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 148)
              local.get 17
              ref.cast (ref 6)
              struct.get 6 1
              local.get 20
              array.set 148
              local.get 17
              ref.cast (ref 6)
              local.get 17
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 64
              local.get 0
              call 54
              local.set 11
              local.get 11
              local.get 0
              struct.get 83 0
              call 25
              i32.ge_u
              if ;; label = @6
                i32.const 1
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 11
                struct.new 72
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 83 0
              local.get 11
              call 29
              local.set 12
              local.get 12
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 11
                i32.const 1
                i32.add
                call 55
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 6)
                struct.new 68
                struct.new 4
                local.set 22
                br 4 (;@2;)
              else
                local.get 12
                i32.const 44
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 11
                  i32.const 1
                  i32.add
                  call 55
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
                  local.get 11
                  local.get 12
                  struct.new 73
                  struct.new 5
                  local.set 22
                  br 5 (;@2;)
                end
              end
              i32.const 1
              local.set 21
              br 2 (;@3;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 22
    end
    ref.cast (ref 3)
  )
  (func (;83;) (type 116) (param (ref 83) i32) (result (ref 3))
    (local i32 i32 eqref (ref 71) eqref eqref)
    local.get 1
    local.get 0
    struct.get 83 3
    struct.get 70 1
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
      struct.new 72
      struct.new 5
    else
      local.get 0
      call 56
      local.get 0
      struct.get 83 3
      struct.get 70 2
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
        call 54
        struct.new 72
        struct.new 5
      else
        local.get 0
        local.get 0
        call 56
        i32.const 1
        i32.add
        call 57
        local.get 0
        call 64
        local.get 0
        call 54
        local.set 2
        local.get 2
        local.get 0
        struct.get 83 0
        call 25
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
          struct.new 72
          struct.new 5
        else
          local.get 0
          struct.get 83 0
          local.get 2
          call 29
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 137 1
            i32.const 0
            i32.const 4
            struct.new 139
            i32.const 0
            struct.new 64
            call 76
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 137 1
              i32.const 0
              i32.const 4
              struct.new 139
              i32.const 1
              i32.const 1
              struct.new 65
              call 76
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 137 1
                i32.const 0
                i32.const 5
                struct.new 139
                i32.const 1
                i32.const 0
                struct.new 65
                call 76
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 75
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
                        struct.new 66
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 71)
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
                    call 78
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 82
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 65
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 77
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
                        struct.new 73
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
  (func (;84;) (type 117) (param eqref (ref 70)) (result (ref 3))
    (local i32 eqref eqref (ref 83) (ref 71) (ref 64) eqref i32 eqref i32 i32 eqref eqref)
    local.get 0
    call 25
    local.set 2
    local.get 2
    local.get 1
    struct.get 70 0
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
      struct.new 72
      struct.new 5
    else
      local.get 0
      call 26
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
        struct.new 71
        struct.new 5
      else
        i32.const 1
        local.set 9
        local.get 9
        array.new_default 143
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
          array.new_default 143
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
              ref.cast (ref 143)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 143)
              local.get 9
              array.get 143
              array.set 143
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
          ref.cast (ref 143)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 143)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 11
        array.set 143
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
        array.new_default 143
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
          array.new_default 143
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
              ref.cast (ref 143)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 143)
              local.get 9
              array.get 143
              array.set 143
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
          ref.cast (ref 143)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 143)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 12
        array.set 143
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
        ref.cast (ref 70)
        struct.new 83
        local.set 5
        local.get 5
        i32.const 0
        call 83
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
              ref.cast (ref 64)
              local.set 7
              local.get 5
              call 64
              local.get 5
              call 54
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
                call 54
                struct.new 72
                struct.new 5
              end
              local.set 14
              br 2 (;@3;)
            end
            local.get 13
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 71)
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
  (func (;85;) (type 120) (param (ref 84) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 84 3
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
    ref.cast (ref 143)
    local.get 3
    array.get 143
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 84 3
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
      ref.cast (ref 143)
      local.get 3
      local.get 5
      array.set 143
    else
    end
  )
  (func (;86;) (type 121) (param (ref 84) i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 84 3
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
    ref.cast (ref 143)
    local.get 3
    array.get 143
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 84 0
      call 45
      local.get 0
      struct.get 84 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 85
      else
        local.get 0
        struct.get 84 0
        local.get 1
        call 47
      end
    end
  )
  (func (;87;) (type 122) (param (ref 84) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 84 0
    call 45
    local.set 2
    local.get 1
    call 41
    local.set 3
    local.get 0
    struct.get 84 3
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
    ref.cast (ref 143)
    local.get 5
    array.get 143
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 84 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 84 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 85
      else
        local.get 0
        struct.get 84 0
        local.get 1
        call 46
      end
    end
  )
  (func (;88;) (type 123) (param (ref 84) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 84 0
    call 45
    local.set 2
    local.get 1
    call 25
    local.set 3
    local.get 0
    struct.get 84 3
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
    ref.cast (ref 143)
    local.get 5
    array.get 143
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 84 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 84 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 85
      else
        local.get 0
        struct.get 84 0
        local.get 1
        call 49
      end
    end
  )
  (func (;89;) (type 124) (param i32) (result i32)
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
  (func (;90;) (type 125) (param (ref 84) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    i32.const 34
    call 86
    local.get 1
    call 42
    local.set 2
    local.get 2
    call 25
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
              struct.get 84 3
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
              ref.cast (ref 143)
              local.get 10
              array.get 143
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 61
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
                call 30
                call 88
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
                call 29
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
                  call 86
                  local.get 0
                  local.get 7
                  call 86
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
                    call 86
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
                    call 86
                  else
                    local.get 0
                    i32.const 92
                    call 86
                    local.get 0
                    i32.const 117
                    call 86
                    local.get 0
                    i32.const 48
                    call 86
                    local.get 0
                    i32.const 48
                    call 86
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 89
                    call 86
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 89
                    call 86
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
    call 86
  )
  (func (;91;) (type 126) (param (ref 84) (ref 64) i32)
    (local i32 eqref eqref eqref eqref i32 eqref eqref eqref i32 eqref (ref 69) eqref i32 eqref eqref i32 eqref eqref i32 eqref)
    local.get 0
    struct.get 84 3
    i32.const 0
    local.set 16
    local.set 15
    local.get 16
    local.get 15
    ref.cast (ref 6)
    struct.get 6 1
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 15
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 143)
    local.get 16
    array.get 143
    i32.const 0
    i32.ne
    if ;; label = @1
      call 52
    else
      local.get 2
      local.get 0
      struct.get 84 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 85
      else
        local.get 1
        local.set 23
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              block ;; label = @6
                block ;; label = @7
                  block ;; label = @8
                    block ;; label = @9
                      block ;; label = @10
                        local.get 23
                        ref.cast (ref 64)
                        struct.get 64 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;) 4 (;@6;) 5 (;@5;) 6 (;@4;)
                      end
                      local.get 0
                      v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                      array.new_fixed 137 1
                      i32.const 0
                      i32.const 4
                      struct.new 138
                      call 87
                      br 6 (;@3;)
                    end
                    local.get 23
                    ref.cast (ref 65)
                    struct.get 65 1
                    local.set 3
                    local.get 3
                    if ;; label = @9
                      local.get 0
                      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                      array.new_fixed 137 1
                      i32.const 0
                      i32.const 4
                      struct.new 138
                      call 87
                    else
                      local.get 0
                      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                      array.new_fixed 137 1
                      i32.const 0
                      i32.const 5
                      struct.new 138
                      call 87
                    end
                    br 5 (;@3;)
                  end
                  local.get 23
                  ref.cast (ref 66)
                  struct.get 66 1
                  local.set 4
                  local.get 4
                  call 42
                  local.set 5
                  local.get 5
                  i32.const 0
                  local.get 5
                  call 25
                  call 71
                  if ;; label = @8
                    local.get 0
                    local.get 4
                    call 87
                  else
                    local.get 0
                    struct.get 84 4
                    local.get 4
                    local.set 18
                    local.set 15
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 2
                    i32.eq
                    if ;; label = @9
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.eqz
                      if (result i32) ;; label = @10
                        i32.const 4
                      else
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.const 2
                        i32.mul
                      end
                      local.set 16
                      local.get 16
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 2
                      i32.le_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 16
                      array.new_default 148
                      local.set 17
                      i32.const 0
                      local.set 16
                      block ;; label = @10
                        loop ;; label = @11
                          local.get 16
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 1
                          i32.ge_u
                          br_if 1 (;@10;)
                          local.get 17
                          ref.cast (ref 148)
                          local.get 16
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 148)
                          local.get 16
                          array.get 148
                          array.set 148
                          local.get 16
                          i32.const 1
                          i32.add
                          local.set 16
                          br 0 (;@11;)
                        end
                      end
                      local.get 15
                      ref.cast (ref 6)
                      local.get 17
                      struct.set 6 0
                      local.get 15
                      ref.cast (ref 6)
                      local.get 17
                      ref.cast (ref 148)
                      array.len
                      struct.set 6 2
                    end
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 148)
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 18
                    array.set 148
                    local.get 15
                    ref.cast (ref 6)
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.const 1
                    i32.add
                    struct.set 6 1
                    local.get 0
                    i32.const 2
                    call 85
                  end
                  br 4 (;@3;)
                end
                local.get 23
                ref.cast (ref 66)
                struct.get 66 1
                local.set 6
                local.get 0
                local.get 6
                call 90
                br 3 (;@3;)
              end
              local.get 23
              ref.cast (ref 67)
              struct.get 67 1
              local.set 7
              local.get 0
              i32.const 91
              call 86
              i32.const 1
              local.set 8
              local.get 7
              i32.const 0
              i32.const 0
              struct.new 6
              local.set 9
              i32.const 1
              local.set 19
              block ;; label = @6
                loop ;; label = @7
                  block ;; label = @8
                    local.get 19
                    i32.const 1
                    i32.eq
                    if ;; label = @9
                      local.get 9
                      local.set 15
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.lt_u
                      if (result i32) ;; label = @10
                        local.get 0
                        struct.get 84 3
                        i32.const 0
                        local.set 16
                        local.set 15
                        local.get 16
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.ge_u
                        if ;; label = @11
                          unreachable
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 143)
                        local.get 16
                        array.get 143
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
                          call 86
                        end
                        local.get 0
                        local.get 9
                        local.set 15
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.lt_u
                        if ;; label = @11
                        else
                          unreachable
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.set 16
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 148)
                        local.get 16
                        array.get 148
                        local.get 15
                        ref.cast (ref 6)
                        local.get 16
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        ref.cast (ref 64)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 91
                        i32.const 1
                        local.set 19
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 52
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
              call 86
              br 2 (;@3;)
            end
            local.get 23
            ref.cast (ref 68)
            struct.get 68 1
            local.set 10
            local.get 0
            i32.const 123
            call 86
            i32.const 0
            array.new_default 148
            i32.const 0
            i32.const 0
            struct.new 6
            local.set 11
            i32.const 1
            local.set 12
            local.get 10
            i32.const 0
            i32.const 0
            struct.new 6
            local.set 13
            i32.const 1
            local.set 22
            block ;; label = @5
              loop ;; label = @6
                block ;; label = @7
                  local.get 22
                  i32.const 1
                  i32.eq
                  if ;; label = @8
                    local.get 13
                    local.set 15
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 6)
                    struct.get 6 1
                    i32.lt_u
                    if (result i32) ;; label = @9
                      local.get 0
                      struct.get 84 3
                      i32.const 0
                      local.set 16
                      local.set 15
                      local.get 16
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.ge_u
                      if ;; label = @10
                        unreachable
                      end
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 143)
                      local.get 16
                      array.get 143
                      i32.const 0
                      i32.eq
                    else
                      i32.const 0
                    end
                    if ;; label = @9
                      local.get 13
                      local.set 15
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 1
                      i32.lt_u
                      if ;; label = @10
                      else
                        unreachable
                      end
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 1
                      local.set 16
                      local.get 15
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 6)
                      struct.get 6 0
                      ref.cast (ref 148)
                      local.get 16
                      array.get 148
                      local.get 15
                      ref.cast (ref 6)
                      local.get 16
                      i32.const 1
                      i32.add
                      struct.set 6 1
                      ref.cast (ref 69)
                      ref.cast (ref 69)
                      local.set 14
                      local.get 11
                      ref.cast (ref 6)
                      local.get 14
                      ref.cast (ref 69)
                      struct.get 69 0
                      call 81
                      if ;; label = @10
                        local.get 0
                        struct.get 84 5
                        local.get 14
                        ref.cast (ref 69)
                        struct.get 69 0
                        local.set 20
                        local.set 15
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.eq
                        if ;; label = @11
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.eqz
                          if (result i32) ;; label = @12
                            i32.const 4
                          else
                            local.get 15
                            ref.cast (ref 6)
                            struct.get 6 2
                            i32.const 2
                            i32.mul
                          end
                          local.set 16
                          local.get 16
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.le_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 16
                          array.new_default 148
                          local.set 17
                          i32.const 0
                          local.set 16
                          block ;; label = @12
                            loop ;; label = @13
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 1
                              i32.ge_u
                              br_if 1 (;@12;)
                              local.get 17
                              ref.cast (ref 148)
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 148)
                              local.get 16
                              array.get 148
                              array.set 148
                              local.get 16
                              i32.const 1
                              i32.add
                              local.set 16
                              br 0 (;@13;)
                            end
                          end
                          local.get 15
                          ref.cast (ref 6)
                          local.get 17
                          struct.set 6 0
                          local.get 15
                          ref.cast (ref 6)
                          local.get 17
                          ref.cast (ref 148)
                          array.len
                          struct.set 6 2
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 148)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 20
                        array.set 148
                        local.get 15
                        ref.cast (ref 6)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        local.get 0
                        i32.const 4
                        call 85
                      else
                        local.get 11
                        local.get 14
                        ref.cast (ref 69)
                        struct.get 69 0
                        local.set 21
                        local.set 15
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 2
                        i32.eq
                        if ;; label = @11
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.eqz
                          if (result i32) ;; label = @12
                            i32.const 4
                          else
                            local.get 15
                            ref.cast (ref 6)
                            struct.get 6 2
                            i32.const 2
                            i32.mul
                          end
                          local.set 16
                          local.get 16
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 2
                          i32.le_u
                          if ;; label = @12
                            unreachable
                          end
                          local.get 16
                          array.new_default 148
                          local.set 17
                          i32.const 0
                          local.set 16
                          block ;; label = @12
                            loop ;; label = @13
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 1
                              i32.ge_u
                              br_if 1 (;@12;)
                              local.get 17
                              ref.cast (ref 148)
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 148)
                              local.get 16
                              array.get 148
                              array.set 148
                              local.get 16
                              i32.const 1
                              i32.add
                              local.set 16
                              br 0 (;@13;)
                            end
                          end
                          local.get 15
                          ref.cast (ref 6)
                          local.get 17
                          struct.set 6 0
                          local.get 15
                          ref.cast (ref 6)
                          local.get 17
                          ref.cast (ref 148)
                          array.len
                          struct.set 6 2
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 148)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 21
                        array.set 148
                        local.get 15
                        ref.cast (ref 6)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        local.get 12
                        if ;; label = @11
                          i32.const 0
                          local.set 12
                        else
                          local.get 0
                          i32.const 44
                          call 86
                        end
                        local.get 0
                        local.get 14
                        ref.cast (ref 69)
                        struct.get 69 0
                        call 90
                        local.get 0
                        i32.const 58
                        call 86
                        local.get 0
                        local.get 14
                        ref.cast (ref 69)
                        struct.get 69 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 91
                      end
                      i32.const 1
                      local.set 22
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 52
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
            call 86
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;92;) (type 127) (param (ref 64) i32 i32) (result (ref 3))
    (local eqref (ref 84) eqref i32 eqref i32)
    i32.const 1
    local.set 6
    local.get 6
    array.new_default 143
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
      array.new_default 143
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
          ref.cast (ref 143)
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 143)
          local.get 6
          array.get 143
          array.set 143
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
      ref.cast (ref 143)
      array.len
      struct.set 6 2
    end
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 143)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    local.get 8
    array.set 143
    local.get 5
    ref.cast (ref 6)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    i32.const 1
    i32.add
    struct.set 6 1
    call 44
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 6)
    i32.const 0
    array.new_default 148
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    i32.const 0
    array.new_default 148
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    struct.new 84
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 91
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
    ref.cast (ref 143)
    local.get 6
    array.get 143
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
      struct.new 75
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
      ref.cast (ref 143)
      local.get 6
      array.get 143
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
        ref.cast (ref 84)
        struct.get 84 4
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
        ref.cast (ref 148)
        local.get 6
        array.get 148
        struct.new 76
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
        ref.cast (ref 143)
        local.get 6
        array.get 143
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
          struct.new 75
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
          ref.cast (ref 143)
          local.get 6
          array.get 143
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
            ref.cast (ref 84)
            struct.get 84 5
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
            ref.cast (ref 148)
            local.get 6
            array.get 148
            struct.new 76
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 84)
            struct.get 84 0
            call 50
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;93;) (type 130) (param eqref i32) (result (ref 3))
    local.get 0
    local.get 1
    call 53
    call 95
    ref.cast (ref 3)
  )
  (func (;94;) (type 131) (param eqref (ref 64)) (result (ref 3))
    local.get 0
    local.get 1
    ref.cast (ref 64)
    i32.const 128
    i32.const 16777216
    call 96
    ref.cast (ref 3)
  )
  (func (;95;) (type 132) (param eqref i32 (ref 70)) (result (ref 3))
    (local eqref eqref (ref 71) (ref 64) eqref eqref eqref eqref)
    local.get 0
    local.get 1
    local.get 2
    struct.get 70 0
    call 39
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
          ref.cast (ref 70)
          call 84
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
                ref.cast (ref 64)
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
              ref.cast (ref 71)
              local.set 5
              i32.const 1
              i32.const 0
              i64.const 0
              f32.const 0x0p+0 (;=0;)
              f64.const 0x0p+0 (;=0;)
              v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
              i32.const 1
              local.get 5
              ref.cast (ref 71)
              struct.new 79
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
        ref.cast (ref 37)
        struct.new 78
        struct.new 5
        local.set 10
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 10
    ref.cast (ref 3)
  )
  (func (;96;) (type 133) (param eqref (ref 64) i32 i32) (result (ref 3))
    (local (ref 75) eqref eqref i32 eqref eqref eqref eqref)
    local.get 1
    ref.cast (ref 64)
    local.get 2
    local.get 3
    call 92
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
          call 42
          call 40
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
              ref.cast (ref 37)
              struct.new 81
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
        ref.cast (ref 75)
        local.set 4
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 1
        local.get 4
        ref.cast (ref 75)
        struct.new 82
        struct.new 5
        local.set 11
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 3)
  )
  (func (;97;) (type 135) (param i32 eqref) (result i32)
    (local (ref 139) (ref 137) i32 i32 i32 i32 i32 i32 i32 v128 i32 i32)
    local.get 1
    ref.cast (ref 139)
    local.set 2
    local.get 2
    struct.get 139 0
    local.set 3
    local.get 2
    struct.get 139 1
    local.set 4
    local.get 2
    struct.get 139 2
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
              array.get 137
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
              array.get 137
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
              array.get 137
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
              array.get 137
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
                array.get 137
                local.set 11
              else
                local.get 3
                local.get 9
                i32.const 4
                i32.shr_u
                array.get 137
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
                array.get 137
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
            array.get 137
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
  (func (;98;) (type 136) (result i32)
    (local eqref eqref eqref eqref i32 eqref i32 eqref i32)
    v128.const i32x4 0x7572745b 0x756e2c65 0x005d6c6c 0x00000000
    array.new_fixed 137 1
    i32.const 0
    i32.const 11
    struct.new 139
    call 31
    i32.const 3
    call 93
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
        ref.cast (ref 64)
        struct.get 64 0
        i32.const 4
        i32.eq
        if (result i32) ;; label = @3
          local.get 7
          ref.cast (ref 4)
          struct.get 4 6
          ref.cast (ref 67)
          struct.get 67 1
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
          call 33
          local.set 1
          local.get 1
          i32.const 4
          local.get 0
          ref.cast (ref 6)
          struct.new 67
          call 94
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
              ref.cast (ref 40)
              call 37
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
                  array.new_fixed 137 1
                  i32.const 0
                  i32.const 11
                  struct.new 139
                  call 28
                  if ;; label = @8
                    i32.const 1
                    v128.const i32x4 0x6e6f736a 0x6165723a 0x2d726564 0x74697277
                    v128.const i32x4 0x00007265 0x00000000 0x00000000 0x00000000
                    array.new_fixed 137 2
                    i32.const 0
                    i32.const 18
                    struct.new 139
                    call 97
                    local.set 4
                    br 2 (;@6;)
                  end
                end
                i32.const 1
                if ;; label = @7
                  i32.const 1
                  v128.const i32x4 0x4c494146 0x00000000 0x00000000 0x00000000
                  array.new_fixed 137 1
                  i32.const 0
                  i32.const 4
                  struct.new 139
                  call 97
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
              array.new_fixed 137 1
              i32.const 0
              i32.const 4
              struct.new 139
              call 97
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
        array.new_fixed 137 1
        i32.const 0
        i32.const 4
        struct.new 139
        call 97
        local.set 8
        br 1 (;@1;)
      end
      unreachable
    end
    local.get 8
  )
)
