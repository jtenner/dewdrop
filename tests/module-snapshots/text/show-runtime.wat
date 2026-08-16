(module
  (type (;0;) (array (mut i32)))
  (type (;1;) (array (mut i64)))
  (type (;2;) (array (mut f32)))
  (type (;3;) (array (mut f64)))
  (type (;4;) (array (mut v128)))
  (type (;5;) (array (mut eqref)))
  (type (;6;) (array (mut i8)))
  (type (;7;) (array (mut i16)))
  (type (;8;) (func (param eqref) (result i32)))
  (type (;9;) (func (param eqref eqref) (result i32)))
  (type (;10;) (func (param eqref i32 i32) (result eqref)))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (result eqref)))
  (type (;13;) (func (param eqref) (result i32)))
  (type (;14;) (func (param eqref eqref)))
  (type (;15;) (func (param eqref eqref)))
  (type (;16;) (func (param eqref i32)))
  (type (;17;) (func (param eqref) (result eqref)))
  (type (;18;) (func (param eqref) (result i32)))
  (type (;19;) (func (param eqref eqref) (result i32)))
  (type (;20;) (func (param eqref i32 i32) (result eqref)))
  (type (;21;) (func (param eqref) (result i32)))
  (type (;22;) (sub (struct (field funcref))))
  (type (;23;) (func (param eqref) (result eqref)))
  (type (;24;) (func (param eqref i32) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result eqref)))
  (type (;26;) (func (param eqref)))
  (type (;27;) (func (param eqref i32)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref i32) (result i32)))
  (type (;30;) (func (param eqref eqref i32) (result eqref)))
  (type (;31;) (func (param eqref eqref eqref) (result eqref)))
  (type (;32;) (func (param eqref eqref)))
  (type (;33;) (func (param eqref eqref i32)))
  (type (;34;) (func (param eqref eqref) (result i32)))
  (type (;35;) (func (param eqref eqref i32) (result i32)))
  (type (;36;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;37;) (func (param i64) (result i32)))
  (type (;38;) (func (param i64) (result i64)))
  (type (;39;) (func (param eqref i64)))
  (type (;40;) (func (param eqref i64)))
  (type (;41;) (func (result eqref)))
  (type (;42;) (func (param eqref) (result i32)))
  (type (;43;) (func (param eqref eqref)))
  (type (;44;) (func (param eqref eqref)))
  (type (;45;) (func (param eqref i32)))
  (type (;46;) (func (param eqref i64)))
  (type (;47;) (func (param eqref i64)))
  (type (;48;) (func (param eqref) (result eqref)))
  (type (;49;) (struct (field eqref) (field i32)))
  (type (;50;) (func (param (ref 49) i32)))
  (type (;51;) (func (param eqref) (result eqref)))
  (type (;52;) (func (param (ref 49))))
  (type (;53;) (func (param (ref 49) eqref)))
  (type (;54;) (func (param (ref 49) eqref)))
  (type (;55;) (func (param (ref 49) eqref)))
  (type (;56;) (func (param (ref 49) i32)))
  (type (;57;) (func (param i32) (result i64)))
  (type (;58;) (func (param i32) (result i64)))
  (type (;59;) (func (param i32) (result i64)))
  (type (;60;) (func (param i32) (result i64)))
  (type (;61;) (func (param i32) (result i64)))
  (type (;62;) (func (param i32) (result i64)))
  (type (;63;) (func (param i64) (result i64)))
  (type (;64;) (func (param i64) (result i32)))
  (type (;65;) (func (param i64) (result i32)))
  (type (;66;) (func (param (ref 49) i64)))
  (type (;67;) (func (param (ref 49) i64)))
  (type (;68;) (func (param (ref 49))))
  (type (;69;) (func (param i32 (ref 49))))
  (type (;70;) (func (param i32 (ref 49))))
  (type (;71;) (func (param i32 (ref 49))))
  (type (;72;) (func (param i32 (ref 49))))
  (type (;73;) (func (param i64 (ref 49))))
  (type (;74;) (func (param i32 (ref 49))))
  (type (;75;) (func (param i32 (ref 49))))
  (type (;76;) (func (param i32 (ref 49))))
  (type (;77;) (func (param i64 (ref 49))))
  (type (;78;) (func (param eqref (ref 49))))
  (type (;79;) (func (param eqref (ref 49))))
  (type (;80;) (func (param (ref 49) i32)))
  (type (;81;) (func (param (ref 49) i64)))
  (type (;82;) (func (result eqref)))
  (type (;83;) (func (param i32) (result eqref)))
  (type (;84;) (func (param i32) (result eqref)))
  (type (;85;) (func (param i32) (result eqref)))
  (type (;86;) (func (param i32) (result eqref)))
  (type (;87;) (func (param i64) (result eqref)))
  (type (;88;) (func (param i32) (result eqref)))
  (type (;89;) (func (param i32) (result eqref)))
  (type (;90;) (func (param i32) (result eqref)))
  (type (;91;) (func (param i64) (result eqref)))
  (type (;92;) (func (param eqref) (result eqref)))
  (type (;93;) (func (param eqref) (result eqref)))
  (type (;94;) (func (param eqref) (result eqref)))
  (type (;95;) (func (param (ref 49))))
  (type (;96;) (func (param (ref 49) i32)))
  (type (;97;) (func (param (ref 49) i32)))
  (type (;98;) (func (param (ref 49) i32)))
  (type (;99;) (func (param (ref 49) i64)))
  (type (;100;) (func (param (ref 49) i32)))
  (type (;101;) (func (param (ref 49) i32)))
  (type (;102;) (func (param (ref 49) i32)))
  (type (;103;) (func (param (ref 49) eqref)))
  (type (;104;) (func (param (ref 49) eqref)))
  (type (;105;) (func (param (ref 49) eqref)))
  (type (;106;) (struct (field i32) (field i64)))
  (type (;107;) (func (param (ref 106) (ref 49))))
  (type (;108;) (func))
  (type (;109;) (func (param eqref eqref)))
  (type (;110;) (func))
  (type (;111;) (func (param eqref)))
  (type (;112;) (func (param i32 eqref)))
  (type (;113;) (func (param i32 eqref)))
  (type (;114;) (func (param i32 eqref)))
  (type (;115;) (func (param i32 eqref)))
  (type (;116;) (func (param i64 eqref)))
  (type (;117;) (func (param i32 eqref)))
  (type (;118;) (func (param i32 eqref)))
  (type (;119;) (func (param i32 eqref)))
  (type (;120;) (func (param i64 eqref)))
  (type (;121;) (func (param eqref eqref)))
  (type (;122;) (func (param eqref eqref)))
  (type (;123;) (func (param eqref eqref)))
  (type (;124;) (array (mut v128)))
  (type (;125;) (struct (field (ref 124)) (field i32) (field i32)))
  (type (;126;) (struct (field (ref 124)) (field i32) (field i32)))
  (type (;127;) (struct (field (ref 124)) (field i32) (field i32)))
  (type (;128;) (struct (field (mut (ref 124))) (field (mut i32)) (field (mut i32))))
  (type (;129;) (struct (field (mut (ref 124))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 82))
  (func (;0;) (type 8) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 125)
    struct.get 125 2
  )
  (func (;1;) (type 9) (param eqref eqref) (result i32)
    (local (ref 125) (ref 125) (ref 124) (ref 124) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 125)
    local.set 2
    local.get 1
    ref.cast (ref 125)
    local.set 3
    local.get 2
    struct.get 125 2
    local.tee 6
    local.get 3
    struct.get 125 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 125 0
    local.set 4
    local.get 3
    struct.get 125 0
    local.set 5
    local.get 2
    struct.get 125 1
    local.set 7
    local.get 3
    struct.get 125 1
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
          array.get 124
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 124
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
          array.get 124
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
          array.get 124
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 124
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
          array.get 124
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
      array.get 124
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
      array.get 124
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
  (func (;2;) (type 10) (param eqref i32 i32) (result eqref)
    (local (ref 125) (ref 124) i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 125)
    local.set 3
    local.get 3
    struct.get 125 2
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
    struct.get 125 0
    local.set 4
    local.get 3
    struct.get 125 1
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
      array.get 124
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
      array.get 124
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
    struct.get 125 1
    local.get 1
    i32.add
    local.get 2
    struct.new 127
  )
  (func (;3;) (type 11) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 127)
    struct.get 127 2
  )
  (func (;4;) (type 12) (result eqref)
    i32.const 4
    array.new_default 124
    i32.const 0
    i32.const 0
    struct.new 128
  )
  (func (;5;) (type 13) (param eqref) (result i32)
    (local (ref 128))
    local.get 0
    ref.cast (ref 128)
    local.tee 1
    struct.get 128 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 128 1
  )
  (func (;6;) (type 14) (param eqref eqref)
    (local (ref 128) (ref 125) (ref 124) (ref 124) i32 i32 i32 i32 i32 i32 (ref 124) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 128)
    local.set 2
    local.get 2
    struct.get 128 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 125)
    local.set 3
    local.get 2
    struct.get 128 0
    local.set 4
    local.get 3
    struct.get 125 0
    local.set 5
    local.get 2
    struct.get 128 1
    local.set 6
    local.get 3
    struct.get 125 1
    local.set 7
    local.get 3
    struct.get 125 2
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
      array.new_default 124
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
          array.get 124
          array.set 124
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 128 0
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
            array.get 124
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 124
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
            array.get 124
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
            array.set 124
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
            array.get 124
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
            array.set 124
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
            array.get 124
            local.get 19
            v128.bitselect
            array.set 124
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
        array.get 124
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
        array.get 124
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 124
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 128 1
  )
  (func (;7;) (type 15) (param eqref eqref)
    (local (ref 128) (ref 127) (ref 124) (ref 124) i32 i32 i32 i32 i32 i32 (ref 124) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 128)
    local.set 2
    local.get 2
    struct.get 128 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 127)
    local.set 3
    local.get 2
    struct.get 128 0
    local.set 4
    local.get 3
    struct.get 127 0
    local.set 5
    local.get 2
    struct.get 128 1
    local.set 6
    local.get 3
    struct.get 127 1
    local.set 7
    local.get 3
    struct.get 127 2
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
      array.new_default 124
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
          array.get 124
          array.set 124
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 128 0
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
            array.get 124
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 124
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
            array.get 124
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
            array.set 124
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
            array.get 124
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
            array.set 124
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
            array.get 124
            local.get 19
            v128.bitselect
            array.set 124
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
        array.get 124
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
        array.get 124
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 124
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 128 1
  )
  (func (;8;) (type 16) (param eqref i32)
    (local (ref 128) (ref 124) i32 i32 i32 (ref 124) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 128)
    local.set 2
    local.get 2
    struct.get 128 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 128 0
    local.set 3
    local.get 2
    struct.get 128 1
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
      array.new_default 124
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
          array.get 124
          array.set 124
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 128 0
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
    array.get 124
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 124
    local.get 2
    local.get 5
    struct.set 128 1
  )
  (func (;9;) (type 17) (param eqref) (result eqref)
    (local (ref 128))
    local.get 0
    ref.cast (ref 128)
    local.set 1
    local.get 1
    struct.get 128 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 128 2
    local.get 1
    struct.get 128 0
    i32.const 0
    local.get 1
    struct.get 128 1
    struct.new 125
  )
  (func (;10;) (type 18) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;11;) (type 19) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;12;) (type 20) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 2
  )
  (func (;13;) (type 21) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;14;) (type 37) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;15;) (type 38) (param i64) (result i64)
    local.get 0
  )
  (func (;16;) (type 39) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 16
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 14
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 8
  )
  (func (;17;) (type 40) (param eqref i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 8
      local.get 0
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 15
      i64.const 1
      i64.add
      call 16
    else
      local.get 0
      local.get 1
      call 15
      call 16
    end
  )
  (func (;18;) (type 41) (result eqref)
    call 4
  )
  (func (;19;) (type 42) (param eqref) (result i32)
    local.get 0
    call 5
  )
  (func (;20;) (type 43) (param eqref eqref)
    local.get 0
    local.get 1
    call 6
  )
  (func (;21;) (type 44) (param eqref eqref)
    local.get 0
    local.get 1
    call 7
  )
  (func (;22;) (type 45) (param eqref i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;23;) (type 46) (param eqref i64)
    local.get 0
    local.get 1
    call 17
  )
  (func (;24;) (type 47) (param eqref i64)
    local.get 0
    local.get 1
    call 16
  )
  (func (;25;) (type 48) (param eqref) (result eqref)
    local.get 0
    call 9
  )
  (func (;26;) (type 50) (param (ref 49) i32)
    (local i32)
    local.get 0
    struct.get 49 0
    call 19
    local.set 2
    local.get 2
    i32.const 1048576
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const 1048576
      local.get 2
      i32.sub
      i32.gt_u
    end
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;27;) (type 52) (param (ref 49))
    local.get 0
    struct.get 49 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;28;) (type 54) (param (ref 49) eqref)
    local.get 0
    local.get 1
    call 10
    call 26
    local.get 0
    struct.get 49 0
    local.get 1
    call 20
  )
  (func (;29;) (type 55) (param (ref 49) eqref)
    local.get 0
    local.get 1
    call 13
    call 26
    local.get 0
    struct.get 49 0
    local.get 1
    call 21
  )
  (func (;30;) (type 56) (param (ref 49) i32)
    local.get 0
    i32.const 1
    call 26
    local.get 0
    struct.get 49 0
    local.get 1
    call 22
  )
  (func (;31;) (type 57) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;32;) (type 58) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;33;) (type 59) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;34;) (type 60) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;35;) (type 61) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;36;) (type 62) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;37;) (type 63) (param i64) (result i64)
    local.get 0
  )
  (func (;38;) (type 64) (param i64) (result i32)
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
      call 38
      i32.add
    end
  )
  (func (;39;) (type 65) (param i64) (result i32)
    local.get 0
    i64.const 0
    i64.lt_s
    if (result i32) ;; label = @1
      i32.const 1
      i64.const 0
      local.get 0
      i64.const 1
      i64.add
      i64.sub
      call 37
      i64.const 1
      i64.add
      call 38
      i32.add
    else
      local.get 0
      call 37
      call 38
    end
  )
  (func (;40;) (type 66) (param (ref 49) i64)
    local.get 0
    local.get 1
    call 39
    call 26
    local.get 0
    struct.get 49 0
    local.get 1
    call 23
  )
  (func (;41;) (type 67) (param (ref 49) i64)
    local.get 0
    local.get 1
    call 38
    call 26
    local.get 0
    struct.get 49 0
    local.get 1
    call 24
  )
  (func (;42;) (type 68) (param (ref 49))
    local.get 0
    v128.const i32x4 0x00002928 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 2
    struct.new 125
    call 28
  )
  (func (;43;) (type 69) (param i32 (ref 49))
    local.get 0
    if ;; label = @1
      local.get 1
      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
      array.new_fixed 124 1
      i32.const 0
      i32.const 4
      struct.new 125
      call 28
    else
      local.get 1
      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
      array.new_fixed 124 1
      i32.const 0
      i32.const 5
      struct.new 125
      call 28
    end
  )
  (func (;44;) (type 70) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 31
    call 40
  )
  (func (;45;) (type 71) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 32
    call 40
  )
  (func (;46;) (type 72) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 33
    call 40
  )
  (func (;47;) (type 73) (param i64 (ref 49))
    local.get 1
    local.get 0
    call 40
  )
  (func (;48;) (type 74) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 34
    call 41
  )
  (func (;49;) (type 75) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 35
    call 41
  )
  (func (;50;) (type 76) (param i32 (ref 49))
    local.get 1
    local.get 0
    call 36
    call 41
  )
  (func (;51;) (type 77) (param i64 (ref 49))
    local.get 1
    local.get 0
    call 41
  )
  (func (;52;) (type 78) (param eqref (ref 49))
    local.get 1
    local.get 0
    call 28
  )
  (func (;53;) (type 79) (param eqref (ref 49))
    local.get 1
    local.get 0
    call 29
  )
  (func (;54;) (type 80) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 46
  )
  (func (;55;) (type 81) (param (ref 49) i64)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 51
  )
  (func (;56;) (type 82) (result eqref)
    (local eqref)
    call 18
    local.set 0
    local.get 0
    i32.const 0
    struct.new 49
    call 69
    local.get 0
    call 25
  )
  (func (;57;) (type 83) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 70
    local.get 1
    call 25
  )
  (func (;58;) (type 84) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 71
    local.get 1
    call 25
  )
  (func (;59;) (type 85) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 72
    local.get 1
    call 25
  )
  (func (;60;) (type 86) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 54
    local.get 1
    call 25
  )
  (func (;61;) (type 87) (param i64) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 73
    local.get 1
    call 25
  )
  (func (;62;) (type 88) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 74
    local.get 1
    call 25
  )
  (func (;63;) (type 89) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 75
    local.get 1
    call 25
  )
  (func (;64;) (type 90) (param i32) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 76
    local.get 1
    call 25
  )
  (func (;65;) (type 91) (param i64) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 55
    local.get 1
    call 25
  )
  (func (;66;) (type 92) (param eqref) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 77
    local.get 1
    call 25
  )
  (func (;67;) (type 93) (param eqref) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 78
    local.get 1
    call 25
  )
  (func (;68;) (type 94) (param eqref) (result eqref)
    (local eqref)
    call 18
    local.set 1
    local.get 1
    i32.const 0
    struct.new 49
    local.get 0
    call 79
    local.get 1
    call 25
  )
  (func (;69;) (type 95) (param (ref 49))
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 42
  )
  (func (;70;) (type 96) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 43
  )
  (func (;71;) (type 97) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 44
  )
  (func (;72;) (type 98) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 45
  )
  (func (;73;) (type 99) (param (ref 49) i64)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 47
  )
  (func (;74;) (type 100) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 48
  )
  (func (;75;) (type 101) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 49
  )
  (func (;76;) (type 102) (param (ref 49) i32)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 50
  )
  (func (;77;) (type 103) (param (ref 49) eqref)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 52
  )
  (func (;78;) (type 104) (param (ref 49) eqref)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 53
  )
  (func (;79;) (type 105) (param (ref 49) eqref)
    local.get 0
    ref.cast (ref 49)
    call 27
    local.get 1
    ref.cast (ref 106)
    local.get 0
    struct.get 49 0
    local.get 0
    struct.get 49 1
    i32.const 1
    i32.add
    struct.new 49
    call 80
  )
  (func (;80;) (type 107) (param (ref 106) (ref 49))
    local.get 1
    ref.cast (ref 49)
    i32.const 40
    call 30
    local.get 1
    ref.cast (ref 49)
    local.get 0
    struct.get 106 0
    call 54
    local.get 1
    ref.cast (ref 49)
    i32.const 44
    call 30
    local.get 1
    ref.cast (ref 49)
    local.get 0
    struct.get 106 1
    call 55
    local.get 1
    ref.cast (ref 49)
    i32.const 41
    call 30
  )
  (func (;81;) (type 108))
  (func (;82;) (type 110)
    call 81
    v128.const i32x4 0x00002928 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 2
    struct.new 125
    call 83
    i32.const 1
    v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 4
    struct.new 125
    call 84
    i32.const 0
    v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 5
    struct.new 125
    call 84
    i32.const 0
    i32.const -128
    i32.sub
    i32.extend8_s
    v128.const i32x4 0x3832312d 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 4
    struct.new 125
    call 85
    i32.const 0
    i32.const -32768
    i32.sub
    i32.extend16_s
    v128.const i32x4 0x3732332d 0x00003836 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 6
    struct.new 125
    call 86
    i32.const -2147483648
    v128.const i32x4 0x3431322d 0x33383437 0x00383436 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    call 87
    i64.const -9223372036854775808
    v128.const i32x4 0x3232392d 0x32373333 0x38363330 0x37373435
    v128.const i32x4 0x38303835 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 2
    i32.const 0
    i32.const 20
    struct.new 125
    call 88
    i32.const 255
    v128.const i32x4 0x00353532 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 3
    struct.new 125
    call 89
    i32.const 65535
    v128.const i32x4 0x33353536 0x00000035 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 5
    struct.new 125
    call 90
    i32.const -1
    v128.const i32x4 0x34393234 0x32373639 0x00003539 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 10
    struct.new 125
    call 91
    i64.const -1
    v128.const i32x4 0x34343831 0x34343736 0x37333730 0x35353930
    v128.const i32x4 0x35313631 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 2
    i32.const 0
    i32.const 20
    struct.new 125
    call 92
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 3
    struct.new 125
    v128.const i32x4 0x00776564 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 3
    struct.new 125
    call 93
    v128.const i32x4 0x64636261 0x00006665 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 6
    struct.new 125
    i32.const 1
    i32.const 3
    call 12
    v128.const i32x4 0x00646362 0x00000000 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 3
    struct.new 125
    call 94
    i32.const -42
    i64.const 99
    struct.new 106
    v128.const i32x4 0x32342d28 0x2939392c 0x00000000 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 8
    struct.new 125
    call 95
  )
  (func (;83;) (type 111) (param eqref)
    call 56
    local.get 0
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;84;) (type 112) (param i32 eqref)
    local.get 0
    call 57
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;85;) (type 113) (param i32 eqref)
    local.get 0
    call 58
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;86;) (type 114) (param i32 eqref)
    local.get 0
    call 59
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;87;) (type 115) (param i32 eqref)
    local.get 0
    call 60
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;88;) (type 116) (param i64 eqref)
    local.get 0
    call 61
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;89;) (type 117) (param i32 eqref)
    local.get 0
    call 62
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;90;) (type 118) (param i32 eqref)
    local.get 0
    call 63
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;91;) (type 119) (param i32 eqref)
    local.get 0
    call 64
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;92;) (type 120) (param i64 eqref)
    local.get 0
    call 65
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;93;) (type 121) (param eqref eqref)
    local.get 0
    call 66
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;94;) (type 122) (param eqref eqref)
    local.get 0
    call 67
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;95;) (type 123) (param eqref eqref)
    local.get 0
    call 68
    local.get 1
    call 11
    v128.const i32x4 0x776f6873 0x74756f20 0x00747570 0x00000000
    array.new_fixed 124 1
    i32.const 0
    i32.const 11
    struct.new 125
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
