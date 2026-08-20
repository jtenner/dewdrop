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
  (type (;11;) (struct (field (mut eqref)) (field (mut i32)) (field (mut i32))))
  (type (;12;) (struct (field eqref) (field (mut i32))))
  (type (;13;) (sub (struct (field funcref))))
  (type (;14;) (func (param eqref) (result eqref)))
  (type (;15;) (func (param eqref i32) (result eqref)))
  (type (;16;) (func (param eqref) (result (ref 11))))
  (type (;17;) (func (param eqref eqref) (result eqref)))
  (type (;18;) (func (param eqref)))
  (type (;19;) (func (param eqref i32)))
  (type (;20;) (func (param eqref) (result i32)))
  (type (;21;) (func (param eqref i32) (result i32)))
  (type (;22;) (func (param eqref eqref i32) (result eqref)))
  (type (;23;) (func (param eqref eqref) (result (ref 11))))
  (type (;24;) (func (param eqref eqref eqref) (result eqref)))
  (type (;25;) (func (param eqref eqref)))
  (type (;26;) (func (param eqref eqref i32)))
  (type (;27;) (func (param eqref eqref) (result i32)))
  (type (;28;) (func (param eqref eqref i32) (result i32)))
  (type (;29;) (func (param eqref eqref eqref i32) (result eqref)))
  (type (;30;) (func (param eqref eqref) (result i32)))
  (type (;31;) (func (param i32) (result eqref)))
  (type (;32;) (func (param eqref i32)))
  (type (;33;) (func (param eqref) (result eqref)))
  (type (;34;) (func (param i32) (result eqref)))
  (type (;35;) (func (param eqref i32)))
  (type (;36;) (func (param eqref) (result eqref)))
  (type (;37;) (func (param eqref) (result i32)))
  (type (;38;) (func (param eqref i32) (result i32)))
  (type (;39;) (func (param eqref) (result i32)))
  (type (;40;) (func (param eqref i32) (result i32)))
  (type (;41;) (struct (field (ref 0)) (field (ref 0)) (field i64) (field i32) (field i32)))
  (type (;42;) (func))
  (type (;43;) (func (result (ref 0))))
  (type (;44;) (func (result (ref 0))))
  (type (;45;) (func (param i32 i32) (result i32)))
  (type (;46;) (func (param (ref 0) i32 i32 i32 i32 i32 i32)))
  (type (;47;) (func (param (ref 0) (ref 0))))
  (type (;48;) (func (param (ref 0)) (result (ref 0))))
  (type (;49;) (func (param i64) (result i32)))
  (type (;50;) (func (param (ref 41) i64) (result (ref 0))))
  (type (;51;) (func (param (ref 0)) (result (ref 0))))
  (type (;52;) (func (param (ref 41)) (result (ref 0))))
  (type (;53;) (func (param i32) (result i32)))
  (type (;54;) (func (param (ref 41)) (result (ref 6))))
  (type (;55;) (func (param i32) (result i32)))
  (type (;56;) (func (param eqref i32 i32) (result (ref 0))))
  (type (;57;) (func (param eqref i32 i32 i64) (result (ref 41))))
  (type (;58;) (func (param (ref 0) (ref 0)) (result (ref 41))))
  (type (;59;) (func (param i32) (result i64)))
  (type (;60;) (func (param i32) (result (ref 11))))
  (type (;61;) (func (result (ref 8))))
  (type (;62;) (func (param eqref) (result (ref 6))))
  (type (;63;) (func (param eqref) (result i32)))
  (type (;64;) (func (param eqref eqref) (result i32)))
  (type (;65;) (func (param i32) (result eqref)))
  (type (;66;) (func (param eqref i32)))
  (type (;67;) (func (param eqref) (result eqref)))
  (type (;68;) (func (param i32) (result eqref)))
  (type (;69;) (func (param eqref i32)))
  (type (;70;) (func (param eqref) (result eqref)))
  (type (;71;) (func (param i32) (result i32)))
  (type (;72;) (func (param i32) (result eqref)))
  (type (;73;) (func (param i32) (result i32)))
  (type (;74;) (func (param i32) (result i32)))
  (type (;75;) (func (param i32) (result i32)))
  (type (;76;) (func (param i32) (result i32)))
  (type (;77;) (func (param (ref 6)) (result eqref)))
  (type (;78;) (func (param i32 eqref)))
  (type (;79;) (func))
  (type (;80;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;81;) (struct))
  (type (;82;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;83;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;84;) (struct (field (mut eqref)) (field (mut i32))))
  (type (;85;) (array (mut v128)))
  (type (;86;) (struct (field (ref 85)) (field i32) (field i32)))
  (type (;87;) (struct (field (ref 85)) (field i32) (field i32)))
  (type (;88;) (struct (field (ref 85)) (field i32) (field i32)))
  (type (;89;) (struct (field (mut (ref 85))) (field (mut i32)) (field (mut i32))))
  (type (;90;) (struct (field (mut (ref 85))) (field (mut i32)) (field (mut i32))))
  (export "main" (func 48))
  (func (;0;) (type 30) (param eqref eqref) (result i32)
    (local (ref 86) (ref 86) (ref 85) (ref 85) i32 i32 i32 i32 v128 v128)
    local.get 0
    ref.cast (ref 86)
    local.set 2
    local.get 1
    ref.cast (ref 86)
    local.set 3
    local.get 2
    struct.get 86 2
    local.tee 6
    local.get 3
    struct.get 86 2
    i32.ne
    if ;; label = @1
      i32.const 0
      return
    end
    local.get 2
    struct.get 86 0
    local.set 4
    local.get 3
    struct.get 86 0
    local.set 5
    local.get 2
    struct.get 86 1
    local.set 7
    local.get 3
    struct.get 86 1
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
          array.get 85
          local.set 10
        else
          local.get 4
          local.get 7
          i32.const 4
          i32.shr_u
          array.get 85
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
          array.get 85
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
          array.get 85
          local.set 11
        else
          local.get 5
          local.get 8
          i32.const 4
          i32.shr_u
          array.get 85
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
          array.get 85
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
      array.get 85
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
      array.get 85
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
  (func (;1;) (type 31) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 85
    i32.const 0
    i32.const 0
    struct.new 89
  )
  (func (;2;) (type 32) (param eqref i32)
    (local (ref 89) (ref 85) i32 i32 i32 (ref 85) i32)
    local.get 1
    i32.const 127
    i32.gt_u
    if ;; label = @1
      unreachable
    end
    local.get 0
    ref.cast (ref 89)
    local.set 2
    local.get 2
    struct.get 89 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 89 0
    local.set 3
    local.get 2
    struct.get 89 1
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
      array.new_default 85
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
          array.get 85
          array.set 85
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 89 0
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
    array.get 85
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 85
    local.get 2
    local.get 5
    struct.set 89 1
  )
  (func (;3;) (type 33) (param eqref) (result eqref)
    (local (ref 89))
    local.get 0
    ref.cast (ref 89)
    local.set 1
    local.get 1
    struct.get 89 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 89 2
    local.get 1
    struct.get 89 0
    i32.const 0
    local.get 1
    struct.get 89 1
    struct.new 86
  )
  (func (;4;) (type 34) (param i32) (result eqref)
    local.get 0
    i32.const 4
    i32.shr_u
    local.get 0
    i32.const 15
    i32.and
    i32.const 0
    i32.ne
    i32.add
    array.new_default 85
    i32.const 0
    i32.const 0
    struct.new 90
  )
  (func (;5;) (type 35) (param eqref i32)
    (local (ref 90) (ref 85) i32 i32 i32 (ref 85) i32)
    local.get 0
    ref.cast (ref 90)
    local.set 2
    local.get 2
    struct.get 90 2
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 90 0
    local.set 3
    local.get 2
    struct.get 90 1
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
      array.new_default 85
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
          array.get 85
          array.set 85
          local.get 8
          i32.const 1
          i32.add
          local.set 8
          br 0 (;@3;)
        end
      end
      local.get 2
      local.get 7
      struct.set 90 0
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
    array.get 85
    v128.const i32x4 0x03020100 0x07060504 0x0b0a0908 0x0f0e0d0c
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.eq
    v128.bitselect
    array.set 85
    local.get 2
    local.get 5
    struct.set 90 1
  )
  (func (;6;) (type 36) (param eqref) (result eqref)
    (local (ref 90))
    local.get 0
    ref.cast (ref 90)
    local.set 1
    local.get 1
    struct.get 90 2
    if ;; label = @1
      unreachable
    end
    local.get 1
    i32.const 1
    struct.set 90 2
    local.get 1
    struct.get 90 0
    i32.const 0
    local.get 1
    struct.get 90 1
    struct.new 87
  )
  (func (;7;) (type 37) (param eqref) (result i32)
    local.get 0
    ref.cast (ref 87)
    struct.get 87 2
  )
  (func (;8;) (type 38) (param eqref i32) (result i32)
    (local (ref 87) (ref 85) i32)
    local.get 0
    ref.cast (ref 87)
    local.set 2
    local.get 1
    local.get 2
    struct.get 87 2
    i32.ge_u
    if ;; label = @1
      unreachable
    end
    local.get 2
    struct.get 87 0
    local.set 3
    local.get 2
    struct.get 87 1
    local.get 1
    i32.add
    local.set 4
    local.get 3
    local.get 4
    i32.const 4
    i32.shr_u
    array.get 85
    local.get 4
    i32.const 15
    i32.and
    i8x16.splat
    i8x16.swizzle
    i8x16.extract_lane_u 0
  )
  (func (;9;) (type 39) (param eqref) (result i32)
    local.get 0
    call 7
  )
  (func (;10;) (type 40) (param eqref i32) (result i32)
    local.get 0
    local.get 1
    call 8
  )
  (func (;11;) (type 42))
  (func (;12;) (type 43) (result (ref 0))
    (local eqref eqref i32)
    i32.const 8
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 1779033703
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const -1150833019
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 1013904242
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 3
    i32.const -1521486534
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 4
    i32.const 1359893119
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 5
    i32.const -1694144372
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 6
    i32.const 528734635
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 7
    i32.const 1541459225
    array.set 0
    local.get 0
    ref.cast (ref 0)
  )
  (func (;13;) (type 44) (result (ref 0))
    (local eqref eqref i32)
    i32.const 16
    local.set 2
    i32.const 0
    local.get 2
    array.new 0
    local.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 2
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const 6
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 3
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 3
    i32.const 10
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 4
    i32.const 7
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 5
    i32.const 0
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 6
    i32.const 4
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 7
    i32.const 13
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 8
    i32.const 1
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 9
    i32.const 11
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 10
    i32.const 12
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 11
    i32.const 5
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 12
    i32.const 9
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 13
    i32.const 14
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 14
    i32.const 15
    array.set 0
    local.get 0
    ref.cast (ref 0)
    i32.const 15
    i32.const 8
    array.set 0
    local.get 0
    ref.cast (ref 0)
  )
  (func (;14;) (type 45) (param i32 i32) (result i32)
    local.get 0
    local.get 1
    i32.shr_u
    local.get 0
    i32.const 32
    local.get 1
    i32.sub
    i32.shl
    i32.or
  )
  (func (;15;) (type 46) (param (ref 0) i32 i32 i32 i32 i32 i32)
    local.get 0
    ref.cast (ref 0)
    local.get 1
    local.get 0
    ref.cast (ref 0)
    local.get 1
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.add
    local.get 5
    i32.add
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 4
    local.get 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 1
    array.get 0
    i32.xor
    i32.const 16
    call 14
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 3
    local.get 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.add
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 2
    local.get 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.xor
    i32.const 12
    call 14
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 1
    local.get 0
    ref.cast (ref 0)
    local.get 1
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    i32.add
    local.get 6
    i32.add
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 4
    local.get 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 1
    array.get 0
    i32.xor
    i32.const 8
    call 14
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 3
    local.get 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 4
    array.get 0
    i32.add
    array.set 0
    local.get 0
    ref.cast (ref 0)
    local.get 2
    local.get 0
    ref.cast (ref 0)
    local.get 2
    array.get 0
    local.get 0
    ref.cast (ref 0)
    local.get 3
    array.get 0
    i32.xor
    i32.const 7
    call 14
    array.set 0
  )
  (func (;16;) (type 47) (param (ref 0) (ref 0))
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 4
    i32.const 8
    i32.const 12
    local.get 1
    ref.cast (ref 0)
    i32.const 0
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 1
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const 5
    i32.const 9
    i32.const 13
    local.get 1
    ref.cast (ref 0)
    i32.const 2
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 3
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 6
    i32.const 10
    i32.const 14
    local.get 1
    ref.cast (ref 0)
    i32.const 4
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 5
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 3
    i32.const 7
    i32.const 11
    i32.const 15
    local.get 1
    ref.cast (ref 0)
    i32.const 6
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 7
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 0
    i32.const 5
    i32.const 10
    i32.const 15
    local.get 1
    ref.cast (ref 0)
    i32.const 8
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 9
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 1
    i32.const 6
    i32.const 11
    i32.const 12
    local.get 1
    ref.cast (ref 0)
    i32.const 10
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 11
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 2
    i32.const 7
    i32.const 8
    i32.const 13
    local.get 1
    ref.cast (ref 0)
    i32.const 12
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 13
    array.get 0
    call 15
    local.get 0
    ref.cast (ref 0)
    i32.const 3
    i32.const 4
    i32.const 9
    i32.const 14
    local.get 1
    ref.cast (ref 0)
    i32.const 14
    array.get 0
    local.get 1
    ref.cast (ref 0)
    i32.const 15
    array.get 0
    call 15
  )
  (func (;17;) (type 48) (param (ref 0)) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 eqref)
    call 13
    local.set 1
    i32.const 16
    local.set 5
    i32.const 0
    local.get 5
    array.new 0
    local.set 2
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 3
            local.get 3
            i32.const 16
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 3
              local.get 0
              ref.cast (ref 0)
              local.get 1
              ref.cast (ref 0)
              local.get 3
              array.get 0
              array.get 0
              array.set 0
              local.get 3
              i32.const 1
              i32.add
              local.set 6
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
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
    ref.cast (ref 0)
  )
  (func (;18;) (type 49) (param i64) (result i32)
    local.get 0
    i32.wrap_i64
  )
  (func (;19;) (type 50) (param (ref 41) i64) (result (ref 0))
    (local eqref i32 eqref i32 eqref i32 eqref i32 eqref i32 i32 i32 i32 i32 eqref)
    i32.const 16
    local.set 11
    i32.const 0
    local.get 11
    array.new 0
    local.set 2
    i32.const 0
    local.set 12
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 12
            local.set 3
            local.get 3
            i32.const 8
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 3
              local.get 0
              ref.cast (ref 41)
              struct.get 41 0
              ref.cast (ref 0)
              local.get 3
              array.get 0
              array.set 0
              local.get 3
              i32.const 1
              i32.add
              local.set 12
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    call 12
    local.set 4
    i32.const 0
    local.set 13
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 13
            local.set 5
            local.get 5
            i32.const 4
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              i32.const 8
              local.get 5
              i32.add
              local.get 4
              ref.cast (ref 0)
              local.get 5
              array.get 0
              array.set 0
              local.get 5
              i32.const 1
              i32.add
              local.set 13
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 2
    ref.cast (ref 0)
    i32.const 12
    local.get 1
    call 18
    array.set 0
    local.get 2
    ref.cast (ref 0)
    i32.const 13
    local.get 1
    i64.const 32
    i64.shr_u
    call 18
    array.set 0
    local.get 2
    ref.cast (ref 0)
    i32.const 14
    local.get 0
    ref.cast (ref 41)
    struct.get 41 3
    array.set 0
    local.get 2
    ref.cast (ref 0)
    i32.const 15
    local.get 0
    ref.cast (ref 41)
    struct.get 41 4
    array.set 0
    local.get 0
    ref.cast (ref 41)
    struct.get 41 1
    local.set 6
    i32.const 0
    local.set 14
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 14
            local.set 7
            local.get 7
            i32.const 7
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 6
              ref.cast (ref 0)
              call 16
              local.get 7
              i32.const 6
              i32.ne
              if ;; label = @6
                local.get 6
                ref.cast (ref 0)
                call 17
                local.set 6
              else
              end
              local.get 7
              i32.const 1
              i32.add
              local.set 14
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    i32.const 16
    local.set 11
    i32.const 0
    local.get 11
    array.new 0
    local.set 8
    i32.const 0
    local.set 15
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 15
            local.set 9
            local.get 9
            i32.const 8
            i32.lt_u
            if ;; label = @5
              local.get 8
              ref.cast (ref 0)
              local.get 9
              local.get 2
              ref.cast (ref 0)
              local.get 9
              array.get 0
              local.get 2
              ref.cast (ref 0)
              local.get 9
              i32.const 8
              i32.add
              array.get 0
              i32.xor
              array.set 0
              local.get 8
              ref.cast (ref 0)
              local.get 9
              i32.const 8
              i32.add
              local.get 2
              ref.cast (ref 0)
              local.get 9
              i32.const 8
              i32.add
              array.get 0
              local.get 0
              ref.cast (ref 41)
              struct.get 41 0
              ref.cast (ref 0)
              local.get 9
              array.get 0
              i32.xor
              array.set 0
              local.get 9
              i32.const 1
              i32.add
              local.set 15
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 8
            local.set 16
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 16
    ref.cast (ref 0)
  )
  (func (;20;) (type 51) (param (ref 0)) (result (ref 0))
    (local eqref i32 eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 0)
    array.len
    local.set 4
    i32.const 0
    local.get 4
    array.new 0
    local.set 1
    i32.const 0
    local.set 5
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 5
            local.set 2
            local.get 2
            local.get 0
            ref.cast (ref 0)
            array.len
            i32.lt_u
            if ;; label = @5
              local.get 1
              ref.cast (ref 0)
              local.get 2
              local.get 0
              ref.cast (ref 0)
              local.get 2
              array.get 0
              array.set 0
              local.get 2
              i32.const 1
              i32.add
              local.set 5
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 1
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
    ref.cast (ref 0)
  )
  (func (;21;) (type 52) (param (ref 41)) (result (ref 0))
    (local eqref eqref i32 eqref i32 i32 eqref)
    local.get 0
    local.get 0
    ref.cast (ref 41)
    struct.get 41 2
    call 19
    local.set 1
    i32.const 8
    local.set 5
    i32.const 0
    local.get 5
    array.new 0
    local.set 2
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 3
            local.get 3
            i32.const 8
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 3
              local.get 1
              ref.cast (ref 0)
              local.get 3
              array.get 0
              array.set 0
              local.get 3
              i32.const 1
              i32.add
              local.set 6
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 2
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
    ref.cast (ref 0)
  )
  (func (;22;) (type 53) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;23;) (type 54) (param (ref 41)) (result (ref 6))
    (local (ref 41) eqref eqref i32 i32 i32 eqref i32 i32 eqref)
    local.get 0
    ref.cast (ref 41)
    struct.get 41 0
    ref.cast (ref 0)
    local.get 0
    ref.cast (ref 41)
    struct.get 41 1
    ref.cast (ref 0)
    local.get 0
    ref.cast (ref 41)
    struct.get 41 2
    local.get 0
    ref.cast (ref 41)
    struct.get 41 3
    local.get 0
    ref.cast (ref 41)
    struct.get 41 4
    i32.const 8
    i32.or
    struct.new 41
    local.set 1
    local.get 1
    i64.const 0
    call 19
    local.set 2
    i32.const 32
    local.set 8
    i32.const 0
    local.get 8
    array.new 6
    local.set 3
    i32.const 0
    local.set 9
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 9
            local.set 4
            local.get 4
            i32.const 8
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 4
              array.get 0
              local.set 5
              local.get 4
              i32.const 4
              i32.mul
              local.set 6
              local.get 3
              ref.cast (ref 6)
              local.get 6
              local.get 5
              i32.const 255
              i32.and
              call 22
              array.set 6
              local.get 3
              ref.cast (ref 6)
              local.get 6
              i32.const 1
              i32.add
              local.get 5
              i32.const 8
              i32.shr_u
              i32.const 255
              i32.and
              call 22
              array.set 6
              local.get 3
              ref.cast (ref 6)
              local.get 6
              i32.const 2
              i32.add
              local.get 5
              i32.const 16
              i32.shr_u
              i32.const 255
              i32.and
              call 22
              array.set 6
              local.get 3
              ref.cast (ref 6)
              local.get 6
              i32.const 3
              i32.add
              local.get 5
              i32.const 24
              i32.shr_u
              i32.const 255
              i32.and
              call 22
              array.set 6
              local.get 4
              i32.const 1
              i32.add
              local.set 9
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 3
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
    ref.cast (ref 6)
  )
  (func (;24;) (type 55) (param i32) (result i32)
    local.get 0
  )
  (func (;25;) (type 56) (param eqref i32 i32) (result (ref 0))
    (local eqref i32 i32 i32 i32 eqref i32 i32 eqref)
    i32.const 16
    local.set 9
    i32.const 0
    local.get 9
    array.new 0
    local.set 3
    i32.const 0
    local.set 10
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 10
            local.set 4
            local.get 4
            local.get 2
            i32.lt_u
            if ;; label = @5
              local.get 4
              i32.const 4
              i32.div_u
              local.set 5
              local.get 4
              i32.const 4
              i32.rem_u
              i32.const 8
              i32.mul
              local.set 6
              local.get 3
              ref.cast (ref 0)
              local.get 5
              array.get 0
              local.get 0
              local.get 1
              local.get 4
              i32.add
              call 10
              call 24
              local.get 6
              i32.shl
              i32.or
              local.set 7
              local.get 3
              ref.cast (ref 0)
              local.get 5
              local.get 7
              array.set 0
              local.get 4
              i32.const 1
              i32.add
              local.set 10
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 11
    ref.cast (ref 0)
  )
  (func (;26;) (type 57) (param eqref i32 i32 i64) (result (ref 41))
    (local i32 eqref (ref 41) i32 i32 i32 i32 i32 i32 eqref i32 eqref i32 i32 i32 eqref)
    local.get 2
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 2
      i32.const 64
      i32.div_u
      local.get 2
      i32.const 64
      i32.rem_u
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        i32.const 0
      else
        i32.const 1
      end
      i32.add
    end
    local.set 4
    call 12
    local.set 5
    local.get 5
    ref.cast (ref 0)
    i32.const 16
    local.set 16
    i32.const 0
    local.get 16
    array.new 0
    ref.cast (ref 0)
    local.get 3
    i32.const 0
    i32.const 1
    i32.const 2
    i32.or
    struct.new 41
    local.set 6
    i32.const 0
    local.set 18
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 18
            local.set 7
            local.get 7
            local.get 4
            i32.lt_u
            if ;; label = @5
              local.get 1
              local.get 7
              i32.const 64
              i32.mul
              i32.add
              local.set 8
              local.get 7
              i32.const 64
              i32.mul
              local.set 9
              local.get 2
              local.get 9
              i32.sub
              local.set 10
              local.get 10
              i32.const 64
              i32.lt_u
              if (result i32) ;; label = @6
                local.get 10
              else
                i32.const 64
              end
              local.set 11
              i32.const 0
              local.set 12
              local.get 7
              i32.const 0
              i32.eq
              if ;; label = @6
                local.get 12
                i32.const 1
                i32.or
                local.set 12
              else
              end
              local.get 7
              i32.const 1
              i32.add
              local.get 4
              i32.eq
              if ;; label = @6
                local.get 12
                i32.const 2
                i32.or
                local.set 12
              else
              end
              local.get 5
              ref.cast (ref 0)
              call 20
              ref.cast (ref 0)
              local.get 0
              local.get 8
              local.get 11
              call 25
              ref.cast (ref 0)
              local.get 3
              local.get 11
              local.get 12
              struct.new 41
              local.set 6
              local.get 7
              i32.const 1
              i32.add
              local.get 4
              i32.ne
              if ;; label = @6
                local.get 6
                call 21
                local.set 13
                i32.const 0
                local.set 17
                block ;; label = @7
                  loop ;; label = @8
                    block ;; label = @9
                      i32.const 1
                      if ;; label = @10
                        local.get 17
                        local.set 14
                        local.get 14
                        i32.const 8
                        i32.lt_u
                        if ;; label = @11
                          local.get 5
                          ref.cast (ref 0)
                          local.get 14
                          local.get 13
                          ref.cast (ref 0)
                          local.get 14
                          array.get 0
                          array.set 0
                          local.get 14
                          i32.const 1
                          i32.add
                          local.set 17
                          br 3 (;@8;)
                          br 2 (;@9;)
                        end
                      end
                      i32.const 1
                      if ;; label = @10
                        call 11
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
              local.get 7
              i32.const 1
              i32.add
              local.set 18
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 19
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 19
    ref.cast (ref 41)
  )
  (func (;27;) (type 58) (param (ref 0) (ref 0)) (result (ref 41))
    (local eqref i32 eqref i32 i32)
    i32.const 16
    local.set 5
    i32.const 0
    local.get 5
    array.new 0
    local.set 2
    i32.const 0
    local.set 6
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 6
            local.set 3
            local.get 3
            i32.const 8
            i32.lt_u
            if ;; label = @5
              local.get 2
              ref.cast (ref 0)
              local.get 3
              local.get 0
              ref.cast (ref 0)
              local.get 3
              array.get 0
              array.set 0
              local.get 2
              ref.cast (ref 0)
              local.get 3
              i32.const 8
              i32.add
              local.get 1
              ref.cast (ref 0)
              local.get 3
              array.get 0
              array.set 0
              local.get 3
              i32.const 1
              i32.add
              local.set 6
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            call 11
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    call 12
    ref.cast (ref 0)
    local.get 2
    ref.cast (ref 0)
    i64.const 0
    i32.const 64
    i32.const 4
    struct.new 41
    ref.cast (ref 41)
  )
  (func (;28;) (type 59) (param i32) (result i64)
    local.get 0
    i64.extend_i32_u
  )
  (func (;29;) (type 60) (param i32) (result (ref 11))
    (local eqref i32 eqref)
    local.get 0
    local.set 2
    local.get 2
    array.new_default 5
    i32.const 0
    local.get 2
    struct.new 11
    ref.cast (ref 11)
  )
  (func (;30;) (type 61) (result (ref 8))
    i32.const 0
    struct.new 8
    ref.cast (ref 8)
  )
  (func (;31;) (type 62) (param eqref) (result (ref 6))
    (local i32 i32 eqref i32 i32 i32 i32 eqref eqref i32 eqref i32 (ref 41) (ref 41) eqref i32 eqref eqref i32 eqref eqref i32 i32 eqref eqref)
    local.get 0
    call 9
    local.set 1
    local.get 1
    i32.const 0
    i32.eq
    if (result i32) ;; label = @1
      i32.const 1
    else
      local.get 1
      i32.const 1024
      i32.div_u
      local.get 1
      i32.const 1024
      i32.rem_u
      i32.const 0
      i32.eq
      if (result i32) ;; label = @2
        i32.const 0
      else
        i32.const 1
      end
      i32.add
    end
    local.set 2
    local.get 2
    i32.const 1
    i32.eq
    if (result eqref) ;; label = @1
      local.get 0
      i32.const 0
      local.get 1
      i64.const 0
      call 26
      call 23
    else
      local.get 2
      call 29
      local.set 3
      i32.const 0
      local.set 19
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 19
              local.set 4
              local.get 4
              local.get 2
              i32.lt_u
              if ;; label = @6
                local.get 4
                i32.const 1024
                i32.mul
                local.set 5
                local.get 1
                local.get 5
                i32.sub
                local.set 6
                local.get 6
                i32.const 1024
                i32.lt_u
                if (result i32) ;; label = @7
                  local.get 6
                else
                  i32.const 1024
                end
                local.set 7
                local.get 3
                local.get 0
                local.get 5
                local.get 7
                local.get 4
                call 28
                call 26
                call 21
                local.set 18
                local.set 15
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                local.get 15
                ref.cast (ref 11)
                struct.get 11 2
                i32.eq
                if ;; label = @7
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 2
                  i32.eqz
                  if (result i32) ;; label = @8
                    i32.const 4
                  else
                    local.get 15
                    ref.cast (ref 11)
                    struct.get 11 2
                    i32.const 2
                    i32.mul
                  end
                  local.set 16
                  local.get 16
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 2
                  i32.le_u
                  if ;; label = @8
                    unreachable
                  end
                  local.get 16
                  array.new_default 5
                  local.set 17
                  local.get 17
                  ref.cast (ref 5)
                  i32.const 0
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 0
                  ref.cast (ref 5)
                  i32.const 0
                  local.get 15
                  ref.cast (ref 11)
                  struct.get 11 1
                  array.copy 5 5
                  local.get 15
                  ref.cast (ref 11)
                  local.get 17
                  struct.set 11 0
                  local.get 15
                  ref.cast (ref 11)
                  local.get 17
                  ref.cast (ref 5)
                  array.len
                  struct.set 11 2
                end
                local.get 15
                ref.cast (ref 11)
                struct.get 11 0
                ref.cast (ref 5)
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                local.get 18
                array.set 5
                local.get 15
                ref.cast (ref 11)
                local.get 15
                ref.cast (ref 11)
                struct.get 11 1
                i32.const 1
                i32.add
                struct.set 11 1
                local.get 4
                i32.const 1
                i32.add
                local.set 19
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 11
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 3
      local.set 8
      call 30
      local.set 9
      local.get 8
      ref.cast (ref 11)
      struct.get 11 1
      local.set 23
      block ;; label = @2
        loop ;; label = @3
          block ;; label = @4
            i32.const 1
            if ;; label = @5
              local.get 23
              local.set 10
              local.get 10
              i32.const 1
              i32.gt_u
              if ;; label = @6
                local.get 10
                i32.const 2
                i32.div_u
                local.get 10
                i32.const 2
                i32.rem_u
                i32.add
                call 29
                local.set 11
                i32.const 0
                local.set 22
                block ;; label = @7
                  loop ;; label = @8
                    block ;; label = @9
                      i32.const 1
                      if ;; label = @10
                        local.get 22
                        local.set 12
                        local.get 12
                        local.get 10
                        i32.lt_u
                        if ;; label = @11
                          local.get 12
                          i32.const 1
                          i32.add
                          local.get 10
                          i32.eq
                          if ;; label = @12
                            local.get 11
                            local.get 8
                            local.get 12
                            local.set 16
                            local.set 15
                            local.get 16
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            i32.ge_u
                            if ;; label = @13
                              unreachable
                            end
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 0
                            ref.cast (ref 5)
                            local.get 16
                            array.get 5
                            local.set 20
                            local.set 15
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 2
                            i32.eq
                            if ;; label = @13
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 2
                              i32.eqz
                              if (result i32) ;; label = @14
                                i32.const 4
                              else
                                local.get 15
                                ref.cast (ref 11)
                                struct.get 11 2
                                i32.const 2
                                i32.mul
                              end
                              local.set 16
                              local.get 16
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 2
                              i32.le_u
                              if ;; label = @14
                                unreachable
                              end
                              local.get 16
                              array.new_default 5
                              local.set 17
                              local.get 17
                              ref.cast (ref 5)
                              i32.const 0
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 0
                              ref.cast (ref 5)
                              i32.const 0
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 1
                              array.copy 5 5
                              local.get 15
                              ref.cast (ref 11)
                              local.get 17
                              struct.set 11 0
                              local.get 15
                              ref.cast (ref 11)
                              local.get 17
                              ref.cast (ref 5)
                              array.len
                              struct.set 11 2
                            end
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 0
                            ref.cast (ref 5)
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            local.get 20
                            array.set 5
                            local.get 15
                            ref.cast (ref 11)
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            i32.const 1
                            i32.add
                            struct.set 11 1
                            local.get 12
                            i32.const 1
                            i32.add
                            local.set 22
                            br 4 (;@8;)
                          else
                            local.get 8
                            local.get 12
                            local.set 16
                            local.set 15
                            local.get 16
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            i32.ge_u
                            if ;; label = @13
                              unreachable
                            end
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 0
                            ref.cast (ref 5)
                            local.get 16
                            array.get 5
                            ref.cast (ref 0)
                            local.get 8
                            local.get 12
                            i32.const 1
                            i32.add
                            local.set 16
                            local.set 15
                            local.get 16
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            i32.ge_u
                            if ;; label = @13
                              unreachable
                            end
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 0
                            ref.cast (ref 5)
                            local.get 16
                            array.get 5
                            ref.cast (ref 0)
                            call 27
                            local.set 13
                            i32.const 1
                            local.get 13
                            struct.new 10
                            local.set 9
                            local.get 11
                            local.get 13
                            call 21
                            local.set 21
                            local.set 15
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 2
                            i32.eq
                            if ;; label = @13
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 2
                              i32.eqz
                              if (result i32) ;; label = @14
                                i32.const 4
                              else
                                local.get 15
                                ref.cast (ref 11)
                                struct.get 11 2
                                i32.const 2
                                i32.mul
                              end
                              local.set 16
                              local.get 16
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 2
                              i32.le_u
                              if ;; label = @14
                                unreachable
                              end
                              local.get 16
                              array.new_default 5
                              local.set 17
                              local.get 17
                              ref.cast (ref 5)
                              i32.const 0
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 0
                              ref.cast (ref 5)
                              i32.const 0
                              local.get 15
                              ref.cast (ref 11)
                              struct.get 11 1
                              array.copy 5 5
                              local.get 15
                              ref.cast (ref 11)
                              local.get 17
                              struct.set 11 0
                              local.get 15
                              ref.cast (ref 11)
                              local.get 17
                              ref.cast (ref 5)
                              array.len
                              struct.set 11 2
                            end
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 0
                            ref.cast (ref 5)
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            local.get 21
                            array.set 5
                            local.get 15
                            ref.cast (ref 11)
                            local.get 15
                            ref.cast (ref 11)
                            struct.get 11 1
                            i32.const 1
                            i32.add
                            struct.set 11 1
                            local.get 12
                            i32.const 2
                            i32.add
                            local.set 22
                            br 4 (;@8;)
                          end
                          br 2 (;@9;)
                        end
                      end
                      i32.const 1
                      if ;; label = @10
                        call 11
                        br 3 (;@7;)
                        br 1 (;@9;)
                      end
                      unreachable
                    end
                    unreachable
                  end
                  unreachable
                end
                local.get 11
                local.set 8
                local.get 8
                ref.cast (ref 11)
                struct.get 11 1
                local.set 23
                br 3 (;@3;)
                br 2 (;@4;)
              end
            end
            i32.const 1
            if ;; label = @5
              call 11
              br 3 (;@2;)
              br 1 (;@4;)
            end
            unreachable
          end
          unreachable
        end
        unreachable
      end
      local.get 9
      local.set 24
      block ;; label = @2
        block ;; label = @3
          block ;; label = @4
            block ;; label = @5
              local.get 24
              ref.cast (ref 8)
              struct.get 8 0
              br_table 0 (;@5;) 1 (;@4;) 2 (;@3;)
            end
            unreachable
            local.set 25
            br 2 (;@2;)
          end
          local.get 24
          ref.cast (ref 10)
          struct.get 10 1
          ref.cast (ref 41)
          local.set 14
          local.get 14
          call 23
          local.set 25
          br 1 (;@2;)
        end
        unreachable
      end
      local.get 25
    end
    ref.cast (ref 6)
  )
  (func (;32;) (type 63) (param eqref) (result i32)
    (local eqref)
    local.get 0
    call 31
    local.set 1
    local.get 1
    ref.cast (ref 6)
    i32.const 0
    array.get_u 6
    call 24
    local.get 1
    ref.cast (ref 6)
    i32.const 1
    array.get_u 6
    call 24
    i32.const 8
    i32.shl
    i32.or
    local.get 1
    ref.cast (ref 6)
    i32.const 2
    array.get_u 6
    call 24
    i32.const 16
    i32.shl
    i32.or
    local.get 1
    ref.cast (ref 6)
    i32.const 3
    array.get_u 6
    call 24
    i32.const 24
    i32.shl
    i32.or
  )
  (func (;33;) (type 64) (param eqref eqref) (result i32)
    local.get 0
    local.get 1
    call 0
  )
  (func (;34;) (type 65) (param i32) (result eqref)
    local.get 0
    call 1
  )
  (func (;35;) (type 66) (param eqref i32)
    local.get 0
    local.get 1
    call 2
  )
  (func (;36;) (type 67) (param eqref) (result eqref)
    local.get 0
    call 3
  )
  (func (;37;) (type 68) (param i32) (result eqref)
    local.get 0
    call 4
  )
  (func (;38;) (type 69) (param eqref i32)
    local.get 0
    local.get 1
    call 5
  )
  (func (;39;) (type 70) (param eqref) (result eqref)
    local.get 0
    call 6
  )
  (func (;40;) (type 71) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;41;) (type 72) (param i32) (result eqref)
    (local eqref i32 i32 eqref)
    local.get 0
    call 37
    local.set 1
    i32.const 0
    local.set 3
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 3
            local.set 2
            local.get 2
            local.get 0
            i32.lt_u
            if ;; label = @5
              local.get 1
              local.get 2
              i32.const 251
              i32.rem_u
              call 40
              call 38
              local.get 2
              i32.const 1
              i32.add
              local.set 3
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 1
            call 39
            local.set 4
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 4
  )
  (func (;42;) (type 73) (param i32) (result i32)
    local.get 0
  )
  (func (;43;) (type 74) (param i32) (result i32)
    local.get 0
    i32.const 255
    i32.and
  )
  (func (;44;) (type 75) (param i32) (result i32)
    local.get 0
    call 42
    i32.const 4
    i32.shr_u
    call 43
  )
  (func (;45;) (type 76) (param i32) (result i32)
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
  (func (;46;) (type 77) (param (ref 6)) (result eqref)
    (local eqref i32 i32 i32 eqref)
    i32.const 64
    call 34
    local.set 1
    i32.const 0
    local.set 4
    block ;; label = @1
      loop ;; label = @2
        block ;; label = @3
          i32.const 1
          if ;; label = @4
            local.get 4
            local.set 2
            local.get 2
            i32.const 32
            i32.lt_u
            if ;; label = @5
              local.get 0
              ref.cast (ref 6)
              local.get 2
              array.get_u 6
              local.set 3
              local.get 1
              local.get 3
              call 44
              call 45
              call 35
              local.get 1
              local.get 3
              i32.const 15
              i32.and
              i32.const 255
              i32.and
              call 45
              call 35
              local.get 2
              i32.const 1
              i32.add
              local.set 4
              br 3 (;@2;)
              br 2 (;@3;)
            end
          end
          i32.const 1
          if ;; label = @4
            local.get 1
            call 36
            local.set 5
            br 3 (;@1;)
            br 1 (;@3;)
          end
          unreachable
        end
        unreachable
      end
      unreachable
    end
    local.get 5
  )
  (func (;47;) (type 78) (param i32 eqref)
    local.get 0
    call 41
    call 31
    call 46
    local.get 1
    call 33
    v128.const i32x4 0x4b414c42 0x76203345 0x6f746365 0x696d2072
    v128.const i32x4 0x74616d73 0x00006863 0x00000000 0x00000000
    array.new_fixed 85 2
    i32.const 0
    i32.const 22
    struct.new 86
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
  (func (;48;) (type 79)
    i32.const 0
    v128.const i32x4 0x33316661 0x39623934 0x39663566 0x36613161
    v128.const i32x4 0x30343061 0x61656434 0x63643633 0x39343963
    v128.const i32x4 0x62636239 0x39633532 0x31636461 0x37623231
    v128.const i32x4 0x61396363 0x61633339 0x66313465 0x32363233
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    i32.const 1
    v128.const i32x4 0x61336432 0x66646564 0x62313166 0x31663136
    v128.const i32x4 0x38386334 0x35336536 0x30616661 0x33373633
    v128.const i32x4 0x64636436 0x37613738 0x37326434 0x31633562
    v128.const i32x4 0x32303135 0x30643532 0x32393566 0x33313265
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    i32.const 64
    v128.const i32x4 0x64656534 0x31343137 0x61346165 0x34646335
    v128.const i32x4 0x38383762 0x62363036 0x66333264 0x32653634
    v128.const i32x4 0x66613231 0x63616339 0x63616265 0x64376364
    v128.const i32x4 0x63346631 0x37636436 0x31353266 0x38396231
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    i32.const 1024
    v128.const i32x4 0x31323234 0x39333734 0x35393066 0x36303461
    v128.const i32x4 0x63663366 0x65643338 0x39383862 0x61343437
    v128.const i32x4 0x64303063 0x31333866 0x64303163 0x35356161
    v128.const i32x4 0x62393831 0x32316435 0x35386331 0x37666135
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    i32.const 1025
    v128.const i32x4 0x32303064 0x65613837 0x62653734 0x33623732
    v128.const i32x4 0x65616634 0x37366663 0x65663462 0x66333632
    v128.const i32x4 0x35643238 0x39323134 0x31633631 0x39646666
    v128.const i32x4 0x63386337 0x62663762 0x62343138 0x34343438
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    i32.const 8193
    v128.const i32x4 0x36626162 0x63393063 0x65633862 0x34666338
    v128.const i32x4 0x36323935 0x38393331 0x37653264 0x33666561
    v128.const i32x4 0x30303735 0x38346662 0x36313138 0x39626563
    v128.const i32x4 0x36336134 0x35663064 0x37623166 0x62336362
    array.new_fixed 85 4
    i32.const 0
    i32.const 64
    struct.new 86
    call 47
    array.new_fixed 85 0
    i32.const 0
    i32.const 0
    struct.new 87
    call 32
    i32.const -1186393169
    i32.eq
    v128.const i32x4 0x4b414c42 0x68203345 0x33687361 0x616c2032
    v128.const i32x4 0x6320656e 0x676e6168 0x00006465 0x00000000
    array.new_fixed 85 2
    i32.const 0
    i32.const 26
    struct.new 86
    drop
    i32.eqz
    if ;; label = @1
      unreachable
    end
  )
)
