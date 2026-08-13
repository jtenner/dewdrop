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
  (type (;10;) (func (result eqref)))
  (type (;11;) (func (param eqref) (result i32)))
  (type (;12;) (func (param eqref eqref)))
  (type (;13;) (func (param eqref i32)))
  (type (;14;) (func (param eqref i32)))
  (type (;15;) (func (param eqref) (result eqref)))
  (type (;16;) (func (param eqref) (result i32)))
  (type (;17;) (func (param eqref) (result i32)))
  (type (;18;) (func (param eqref) (result eqref)))
  (type (;19;) (func (param eqref eqref) (result i32)))
  (type (;20;) (func (param eqref i32) (result i32)))
  (type (;21;) (func (param eqref i32 i32) (result eqref)))
  (type (;22;) (func (param eqref) (result i32)))
  (type (;23;) (func (param eqref) (result i32)))
  (type (;24;) (func (param eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref) (result i32)))
  (type (;26;) (func (param eqref i32) (result i32)))
  (type (;27;) (func (param eqref i32 i32) (result eqref)))
  (type (;28;) (func (param eqref) (result i32)))
  (type (;29;) (func (param eqref) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (result eqref)))
  (type (;32;) (func (param eqref) (result i32)))
  (type (;33;) (func (param eqref eqref)))
  (type (;34;) (func (param eqref i32)))
  (type (;35;) (func (param eqref i32)))
  (type (;36;) (func (param eqref eqref)))
  (type (;37;) (func (param eqref) (result eqref)))
  (type (;38;) (func (param eqref i32) (result v128)))
  (type (;39;) (sub (struct (field i32))))
  (type (;40;) (sub final 39 (struct (field i32) (field i32))))
  (type (;41;) (sub final 39 (struct (field i32) (field eqref))))
  (type (;42;) (sub final 39 (struct (field i32) (field (ref 6)))))
  (type (;43;) (sub final 39 (struct (field i32) (field (ref 6)))))
  (type (;44;) (struct (field eqref) (field (ref 39))))
  (type (;45;) (struct (field i32) (field i32) (field i32) (field i32)))
  (type (;46;) (sub (struct (field i32))))
  (type (;47;) (sub final 46 (struct (field i32) (field i32))))
  (type (;48;) (sub final 46 (struct (field i32) (field i32) (field i8))))
  (type (;49;) (sub final 46 (struct (field i32) (field i32) (field eqref))))
  (type (;50;) (sub (struct (field i32))))
  (type (;51;) (sub final 50 (struct (field i32) (field eqref))))
  (type (;52;) (struct (field eqref) (field (ref 6)) (field (ref 6)) (field (ref 45))))
  (type (;53;) (struct (field eqref) (field i32) (field i32) (field (ref 6)) (field (ref 6)) (field (ref 6))))
  (type (;54;) (func))
  (type (;55;) (func (result (ref 45))))
  (type (;56;) (func (param (ref 52)) (result i32)))
  (type (;57;) (func (param (ref 52) i32)))
  (type (;58;) (func (param (ref 52)) (result i32)))
  (type (;59;) (func (param (ref 52) i32)))
  (type (;60;) (func (param i32) (result i32)))
  (type (;61;) (func (param i32) (result i32)))
  (type (;62;) (func (param eqref i32) (result i32)))
  (type (;63;) (func (param eqref i32) (result i32)))
  (type (;64;) (func (param i32) (result i32)))
  (type (;65;) (func (param eqref i32) (result i32)))
  (type (;66;) (func (param (ref 52))))
  (type (;67;) (func (param i32) (result i32)))
  (type (;68;) (func (param i32) (result i32)))
  (type (;69;) (func (param eqref i32 i32) (result i32)))
  (type (;70;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;71;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;72;) (func (param eqref i32 i32) (result (ref 1))))
  (type (;73;) (func (param eqref i32 i32) (result i32)))
  (type (;74;) (func (param i32) (result i32)))
  (type (;75;) (func (param eqref i32) (result (ref 1))))
  (type (;76;) (func (param (ref 52) eqref i32 i32) (result i32)))
  (type (;77;) (func (param (ref 52)) (result (ref 3))))
  (type (;78;) (func (param (ref 52) eqref (ref 39)) (result (ref 3))))
  (type (;79;) (func (param (ref 52)) (result (ref 3))))
  (type (;80;) (func (param (ref 52) i32) (result (ref 3))))
  (type (;81;) (func (param eqref eqref) (result i32)))
  (type (;82;) (func (param (ref 6) eqref) (result i32)))
  (type (;83;) (func (param (ref 6) eqref) (result i32)))
  (type (;84;) (func (param (ref 52) i32) (result (ref 3))))
  (type (;85;) (func (param (ref 52) i32) (result (ref 3))))
  (type (;86;) (func (param eqref (ref 45)) (result (ref 3))))
  (type (;87;) (func (param eqref) (result (ref 3))))
  (type (;88;) (func (param eqref) (result (ref 3))))
  (type (;89;) (func (param (ref 53) i32)))
  (type (;90;) (func (param (ref 53) i32)))
  (type (;91;) (func (param (ref 53) eqref)))
  (type (;92;) (func (param (ref 53) eqref)))
  (type (;93;) (func (param i32) (result i32)))
  (type (;94;) (func (param (ref 53) eqref)))
  (type (;95;) (func (param (ref 53) (ref 39) i32)))
  (type (;96;) (func (param (ref 39) i32 i32) (result (ref 3))))
  (type (;97;) (func (param (ref 39)) (result (ref 3))))
  (type (;98;) (func (result i32)))
  (type (;99;) (array (mut v128)))
  (type (;100;) (struct (field (ref 99)) (field i32) (field i32)))
  (type (;101;) (struct (field (ref 99)) (field i32) (field i32)))
  (type (;102;) (struct (field (ref 99)) (field i32) (field i32)))
  (type (;103;) (struct (field (mut (ref 99))) (field (mut i32)) (field (mut i32))))
  (type (;104;) (struct (field (mut (ref 99))) (field (mut i32)) (field (mut i32))))
  (type (;105;) (array (mut i32)))
  (type (;106;) (array (mut i64)))
  (type (;107;) (array (mut f32)))
  (type (;108;) (array (mut f64)))
  (type (;109;) (array (mut v128)))
  (type (;110;) (array (mut eqref)))
  (memory (;0;) 1)
  (export "main" (func 77))
  (func (;0;) (type 0) (param i32 i32) (result i32)
    local.get 0
    if (result i32) ;; label = @1
      local.get 1
    else
      local.get 1
      i32.eqz
    end
  )
  (func (;1;) (type 7) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 100)
    struct.get 100 2
  )
  (func (;2;) (type 8) (param eqref) (result eqref)
    (local (ref 100))
    local.get 0
    ref.cast (ref 100)
    local.tee 1
    struct.get 100 0
    local.get 1
    struct.get 100 1
    local.get 1
    struct.get 100 2
    struct.new 101
  )
  (func (;3;) (type 9) (param eqref eqref) (result i32)
    (local (ref 100) (ref 100) (ref 99) (ref 99) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 100)
    local.set 2
    local.get 1
    ref.cast (ref 100)
    local.set 3
    local.get 2
    struct.get 100 2
    local.tee 6
    local.get 3
    struct.get 100 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 100 0
    local.set 4
    local.get 3
    struct.get 100 0
    local.set 5
    local.get 2
    struct.get 100 1
    local.set 7
    local.get 3
    struct.get 100 1
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
          array.get 99
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 99
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
          array.get 99
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
          array.get 99
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 99
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
          array.get 99
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
      array.get 99
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
      array.get 99
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
  (func (;4;) (type 10) (result eqref)
    i32.const 4
    array.new_default 99
    i32.const 0
    i32.const 0
    struct.new 103
  )
  (func (;5;) (type 11) (param eqref) (result i32)
    (local (ref 103))
    local.get 0
    ref.cast (ref 103)
    local.tee 1
    struct.get 103 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    struct.get 103 1
  )
  (func (;6;) (type 12) (param eqref eqref)
    (local (ref 103) (ref 100) (ref 99) (ref 99) i32 i32 i32 i32 i32 i32 (ref 99) i32 i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 103)
    local.set 2
    local.get 2
    struct.get 103 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    ref.cast (ref 100)
    local.set 3
    local.get 2
    struct.get 103 0
    local.set 4
    local.get 3
    struct.get 100 0
    local.set 5
    local.get 2
    struct.get 103 1
    local.set 6
    local.get 3
    struct.get 100 1
    local.set 7
    local.get 3
    struct.get 100 2
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
      array.new_default 99
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
          array.get 99
          array.set 99
          local.get 13
          i32.const 1
          i32.add
          local.set 13
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 12
      struct.set 103 0
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
            array.get 99
            local.set 18
          else
            local.get 5
            local.get 15
            i32.const 4
            i32.shr_u
            array.get 99
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
            array.get 99
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
            array.set 99
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
            array.get 99
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
            array.set 99
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
            array.get 99
            local.get 19
            v128.bitselect
            array.set 99
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
        array.get 99
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
        array.get 99
        v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
        local.get 16
        i32.const 15
        i32.and
        i8x16.splat
        i8x16.eq
        v128.bitselect
        array.set 99
        local.get 14
        i32.const 1
        i32.add
        local.set 14
        br 0 (;@2;)
      end
    end
    local.get 2
    local.get 9
    struct.set 103 1
  )
  (func (;7;) (type 13) (param eqref i32)
    (local (ref 103) (ref 99) i32 i32 i32 (ref 99) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 103)
    local.set 2
    local.get 2
    struct.get 103 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 103 0
    local.set 3
    local.get 2
    struct.get 103 1
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
      array.new_default 99
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
          array.get 99
          array.set 99
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 103 0
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
    array.get 99
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 99
    local.get 2
    local.get 5
    struct.set 103 1
  )
  (func (;8;) (type 14) (param eqref i32)
    (local (ref 103) (ref 99) i32 i32 i32 i32 i32 (ref 99) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 103)
    local.set 2
    local.get 2
    struct.get 103 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 103 0
    local.set 3
    local.get 2
    struct.get 103 1
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
      array.new_default 99
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
          array.get 99
          array.set 99
          local.get 10
          i32.const 1
          i32.add
          local.set 10
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 9
      struct.set 103 0
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
    array.get 99
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 15
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 99
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
      array.get 99
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 99
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
      array.get 99
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 99
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
      array.get 99
      v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
      local.get 15
      i32.const 15
      i32.and
      i8x16.splat
      i8x16.eq
      v128.bitselect
      array.set 99
    end
    local.get 2
    local.get 6
    struct.set 103 1
  )
  (func (;9;) (type 15) (param eqref) (result eqref)
    (local (ref 103))
    local.get 0
    ref.cast (ref 103)
    local.set 1
    local.get 1
    struct.get 103 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 103 2
    local.get 1
    struct.get 103 0
    i32.const 0
    local.get 1
    struct.get 103 1
    struct.new 100
  )
  (func (;10;) (type 16) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 101)
    struct.get 101 2
  )
  (func (;11;) (type 17) (param eqref) (result i32)
    (local (ref 101) (ref 99) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 101)
    local.set 1
    local.get 1
    struct.get 101 0
    local.set 2
    local.get 1
    struct.get 101 1
    local.set 4
    local.get 1
    struct.get 101 2
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
        array.get 99
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
      array.get 99
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
        array.get 99
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
        array.get 99
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
        array.get 99
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
        array.get 99
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
        array.get 99
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
        array.get 99
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
  (func (;12;) (type 18) (param eqref) (result eqref)
    (local (ref 101))
    local.get 0
    call 11
    i32.eqz
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 101)
    local.tee 1
    struct.get 101 0
    local.get 1
    struct.get 101 1
    local.get 1
    struct.get 101 2
    struct.new 100
  )
  (func (;13;) (type 19) (param eqref eqref) (result i32)
    (local (ref 101) (ref 101) (ref 99) (ref 99) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 101)
    local.set 2
    local.get 1
    ref.cast (ref 101)
    local.set 3
    local.get 2
    struct.get 101 2
    local.tee 6
    local.get 3
    struct.get 101 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 101 0
    local.set 4
    local.get 3
    struct.get 101 0
    local.set 5
    local.get 2
    struct.get 101 1
    local.set 7
    local.get 3
    struct.get 101 1
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
          array.get 99
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 99
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
          array.get 99
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
          array.get 99
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 99
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
          array.get 99
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
      array.get 99
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
      array.get 99
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
  (func (;14;) (type 20) (param eqref i32) (result i32)
    (local (ref 101) (ref 99) i32)
    local.get 0
    ref.cast (ref 101)
    local.set 2
    local.get 1
    local.get 2
    struct.get 101 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 101 0
    local.set 3
    local.get 2
    struct.get 101 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 99
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;15;) (type 21) (param eqref i32 i32) (result eqref)
    (local (ref 101) i32)
    local.get 0
    ref.cast (ref 101)
    local.set 3
    local.get 3
    struct.get 101 2
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
    struct.get 101 0
    local.get 3
    struct.get 101 1
    local.get 1
    i32.add
    local.get 2
    struct.new 101
  )
  (func (;16;) (type 22) (param eqref) (result i32)
    local.get 0
    call 10
  )
  (func (;17;) (type 23) (param eqref) (result i32)
    local.get 0
    call 11
  )
  (func (;18;) (type 24) (param eqref) (result eqref)
    local.get 0
    call 12
  )
  (func (;19;) (type 25) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 13
  )
  (func (;20;) (type 26) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 14
  )
  (func (;21;) (type 27) (param eqref i32 i32) (result eqref)
    local.get 0
    local.get 1
    local.get 2
    call 15
  )
  (func (;22;) (type 28) (param eqref) (result i32)
    local.get 0
    call 1
  )
  (func (;23;) (type 29) (param eqref) (result eqref)
    local.get 0
    call 2
  )
  (func (;24;) (type 30) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 3
  )
  (func (;25;) (type 31) (result eqref)
    call 4
  )
  (func (;26;) (type 32) (param eqref) (result i32)
    local.get 0
    call 5
  )
  (func (;27;) (type 33) (param eqref eqref)
    local.get 0
    local.get 1
    call 6
  )
  (func (;28;) (type 34) (param eqref i32)
    local.get 0
    local.get 1
    call 7
  )
  (func (;29;) (type 35) (param eqref i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;30;) (type 36) (param eqref eqref)
    local.get 0
    local.get 1
    call 12
    call 6
  )
  (func (;31;) (type 37) (param eqref) (result eqref)
    local.get 0
    call 9
  )
  (func (;32;) (type 38) (param eqref i32) (result v128)
    (local (ref 101) (ref 99) i32 v128)
    local.get 0
    ref.cast (ref 101)
    local.set 2
    local.get 1
    local.get 2
    struct.get 101 2
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 101 2
    local.get 1
    i32.sub
    i32.const 16
    i32.lt_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 101 0
    local.set 3
    local.get 2
    struct.get 101 1
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
      array.get 99
      local.set 5
    else
      local.get 3
      local.get 4
      i32.const 4
      i32.shr_u
      array.get 99
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
      array.get 99
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
  (func (;33;) (type 54))
  (func (;34;) (type 55) (result (ref 45))
    i32.const 16777216
    i32.const 128
    i32.const 1048576
    i32.const 16777216
    struct.new 45
    ref.cast (ref 45)
  )
  (func (;35;) (type 56) (param (ref 52)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 52 1
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
    ref.cast (ref 105)
    local.get 2
    array.get 105
  )
  (func (;36;) (type 57) (param (ref 52) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 52 1
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
    ref.cast (ref 105)
    local.get 3
    local.get 5
    array.set 105
  )
  (func (;37;) (type 58) (param (ref 52)) (result i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 52 2
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
    ref.cast (ref 105)
    local.get 2
    array.get 105
  )
  (func (;38;) (type 59) (param (ref 52) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 52 2
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
    ref.cast (ref 105)
    local.get 3
    local.get 5
    array.set 105
  )
  (func (;39;) (type 60) (param i32) (result i32)
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
  (func (;40;) (type 61) (param i32) (result i32)
    local.get 0
    i32.ctz
  )
  (func (;41;) (type 62) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 16
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
              call 32
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
                call 40
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
              call 20
              call 39
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
  (func (;42;) (type 63) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32 i32)
    local.get 0
    call 16
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
              call 32
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
                call 40
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
              call 20
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
  (func (;43;) (type 64) (param i32) (result i32)
    local.get 0
    call 39
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
  (func (;44;) (type 65) (param eqref i32) (result i32)
    (local i32 i32 i32 v128 v128 i32 i32 i32 i32)
    local.get 0
    call 16
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
              call 32
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
                call 40
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
              call 20
              call 43
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
  (func (;45;) (type 66) (param (ref 52))
    local.get 0
    local.get 0
    struct.get 52 0
    local.get 0
    call 35
    call 41
    call 36
  )
  (func (;46;) (type 67) (param i32) (result i32)
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
  (func (;47;) (type 68) (param i32) (result i32)
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
  (func (;48;) (type 69) (param eqref i32 i32) (result i32)
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
              call 20
              call 46
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
  (func (;49;) (type 70) (param eqref i32 i32) (result (ref 1))
    local.get 1
    local.get 2
    i32.ge_u
    if (result eqref) ;; label = @1
      i32.const 0
      struct.new 1
    else
      local.get 0
      local.get 1
      call 20
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
          call 20
          call 46
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
        call 20
        call 47
        if (result eqref) ;; label = @3
          i32.const 1
          local.get 0
          local.get 1
          i32.const 1
          i32.add
          local.get 2
          call 48
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
  (func (;50;) (type 71) (param eqref i32 i32) (result (ref 1))
    (local i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 20
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
        call 20
        call 46
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
        call 48
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
  (func (;51;) (type 72) (param eqref i32 i32) (result (ref 1))
    (local i32 i32)
    local.get 1
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      local.get 1
      call 20
      i32.const 101
      i32.eq
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 0
        local.get 1
        call 20
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
        call 20
        i32.const 43
        i32.eq
        if (result i32) ;; label = @3
          i32.const 1
        else
          local.get 0
          local.get 3
          call 20
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
        call 20
        call 46
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
        call 48
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
  (func (;52;) (type 73) (param eqref i32 i32) (result i32)
    (local i32 i32 i32 i32 eqref i32 eqref i32 eqref i32)
    local.get 1
    local.get 2
    i32.ge_u
    if (result i32) ;; label = @1
      i32.const 0
    else
      local.get 0
      local.get 1
      call 20
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
      call 49
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
          call 50
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
              call 51
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
  (func (;53;) (type 74) (param i32) (result i32)
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
  (func (;54;) (type 75) (param eqref i32) (result (ref 1))
    (local i32 i32 i32 i32)
    local.get 1
    local.get 0
    call 16
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 0
      call 16
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
      call 20
      call 53
      local.set 2
      local.get 0
      local.get 1
      i32.const 1
      i32.add
      call 20
      call 53
      local.set 3
      local.get 0
      local.get 1
      i32.const 2
      i32.add
      call 20
      call 53
      local.set 4
      local.get 0
      local.get 1
      i32.const 3
      i32.add
      call 20
      call 53
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
  (func (;55;) (type 76) (param (ref 52) eqref i32 i32) (result i32)
    (local i32)
    local.get 1
    call 26
    local.set 4
    local.get 3
    local.get 2
    i32.lt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 4
      local.get 0
      struct.get 52 3
      struct.get 45 3
      i32.gt_u
    end
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 3
      local.get 2
      i32.sub
      local.get 0
      struct.get 52 3
      struct.get 45 3
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
        struct.get 52 0
        local.get 2
        local.get 3
        local.get 2
        i32.sub
        call 21
        call 30
      else
      end
      i32.const 1
    end
  )
  (func (;56;) (type 77) (param (ref 52)) (result (ref 3))
    (local i32 i32 eqref i32 i32 i32 i32 i32 i32 i32 i32 eqref eqref i32 eqref)
    local.get 0
    call 35
    local.set 1
    local.get 0
    struct.get 52 0
    call 16
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
      struct.new 47
      struct.new 5
    else
      local.get 0
      struct.get 52 0
      local.get 1
      call 20
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
        struct.get 52 0
        local.get 1
        call 20
        struct.new 48
        struct.new 5
      else
        call 25
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
                struct.get 52 0
                local.get 5
                call 42
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
                  struct.new 47
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                local.get 3
                local.get 4
                local.get 6
                call 55
                i32.const 0
                call 0
                if ;; label = @7
                  i32.const 1
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  i32.const 3
                  local.get 6
                  struct.new 47
                  struct.new 5
                  local.set 15
                  br 4 (;@3;)
                else
                end
                local.get 0
                struct.get 52 0
                local.get 6
                call 20
                local.set 7
                local.get 7
                i32.const 34
                i32.eq
                if ;; label = @7
                  local.get 0
                  local.get 6
                  i32.const 1
                  i32.add
                  call 36
                  i32.const 0
                  i32.const 0
                  i64.const 0
                  f32.const 0x0p+0 (;=0;)
                  f64.const 0x0p+0 (;=0;)
                  v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                  local.get 3
                  call 31
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
                    struct.new 47
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
                      struct.new 48
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
                        struct.new 47
                        struct.new 5
                        local.set 15
                        br 7 (;@3;)
                      else
                        local.get 0
                        struct.get 52 0
                        local.get 6
                        i32.const 1
                        i32.add
                        call 20
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
                          call 28
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
                            call 28
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
                              call 28
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
                                call 28
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
                                  call 28
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
                                    call 28
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
                                      struct.get 52 0
                                      local.get 6
                                      i32.const 2
                                      i32.add
                                      call 54
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
                                            struct.new 47
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
                                              struct.get 52 0
                                              local.get 10
                                              call 20
                                              i32.const 92
                                              i32.ne
                                            end
                                            if (result i32) ;; label = @21
                                              i32.const 1
                                            else
                                              local.get 0
                                              struct.get 52 0
                                              local.get 10
                                              i32.const 1
                                              i32.add
                                              call 20
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
                                              struct.new 47
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                            end
                                            local.get 0
                                            struct.get 52 0
                                            local.get 10
                                            i32.const 2
                                            i32.add
                                            call 54
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
                                                  call 29
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
                                                struct.new 47
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
                                              struct.new 47
                                              struct.new 5
                                              local.set 15
                                              br 18 (;@3;)
                                            else
                                              local.get 3
                                              local.get 9
                                              call 29
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
                                      struct.new 47
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
                        call 26
                        local.get 0
                        struct.get 52 3
                        struct.get 45 3
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
                          struct.new 47
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
  (func (;57;) (type 78) (param (ref 52) eqref (ref 39)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 35
    local.set 3
    local.get 0
    struct.get 52 0
    call 16
    local.set 4
    local.get 3
    local.get 4
    i32.gt_u
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      call 16
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
      struct.new 47
      struct.new 5
    else
      local.get 0
      struct.get 52 0
      local.get 3
      local.get 1
      call 16
      call 21
      local.get 1
      call 19
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
        struct.new 47
        struct.new 5
      else
        local.get 0
        local.get 3
        local.get 1
        call 16
        i32.add
        call 36
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
  (func (;58;) (type 79) (param (ref 52)) (result (ref 3))
    (local i32 i32)
    local.get 0
    call 35
    local.set 1
    local.get 0
    struct.get 52 0
    local.get 1
    call 44
    local.set 2
    local.get 0
    struct.get 52 0
    local.get 1
    local.get 2
    call 52
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
      struct.new 47
      struct.new 5
    else
      local.get 0
      local.get 2
      call 36
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 2
      local.get 0
      struct.get 52 0
      local.get 1
      local.get 2
      local.get 1
      i32.sub
      call 21
      call 18
      struct.new 41
      struct.new 4
    end
    ref.cast (ref 3)
  )
  (func (;59;) (type 80) (param (ref 52) i32) (result (ref 3))
    (local eqref (ref 46) (ref 39) i32 i32 eqref i32 eqref eqref eqref i32 eqref)
    i32.const 0
    array.new_default 110
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 35
    i32.const 1
    i32.add
    call 36
    local.get 0
    call 45
    local.get 0
    call 35
    local.get 0
    struct.get 52 0
    call 16
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 52 0
      local.get 0
      call 35
      call 20
      i32.const 93
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 35
      i32.const 1
      i32.add
      call 36
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 4
      local.get 2
      ref.cast (ref 6)
      struct.new 42
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
              call 64
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
                    ref.cast (ref 39)
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
                      array.new_default 110
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
                          ref.cast (ref 110)
                          local.get 8
                          local.get 7
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 110)
                          local.get 8
                          array.get 110
                          array.set 110
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
                      ref.cast (ref 110)
                      array.len
                      struct.set 6 2
                    end
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 110)
                    local.get 7
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 10
                    array.set 110
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
                  ref.cast (ref 46)
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
              call 45
              local.get 0
              call 35
              local.set 5
              local.get 5
              local.get 0
              struct.get 52 0
              call 16
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
                struct.new 47
                struct.new 5
                local.set 13
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 52 0
              local.get 5
              call 20
              local.set 6
              local.get 6
              i32.const 93
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 5
                i32.const 1
                i32.add
                call 36
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 4
                local.get 2
                ref.cast (ref 6)
                struct.new 42
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
                  call 36
                  local.get 0
                  call 45
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
                  struct.new 48
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
  (func (;60;) (type 81) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 24
  )
  (func (;61;) (type 82) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 110)
              local.get 4
              array.get 110
              ref.cast (ref 44)
              struct.get 44 0
              local.get 1
              call 60
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
  (func (;62;) (type 83) (param (ref 6) eqref) (result i32)
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
              ref.cast (ref 110)
              local.get 4
              array.get 110
              local.get 1
              call 60
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
  (func (;63;) (type 84) (param (ref 52) i32) (result (ref 3))
    (local eqref i32 eqref (ref 46) eqref i32 (ref 39) (ref 46) (ref 39) i32 i32 eqref eqref eqref eqref eqref i32 eqref eqref i32 eqref)
    i32.const 0
    array.new_default 110
    i32.const 0
    i32.const 0
    struct.new 6
    local.set 2
    local.get 0
    local.get 0
    call 35
    i32.const 1
    i32.add
    call 36
    local.get 0
    call 45
    local.get 0
    call 35
    local.get 0
    struct.get 52 0
    call 16
    i32.lt_u
    if (result i32) ;; label = @1
      local.get 0
      struct.get 52 0
      local.get 0
      call 35
      call 20
      i32.const 125
      i32.eq
    else
      i32.const 0
    end
    if (result eqref) ;; label = @1
      local.get 0
      local.get 0
      call 35
      i32.const 1
      i32.add
      call 36
      i32.const 0
      i32.const 0
      i64.const 0
      f32.const 0x0p+0 (;=0;)
      f64.const 0x0p+0 (;=0;)
      v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
      i32.const 5
      local.get 2
      ref.cast (ref 6)
      struct.new 43
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
              call 35
              local.set 3
              local.get 3
              local.get 0
              struct.get 52 0
              call 16
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
                struct.new 47
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 52 0
              local.get 3
              call 20
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
                struct.get 52 0
                local.get 3
                call 20
                struct.new 48
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              call 56
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
                  ref.cast (ref 46)
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
              call 61
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
                struct.new 49
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              call 45
              local.get 0
              call 35
              local.set 7
              local.get 7
              local.get 0
              struct.get 52 0
              call 16
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
                struct.new 47
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 52 0
              local.get 7
              call 20
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
                struct.get 52 0
                local.get 7
                call 20
                struct.new 48
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              local.get 7
              i32.const 1
              i32.add
              call 36
              local.get 0
              call 45
              local.get 0
              local.get 1
              i32.const 1
              i32.add
              call 64
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
                    ref.cast (ref 39)
                    local.set 8
                    local.get 8
                    local.set 16
                    br 2 (;@6;)
                  end
                  local.get 15
                  ref.cast (ref 5)
                  struct.get 5 6
                  ref.cast (ref 46)
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
              ref.cast (ref 39)
              local.set 10
              local.get 2
              local.get 6
              local.get 10
              ref.cast (ref 39)
              struct.new 44
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
                array.new_default 110
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
                    ref.cast (ref 110)
                    local.get 18
                    local.get 17
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 110)
                    local.get 18
                    array.get 110
                    array.set 110
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
                ref.cast (ref 110)
                array.len
                struct.set 6 2
              end
              local.get 17
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 110)
              local.get 17
              ref.cast (ref 6)
              struct.get 6 1
              local.get 20
              array.set 110
              local.get 17
              ref.cast (ref 6)
              local.get 17
              ref.cast (ref 6)
              struct.get 6 1
              i32.const 1
              i32.add
              struct.set 6 1
              local.get 0
              call 45
              local.get 0
              call 35
              local.set 11
              local.get 11
              local.get 0
              struct.get 52 0
              call 16
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
                struct.new 47
                struct.new 5
                local.set 22
                br 4 (;@2;)
              else
              end
              local.get 0
              struct.get 52 0
              local.get 11
              call 20
              local.set 12
              local.get 12
              i32.const 125
              i32.eq
              if ;; label = @6
                local.get 0
                local.get 11
                i32.const 1
                i32.add
                call 36
                i32.const 0
                i32.const 0
                i64.const 0
                f32.const 0x0p+0 (;=0;)
                f64.const 0x0p+0 (;=0;)
                v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
                i32.const 5
                local.get 2
                ref.cast (ref 6)
                struct.new 43
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
                  call 36
                  local.get 0
                  call 45
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
                  struct.new 48
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
  (func (;64;) (type 85) (param (ref 52) i32) (result (ref 3))
    (local i32 i32 eqref (ref 46) eqref eqref)
    local.get 1
    local.get 0
    struct.get 52 3
    struct.get 45 1
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
      struct.new 47
      struct.new 5
    else
      local.get 0
      call 37
      local.get 0
      struct.get 52 3
      struct.get 45 2
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
        call 35
        struct.new 47
        struct.new 5
      else
        local.get 0
        local.get 0
        call 37
        i32.const 1
        i32.add
        call 38
        local.get 0
        call 45
        local.get 0
        call 35
        local.set 2
        local.get 2
        local.get 0
        struct.get 52 0
        call 16
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
          struct.new 47
          struct.new 5
        else
          local.get 0
          struct.get 52 0
          local.get 2
          call 20
          local.set 3
          local.get 3
          i32.const 110
          i32.eq
          if (result eqref) ;; label = @4
            local.get 0
            v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
            array.new_fixed 99 1
            i32.const 0
            i32.const 4
            struct.new 101
            i32.const 0
            struct.new 39
            call 57
          else
            local.get 3
            i32.const 116
            i32.eq
            if (result eqref) ;; label = @5
              local.get 0
              v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
              array.new_fixed 99 1
              i32.const 0
              i32.const 4
              struct.new 101
              i32.const 1
              i32.const 1
              struct.new 40
              call 57
            else
              local.get 3
              i32.const 102
              i32.eq
              if (result eqref) ;; label = @6
                local.get 0
                v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                array.new_fixed 99 1
                i32.const 0
                i32.const 5
                struct.new 101
                i32.const 1
                i32.const 0
                struct.new 40
                call 57
              else
                local.get 3
                i32.const 34
                i32.eq
                if (result eqref) ;; label = @7
                  local.get 0
                  call 56
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
                        struct.new 41
                        struct.new 4
                        local.set 7
                        br 2 (;@8;)
                      end
                      local.get 6
                      ref.cast (ref 5)
                      struct.get 5 6
                      ref.cast (ref 46)
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
                    call 59
                  else
                    local.get 3
                    i32.const 123
                    i32.eq
                    if (result eqref) ;; label = @9
                      local.get 0
                      local.get 1
                      call 63
                    else
                      local.get 3
                      i32.const 45
                      i32.eq
                      if (result i32) ;; label = @10
                        i32.const 1
                      else
                        local.get 3
                        call 46
                      end
                      if (result eqref) ;; label = @10
                        local.get 0
                        call 58
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
                        struct.new 48
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
  (func (;65;) (type 86) (param eqref (ref 45)) (result (ref 3))
    (local i32 eqref eqref (ref 52) (ref 46) (ref 39) eqref i32 eqref i32 i32 eqref eqref)
    local.get 0
    call 16
    local.set 2
    local.get 2
    local.get 1
    struct.get 45 0
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
      struct.new 47
      struct.new 5
    else
      local.get 0
      call 17
      i32.const 0
      call 0
      if (result eqref) ;; label = @2
        i32.const 1
        i32.const 0
        i64.const 0
        f32.const 0x0p+0 (;=0;)
        f64.const 0x0p+0 (;=0;)
        v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
        i32.const 4
        struct.new 46
        struct.new 5
      else
        i32.const 1
        local.set 9
        local.get 9
        array.new_default 105
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
          array.new_default 105
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
              ref.cast (ref 105)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 105)
              local.get 9
              array.get 105
              array.set 105
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
          ref.cast (ref 105)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 105)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 11
        array.set 105
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
        array.new_default 105
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
          array.new_default 105
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
              ref.cast (ref 105)
              local.get 9
              local.get 8
              ref.cast (ref 6)
              struct.get 6 0
              ref.cast (ref 105)
              local.get 9
              array.get 105
              array.set 105
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
          ref.cast (ref 105)
          array.len
          struct.set 6 2
        end
        local.get 8
        ref.cast (ref 6)
        struct.get 6 0
        ref.cast (ref 105)
        local.get 8
        ref.cast (ref 6)
        struct.get 6 1
        local.get 12
        array.set 105
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
        ref.cast (ref 45)
        struct.new 52
        local.set 5
        local.get 5
        i32.const 0
        call 64
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
              ref.cast (ref 39)
              local.set 7
              local.get 5
              call 45
              local.get 5
              call 35
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
                call 35
                struct.new 47
                struct.new 5
              end
              local.set 14
              br 2 (;@3;)
            end
            local.get 13
            ref.cast (ref 5)
            struct.get 5 6
            ref.cast (ref 46)
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
  (func (;66;) (type 87) (param eqref) (result (ref 3))
    local.get 0
    call 34
    call 65
    ref.cast (ref 3)
  )
  (func (;67;) (type 88) (param eqref) (result (ref 3))
    local.get 0
    call 23
    call 66
    ref.cast (ref 3)
  )
  (func (;68;) (type 89) (param (ref 53) i32)
    (local eqref i32 eqref i32)
    local.get 0
    struct.get 53 3
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
    ref.cast (ref 105)
    local.get 3
    array.get 105
    i32.const 0
    i32.eq
    if ;; label = @1
      local.get 0
      struct.get 53 3
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
      ref.cast (ref 105)
      local.get 3
      local.get 5
      array.set 105
    else
    end
  )
  (func (;69;) (type 90) (param (ref 53) i32)
    (local eqref i32 eqref)
    local.get 0
    struct.get 53 3
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
    ref.cast (ref 105)
    local.get 3
    array.get 105
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 0
      struct.get 53 0
      call 26
      local.get 0
      struct.get 53 2
      i32.ge_u
      if ;; label = @2
        local.get 0
        i32.const 3
        call 68
      else
        local.get 0
        struct.get 53 0
        local.get 1
        call 28
      end
    end
  )
  (func (;70;) (type 91) (param (ref 53) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 53 0
    call 26
    local.set 2
    local.get 1
    call 22
    local.set 3
    local.get 0
    struct.get 53 3
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
    ref.cast (ref 105)
    local.get 5
    array.get 105
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 53 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 53 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 68
      else
        local.get 0
        struct.get 53 0
        local.get 1
        call 27
      end
    end
  )
  (func (;71;) (type 92) (param (ref 53) eqref)
    (local i32 i32 eqref i32 eqref)
    local.get 0
    struct.get 53 0
    call 26
    local.set 2
    local.get 1
    call 16
    local.set 3
    local.get 0
    struct.get 53 3
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
    ref.cast (ref 105)
    local.get 5
    array.get 105
    i32.const 0
    i32.ne
    if ;; label = @1
    else
      local.get 2
      local.get 0
      struct.get 53 2
      i32.gt_u
      if (result i32) ;; label = @2
        i32.const 1
      else
        local.get 3
        local.get 0
        struct.get 53 2
        local.get 2
        i32.sub
        i32.gt_u
      end
      if ;; label = @2
        local.get 0
        i32.const 3
        call 68
      else
        local.get 0
        struct.get 53 0
        local.get 1
        call 30
      end
    end
  )
  (func (;72;) (type 93) (param i32) (result i32)
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
  (func (;73;) (type 94) (param (ref 53) eqref)
    (local eqref i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32)
    local.get 0
    i32.const 34
    call 69
    local.get 1
    call 23
    local.set 2
    local.get 2
    call 16
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
              struct.get 53 3
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
              ref.cast (ref 105)
              local.get 10
              array.get 105
              i32.const 0
              i32.eq
            else
              i32.const 0
            end
            if ;; label = @5
              local.get 2
              local.get 5
              call 42
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
                call 21
                call 71
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
                call 20
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
                  call 69
                  local.get 0
                  local.get 7
                  call 69
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
                    call 69
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
                    call 69
                  else
                    local.get 0
                    i32.const 92
                    call 69
                    local.get 0
                    i32.const 117
                    call 69
                    local.get 0
                    i32.const 48
                    call 69
                    local.get 0
                    i32.const 48
                    call 69
                    local.get 0
                    local.get 7
                    i32.const 4
                    i32.const 7
                    i32.and
                    i32.shr_u
                    i32.const 255
                    i32.and
                    call 72
                    call 69
                    local.get 0
                    local.get 7
                    i32.const 15
                    i32.and
                    i32.const 255
                    i32.and
                    call 72
                    call 69
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
    call 69
  )
  (func (;74;) (type 95) (param (ref 53) (ref 39) i32)
    (local i32 eqref eqref eqref eqref i32 eqref eqref eqref i32 eqref (ref 44) eqref i32 eqref eqref i32 eqref eqref i32 eqref)
    local.get 0
    struct.get 53 3
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
    ref.cast (ref 105)
    local.get 16
    array.get 105
    i32.const 0
    i32.ne
    if ;; label = @1
      call 33
    else
      local.get 2
      local.get 0
      struct.get 53 1
      i32.gt_u
      if ;; label = @2
        local.get 0
        i32.const 1
        call 68
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
                        ref.cast (ref 39)
                        struct.get 39 0
                        br_table 0 (;@10;) 1 (;@9;) 2 (;@8;) 3 (;@7;) 4 (;@6;) 5 (;@5;) 6 (;@4;)
                      end
                      local.get 0
                      v128.const i32x4 0x6c6c756e 0x00000000 0x00000000 0x00000000
                      array.new_fixed 99 1
                      i32.const 0
                      i32.const 4
                      struct.new 100
                      call 70
                      br 6 (;@3;)
                    end
                    local.get 23
                    ref.cast (ref 40)
                    struct.get 40 1
                    local.set 3
                    local.get 3
                    if ;; label = @9
                      local.get 0
                      v128.const i32x4 0x65757274 0x00000000 0x00000000 0x00000000
                      array.new_fixed 99 1
                      i32.const 0
                      i32.const 4
                      struct.new 100
                      call 70
                    else
                      local.get 0
                      v128.const i32x4 0x736c6166 0x00000065 0x00000000 0x00000000
                      array.new_fixed 99 1
                      i32.const 0
                      i32.const 5
                      struct.new 100
                      call 70
                    end
                    br 5 (;@3;)
                  end
                  local.get 23
                  ref.cast (ref 41)
                  struct.get 41 1
                  local.set 4
                  local.get 4
                  call 23
                  local.set 5
                  local.get 5
                  i32.const 0
                  local.get 5
                  call 16
                  call 52
                  if ;; label = @8
                    local.get 0
                    local.get 4
                    call 70
                  else
                    local.get 0
                    struct.get 53 4
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
                      array.new_default 110
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
                          ref.cast (ref 110)
                          local.get 16
                          local.get 15
                          ref.cast (ref 6)
                          struct.get 6 0
                          ref.cast (ref 110)
                          local.get 16
                          array.get 110
                          array.set 110
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
                      ref.cast (ref 110)
                      array.len
                      struct.set 6 2
                    end
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 0
                    ref.cast (ref 110)
                    local.get 15
                    ref.cast (ref 6)
                    struct.get 6 1
                    local.get 18
                    array.set 110
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
                    call 68
                  end
                  br 4 (;@3;)
                end
                local.get 23
                ref.cast (ref 41)
                struct.get 41 1
                local.set 6
                local.get 0
                local.get 6
                call 73
                br 3 (;@3;)
              end
              local.get 23
              ref.cast (ref 42)
              struct.get 42 1
              local.set 7
              local.get 0
              i32.const 91
              call 69
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
                        struct.get 53 3
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
                        ref.cast (ref 105)
                        local.get 16
                        array.get 105
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
                          call 69
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
                        ref.cast (ref 110)
                        local.get 16
                        array.get 110
                        local.get 15
                        ref.cast (ref 6)
                        local.get 16
                        i32.const 1
                        i32.add
                        struct.set 6 1
                        ref.cast (ref 39)
                        local.get 2
                        i32.const 1
                        i32.add
                        call 74
                        i32.const 1
                        local.set 19
                        br 3 (;@7;)
                        br 2 (;@8;)
                      end
                    end
                    i32.const 1
                    if ;; label = @9
                      call 33
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
              call 69
              br 2 (;@3;)
            end
            local.get 23
            ref.cast (ref 43)
            struct.get 43 1
            local.set 10
            local.get 0
            i32.const 123
            call 69
            i32.const 0
            array.new_default 110
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
                      struct.get 53 3
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
                      ref.cast (ref 105)
                      local.get 16
                      array.get 105
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
                      ref.cast (ref 110)
                      local.get 16
                      array.get 110
                      local.get 15
                      ref.cast (ref 6)
                      local.get 16
                      i32.const 1
                      i32.add
                      struct.set 6 1
                      ref.cast (ref 44)
                      ref.cast (ref 44)
                      local.set 14
                      local.get 11
                      ref.cast (ref 6)
                      local.get 14
                      ref.cast (ref 44)
                      struct.get 44 0
                      call 62
                      if ;; label = @10
                        local.get 0
                        struct.get 53 5
                        local.get 14
                        ref.cast (ref 44)
                        struct.get 44 0
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
                          array.new_default 110
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
                              ref.cast (ref 110)
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 110)
                              local.get 16
                              array.get 110
                              array.set 110
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
                          ref.cast (ref 110)
                          array.len
                          struct.set 6 2
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 110)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 20
                        array.set 110
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
                        call 68
                      else
                        local.get 11
                        local.get 14
                        ref.cast (ref 44)
                        struct.get 44 0
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
                          array.new_default 110
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
                              ref.cast (ref 110)
                              local.get 16
                              local.get 15
                              ref.cast (ref 6)
                              struct.get 6 0
                              ref.cast (ref 110)
                              local.get 16
                              array.get 110
                              array.set 110
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
                          ref.cast (ref 110)
                          array.len
                          struct.set 6 2
                        end
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 0
                        ref.cast (ref 110)
                        local.get 15
                        ref.cast (ref 6)
                        struct.get 6 1
                        local.get 21
                        array.set 110
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
                          call 69
                        end
                        local.get 0
                        local.get 14
                        ref.cast (ref 44)
                        struct.get 44 0
                        call 73
                        local.get 0
                        i32.const 58
                        call 69
                        local.get 0
                        local.get 14
                        ref.cast (ref 44)
                        struct.get 44 1
                        local.get 2
                        i32.const 1
                        i32.add
                        call 74
                      end
                      i32.const 1
                      local.set 22
                      br 3 (;@6;)
                      br 2 (;@7;)
                    end
                  end
                  i32.const 1
                  if ;; label = @8
                    call 33
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
            call 69
            br 1 (;@3;)
          end
          unreachable
        end
      end
    end
  )
  (func (;75;) (type 96) (param (ref 39) i32 i32) (result (ref 3))
    (local eqref (ref 53) eqref i32 eqref i32)
    i32.const 1
    local.set 6
    local.get 6
    array.new_default 105
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
      array.new_default 105
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
          ref.cast (ref 105)
          local.get 6
          local.get 5
          ref.cast (ref 6)
          struct.get 6 0
          ref.cast (ref 105)
          local.get 6
          array.get 105
          array.set 105
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
      ref.cast (ref 105)
      array.len
      struct.set 6 2
    end
    local.get 5
    ref.cast (ref 6)
    struct.get 6 0
    ref.cast (ref 105)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    local.get 8
    array.set 105
    local.get 5
    ref.cast (ref 6)
    local.get 5
    ref.cast (ref 6)
    struct.get 6 1
    i32.const 1
    i32.add
    struct.set 6 1
    call 25
    local.get 1
    local.get 2
    local.get 3
    ref.cast (ref 6)
    i32.const 0
    array.new_default 110
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    i32.const 0
    array.new_default 110
    i32.const 0
    i32.const 0
    struct.new 6
    ref.cast (ref 6)
    struct.new 53
    local.set 4
    local.get 4
    local.get 0
    i32.const 0
    call 74
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
    ref.cast (ref 105)
    local.get 6
    array.get 105
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
      struct.new 50
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
      ref.cast (ref 105)
      local.get 6
      array.get 105
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
        ref.cast (ref 53)
        struct.get 53 4
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
        ref.cast (ref 110)
        local.get 6
        array.get 110
        struct.new 51
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
        ref.cast (ref 105)
        local.get 6
        array.get 105
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
          struct.new 50
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
          ref.cast (ref 105)
          local.get 6
          array.get 105
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
            ref.cast (ref 53)
            struct.get 53 5
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
            ref.cast (ref 110)
            local.get 6
            array.get 110
            struct.new 51
            struct.new 5
          else
            i32.const 0
            i32.const 0
            i64.const 0
            f32.const 0x0p+0 (;=0;)
            f64.const 0x0p+0 (;=0;)
            v128.const i32x4 0x00000000 0x00000000 0x00000000 0x00000000
            local.get 4
            ref.cast (ref 53)
            struct.get 53 0
            call 31
            struct.new 4
          end
        end
      end
    end
    ref.cast (ref 3)
  )
  (func (;76;) (type 97) (param (ref 39)) (result (ref 3))
    local.get 0
    i32.const 128
    i32.const 16777216
    call 75
    ref.cast (ref 3)
  )
  (func (;77;) (type 98) (result i32)
    (local eqref eqref eqref i32 eqref i32)
    v128.const i32x4 0x61227b20 0x745b3a22 0x2c657572 0x6c6c756e
    v128.const i32x4 0x2e312d2c 0x32653532 0x62222c5d 0x30223a22
    v128.const i32x4 0x34333231 0x38373635 0x63626139 0x22666564
    v128.const i32x4 0x0000207d 0x00000000 0x00000000 0x00000000
    array.new_fixed 99 4
    i32.const 0
    i32.const 50
    struct.new 100
    call 67
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
          ref.cast (ref 39)
          call 76
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
                array.new_fixed 99 3
                i32.const 0
                i32.const 48
                struct.new 100
                call 24
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
