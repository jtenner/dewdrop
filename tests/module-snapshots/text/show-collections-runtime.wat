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
  (type (;9;) (sub final 8 (struct (field i32) (field i32))))
  (type (;10;) (sub final 8 (struct (field i32) (field eqref))))
  (type (;11;) (sub (struct (field i32))))
  (type (;12;) (sub final 11 (struct (field i32) (field i32))))
  (type (;13;) (sub final 11 (struct (field i32) (field eqref))))
  (type (;14;) (sub final 11 (struct (field i32) (field eqref))))
  (type (;15;) (sub final 11 (struct (field i32) (field eqref))))
  (type (;16;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;17;) (struct (field eqref) (field (mut i32))))
  (type (;18;) (sub (struct (field funcref))))
  (type (;19;) (func (param eqref) (result eqref)))
  (type (;20;) (func (param eqref i32) (result eqref)))
  (type (;21;) (func (param eqref) (result (ref 16))))
  (type (;22;) (func (param eqref eqref) (result eqref)))
  (type (;23;) (func (param eqref)))
  (type (;24;) (func (param eqref i32)))
  (type (;25;) (func (param eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param eqref eqref i32) (result eqref)))
  (type (;28;) (func (param eqref eqref) (result (ref 16))))
  (type (;29;) (func (param eqref eqref eqref) (result eqref)))
  (type (;30;) (func (param eqref eqref)))
  (type (;31;) (func (param eqref eqref i32)))
  (type (;32;) (func (param eqref eqref) (result i32)))
  (type (;33;) (func (param eqref eqref i32) (result i32)))
  (type (;34;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;35;) (func (param eqref) (result i32)))
  (type (;36;) (func (param eqref eqref) (result i32)))
  (type (;37;) (func (result eqref)))
  (type (;38;) (func (param eqref) (result i32)))
  (type (;39;) (func (param eqref eqref)))
  (type (;40;) (func (param eqref i32)))
  (type (;41;) (func (param eqref) (result eqref)))
  (type (;42;) (func (param eqref) (result i32)))
  (type (;43;) (func (param eqref eqref) (result i32)))
  (type (;44;) (func (param i64) (result i32)))
  (type (;45;) (func (param i64) (result i64)))
  (type (;46;) (func (param eqref i64)))
  (type (;47;) (func (param eqref i64)))
  (type (;48;) (func (result eqref)))
  (type (;49;) (func (param eqref) (result i32)))
  (type (;50;) (func (param eqref eqref)))
  (type (;51;) (func (param eqref i32)))
  (type (;52;) (func (param eqref i64)))
  (type (;53;) (func (param eqref i64)))
  (type (;54;) (func (param eqref) (result eqref)))
  (type (;55;) (struct (field eqref) (field i32)))
  (type (;56;) (func))
  (type (;57;) (func (param (ref 55) i32)))
  (type (;58;) (func (param eqref) (result eqref)))
  (type (;59;) (func (param (ref 55))))
  (type (;60;) (func (param (ref 55) eqref)))
  (type (;61;) (func (param (ref 55) eqref)))
  (type (;62;) (func (param (ref 55) i32)))
  (type (;63;) (func (param i32) (result i64)))
  (type (;64;) (func (param i64) (result i64)))
  (type (;65;) (func (param i64) (result i32)))
  (type (;66;) (func (param i64) (result i32)))
  (type (;67;) (func (param (ref 55) i64)))
  (type (;68;) (func (param (ref 55) i64)))
  (type (;69;) (func (param i32 (ref 55))))
  (type (;70;) (func (param i64 (ref 55))))
  (type (;71;) (func (param eqref (ref 55))))
  (type (;72;) (func (param (ref 5) (ref 55))))
  (type (;73;) (func (param (ref 16) (ref 55))))
  (type (;74;) (func (param (ref 8) (ref 55))))
  (type (;75;) (func (param (ref 11) (ref 55))))
  (type (;76;) (func (param eqref) (result eqref)))
  (type (;77;) (func (param eqref) (result eqref)))
  (type (;78;) (func (param eqref) (result eqref)))
  (type (;79;) (func (param eqref) (result eqref)))
  (type (;80;) (func (param eqref) (result eqref)))
  (type (;81;) (func (param (ref 55) eqref)))
  (type (;82;) (func (param (ref 55) eqref)))
  (type (;83;) (func (param (ref 55) eqref)))
  (type (;84;) (func (param (ref 55) eqref)))
  (type (;85;) (func (param (ref 55) eqref)))
  (type (;86;) (func (param (ref 16) (ref 55))))
  (type (;87;) (func (param (ref 1) (ref 55))))
  (type (;88;) (func (param (ref 8) (ref 55))))
  (type (;89;) (func (param (ref 11) (ref 55))))
  (type (;90;) (func (param (ref 8) (ref 55))))
  (type (;91;) (func (param (ref 55) i32)))
  (type (;92;) (func (param (ref 55) i64)))
  (type (;93;) (func (param (ref 55) eqref)))
  (type (;94;) (func (result (ref 8))))
  (type (;95;) (func (result (ref 8))))
  (type (;96;) (func (result (ref 11))))
  (type (;97;) (func (result (ref 11))))
  (type (;98;) (func (param (ref 16)) (result (ref 8))))
  (type (;99;) (func))
  (type (;100;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;101;) (struct))
  (type (;102;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;103;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;104;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;105;) (array (mut v128)))
  (type (;106;) (struct (field (ref 105)) (field i32) (field i32)))
  (type (;107;) (struct (field (ref 105)) (field i32) (field i32)))
  (type (;108;) (struct (field (ref 105)) (field i32) (field i32)))
  (type (;109;) (struct (field (mut (ref 105))) (field (mut i32)) (field (mut i32))))
  (type (;110;) (struct (field (mut (ref 105))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 57))
  (func (;0;) (type 35) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 106)
    struct.get 106 2
  )
  (func (;1;) (type 36) (param eqref eqref) (result i32)
    (local (ref 106) (ref 106) (ref 105) (ref 105) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 106)
    local.set 2
    local.get 1
    ref.cast (ref 106)
    local.set 3
    local.get 2
    struct.get 106 2
    local.tee 6
    local.get 3
    struct.get 106 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 106 0
    local.set 4
    local.get 3
    struct.get 106 0
    local.set 5
    local.get 2
    struct.get 106 1
    local.set 7
    local.get 3
    struct.get 106 1
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
          array.get 105
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 105
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
          array.get 105
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
          array.get 105
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 105
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
          array.get 105
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
      array.get 105
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
      array.get 105
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
  (func (;2;) (type 37) (result eqref)
    i32.const 4
    array.new_default 105
    i32.const 0
    i32.const 0
    struct.new 109
  )
  (func (;3;) (type 38) (param eqref) (result i32)
    (local (ref 109))
    local.get 0
    ref.cast (ref 109)
    local.tee 1
    struct.get 109 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 109 1
  )
  (func (;4;) (type 39) (param eqref eqref)
    (local (ref 109) (ref 106) (ref 105) (ref 105) i32 i32 i32 i32 i32 i32 (ref 105) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 109)
    local.set 2
    local.get 2
    struct.get 109 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 106)
    local.set 3
    local.get 2
    struct.get 109 0
    local.set 4
    local.get 3
    struct.get 106 0
    local.set 5
    local.get 2
    struct.get 109 1
    local.set 6
    local.get 3
    struct.get 106 1
    local.set 7
    local.get 3
    struct.get 106 2
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
      array.new_default 105
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
          array.get 105
          array.set 105
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 109 0
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
            array.get 105
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 105
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
            array.get 105
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
            array.set 105
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
            array.get 105
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
            array.set 105
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
            array.get 105
            local.get 19
            v128.bitselect
            array.set 105
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
        array.get 105
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
        array.get 105
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 105
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 109 1
  )
  (func (;5;) (type 40) (param eqref i32)
    (local (ref 109) (ref 105) i32 i32 i32 (ref 105) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 109)
    local.set 2
    local.get 2
    struct.get 109 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 109 0
    local.set 3
    local.get 2
    struct.get 109 1
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
      array.new_default 105
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
          array.get 105
          array.set 105
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 109 0
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
    array.get 105
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 105
    local.get 2
    local.get 5
    struct.set 109 1
  )
  (func (;6;) (type 41) (param eqref) (result eqref)
    (local (ref 109))
    local.get 0
    ref.cast (ref 109)
    local.set 1
    local.get 1
    struct.get 109 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 109 2
    local.get 1
    struct.get 109 0
    i32.const 0
    local.get 1
    struct.get 109 1
    struct.new 106
  )
  (func (;7;) (type 42) (param eqref) (result i32)
    local.get 0
    call 0
  )
  (func (;8;) (type 43) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 1
  )
  (func (;9;) (type 44) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
    i32.const 255
    i32.and
  )
  (func (;10;) (type 45) (param i64) (result i64)
    local.get 0
  )
  (func (;11;) (type 46) (param eqref i64)
    local.get 1
    i64.const 10
    i64.ge_u
    if ;; label = @1
      local.get 0
      local.get 1
      i64.const 10
      i64.div_u
      call 11
    else
    end
    local.get 0
    local.get 1
    i64.const 10
    i64.rem_u
    call 9
    i32.const 48
    i32.add
    i32.const 255
    i32.and
    call 5
  )
  (func (;12;) (type 47) (param eqref i64)
    local.get 1
    i64.const 0
    i64.lt_s
    if ;; label = @1
      local.get 0
      i32.const 45
      call 5
      local.get 0
      i64.const 0
      local.get 1
      i64.const 1
      i64.add
      i64.sub
      call 10
      i64.const 1
      i64.add
      call 11
    else
      local.get 0
      local.get 1
      call 10
      call 11
    end
  )
  (func (;13;) (type 48) (result eqref)
    call 2
  )
  (func (;14;) (type 49) (param eqref) (result i32)
    local.get 0
    call 3
  )
  (func (;15;) (type 50) (param eqref eqref)
    local.get 0
    local.get 1
    call 4
  )
  (func (;16;) (type 51) (param eqref i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;17;) (type 52) (param eqref i64)
    local.get 0
    local.get 1
    call 12
  )
  (func (;18;) (type 53) (param eqref i64)
    local.get 0
    local.get 1
    call 11
  )
  (func (;19;) (type 54) (param eqref) (result eqref)
    local.get 0
    call 6
  )
  (func (;20;) (type 56))
  (func (;21;) (type 57) (param (ref 55) i32)
    (local i32)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    call 14
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
  (func (;22;) (type 59) (param (ref 55))
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 64
    i32.ge_u
    if ;; label = @1
      unreachable
    else
    end
  )
  (func (;23;) (type 61) (param (ref 55) eqref)
    local.get 0
    local.get 1
    call 7
    call 21
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 1
    call 15
  )
  (func (;24;) (type 62) (param (ref 55) i32)
    local.get 0
    i32.const 1
    call 21
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 1
    call 16
  )
  (func (;25;) (type 63) (param i32) (result i64)
    local.get 0
    i64.extend_i32_s
  )
  (func (;26;) (type 64) (param i64) (result i64)
    local.get 0
  )
  (func (;27;) (type 65) (param i64) (result i32)
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
      call 27
      i32.add
    end
  )
  (func (;28;) (type 66) (param i64) (result i32)
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
      call 26
      i64.const 1
      i64.add
      call 27
      i32.add
    else
      local.get 0
      call 26
      call 27
    end
  )
  (func (;29;) (type 67) (param (ref 55) i64)
    local.get 0
    local.get 1
    call 28
    call 21
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 1
    call 17
  )
  (func (;30;) (type 68) (param (ref 55) i64)
    local.get 0
    local.get 1
    call 27
    call 21
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 1
    call 18
  )
  (func (;31;) (type 69) (param i32 (ref 55))
    local.get 1
    local.get 0
    call 25
    call 29
  )
  (func (;32;) (type 70) (param i64 (ref 55))
    local.get 1
    local.get 0
    call 30
  )
  (func (;33;) (type 71) (param eqref (ref 55))
    local.get 1
    local.get 0
    call 23
  )
  (func (;34;) (type 76) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 55
    local.get 0
    call 39
    local.get 1
    call 19
  )
  (func (;35;) (type 77) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 55
    local.get 0
    call 40
    local.get 1
    call 19
  )
  (func (;36;) (type 78) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 55
    local.get 0
    call 41
    local.get 1
    call 19
  )
  (func (;37;) (type 79) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 55
    local.get 0
    call 42
    local.get 1
    call 19
  )
  (func (;38;) (type 80) (param eqref) (result eqref)
    (local eqref)
    call 13
    local.set 1
    local.get 1
    i32.const 0
    struct.new 55
    local.get 0
    call 43
    local.get 1
    call 19
  )
  (func (;39;) (type 81) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    ref.cast (ref 16)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 44
  )
  (func (;40;) (type 82) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    ref.cast (ref 1)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 45
  )
  (func (;41;) (type 83) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    ref.cast (ref 8)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 46
  )
  (func (;42;) (type 84) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    ref.cast (ref 11)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 47
  )
  (func (;43;) (type 85) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    ref.cast (ref 8)
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 48
  )
  (func (;44;) (type 86) (param (ref 16) (ref 55))
    (local i32 i32 eqref i32 eqref i32)
    local.get 1
    ref.cast (ref 55)
    i32.const 91
    call 24
    local.get 0
    ref.cast (ref 16)
    struct.get 16 1
    local.set 2
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
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              i32.const 0
              i32.gt_u
              if ;; label = @6
                local.get 1
                ref.cast (ref 55)
                v128.const i32x4 0x0000202c 0x00000000 0x00000000 0x00000000
                array.new_fixed 105 1
                i32.const 0
                i32.const 2
                struct.new 106
                call 23
              else
              end
              local.get 1
              ref.cast (ref 55)
              local.get 0
              local.get 3
              local.set 5
              local.set 4
              local.get 5
              local.get 4
              ref.cast (ref 16)
              struct.get 16 1
              i32.ge_u
              if ;; label = @6
                unreachable
              end
              local.get 4
              ref.cast (ref 16)
              struct.get 16 0
              ref.cast (ref 0)
              local.get 5
              array.get 0
              call 49
              local.get 3
              i32.const 1
              i32.add
              local.set 7
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 20
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 1
    ref.cast (ref 55)
    i32.const 93
    call 24
  )
  (func (;45;) (type 87) (param (ref 1) (ref 55))
    (local i32 i32 i32)
    local.get 1
    ref.cast (ref 55)
    i32.const 91
    call 24
    local.get 0
    ref.cast (ref 1)
    array.len
    local.set 2
    i32.const 0
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 3
            local.get 3
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 3
              i32.const 0
              i32.gt_u
              if ;; label = @6
                local.get 1
                ref.cast (ref 55)
                v128.const i32x4 0x0000202c 0x00000000 0x00000000 0x00000000
                array.new_fixed 105 1
                i32.const 0
                i32.const 2
                struct.new 106
                call 23
              else
              end
              local.get 1
              ref.cast (ref 55)
              local.get 0
              ref.cast (ref 1)
              local.get 3
              array.get 1
              call 50
              local.get 3
              i32.const 1
              i32.add
              local.set 4
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 20
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 1
    ref.cast (ref 55)
    i32.const 93
    call 24
  )
  (func (;46;) (type 88) (param (ref 8) (ref 55))
    (local i32 eqref)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          ref.cast (ref 55)
          v128.const i32x4 0x656e6f4e 0x00000000 0x00000000 0x00000000
          array.new_fixed 105 1
          i32.const 0
          i32.const 4
          struct.new 106
          call 23
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 9)
        struct.get 9 1
        local.set 2
        local.get 1
        ref.cast (ref 55)
        v128.const i32x4 0x656d6f53 0x00000028 0x00000000 0x00000000
        array.new_fixed 105 1
        i32.const 0
        i32.const 5
        struct.new 106
        call 23
        local.get 1
        ref.cast (ref 55)
        local.get 2
        call 49
        local.get 1
        ref.cast (ref 55)
        i32.const 41
        call 24
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;47;) (type 89) (param (ref 11) (ref 55))
    (local i32 eqref eqref)
    local.get 0
    local.set 4
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 4
            ref.cast (ref 11)
            struct.get 11 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 4
          ref.cast (ref 12)
          struct.get 12 1
          local.set 2
          local.get 1
          ref.cast (ref 55)
          v128.const i32x4 0x00286b4f 0x00000000 0x00000000 0x00000000
          array.new_fixed 105 1
          i32.const 0
          i32.const 3
          struct.new 106
          call 23
          local.get 1
          ref.cast (ref 55)
          local.get 2
          call 49
          local.get 1
          ref.cast (ref 55)
          i32.const 41
          call 24
          br 2 (;@1;)
        end
        local.get 4
        ref.cast (ref 14)
        struct.get 14 1
        local.set 3
        local.get 1
        ref.cast (ref 55)
        v128.const i32x4 0x28727245 0x00000000 0x00000000 0x00000000
        array.new_fixed 105 1
        i32.const 0
        i32.const 4
        struct.new 106
        call 23
        local.get 1
        ref.cast (ref 55)
        local.get 3
        call 51
        local.get 1
        ref.cast (ref 55)
        i32.const 41
        call 24
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;48;) (type 90) (param (ref 8) (ref 55))
    (local eqref eqref)
    local.get 0
    local.set 3
    block ;; label = @1
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            local.get 3
            ref.cast (ref 8)
            struct.get 8 0
            br_table 0 (;@4;) 1 (;@3;) 2 (;@2;)
          end
          local.get 1
          ref.cast (ref 55)
          v128.const i32x4 0x656e6f4e 0x00000000 0x00000000 0x00000000
          array.new_fixed 105 1
          i32.const 0
          i32.const 4
          struct.new 106
          call 23
          br 2 (;@1;)
        end
        local.get 3
        ref.cast (ref 10)
        struct.get 10 1
        local.set 2
        local.get 1
        ref.cast (ref 55)
        v128.const i32x4 0x656d6f53 0x00000028 0x00000000 0x00000000
        array.new_fixed 105 1
        i32.const 0
        i32.const 5
        struct.new 106
        call 23
        local.get 1
        ref.cast (ref 55)
        local.get 2
        call 39
        local.get 1
        ref.cast (ref 55)
        i32.const 41
        call 24
        br 1 (;@1;)
      end
      unreachable
    end
  )
  (func (;49;) (type 91) (param (ref 55) i32)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 31
  )
  (func (;50;) (type 92) (param (ref 55) i64)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 32
  )
  (func (;51;) (type 93) (param (ref 55) eqref)
    local.get 0
    ref.cast (ref 55)
    call 22
    local.get 1
    local.get 0
    ref.cast (ref 55)
    struct.get 55 0
    local.get 0
    ref.cast (ref 55)
    struct.get 55 1
    i32.const 1
    i32.add
    struct.new 55
    call 33
  )
  (func (;52;) (type 94) (result (ref 8))
    i32.const 1
    i32.const -7
    struct.new 9
    ref.cast (ref 8)
  )
  (func (;53;) (type 95) (result (ref 8))
    i32.const 0
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;54;) (type 96) (result (ref 11))
    i32.const 0
    i32.const 42
    struct.new 12
    ref.cast (ref 11)
  )
  (func (;55;) (type 97) (result (ref 11))
    i32.const 1
    v128.const i32x4 0x00646162 0x00000000 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 3
    struct.new 106
    struct.new 14
    ref.cast (ref 11)
  )
  (func (;56;) (type 98) (param (ref 16)) (result (ref 8))
    i32.const 1
    local.get 0
    struct.new 10
    ref.cast (ref 8)
  )
  (func (;57;) (type 99)
    (local eqref eqref eqref eqref i32 eqref i32 i32 i32)
    i32.const 0
    array.new_default 0
    i32.const 0
    i32.const 0
    struct.new 16
    local.set 0
    local.get 0
    i32.const 1
    local.set 6
    local.set 3
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 3
    ref.cast (ref 16)
    struct.get 16 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 16)
        struct.get 16 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      struct.set 16 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 16 2
    end
    local.get 3
    ref.cast (ref 16)
    struct.get 16 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 6
    array.set 0
    local.get 3
    ref.cast (ref 16)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    i32.const 1
    i32.add
    struct.set 16 1
    local.get 0
    i32.const 2
    local.set 7
    local.set 3
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 3
    ref.cast (ref 16)
    struct.get 16 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 16)
        struct.get 16 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      struct.set 16 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 16 2
    end
    local.get 3
    ref.cast (ref 16)
    struct.get 16 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 7
    array.set 0
    local.get 3
    ref.cast (ref 16)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    i32.const 1
    i32.add
    struct.set 16 1
    local.get 0
    i32.const 3
    local.set 8
    local.set 3
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 3
    ref.cast (ref 16)
    struct.get 16 2
    i32.eq
    if ;; label = @1
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.eqz
      if (result i32) ;; label = @2
        i32.const 4
      else
        local.get 3
        ref.cast (ref 16)
        struct.get 16 2
        i32.const 2
        i32.mul
      end
      local.set 4
      local.get 4
      local.get 3
      ref.cast (ref 16)
      struct.get 16 2
      i32.le_u
      if ;; label = @2
        unreachable
      end
      local.get 4
      array.new_default 0
      local.set 5
      local.get 5
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 0
      ref.cast (ref 0)
      i32.const 0
      local.get 3
      ref.cast (ref 16)
      struct.get 16 1
      array.copy 0 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      struct.set 16 0
      local.get 3
      ref.cast (ref 16)
      local.get 5
      ref.cast (ref 0)
      array.len
      struct.set 16 2
    end
    local.get 3
    ref.cast (ref 16)
    struct.get 16 0
    ref.cast (ref 0)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    local.get 8
    array.set 0
    local.get 3
    ref.cast (ref 16)
    local.get 3
    ref.cast (ref 16)
    struct.get 16 1
    i32.const 1
    i32.add
    struct.set 16 1
    local.get 0
    call 34
    v128.const i32x4 0x202c315b 0x33202c32 0x0000005d 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 9
    struct.new 106
    call 8
    v128.const i32x4 0x61727241 0x68532079 0x6320776f 0x676e6168
    v128.const i32x4 0x00006465 0x00000000 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 18
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    i32.const 2
    local.set 4
    i64.const 9
    local.get 4
    array.new 1
    local.set 1
    local.get 1
    call 35
    v128.const i32x4 0x202c395b 0x00005d39 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 6
    struct.new 106
    call 8
    v128.const i32x4 0x65786946 0x72724164 0x53207961 0x20776f68
    v128.const i32x4 0x6e616863 0x00646567 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 23
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 52
    local.set 1
    call 53
    local.set 2
    local.get 1
    call 36
    v128.const i32x4 0x656d6f53 0x29372d28 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 8
    struct.new 106
    call 8
    v128.const i32x4 0x6974704f 0x53206e6f 0x20656d6f 0x776f6853
    v128.const i32x4 0x61686320 0x6465676e 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 24
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    call 36
    v128.const i32x4 0x656e6f4e 0x00000000 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 4
    struct.new 106
    call 8
    v128.const i32x4 0x6974704f 0x4e206e6f 0x20656e6f 0x776f6853
    v128.const i32x4 0x61686320 0x6465676e 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 24
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    call 54
    local.set 1
    call 55
    local.set 2
    local.get 1
    call 37
    v128.const i32x4 0x34286b4f 0x00002932 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 6
    struct.new 106
    call 8
    v128.const i32x4 0x75736552 0x4f20746c 0x6853206b 0x6320776f
    v128.const i32x4 0x676e6168 0x00006465 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 22
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 2
    call 37
    v128.const i32x4 0x28727245 0x29646162 0x00000000 0x00000000
    array.new_fixed 105 1
    i32.const 0
    i32.const 8
    struct.new 106
    call 8
    v128.const i32x4 0x75736552 0x4520746c 0x53207272 0x20776f68
    v128.const i32x4 0x6e616863 0x00646567 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 23
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 16)
    call 56
    local.set 0
    local.get 0
    call 38
    v128.const i32x4 0x656d6f53 0x2c315b28 0x202c3220 0x00295d33
    array.new_fixed 105 1
    i32.const 0
    i32.const 15
    struct.new 106
    call 8
    v128.const i32x4 0x7473656e 0x53206465 0x20776f68 0x6e616863
    v128.const i32x4 0x00646567 0x00000000 0x00000000 0x00000000
    array.new_fixed 105 2
    i32.const 0
    i32.const 19
    struct.new 106
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
